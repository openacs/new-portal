<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="portal::create.create_new_portal">
        <querytext>
            select portal__new(
                null,
                :name,
                :theme_id,
                :layout_id,
                :template_id,
                :default_page_name,
                :default_accesskey,
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
            select portal__delete(:portal_id);
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

    <fullquery name="portal::add_element_to_region.template_params_insert">
        <querytext>
            insert into portal_element_parameters
            (parameter_id, element_id, config_required_p, configured_p, key, value)
            select nextval('t_acs_object_id_seq'), :new_element_id, config_required_p, configured_p, key, value
            from portal_element_parameters
            where element_id = :template_element_id
        </querytext>
    </fullquery>

    <fullquery name="portal::add_element_to_region.params_insert">
        <querytext>
            insert into portal_element_parameters
            (parameter_id, element_id, config_required_p, configured_p, key, value)
            select nextval('t_acs_object_id_seq'), :new_element_id, config_required_p, configured_p, key, value
            from portal_datasource_def_params where datasource_id= :ds_id
        </querytext>
    </fullquery>

    <fullquery name="portal::add_element_to_region.insert">
        <querytext>
            insert into portal_element_map
            (element_id, name, pretty_name, page_id, datasource_id, region, sort_key)
            values
            (:new_element_id, :ds_name, :pretty_name, :page_id, :ds_id, :region, :sort_key)
        </querytext>
    </fullquery>

    <fullquery name="portal::add_element_param_value.insert">
        <querytext>
            insert into portal_element_parameters
            (parameter_id, element_id, configured_p, key, value)
            select nextval('t_acs_object_id_seq'), :element_id, 't', :key, :value
            from dual
            where not exists (select parameter_id
                              from portal_element_parameters
                              where element_id = :element_id
                              and key = :key
                              and value= :value)
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
            select portal_page__new(
                null,
                :pretty_name,
                :accesskey,
                :portal_id,
                :layout_id,
                'f',
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
            select portal_page__delete(:page_id);
        </querytext>
    </fullquery>

    <fullquery name="portal::swap_element.get_prev_sort_key">
        <querytext>
            select sort_key as other_sort_key,
                   element_id as other_element_id
            from (select pem.sort_key,
                         element_id
                  from portal_element_map pem,
                       portal_pages pp
                  where pp.portal_id = :portal_id
                  and pem.page_id = :my_page_id
                  and pp.page_id = pem.page_id
                  and region = :region
                  and pem.sort_key < :my_sort_key
                  and state != 'pinned'
                  order by pem.sort_key desc) as sort_keys
                  limit 1
        </querytext>
    </fullquery>

    <fullquery name="portal::swap_element.get_next_sort_key">
        <querytext>
            select sort_key as other_sort_key,
                   element_id as other_element_id
            from (select pem.sort_key,
                         element_id
                  from portal_element_map pem, portal_pages pp
                  where pp.portal_id = :portal_id
                  and pem.page_id = :my_page_id
                  and pem.page_id = pp.page_id
                  and region = :region
                  and pem.sort_key > :my_sort_key
                  and state != 'pinned'
                  order by pem.sort_key) as sort_keys
                  limit 1
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_max_page_id_select">
        <querytext>
            select page_id
            from portal_pages
            where portal_id = :portal_id
            order by sort_key desc
            limit 1
        </querytext>
    </fullquery>

    <fullquery name="portal::configure_dispatch.revert_min_page_id_select">
        <querytext>
            select page_id
            from portal_pages
            where portal_id = :portal_id
            order by sort_key
            limit 1
        </querytext>
    </fullquery>

</queryset>
