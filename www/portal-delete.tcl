# www/portal-delete.tcl

ad_page_contract {
    Deletes the specified portal

    @author Arjun Sanyal
    @creation-date 9/28/2001
    @cvs-id $Id$
} { 
    portal_id:notnull,naturalnum
}

set user_id [ad_conn user_id]

# XXX security!

db_dml delete_portal_perms "
delete from acs_permissions where object_id = $portal_id"

db_dml delete_portal "
delete from portals where portal_id = $portal_id"

portal::delete_portal $portal_id

ns_returnredirect "index"
