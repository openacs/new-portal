<?xml version="1.0"?>

<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="portal::create.create_new_portal">
  <querytext>
    
    select portal__new ( 
    null,
    :name,
    :theme_id,
    :layout_id,
    :template_id,
    :default_page_name,
    'portal',
    now(),
    null,
    null,
    :context_id
    );
 
  </querytext>
</fullquery>

<fullquery name="portal::delete.delete_portal">
  <querytext>
    begin
      portal__delete (:portal_id);
    end;
  </querytext>
</fullquery>

<fullquery name="portal::configure_dispatch.show_here_update_sk">      
  <querytext>
    update portal_element_map
    set region = :region,
    page_id = :page_id,
    sort_key = (select coalesce((select max(pem.sort_key) + 1
	                    from portal_element_map pem
                            where pem.page_id = :page_id
		            and region = :region), 
                            1) 
		 from dual)
     where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::move_element_to_page.update">      
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
    (:new_element_id, :ds_name, :pretty_name, :page_id, :ds_id, :region,  
    coalesce((select max(sort_key) + 1 
         from portal_element_map
         where region = :region
         and page_id = :page_id), 1))
  </querytext>
</fullquery> 

<fullquery name="portal::move_element.update">      
  <querytext>
    update portal_element_map 
    set region = :target_region, 
    sort_key = (select coalesce((select max(pem.sort_key) + 1
	                    from portal_element_map pem
	                    where page_id = :my_page_id         
                            and region = :target_region), 
                           1) 
                from dual)
    where element_id = :element_id
  </querytext>
</fullquery> 		

<fullquery name="portal::page_create.page_create_insert">
  <querytext>
      select portal_page__new ( 
      null,
      :pretty_name,
      :portal_id,
      :layout_id,
      'portal_page',
      now(),
      null,
      null,
      null
      );
  </querytext>
</fullquery>

<fullquery name="portal::page_delete.page_delete">
  <querytext>
      select portal_page__delete ( :page_id );
  </querytext>
</fullquery>

</queryset>

