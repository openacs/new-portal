<?xml version="1.0"?>
<queryset>

<fullquery name="portal::list_datasources.select_all_datasources">      
  <querytext>
    select impl_name 
    from acs_sc_impls, acs_sc_bindings, acs_sc_contracts
    where acs_sc_impls.impl_id = acs_sc_bindings.impl_id 
    and acs_sc_contracts.contract_id= acs_sc_bindings.contract_id
    and acs_sc_contracts.contract_name='portal_datasource'
  </querytext>
</fullquery>

<fullquery name="portal::list_datasources.select_datasources">      
  <querytext>
    select datasource_id 
    from portal_datasource_avail_map
    where portal_id = :portal_id
  </querytext>
</fullquery> 

<fullquery name="portal::delete.delete_perms">      
  <querytext>
    delete from acs_permissions where object_id= :portal_id
  </querytext>
</fullquery> 

<fullquery name="portal::get_name.get_name_select">      
  <querytext>
    select name from portals where portal_id = :portal_id
  </querytext>
</fullquery> 

<fullquery name="portal::render.portal_select">      
  <querytext>
    select p.name, p.portal_id, p.theme_id as theme_id, 
    pl.layout_id as layout_id, pl.filename as layout_filename
    from portals p, portal_pages pp, portal_layouts pl
    where :page_id = pp.page_id 
    and pp.portal_id = p.portal_id
    and pp.layout_id = pl.layout_id
  </querytext>
</fullquery> 

<fullquery name="portal::render.element_select">      
  <querytext>
    select element_id, region, pem.sort_key
    from portal_element_map pem, portal_pages pp
    where pp.portal_id = :portal_id
    and pem.page_id = :page_id
    and pem.page_id = pp.page_id
    and state != 'hidden'
    order by region, sort_key
  </querytext>
</fullquery> 

<fullquery name="portal::update_name.update">      
  <querytext>
    update portals 
    set name = :new_name 
    where portal_id = :portal_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure.current_theme_select">      
  <querytext>
    select theme_id as cur_theme_id
    from portals
    where portal_id = :portal_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure.all_theme_select">      
  <querytext>
    select theme_id, name, description
    from portal_element_themes
    order by name 
  </querytext>
</fullquery> 

<fullquery name="portal::configure.portal_select">      
  <querytext>
    select  p.name, p.portal_id,  pl.filename as template, pp.pretty_name as page_name
    from portals p, portal_layouts pl, portal_pages pp
    where  pp.portal_id = :portal_id
    and pp.page_id = :page_id
    and pp.portal_id = p.portal_id
    and pl.layout_id = pp.layout_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure.get_regions">      
  <querytext>
    select region
    from portal_supported_regions
    where layout_id = :layout_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure_dispatch.show_here_update_state">      
  <querytext>
    update portal_element_map
    set state = 'full' 
    where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure_dispatch.move_to_page_curr_select">      
  <querytext>
    select region
    from portal_element_map
    where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure_dispatch.move_to_page_target_select">      
  <querytext>
    select count(*) 
    from portal_pages pp, portal_supported_regions psr 
    where pp.layout_id = psr.layout_id 
    and pp.page_id = :page_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure_dispatch.hide_update">      
  <querytext>
  update portal_element_map 
  set state =  'hidden' 
  where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure_dispatch.update_theme">      
  <querytext>
  update portals
  set theme_id = :theme_id
  where portal_id = :portal_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure_dispatch.toggle_pinned_select">
  <querytext>
    select state
    from portal_element_map pem, portal_currentXXXX_page pcp 
    where pcp.portal_id = :portal_id 
    and pem.page_id = pcp.page_id
    and element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure_dispatch.toggle_pinned_update_pin">
  <querytext>
    update portal_element_map
    set state = 'pinned'
    where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure_dispatch.toggle_pinned_update_unpin">
  <querytext>
    update portal_element_map
    set state = 'full'
    where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::template_p.select">      
  <querytext>
    select 1
    from portals 
    where portal_template_p = 't'
    and portal_id = :portal_id
  </querytext>
