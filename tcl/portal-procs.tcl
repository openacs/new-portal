# tcl/portal-procs.tcl
#
# "The Mystic Portal! Oooo!"  --Toy Story 2

ad_library {
    Portal.
    
    @author Ian Baker (ibaker@arsdigita.com)
    @creation-date 12/1/2000
    @cvs-id $Id$
}

ad_proc -public full_portal_path { } {
    The path to the portal package. This is a stopgap for development. 
    Something smarter will be done later.

    @return path to portal package

    @creation-date Spetember 2001
} {
    return "/web/arjun/openacs-4/packages/new-portal"
}

ad_proc -public portal_path { } {
    The path to the portal package from acs root. This is a stopgap
    for development.
    Something smarter will be done later.

    @return path to portal package

    @creation-date Spetember 2001
} {
    return "/packages/new-portal"
}

ad_proc -public portal_exists_p { portal_id } {
    Check if a portal by that id exists.

    @return 1 on success, 0 on failure
    @param a portal_id
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date September 2001
} {
    if { [db_0or1row select_portal_exists "select 1 from portals where portal_id = :portal_id"]} {
	return 1
    } else {
	return 0
    }
}


ad_proc -public portal_render_portal { portal_id } {
    Get a portal by id. If it's not found, say so.

    @return Fully rendered portal or error message
    @param element_id The object-id for the element that you'd like to retrieve.
    @author AKS
    @creation-date
} {

db_0or1row select_portal_and_layout "
  select
    p.portal_id,
    p.name,
    p.owner_id,
    l.filename as layout
  from portals p, portal_layouts l
  where  p.portal_id = :portal_id" -column_array portal

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



}



ad_proc -public portal_evaluate_element { element_id } {
    Get an element.  Combine the datasource, template, etc.  Return a suitable
    chunk of HTML.

    @return A string containing the fully-rendered content for $element_id.
    @param element_id The object-id for the element that you'd like to retrieve.
    @author Ian Baker (ibaker@arsdigita.com)
    @creation-date December 2000
} {
    # the caching in here needs to be completely redone.  It totally sucks.

    # get the element.
    if { [info exists flush] } {
	set flush_p 1
	util_memoize_flush [ list portal_fetch_element_data $element_id ]
    } else {
	set flush_p ""
    }

    array set element [util_memoize [list portal_get_element_data $element_id] ]

    if { ! [info exists element(element_id)] } {
	# no permission, probably.  Debug?
	return
    }

    # get the datasource and configuration.
    if { [info exists flush] } {
	util_memoize_flush [list portal_get_datasource $element(datasource_id)]
	util_memoize_flush [list portal_get_element_parameters $element(config_id)]
    }
    array set datasource [ util_memoize [list portal_get_datasource $element(datasource_id)] ]
    set element(config) [ util_memoize [list portal_get_element_parameters $element(config_id) ] ]

    if { ! [info exists datasource(datasource_id)] } {
	# permissions likely didn't match.  Debug?
	return
    }

    # untaint the data-type before passing it through eval, just in case.
    if { ! [regexp {^[\w\-]+$} $datasource(data_type)] } {
	error "Bad data_type: $datasource(data_type)"
	return
    }

    # evaulate the datasource.
    #  it might be good to (optionally) cache this, since it can be an expensive step.
    set element(content) [ eval { 
	portal_render_datasource_$datasource(data_type) [array get datasource] $element(config)
    } ]

    # this is sometimes used when interacting with templates in the filesystem.
    set element(mime_type) $datasource(mime_type)
    regsub -all {/} $element(mime_type) {+} element(mime_type_noslash)
    
    return [array get element]
}

ad_proc -private portal_get_element_data { element_id } {
    Fetch element data.

    @param element_id The element's ID.
    @return a list-ified array containing the information from portal_elements and portal_templates for $element_id.
    @author Ian Baker (ibaker@arsdigita.com)
    @creation-date December 2000
} {
    set user_id [ad_conn user_id]

    if { ! [db_0or1row select_element_data {
	select
	element_id,
	name,
	datasource_id,
	template_id,
	description,
	config_id,
	exportable_p,
	filename,
	decode(acs_permission.permission_p(element_id, :user_id, 'read'), 't', 1, 'f', 0) as element_read_p,
	decode(acs_permission.permission_p(template_id, :user_id, 'read'), 't', 1, 'f', 0) as template_read_p
	from portal_elem_tmpl
	where
	element_id = :element_id } -column_array element_data ]
     } {
	return -code error "That element doesn't exist."
    }
    
    if { ! [ regexp {^/} $element_data(filename)] } {
# AKS - hack
	set element_data(filename) "/packages/new-portal/www/$element_data(filename)"
    }

    if { $element_data(element_read_p) } {
	if { $element_data(template_read_p) } {
	    return [array get element_data]
	} else {
	    return -code error "Read permission on template $template_id required."
	}
    } else {
	return -code error "Read permission on element $element_id required."
    }

}


