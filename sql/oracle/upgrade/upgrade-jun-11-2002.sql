-- remove the 3 col with header layout from the system
-- the data in the portal_supported_regions table will cascade
declare
    v_layout_id  portal_layouts.layout_id%TYPE;
begin 
     select layout_id into v_layout_id from portal_layouts where name = '3-column w/ Header';
     
     portal_layout.delete( layout_id => v_layout_id ); 
end;