</fullquery> 

<fullquery name="portal::get_portal_template_id.select">      
  <querytext>
   select template_id
   from portals
   where portal_id = :portal_id 
   and template_id is not null
  </querytext>
</fullquery> 

<fullquery name="portal::get_page_id.get_page_id_select">      
  <querytext>
   select page_id
   from portal_pages
   where portal_id = :portal_id 
   and sort_key = :sort_key
  </querytext>
</fullquery> 

<fullquery name="portal::page_count.page_count_select">      
  <querytext>
   select count(*)
   from portal_pages
   where portal_id = :portal_id 
  </querytext>
</fullquery> 

<fullquery name="portal::get_page_pretty_name.get_page_pretty_name_select">      
  <querytext>
   select pretty_name
   from portal_pages
   where page_id = :page_id 
  </querytext>
</fullquery> 

<fullquery name="portal::list_pages_tcl_list.list_pages_tcl_list_select">      
  <querytext>
   select page_id
   from portal_pages
   where portal_id = :portal_id 
   order by sort_key
  </querytext>
</fullquery> 

<fullquery name="portal::navbar.list_page_nums_select">
<querytext>
select pretty_name, sort_key as page_num from portal_pages where
portal_id = :portal_id
order by sort_key
</querytext>
</fullquery>

<fullquery name="portal::add_element.get_regions">      
  <querytext>
    select region
    from portal_supported_regions
    where layout_id = :layout_id
  </querytext>
</fullquery> 

<fullquery name="portal::add_element.region_count">      
  <querytext>
    select count(*) as count
    from portal_element_map pem, portal_pages pp
    where pp.portal_id = :portal_id
    and pem.region = :region
    and pp.page_id = pem.page_id
  </querytext>
</fullquery> 

<fullquery name="portal::remove_element.delete">      
  <querytext>
    delete from portal_element_map
    where element_id= :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::add_element_to_region.get_template_info_select">
  <querytext>
     select pp.page_id as template_page_id, 
       pp.sort_key as template_page_sort_key,
       pem.element_id as template_element_id
     from portals p, portal_element_map pem, portal_pages pp
     where p.portal_id = :portal_id
       and p.template_id = pp.portal_id
       and pp.page_id = pem.page_id
       and pem.datasource_id = :ds_id
  </querytext>
</fullquery> 

<fullquery name="portal::add_element_to_region.get_target_page_id">      
  <querytext>
   select page_id as target_page_id
   from portal_pages pp
   where pp.portal_id = :portal_id 
   and pp.sort_key = :template_page_sort_key   
  </querytext>
</fullquery> 

<fullquery name="portal::add_element_to_region.template_insert">      
  <querytext>
    insert into portal_element_map
    (element_id, name, pretty_name, page_id, datasource_id, region,  sort_key, state)
    select 
    :new_element_id,
    name, 
    pretty_name,
    :target_page_id,
    :ds_id,
    region,
    sort_key,
    state
    from portal_element_map pem
    where pem.element_id = :template_element_id
  </querytext>
</fullquery> 

<fullquery name="portal::add_element_to_region.template_params_insert">      
  <querytext>
    insert into portal_element_parameters
    (parameter_id, element_id, config_required_p, configured_p, key, value)
    select acs_object_id_seq.nextval, :new_element_id, config_required_p, configured_p, key, value
    from portal_element_parameters
    where element_id = :template_element_id
</querytext>
</fullquery> 

<fullquery name="portal::add_element_to_region.params_insert">      
  <querytext>
    insert into portal_element_parameters
    (parameter_id, element_id, config_required_p, configured_p, key, value)
    select acs_object_id_seq.nextval, :new_element_id, config_required_p, configured_p, key, value
    from portal_datasource_def_params where datasource_id= :ds_id
  </querytext>
