# www/admin/portal-ae-2.tcl

ad_page_contract {
    Generate a page with the same layout as the portal, for editing.

    @author Arjun Sanyal
    @creation-date 9/28/2001
    @cvs-id $Id$
} {
    name:nohtml,notnull
    layout_id:naturalnum,notnull,permission(read),optional
    portal_id:naturalnum,notnull
}

# XXX permission filter?

set user_id [ad_conn user_id]
set master_template [ad_parameter master_template]

db_transaction {
    # does the portal exist?
    if { [portal_exists_p] } {

	# aks - update the vars XXX fixme

	
	# which vars should be set?
	# (yes, I know, dynamic SQL is bad.  tell me how to do it otherwise, k?)
	#	foreach var [ list name template_id ] {
	    #	    if { [info exists $var] } {
		#		lappend things_to_set "$var = :$var"
		#	    }
		#	}
	
	#db_dml update_portal \
	#    "update portals set [join $things_to_set ","] where portal_id = :portal_id"
		# 
		
	    } else {

    # portal doesn't exist yet.  Create it.

    # undefined name? - this should not happen - aks 
    if { ! [info exists name] } {
	set name "Untitled Portal"
    }
    
    # insert the portal and grant permission on it.    
    db_exec_plsql insert_portal {
	declare
	
	pid portals.portal_id%TYPE;
	
	begin
	
	pid := portal.new ( 
	    portal_id => :portal_id,
	    name => :name,
	    owner_id => :user_id,
	    parent_portal_id => :default_portal_id 
	    );
	
	acs_permission.grant_permission ( 
	    object_id => pid,
	    grantee_id => :user_id,
	    privilege => 'read' 
	);
	
	acs_permission.grant_permission ( 
	    object_id => pid,
	    grantee_id => :user_id,
	    privilege => 'write'
	);
	
	acs_permission.grant_permission ( 
	    object_id => pid,
	    grantee_id => :user_id,
	    privilege => 'admin'
	);
	end;
    }
}


ns_returnredirect "element-layout?[export_url_vars portal_id]"
