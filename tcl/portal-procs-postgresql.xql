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
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="portal::create.create_new_portal_and_perms">
<querytext>

    begin
    
    :1 := portal__new ( 
    /* name */ :name,
    /* layout_id */ :layout_id,
    /* template_id */ :template_id,
    /* portal_template_p */ :portal_template_p,
    /* default_page_name */ :default_page_name,
    /* theme_id */ :theme_id,
    /* context_id */ :context_id
    );
    
    perform acs_permission__grant_permission ( 
    /* object_id */ :1,
    /* grantee_id */ :user_id,
    /* privilege */ 'portal_read_portal' 
    );
    
    perform acs_permission__grant_permission ( 
    /* object_id */ :1,
    /* grantee_id */ :user_id,
    /* privilege */ 'portal_edit_portal'
    );

    if :portal_template_p = 't' then
    acs_permission__grant_permission ( 
    /* object_id */ :1,
    /* grantee_id */ :user_id,
    /* privilege */ 'portal_admin_portal'
    );
    end if;

    end;

</querytext>
</fullquery>

<fullquery name="portal::delete.delete_portal">
  <querytext>
      select portal__delete (/* portal_id */ :portal_id);
  </querytext>
</fullquery>

<fullquery name="portal::configure_dispatch.show_here_update_sk">      
  <querytext>
    update portal_element_map
    set region = :region,
    page_id = :page_id,
    sort_key = (select coalesce((select max(pem.sort_key) + 1
	                    from portal_element_map pem, portal_pages pp
	                    where pp.portal_id = :portal_id 
                            and pp.page_id = pem.page_id
		            and region = :region), 
                            1) 
		 from dual)
     where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure_dispatch.move_to_page_update">      
  <querytext>
    update portal_element_map
    set page_id = :page_id, 
    region = :region,
    sort_key = (select coalesce((select max(sort_key) + 1
	                    from portal_element_map 
                            where page_id = :page_id
		            and region = :region), 
                            1) 
		 from dual)    
    where element_id = :element_id
  </querytext>
</fullquery> 		

<fullquery name="portal::add_element_to_region.insert">      
  <querytext>
    insert into portal_element_map
    (element_id, name, pretty_name, page_id, datasource_id, region, sort_key)
    values
    (:new_element_id, :ds_name, :ds_name, :page_id, :ds_id, :region,  
    coalesce((select max(sort_key) + 1 
         from portal_element_map
         where region = :region), 1))
  </querytext>
</fullquery> 

<fullquery name="portal::move_element.update">      
  <querytext>
    update portal_element_map 
    set region = :target_region, 
    sort_key = (select coalesce((select max(pem.sort_key) + 1
	                    from portal_element_map pem, portal_pages pp
	                    where pp.portal_id = :portal_id
                            and pp.page_id = pem.page_id
                            and region = :target_region), 
                           1) 
                from dual)
    where element_id = :element_id
  </querytext>
</fullquery> 		

<fullquery name="portal::page_create.page_create_insert">
<querytext>

    select portal_page__new ( 
    /* pretty_name */ :pretty_name,
    /* portal_id */ :portal_id,
    /* layout_id */ :layout_id
    );

</querytext>
</fullquery>

</queryset>

