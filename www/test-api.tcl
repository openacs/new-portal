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
set ds_name "NULL datasource"
set foo [portal_add_element $new_portal_id $ds_name]

#set up some params


ns_returnredirect "index"
