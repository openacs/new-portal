# tcl/filter-procs.tcl

ad_library {
    ad_page_contract filters specific to portal.
    
    @author Ian Baker (ibaker@arsdigita.com)
    @creation-date 12/13/2000
    @cvs-id $Id$
}

ad_page_contract_filter permission { name value permission } {
    Checks whether the current user has the specified permission on the object indicated by $value.
    If $value is the empty string, return true.

    @param name
    @param value
    @param permission
} {
    # don't use ad_require_permission, since it prohibits inclusion of any other
    # complaints.
    if { ![empty_string_p $value] && ![ad_permission_p $value read] } {
	ad_complain "You don't have $permission permission on $name, or the object doesn't exist."
	return 0
    }
    return 1
}


ad_page_contract_filter object_read { name value } {
    The value is an ACS Object.  Checks whether the current user can read it.
} {
    ns_log Notice "*****************deprecated"
    if { ! [ad_permission_p $value read] } {
	ad_complain "You don't have permission to read $name, or it doesn't exist."
	return 0
    }
    return 1
}

ad_page_contract_filter object_write { name value } {
    The value is an ACS Object.  Checks whether the current user can write it.
} {
    ns_log Notice "*****************deprecated"

    if { ! [ad_permission_p $value write] } {
	ad_complain "You don't have permission to write $name, or it doesn't exist."
	return 0
    }
    return 1
}

ad_page_contract_filter object_admin { name value } {
    The value is an ACS Object.  Checks whether the current user can admin it.
} {
    ns_log Notice "*****************deprecated"

    if { ! [ad_permission_p $value admin] } {
	ad_complain "You don't have permission to administer $name, or it doesn't exist."
	return 0
    }
    return 1
}
