# www/portal-config.tcl

ad_page_contract {
    Main configuration page for a portal

    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 10/20/2001
    @cvs-id $Id$
} {
    portal_id:naturalnum,notnull
}

# Get the portal's name for the title
set name [portal::get_name $portal_id]

set rendered_page [portal::configure $portal_id]

ad_return_template