</fullquery> 

<fullquery name="portal::swap_element.get_my_sort_key_and_page_id">      
  <querytext>
  select sort_key as my_sort_key, page_id as my_page_id
  from portal_element_map 
  where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::swap_element.get_prev_sort_key">      
  <querytext>
    select sort_key as other_sort_key, element_id as other_element_id
    from (select pem.sort_key, element_id 
          from portal_element_map pem, portal_pages pp
          where pp.portal_id = :portal_id 
          and pem.page_id = :my_page_id
          and pp.page_id = pem.page_id
          and region = :region 
          and pem.sort_key < :my_sort_key
          and state != 'pinned'
          order by pem.sort_key desc) where rownum = 1
  </querytext>
</fullquery> 

<fullquery name="portal::swap_element.get_next_sort_key">      
  <querytext>
    select sort_key as other_sort_key, element_id as other_element_id
    from (select pem.sort_key, element_id
          from portal_element_map pem, portal_pages pp
          where pp.portal_id = :portal_id 
          and pem.page_id = :my_page_id
          and pem.page_id = pp.page_id
          and region = :region 
          and pem.sort_key > :my_sort_key 
          and state != 'pinned'
          order by pem.sort_key) where rownum = 1 
  </querytext>
</fullquery> 

<fullquery name="portal::swap_element.swap_sort_keys_1">      
  <querytext>
    update portal_element_map set sort_key = :dummy_sort_key
    where element_id = :element_id 
  </querytext>
</fullquery> 

<fullquery name="portal::swap_element.swap_sort_keys_2">      
  <querytext>
     update portal_element_map set sort_key = :my_sort_key
     where element_id = :other_element_id
  </querytext>
</fullquery> 

<fullquery name="portal::swap_element.swap_sort_keys_3">      
  <querytext>
    update portal_element_map set sort_key = :other_sort_key
    where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::set_element_param.update">      
  <querytext>
    update portal_element_parameters set value = :value
    where element_id = :element_id and 
    key = :key
  </querytext>
</fullquery> 

<fullquery name="portal::move_element.get_my_page_id">      
  <querytext>
  select page_id as my_page_id
  from portal_element_map 
  where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::get_element_param_list.select">      
  <querytext>
    select value
    from portal_element_parameters
    where element_id= :element_id
    and key= :key
  </querytext>
</fullquery> 

<fullquery name="portal::add_element_param_value.insert">      
  <querytext>
    insert into portal_element_parameters
    (parameter_id, element_id, configured_p, key, value) 
    select acs_object_id_seq.nextval, :element_id, 't', :key, :value
        from dual
        where not exists (select parameter_id from portal_element_parameters where 
                          element_id= :element_id and key= :key and value= :value)
  </querytext>
</fullquery> 

<fullquery name="portal::.">      
  <querytext>
    
  </querytext>
</fullquery> 

<fullquery name="portal::remove_element_param_value.delete">      
  <querytext>
     delete from portal_element_parameters where
     element_id= :element_id and
     key= :key and
     value= :value
  </querytext>
</fullquery> 

<fullquery name="portal::remove_all_element_param_values.delete">      
  <querytext>
	delete from portal_element_parameters where
	element_id= :element_id and
	key= :key
  </querytext>
</fullquery> 

<fullquery name="portal::get_element_param.select">      
  <querytext>
    select value
    from portal_element_parameters 
    where element_id = :element_id and 
    key = :key
  </querytext>
</fullquery> 

<fullquery name="portal::evaluate_element.element_select">      
  <querytext>
    select pem.element_id,
    pem.datasource_id,
    pem.state,
    pet.filename as filename, 
    pet.resource_dir as resource_dir,
    pem.pretty_name as pretty_name,
    pd.name as ds_name
    from portal_element_map pem, portal_element_themes pet, portal_datasources pd
    where pet.theme_id = :theme_id
    and pem.element_id = :element_id
    and pem.datasource_id = pd.datasource_id
  </querytext>
