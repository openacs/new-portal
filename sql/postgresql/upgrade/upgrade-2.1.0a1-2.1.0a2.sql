-- missing declare statements

create or replace function portal_element_theme__delete (integer)
returns integer as '
declare
    p_theme_id                      alias for $1;
begin
    PERFORM acs_object__delete(p_theme_id);

    return (0);
end;' language 'plpgsql';

create or replace function portal_layout__delete(integer)
returns integer as '
declare
    p_layout_id                     alias for $1;
begin
    perform acs_object__delete(layout_id);
    return 0;
end;' language 'plpgsql';
