# tcl/portal-procs.tcl

ad_library {
    Portal. 
    
    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date Sept 2001
    @cvs-id $Id$
}

namespace eval portal {

    #
    # acs-service-contract procs
    #

    ad_proc -public datasource_call {
	ds_id
	op
	list_args
    } {
	Call a particular ds op
    } {
	ns_log notice "portal::datasource_call op= $op ds_id = $ds_id"
	return [acs_sc_call \
                portal_datasource $op $list_args [get_datasource_name $ds_id]]
    }

    ad_proc -public list_datasources {
	{portal_id ""}
    } {
	Lists the datasources available to a portal or in general
    } {
	if {[empty_string_p $portal_id]} {
	    # List all applets
	    return [db_list select_all_datasources {}]
	} else {
	    # List from the DB
	    return [db_list select_datasources {}]
	}
    }

    ad_proc -public datasource_dispatch {
	portal_id
	op
	list_args
    } {
	Dispatch an operation to every datasource
    } {
	foreach datasource [list_datasources $portal_id] {
	    # Callback on datasource
	    datasource_call $datasource $op $list_args
	}
    }


    #
    # Special Hacks
    #

    # The mangement is not responsible for the results of multi-mounting

    ad_proc -private  package_key {} {
	Returns the package_key
    } { 
        return "new-portal"
    }

    # Work around for template::util::url_to_file
    ad_proc -private  www_path {} {
	Returns the path of the www dir of the portal package. We
        need this for stupid template tricks.
    } { 
        return "/packages/[package_key]/www"
    }

    ad_proc -public  mount_point {} {
	Returns the mount point of the portal package. 
        Sometimes we need to know this for like <include>ing 
        templates from tcl
    } { 
        return [site_nodes::get_info -return param \
                -param url \
                -package_key [package_key]]
    }

    ad_proc -public  automount_point {} {
        packages such as dotlrn can automount the portal here
    } { return "/portal"  }
    
    #
    # Main portal procs
    #

    ad_proc -public create {
	{-name "Untitled"} 
	{-template_id ""} 
	{-portal_template_p "f"} 
	{-layout_name "'Simple 2-Column'"}
	{-context_id ""} 
	user_id 
    } {
	Create a new portal for the passed in user id. 
	
	@return The newly created portal's id
	@param user_id
	@param layout_name optional
    } {
	# XXX todo permissions should be portal_create_portal	
	db_1row layout_id_select {}
	return [ db_exec_plsql create_new_portal_and_perms {}]
    }
    
    ad_proc -public delete {
        portal_id 
    } {
	Destroy the portal
	@param portal_id
    } {
	# XXX todo permissions should be portal_delete_portal
	# XXX remove permissions (this sucks - ben)
	db_dml delete_perms {}
	
	return [db_exec_plsql delete_portal {}]
    }
	
    ad_proc -public get_name { 
        portal_id
    } {
	Get the name of this portal
	
	@param portal_id
	@return the name of the portal or null string
    } {
	ad_require_permission $portal_id portal_read_portal
	
	if {[portal::exists_p $portal_id]} {
	    return [db_1row get_name_select {}]
	} else {
	    return ""
	}
    }
    
    ad_proc -public render { 
        portal_id
        {theme_id ""} 
    } {
	Get a portal by id. If it's not found, say so.
	
	@return Fully rendered portal as an html string
	@param portal_id
    } {

	ad_require_permission $portal_id portal_read_portal

	set edit_p [ad_permission_p $portal_id portal_edit_portal]
	set master_template [ad_parameter master_template]
	set css_path [ad_parameter css_path]
	
	# get the portal and layout
	db_1row portal_select {} -column_array portal

	# theme_id override
	if { $theme_id != "" } { set portal(theme_id) $theme_id }

	db_foreach element_select {} -column_array entry {
	    # put the element IDs into buckets by region...
	    lappend element_ids($entry(region)) $entry(element_id)
	} if_no_rows {
	    set element_ids {}
	}

	set element_list [array get element_ids]

	# set up the template, it includes the layout template,
	# which in turn includes the theme, then elements
	if { [empty_string_p $element_list] } {
	    # The portal has no elements, show anyway (they can configure)
	    set template "<master src=\"@master_template@\">
	    <property name=\"title\">@portal.name@</property>"
	} else {
	    set element_src "[www_path]/render-element"
	    set template "<master src=\"@master_template@\">
	    <property name=\"title\">@portal.name@</property>
	    <include src=\"@portal.layout_template@\" 
	    element_list=\"@element_list@\"
	    element_src=\"@element_src@\"
	    theme_id=@portal.theme_id@
	    portal_id=@portal.portal_id@>"
	}
	
	# Necessary hack to work around the acs-templating system
	set __adp_stub "[get_server_root][www_path]/."
	set {master_template} \"master\" 
	
	# Compile and evaluate the template
	set code [template::adp_compile -string $template]
	set output [template::adp_eval code]
	
	return $output
    }

