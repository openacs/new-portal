--
-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- Arjun Sanyal (arjun@openforce.net)
-- $Id$
--
--
-- XXX - Just a bare-bones API for now, needs work
-- 

-- func for creating a PE (copying from DS defaults)
--			  -- copy the portal_element_map entries
--			  insert into portal_element_map
--				  (portal_id, element_id, region, sort_key)
--			  select new.v_portal_id, m.element_id, m.region, m.sort_key
--			  from portal_element_map m
--			  where portal_id = new.parent_portal_id;
--

-- funcs in portal_element (not an acs_object in my DM)
--	procedure make_available (
--	procedure move (


create or replace package portal
as
	function new (
		portal_id		in portals.portal_id%TYPE default null,
		name			in portals.name%TYPE default null,
		layout_id		in portals.layout_id%TYPE default null,
		owner_id		in persons.person_id%TYPE default 0,
		object_type		in acs_object_types.object_type%TYPE default 'portal',
		creation_date		in acs_objects.creation_date%TYPE 
					default sysdate,
		creation_user		in acs_objects.creation_user%TYPE 
					default null,
		creation_ip		in acs_objects.creation_ip%TYPE default null, 
		context_id		in acs_objects.context_id%TYPE default null 
	) return portals.portal_id%TYPE;

	procedure delete (
		portal_id	in portals.portal_id%TYPE
	);
end portal;
/
show errors

create or replace package body portal
as
	function new (
		portal_id		in portals.portal_id%TYPE default null,
		name			in portals.name%TYPE default null,
		layout_id		in portals.layout_id%TYPE default null,
		owner_id		in persons.person_id%TYPE default 0,
		object_type		in acs_object_types.object_type%TYPE default 'portal',
		creation_date		in acs_objects.creation_date%TYPE 
					default sysdate,
		creation_user		in acs_objects.creation_user%TYPE 
					default null,
		creation_ip		in acs_objects.creation_ip%TYPE default null, 
		context_id		in acs_objects.context_id%TYPE default null 
	) return portals.portal_id%TYPE
	is
		v_portal_id portals.portal_id%TYPE;
	begin
		v_portal_id := acs_object.new (
			object_id	=> portal_id,
			object_type	=> object_type,
			creation_date	=> creation_date,
			creation_user	=> creation_user,
			creation_ip	=> creation_ip,
			context_id	=> context_id
		);

		insert into portals (portal_id, layout_id, name, owner_id) 
			     values (v_portal_id, layout_id, name,
			decode(owner_id, 0, NULL, owner_id)
		);

		return v_portal_id;
	end new;

	procedure delete (
		portal_id	in portals.portal_id%TYPE
	)
	is
	begin
		acs_object.delete(portal_id);
	end delete;

end portal;
/
show errors


-- Portal element themes
create or replace package portal_element_theme
as
	function new (
		theme_id		in portal_element_themes.theme_id%TYPE default null,
		name			in portal_element_themes.name%TYPE,
		description		in portal_element_themes.description%TYPE default null,
		filename		in portal_element_themes.filename%TYPE,
		resource_dir		in portal_element_themes.resource_dir%TYPE,
		object_type		in acs_object_types.object_type%TYPE default 'portal_element_theme',
		creation_date		in acs_objects.creation_date%TYPE 
					default sysdate,
		creation_user		in acs_objects.creation_user%TYPE 
					default null,
		creation_ip		in acs_objects.creation_ip%TYPE default null, 
		context_id		in acs_objects.context_id%TYPE default null 
	) return portal_element_themes.theme_id%TYPE;

	procedure delete (
		theme_id	in portal_element_themes.theme_id%TYPE
	);

end portal_element_theme;
/
show errors

create or replace package body portal_element_theme
as
	function new (
		theme_id		in portal_element_themes.theme_id%TYPE default null,
		name			in portal_element_themes.name%TYPE,
		description		in portal_element_themes.description%TYPE default null,
		filename		in portal_element_themes.filename%TYPE,
		resource_dir		in portal_element_themes.resource_dir%TYPE,
		object_type		in acs_object_types.object_type%TYPE default 'portal_element_theme',
		creation_date		in acs_objects.creation_date%TYPE 
					default sysdate,
		creation_user		in acs_objects.creation_user%TYPE 
					default null,
		creation_ip		in acs_objects.creation_ip%TYPE default null, 
		context_id		in acs_objects.context_id%TYPE default null 
	) return portal_element_themes.theme_id%TYPE
	is
		v_theme_id portal_element_themes.theme_id%TYPE;
	begin
		v_theme_id := acs_object.new (
			object_id	=> theme_id,
			object_type	=> object_type,
			creation_date	=> creation_date,
			creation_user	=> creation_user,
			creation_ip	=> creation_ip,
			context_id	=> context_id
		);

		insert into portal_element_themes
			(theme_id, name, description, filename, resource_dir)
		values
			(v_theme_id, name, description, filename, resource_dir);

		return v_theme_id;
	end new;

	procedure delete (
		theme_id	in portal_element_themes.theme_id%TYPE
	)
	is
	begin
		acs_object.delete(theme_id);
	end delete;

end portal_element_theme;
/
show errors

-- Portal layouts
create or replace package portal_layout
as
	function new (
		layout_id		in portal_layouts.layout_id%TYPE default null,
		name			in portal_layouts.name%TYPE,
		description		in portal_layouts.description%TYPE default null,
		filename		in portal_layouts.filename%TYPE,
		resource_dir		in portal_layouts.resource_dir%TYPE,
		object_type		in acs_object_types.object_type%TYPE default 'portal_layout',
		creation_date		in acs_objects.creation_date%TYPE 
					default sysdate,
		creation_user		in acs_objects.creation_user%TYPE 
					default null,
		creation_ip		in acs_objects.creation_ip%TYPE default null, 
		context_id		in acs_objects.context_id%TYPE default null 
	) return portal_layouts.layout_id%TYPE;

	procedure delete (
		layout_id	in portal_layouts.layout_id%TYPE
	);

	procedure add_region (
		layout_id		in portal_supported_regions.layout_id%TYPE,
		region			in portal_supported_regions.region%TYPE,
		immutable_p		in portal_supported_regions.immutable_p%TYPE default 'f'
	);

end portal_layout;
/
show errors

create or replace package body portal_layout
as
	function new (
		layout_id		in portal_layouts.layout_id%TYPE default null,
		name			in portal_layouts.name%TYPE,
		description		in portal_layouts.description%TYPE default null,
		filename		in portal_layouts.filename%TYPE,
		resource_dir		in portal_layouts.resource_dir%TYPE,
		object_type		in acs_object_types.object_type%TYPE default 'portal_layout',
		creation_date		in acs_objects.creation_date%TYPE 
					default sysdate,
		creation_user		in acs_objects.creation_user%TYPE 
					default null,
		creation_ip		in acs_objects.creation_ip%TYPE default null, 
		context_id		in acs_objects.context_id%TYPE default null 
	) return portal_layouts.layout_id%TYPE
	is
		v_layout_id portal_layouts.layout_id%TYPE;
	begin
		v_layout_id := acs_object.new (
			object_id	=> layout_id,
			object_type	=> object_type,
			creation_date	=> creation_date,
			creation_user	=> creation_user,
			creation_ip	=> creation_ip,
			context_id	=> context_id
		);

		insert into portal_layouts
			(layout_id, name, description, filename, resource_dir)
		values
			(v_layout_id, name, description,filename, resource_dir);

		return v_layout_id;
	end new;

	procedure delete (
		layout_id	in portal_layouts.layout_id%TYPE
	)
	is
	begin
		acs_object.delete(layout_id);
	end delete;

	procedure add_region (
		layout_id		in portal_supported_regions.layout_id%TYPE,
		region			in portal_supported_regions.region%TYPE,
		immutable_p		in portal_supported_regions.immutable_p%TYPE default 'f'
	)
	is
	begin
		insert into portal_supported_regions (layout_id, region, immutable_p)
		values (layout_id, region, immutable_p);
	end add_region;

end portal_layout;
/
show errors

-- datasources
create or replace package portal_datasource
as
	function new (
		datasource_id	in portal_datasources.datasource_id%TYPE default null,
		data_type	in portal_datasources.data_type%TYPE default null,
		mime_type	in portal_datasources.mime_type%TYPE default null,
		secure_p	in portal_datasources.secure_p%TYPE default null,
		configurable_p	in portal_datasources.configurable_p%TYPE default null,
		name		in portal_datasources.name%TYPE default null,
		description	in portal_datasources.description%TYPE default null,
		content		in portal_datasources.content%TYPE default null,
		content_varchar	varchar default null,
		object_type	in acs_object_types.object_type%TYPE default 'portal_datasource',
		creation_date	in acs_objects.creation_date%TYPE 
				default sysdate,
		creation_user	in acs_objects.creation_user%TYPE 
				default null,
		creation_ip	in acs_objects.creation_ip%TYPE default null, 
		context_id	in acs_objects.context_id%TYPE default null 
	) return portal_datasources.datasource_id%TYPE;

	procedure delete (
		datasource_id	in portal_datasources.datasource_id%TYPE
	);
end portal_datasource;
/
show errors

create or replace package body portal_datasource
as
	function new (
		datasource_id		in portal_datasources.datasource_id%TYPE default null,
		data_type		in portal_datasources.data_type%TYPE default null,
		mime_type		in portal_datasources.mime_type%TYPE default null,
		secure_p		in portal_datasources.secure_p%TYPE default null,
		configurable_p		in portal_datasources.configurable_p%TYPE default null,
		name			in portal_datasources.name%TYPE default null,
		description		in portal_datasources.description%TYPE default null,
		content			in portal_datasources.content%TYPE default null,
		config_varchar		varchar default null,
		config_content		in portal_datasources.config_content%TYPE default null,
		content_varchar		varchar default null,
		object_type		in acs_object_types.object_type%TYPE default 'portal_datasource',
		creation_date		in acs_objects.creation_date%TYPE 
					default sysdate,
		creation_user		in acs_objects.creation_user%TYPE 
					default null,
		creation_ip		in acs_objects.creation_ip%TYPE default null, 
		context_id		in acs_objects.context_id%TYPE default null 
	) return portal_datasources.datasource_id%TYPE
	is
		v_datasource_id		portal_datasources.datasource_id%TYPE;
		v_content_loc		portal_datasources.content%TYPE;
		v_config_content_loc	portal_datasources.config_content%TYPE;
	begin
		v_datasource_id := acs_object.new (
			object_id	=> datasource_id,
			object_type	=> object_type,
			creation_date	=> creation_date,
			creation_user	=> creation_user,
			creation_ip	=> creation_ip,
			context_id	=> context_id
		);

		if content_varchar is not null
		then
			dbms_lob.createtemporary(v_content_loc, TRUE);
			dbms_lob.write(v_content_loc, length(new.content_varchar), 1, new.content_varchar);
		else
			v_content_loc := content;
		end if;

		if config_varchar is not null
		then
			dbms_lob.createtemporary(v_config_content_loc, TRUE);
			dbms_lob.write(v_config_content_loc, length(new.config_content_varchar), 1, new.config_content_varchar);
		else
			v_config_content_loc := config_content;
		end if;

		insert into portal_datasources
			(datasource_id, data_type,
			mime_type, name, description, secure_p, configurable_p, content)
		values
			(v_datasource_id, data_type,
			mime_type, name, description, secure_p, configurable_p, v_content_loc); 

		return v_datasource_id;
	end new;

	procedure delete (
		datasource_id	in portal_datasources.datasource_id%TYPE
	)
	is
	begin
		acs_object.delete(datasource_id);
	end delete;

end portal_datasource;
/
show errors

-- AKS XXX Do we need an API for datasource def params?
