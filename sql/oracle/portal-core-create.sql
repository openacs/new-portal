-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- arjun@openforce.net
-- $Id$

-- **** DATASOURCES ****

create table portal_mime_types (
	name		varchar(200)
			constraint p_mime_types_name_pk primary key,
	pretty_name	varchar(200)
);

-- secure_p is for an extra layer of security. See defualts.sql
create table portal_data_types (
	name		varchar(200)
			constraint p_data_types_name_pk primary key,
	pretty_name	varchar(200),
	secure_p	char(1) default 'f'
			constraint p_data_types_secure_p_ck
			check(secure_p in ('t', 'f'))
);


-- XXX A central unresolved issue here is how to model the DS's
-- metadata, args, etc.  acs-service-contract?

-- Some datasources need to be restricted and some do not.  The way we
-- will handle this is a check at PE creation (DS binding) time, and
-- of course, checks on the portal_id sent in.
create table portal_datasources (
	datasource_id		constraint p_datasources_datasource_id_fk
				references acs_objects(object_id)
				constraint p_datasources_datasource_id_pk
				primary key,
	data_type		constraint p_datasources_data_type_fk
				references portal_data_types(name)
				not null,
	mime_type		constraint p_datasources_mime_type_fk
				references portal_mime_types(name)
				not null,
	-- lame flag until real metadata arrives
	secure_p		char(1) default 'f'
				constraint p_datasources_secure_p_ck
				check(secure_p in ('t', 'f')),
	configurable_p		char(1) default 'f'
				constraint p_elements_configurable_p_ck
				check(configurable_p in ('t', 'f')),
	name			varchar(200) not null,
	description		varchar(4000),
	config_content		clob,
	content			clob
);


-- A default configuration for a ds will be stored here, to be copied
-- to the portal_element_parameters table at PE creation (DS binding) time
-- 
-- Config semantics:
-- true: cfg_req, cfg_p - A static config is given for all PEs, can
--	 be changed later
-- true: cfg_req false: cfg_p - PE must be configured before use
-- false: cfg_req true: cfg_p - An optional default cfg given
-- both false: Configuration optional w. no default suggested
create table portal_datasource_def_params (
	parameter_id		integer
				constraint p_ds_def_prms_prm_id_pk
				primary key,
	datasource_id		constraint p_ds_def_prms_element_id_fk
				references portal_datasources on delete cascade
				not null,
	config_required_p	char(1) default 'f'
				constraint p_ds_def_prms_cfg_req_p_ck
				check(config_required_p in ('t', 'f')),
	configured_p		char(1) default 'f'
				constraint p_ds_def_prms_configured_p_ck
				check(configured_p in ('t', 'f')),
	key		varchar(50) not null,
	value		varchar(4000)
);


-- **** Portal Layouts ****

-- Layouts are the template for the portal page. i.e. 2 cols, 3 cols,
-- etc. They are globally available. No secret layouts!
create table portal_layouts (
	layout_id		constraint p_layouts_layout_id_fk
				references acs_objects(object_id)
				constraint p_layouts_layout_id_pk
				primary key,
	name			varchar(200)
				constraint p_layouts_name_un
				unique
				not null,
	description		varchar(4000),
	filename		varchar(4000),
	resource_dir		varchar(4000)
);

create table portal_supported_regions (
	  layout_id		constraint p_spprtd_rgns_layout_id_fk
				references portal_layouts
				on delete cascade
				not null,
	  region		varchar(20) not null,
	  immutable_p		char(1) not null
				constraint p_spprtd_rgns_immtble_p_ck
				check(immutable_p in ('t', 'f')),
	  constraint p_spprtd_rgns_tmpl_id_rgn_pk primary key (layout_id,region)
);


-- **** Portal Element Themes ****

-- Themes are templates with decoration for PEs, nothing more.
-- At this point they will just be bits of ADPs  in the filesystem
create table portal_element_themes (
	theme_id		constraint p_e_themes_theme_id_fk
				references acs_objects(object_id)
				constraint p_e_themes_theme_id_pk
				primary key,
	name			varchar(200)
				constraint p_e_themes_name_un
				unique
				not null,
	description		varchar(4000),
	filename		varchar(4000),
	resource_dir		varchar(4000)
);


-- **** Portals ****

-- Portals are essentially "containers" for PEs that bind to DSs.
-- Parties have, optionally have portals 
-- Restrict to party check? 
-- Roles and perms issues? 
create table portals (
	portal_id	 	constraint p_portal_id_fk
				references acs_objects(object_id)
				constraint p_portal_id_pk
				primary key,
	name			varchar(200) default 'Untitled' not null,
	layout_id		constraint p_template_id_fk
				references portal_layouts
				not null,
	owner_id		constraint p_owner_id_fk
				references parties(party_id)
				on delete cascade
);

-- **** Portal Elements (PEs) ****


-- PE are fully owned by one and only one portal. They are not
-- "objects" that live on after their portal is gone. One way to think
-- of them is a map b/w a portal and a DS, with satellite data of a
-- theme, a config, a region, etc. 
--
-- No securtiy checks are done here. If you can view and bind to a DS you have
-- a PE for it.

create table portal_element_map (
	element_id		integer
				constraint p_element_map_element_id_pk
				primary key,
	name			varchar(200) not null,
	portal_id		constraint p_element_map_portal_id_fk
				references portals on delete cascade
				not null,
	datasource_id		constraint p_element_map_datasource_id_fk
				references portal_datasources
				on delete cascade
				not null,
	theme_id		constraint p_element_map_theme_id_fk
				references portal_element_themes
				not null,
	region			varchar(20) not null,
	sort_key		integer	not null,
 	-- Two elements may not exist in the same place on a portal.
	constraint p_element_map_pid_rgn_srt_un 
	unique(portal_id,region,sort_key),
 	-- Two elements may not have the same name on a portal.
	constraint p_element_map_pid_name_un 
	unique(portal_id,name)
);

create table portal_element_parameters (
	parameter_id		integer
				constraint p_element_prms_prm_id_pk
				primary key,
	element_id		constraint p_element_prms_element_id_fk
				references portal_element_map on delete cascade
				not null,
	config_required_p	char(1) default 'f'
				constraint p_element_prms_cfg_req_p_ck
				check(config_required_p in ('t', 'f')),
	configured_p		char(1) default 'f'
				constraint p_element_prms_configured_p_ck
				check(configured_p in ('t', 'f')),
	key			varchar(50) not null,
	value			varchar(4000) 
);



