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

db_1row select_num_regions "
select count(*) as num_regions
from portal_supported_regions
where layout_id = :layout_id"

# get the elements for this region.
set region_count 0
template::multirow create element_multi element_id name sort_key state hideable_p

db_foreach select_elements_by_region {
    select element_id, pem.pretty_name as name,  pem.sort_key, state
    from portal_element_map pem, portal_pages pp
    where
    pp.portal_id = :portal_id 
    and pp.page_id = :page_id
    and pem.page_id = pp.page_id
    and region = :region 
    and state != 'hidden'
    order by sort_key } {

        set hideable_p [portal::get_element_param $element_id "hideable_p"]
        
	template::multirow append element_multi \
		$element_id $name $sort_key $state $hideable_p
	incr region_count
    }


db_1row select_all_noimm_count \
"select count(*) as all_count
from portal_element_map pem, portal_pages pcp
where
pcp.portal_id = :portal_id
and pcp.page_id = :page_id
and pem.page_id = pcp.page_id
and state != 'hidden'
and region not like 'i%'"

# Set up the form target
set target_stub [lindex [ns_conn urlv] [expr [ns_conn urlc] - 1]]
set show_avail_p 0
set show_html ""
set new_package_id [db_nextval acs_object_id_seq]

append show_html "<select name=element_id>"

db_foreach hidden_elements {
    select element_id, name
     from portal_element_map pem, portal_pages pp
     where
       pp.portal_id = :portal_id 
       and pp.page_id = :page_id
       and pp.page_id = pem.page_id
       and pem.state = 'hidden'
    order by name
} {
    set show_avail_p 1
    append show_html "<option value=$element_id>$name</option>\n"
}


# moving to other pages
set other_page_avail_p 0
set other_page_html "<select name=page_id>"

db_foreach other_pages_select {
    select page_id, pretty_name
     from portal_pages pem
     where
       pp.portal_id = :portal_id 
       and pp.page_id != :page_id
    order by sort_key
} {
    set other_page_avail_p 1
    append other_page_html "<option value=$element_id>$name</option>\n"
}

set dir "[portal::mount_point]/place-element-components"        
