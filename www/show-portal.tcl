# www/show-portal.tcl

ad_page_contract {
    Just a test script to display the portal.

    @author AKS
    @creation-date 
    @cvs-id $Id$
} {
    portal_id:naturalnum,notnull
}



ns_return 200 text/html [portal::render $portal_id]


