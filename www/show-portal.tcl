# www/show-portal.tcl

ad_page_contract {
    The page that does the work - display the portal.

    @author AKS
    @creation-date 
    @cvs-id $Id$
} {
    portal_id:naturalnum,notnull,optional
}

set master_template [ad_parameter master_template]

set element_list [portal_setup_element_list 2285]
set element_src [portal_setup_element_src 2285]
array set portal [portal_render_portal 2285]


ad_return_template

