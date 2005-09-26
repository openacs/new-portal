alter table portal_pages add hidden_p char(1) default 'f';
alter table portal_pages add constraint portal_pages_hidden_p_nn
 check (hidden_p is not null);
alter table portal_pages add constraint portal_pages_hidden_p_ck
 check (hidden_p in ('t','f'));

--
-- We were detecting hidden pages in the Tcl layer by checking
-- for whitespace.  Let's go ahead an update existing hidden pages
-- making the hidden state formal and explicit.
--
update portal_pages
set hidden_p = 't'
where trim(pretty_name) is null;

create or replace package portal_page
as

    function new (
        page_id                     in portal_pages.page_id%TYPE default null,
        pretty_name                 in portal_pages.pretty_name%TYPE default 'Untitled Page',
        portal_id                   in portal_pages.portal_id%TYPE,
        layout_id                   in portal_pages.layout_id%TYPE default null,
        hidden_p                    in portal_pages.hidden_p%TYPE default 'f',
        object_type                 in acs_object_types.object_type%TYPE default 'portal_page',
        creation_date               in acs_objects.creation_date%TYPE default sysdate,
        creation_user               in acs_objects.creation_user%TYPE default null,
        creation_ip                 in acs_objects.creation_ip%TYPE default null,
        context_id                  in acs_objects.context_id%TYPE default null
    ) return portal_pages.page_id%TYPE;

    procedure del (
        page_id                     in portal_pages.page_id%TYPE
    );

end portal_page;
/
show errors

create or replace package body portal_page
as

    function new (
        page_id                     in portal_pages.page_id%TYPE default null,
        pretty_name                 in portal_pages.pretty_name%TYPE default 'Untitled Page',
        portal_id                   in portal_pages.portal_id%TYPE,
        layout_id                   in portal_pages.layout_id%TYPE default null,
        hidden_p                    in portal_pages.hidden_p%TYPE default 'f',
        object_type                 in acs_object_types.object_type%TYPE default 'portal_page',
        creation_date               in acs_objects.creation_date%TYPE default sysdate,
        creation_user               in acs_objects.creation_user%TYPE default null,
        creation_ip                 in acs_objects.creation_ip%TYPE default null,
        context_id                  in acs_objects.context_id%TYPE default null
    ) return portal_pages.page_id%TYPE
    is
        v_page_id                   portal_pages.page_id%TYPE;
        v_layout_id                 portal_pages.layout_id%TYPE;
        v_sort_key                  portal_pages.sort_key%TYPE;
    begin

        v_page_id := acs_object.new(
            object_type => object_type,
            creation_date => creation_date,
            creation_user => creation_user,
            creation_ip => creation_ip,
            context_id => context_id
        );

        if layout_id is null then
            select min(layout_id)
            into v_layout_id
            from portal_layouts;
        else
            v_layout_id := layout_id;
        end if;

        select nvl(max(sort_key) + 1, 0)
        into v_sort_key
        from portal_pages
        where portal_id = portal_page.new.portal_id;

        insert into portal_pages
        (page_id, pretty_name, portal_id, layout_id, sort_key, hidden_p)
        values
        (v_page_id, pretty_name, portal_id, v_layout_id, v_sort_key, hidden_p);

        return v_page_id;

    end new;

    procedure del (
        page_id                     in portal_pages.page_id%TYPE
    )
    is
        v_portal_id                 portal_pages.portal_id%TYPE;
        v_sort_key                  portal_pages.sort_key%TYPE;
        v_curr_sort_key             portal_pages.sort_key%TYPE;
        v_page_count_from_0         integer;
    begin

        -- IMPORTANT: sort keys MUST be an unbroken sequence from 0 to max(sort_key)

        select portal_id, sort_key
        into v_portal_id, v_sort_key
        from portal_pages
        where page_id = portal_page.del.page_id;

        select (count(*) - 1)
        into v_page_count_from_0
        from portal_pages
        where portal_id = v_portal_id;

        for i in 0 .. v_page_count_from_0 loop

            if i = v_sort_key then

                delete
                from portal_pages
                where page_id = portal_page.del.page_id;

            elsif i > v_sort_key then

                update portal_pages
                set sort_key = -1
                where sort_key = i
		and page_id = portal_page.del.page_id;

                update portal_pages
                set sort_key = i - 1
                where sort_key = -1
		and page_id = portal_page.del.page_id;

            end if;

        end loop;

        acs_object.del(page_id);

    end del;

end portal_page;
/
show errors
