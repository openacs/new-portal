# www/portal-ae.tcl

ad_page_contract {
    edit a portal.

    @author Arjun Sanyal
    @creation-date 9/28/2001
    @cvs-id $Id$
} {
    portal_id:naturalnum,notnull
}

set user_id [ad_conn user_id]
set master_template [ad_parameter master_template]


# We got a portal_id, check if the user is allowed to mess with it
db_1row select_owner_id "select owner_id from portals where portal_id = :portal_id"
if { $owner_id != $user_id } {
    # They are not allowed XXX perms
    return
} else {
    set owner_where $user_id
}


# get the layouts
set layout_count 0
template::multirow create layouts layout_id name description filename resource_dir checked

db_foreach get_layouts "
select 
layout_id, 
name, 
description, 
filename, 
resource_dir, 
' ' as checked
from portal_layouts
order by name" {

    set resource_dir "$resource_dir"

    # this is evil and broken.  
    # I should be able to pass it a list, straight from db_list.
    template::multirow append layouts $layout_id $name $description $filename $resource_dir $checked
    incr layout_count
}

set title "Edit Your Portal"
# the portal we're editing exists.  Return it.
db_1row get_portal "select
name,
layout_id
from portals
where portal_id = :portal_id"
ad_return_template

