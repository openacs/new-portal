# www/element-layout-2.tcl
ad_page_contract {
    Do the actual moving/removing of the elements, or redirect to add.

    @author Arjun Sanyal
    @creation-date 9/28/2001
    @cvs_id $Id$
} { }

set form [ns_getform]
set portal_id [ns_set get $form portal_id]

set user_id [ad_conn user_id]

portal::configure_dispatch $portal_id $form

ns_returnredirect "portal-config?portal_id=$portal_id"

