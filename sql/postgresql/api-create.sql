--
-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- Arjun Sanyal (arjun@openforce.net)
-- $Id$
--
--

select define_function_args ('portal_page__new','page_id,pretty_name,portal_id,layout_id,sort_key,object_type;portal_page,creation_date,creation_user,creation_ip,context_id');

create function portal_page__new (integer,varchar,integer,integer,integer,varchar,timestamp,integer,varchar,integer)
returns integer as '
declare
    p_page_id		alias for $1;
    p_pretty_name	alias for $2;
    p_portal_id		alias for $3;
    p_layout_id		alias for $4;
    p_sort_key		alias for $5;
    p_object_type	alias for $6;
    p_creation_date	alias for $7;
    p_create_user	alias for $8;
    p_creation_ip	alias for $9;
    p_context_id	alias for $10;
    v_page_id		portal_pages.page_id%TYPE;
    v_layout_id		portal_pages.layout_id%TYPE;
    v_sort_key		portal_pages.sort_key%TYPE;
begin
		v_page_id := acs_object__new (
			/* object_type	 */ p_object_type,
			/* creation_date */ p_creation_date,
			/* creation_user */ p_creation_user,
			/* creation_ip	 */ p_creation_ip,
			/* context_id	 */ p_context_id
		);

                if p_layout_id is null then             
                   select min(layout_id) into v_layout_id from portal_layouts;
                else 
                   v_layout_id := p_layout_id;
                end if;

                if p_portal_id is not null then             
                   select max(sort_key) + 1  into v_sort_key 
                   from portal_pages 
                   where portal_id = p_portal_id;                   
                   if v_sort_key is null then
                      v_sort_key := 0;
                   end if;
                else 
                    raise exception ''-20000, NULL portal_id sent to portal_page__new!'';
                end if;

		insert into portal_pages 
                       (page_id, pretty_name, portal_id, layout_id, sort_key)
		values (v_page_id, p_pretty_name, p_portal_id, v_layout_id, v_sort_key);

                return v_page_id;
end;' language 'plpgsql';


select define_function_args('portal_page__delete','page_id');

create function portal_page__delete (integer)
returns integer as '
declare
    p_page_id		integer;
begin
    delete from portal_pages where page_id = p_page_id;
    perform acs_object__delete(p_page_id);

    return 0;
end;' language 'plpgsql';


select define_function_args('portal__new','portal_id,name,theme_id,layout_id,portal_template_p,template_id,default_page_name,object_type;portal,creation_date,creation_user,creation_ip,context_id');

create function portal__new (integer,varchar,integer,integer,integer,boolean,integer,varchar,varchar,timestamp,integer,varchar,integer)
returns integer as '
declare
    p_portal_id		alias for $1;
    p_name		alias for $2;
    p_theme_id		alias for $3;
    p_layout_id		alias for $4;
    p_portal_template_p	alias for $5;
    p_template_id	alias for $6;
    p_default_page_name	alias for $7;
    p_object_type	alias for $8;
    p_creation_date	alias for $9;
    p_creation_user	alias for $10;
    p_creation_ip	alias for $11;
    p_context_id	alias for $12;
    v_portal_id		portals.portal_id%TYPE;
    v_theme_id		portals.theme_id%TYPE;
    v_layout_id		portal_layouts.layout_id%TYPE;
    v_page_id		portal_pages.page_id%TYPE;
    v_page		record;
begin

                -- we must create at least one page for this portal
		v_portal_id := acs_object__new (
			/* object_id	 */ p_portal_id,
			/* object_type	 */ p_object_type,
			/* creation_date */ p_creation_date,
			/* creation_user */ p_creation_user,
			/* creation_ip	 */ p_creation_ip,
			/* context_id	 */ p_context_id
		);

                if p_template_id is null then	       

                   if p_theme_id is null then
                      select max(theme_id) into v_theme_id from portal_element_themes;
                   else 
                        v_theme_id := p_theme_id;
                   end if;
                   
                   if p_layout_id is null then
                     select min(layout_id) into v_layout_id from portal_layouts;
                   else 
                     v_layout_id := p_layout_id;
                   end if;

                   insert into portals 
                          (portal_id, name, theme_id, portal_template_p)
                   values (v_portal_id, p_name, v_theme_id, p_portal_template_p);

                   -- now insert the default page
		   v_page_id := portal_page__new (
			/* portal_id	 */ v_portal_id,
			/* pretty_name   */ p_default_page_name,      
                        /* layout_id     */ v_layout_id,
			/* creation_date */ p_creation_date,
			/* creation_user */ p_creation_user,
			/* creation_ip	 */ p_creation_ip,
			/* context_id	 */ p_context_id
		   );
                else
                   -- we have to copy things like the template, theme form the 
                   --  templateportal_template_p is false. no chained templates 
                   select theme_id into v_theme_id 
                   from portals 
                   where portal_id = p_template_id;

                   insert into portals 
                   (portal_id, name, theme_id, portal_template_p, template_id)
                   values 
                   (v_portal_id, p_name,  v_theme_id, ''f'', p_template_id);

                   for v_page in select * 
				 from portal_pages 
				 where portal_id = p_template_id
		   loop
                       -- now insert the pages from the portal template
		       v_page_id := portal_page__new (
		            /* portal_id       */ v_portal_id,
		            /* pretty_name     */ v_page.pretty_name,      
                            /* layout_id       */ v_page.layout_id,
                            /* sort_key        */ v_page.sort_key
		       );                                      
                   end loop;
                end if;


		return v_portal_id;
