<?xml version="1.0"?>

<queryset>
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="portal::mapping::new.set_node_mapping">
<querytext>
declare
begin
portal_node_mapping.new(object_id => :object_id, node_id => :node_id);
end;
</querytext>
</fullquery>

<fullquery name="portal::mapping::del.unset_node_mapping">
<querytext>
declare
begin
portal_node_mapping.del(object_id => :object_id);
end;
</querytext>
</fullquery>

</queryset>

