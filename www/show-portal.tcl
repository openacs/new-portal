# www/show-portal.tcl

ad_page_contract {
    Display the portal.

    @author AKS
    @creation-date 
    @cvs-id $Id$
} {
    portal_id:naturalnum,notnull
}



portal::render_portal $portal_id


