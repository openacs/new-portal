# www/element-add.tcl
ad_page_contract {
    Add an element to a portal by binding a DS to a PE
} {
    portal_id:naturalnum,notnull,permission(write)
    name:trim,notnull,nohtml
    region:notnull
    ds_ids:naturalnum,multiple,notnull
}

# XXX fix me themes
# XXX check for name constraint violations

# AKS: most of the references to "element" here are really
# to DS

# Check if any of the PEs need to be configured
# i.e. "config_required_p = t" and "configured_p = f" for this DS in
# the portal_datasource_def_params table. If so, redirect to configure
# it, then remove it from the PE list and come back here.  

foreach ds_id $ds_ids {
    # can the user read this element?
    if { ! [ad_permission_p $ds_id read] } {
	continue
    }

    if { ! [db_0or1row check_config_select "
    select 1 
    from portal_datasource_def_params
    where datasource_id = :ds_id and
    config_required_p = 't' and
    configured_p = 'f'"] } {
	# needs to be configured, redirect to config page
	# everything that this page needs along the way
	set ds_to_configure $ds_id
	ad_returnredirect "element-config?[export_url_vars portal_id name region ds_ids ds_to_configure]"	
    }
}


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
foreach ds_id $ds_ids {
    # can the user read this element?
    if { ! [ad_permission_p $ds_id read] } {
	continue
    }

    set new_element_id [db_nextval acs_object_id_seq]

    db_dml insert_into_map "
    insert into portal_element_map
    (element_id,
    name, 
    portal_id,
    datasource_id, 
    theme_id,
    region,
    sort_key)
    values
    (:new_element_id,
    :name,
    :portal_id,
    :ds_id,
    nvl((select max(theme_id) from portal_element_themes), 1),
    :region,
    nvl((select max(sort_key) + 1 from portal_element_map where region = :region), 1))"
}

ad_returnredirect "element-layout?[export_url_vars portal_id]"
