# www/portal-ae.tcl

ad_page_contract {
    Add/edit a portal.

    @author Arjun Sanyal
    @creation-date 9/28/2001
    @cvs-id $Id$
} {
    portal_id:naturalnum,notnull,optional
}

set user_id [ad_conn user_id]
set master_template [ad_parameter master_template]
set create_p 0

# Did we get a portal_id passed in? 
# If not, let make a new one!
if { ! [info exists portal_id] } {
    set create_p 1
    set portal_id [db_nextval acs_object_id_seq]
} else {
    # We got a portal_id, check if the user is allowed to mess with it
    db_1row select_owner_id "select owner_id from portals where portal_id = :portal_id"
    if { $owner_id != $user_id } {
	# They are not allowed XXX perms
	return
    }
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
    if { ! [ regexp {^/} $resource_dir] } {
	# aks - need this resource dir to be a param
	set resource_dir "/packages/new-portal/www/$resource_dir"
    }

    # this is evil and broken.  
    # I should be able to pass it a list, straight from db_list.
    template::multirow append layouts $layout_id $name $description $filename $resource_dir $checked
    incr layout_count
}

# now, get the correct data and return it.
if {$create_p} {
    # there's no data at all.  Just return the template.
    set title "Create a New Portal"
    set name {}
    set template_id {}
    ad_return_template
    return
} else {
    set title "Edit Your Portal"
    # the portal we're editing exists.  Return it.
    db_1row get_portal "select
       portal_id,
       name,
       template_id
     from portals
     where package_id = :package_id and $owner_where"
    ad_return_template
}
