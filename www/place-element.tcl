# www/place-element.tcl
ad_page_contract {
    Place elements. IMPROVE ME

    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
    @cvs_id $Id$
} -properties {
    region:onevalue
    action_string:onevalue
    portal_id:onevalue
    element_multi:multirow
}

# this template gets its vars from the layout template (e.g. simple2.adp)

db_1row select_num_regions {}

# get the elements for this region.
set region_count 0
template::multirow create element_multi element_id name sort_key state hideable_p page_id 

db_foreach select_elements_by_region {} {

    set hideable_p [portal::get_element_param $element_id "hideable_p"]
    
    template::multirow append element_multi \
	    $element_id $name $sort_key $state $hideable_p $page_id
    incr region_count
}


db_1row select_all_noimm_count {}

# Set up the form target
set target_stub [lindex [ns_conn urlv] [expr [ns_conn urlc] - 1]]
set show_avail_p 0
set show_html ""
set new_package_id [db_nextval acs_object_id_seq]

append show_html "<select name=element_id>"

db_foreach hidden_elements {} {
    set show_avail_p 1
    append show_html "<option value=$element_id>$name</option>\n"
}

set dir "[portal::mount_point]/place-element-components"        
