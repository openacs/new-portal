# www/element-add.tcl
ad_page_contract {
    Add an element to a portal by binding a DS to a PE
} {
    portal_id:naturalnum,notnull,permission(write)
    name:trim,notnull,nohtml
    region:notnull
    datasource_id:naturalnum,notnull
}

# XXX fix me portal_element_themes
# XXX permisson read filter on ds_id?

set ds_id $datasource_id
set layout_id [portal_get_layout_id $portal_id]

# this is required to execute the query that initializes the
# datastructures used by portal_region_immutable_p
portal_get_regions $layout_id

if { [portal_region_immutable_p $region] && ! [portal_default_p $portal_id] } {
    ad_return_complaint 1 "You don't have permission to edit this region."
    return
}

set master_template [ad_parameter master_template]

# shouldn't it be possible to do this with one query?  Hmmm.

# can the user read this element?
if { ! [ad_permission_p $ds_id read] } {
    # XXX complain loudly
    continue
}

# Bind the DS to the PE by inserting into the map
set new_element_id [db_nextval acs_object_id_seq]


db_transaction {
    db_dml insert_into_map "
    insert into portal_element_map
    (element_id, name, portal_id, datasource_id, theme_id, region, sort_key)
    values
    (:new_element_id, 
    :name, 
    :portal_id, 
    :ds_id, 
    nvl((select max(theme_id) from portal_element_themes), 1), 
    :region,  
    nvl((select max(sort_key) + 1 from portal_element_map where region = :region), 1))" 
    
    db_foreach get_def_params "
    select config_required_p, configured_p, key, value
    from portal_datasource_def_params
    where datasource_id = :ds_id" {
	set new_param_id [db_nextval acs_object_id_seq]
	db_dml insert_into_params "
	insert into partal_element_parameters
	(parameter_id, element_id, config_required_p, configured_p)
	values
	(:new_param_id, :new_element_id, :config_required_p, :configured_p)"
    }
    
}   on_error {
    ad_return_complaint "The DML failed."
}


# Check if the PE needs to be configured i.e. "config_required_p = t"
# and "configured_p = f" for this DS in the
# portal_datasource_def_params table. If so, redirect to configure it

# can the user read this element?
if { ! [ad_permission_p $ds_id read] } {
    continue
}

if { [db_0or1row check_config_select "
     select config_path 
     from portal_datasource_def_params dsdp, portal_datasources ds
     where dsdp.datasource_id = :ds_id and
     dsdp.datasource_id = ds.datasource_id and
     dsdp.config_required_p = 't' and
     dsdp.configured_p = 'f'"] } {
    # This PE needs to be configured, redirect to config page
    ad_returnredirect "$config_path?[export_url_vars new_element_id]"	
}

ad_returnredirect "element-layout?[export_url_vars portal_id]"


