# www/place-element.tcl
ad_page_contract {
    Place elements.

    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
    @cvs_id $Id$
} -properties {
    element_id:onevalue
    region:onevalue
}

set my_url [ad_conn url]

# this is actually the portal_id.  It's passed as element_id to make
# the template designer's job a little easier (one less thing to pass,
# since it's seldom used anyway) perhaps it should be named something
# that can represent both values...?  

set portal_id $element_id

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
and region not like 'i%'"

# Set up the form target
set target_stub [lindex [ns_conn urlv] [expr [ns_conn urlc] - 1]]
set add_avail_p 0
set add_html ""
set new_package_id [db_nextval acs_object_id_seq]

append add_html "<select name=ds_id>"

db_foreach datasource_avail {
    select name, pd.datasource_id 
    from portal_datasources pd, portal_datasource_avail_map pdam
    where pdam.portal_id = :portal_id
    and pd.datasource_id = pdam.datasource_id
    and pd.datasource_id  in (
      select datasource_id
      from portal_element_map
      where portal_id = :portal_id
      and state = 'hidden')
    order by name
} {
    set add_avail_p 1
    append add_html "<option value=$datasource_id>$name</option>\n"
}

append add_html ""
        
