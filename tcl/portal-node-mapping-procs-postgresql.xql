<?xml version="1.0"?>

<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="portal::mapping::set.set_node_mapping">
<querytext>
select portal_node_mapping__new(:object_id, :node_id)
</querytext>
</fullquery>

<fullquery name="portal::mapping::unset.unset_node_mapping">
<querytext>
select portal_node_mapping__del(:object_id)
</querytext>
</fullquery>

</queryset>

