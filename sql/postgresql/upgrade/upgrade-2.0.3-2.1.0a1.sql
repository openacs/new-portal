-- fixes bug where you couldn't delete and emply page - 476



-- added
select define_function_args('portal_page__delete','page_id');

--
-- procedure portal_page__delete/1
--
CREATE OR REPLACE FUNCTION portal_page__delete(
   p_page_id integer
) RETURNS integer AS $$
DECLARE
    v_portal_id                     portal_pages.portal_id%TYPE;
    v_sort_key                      portal_pages.sort_key%TYPE;
    v_curr_sort_key                 portal_pages.sort_key%TYPE;
    v_page_count_from_0             integer;
BEGIN

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

END;
$$ LANGUAGE plpgsql;


