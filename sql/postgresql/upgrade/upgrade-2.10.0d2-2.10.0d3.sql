-- upgrade 2.10.0d2 to 2.10.0d3
--
-- prefer acs_object__new/9 over acs_object__new/7

BEGIN;
    
    --
    -- procedure portal_page__new/11
    --
    CREATE OR REPLACE FUNCTION portal_page__new(
       p_page_id integer,
       p_pretty_name varchar,
       p_accesskey varchar,
       p_portal_id integer,
       p_layout_id integer,
       p_hidden_p boolean,
       p_object_type varchar, -- default 'portal_page'
       p_creation_date timestamptz,
       p_creation_user integer,
       p_creation_ip varchar,
       p_context_id integer
    
    ) RETURNS integer AS $$
    DECLARE
        v_page_id                       portal_pages.page_id%TYPE;
        v_layout_id                     portal_pages.layout_id%TYPE;
        v_sort_key                      portal_pages.sort_key%TYPE;
    BEGIN
    
        v_page_id := acs_object__new(
            null,               -- object_id 
            p_object_type,      -- object_type 
            p_creation_date,    -- creation_date 
            p_creation_user,    -- creation_user 
            p_creation_ip,      -- creation_ip 
            p_context_id,       -- context_id 
            true,               -- security_inherit_p 
            p_pretty_name,      -- title 
            null                -- package_id
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
    
    END;
    $$ LANGUAGE plpgsql;
    
    
    --
    -- procedure portal__new/12
    --
    CREATE OR REPLACE FUNCTION portal__new(
       p_portal_id integer,
       p_name varchar,
       p_theme_id integer,
       p_layout_id integer,
       p_template_id integer,
       p_default_page_name varchar,
       p_default_accesskey varchar,
       p_object_type varchar, -- default 'portal'
       p_creation_date timestamptz,
       p_creation_user integer,
       p_creation_ip varchar,
       p_context_id integer
    
    ) RETURNS integer AS $$
    DECLARE
        v_portal_id                     portals.portal_id%TYPE;
        v_theme_id                      portals.theme_id%TYPE;
        v_layout_id                     portal_layouts.layout_id%TYPE;
        v_page_id                       portal_pages.page_id%TYPE;
        v_page                          record;
        v_element                       record;
        v_param                         record;
        v_new_element_id                integer;
        v_new_parameter_id              integer;
    BEGIN
    
        v_portal_id := acs_object__new(
            p_portal_id,        -- object_id 
            p_object_type,      -- object_type 
            p_creation_date,    -- creation_date 
            p_creation_user,    -- creation_user 
            p_creation_ip,      -- creation_ip 
            p_context_id,       -- context_id 
            true,               -- security_inherit_p 
            p_name,             -- title 
            null                -- package_id
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
                'f',
                'portal_page',
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
                'f',
                'portal_page',
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
    
                    select nextval('t_acs_object_id_seq')
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
    
                        select nextval('t_acs_object_id_seq')
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
    
    END;
    $$ LANGUAGE plpgsql;
    
    --
    -- procedure portal_element_theme__new/10
    --
    CREATE OR REPLACE FUNCTION portal_element_theme__new(
       p_theme_id integer,
       p_name varchar,
       p_description varchar,
       p_filename varchar,
       p_resource_dir varchar,
       p_object_type varchar, -- default 'portal_element_theme'
       p_creation_date timestamptz,
       p_creation_user integer,
       p_creation_ip varchar,
       p_context_id integer
    
    ) RETURNS integer AS $$
    DECLARE
        v_theme_id                      portal_element_themes.theme_id%TYPE;
    BEGIN
    
        v_theme_id := acs_object__new(
            p_theme_id,         -- object_id 
            p_object_type,      -- object_type 
            p_creation_date,    -- creation_date 
            p_creation_user,    -- creation_user 
            p_creation_ip,      -- creation_ip 
            p_context_id,       -- context_id 
            true,               -- security_inherit_p 
            p_name,             -- title 
            null                -- package_id
        );   
        
        
        insert
        into portal_element_themes
        (theme_id, name, description, filename, resource_dir)
        values
        (v_theme_id, p_name, p_description, p_filename, p_resource_dir);
    
        return v_theme_id;
    
    END;
    $$ LANGUAGE plpgsql;
    
    --
    -- procedure portal_layout__new/10
    --
    CREATE OR REPLACE FUNCTION portal_layout__new(
       p_layout_id integer,
       p_name varchar,
       p_description varchar,
       p_filename varchar,
       p_resource_dir varchar,
       p_object_type varchar, -- default 'portal_layout'
       p_creation_date timestamptz,
       p_creation_user integer,
       p_creation_ip varchar,
       p_context_id integer
    
    ) RETURNS integer AS $$
    DECLARE
        v_layout_id                     portal_layouts.layout_id%TYPE;
    BEGIN
    
        v_layout_id := acs_object__new(
            p_layout_id,        -- object_id 
            p_object_type,      -- object_type 
            p_creation_date,    -- creation_date 
            p_creation_user,    -- creation_user 
            p_creation_ip,      -- creation_ip 
            p_context_id,       -- context_id 
            true,               -- security_inherit_p 
            p_name,             -- title 
            null                -- package_id
        );   
        
        insert into portal_layouts
        (layout_id, name, description, filename, resource_dir)
        values
        (v_layout_id, p_name, p_description, p_filename, p_resource_dir);
    
        return v_layout_id;
    
    END;
    $$ LANGUAGE plpgsql;
    
    --
    -- procedure portal_datasource__new/9
    --
    CREATE OR REPLACE FUNCTION portal_datasource__new(
       p_datasource_id integer,     -- default null
       p_name varchar,              -- default null
       p_description varchar,       -- default null
       p_css_dir varchar,
       p_object_type varchar,       -- default 'portal_datasource'
       p_creation_date timestamptz, -- default now()
       p_creation_user integer,     -- default null
       p_creation_ip varchar,       -- default null
       p_context_id integer         -- default null
    
    ) RETURNS integer AS $$
    DECLARE
        v_datasource_id                 portal_datasources.datasource_id%TYPE;
    BEGIN
    
        v_datasource_id := acs_object__new(
            p_datasource_id,    -- object_id 
            p_object_type,      -- object_type 
            p_creation_date,    -- creation_date 
            p_creation_user,    -- creation_user 
            p_creation_ip,      -- creation_ip 
            p_context_id,       -- context_id 
            true,               -- security_inherit_p 
            p_name,             -- title 
            null                -- package_id
        );       
        
        insert into portal_datasources
        (datasource_id, name, description, css_dir)
        values
        (v_datasource_id, p_name, p_description, p_css_dir);
    
        return v_datasource_id;
    
    END;
    $$ LANGUAGE plpgsql;

END;
   