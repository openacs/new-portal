# www/element-move.tcl
ad_page_contract {
    Move an element up or down one space in an area.

    @author Arjun Sanyal
    @creation-date 10/20/2001
    @cvs_id $Id$
} {
    portal_id:naturalnum,notnull
    sort_key:naturalnum,notnull
    region:notnull
    direction:notnull
}

ad_require_permission $portal_id portal_read_portal
ad_require_permission $portal_id portal_edit_portal

# AKS: XXX locked areas

db_dml move_element \
    "begin
       portal_element.move(portal_id => :portal_id, region => :region, sort_key => :sort_key, direction => :direction);
     end;"

ns_returnredirect "portal-config?portal_id=$portal_id"