ad_proc -private portal_get_element_parameters { config_id } {
    Fetch element parameters.

    @param config_id The configuration's ID.
    @author Ian Baker (ibaker@arsdigita.com)
    @creaton-date December 2000
} {
    set user_id [ad_conn user_id]

    db_foreach select_element_params "
    select key, value
    from portal_element_parameters
    where
      config_id = :config_id and
      acs_permission.permission_p(config_id, :user_id, 'read') = 't'
    order by key" {
	lappend config($key) $value
    } if_no_rows {
	# this might happen if the passed config_id was null, which will happen occasionally.
	# (though not too often, since this empty return value will be cached...)
	array set config {}
    }
    
    return [array get config]
}

ad_proc -private portal_get_datasource { datasource_id } {
    Fetch datasource data.

    @param datasource_id The element's ID.
    @author Ian Baker (ibaker@arsdigita.com)
    @creaton-date December 2000
} {
    set user_id [ad_conn user_id]

    if { ! [db_0or1row select_datasource_data {
	select
        datasource_id,
        name,
        description,
        content,
        mime_type,
        data_type,
        default_config_id,
	decode(acs_permission.permission_p(datasource_id, :user_id, 'read'), 't', 1, 'f', 0) as datasource_read_p
	from portal_datasources
	where datasource_id = :datasource_id } -column_array datasource ]
     } {
	return -code error "That datasource doesn't exist."
    }

    if { ! $datasource(datasource_read_p) } {
	return -code error "Inadequate permissions on datasource $datasource_id"
    }
    
    # There's no provision to flush these, but they should update so
    # infrequently as to never need flushing (essentially, only when
    # the package is upgraded).
    array set datasource [ util_memoize [ list portal_data_type data_type $datasource(data_type) ] ]
    
    return [array get datasource]
}

ad_proc -private portal_data_type { type name } {
    Get the details about a data or mime type.  The idea here is that
    the caller will cache the call to this proc with util_memoize.

    @param type Which type to fetch (mime_type or data_type)
    @param id The id if the type.
    @author Ian Baker (ibaker@arsdigita.com)
    @creaton-date December 2000
} {
    if {$type == "data_type"} {
	db_1row select_data_type "select pretty_name as data_type_pretty, secure_p, sort_key as data_type_sort_key
                 from portal_data_types
                 where name = :name" -column_array type_details
    } elseif {$type == "mime_type"} {
	db_1row select_mime_type "select pretty_name as mime_type_pretty, sort_key as mime_type_sort_key
                 from portal_mime_types
                 where name = :name" -column_array type_details
    } else {
	error "Invalid type: $type"
	return
    }
    return [ array get type_details ]
}

