-- fixes bug where you couldn't delete and emply page - 476

create or replace function portal_page__delete(integer)
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