end;' language 'plpgsql';


select define_function_args('portal__delete','portal_id');

create function portal__delete (integer)
returns integer as '
declare
    p_portal_id		alias for $1;
    v_page		record;
begin
    for v_page in select page_id
                  from portal_pages 
                  where portal_id = p_portal_id) 
    loop
        -- delete this portal''s pages
        perform portal_page__delete (
	    /* page_id       */ v_page.page_id
        );                                      
    end loop;

    perform acs_object__delete(p_portal_id);

    return 0;

end;' language 'plpgsql';

-- Portal element themes

select define_function_args('portal_element_theme__new','theme_id,name,description,filename,resource_dir,object_type;portal_element_theme,creation_date,creation_user,creation_ip,context_id');

create function portal_element_theme__new (integer,varchar,varchar,varchar,varchar,varchar,timestamp,integer,varchar,integer)
returns integer as '
declare
    p_theme_id		alias for $1;
    p_name		alias for $2;
    p_description	alias for $3;
    p_filename		alias for $4;
    p_resource_dir	alias for $5;
    p_object_type	alias for $6;
    p_creation_date	alias for $7;
    p_creation_user	alias for $8;
    p_creation_ip	alias for $9;
    p_context_id	alias for $10;
    v_theme_id		portal_element_themes.theme_id%TYPE;
begin
		v_theme_id := acs_object__new (
			/* object_id	 */ p_theme_id,
			/* object_type	 */ p_object_type,
			/* creation_date */ p_creation_date,
			/* creation_user */ p_creation_user,
			/* creation_ip	 */ p_creation_ip,
			/* context_id	 */ p_context_id
		);

		insert into portal_element_themes
			(theme_id, name, description, filename, resource_dir)
		values
			(v_theme_id, p_name, p_description, p_filename, p_resource_dir);

		return v_theme_id;
end;' language 'plpgsql';


create function portal_element_theme__new (varchar,varchar,varchar,varchar)
returns integer as '
declare
    p_name		alias for $1;
    p_description	alias for $2;
    p_filename		alias for $3;
    p_resource_dir	alias for $4;
    v_theme_id		portal_element_themes.theme_id%TYPE;
begin
    v_theme_id := portal_element_theme__new (
		      null,
	              p_name,
		      p_description,
		      p_filename,
		      p_resource_dir, 
		      ''portal_element_theme'',
		       now(),
		       null,
		       null,
		       null
		  );

    return v_theme_id;
end;' language 'plpgsql';


select define_function_args('portal_element_theme__delete','theme_id');

create function portal_element_theme__delete (integer)
returns integer as '
    p_theme_id		alias for $1;
begin
    perform acs_object__delete(p_theme_id);
    return (0);
end;' language 'plpgsql';


-- Portal layouts

select define_function_args('portal_layout__new','layout_id,name,description,filename,resource_dir,object_type;portal_layout,creation_date,creation_user,creation_ip,context_id');

create function portal_layout__new (integer,varchar,varchar,varchar,varchar,varchar,timestamp,integer,varchar,integer)
returns integer as '
declare
    p_layout_id		alias for $1;
    p_name		alias for $2;
    p_description	alias for $3;
    p_filename		alias for $4;
    p_resource_dir	alias for $5;
    p_object_type	alias for $6;
    p_creation_date	alias for $7;
    p_creation_user	alias for $8;
    p_creation_ip	alias for $9;
    p_context_id	alias for $10;
    v_layout_id		portal_layouts.layout_id%TYPE;
