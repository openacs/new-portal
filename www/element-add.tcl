# www/element-add.tcl
ad_page_contract {
    Add an element to a portal.
} {
    portal_id:naturalnum,notnull,object_write
    region:notnull
}

# XXX AKS: Serious datasource security needed here

set user_id [ad_conn user_id]

# this should do a 'preview' type thing, and generate popups for
# descriptions and stuff.  (at least, on the JavaScript-heavy version)
# also, a "show me all the elements, even the ones I'm using" button.

set layout_id [portal_get_layout_id $portal_id]

# this is required to execute the query that initializes the
# datastructures used by portal_region_immutable_p
portal_get_regions $layout_id

if { [portal_region_immutable_p $region] } {
    ad_return_complaint 1 "You don't have permission to edit this region."
    return
}

set master_template [ad_parameter master_template]

template::multirow create element_ids element_id name description 

# XXX we really want to check if they can view these datasources in
# the future something like # where
# acs_permission.permission_p(element_id, :user_id, 'read') = 't' 
 # the barn door is open! Wronly
# called elements for now, too. 
 db_foreach select_elements \
    "select datasource_id, name, description
     from portal_datasources" \
    -column_array element {
    template::multirow append element_ids $element(element_id) $element(name) $element(description)
}

ad_return_template
