# www/admin/portal-ae-2.tcl

ad_page_contract {
    Generate a page with the same layout as the portal, for editing.

    @author Arjun Sanyal
    @creation-date 9/28/2001
    @cvs-id $Id$
} {
    name:nohtml,notnull
    layout_id:naturalnum,notnull,optional
    portal_id:naturalnum,notnull
}

# XXX we are not creating portals here anymore, just redirect
#  permission filter? The vars are in the URL !!! BAD!


ns_returnredirect "element-layout?[export_url_vars portal_id]"