begin
		v_layout_id := acs_object__new (
			/* object_id	 */ p_layout_id,
			/* object_type	 */ p_object_type,
			/* creation_date */ p_creation_date,
			/* creation_user */ p_creation_user,
			/* creation_ip	 */ p_creation_ip,
			/* context_id	 */ p_context_id
		);

		insert into portal_layouts
			(layout_id, name, description, filename, resource_dir)
		values
			(v_layout_id, p_name, p_description,p_filename, p_resource_dir);

		return v_layout_id;
end;' language 'plpgsql';


create function portal_layout__new (varchar,varchar,varchar,varchar)
returns integer as '
declare
    p_name		alias for $1;
    p_description	alias for $2;
    p_filename		alias for $3;
    p_resource_dir	alias for $4;
    v_layout_id		portal_layouts.layout_id%TYPE;
begin

    v_layout_id := portal_layout__new (
		       null,
		       p_name,
		       p_description,
		       p_filename,
		       p_resource_dir,
		       ''portal_layout'',
		       now(),
		       null,
		       null,
		       null
		   );

    return v_layout_id;
end;' language 'plpgsql';


select define_function_args('portal_layout__delete','layout_id');

create function portal_layout__delete(integer)
returns integer as '
    p_layout_id		alias for $1;
begin
    perform acs_object__delete(layout_id);
    return 0;
end;' language 'plpgsql';


select define_function_args('portal_layout__add_region','layout_id,region,immutable_p;f');

create function portal_layout__add_region (integer,varchar,char)
returns integer as '
declare
    p_layout_id		alias for $1;
    p_region		alias for $2;
    p_immutable_p	alias for $3;
begin
    insert into portal_supported_regions (layout_id, region, immutable_p)
    values (p_layout_id, p_region, p_immutable_p);

    return 0;
end;' language 'plpgsql';


-- for the default to f, okay.
create function portal_layout__add_region (integer,varchar)
returns integer as '
declare
    p_layout_id		alias for $1;
    p_region		alias for $2;
begin
    insert into portal_supported_regions (layout_id, region, immutable_p)
    values (p_layout_id, p_region, ''f'');

    return 0;
end;' language 'plpgsql';



-- datasources

select define_function_args('portal_datasource__new','datasource_id,name,description,object_type;portal_datasource,creation_date,creation_user,creation_ip,context_id');

create function portal_datasource__new (integer,varchar,varchar,varchar,timestamp,integer,integer,integer)
returns integer as '
declare
    p_datasource_id		alias for $1;
    p_name			alias for $2;
    p_description		alias for $3;
    p_object_type		alias for $4;
    p_creation_date		alias for $5;
    p_creation_user		alias for $6;
    p_creation_ip		alias for $7;
    p_context_id		alias for $8;
    v_datasource_id		portal_datasources.datasource_id%TYPE;
begin
    v_datasource_id := acs_object__new (
	/* object_id	 */ p_datasource_id,
	/* object_type	 */ p_object_type,
	/* creation_date */ p_creation_date,
	/* creation_user */ p_creation_user,
	/* creation_ip	 */ p_creation_ip,
	/* context_id	 */ p_context_id
    );


    insert into portal_datasources
	(datasource_id, name, description)
    values
	(v_datasource_id, p_name, p_description); 

    return v_datasource_id;
end;' language 'plpgsql';


select define_function_args('portal_datasource__delete','datasource_id');

create function portal_datasource__delete (integer)
returns integer as '
declare
    p_datasource_id		alias for $1;
begin
    perform acs_object__delete(datasource_id);
    return 0;
end;' language 'plpgsql';


select define_function_args('portal_datasource__set_def_param','datasource_id,config_required_p,configured_p,key,value');

create function portal_datasource__set_def_param (integer,boolean,boolean,varchar)
returns integer as '
declare
    p_datasource_id		alias for $1;
    p_config_required_p		alias for $2;
    p_configured_p		alias for $3;
    p_key			alias for $4;
    p_value			alias for $5;
    v_parameter_id		portal_datasource_def_params.parameter_id%TYPE;
begin

    select acs_object_id_seq.nextval into v_parameter_id from dual;
		    
    insert into portal_datasource_def_params
	(parameter_id, datasource_id, config_required_p, configured_p, key, value)
    values
	(v_parameter_id, p_datasource_id, p_config_required_p, p_configured_p, p_key, p_value);

    return v_parameter_id;

end;' language 'plpgsql';