<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="portal::create.create_new_portal">
        <querytext>
            begin
                :1 := portal.new (
                    name => :name,
                    layout_id => :layout_id,
                    template_id => :template_id,
                    default_page_name => :default_page_name,
                    default_accesskey => :default_accesskey,
                    theme_id => :theme_id,
                    context_id => :context_id
                );
            end;
        </querytext>
    </fullquery>

    <fullquery name="portal::delete.delete_portal">
        <querytext>
            begin
                portal.del(portal_id => :portal_id);
            end;
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

    <fullquery name="portal::add_element_param_value.insert">
        <querytext>
            insert into portal_element_parameters
            (parameter_id, element_id, configured_p, key, value)
            select acs_object_id_seq.nextval, :element_id, 't', :key, :value
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
            begin
                :1 := portal_page.new(
                    pretty_name => :pretty_name,
                    accesskey => :accesskey,
                    portal_id => :portal_id,
                    layout_id => :layout_id
                );
            end;
        </querytext>
    </fullquery>

    <fullquery name="portal::page_delete.page_delete">
        <querytext>
            begin
                portal_page.del(page_id => :page_id);
            end;
        </querytext>
    </fullquery>

</queryset>
