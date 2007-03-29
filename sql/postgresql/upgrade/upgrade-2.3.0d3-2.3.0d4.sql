alter table portal_pages add accesskey varchar(200) default null;

select define_function_args('portal_page__new','page_id,pretty_name,accesskey,portal_id,layout_id,hidden_p,object_type;portal_page,creation_date,creation_user,creation_ip,context_id');

--drop function portal_page__new (integer,varchar,integer,integer,char,varchar,timestamptz,integer,varchar,integer);

create or replace function portal_page__new (integer,char,varchar,integer,integer,char,varchar,timestamptz,integer,varchar,integer)
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

create or replace function portal__new (integer,varchar,integer,integer,integer,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
    p_portal_id                     alias for $1;
    p_name                          alias for $2;
    p_theme_id                      alias for $3;
    p_layout_id                     alias for $4;
    p_template_id                   alias for $5;
    p_default_page_name             alias for $6;
    p_object_type                   alias for $7;
    p_creation_date                 alias for $8;
    p_creation_user                 alias for $9;
    p_creation_ip                   alias for $10;
    p_context_id                    alias for $11;
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
            null,
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
        loop

            v_page_id := portal_page__new(
            null,
            v_page.pretty_name,
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

