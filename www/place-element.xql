<?xml version="1.0"?>
<queryset>

<fullquery name="select_elements_by_region">
<querytext>
select element_id, pem.pretty_name as name,  pem.sort_key, state
from portal_element_map pem, portal_pages pp
where
pp.portal_id = :portal_id 
and pem.page_id = pp.page_id
and pp.page_id = :page_id
and region = :region 
and state != 'hidden'
order by sort_key 
</querytext>
</fullquery>

<fullquery name="hidden_elements">
<querytext>
select element_id, pem.pretty_name
from portal_element_map pem, portal_pages pp
where
pp.portal_id = :portal_id 
and pp.page_id = pem.page_id
and pem.state = 'hidden'
order by name
</querytext>
</fullquery>

</queryset>