ad_proc -private portal_data_types { type } {
    Get all the entries in a data_type table, sorted by sort_key.

    @param type Which type to fetch (mime_type or data_type)
    @return For data_type, a db_list_of_lists containing name, pretty_name, secure_p, sort_key.  For mime_type, name, pretty_name, sort_key.
    @author Ian Baker (ibaker@arsdigita.com)
    @creaton-date December 2000
} {
    if {$type == "data_type"} {
	return [ db_list_of_lists select_all_data_types "select name, pretty_name, secure_p, sort_key
                 from portal_data_types
                 order by sort_key" ]
    } elseif {$type == "mime_type"} {
	return [ db_list_of_lists select_all_mime_types "select name, pretty_name, sort_key
                 from portal_mime_types
                 order by sort_key" ]
    } else {
	error "Invalid type: $type"
    }
}

# put a proc here for retrieving stuff from the portal/element map (so
# it can me memoized by index.tcl)
ad_proc -private portal_get_elements { portal_id } {
    Get the portal_element_map entries for a portal.

    @param portal_id The portal in question's ID.
    @return A list of lists.  Each sublist is suitable for passing through 'array set', yielding an array with the keys 'element_id', 'region', 'sort_key'.
} {
    set user_id [ad_conn user_id]

    db_foreach select_p_e_map "
    select m.element_id, m.region, m.sort_key
    from portal_element_map m
    where m.portal_id = :portal_id and
    acs_permission.permission_p(m.element_id, :user_id, 'read') = 't'
    order by region, sort_key, element_id" -column_array entry {
	lappend entries [array get entry]
    } if_no_rows {
	set entries {}
    }
    
    return $entries
}

ad_proc -private portal_default_p { portal_id } {
    @return 1 if portal_id is a default portal (NULL owner_id), 0 otherwise.  Please make sure that the portal exists.
} {
    db_1row check_default "select decode(owner_id, null, 1, 0) as default_portal_p from portals where portal_id = :portal_id"
    return $default_portal_p
}

ad_proc -public portal_arg { config key } {
    Used in building Tcl datasources.  This is the method by which the value
    (or values) of an argument may be fetched by the datasource to which
    it applies.

    @param config The configuration variable passed to the datasource.
    @param key The name of the argument for which you'd like the values.
    @return a list containing all the values for $key for the current datasource.  If there are no values, returns the empty string.
} {
    array set cf $config
    if { [info exists cf($key)] } {
	return $cf($key)
    } else {
	return {}
    }
}

ad_proc -public portal_info { flag } {
    Return information about the current connection that's relevant to the current connection.<p>
    Currently, the following keys are available:<br>

    <ul>
    <li>
      <b>default_portal_id</b>: The default portal (if any) for the current connection.
                                If none is available, returns the empty string.
    </li>
    <li>
      <b>parent_portal_id</b>: The ultimate parent portal for the current connection.  In some cases, the default will
                               still be a child of some other portal.  This returns the absolute parent, whatever its package_id.
    </li>
    </ul>

    A value is retrieved only once per session.

    @param flag The name of the parameter you'd like.
} {
    global portal_info

    set package_id [ad_conn package_id]

    if { ! [info exists portal_info($flag)] } {
	if { $flag == "default_portal_id" } {

	    db_0or1row get_default \
		"select portal_id as info_value
                 from portals
                 where package_id = :package_id and owner_id is null"

	} elseif { $flag == "parent_portal_id" } {

	    db_0or1row get_parent \
		"select portal.parent(default_portal_id) as info_value
                 from (
                   select portal_id as default_portal_id
                   from portals
                   where package_id = :package_id and owner_id is null
                 )"

	} else {
	    reutrn -code error "Don't know what to do with $flag.  Expecting one of: default_portal_id, parent_portal_id"
	}

	if { ! [info exists info_value] } {
	    set info_value {}
	}

	set portal_info($flag) $info_value
    }

    return $portal_info($flag)
}

ad_proc -private portal_get_template_id { portal_id } {
    Get the template_id of a layout template for a portal.

    @param portal_id The portal_id.
    @return A template_id.
    @creation-date 2/13/2001
    @author Ian Baker (ibaker@arsdigita.com)
} {
    db_1row get_template_id {
	select template_id from portals where portal_id = :portal_id
    }

    return $template_id
}

ad_proc -private portal_get_regions { layout_id } {
    Set the current layout, returning the regions that it supports.

    @param layout_id
    @return a list containing the name of each region, in no particular order.
    @creation-date 9/28/2001
    @author Arjun Sanyal (arjun@openforce.net)
} {
    global portal_region_immutable_p
    global portal_region_list

    if { ! [info exists portal_region_list($layout_id) ] } {
	db_foreach get_regions {
	    select
	    region,
	    decode(immutable_p, 't', 1, 'f', 0) as immutable_p
	    from portal_supported_regions
	    where layout_id = :layout_id
	} {
	    set portal_region_immutable_p($region) $immutable_p
	    lappend portal_region_list $region
	}
    }

    return $portal_region_list
}

ad_proc -private portal_region_immutable_p { region } {
    Check to see if a region in the current layout template is immutable.

    @param region The region
    @return 1 if the region is marked immutable, 0 otherwise.
    @creation-date 2/13/2001
    @author Ian Baker (ibaker@arsdigita.com)
} {
    global portal_region_immutable_p

    if { ! [info exists portal_region_immutable_p($region)] } {
	# I'd like to just call it here, but the template datasource that calls
	# this won't know what the current layout template is.
	return -code error "Region $region doesn't exist, or portal_get_regions hasn't been called"
    }

    return $portal_region_immutable_p($region)
}
