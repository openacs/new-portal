# www/show-portal.tcl

ad_page_contract {
    Display the portal.

    @author AKS
    @creation-date 
    @cvs-id $Id$
} {
    portal_id:naturalnum,notnull
}

set master_template [ad_parameter master_template]

set element_list [portal_setup_element_list $portal_id]
set element_src [portal_setup_element_src $portal_id]
array set portal [portal_render_portal $portal_id]


ad_return_template

