alter table portal_pages add accesskey char(1) default null;

select define_function_args('portal_page__new','page_id,pretty_name,accesskey,portal_id,layout_id,hidden_p,object_type;portal_page,creation_date,creation_user,creation_ip,context_id');

drop function portal_page__new (integer,varchar,integer,integer,char,varchar,timestamptz,integer,varchar,integer);

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
