--
--  Copyright (C) 2001, 2002 MIT
--
--  This file is part of dotLRN.
--
--  dotLRN is free software; you can redistribute it and/or modify it under the
--  terms of the GNU General Public License as published by the Free Software
--  Foundation; either version 2 of the License, or (at your option) any later
--  version.
--
--  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
--  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
--  details.
--

--
-- The New Portal Package
-- copyright 2001, MIT
-- distributed under the GNU GPL v2
--
-- @author Arjun Sanyal (arjun@openforce.net)
-- @version $Id$
--

select define_function_args('portal_page__new','page_id,pretty_name,accesskey,portal_id,layout_id,hidden_p,object_type;portal_page,creation_date,creation_user,creation_ip,context_id');

create function portal_page__new (integer,varchar,varchar,integer,integer,char,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
    p_page_id                       alias for $1;
    p_pretty_name                   alias for $2;
    p_accesskey                     alias for $3;
    p_portal_id                     alias for $4;
    p_layout_id                     alias for $5;
    p_hidden_p                      alias for $6;
    p_object_type                   alias for $7;
    p_creation_date                 alias for $8;
    p_creation_user                 alias for $9;
    p_creation_ip                   alias for $10;
    p_context_id                    alias for $11;
    v_page_id                       portal_pages.page_id%TYPE;
    v_layout_id                     portal_pages.layout_id%TYPE;
    v_sort_key                      portal_pages.sort_key%TYPE;
begin

    v_page_id := acs_object__new(
        null,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        p_context_id,
        ''t''
    );

    if p_layout_id is null then
        select min(layout_id)
        into v_layout_id
        from portal_layouts;
    else
        v_layout_id := p_layout_id;
    end if;

    select coalesce(max(sort_key) + 1, 0)
    into v_sort_key
    from portal_pages
    where portal_id = p_portal_id;

    insert into portal_pages
    (page_id, pretty_name, accesskey, portal_id, layout_id, sort_key, hidden_p)
    values
    (v_page_id, p_pretty_name, p_accesskey, p_portal_id, v_layout_id, v_sort_key, p_hidden_p);

    return v_page_id;

end;' language 'plpgsql';

select define_function_args('portal_page__delete','page_id');

create function portal_page__delete(integer)
returns integer as '
declare
    p_page_id                       alias for $1;
    v_portal_id                     portal_pages.portal_id%TYPE;
    v_sort_key                      portal_pages.sort_key%TYPE;
    v_curr_sort_key                 portal_pages.sort_key%TYPE;
    v_page_count_from_0             integer;
begin

    -- IMPORTANT: sort keys MUST be an unbroken sequence from 0 to max(sort_key)

    select portal_id, sort_key
    into v_portal_id, v_sort_key
    from portal_pages
    where page_id = p_page_id;

    select (count(*) - 1)
    into v_page_count_from_0
    from portal_pages
    where portal_id = v_portal_id;

    for i in 0 .. v_page_count_from_0 loop

        if i = v_sort_key then

            delete
            from portal_pages
            where page_id = p_page_id;

        elsif i > v_sort_key then

            update portal_pages
            set sort_key = -1
            where sort_key = i
	    and page_id = p_page_id;

            update portal_pages
            set sort_key = i - 1
            where sort_key = -1
	    and page_id = p_page_id;

        end if;

    end loop;

    perform acs_object__delete(p_page_id);

    return 0;

end;' language 'plpgsql';

select define_function_args('portal__new','portal_id,name,theme_id,layout_id,template_id,default_page_name,default_accesskey,object_type;portal,creation_date,creation_user,creation_ip,context_id');

create or replace function portal__new (integer,varchar,integer,integer,integer,varchar,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
    p_portal_id                     alias for $1;
    p_name                          alias for $2;
    p_theme_id                      alias for $3;
    p_layout_id                     alias for $4;
    p_template_id                   alias for $5;
    p_default_page_name             alias for $6;
    p_default_accesskey             alias for $7;
    p_object_type                   alias for $8;
    p_creation_date                 alias for $9;
    p_creation_user                 alias for $10;
    p_creation_ip                   alias for $11;
    p_context_id                    alias for $12;
    v_portal_id                     portals.portal_id%TYPE;
    v_theme_id                      portals.theme_id%TYPE;
    v_layout_id                     portal_layouts.layout_id%TYPE;
    v_page_id                       portal_pages.page_id%TYPE;
    v_page                          record;
    v_element                       record;
    v_param                         record;
    v_new_element_id                integer;
    v_new_parameter_id              integer;
begin

    v_portal_id := acs_object__new(
        p_portal_id,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        p_context_id,
        ''t''
    );

    if p_template_id is null then

        if p_theme_id is null then
            select max(theme_id)
            into v_theme_id
            from portal_element_themes;
        else
            v_theme_id := p_theme_id;
        end if;

        if p_layout_id is null then
            select min(layout_id)
            into v_layout_id
            from portal_layouts;
        else
            v_layout_id := p_layout_id;
        end if;

        insert
        into portals
        (portal_id, name, theme_id)
        values
        (v_portal_id, p_name, v_theme_id);

        -- now insert the default page
        v_page_id := portal_page__new(
            null,
            p_default_page_name,
            p_default_accesskey,
            v_portal_id,
            v_layout_id,
            ''f'',
            ''portal_page'',
            p_creation_date,
            p_creation_user,
            p_creation_ip,
            p_context_id
        );

    else

        -- we have a portal as our template. copy its theme, pages, layouts,
        -- elements, and element params.
        select theme_id
        into v_theme_id
        from portals
        where portal_id = p_template_id;

        insert
        into portals
        (portal_id, name, theme_id, template_id)
        values
        (v_portal_id, p_name, v_theme_id, p_template_id);

        -- now insert the pages from the portal template
        for v_page in select *
                      from portal_pages
                      where portal_id = p_template_id
		      order by sort_key
        loop

            v_page_id := portal_page__new(
            null,
            v_page.pretty_name,
            v_page.accesskey,
            v_portal_id,
            v_page.layout_id,
            ''f'',
            ''portal_page'',
            p_creation_date,
            p_creation_user,
            p_creation_ip,
            p_context_id
            );

            -- now get the elements on the templates page and put them on the new page
            for v_element in select * 
                           from portal_element_map 
                           where page_id = v_page.page_id
            loop

                select acs_object_id_seq.nextval
                into v_new_element_id
                from dual;

                insert
                into portal_element_map
                (element_id, name, pretty_name, page_id, datasource_id, region, state, sort_key)
                select v_new_element_id, name, pretty_name, v_page_id, datasource_id, region, state, sort_key
                from portal_element_map pem
                where pem.element_id = v_element.element_id;

                -- now for the elements params
                for v_param in select * 
                             from portal_element_parameters 
                             where element_id = v_element.element_id
                loop

                    select acs_object_id_seq.nextval
                    into v_new_parameter_id
                    from dual;

                    insert
                    into portal_element_parameters
                    (parameter_id, element_id, config_required_p, configured_p, key, value)
                    select v_new_parameter_id, v_new_element_id, config_required_p, configured_p, key, value
                    from portal_element_parameters
                    where parameter_id = v_param.parameter_id;

                end loop;

            end loop;

        end loop;

    end if;

    return v_portal_id;

end;' language 'plpgsql';

select define_function_args('portal__delete','portal_id');

create function portal__delete (integer)
returns integer as '
declare
    p_portal_id                     alias for $1;
    v_page                          record;
begin

    for v_page in select page_id
                  from portal_pages
                  where portal_id = p_portal_id
    loop
        perform portal_page__delete(v_page.page_id);
    end loop;

    perform acs_object__delete(p_portal_id);

    return 0;

end;' language 'plpgsql';

select define_function_args('portal_element_theme__new','theme_id,name,description,filename,resource_dir,object_type;portal_element_theme,creation_date,creation_user,creation_ip,context_id');

create function portal_element_theme__new (integer,varchar,varchar,varchar,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
    p_theme_id                      alias for $1;
    p_name                          alias for $2;
    p_description                   alias for $3;
    p_filename                      alias for $4;
    p_resource_dir                  alias for $5;
    p_object_type                   alias for $6;
    p_creation_date                 alias for $7;
    p_creation_user                 alias for $8;
    p_creation_ip                   alias for $9;
    p_context_id                    alias for $10;
    v_theme_id                      portal_element_themes.theme_id%TYPE;
begin

    v_theme_id := acs_object__new(
        p_theme_id,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        p_context_id,
        ''t''
    );

    insert
    into portal_element_themes
    (theme_id, name, description, filename, resource_dir)
    values
    (v_theme_id, p_name, p_description, p_filename, p_resource_dir);

    return v_theme_id;

end;' language 'plpgsql';

create function portal_element_theme__new (varchar,varchar,varchar,varchar)
returns integer as '
declare
    p_name                          alias for $1;
    p_description                   alias for $2;
    p_filename                      alias for $3;
    p_resource_dir                  alias for $4;
    v_theme_id                      portal_element_themes.theme_id%TYPE;
begin

    v_theme_id := portal_element_theme__new(
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

create or replace function portal_element_theme__delete (integer)
returns integer as '
declare
    p_theme_id                      alias for $1;
begin
    PERFORM acs_object__delete(p_theme_id);

    return (0);
end;' language 'plpgsql';

select define_function_args('portal_layout__new','layout_id,name,description,filename,resource_dir,object_type;portal_layout,creation_date,creation_user,creation_ip,context_id');

create function portal_layout__new (integer,varchar,varchar,varchar,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
    p_layout_id                     alias for $1;
    p_name                          alias for $2;
    p_description                   alias for $3;
    p_filename                      alias for $4;
    p_resource_dir                  alias for $5;
    p_object_type                   alias for $6;
    p_creation_date                 alias for $7;
    p_creation_user                 alias for $8;
    p_creation_ip                   alias for $9;
    p_context_id                    alias for $10;
    v_layout_id                     portal_layouts.layout_id%TYPE;
begin

    v_layout_id := acs_object__new(
        p_layout_id,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        p_context_id,
        ''t''
    );

    insert into portal_layouts
    (layout_id, name, description, filename, resource_dir)
    values
    (v_layout_id, p_name, p_description, p_filename, p_resource_dir);

    return v_layout_id;

end;' language 'plpgsql';

create function portal_layout__new (varchar,varchar,varchar,varchar)
returns integer as '
declare
    p_name                          alias for $1;
    p_description                   alias for $2;
    p_filename                      alias for $3;
    p_resource_dir                  alias for $4;
    v_layout_id                     portal_layouts.layout_id%TYPE;
begin

    v_layout_id := portal_layout__new(
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

create or replace function portal_layout__delete(integer)
returns integer as '
declare
    p_layout_id                     alias for $1;
begin
    perform acs_object__delete(layout_id);
    return 0;
end;' language 'plpgsql';

select define_function_args('portal_layout__add_region','layout_id,region,immutable_p;f');

create function portal_layout__add_region (integer,varchar,char)
returns integer as '
declare
    p_layout_id                     alias for $1;
    p_region                        alias for $2;
    p_immutable_p                   alias for $3;
begin
    insert
    into portal_supported_regions
    (layout_id, region, immutable_p)
    values
    (p_layout_id, p_region, p_immutable_p);

    return 0;
end;' language 'plpgsql';

create function portal_layout__add_region (integer,varchar)
returns integer as '
declare
    p_layout_id                     alias for $1;
    p_region                        alias for $2;
begin
    insert
    into portal_supported_regions
    (layout_id, region, immutable_p)
    values
    (p_layout_id, p_region, ''f'');

    return 0;
end;' language 'plpgsql';

select define_function_args('portal_datasource__new','datasource_id,name,description,css_dir,object_type;portal_datasource,creation_date,creation_user,creation_ip,context_id');

create function portal_datasource__new (integer,varchar,varchar,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
    p_datasource_id                 alias for $1; -- default null
    p_name                          alias for $2; -- default null
    p_description                   alias for $3; -- default null
    p_css_dir                       alias for $4;
    p_object_type                   alias for $5; -- default ''portal_datasource''
    p_creation_date                 alias for $6; -- default now()
    p_creation_user                 alias for $7; -- default null
    p_creation_ip                   alias for $8; -- default null
    p_context_id                    alias for $9; -- default null
    v_datasource_id                 portal_datasources.datasource_id%TYPE;
begin

    v_datasource_id := acs_object__new(
        p_datasource_id,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        p_context_id,
        ''t''
    );

    insert into portal_datasources
    (datasource_id, name, description, css_dir)
    values
    (v_datasource_id, p_name, p_description, p_css_dir);

    return v_datasource_id;

end;' language 'plpgsql';

create function portal_datasource__new (integer,varchar,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
    p_datasource_id                 alias for $1; -- default null
    p_name                          alias for $2; -- default null
    p_description                   alias for $3; -- default null
    p_object_type                   alias for $4; -- default ''portal_datasource''
    p_creation_date                 alias for $5; -- default now()
    p_creation_user                 alias for $6; -- default null
    p_creation_ip                   alias for $7; -- default null
    p_context_id                    alias for $8; -- default null
    v_datasource_id                 portal_datasources.datasource_id%TYPE;
begin

    v_datasource_id := portal_datasource__new(null,
				  p_name,
				  p_description,
                                  null,
				  p_object_type,
				  p_creation_date,
				  p_creation_user,
				  p_creation_ip,
				  p_context_id);

    return v_datasource_id;

end;' language 'plpgsql';


create function portal_datasource__new (varchar,varchar)
returns integer as '
declare
    p_name                          alias for $1; -- default null
    p_description                   alias for $2; -- default null
    v_datasource_id                 portal_datasources.datasource_id%TYPE;
begin

    v_datasource_id := portal_datasource__new(null,
				  p_name,
				  p_description,
                                  null,
				  ''portal_datasource'',
				  now(),
				  null,
				  null,
				  null);

    return v_datasource_id;

end;' language 'plpgsql';

create function portal_datasource__new (varchar,varchar,varchar)
returns integer as '
declare
    p_name                          alias for $1; -- default null
    p_description                   alias for $2; -- default null
    p_css_dir                       alias for $3;
    v_datasource_id                 portal_datasources.datasource_id%TYPE;
begin

    v_datasource_id := portal_datasource__new(null,
				  p_name,
				  p_description,
                                  p_css_dir,
				  ''portal_datasource'',
				  now(),
				  null,
				  null,
				  null);

    return v_datasource_id;

end;' language 'plpgsql';

select define_function_args('portal_datasource__delete','datasource_id');

create function portal_datasource__delete (integer)
returns integer as '
declare
    p_datasource_id                 alias for $1;
begin
    perform acs_object__delete(p_datasource_id);
    return 0;
end;' language 'plpgsql';

select define_function_args('portal_datasource__set_def_param','datasource_id,config_required_p,configured_p,key,value');

create function portal_datasource__set_def_param (integer,varchar,varchar,varchar,varchar)
returns integer as '
declare
    p_datasource_id                 alias for $1;
    p_config_required_p             alias for $2;
    p_configured_p                  alias for $3;
    p_key                           alias for $4;
    p_value                         alias for $5;
begin

    insert into portal_datasource_def_params
    (parameter_id, datasource_id, config_required_p, configured_p, key, value)
    values
    (acs_object_id_seq.nextval, p_datasource_id, p_config_required_p, p_configured_p, p_key, p_value);

    return 0;

end;' language 'plpgsql';
