--
-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- Arjun Sanyal (arjun@openforce.net)
-- $Id$
--
--


create or replace package portal_page
as
	function new (
		page_id                 in portal_pages.page_id%TYPE default null,
		pretty_name		in portal_pages.pretty_name%TYPE default 'Untitled Page',
		portal_id		in portal_pages.portal_id%TYPE default null,
		layout_id		in portal_pages.layout_id%TYPE default null,
		sort_key		in portal_pages.sort_key%TYPE default 0,
		object_type		in acs_object_types.object_type%TYPE default 'portal_page',
		creation_date		in acs_objects.creation_date%TYPE 
					default sysdate,
		creation_user		in acs_objects.creation_user%TYPE 
					default null,
		creation_ip		in acs_objects.creation_ip%TYPE default null, 
		context_id		in acs_objects.context_id%TYPE default null 
	) return portal_pages.page_id%TYPE;

	procedure delete (
		page_id                 in portal_pages.page_id%TYPE
	);
end portal_page;
/
show errors

create or replace package body portal_page
as
	function new (
		page_id                 in portal_pages.page_id%TYPE default null,
		pretty_name		in portal_pages.pretty_name%TYPE default 'Untitled Page',
		portal_id		in portal_pages.portal_id%TYPE default null,
		layout_id		in portal_pages.layout_id%TYPE default null,
		sort_key		in portal_pages.sort_key%TYPE default 0,
		object_type		in acs_object_types.object_type%TYPE default 'portal_page',
		creation_date		in acs_objects.creation_date%TYPE 
					default sysdate,
		creation_user		in acs_objects.creation_user%TYPE 
					default null,
		creation_ip		in acs_objects.creation_ip%TYPE default null, 
		context_id		in acs_objects.context_id%TYPE default null 
	) return portal_pages.page_id%TYPE
	is
		v_page_id portal_pages.page_id%TYPE;
		v_layout_id portal_pages.layout_id%TYPE;
		v_sort_key portal_pages.sort_key%TYPE;
                v_current_page_count integer;       
	begin
		v_page_id := acs_object.new (
			object_type	=> object_type,
			creation_date	=> creation_date,
			creation_user	=> creation_user,
			creation_ip	=> creation_ip,
			context_id	=> context_id
		);

                if layout_id is null then             
                   select min(layout_id) into v_layout_id from portal_layouts;
                else 
                   v_layout_id := layout_id;
                end if;

                if portal_id is not null then             
                   select max(sort_key) + 1  into v_sort_key 
                   from portal_pages 
                   where portal_id = portal_page.new.portal_id;                   
                   if v_sort_key is null then
                      v_sort_key := 0;
                   end if;
                else 
                    raise_application_error(-20000, 'NULL portal_id sent to portal_page.new!');
                end if;

		insert into portal_pages 
                       (page_id, pretty_name, portal_id, layout_id, sort_key)
		values (v_page_id, pretty_name, portal_id, v_layout_id, v_sort_key);

                select count(*) into v_current_page_count 
                from portal_current_page
                where portal_id = portal_page.new.portal_id;
                
                if v_current_page_count = 0 then
                   insert into portal_current_page
                   (portal_id, page_id) values (portal_page.new.portal_id, v_page_id);
                else
                   update portal_current_page 
                   set page_id = v_page_id
                   where portal_id = portal_id;

--                   raise_application_error(-20000, 'aks1 just UPDATED portal_current_page with page_id ' || v_page_id || ' portal_id ' || portal_id || ' page count ' || v_current_page_count); 
                end if;

                return v_page_id;
	end new;

	procedure delete (
		page_id         in portal_pages.page_id%TYPE
	)
	is
	begin
                delete from portal_current_page where page_id = portal_page.delete.page_id;
                delete from portal_pages where page_id = portal_page.delete.page_id;
                
                acs_object.delete(page_id);
	end delete;

end portal_page;
/
show errors

create or replace package portal
as
    function new (
        portal_id		in portals.portal_id%TYPE default null,
        name			in portals.name%TYPE default 'Untitled',
        theme_id		in portals.theme_id%TYPE default null,
        layout_id		in portal_layouts.layout_id%TYPE default null,
        portal_template_p	in portals.portal_template_p%TYPE default 'f',
        template_id		in portals.template_id%TYPE default null,
        default_page_name       in portal_pages.pretty_name%TYPE default 'Main Page',
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
		theme_id		in portals.theme_id%TYPE default null,
		layout_id		in portal_layouts.layout_id%TYPE default null,
		portal_template_p	in portals.portal_template_p%TYPE default 'f',
		template_id		in portals.template_id%TYPE default null,
                default_page_name       in portal_pages.pretty_name%TYPE default 'Main Page',
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
		v_page_id portal_pages.page_id%TYPE;
	begin

                -- we must create at least one page for this portal
		v_portal_id := acs_object.new (
			object_id	=> portal_id,
			object_type	=> object_type,
			creation_date	=> creation_date,
			creation_user	=> creation_user,
			creation_ip	=> creation_ip,
			context_id	=> context_id
		);

                if template_id is null then	       
                   select max(theme_id) into v_theme_id from portal_element_themes;

                   if layout_id is null then
                     select min(layout_id) into v_layout_id from portal_layouts;
                   else 
                     v_layout_id := portal.new.layout_id;
                   end if;

                   insert into portals 
                          (portal_id, name, theme_id, portal_template_p)
                   values (v_portal_id, name, v_theme_id, portal_template_p);

                   -- now insert the default page
		   v_page_id := portal_page.new (
			portal_id	=> v_portal_id,
			pretty_name     => default_page_name,      
                        layout_id       => v_layout_id,
			creation_date	=> creation_date,
			creation_user	=> creation_user,
			creation_ip	=> creation_ip,
			context_id	=> context_id
		   );
                else
                   -- we have to copy things like the template, theme form the 
                   --  templateportal_template_p is false. no chained templates 
                   select theme_id into v_theme_id 
                   from portals 
                   where portal_id = portal.new.template_id;

                   insert into portals 
                   (portal_id, name, theme_id, portal_template_p, template_id)
                   values 
                   (v_portal_id, name,  v_theme_id, 'f', portal.new.template_id);

                   for page in (select * from portal_pages where portal_id = portal.new.template_id) loop
                       -- now insert the pages from the portal template
		       v_page_id := portal_page.new (
		            portal_id       => v_portal_id,
		            pretty_name     => page.pretty_name,      
                            layout_id       => page.layout_id,
                            sort_key        => page.sort_key
		       );                                      
                   end loop;
                end if;


		return v_portal_id;
	end new;

	procedure delete (
		portal_id	in portals.portal_id%TYPE
	)
	is
	begin
                  for page in (select page_id
                               from portal_pages 
                               where portal_id = portal.delete.portal_id) 
                  loop
                       -- delete this portal's pages
		       portal_page.delete (
		            page_id       => page.page_id
                       );                                      
                   end loop;

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
