# www/index.tcl

ad_page_contract {
    The page that does the work - display the right portal.

    @author AKS
    @creation-date 
    @cvs-id $Id$
} {
    portal_id:naturalnum,notnull,optional
}

set portal_id 2285

set user_id [ad_conn user_id]
#set admin_p [ad_permission_p $package_id admin]
#set write_p [ad_permission_p $package_id write]
#set read_p [ad_permission_p $package_id read]
set master_template [ad_parameter master_template]
set css_path [ad_parameter css_path]

# this should point to the parent portal, if there is one, at some point.

set context_bar {}

# if they explicitly ask for a specific portal in this instance
# (instead of their own or the default), give it to them.

db_0or1row select_portal_and_layout "
  select
    p.portal_id,
    p.name,
    p.owner_id,
    t.filename as template,
    't' as portal_read_p,
    't' as layout_read_p
  from portals p, portal_layouts t
  where p.layout_id = t.layout_id and p.portal_id = :portal_id" -column_array portal

if { ! [info exists portal(portal_id)] } {
    if { ! [info exists portal_id] } {
	if { $admin_p } {
	    ad_returnredirect "portal-ae?edit_default_p=1"
	} else {
	    ad_return_abort_complaint 1 "This portal is not yet configured.  Please try again later."
	}
    } else {
	ad_return_complaint 1 "That portal (portal_id $portal_id) doesn't exist in this instance.  Perhaps it's been deleted?"
    }
    ad_script_abort
}

set read_p 1

if { ! $read_p } {
    if { ! [ info exists portal_id ] } {
	ad_return_complaint 1 "You don't have permission to view this portal."
    } else {
	# fix this link.  There's little chance it's right.
	ad_return_complaint 1 "You don't have permission to view this portal.  You could try the <a href=\"[ad_conn url]\">default.</a>"
    }
    ad_script_abort
}

# put the element IDs into buckets by region...
foreach entry_list [portal_get_elements $portal(portal_id)] {
    array set entry $entry_list
    lappend element_ids($entry(region)) $entry(element_id)
}    

# is there an automatic way to determine this path?
set element_src "[portal_path]/www/render-element"

set element_list [array get element_ids]

if { [empty_string_p $element_list] } {
    set portal_id $portal(portal_id)
    ad_return_complaint 1 \
	"This portal has no elements.
         You might want to <a href=\"element-layout?[export_url_vars portal_id]\">edit</a> it."
    ad_script_abort
}

ad_return_template
