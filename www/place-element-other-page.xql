<?xml version="1.0"?>
<queryset>

<fullquery name="other_pages_select">
<querytext>
select page_id, pretty_name
from portal_pages pp
where
pp.portal_id = :portal_id 
and pp.page_id != :page_id
order by sort_key
</querytext>
</fullquery>

</queryset>
