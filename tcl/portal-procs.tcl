# tcl/portal-procs.tcl

ad_library {
    Portal.
    
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date Sept 2001
    @cvs-id $Id$
}

namespace eval portal {

# helper procs for datasources
ad_proc -public get_datasource_name { ds_id } {
    Get the ds name from the id or the null string if not found.

    @param ds_id
    @return ds_name
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date Spetember 2001
} { 
    if {[db_0or1row get_ds_name_from_id "select name from portal_datasources where datasource_id = :ds_id"]} {
	return $name
    } else {
	return ""
    }
}

ad_proc -public get_datasource_id { ds_name } {
    Get the ds is from the name or the null string if not found.

    @param ds_name
    @return ds_id
    @creation-date Spetember 2001
} { 
    if {[db_0or1row get_ds_id_from_name "select datasource_id from portal_datasources where name = :ds_name"]} {
	return $datasource_id
    } else {
	return ""
    }
}

ad_proc -public make_datasource_available {portal_id ds_id} {
    Make the datasource available to the given portal.  

    @param portal_id
    @param ds_id
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 10/30/2001
} {
#    ad_require_permission $portal_id portal_admin_portal

    set new_p_ds_id [db_nextval acs_object_id_seq]

    db_dml insert_into_portal_datasource_avail_map "
    insert into portal_datasource_avail_map
    (portal_datasource_id, portal_id, datasource_id)
    values
    (:new_p_ds_id, :portal_id, :ds_id)"
}

ad_proc -public make_datasource_unavailable {portal_id ds_id} {
    Make the datasource unavailable to the given portal.  

    @param portal_id
    @param ds_id
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 10/30/2001
} {

#    ad_require_permission $portal_id portal_admin_portal

    db_dml delete_from_portal_datasource_avail_map "
    delete from portal_datasource_avail_map
    where portal_id =  :portal_id
          and datasource_id = :ds_id"
}

ad_proc -public toggle_datasource_availability {portal_id ds_id} {
    Toggle

    @param portal_id
    @param ds_id
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 10/30/2001
} {
    ad_require_permission $portal_id portal_admin_portal
    
    if { [db_0or1row datasource_avail_check "select 1  
    from portal_datasource_avail_map
    where portal_id = :portal_id and
    datasource_id = :ds_id"] } {
	[make_datasource_unavailable $portal_id $ds_id]
    } else {
	[make_datasource_available $portal_id $ds_id]
    }
}


    ad_proc -public create {user_id {layout_name "'Simple 2-Column'"}} {
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
	
    # insert the portal and grant user-level permission on it.    
    return [ db_exec_plsql insert_portal {
	begin
	    
	:1 := portal.new ( 
	layout_id => :layout_id
	);
	    
	acs_permission.grant_permission ( 
	object_id => :1,
	grantee_id => :user_id,
	privilege => 'portal_read_portal' 
	);
	
	acs_permission.grant_permission ( 
	object_id => :1,
	grantee_id => :user_id,
	privilege => 'portal_edit_portal'
	);
	end;
    }]
}

ad_proc -public delete { portal_id } {
    Destroy the portal

    @param portal_id
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {
    # remove permissions (this sucks - ben)
    db_dml remove_permissions "delete from acs_permissions where object_id= :portal_id"

    return [ db_exec_plsql delete_portal {
	begin
	portal.delete (portal_id => :portal_id);
	end;
    }]
}

ad_proc -public get_name { portal_id } {
    Get the name of this portal

    @param portal_id
    @return the name of the portal or null
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {
    # check permissions
    ad_require_permission $portal_id portal_read_portal

    if {[portal::exists_p $portal_id]} {
	db_1row get_name \
		"select name from portals where portal_id = :portal_id" 
    } else {
	set name ""
    }
    
    return $name
}

ad_proc -public update_name { portal_id new_name } {
    Update the name of this
 portal

    @param portal_id
    @param new_name
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {

    # check permissions
    ad_require_permission $portal_id portal_read_portal
    ad_require_permission $portal_id portal_edit_portal

    db_dml update_name "update portals set name = :new_name where portal_id = :portal_id"

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

ad_proc -public remove_element {element_id} {
    Remove an element from a portal
} {
    db_transaction {

	# Remove map, this PE's parameters will cascade
	db_dml remove_map "delete from portal_element_map where element_id= :element_id"
    }
}

ad_proc -public add_element_to_region { portal_id ds_name region } {
    Add an element to a portal in a region, given a datasource name

    @return the id of the new element
    @param portal_id 
    @param ds_name
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {

    set ds_id [get_datasource_id $ds_name]

    # set up a unique prett_name for the PE
    if { [db_0or1row pe_prety_name_unique_check "select 1  
    from portal_element_map
    where portal_id = :portal_id and
    pretty_name = :ds_name"] } {
	# XXX sophisticated regsub here
	set pretty_name [append ds_name "+1"]
    } else {
	set pretty_name $ds_name
    }

    # Bind the DS to the PE by inserting into the map and
    # copying the default params. 
    set new_element_id [db_nextval acs_object_id_seq]

    db_dml insert_pe_into_map "
    insert into portal_element_map
    (element_id, 
    name, 
    pretty_name,
    portal_id, 
    datasource_id, 
    theme_id, 
    region, 
    sort_key)
    values
    (:new_element_id, 
    :ds_name,
    :pretty_name,
    :portal_id, 
    :ds_id, 
    nvl((select max(theme_id) from portal_element_themes), 1), 
    :region,  
    nvl((select max(sort_key) + 1 from portal_element_map where region = :region), 1))" 
	
    db_dml insert_into_params "
    insert into portal_element_parameters
    (parameter_id, element_id, config_required_p, configured_p, key, value)
    select acs_object_id_seq.nextval, 
    :new_element_id, 
    config_required_p, 
    configured_p, 
    key, 
    value
    from portal_datasource_def_params where datasource_id= :ds_id"
    # The caller must now set the necessary params or else!
    return $new_element_id
}

ad_proc -public swap_element {portal_id element_id sort_key region direction} {
    Moves a PE in the direction indicated by swapping it with its neighbor

    @param portal_id 
    @param element_id 
    @param sort_key of the element to be moved
    @param region
    @param direction either up or down
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {

    if { $direction == "up" } {
	# get the sort_key and id of the element above
	db_1row move_element_get_prev_sort_key {
	    select sort_key as other_sort_key, 
	           element_id as other_element_id
	    from (select sort_key,
	                 element_id 
	          from portal_element_map
	          where portal_id = :portal_id 
	                and region = :region 
	                and sort_key < :sort_key 
	                order by sort_key desc
	          ) where rownum = 1
	}
    } elseif { $direction == "down"} {
	# get the sort_key and id of the element below
	db_1row move_element_get_next_sort_key {
	    select sort_key as other_sort_key,
	           element_id as other_element_id
	    from (select sort_key, 
	                 element_id
	          from portal_element_map
	          where portal_id = :portal_id 
	                and region = :region 
	                and sort_key > :sort_key 
	                order by sort_key
	          ) where rownum = 1
	}
    } else {
	ad_return_complaint 1 \ 
	"portal::swap_element: Bad direction: $direction"
	ad_script_abort
    }

    # swap the sort keys
    db_transaction {

	# because of the uniqueness constraint on sort_keys we
	# need to set a dummy key, then do the swap

	db_1row swap_get_dummy \
		"select acs_object_id_seq.nextval as dummy_sort_key from dual"

	# Set the element to be moved to the dummy key
	db_dml swap_sort_keys_1 \
		"update portal_element_map set sort_key = :dummy_sort_key 
	        where element_id = :element_id"
	
	# Set the other_element's sort_key to the right value
	db_dml swap_sort_keys_2 \
		"update portal_element_map set sort_key = :sort_key 
	         where element_id = :other_element_id"

	# Set the element to be moved's sort_key to the right value
	db_dml swap_sort_keys_3 \
		"update portal_element_map set sort_key = :other_sort_key 
	         where element_id = :element_id"
    } on_error {
	ad_return_complaint 1 "portal::move_element: transaction failed"
    }
}    


ad_proc -public move_elements {portal_id element_id_list target_region} {
    Moves a PE in the direction indicated by swapping it with its neighbor

    @param portal_id 
    @param element_id_list
    @param target_region
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {
    
    ad_require_permission $portal_id portal_read_portal
    ad_require_permission $portal_id portal_edit_portal
    
    # AKS: XXX locked areas
    foreach element_id $element_id_list {

	# just move each element to the bottom of the region, don't 
	# fuss with keeping sort_keys in order at this point
	db_dml move_elements \
		"update portal_element_map 
	set region = :target_region, 
	    sort_key = (select nvl(
	                          (select max(sort_key) + 1
	                           from portal_element_map 
	                           where portal_id = :portal_id 
	                           and region = :target_region), 
                                 1) 
	               from dual)
	where element_id = :element_id"

    }    
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


ad_proc -public configure { portal_id } {
    Return a portal configuration page. All form targets point to
    file_stub-2.
    
    @return A portal configuration page
    
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {
    ad_require_permission $portal_id portal_read_portal
    ad_require_permission $portal_id portal_edit_portal
    
    # Set up some template vars
    set master_template [ad_parameter master_template]

    # Set up the form target
    set target_stub [lindex [ns_conn urlv] [expr [ns_conn urlc] - 1]]

    # AKS XXX layout change
    # get the layouts
    set layout_count 0
    template::multirow create layouts layout_id name \
	    description filename resource_dir checked
    
    db_foreach get_layouts "
    select 
    layout_id, 
    name, 
    description, 
    filename, 
    resource_dir, 
    ' ' as checked
    from portal_layouts 
    order by name "  {
	set resource_dir "$resource_dir"
	template::multirow append layouts $layout_id $name \
		$description $filename $resource_dir $checked
	incr layout_count
    }
    
    # get the portal.
    db_1row select_portal "
	select
	p.portal_id,
	p.name,
	t.filename as template,
	t.layout_id
	from portals p, portal_layouts t
	where p.layout_id = t.layout_id and p.portal_id = :portal_id
    " -column_array portal

    # fake some elements so that the <list> in the template has
    # something to do.
    foreach region [ portal::get_regions $portal(layout_id) ] {
	# pass the portal_id along here instead of the element_id.
	lappend fake_element_ids($region) $portal_id
    }
    
    set element_list [array get fake_element_ids]
    set element_src "[portal::www_path]/place-element"
    

    # the <include> sources /www/place-element.tcl
    set template "	
    <master src=\"@master_template@\">
    <form action=\"@target_stub@-2\">
    <b>Change Your Portal's Name:</b>
    <P>
    <input type=\"text\" name=\"new_name\" value=\"@portal.name@\">
    <input type=hidden name=portal_id value=@portal_id@>
    <input type=submit name=\"op\" value=\"Rename\">
    </form>
    
    <P>


    <b>Configure The Portal's Elements:</b>
    <form method=get action=\"@target_stub@-2\">
    <input type=hidden name=portal_id value=@portal_id@>
    <%= [export_form_vars portal_id] %>
    <include src=\"@portal.template@\" element_list=\"@element_list@\" element_src=\"@element_src@\">
    <center>
    <input type=submit name=\"op@region@\" value=\"Remove All Checked\"> 
    </center>
    </form>
    
    <b>Undo Your Changes:</b>
    <form method=get action=\"@target_stub@-2\">
    <input type=hidden name=portal_id value=@portal_id@>
    <%= [export_form_vars portal_id ] %>
    <input type=submit name=op value=\"Revert To Default\">
    </form>
"

#
#	 <form action=\"update_layout\">
#	 <if @layout_count@ gt 1>
#	 <p>
#	 Change Layout:
#	 <br>
#	 
#	 <table border=0>
#	 <tr>
#	 
#	 <multiple name=\"layouts\">
#	 <td>
#	 <table border=0>
#	 <tr>
#	 <td>
#	 <input type=radio name=layout_id value=\"@layouts.layout_id@\" 
#	 <if @layout_id@ eq @layouts.layout_id@>checked</if>>
#	 <b>@layouts.name@</b><br>
#	 <table border=0 align=center>
#	 <tr><td>
#	 <include src=\"@layouts.resource_dir@/example\" 
#	 resource_dir=\"@layouts.resource_dir@\">
#	 </td></tr>
#	 </table>
#	 <font size=-1>
#	 @layouts.description@
#	 </font>
#	 </td>
#	 </tr>
#	 </table>
#	 </td>
#	 </multiple>
#	 
#	 </tr>
#	 </table>
#	 </p>
#	 </if>
#	 
#	 <center>
#	 <input type=submit value=\"Update Layout\">
#	 </center>
#	 </form>

	
	# This hack is to work around the acs-templating system
	set __adp_stub "[get_server_root][www_path]/."
	set {master_template} \"master\" 

	set code [template::adp_compile -string $template]
	set output [template::adp_eval code]
	
	return $output
    }

ad_proc -public configure_dispatch { portal_id query } {
    Dispatches the configuration operation. 
    We get the target region number from the op.
    
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
nope} {
    ad_require_permission $portal_id portal_read_portal
    ad_require_permission $portal_id portal_edit_portal

    # remove the portal_id from the query
    set query [string tolower $query]
    regsub {[&]*portal_id=\d+} $query "" query
    
    # get then remove the op including an optional target_region
    regexp {[&]*op([\d])?=([\w\+]+)} $query whole_op target_region op
    regsub {[&]*op[\d]?=[\w\+]+} $query "" query

    # replace the "+"'s with spaces
    regsub -all {\+} $op " " op
    set op [string tolower $op]

    switch $op {
	"rename" { 
	    regsub {[&]*new_name=} $query "" new_name
	    portal::update_name $portal_id $new_name
	}
	"swap" {  
	    regexp {[&]*element_id=(\d+)} $query "" element_id
	    regexp {[&]*sort_key=(\d+)} $query "" sort_key
	    regexp {[&]*region=(\d+)} $query "" region
	    regexp {[&]*direction=(\w+)} $query "" direction
	    portal::swap_element \
		    $portal_id $element_id $sort_key $region $direction
	}
	"move all checked here" {

	    set element_id_list [list]

	    while {[regexp {[&]*element_ids=(\d+)} $query "" element_id]} {
		lappend element_id_list $element_id
		regsub {[&]*element_ids=\d+} $query ""  query
	    }

	    if {! [empty_string_p $element_id_list] } {
		portal::move_elements \
			$portal_id $element_id_list $target_region 
	    } else {
		ns_returnredirect \
			"portal-config.tcl?[export_url_vars portal_id]"
	    }
	} 
	"add a new element here" {
	    db_dml unhide_element \
		    "update portal_element_map 
	            set state = 'full' 
	            where element_id = :element_id"
	}
	"remove all checked" {

	    set element_id_list [list]

	    while {[regexp {[&]*element_ids=(\d+)} $query "" element_id]} {
		lappend element_id_list $element_id
		regsub {[&]*element_ids=\d+} $query ""  query
	    }

	    if {! [empty_string_p $element_id_list] } {
		foreach element_id $element_id_list {
		    db_dml hide_element \
			    "update portal_element_map 
		             set state =  'hidden' 
		             where element_id = :element_id"
		}
	    } else {
		ns_returnredirect \
			"portal-config.tcl?[export_url_vars portal_id]"
	    }
	}
	"revert to default" {
	    ad_return_complaint 1 "Not implimented yet:  op  = $op, target_region = $target_region"
	}
	"update_layout" {
	    ad_return_complaint 1 "Not implimented yet: op  = $op, target_region = $target_region"
	}
	default {
	    ns_log Warning \
		    "portal::config_dispatch: op = $op, and that's not right!"
	    ad_return_complaint 1  "portal::config_dispatch: Bad Op! \n whole_op = $whole_op, tr = $target_region, op $op"
	}
    }
}


ad_proc -public render { portal_id } {
    Get a portal by id. If it's not found, say so.

    @return Fully rendered portal as an html string
    @param portal_id

    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
} {
    
    ad_require_permission $portal_id portal_read_portal
    set edit_p [ad_permission_p $portal_id portal_edit_portal]
    set master_template [ad_parameter master_template]
    set css_path [ad_parameter css_path]
   

   # put the element IDs into buckets by region...
    foreach entry_list [get_elements $portal_id] {
	array set entry $entry_list
	lappend element_ids($entry(region)) $entry(element_id)
    }    
        
    set element_list [array get element_ids]

    if { [empty_string_p $element_list] } {

	# The portal has no elements, show anyway (they can configure)
	set template "<master src=\"@master_template@\">
	<property name=\"title\">@portal.name@</property>"
    } else {
	set element_src "[www_path]/render-element"

	set template "<master src=\"@master_template@\">
	<property name=\"title\">@portal.name@</property>
	<include src=\"@portal.layout_template@\" element_list=\"@element_list@\" element_src=\"@element_src@\">"
    }
	
	db_0or1row select_portal_and_layout "
	select
	p.portal_id,
	p.name,
	t.filename as layout_template,
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
    set __adp_stub "[get_server_root][www_path]/."
    set {master_template} \"master\" 

    set code [template::adp_compile -string $template]
    set output [template::adp_eval code]

    return $output

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
    # it might be good to (optionally) cache this,
    # since it can be an expensive step.
    set element(content) [ eval { 
	portal_render_datasource_$datasource(data_type) [array get datasource] $element(config)
    } ]
	
	# this is sometimes used when interacting with templates in the
	# filesystem.
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

ad_proc -private get_element_ids_by_ds {portal_id ds_name} {
    Get element IDs for a particular portal and a datasource name
} {
    set ds_id [get_datasource_id $ds_name]

    return [db_list select_element_ids "select element_id from portal_element_map 
    where portal_id= :portal_id and datasource_id= :ds_id"]
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

ad_proc -private fake_regions { layout_id } {
    Fake a display of regions using simple html tables.

    @param layout_id
    @return a list containing the name of each region, in no particular order.
    @creation-date 9/28/2001
    @author Arjun Sanyal (arjun@openforce.net)
} {
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


ad_proc -public layout_elements { 
    element_list 
    {var_stub "element_ids"} 
} {
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

# Work around for template::util::url_to_file 
ad_proc -public  www_path {} {
    Stuff
} {
     return "/packages/new-portal/www" 
}
ad_proc -public  dummy {} {
    There's really something wrong with ad_proc
} { 
     return 1
}


}
