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

</queryset>