    ad_proc -private layout_elements { 
	element_list 
	{var_stub "element_ids"} 
    } {
	Split a list up into a bunch of variables for inserting into a
	layout template.  This seems pretty kludgy (probably because it is), 
	but a template::multirow isn't really well suited to data of this
	shape. It'll setup a set of variables, $var_stub_1 - $var_stub_8
	and $var_stub_i1- $var_stub_i8, each contining the portal_ids that
	belong in that region. - Ian Baker

	AKS: XXX improve me
	
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

    #
    # Portal configuration procs
    #

    ad_proc -private update_name { 
        portal_id new_name
    } {
	Update the name of this portal
	
	@param portal_id
	@param new_name
    } {
	
	ad_require_permission $portal_id portal_read_portal
	ad_require_permission $portal_id portal_edit_portal
	
	db_dml update {}
    }
    

    ad_proc -public configure { 
        {-template_p "f"}
        portal_id
        return_url
    } {
	Return a portal or portal template configuration page. 
	All form targets point to file_stub-2.
    
	@param portal_id
	@return_url
	@return A portal configuration page	
    } {

	if { $template_p == "f" } {
            ad_require_permission $portal_id portal_read_portal
            ad_require_permission $portal_id portal_edit_portal
        } else {
            ad_require_permission $portal_id portal_admin_portal
        }

	
	# Set up some template vars, including the form target
	set master_template [ad_parameter master_template]
	set target_stub [lindex [ns_conn urlv] [expr [ns_conn urlc] - 1]]
	set action_string [append target_stub "-2"]
	set name [get_name $portal_id]

        # get the themes, template::multirow is not working here
        set theme_count 0
        set theme_data "<br>"
        
        db_1row current_theme_select {}

        db_foreach all_theme_select {} {
            if { $cur_theme_id == $theme_id } {
                append theme_data "<label><input type=radio name=theme_id 
                value=$theme_id checked><b>$name - $description</label></b>
                <br>"
            } else {
                append theme_data "<label><input type=radio name=theme_id 
                value=$theme_id>$name - $description</label><br>"
            }   
        }
        
        append theme_data "<input type=submit name=op value=\"Change Theme\">"
	    
        # get the portal.	    
        db_1row portal_select {} -column_array portal

        # fake some elements for the <list> in the template 
        set layout_id [get_layout_id $portal_id]

        db_foreach get_regions {}  {
            lappend fake_element_ids($region) $portal_id
        }

        set element_list [array get fake_element_ids]

        if { $template_p == "f" } {
            set element_src "[portal::www_path]/place-element"
        }  else {
            set element_src "[portal::www_path]/template-place-element"
        }
        
        set template "	
        <master src=\"@master_template@\">
        <b>Configuring @portal.name@</b>
        <p>
        <a href=@return_url@>Go back</a>
        <P>
        <form method=post action=@action_string@>
        <input type=hidden name=portal_id value=@portal_id@>
        <input type=hidden name=return_url value=@return_url@>
        <b>Change Theme:</b>
        @theme_data@
        </form>
        <P>
        <b>Configure The Portal's Elements:</b>
        <include src=\"@portal.template@\" element_list=\"@element_list@\" 
        action_string=@action_string@ portal_id=@portal_id@ 
        return_url=\"@return_url@\" element_src=\"@element_src@\">
        "
	# This hack is to work around the acs-templating system
	set __adp_stub "[get_server_root][www_path]/."
	set {master_template} \"master\" 
	
	set code [template::adp_compile -string $template]
	set output [template::adp_eval code]
	
	return $output
    }
    
    ad_proc -public configure_dispatch { 
        {-template_p "f"}
        portal_id
        form
    } {
	Dispatches the configuration operation. 
	We get the target region number from the op.
    
	@param portal_id
	@param formdata an ns_set with all the formdata
    } { 
	
	ad_require_permission $portal_id portal_read_portal
	ad_require_permission $portal_id portal_edit_portal
	
	set op [ns_set get $form op]

	switch $op {
	    "Rename" { 
		portal::update_name $portal_id [ns_set get $form new_name]
	    }
	    "swap" {  
		portal::swap_element $portal_id \
			[ns_set get $form element_id] \
			[ns_set get $form sort_key] \
			[ns_set get $form region] \
			[ns_set get $form direction]
	    }
	    "move" {
		portal::move_element $portal_id \
			[ns_set get $form element_id] \
			[ns_set get $form region] \
			[ns_set get $form direction]
	    }
	    "Show Here" {
		set region [ns_set get $form region]
		set element_id [ns_set get $form element_id]
		
		db_transaction {
		    # The new element's sk will be the last in the region
		    db_dml show_here_update_sk {} 
		    db_dml show_here_update_state {}
		}		
	    }
	    "hide" {
		set element_id_list [list]
		
		# iterate through the set, destructive!
		while { [expr [ns_set find $form "element_id"] + 1 ]  } {
		    lappend element_id_list [ns_set get $form "element_id"]
		    ns_set delkey $form "element_id"
		}
		
		if {! [empty_string_p $element_id_list] } {
		    foreach element_id $element_id_list {
			db_dml hide_update {}
		    }
		} 
	    }
	    "Change Theme" {
		set theme_id [ns_set get $form theme_id] 
		
		db_dml update_theme {}
	    }
	    "toggle_pinned" {
		set element_id [ns_set get $form element_id]

		if {[db_string toggle_pinned_select {}] == "full"} {
		    
                    db_dml toggle_pinned_update_pin {}

                    # "pinned" implies not user hideable, shadable
		    set_element_param $element_id "hideable_p" "f"
		    set_element_param $element_id "shadeable_p" "f"
                    
		} else {
		    db_dml toggle_pinned_update_unpin {}
		}
	    }
	    "toggle_hideable" {
		set element_id [ns_set get $form element_id]
                toggle_element_param -element_id $element_id -key "hideable_p"
	    }
	    "toggle_shadeable" {
		set element_id [ns_set get $form element_id]
                toggle_element_param -element_id $element_id -key "shadeable_p"
            }
	    "update_layout" {
		ns_log Error \
			"portal::config_dispatch: Bad op = $op!"
		ad_return_complaint 1 \
			"portal::config_dispatch: Not implimented op  = $op"
	    }
	    default {
		ns_log Error \
			"portal::config_dispatch: Bad op = $op!"
		ad_return_complaint 1 \
			"portal::config_dispatch: Bad Op! \n op $op"
	    }
	}
    }


    #
    # portal template procs - util and configuration
    #
    ad_proc -private template_p { 
        portal_id
    } {
	Check if a portal is a portal template and not a user poral
    } {
        return [db_0or1row select {}]
    }

    ad_proc -private get_portal_template_id { 
        portal_id
    } {
	Returns this portal's template_id or the null string if it
        doesn't have a portal template
    } {
	if { [db_0or1row select {}] } { 
	    return $template_id
	} else { 
	    return ""
	}
    }

    ad_proc -public template_configure {
        portal_id 
        return_url
    } {
        Just a wrapper for the configure proc
    
	@param portal_id
	@return A portal configuration page	
    } {
	if { ! [template_p $portal_id] } {
            ns_log error "portal::template_configure called with portal_id 
            $portal_id!"
	    ad_return_complaint 1 "There is an error in our code. 
            Please inform your system administrator of the following error:
            portal::template_configure called with portal_id $portal_id"
	}
        
        portal::configure -template_p "t" $portal_id $return_url 
    }

    ad_proc -public template_configure_dispatch { 
        portal_id
        form
    } {
        Just a wrapper for the configure_dispatch proc
        
	@param portal_id
	@param formdata an ns_set with all the formdata
    } { 
        configure_dispatch -template_p "t" $portal_id $form 
    }
    
    #
    # Element Procs
    #

    ad_proc -public add_element { 
        portal_id
        ds_name
    } {
	Add an element to a portal given a datasource name. Used for procs
	that have no knowledge of regions
	
	@return the id of the new element
	@param portal_id 
	@param ds_name
    } {
	# Balance the portal by adding the new element to the region
	# with the fewest number of elements, the first region w/ 0 elts,
	# or, if all else fails, the first region
	set min_num 99999
	set min_region 0
	set layout_id [get_layout_id $portal_id]
	
	db_foreach get_regions {} {
	    lappend region_list $region
	}

	foreach region $region_list {
	    db_1row region_count {}
	    
	    if { $count == 0 } {
		set min_region $region
		break
	    }
	    
	    if { $min_num > $count } {
		set min_num $count
		set min_region $region
	    } 
	}
	
	if { $min_region == 0 } { set min_region 1 }
	return [add_element_to_region $portal_id $ds_name $min_region]
    }


    ad_proc -public remove_element {
        element_id
    } {
	Remove an element from a portal
    } {
        db_dml delete {}
    }

    ad_proc -private add_element_to_region { 
        portal_id
        ds_name
        region
    } {
	Add an element to a portal in a region, given a datasource name
	
	@return the id of the new element
	@param portal_id 
	@param ds_name
    } {

	set ds_id [get_datasource_id $ds_name]

	# First, check if this portal has a portal template and
	# that that template has an element of this DS in it. If 
	# so, copy stuff. If not, just insert normally. 

	if { [db_0or1row check_new {}] == 1 } {

            db_transaction {
                set new_element_id [db_nextval acs_object_id_seq]
                db_dml template_insert {}
                db_dml template_params_insert {}
            }

	} else {
	    # no template, or the template dosen't have this DS,
            # or I'm a template!
            
            db_transaction {
                set new_element_id [db_nextval acs_object_id_seq]
                db_dml insert {}
                db_dml params_insert {}
            }
	}

	# The caller must now set the necessary params or else!
	return $new_element_id
    }

    ad_proc -private swap_element {
        portal_id
        element_id
        sort_key
        region
        dir
    } {
	Moves a PE in the up or down by swapping its sk with its neighbor's
	
	@param portal_id 
	@param element_id 
	@param sort_key of the element to be moved
	@param region
	@param dir either up or down
    } {

	ad_require_permission $portal_id portal_read_portal
	ad_require_permission $portal_id portal_edit_portal
	
	if { $dir == "up" } {
	    # get the sort_key and id of the element above
	    if {[db_0or1row get_prev_sort_key {}] == 0} {
                return
            }
	} elseif { $dir == "down"} {
	    # get the sort_key and id of the element below
	    if {[db_0or1row get_next_sort_key {}] == 0} {
                return
            }
	} else {
	    ad_return_complaint 1 \ 
	    "portal::swap_element: Bad direction: $dir"
	}

	db_transaction {
	    # because of the uniqueness constraint on sort_keys we
	    # need to set a dummy key, then do the swap. 
            set dummy_sort_key [db_nextval portal_element_map_sk_seq]

	    # Set the element to be moved to the dummy key
	    db_dml swap_sort_keys_1 {}
	
	    # Set the other_element's sort_key to the correct value
	    db_dml swap_sort_keys_2 {}

	    # Set the element to be moved's sort_key to the right value
	    db_dml swap_sort_keys_3 {}
        } on_error {
	    ad_return_complaint 1 "portal::swap_element: transaction failed"
	}
    }

    ad_proc -private move_element {
        portal_id
        element_id
        region
        direction
    } {
	Moves a PE to a neighboring region

	@param portal_id 
	@param element_id
	@param region the PEs current region
	@param direction up or down
    } {
    
	ad_require_permission $portal_id portal_read_portal
	ad_require_permission $portal_id portal_edit_portal
	
	if { $direction == "right" } {
	    set target_region [expr $region + 1]
	} elseif { $direction == "left" } {
	    set target_region [expr $region - 1]
	} else {
	    ad_return_complaint 1 "portal::move_element Bad direction!"
	}
	
	# just move the element to the bottom of the region
	db_dml update {} 
    }
    
    ad_proc -private set_element_param { 
        element_id
        key
        value
    } {
	Set an element param named key to value

	@param element_id
	@param key
	@param value
    } {	
	db_dml update {}
	return 1
    }

    ad_proc -private toggle_element_param { 
        {-element_id:required}
        {-key:required}
    } {
        toggles a boolean (t or f)  element_param
	
	@param element_id
	@param key
    } {
        if { [get_element_param $element_id $key] == "t" } {
            set_element_param $element_id $key "f"
        } else {
            set_element_param $element_id $key "t"
        }
    }
    
    ad_proc -private get_element_param_list {
	{-element_id:required}
	{-key:required}
    } {
	Get the list of parameter values for a particular element

	@author ben@openforce
    } {
	return [db_list select {}]
    }
	
    ad_proc -private add_element_param_value {
	{-element_id:required}
	{-key:required}
	{-value:required}
    } {
	This adds a value for a param (instead of resetting a single value)
	
	@author ben@openforce
    } {
	db_dml insert {}
    }

    ad_proc -private remove_element_param_value {
	{-element_id:required}
	{-key:required}
	{-value:required}
    } {
	removes a value for a param
    } {
	db_dml delete {}
    }

    ad_proc -private remove_all_element_param_values {
	{-element_id:required}
	{-key:required}
    } {
	removes a value for a param
    } {
	db_dml delete {}
    }

    ad_proc -private get_element_param { element_id key } {
	Get an element param. Returns the value of the param.

	@return the value of the param
	@param element_id
	@param key
    } {
	
	if { [db_0or1row select {}] } {
	    return $value
	} else {
	    ad_return_complaint \
		    1 "get_element_param: Invalid element_id ($element_id) and/or key ($key) given."
	    ad_script_abort
	}
    }

    ad_proc -private evaluate_element { element_id theme_id } {
	Combine the datasource, template, etc.  Return a chunk of HTML.
	
	@param element_id
	@param theme_id
	@return A string containing the fully-rendered content for $element_id.
	@param element_id 
    } {

	# get the element data and theme
	db_1row element_select {} -column_array element 

	# get the element's params
	db_foreach params_select {} {
	    lappend config($key) $value
	} if_no_rows {
	    # this element has no config, set up some defaults
	    set config(shaded_p) "f"
	    set config(shadeable_p) "f"
	    set config(hideable_p) "f"
	    set config(user_editable_p) "f"
	}
	
	# do the callback for the ::show proc
	# evaulate the datasource.
	if { [catch {	set element(content) \
		[datasource_call \
		$element(datasource_id) "Show" [list [array get config] ]] } \
		errmsg ] } {
	    ns_log error "*** portal::render_element show callback Error! ***\n\n $errmsg\n\n"	
            ad_return_complaint 1 "*** portal::render_element show callback Error! *** <P> $errmsg\n\n"
	}

	set element(name) \
		[datasource_call \
		$element(datasource_id) "GetPrettyName" [list]] 

	set element(link) \
                [datasource_call $element(datasource_id) "Link" [list]]

	# done with callbacks, now set config params
	set element(shadeable_p) $config(shadeable_p) 
	set element(shaded_p) $config(shaded_p) 
	set element(hideable_p) $config(hideable_p) 
	set element(user_editable_p) $config(user_editable_p)

	# apply the path hack to the filename and the resourcedir
	set element(filename) "[www_path]/$element(filename)"
	set element(resource_dir) "[mount_point]/$element(resource_dir)"

	return [array get element]
    }
    

    ad_proc -public configure_element { element_id op return_url } {
	Dispatch on the element_id and op requested

	@param element_id
	@param op
	@param return_url
    } {
	
	if { [db_0or1row select {}] } {
	    # passed in element_id is good, do they have perms?
	    ad_require_permission $portal_id portal_read_portal
	    ad_require_permission $portal_id portal_edit_portal
	} else {
	    ad_returnredirect $return_url
	}
	
	switch $op {
	    "edit" { 		
		# Get the edit html by callback
		# Notice that the "edit" proc takes only the element_id
		set html_string [datasource_call $datasource_id "Edit" \
			[list $element_id]]		

		if { $html_string == ""  } { 
		    ns_log Error "portal::configure_element op = edit, but
		    portlet's edit proc returned null string"
		    
		    ad_returnredirect $return_url
		}
		
		# Set up some template vars, including the form target
		set master_template [ad_parameter master_template]
		set target_stub \
			[lindex [ns_conn urlv] [expr [ns_conn urlc] - 1]]
		set action_string [append target_stub "-2"]

		# the <include> sources /www/place-element.tcl
		set template "	
		<master src=\"@master_template@\">
		<b><a href=@return_url@>Return to your portal</a></b>
		<p>
		<form action=@action_string@>
		<b>Edit this element's parameters:</b>
		<P>
		@html_string@ 
		<P>
		</form>
		"
		set __adp_stub "[get_server_root][www_path]/."
		set {master_template} \"master\" 
		
		set code [template::adp_compile -string $template]
		set output [template::adp_eval code]
		
		return $output
		
	    }
	    "shade" {  
		set shaded_p [get_element_param $element_id "shaded_p"]
		
		if { $shaded_p == "f" } {
		    set_element_param $element_id "shaded_p" "t"
		} else {
		    set_element_param $element_id "shaded_p" "f"
		}
		ad_returnredirect $return_url
	    }
	    "hide" {
		db_dml hide_update {}
		ad_returnredirect $return_url
	    }
	}
    }
    
    #
    # Datasource helper procs
    #
    
    ad_proc -private get_datasource_name { ds_id } {
	Get the ds name from the id or the null string if not found.
	
	@param ds_id
	@return ds_name
    } { 
	if {[db_0or1row select {}]} {
	    return $name
	} else {
	    return ""
	}
    }
    
    ad_proc -private get_datasource_id { ds_name } {
	Get the ds id from the name or the null string if not found.

	@param ds_name
	@return ds_id
    } { 
	if {[db_0or1row get_datasource_id_select {}]} {
	    return $datasource_id
	} else {
	    return ""
	}
    }
    
    ad_proc -private make_datasource_available {portal_id ds_id} {
	Make the datasource available to the given portal.  
	
	@param portal_id
	@param ds_id
    } {
	# XXX todo permissions on availabliliy procs
	# ad_require_permission $portal_id portal_admin_portal
	set new_p_ds_id [db_nextval acs_object_id_seq]
	db_dml insert {} 
    }
    
    ad_proc -private make_datasource_unavailable {portal_id ds_id} {
	Make the datasource unavailable to the given portal.  
	
	@param portal_id
	@param ds_id
    } {
	#    ad_require_permission $portal_id portal_admin_portal
	db_dml delete {}
    }
    
    ad_proc -private toggle_datasource_availability {portal_id ds_id} {
	Toggle
	
	@param portal_id
	@param ds_id
    } {
	ad_require_permission $portal_id portal_admin_portal
	
	if { [db_0or1row select {}] } {
	    [make_datasource_unavailable $portal_id $ds_id]
	} else {
	    [make_datasource_available $portal_id $ds_id]
	}
    }

    #
    # Misc procs
    #

    ad_proc -private get_element_ids_by_ds {portal_id ds_name} {
	Get element IDs for a particular portal and a datasource name
    } {
	set ds_id [get_datasource_id $ds_name]
	return [db_list select {}]
    }
    
    ad_proc -private get_layout_id { portal_id } {
	Get the layout_id of a layout template for a portal.
	
	@param portal_id The portal_id.
	@return A layout_id.
    } {
	db_1row select {}
	return $layout_id
    }    
    
    ad_proc -private exists_p { portal_id } {
	Check if a portal by that id exists.
	
	@return 1 on success, 0 on failure
	@param a portal_id
    } {
	if { [db_0or1row select {} ]} { 
	    return 1
	} else { 
	    return 0 
	}
    }
    
        
}
