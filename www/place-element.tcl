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

set user_id [ad_conn user_id]
set my_url [ad_conn url]

# this is actually the portal_id.  It's passed as element_id to make
# the template designer's job a little easier (one less thing to pass,
# since it's seldom used anyway) perhaps it should be named something
# that can represent both values...?  

set portal_id $element_id

# can this region be edited?
if { [portal_region_immutable_p $region] } {
    set immutable_p 1
    set would_be_immutable_p 0
} else {
    set immutable_p 0
    set would_be_immutable_p 0
}

# get the elements for this region.
set region_count 0
template::multirow create element_multi element_id name sort_key
db_foreach select_elements_by_region \
    "select pe.element_id, pe.name, pe.sort_key
     from portal_element_map pe
     where
       pe.portal_id = :portal_id and
       pe.region = :region 
     order by pe.sort_key" \
{
    template::multirow append element_multi $element_id $name $sort_key
    if {![portal_region_immutable_p $region]} {
	incr region_count
    }
}


db_1row select_all_noimm_count \
"select count(*) as all_count
from portal_element_map
where
portal_id = :portal_id
and region not like 'i%'"