</fullquery> 

<fullquery name="portal::evaluate_element.params_select">      
  <querytext>
    select key, value
    from portal_element_parameters
    where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::evaluate_element.select_portal_id">
<querytext>
select portal_id from portal_pages where page_id = (select page_id from portal_element_map where element_id= :element_id)
</querytext>
</fullquery>

<fullquery name="portal::evaluate_element_raw.element_select">      
  <querytext>
    select pem.element_id,
    pem.datasource_id,
    pem.state
    from portal_element_map pem
    where pem.element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::evaluate_element_raw.params_select">      
  <querytext>
    select key, value
    from portal_element_parameters
    where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure_element.select">      
  <querytext>
    select portal_id, datasource_id
    from portal_element_map pem, portal_pages pp
    where element_id = :element_id
    and pem.page_id = pp.page_id
  </querytext>
</fullquery> 

<fullquery name="portal::configure_element.hide_update">      
  <querytext>
    update portal_element_map 
    set state =  'hidden' 
    where element_id = :element_id
  </querytext>
</fullquery> 

<fullquery name="portal::get_datasource_name.select">      
  <querytext>
    select name from portal_datasources where datasource_id = :ds_id
  </querytext>
</fullquery> 

<fullquery name="portal::get_datasource_id.select">      
  <querytext>
    select datasource_id from portal_datasources where name = :ds_name
  </querytext>
</fullquery> 

<fullquery name="portal::make_datasource_available.insert">      
  <querytext>
    insert into portal_datasource_avail_map
    (portal_datasource_id, portal_id, datasource_id)
    values
    (:new_p_ds_id, :portal_id, :ds_id)
  </querytext>
</fullquery> 

<fullquery name="portal::make_datasource_unavailable.delete">      
  <querytext>
    delete from portal_datasource_avail_map
    where portal_id =  :portal_id
    and datasource_id = :ds_id
  </querytext>
</fullquery> 

<fullquery name="portal::toggle_datasource_availability.select">      
  <querytext>
    select 1  
    from portal_datasource_avail_map
    where portal_id = :portal_id and
    datasource_id = :ds_id
  </querytext>
</fullquery> 

<fullquery name="portal::get_element_ids_by_ds.select">      
  <querytext>
    select element_id from portal_element_map pem, portal_pages pp
    where pp.portal_id= :portal_id 
    and datasource_id= :ds_id
    and pem.page_id = pp.page_id
  </querytext>
</fullquery> 

<fullquery name="portal::get_layout_region_count.select_region_count">      
  <querytext>
    select count(*) as region_count
    from portal_supported_regions
    where layout_id = :layout_id
  </querytext>
</fullquery> 

<fullquery name="portal::get_layout_id.get_layout_id_num_select">      
  <querytext>
    select layout_id from portal_pages where portal_id = :portal_id and sort_key = :page_num
  </querytext>
</fullquery> 

<fullquery name="portal::get_layout_id.get_layout_id_page_select">      
  <querytext>
    select layout_id from portal_pages where page_id = :page_id
  </querytext>
</fullquery> 

<fullquery name="portal::get_layout_id.get_layout_id_name_select">      
  <querytext>
    select layout_id from portal_layouts where name = :layout_name 
  </querytext>
</fullquery> 

<fullquery name="portal::exists_p.select">      
  <querytext>
    select 1 from portals where portal_id = :portal_id
  </querytext>
</fullquery> 

<fullquery name="portal::get_theme_id_from_name.get_theme_id_from_name_select">      
  <querytext>
    select theme_id from portal_element_themes where name = :theme_name
  </querytext>
</fullquery> 

<fullquery name="portal::get_page_id.get_page_id_from_name">      
   <querytext>
    select page_id
    from portal_pages
    where portal_id = :portal_id 
    and pretty_name= :page_name
   </querytext>
 </fullquery>


</queryset>
