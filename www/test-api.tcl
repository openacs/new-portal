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
set new_portal_id [portal::create $user_id]

# add an bboard PE with a fake instance id
set community_id "2763"

set element_id [faq_portlet::add_self_to_page $new_portal_id $community_id  ]

ns_returnredirect "index"
