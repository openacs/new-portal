-- missing declare statements



-- added
select define_function_args('portal_element_theme__delete','theme_id');

--
-- procedure portal_element_theme__delete/1
--
CREATE OR REPLACE FUNCTION portal_element_theme__delete(
   p_theme_id integer
) RETURNS integer AS $$
DECLARE
BEGIN
    PERFORM acs_object__delete(p_theme_id);

    return (0);
END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('portal_layout__delete','layout_id');

--
-- procedure portal_layout__delete/1
--
CREATE OR REPLACE FUNCTION portal_layout__delete(
   p_layout_id integer
) RETURNS integer AS $$
DECLARE
BEGIN
    perform acs_object__delete(layout_id);
    return 0;
END;
$$ LANGUAGE plpgsql;
