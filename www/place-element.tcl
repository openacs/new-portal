# www/place-element.tcl
ad_page_contract {
    Place elements.

    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
    @cvs_id $Id$
} -properties {
    region:onevalue
    action_string:onevalue
    portal_id:onevalue
}



# this is actually the portal_id.  It's passed as element_id to make
# the template designer's job a little easier (one less thing to pass,
# since it's seldom used anyway) perhaps it should be named something
# that can represent both values...?  

# AKS: XXX fixme 
set portal_id $element_id

set layout_id [portal::get_layout_id $portal_id]

db_1row select_num_regions "
select count(*) as num_regions
from portal_supported_regions
where layout_id = :layout_id"


# get the elements for this region.
set region_count 0
template::multirow create element_multi element_id name sort_key state
db_foreach select_elements_by_region {
    select element_id, name, sort_key, state
     from portal_element_map
     where
       portal_id = :portal_id 
       and region = :region 
       and state != 'hidden'
    order by sort_key } {
	template::multirow append element_multi \
		$element_id $name $sort_key $state
	incr region_count
    }


db_1row select_all_noimm_count \
"select count(*) as all_count
from portal_element_map
where
portal_id = :portal_id
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
     from portal_element_map pem
     where
       pem.portal_id = :portal_id 
       and pem.state = 'hidden'
    order by name
} {
    set show_avail_p 1
    append show_html "<option value=$element_id>$name</option>\n"
}

append show_html ""
        
