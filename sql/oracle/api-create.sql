--
-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- Arjun Sanyal (arjun@openforce.net)
-- $Id$
--
--

create or replace package portal
as
	function new (
		portal_id		in portals.portal_id%TYPE default null,
		name			in portals.name%TYPE default 'Untitled',
		layout_id		in portals.layout_id%TYPE default null,
		theme_id		in portals.theme_id%TYPE default null,
		portal_template_p	in portals.portal_template_p%TYPE default 'f',
		template_id		in portals.template_id%TYPE default null,
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
		name			in portals.name%TYPE default 'Untitled',
		layout_id		in portals.layout_id%TYPE default null,
		theme_id		in portals.theme_id%TYPE default null,
		portal_template_p	in portals.portal_template_p%TYPE default 'f',
		template_id		in portals.template_id%TYPE default null,
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
		v_theme_id portals.theme_id%TYPE;
		v_layout_id portal_layouts.layout_id%TYPE;
	begin
		v_portal_id := acs_object.new (
			object_id	=> portal_id,
			object_type	=> object_type,
			creation_date	=> creation_date,
			creation_user	=> creation_user,
			creation_ip	=> creation_ip,
			context_id	=> context_id
		);



		-- if we don't have a template_id this is a stand-alone portal
		if template_id is null then	       
		   select max(theme_id) into v_theme_id from portal_element_themes;
		   select min(layout_id) into v_layout_id from portal_layouts;

		   insert into portals 
			  (portal_id, name, layout_id, theme_id)
		   values (v_portal_id, name, v_layout_id, v_theme_id);

		else
		-- we have to copy things like the template, theme form the template
		-- portal_template_p is false. no chained templates yet
		select theme_id, layout_id into v_theme_id, v_layout_id 
		from portals where portal_id = portal.new.template_id;

		   insert into portals 
			  (portal_id, name, layout_id, theme_id, portal_template_p, template_id)
		   values (v_portal_id, name, v_layout_id, v_theme_id, 'f', portal.new.template_id);



		end if;

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
		name		in portal_datasources.name%TYPE default null,
		description	in portal_datasources.description%TYPE default null,
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

	procedure set_def_param (
		datasource_id		in portal_datasource_def_params.datasource_id%TYPE,
		config_required_p	in portal_datasource_def_params.config_required_p%TYPE default null,
		configured_p		in portal_datasource_def_params.configured_p%TYPE default null,
		key			in portal_datasource_def_params.key%TYPE,
		value			in portal_datasource_def_params.value%TYPE default null
	);


end portal_datasource;
/
show errors

create or replace package body portal_datasource
as
	function new (
		datasource_id		in portal_datasources.datasource_id%TYPE default null,	
		name			in portal_datasources.name%TYPE default null,
		description		in portal_datasources.description%TYPE default null,
		object_type		in acs_object_types.object_type%TYPE default 'portal_datasource',
		creation_date		in acs_objects.creation_date%TYPE default sysdate,
		creation_user		in acs_objects.creation_user%TYPE default null,
		creation_ip		in acs_objects.creation_ip%TYPE default null, 
		context_id		in acs_objects.context_id%TYPE default null 

	) return portal_datasources.datasource_id%TYPE
	is
		v_datasource_id		portal_datasources.datasource_id%TYPE;
	begin
		v_datasource_id := acs_object.new (
			object_id	=> datasource_id,
			object_type	=> object_type,
			creation_date	=> creation_date,
			creation_user	=> creation_user,
			creation_ip	=> creation_ip,
			context_id	=> context_id
		);


		insert into portal_datasources
			(datasource_id, name, description)
		values
			(v_datasource_id, name, description); 

		return v_datasource_id;
	end new;

	procedure delete (
		datasource_id	in portal_datasources.datasource_id%TYPE
	)
	is
	begin
		acs_object.delete(datasource_id);
	end delete;

	procedure set_def_param (
		datasource_id		in portal_datasource_def_params.datasource_id%TYPE,
		config_required_p	in portal_datasource_def_params.config_required_p%TYPE default null,
		configured_p		in portal_datasource_def_params.configured_p%TYPE default null,
		key			in portal_datasource_def_params.key%TYPE,
		value			in portal_datasource_def_params.value%TYPE default null
	)
	is
		v_parameter_id  portal_datasource_def_params.parameter_id%TYPE;
	begin

		select acs_object_id_seq.nextval into v_parameter_id from dual;
		    
		insert into portal_datasource_def_params
			(parameter_id, datasource_id, config_required_p, configured_p, key, value)
		values
			(v_parameter_id, datasource_id, config_required_p, configured_p, key, value);

	end set_def_param;

end portal_datasource;
/
show errors
