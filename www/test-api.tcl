# www/test-api.tcl

ad_page_contract {
    Test the portals API

    @author Arjun Sanyal
    @creation-date 9/28/2001
    @cvs-id $Id$
} { 
}

set user_id [ad_conn user_id]

# make a new portal
set new_portal_id [portal_create_portal $user_id]

# add an element
set ds_name "null-datasource"
set element_id [portal_add_element $new_portal_id $ds_name]

# get a def param
set key "foo"
set value [portal_get_element_param $element_id $key]

ns_log Notice "AKS20: value: $value"
# alter param
set value "Just like honey"

portal_set_element_param $element_id $key $value

ns_returnredirect "index"
