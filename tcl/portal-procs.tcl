# tcl/portal-procs.tcl

ad_library {
    Portal.
    
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date Sept 2001
    @cvs-id $Id$
}

namespace eval portal {

    ad_proc -public create_portal {user_id {layout_name "'Simple 2-Column'"}} {
    Create a new portal for the passed in user id. 

    @return The newly created portal's id
    @param user_id
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {
    # The defualt layout is simple 2 column
    db_1row select_layout \
	    "select layout_id from
            portal_layouts where
            name = $layout_name "
	
    # insert the portal and grant permission on it.    
    return [ db_exec_plsql insert_portal {
	begin
	    
	:1 := portal.new ( 
	layout_id => :layout_id,
	owner_id => :user_id
	);
	    
	acs_permission.grant_permission ( 
	object_id => :1,
	grantee_id => :user_id,
	privilege => 'read' 
	);
	
	acs_permission.grant_permission ( 
	object_id => :1,
	grantee_id => :user_id,
	privilege => 'write'
	);
	    
	acs_permission.grant_permission ( 
	object_id => :1,
	grantee_id => :user_id,
	privilege => 'admin'
	);
	end;
    }]
}

ad_proc -public delete_portal { portal_id } {
    Destroy the portal

    @param portal_id
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {
    return [ db_exec_plsql delete_portal {
	begin
	portal.delete (portal_id => :portal_id);
	end;
    }]
}

ad_proc -public add_element { portal_id ds_name } {
    Add an element to a portal given a datasource name. Used for procs
    that have no knowledge of regions

    @return the id of the new element
    @param portal_id 
    @param ds_name
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {
    # get the regions that the layout supports
    # portal_get_regions [portal_get_layout_id $portal_id]
    # AKS: for now _always_ insert the new PE into region 1
    return [add_element_to_region $portal_id $ds_name 1]
}

ad_proc -public add_element_to_region { portal_id ds_name region } {
    Add an element to a portal in a region, given a datasource name

    @return the id of the new element
    @param portal_id 
    @param ds_name
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {

    # get the ds_id from the ds_name
    db_1row ds_name_select "select datasource_id as ds_id
    from portal_datasources 
    where name = :ds_name"

    # set up a unique name for the PE
    if { [db_0or1row pe_name_unique_check "select 1  
    from portal_element_map
    where portal_id = :portal_id and
    name = :ds_name"] } {
	# XXX sophisticated regsub here
	append ds_name "+1"
    } 

    # Bind the DS to the PE by inserting into the map and
    # copying the default params. 
    set new_element_id [db_nextval acs_object_id_seq]

    db_dml insert_pe_into_map "
    insert into portal_element_map
    (element_id, 
    name, 
    portal_id, 
    datasource_id, 
    theme_id, 
    region, 
    sort_key)
    values
    (:new_element_id, 
    :ds_name, 
    :portal_id, 
    :ds_id, 
    nvl((select max(theme_id) from portal_element_themes), 1), 
    :region,  
    nvl((select max(sort_key) + 1 from portal_element_map where region = :region), 1))" 
	
    db_foreach get_def_params "
    select config_required_p, configured_p, key, value
    from portal_datasource_def_params
    where datasource_id = :ds_id" {
	set new_param_id [db_nextval acs_object_id_seq]
	db_dml insert_into_params "
	insert into portal_element_parameters
	(parameter_id, element_id, config_required_p, configured_p, key, value)
	values
	(:new_param_id, :new_element_id, :config_required_p, :configured_p, :key, :value)"
    }

    # The caller must now set the necessary params or else!
    return $new_element_id
}

ad_proc -public set_element_param { element_id key value } {
    Set an element param

    @return 1 on success
    @param element_id
    @param key
    @param value
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {

    db_dml upadate_parms "
    update portal_element_parameters set value = :value
    where element_id = :element_id and 
    key = :key"

    return 1

}

ad_proc -public get_element_param { element_id key } {
    Get an element param. Returns the value of the param.

    @return the value of the param
    @param element_id
    @param key
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {

    if { [db_0or1row get_parm "
    select value
    from portal_element_parameters 
    where element_id = :element_id and 
    key = :key"] } {
	return $value
    } else {
	ad_return_complaint 1 "portal_get_element_param: Invalid element_id and/or key given."
	ad_script_abort
    }
}


ad_proc -public render_portal { portal_id } {
    Get a portal by id. If it's not found, say so.

    @return Fully rendered portal or error message
    @param element_id The object-id for the element that you'd like to retrieve.
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {
    set user_id [ad_conn user_id]
    #set admin_p [ad_permission_p $package_id admin]
    #set write_p [ad_permission_p $package_id write]
    #set read_p [ad_permission_p $package_id read]
    set master_template [ad_parameter master_template]
    set css_path [ad_parameter css_path]
   

   # put the element IDs into buckets by region...
    foreach entry_list [get_elements $portal_id] {
	array set entry $entry_list
	lappend element_ids($entry(region)) $entry(element_id)
    }    
        
    set element_list [array get element_ids]

    if { [empty_string_p $element_list] } {
	ad_return_complaint 1 \
		"This portal has no elements.
	You might want to <a href=\"element-layout?[export_url_vars portal_id]\">edit</a> it."
	ad_script_abort
    }

    set element_src [portal_path]/www/render-element
 
    set template "<master src=\"@master_template@\">
<property name=\"title\">@portal.name@</property>
<include src=\"@portal.template@\" element_list=\"@element_list@\" element_src=\"@element_src@\">"

    db_0or1row select_portal_and_layout "
    select
    p.portal_id,
    p.name,
    p.owner_id,
    t.filename as template,
    't' as portal_read_p,
    't' as layout_read_p
    from portals p, portal_layouts t
    where p.layout_id = t.layout_id 
  and p.portal_id = :portal_id" -column_array portal

    if { ! [exists_p $portal_id] } {
	ad_return_complaint 1 "That portal (portal_id $portal_id) doesn't exist in this instance.  Perhaps it's been deleted?"
	ad_script_abort
    }

    # This hack is to work around the acs-templating system
    set __adp_stub "[full_portal_path]/www/."
    set {master_template} \"master\" 

    set code [template::adp_compile -string $template]
    ns_log notice "AKS22 got here $code"
    set output [template::adp_eval code]

    if {![empty_string_p $output]} {
        set mime_type [template::get_mime_type]
        set header_preamble [template::get_mime_header_preamble $mime_type]

	ns_return 200 $mime_type "$header_preamble $output"
    }
    
    return

}

ad_proc -public render_element { element_id region_id } {
    Wrapper for the below proc

    @return 
    @param element_id 
    @param region_id 
    @author Arjun Sanyal
    @creation-date Sept 2001
} {

    # get the complete, evaluated element.
    # if there's an error, report it.
    if { [catch {set element_data [evaluate_element $element_id] } errmsg ] } {
	if { [ad_parameter log_datasource_errors_p] } {
	    ns_log Error "portal: $errmsg"
	}
    
	if { [ad_parameter show_datasource_errors_p] } {
	    set element(content) "<div class=portal_alert>$errmsg</div>"
	    set element(mime_type) "text/html"
	} else {
	    return
	}
    } else {
	array set element $element_data
    }
    
    # consistency is good.
    set element(region) $region
    
    # return the appropriate template for that element.
    ad_return_template "layouts/mime-types/$element(mime_type_noslash)"
}

ad_proc -public evaluate_element { element_id } {
    Get an element.  Combine the datasource, template, etc.  Return a suitable
    chunk of HTML.

    @return A string containing the fully-rendered content for $element_id.
    @param element_id The object-id for the element that you'd like to retrieve.
    @author Ian Baker (ibaker@arsdigita.com)
    @creation-date December 2000
} {
 
    # the caching in here needs to be completely redone.  It totally sucks.
    # aks - all catching removed

    array set element [eval [list get_element_data $element_id]]

    if { ! [info exists element(element_id)] } {
	# no permission, probably.  Debug?
	return
    }

    # get the datasource and configuration.
    array set datasource [eval [list get_datasource $element(datasource_id)] ]
    set element(config) [eval [list get_element_parameters $element(element_id) ]]

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
    ns_log Notice "aks29 got here"
    set element(content) [ eval { 
	portal_render_datasource_$datasource(data_type) [array get datasource] $element(config)
    } ]
    ns_log Notice "aks30 got here content is $element(content)"	
	
	# this is sometimes used when interacting with templates in the filesystem.
	set element(mime_type) $datasource(mime_type)
	regsub -all {/} $element(mime_type) {+} element(mime_type_noslash)

	return [array get element]

}

ad_proc -private get_element_data { element_id } {
    Fetch element data.

    @param element_id The element's ID.
    @return a list-ified array containing the information from portal_elements and portal_templates for $element_id.
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date Sept 2001 } {

    set user_id [ad_conn user_id]

    # XXX issue here with element config params

    if { ! [db_0or1row select_element_data {
	select
	pem.element_id,
	pem.name,
	pem.datasource_id,
	pem.theme_id,
	pet.description,
	pet.filename,
	't' as element_read_p,
	't' as template_read_p
	from portal_element_map pem, portal_element_themes pet
	where pem.theme_id = pet.theme_id
	and pem.element_id = :element_id
    } -column_array element_data ]
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

ad_proc -private get_element_parameters { element_id } {
    Fetch element parameters.

    @param element_id
    @author 
    @creaton-date 
} {
    set user_id [ad_conn user_id]

    db_foreach select_element_params "
    select key, value
    from portal_element_parameters
    where
      element_id = :element_id 
    order by key" {
	lappend config($key) $value
    } if_no_rows {
	
	# this might happen if the passed config_id was null, 
	# which will happen occasionally. (though not too often, 
	#since this empty return value will be cached...)
	array set config {}
    }
    
    return [array get config]
}

ad_proc -private get_datasource { datasource_id } {
    Fetch datasource data.

    @param datasource_id The element's ID.
    @author Ian Baker (ibaker@arsdigita.com)
    @creaton-date December 2000
} {
    set user_id [ad_conn user_id]

    if { ! [db_0or1row select_datasource_data {
	select
        datasource_id,
        data_type,
        mime_type,
        name,
        description,
        content
	from portal_datasources
	where datasource_id = :datasource_id } -column_array datasource ]
     } {
	return -code error "That datasource doesn't exist."
    }

#    if { ! $datasource(datasource_read_p) } {
#	return -code error "Inadequate permissions on datasource $datasource_id"
#    }
    
    # There's no provision to flush these, but they should update so
    # infrequently as to never need flushing (essentially, only when
    # the package is upgraded).

#    array set datasource  [ list portal_data_type data_type $datasource(data_type) ]
    
    return [array get datasource]
}

ad_proc -private data_type { type name } {
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

ad_proc -private data_types { type } {
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
ad_proc -private get_elements { portal_id } {
    Get the portal_element_map entries for a portal.

    @param portal_id The portal in question's ID.
    @return A list of lists.  Each sublist is suitable for passing through 'array set', yielding an array with the keys 'element_id', 'region', 'sort_key'.
} {
    set user_id [ad_conn user_id]

    db_foreach select_p_e_map "
    select m.element_id, m.region, m.sort_key
    from portal_element_map m
    where m.portal_id = :portal_id
    order by region, sort_key, element_id" -column_array entry {
	lappend entries [array get entry]
    } if_no_rows {
	set entries {}
    }
    
    return $entries
}

ad_proc -private get_layout_id { portal_id } {
    Get the layout_id of a layout template for a portal.

    @param portal_id The portal_id.
    @return A layout_id.
    @creation-date 9/28/2001
    @author Arjun Sanyal (arjun@openforce.net)
} {
    db_1row get_layout_id {
	select layout_id from portals where portal_id = :portal_id
    }

    return $layout_id
}

ad_proc -private get_regions { layout_id } {
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

ad_proc -private region_immutable_p { region } {
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

ad_proc -public full_portal_path { } {
    The path to the portal package.

    @return path to portal package
    @creation-date Spetember 2001
} { return "/web/arjun/openacs-4/packages/new-portal" }

ad_proc -public portal_path { } {
    The path to the portal package from acs root. 
    
    @return path to portal package
    @creation-date Spetember 2001
} { return "/packages/new-portal" }

ad_proc -public exists_p { portal_id } {
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

ad_proc -public get_datasource_name { ds_id } {
    Get the ds name from the id or the null string if not found.

    @return ds_name
    @creation-date Spetember 2001
} { 
    if {[db_0or1row get_ds_name_from_id "select name from portal_datasources where datasource_id = :ds_id"]} {
	return $name
    } else {
	return ""
    }
}

ad_proc -public portal_path { } {
    The path to the portal package from acs root. 
    
    @return path to portal package
    @creation-date Spetember 2001
} { 
    return "/packages/new-portal" 
}

ad_proc -public layout_elements { element_list {var_stub "element_ids"} } {
    Split a list up into a bunch of variables for inserting into a layout
    template.  This seems pretty kludgy (probably because it is), but a
    template::multirow isn't really well suited to data of this shape.  
    It'll setup a set of variables, $var_stub_1 - $var_stub_8 and $var_stub_i1
    - $var_stub_i8, each contining the portal_ids that belong in that region.

    @creation-date 12/11/2000
    @param element_id_list An [array get]'d array, keys are regions, \
	     values are lists of element_ids.
    @param var_stub A name upon which to graft the bits that will be \
	     passed to the template. 
} {
    array set elements $element_list
	 
    foreach idx [list 1 2 3 4 5 6 7 8 9 i1 i2 i3 i4 i5 i6 i7 i8 i9 ] {
	 upvar [join [list $var_stub "_" $idx] ""] group
	 if { [info exists elements($idx) ] } {
	     set group $elements($idx)
	 } else {
	     set group {}
	 }
    }
}



} # namespace
