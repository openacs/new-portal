<?xml version="1.0"?>

<queryset>

    <fullquery name="portal::list_datasources.select_all_datasources">
        <querytext>
            select impl_name
            from acs_sc_impls,
                 acs_sc_bindings,
                 acs_sc_contracts
            where acs_sc_impls.impl_id = acs_sc_bindings.impl_id
            and acs_sc_contracts.contract_id = acs_sc_bindings.contract_id
            and acs_sc_contracts.contract_name = 'portal_datasource'
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
            delete
            from acs_permissions
            where object_id = :portal_id
        </querytext>
    </fullquery>

    <fullquery name="portal::get_name_not_cached.get_name_select">
        <querytext>
            select name
            from portals
            where portal_id = :portal_id
        </querytext>
    </fullquery>

    <fullquery name="portal::render.portal_select">
        <querytext>
            select portals.name,
                   portals.portal_id,
                   portals.theme_id,
                   portal_layouts.layout_id,
                   portal_layouts.filename as layout_filename,
                   portal_layouts.resource_dir as layout_resource_dir,
                   portal_pages.page_id
            from portals,
                 portal_pages,
                 portal_layouts
            where portal_pages.sort_key = :sort_key
            and portal_pages.portal_id = :portal_id
            and portal_pages.portal_id = portals.portal_id
            and portal_pages.layout_id = portal_layouts.layout_id
        </querytext>
    </fullquery>

    <fullquery name="portal::render.element_select">
        <querytext>
            select portal_element_map.element_id,
                   portal_element_map.region,
                   portal_element_map.sort_key
            from portal_element_map,
                 portal_pages
            where portal_pages.portal_id = :portal_id
            and portal_element_map.page_id = :page_id
            and portal_element_map.page_id = portal_pages.page_id
            and portal_element_map.state != 'hidden'
            order by portal_element_map.region,
                     portal_element_map.sort_key
        </querytext>
    </fullquery>

    <fullquery name="portal::update_name.update">
        <querytext>
            update portals
            set name = :new_name
            where portal_id = :portal_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure.get_page_info">
        <querytext>
            select pretty_name as pretty_name_unlocalized,
                   hidden_p
            from portal_pages
            where page_id = :page_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure.portal_and_page_info_select">
        <querytext>
            select portals.name,
                   portals.portal_id,
                   portal_pages.pretty_name as page_name,
                   portal_pages.layout_id
            from portals,
                 portal_layouts,
                 portal_pages
            where portal_pages.portal_id = :portal_id
            and portal_pages.page_id = :page_id
            and portal_pages.portal_id = portals.portal_id
            and portal_pages.layout_id = portal_layouts.layout_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure.layout_id_select">
        <querytext>
            select layout_id
            from portal_layouts
            where filename = :layout
        </querytext>
    </fullquery>

    <fullquery name="portal::configure.sub_portals">
        <querytext>
            select count(*)
              from portals
             where template_id = :portal_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.show_here_update_state">
        <querytext>
            update portal_element_map
            set state = 'full'
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.hide_update">
        <querytext>
            update portal_element_map
            set state = 'hidden'
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_theme_update">
        <querytext>
            update portals
            set theme_id = :theme_id
            where portal_id = :portal_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_move_elements_for_del">
        <querytext>
            select element_id
            from portal_element_map
            where page_id = :page_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_get_source_page_info">
        <querytext>
            select pretty_name,
                   layout_id,
                   sort_key
            from portal_pages
            where page_id = :source_page_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_get_target_page_id">
        <querytext>
            select page_id
            from portal_pages
            where portal_id = :portal_id
            and sort_key = :sort_key
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.hide_all_elements">
        <querytext>
		update portal_element_map		
		set  state = 'hidden'
		 where page_id = :target_page_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_get_source_elements">
	<querytext>
            select region,
                   sort_key,
                   state,
                   pd.datasource_id as datasource_id,
                   pd.name as name,
                   pem.pretty_name as pretty_name
            from portal_element_map pem,
                 portal_datasources pd
            where pem.page_id = :source_page_id
            and pem.datasource_id = pd.datasource_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_get_target_element">
        <querytext>
            select element_id
            from portal_element_map pem,
                 portal_pages pp
            where pp.portal_id = :portal_id
            and pem.page_id = pp.page_id
            and pem.datasource_id = :datasource_id
            and pem.pretty_name = :pretty_name
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_element_update">
        <querytext>
            update portal_element_map
            set region = :region,
                sort_key = :sort_key,
                state = :state,
                page_id = :target_page_id
            where element_id = :target_element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_update">
        <querytext>
            update portals
            set theme_id = :theme_id
            where portal_id = :portal_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_source_pages">
        <querytext>
            select page_id, sort_key
            from portal_pages
            where portal_id = :template_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_set_target_page_sort_key">
        <querytext>
            update portal_pages
            set sort_key = :sort_key
            where page_id = :page_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_target_pages">
        <querytext>
            select page_id, sort_key
            from portal_pages
            where portal_id = :portal_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.update_theme">
        <querytext>
            update portals
            set theme_id = :theme_id
            where portal_id = :portal_id  or template_id=:portal_id
            
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.toggle_pinned_select">
        <querytext>
            select state
            from portal_element_map
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.toggle_tab_visibility">
        <querytext>
            update portal_pages
            set hidden_p = case when hidden_p = true then false else true end
            where page_id = :page_id
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

    <fullquery name="portal::set_page_pretty_name.set_page_pretty_name_update">
        <querytext>
            update portal_pages
            set pretty_name = :pretty_name
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
            select pretty_name,
                   sort_key as page_num
            from portal_pages
            where portal_id = :portal_id
            order by sort_key
        </querytext>
    </fullquery>

    <fullquery name="portal::add_element.region_count">
        <querytext>
            select count(*) as count
            from portal_element_map pem,
                 portal_pages pp
            where pp.portal_id = :portal_id
            and pem.region = :region
            and pp.page_id = pem.page_id
        </querytext>
    </fullquery>

    <fullquery name="portal::remove_element.delete">
        <querytext>
            delete
            from portal_element_map
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::add_element_to_region.get_template_info_select">
        <querytext>
            select pp.page_id as template_page_id,
                   pp.sort_key as template_page_sort_key,
                   pem.element_id as template_element_id,
                   pem.sort_key as template_element_sk,
                   pem.name as template_element_name,
                   pem.region as template_element_region
            from portals p,
                 portal_element_map pem,
                 portal_pages pp
            where p.portal_id = :portal_id
            and p.template_id = pp.portal_id
            and pp.page_id = pem.page_id
            and pem.datasource_id = :ds_id
	    and pem.name <> 'static_portlet'
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

    <fullquery name="portal::add_element_to_region.get_sort_key">
      <querytext>
        select max(sort_key) + 1
        from portal_element_map
        where region = :region and page_id = :page_id
      </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_get_source_page_id">
        <querytext>
            select page_id
            from portal_pages
            where portal_id = :template_id
            and sort_key = :sort_key
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_page_update">
        <querytext>
            update portal_pages
            set pretty_name = :pretty_name,
                layout_id = :layout_id
            where page_id = :target_page_id
        </querytext>
    </fullquery>

    <fullquery name="portal::add_element_to_region.template_insert">
        <querytext>
            insert into portal_element_map
            (element_id, name, pretty_name, page_id, datasource_id, region, state, sort_key)
            select
            :new_element_id, :ds_name, :pretty_name, :target_page_id, :ds_id, region, state, sort_key
            from portal_element_map pem
            where pem.element_id = :template_element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::swap_element.get_my_sort_key_and_page_id">
        <querytext>
            select sort_key as my_sort_key,
                   page_id as my_page_id
            from portal_element_map
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::swap_element.swap_sort_keys_1">
        <querytext>
            update portal_element_map
            set sort_key = :dummy_sort_key
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::swap_element.swap_sort_keys_2">
        <querytext>
            update portal_element_map
            set sort_key = :my_sort_key
            where element_id = :other_element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::swap_element.swap_sort_keys_3">
        <querytext>
            update portal_element_map
            set sort_key = :other_sort_key
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::get_element_region.get_element_region_select">
        <querytext>
            select region
            from portal_element_map
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::hideable_p_not_cached.select_hideable_p">
        <querytext>
            select value
            from portal_element_parameters
            where element_id = :element_id
            and key = 'hideable_p'
        </querytext>
    </fullquery>

    <fullquery name="portal::hidden_elements_list_not_cached.select_hidden_elements">
        <querytext>
            select element_id,
                   pem.pretty_name
            from portal_element_map pem,
                 portal_pages pp
            where pp.portal_id = :portal_id
            and pp.page_id = pem.page_id
            and pem.state = 'hidden'
            order by name
        </querytext>
    </fullquery>

    <fullquery name="portal::non_hidden_elements_p.non_hidden_elements_p_select">
        <querytext>
            select 1
            from dual
            where exists (select 1
                          from portal_element_map pem
                          where pem.page_id = :page_id
                          and pem.state != 'hidden')
        </querytext>
    </fullquery>

    <fullquery name="portal::set_element_param.update">
        <querytext>
            update portal_element_parameters
            set value = :value
            where element_id = :element_id
            and key = :key
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
            where element_id = :element_id
            and key = :key
        </querytext>
    </fullquery>

    <fullquery name="portal::remove_element_param_value.delete">
        <querytext>
            delete
            from portal_element_parameters
            where element_id = :element_id
            and key = :key
            and value= :value
        </querytext>
    </fullquery>

    <fullquery name="portal::remove_all_element_param_values.delete">
        <querytext>
            delete
            from portal_element_parameters
            where element_id = :element_id
            and key = :key
        </querytext>
    </fullquery>

    <fullquery name="portal::get_element_param.select">
        <querytext>
            select value
            from portal_element_parameters
            where element_id = :element_id
            and key = :key
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
            from portal_element_map pem,
                 portal_element_themes pet,
                 portal_datasources pd
            where pet.theme_id = :theme_id
            and pem.element_id = :element_id
            and pem.datasource_id = pd.datasource_id
        </querytext>
    </fullquery>

    <fullquery name="portal::element_params_not_cached.params_select">
        <querytext>
            select key,
                   value
            from portal_element_parameters
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::evaluate_element.select_portal_id">
        <querytext>
            select portal_id
            from portal_pages
            where page_id = (select page_id
                             from portal_element_map
                             where element_id= :element_id)
        </querytext>
    </fullquery>

    <fullquery name="portal::evaluate_element_raw.element_select">
        <querytext>
            select element_id,
                   datasource_id,
                   state
            from portal_element_map
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::evaluate_element_raw.params_select">
        <querytext>
            select key,
                   value
            from portal_element_parameters
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_element.select">
        <querytext>
            select portal_id,
                   datasource_id
            from portal_element_map pem,
                 portal_pages pp
            where element_id = :element_id
            and pem.page_id = pp.page_id
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_element.hide_update">
        <querytext>
            update portal_element_map
            set state = 'hidden'
            where element_id = :element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::get_datasource_name.select">
        <querytext>
            select name
            from portal_datasources
            where datasource_id = :ds_id
        </querytext>
    </fullquery>

    <fullquery name="portal::get_datasource_id.select">
        <querytext>
            select datasource_id
            from portal_datasources
            where name = :ds_name
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

    <fullquery name="portal::datasource_available_p.select">
        <querytext>
            select count(*)
            from portal_datasource_avail_map
            where datasource_id = :datasource_id
            and portal_id = :portal_id
        </querytext>
    </fullquery>

    <fullquery name="portal::make_datasource_unavailable.delete">
        <querytext>
            delete
            from portal_datasource_avail_map
            where portal_id = :portal_id
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
            select portal_element_map.element_id
            from portal_element_map,
                 portal_pages
            where portal_pages.portal_id = :portal_id
            and portal_element_map.datasource_id = :ds_id
            and portal_element_map.page_id = portal_pages.page_id
	    order by portal_element_map.pretty_name
        </querytext>
    </fullquery>

    <fullquery name="portal::get_element_id_by_pretty_name.select">
        <querytext>
            select element_id
            from portal_element_map pem,
                 portal_pages pp
            where pp.portal_id = :portal_id
            and pem.page_id = pp.page_id
            and pem.pretty_name = :pretty_name
        </querytext>
    </fullquery>

    <fullquery name="portal::get_layout_region_count_not_cached.select">
        <querytext>
            select count(*)
            from portal_supported_regions
            where layout_id = :layout_id
        </querytext>
    </fullquery>

    <fullquery name="portal::get_layout_region_list_not_cached.select_region_list">
        <querytext>
            select region
            from portal_supported_regions
            where layout_id = :layout_id
        </querytext>
    </fullquery>

    <fullquery name="portal::get_layout_info.select_layout_info">
        <querytext>
            select layout_id,
                   name as layout_name,
                   description as layout_description
            from portal_layouts
        </querytext>
    </fullquery>

    <fullquery name="portal::set_layout_id.update_layout_id">
        <querytext>
            update portal_pages
            set layout_id = :layout_id
            where page_id = :page_id
        </querytext>
    </fullquery>

    <fullquery name="portal::get_layout_id.get_layout_id_num_select">
        <querytext>
            select layout_id
            from portal_pages
            where portal_id = :portal_id
            and sort_key = :page_num
        </querytext>
    </fullquery>

    <fullquery name="portal::get_layout_id.get_layout_id_page_select">
        <querytext>
            select layout_id
            from portal_pages
            where page_id = :page_id
        </querytext>
    </fullquery>

    <fullquery name="portal::get_layout_id.get_layout_id_name_select">
        <querytext>
            select layout_id
            from portal_layouts
            where name = :layout_name
        </querytext>
    </fullquery>

    <fullquery name="portal::exists_p.select">
        <querytext>
            select 1
            from portals
            where portal_id = :portal_id
        </querytext>
    </fullquery>

    <fullquery name="portal::get_theme_id_from_name.get_theme_id_from_name_select">
        <querytext>
            select theme_id
            from portal_element_themes
            where name = :theme_name
        </querytext>
    </fullquery>

    <fullquery name="portal::get_theme_id.get_theme_id_select">
        <querytext>
            select theme_id
            from portals
            where portal_id = :portal_id
        </querytext>
    </fullquery>

    <fullquery name="portal::get_theme_info_not_cached.get_theme_info_select">
        <querytext>
            select theme_id,
                   name,
                   description
            from portal_element_themes
            order by name
        </querytext>
    </fullquery>

    <fullquery name="portal::get_page_id.get_page_id_from_name">
        <querytext>
            select page_id
            from portal_pages
            where portal_id = :portal_id
            and pretty_name = :page_name
        </querytext>
    </fullquery>

    <fullquery name="portal::portlet_visible_p.portlet_visible">
        <querytext>
            select 1
            from portal_element_map,
                 portal_pages
            where portal_pages.portal_id = :portal_id
            and portal_element_map.datasource_id = :ds_id
            and portal_element_map.page_id = portal_pages.page_id
            and portal_element_map.state <> 'hidden'
            order by portal_element_map.pretty_name
        </querytext>
    </fullquery>
    
</queryset>

