# www/show-portal.tcl

ad_page_contract {
    Display the portal.

    @author AKS
    @creation-date 
    @cvs-id $Id$
} {
    portal_id:naturalnum,notnull
}



ns_return 200 text/html [portal::render_portal $portal_id]


