<?xml version="1.0"?>
<!--

  Copyright (C) 2001, 2002 OpenForce, Inc.

  This file is part of dotLRN.

  dotLRN is free software; you can redistribute it and/or modify it under the
  terms of the GNU General Public License as published by the Free Software
  Foundation; either version 2 of the License, or (at your option) any later
  version.

  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

-->

<queryset>

<fullquery name="select_num_regions">
<querytext>
select count(*) as num_regions
from portal_supported_regions
where layout_id = :layout_id
</querytext>
</fullquery>

<fullquery name="select_elements_by_region">
<querytext>
select element_id, pem.pretty_name as name,  pem.sort_key, state, pem.page_id as page_id
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

<fullquery name="select_all_noimm_count">
<querytext>
select count(*) as all_count
from portal_element_map pem, portal_pages pcp
where
pcp.portal_id = :portal_id
and pem.page_id = pcp.page_id
and state != 'hidden'
and region not like 'i%'
</querytext>
</fullquery>


<fullquery name="hidden_elements">
<querytext>
select element_id, name
from portal_element_map pem, portal_pages pp
where
pp.portal_id = :portal_id 
and pp.page_id = pem.page_id
and pem.state = 'hidden'
order by name
</querytext>
</fullquery>

</queryset>
