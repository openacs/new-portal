-- The "New" Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- arjun@openforce.net
-- started Sept. 26, 2001

-- **** DATASOURCES ****

create table portal_mime_types (
	name		varchar(200)
			constraint p_mime_types_name_pk primary key,
	pretty_name	varchar(200),
);

create table portal_data_types (
	name		varchar(200)
			constraint p_data_types_name_pk primary key,
	pretty_name	varchar(200) not null,
);

-- XXX Fix me. The central issue here is how to model the DS's
-- metadata, args, etc.  acs-service-contract?  On the issue of
-- default configs for PE's, the DS should hold this somehow

-- Some datasources need to be restricted and some do not.  The way we
-- will handle this is a check at PE creation (DS binding) time.
create table portal_datasources (
	datasource_id		constraint p_datasources_datasource_id_fk
				references acs_objects(object_id)
				constraint p_datasources_datasource_id_pk
				primary key,
	data_type		constraint p_datasources_data_type_fk
				references portal_data_types(name)
				not null,
	mime_type		constraint p_datasources_mimetype_fk
				references portal_mime_types(name)
				not null,
	-- lame flag until real metadata arrives
	secure_p		char(1) default 'f'
				constraint p_datasources_secure_p_ck
				check(secure_p in ('t', 'f')),
	configurable_p		char(1) default 'f'
				constraint p_elements_configurable_p_ck
				check(configurable_p in ('t', 'f')),
	name			varchar(200),
	description		varchar(4000),
	-- these may go when acs-service-contract arrives
	content			clob,
	package_key		constraint p_datasources_package_key_fk
				references apm_package_types(package_key) on delete cascade,
	constraint p_name_package_key_un unique(package_key,name)
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
	filename		varchar(4000) not null,
	resource_dir		varchar(4000)
);



-- **** Portal Element Themes ****

-- Themes are templates with decoration for PEs, nothing more.
-- At this point they will just be bits of ADPs stuffed into the DB or in
-- the filesystem
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
	storage			varchar(20)
				constraint p_e_themes_type_ck
				check(storage in ('db', 'fs')),
	filename		varchar(4000),
	resource_dir		varchar(4000), 
	db_storage		varchar(4000)
);


-- XXX configs

-- **** Portal Elements (PEs) ****

-- PE are fully owned by one and only one portal. They are not
-- "objects" that live on after their portal is gone. One way to think
-- of them is a map b/w a portal and a DS, with satellite data of a
-- theme, a config, a region, etc. 
--
-- No securtiy checks are done here. If you can view and bind to a DS you have
-- a PE.

create table portal_element_map (
	element_id		constraint p_element_map_element_id_pk
				primary key,
	name			varchar(200) not null,
	datasource_id		constraint p_element_map_datasource_id_fk
				references portal_datasources
				on delete cascade
				not null,
	theme_id		constraint p_element_map_theme_id_fk
				references portal_element_themes
				not null,
	portal_id		constraint p_element_map_portal_id_fk
				references portals on delete cascade
				not null,
				not null,
	region varchar(20)	not null,
	sort_key integer	not null,
	-- Two elements may not exist in the same place on a portal.
	-- It would probably work, but it would just be stupid.
	constraint p_element_map_pid_rgn_srt_un unique(portal_id,region,sort_key)
);

-- Portals are essentially "containers" for PEs that bind to DSs.
-- XXX Can parties have portals?
create table portals (
	portal_id	 	constraint p_portal_id_fk
				references acs_objects(object_id)
				constraint p_portal_id_pk
				primary key,
	name			varchar(200) default 'Untitled' not null,
        -- the layout template.
	layout_id		constraint p_template_id_fk
				references portal_templates
				not null
	-- nobody owns a portal except for a person (parties create
	-- their own package instances).  I didn't like this about the
	-- old portals data model, but it does make sense.  If this is
	-- null then it's the "default portal" and is -- owned by
	-- nobody.  If this comment confuses you, email me. -ib

	owner_id		constraint p_owner_id_fk
				references persons(person_id)
				on delete cascade,
	-- it's only possible to own one personal version of any portal.  This constraint may
        -- someday be relaxed if it turns out that there's a need to.
	constraint p_owner_package_un unique(package_id,owner_id)
);

-- INDEX owner_id
-- INDEX package_id


-- p_page = portal page
-- pe = portal element i.e. a "box" on a p_page
-- "->" arrows point to a "to-one" relationship

-- p_page_id sequence

-- p_page table
-- name varchar
-- acs_object?
-- restrict_to_party_p
-- owning_party
-- fk(layout)
-- perms?

-- pe table
-- perms?

-- layout table

-- pe_configs table
-- config_id pk
-- portal_id?

-- pe_parameters table
-- this is needed for default configs not associated with no p_page
-- param_id pk
-- config_id refs(pe_configs)
-- key
-- value

-- datasource table
-- configureable_p?
-- default_config_id refs(portal_element_configs)
1


-- pe <-> datasource map

-- p_page <-> pe mapping table, with config_id
-- unique(p_page, pe), index

-- config_id <- attr table




