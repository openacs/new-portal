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
	ns_log warning "datasource_call: op= $op ds_id = $ds_id list args = [llength list_args]"
	return [acs_sc_call portal_datasource $op $list_args [get_datasource_name $ds_id]]
    }

    ad_proc -public list_datasources {
	{portal_id ""}
    } {
	Lists the datasources available to a portal or in general
    } {
	if {[empty_string_p $portal_id]} {
	    # List all applets
	    return [db_list select_all_datasources \
		    "select impl_name from acs_sc_impls, 
	    acs_sc_bindings, 
	    acs_sc_contracts
	    where
	    acs_sc_impls.impl_id = acs_sc_bindings.impl_id and
	    acs_sc_contracts.contract_id= acs_sc_bindings.contract_id and 
	    acs_sc_contracts.contract_name='portal_datasource'"]
	} else {
	    # List from the DB
	    return [db_list select_datasources \
		    "select datasource_id 
	    from portal_datasource_avail_map
	    where portal_id = :portal_id"]
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

    # Work around for template::util::url_to_file 
    ad_proc -private  www_path {} {
	Returns the path of the www dir of the portal package
    } { return "/packages/new-portal/www"  }

    # Work around for template::util::url_to_file 
    ad_proc -private  mount_point {} {
	Returns the mount point - XXX fixme
    } { return "/portal"  }
    
    #
    # Main portal procs
    #

    ad_proc -public create {user_id {layout_name "'Simple 2-Column'"}} {
	Create a new portal for the passed in user id. 
	
	@return The newly created portal's id
	@param user_id
	@param layout_name optional
    } {

	# XXX todo permissions should be portal_create_portal	
	# The defualt layout is simple 2 column
	db_1row create_select \
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
    } {
	# XXX todo permissions should be portal_delete_portal
	# XXX remove permissions (this sucks - ben)
	db_dml delete_delete \
		"delete from acs_permissions where object_id= :portal_id"
	
	return [ db_exec_plsql delete_portal {
	    begin
	    portal.delete (portal_id => :portal_id);
	    end;
	}]
    }
	
    ad_proc -public get_name { portal_id } {
	Get the name of this portal
	
	@param portal_id
	@return the name of the portal or null string
    } {
	ad_require_permission $portal_id portal_read_portal
	
	if {[portal::exists_p $portal_id]} {
	    db_1row get_name_select \
		    "select name from portals where portal_id = :portal_id" 
	} else {
	    set name ""
	}
	return $name
    }
    

    ad_proc -public render { portal_id {theme_id ""} } {
	Get a portal by id. If it's not found, say so.
	
	@return Fully rendered portal as an html string
	@param portal_id
    } {

	ad_require_permission $portal_id portal_read_portal

	set edit_p [ad_permission_p $portal_id portal_edit_portal]
	set master_template [ad_parameter master_template]
	set css_path [ad_parameter css_path]
	
	# get the portal and layout
	db_0or1row render_portal_select "
	select portal_id, portals.name, theme_id, filename as layout_template
	from portals, portal_layouts
	where portals.layout_id = portal_layouts.layout_id 
	and portal_id = :portal_id" -column_array portal

	# theme_id override
	if { $theme_id != "" } {
	    set portal(theme_id) $theme_id
	}

	# get the elements of the portal and put them in a list
	db_foreach render_element_select "
	select element_id, region, sort_key
	from portal_element_map
	where portal_id = :portal_id
	and state != 'hidden'
	order by region, sort_key" -column_array entry {
	    # put the element IDs into buckets by region...
	    lappend element_ids($entry(region)) $entry(element_id)
	} if_no_rows {
	    set element_ids {}
	}

	set element_list [array get element_ids]

	# set up the template, it includes the layout template,
	# which includes the elements
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
	    theme_id=@portal.theme_id@>"
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
	belong in that region.

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

    ad_proc -private update_name { portal_id new_name } {
	Update the name of this portal
	
	@param portal_id
	@param new_name
    } {
	
	ad_require_permission $portal_id portal_read_portal
	ad_require_permission $portal_id portal_edit_portal
	
	db_dml update_name_update \
	"update portals 
	set name = :new_name 
	where portal_id = :portal_id"
    }
    

    ad_proc -public configure { portal_id return_url } {
	Return a portal configuration page. 
	All form targets point to file_stub-2.
    
	@param portal_id
	@return_url
	@return A portal configuration page	
    } {
	ad_require_permission $portal_id portal_read_portal
	ad_require_permission $portal_id portal_edit_portal
	
	# Set up some template vars, including the form target
	set master_template [ad_parameter master_template]
	set target_stub [lindex [ns_conn urlv] [expr [ns_conn urlc] - 1]]
	set action_string [append target_stub "-2"]
	set name [get_name $portal_id]
	
	# XXX todo layout change
	# get the layouts
	#	 set layout_count 0
	#	 template::multirow create layouts layout_id name \
		#		 description filename resource_dir checked
	#    
	#	 db_foreach configure_layout_select "
	#	 select 
	#	 layout_id, 
	#	 name, 
	#	 description, 
	#	 filename, 
	#	 resource_dir, 
	#	 ' ' as checked
	#	 from portal_layouts 
	#	 order by name "  {
	    #	     set resource_dir "$resource_dir"
	    #	     template::multirow append layouts $layout_id $name \
		    #		     $description $filename $resource_dir $checked
	    #	     incr layout_count
	    #	 }
	    #	     
	    # get the portal.

	    
	    # get the themes, template::multirow is not working here
	    set theme_count 0
	    set theme_data "<br>"

	    # get the current theme
	    db_1row configure_portal_curr_theme_select "
	    select theme_id as cur_theme_id
	    from portals
	    where portal_id = :portal_id
	    " 
	    db_foreach configure_theme_select "
	    select 
	    pet.theme_id, 
	    pet.name, 
	    pet.description 
	    from portal_element_themes pet
	    order by name "  {
		if { $cur_theme_id == $theme_id } {
		    append theme_data "<label><input type=radio name=theme_id 
		    value=$theme_id checked><b>$name - $description</label></b><br>"
		} else {
		    append theme_data "<label><input type=radio name=theme_id 
		    value=$theme_id>$name - $description</label><br>"
		}   
	    }

	    append theme_data "<input type=submit name=op value=\"Update Theme\">"
	    
	    # get the portal.	    
	    db_1row configure_portal_select "
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
	    set layout_id [get_layout_id $portal_id]

	    db_foreach configure_get_regions "
	    select region
	    from portal_supported_regions
	    where layout_id = :layout_id"  {
		lappend fake_element_ids($region) $portal_id
	    }

	    set element_list [array get fake_element_ids]
	    set element_src "[portal::www_path]/place-element"

	    # the <include> sources /www/place-element.tcl
	    set template "	
	    <master src=\"@master_template@\">
	    <b>Return to <a href=@return_url@>@name@</a></b>
	    <p>
	    <form action=@action_string@>
	    <b>Change Your Portal's Name:</b>
	    <P>
	    <input type=\"text\" name=\"new_name\" value=\"@portal.name@\">
	    <input type=hidden name=portal_id value=@portal_id@>
	    <input type=submit name=\"op\" value=\"Rename\">
	    </form>
	    
	    <P>
	    
	    <b>Configure The Portal's Elements:</b>
	    <include src=\"@portal.template@\" element_list=\"@element_list@\" 
	    element_src=\"@element_src@\" action_string=@action_string@>
	    
	    
	    <form method=post action=@action_string@>
	    <input type=hidden name=portal_id value=@portal_id@>
	    <b>Change Theme:</b>
	    @theme_data@
	    </form>


	    <b>Undo Your Changes:</b>
	    <form method=get action=\"@target_stub@-2\">
	    <input type=hidden name=portal_id value=@portal_id@>
	    <%= [export_form_vars portal_id ] %>
	    <input type=submit name=op value=\"Revert To Default\">
	    "
	
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
    
    ad_proc -public configure_dispatch { portal_id form } {
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
		    db_dml configure_dispatch_show_update \
			"update portal_element_map 
		         set region = :region, 
		         sort_key = (select nvl((select max(sort_key) + 1
		                                 from portal_element_map 
		                                 where portal_id = :portal_id 
		                                 and region = :region), 
		                                 1) 
		                     from dual)
		                     where element_id = :element_id"

		    db_dml configure_dispatch_unhide_update \
			    "update portal_element_map 
		    set state = 'full' 
		    where element_id = :element_id"
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
			db_dml configure_dispatch_hide_update \
			    "update portal_element_map 
		             set state =  'hidden' 
		             where element_id = :element_id"
		    }
		} 
	    }
	    "Update Theme" {
		set theme_id [ns_set get $form theme_id] 
		
		db_dml configure_dispatch_update_theme \
			"update portals 
		set theme_id = :theme_id
		where portal_id = :portal_id"
	    }
	    "revert to default" {
		ad_return_complaint 1 \
			"portal::config_dispatch: Not implimented op  = $op"
	    }
	    "update_layout" {
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
    # Element Procs
    #

    ad_proc -public add_element { portal_id ds_name } {
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
	
	db_foreach add_element_get_regions "
	select region
	from portal_supported_regions
	where layout_id = :layout_id"  {
	    lappend region_list $region
	}

	foreach region $region_list {
	    db_1row add_element_region_count \
	    "select count(*) as count
	    from portal_element_map 
	    where portal_id = :portal_id 
	    and region = :region"
	    
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


    ad_proc -public remove_element {element_id} {
	Remove an element from a portal
    } {
	db_transaction {
	    # Remove map, this PE's parameters will cascade
	    db_dml remove_element_delete \
	    "delete from portal_element_map 
	    where element_id= :element_id"
	}
    }

    ad_proc -private add_element_to_region { portal_id ds_name region } {
	Add an element to a portal in a region, given a datasource name
	
	@return the id of the new element
	@param portal_id 
	@param ds_name
    } {

	set ds_id [get_datasource_id $ds_name]
	
	# XXX - set up a unique prett_name for the PE
	if { [db_0or1row add_element_to_region_select "select 1  
	from portal_element_map
	where portal_id = :portal_id and
	pretty_name = :ds_name"] } {
	    set pretty_name [append ds_name "+1"]
	} else {
	    set pretty_name $ds_name
	}
	
	# Bind the DS to the PE by inserting into the map
	# and copying over the default params. 
	set new_element_id [db_nextval acs_object_id_seq]

	db_dml add_element_to_region_map_insert "
	insert into portal_element_map
	(element_id, 
	name,
	pretty_name,
	portal_id,
	datasource_id,
	region, 
	sort_key)
	values
	(:new_element_id, 
	:ds_name,
	:pretty_name,
	:portal_id, 
	:ds_id, 
	:region,  
	nvl((select max(sort_key) + 1 
	     from portal_element_map 
	     where region = :region), 1))" 
	
	db_dml add_element_to_region_param_insert "
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

    ad_proc -private swap_element {portal_id element_id sort_key region dir} {
	Moves a PE in the direction indicated by swapping it with its neighbor
	
	@param portal_id 
	@param element_id 
	@param sort_key of the element to be moved
	@param region
	@param dir either up or down
    } {
	
	if { $dir == "up" } {
	    # get the sort_key and id of the element above
	    db_1row swap_element_get_prev_sort_key {
		select sort_key as other_sort_key, 
	               element_id as other_element_id
	        from (select sort_key, element_id 
		      from portal_element_map
	              where portal_id = :portal_id 
	              and region = :region 
	              and sort_key < :sort_key 
	               order by sort_key desc
		) where rownum = 1
	    }
	} elseif { $dir == "down"} {
	    # get the sort_key and id of the element below
	    db_1row swap_element_get_next_sort_key {
		select sort_key as other_sort_key,
		       element_id as other_element_id
		from (select sort_key, element_id
		      from portal_element_map
		      where portal_id = :portal_id 
	              and region = :region 
	              and sort_key > :sort_key 
	              order by sort_key
	  	) where rownum = 1
	    }
	} else {
	    ad_return_complaint 1 \ 
	    "portal::swap_element: Bad direction: $dir"
	}

	db_transaction {
	    # because of the uniqueness constraint on sort_keys we
	    # need to set a dummy key, then do the swap
	    db_1row swap_get_dummy {
		select acs_object_id_seq.nextval as dummy_sort_key
		from dual
	    }

	    # Set the element to be moved to the dummy key
	    db_dml swap_sort_keys_1 {
		update portal_element_map set sort_key = :dummy_sort_key 
		where element_id = :element_id 
	    }
	
	    # Set the other_element's sort_key to the correct value
	    db_dml swap_sort_keys_2 {
		update portal_element_map set sort_key = :sort_key 
		where element_id = :other_element_id
	    }

	    # Set the element to be moved's sort_key to the right value
	    db_dml swap_sort_keys_3 {
		update portal_element_map set sort_key = :other_sort_key 
		where element_id = :element_id
	    }
	} on_error {
	    ad_return_complaint 1 "portal::move_element: transaction failed"
	}
    }


    ad_proc -private move_element {portal_id element_id region direction} {
	Moves a PE in the direction indicated by swapping it with its neighbor

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
	db_dml move_element_update \
		"update portal_element_map 
	set region = :target_region, 
	sort_key = (select nvl((select max(sort_key) + 1
	from portal_element_map 
	where portal_id = :portal_id 
	and region = :target_region), 
	1) 
	from dual)
	where element_id = :element_id"
    }
    
    ad_proc -private set_element_param { element_id key value } {
	Set an element param
	
	@return 1 on success
	@param element_id
	@param key
	@param value
    } {
	
	db_dml set_element_param_upadate "
	update portal_element_parameters set value = :value
	where element_id = :element_id and 
	key = :key"
	
	return 1
	
    }
    
    ad_proc -private get_element_param { element_id key } {
	Get an element param. Returns the value of the param.

	@return the value of the param
	@param element_id
	@param key
    } {
	
	if { [db_0or1row get_element_param_select "
	select value
	from portal_element_parameters 
	where element_id = :element_id and 
	key = :key"] } {
	    return $value
	} else {
	    ad_return_complaint \
		    1 "get_element_param: Invalid element_id and/or key given."
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

	set query "
	select pem.element_id,
	pem.datasource_id,
	pem.state,
	pet.filename as filename, 
	pet.resource_dir as resource_dir
	from portal_element_map pem, portal_element_themes pet
	where pet.theme_id = :theme_id
	and pem.element_id = :element_id "

	# get the element data and theme
	db_1row evaluate_element_element_select $query -column_array element 

	# get the element's params
	db_foreach evaluate_element_params_select "
	select key, value
	from portal_element_parameters
	where
	element_id = :element_id" {
	    lappend config($key) $value
	} if_no_rows {
	    # this element has no config, set up some defaults
	    set config(shaded_p) "f"
	    set config(user_editable_p) "f"
	}
	
	# do the callback for the ::show proc
	# evaulate the datasource.
	set element(content) \
		[datasource_call \
		$element(datasource_id) "Show" [list [array get config] ]] 

	# pass some ds info, and the shaded_p param to the element
	set element(name) \
		[datasource_call \
		$element(datasource_id) "GetPrettyName" [list]] 
	set element(link) [datasource_call $element(datasource_id) "Link" [list]]
	set element(shaded_p) $config(shaded_p) 
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
	
	if { [db_0or1row configure_element_select "select portal_id 
	from portal_element_map 
	where element_id = :element_id"] } {
	    # passed in element_id is good, do they have perms?
	    ad_require_permission $portal_id portal_read_portal
	    ad_require_permission $portal_id portal_edit_portal
	} else {
	    ad_returnredirect $return_url
	}
	
	switch $op {
	    "edit" { 
		configure_element_params $element_id $op $return_url
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
		db_dml configure_element_hide_update \
			"update portal_element_map 
		set state =  'hidden' 
		where element_id = :element_id"
		ad_returnredirect $return_url
	    }
	}

    }



    ad_proc -public configure_element_params { element_id op return_url } {
	Get the html from from the element's edit proc

	@return_url
	@return An element configuration page	
    } {
	# Do perms by looking up the portal_id for this element
	if {[db_0or1row configure_e_p_portal_select "
	select portal_id 
	from portal_element_map 
	where element_id = :element_id"]} {
	    ad_require_permission $portal_id portal_read_portal
	    ad_require_permission $portal_id portal_edit_portal
	} else {
	    # no portal_id for this element
	    ad_return_complaint 1 "portal:: configure_element_params\n
	    This element_id has no portal associated with it!"
	}

	# Get the edit proc name - to be replaced with acs-sc soon - XXX
	db_1row evaluate_element_datasource_select "
	select edit_content
	from portal_element_map pem, portal_datasources pd
	where pem.element_id = :element_id
	and pem.datasource_id = pd.datasource_id"

	if { $edit_content == ""  } { 
	    ad_return_complaint 1 "This element cannot be edited yet. Sorry"
	}

	# Get the chunk of html from the PE
	set html [$edit_content $element_id]

	# Set up some template vars, including the form target
	set master_template [ad_parameter master_template]
	set target_stub [lindex [ns_conn urlv] [expr [ns_conn urlc] - 1]]
	set action_string [append target_stub "-2"]

	# the <include> sources /www/place-element.tcl
	set template "	
	<master src=\"@master_template@\">
	<b><a href=@return_url@>Return to your portal</a></b>
	<p>
	<form action=@action_string@>
	<b>Edit this element's parameters:</b>
	<P>
	@html@ 
	<P>
	</form>
	"
	# This hack is to work around the acs-templating system
	# ad_return_complaint 1 "foo"

	set __adp_stub "[get_server_root][www_path]/."
	set {master_template} \"master\" 
	
	set code [template::adp_compile -string $template]
	set output [template::adp_eval code]
	
	return $output
    }

    
    #
    # Datasource helper procs
    #
    
    ad_proc -private get_datasource_name { ds_id } {
	Get the ds name from the id or the null string if not found.
	
	@param ds_id
	@return ds_name
    } { 
	if {[db_0or1row get_datasource_name_select \
	"select name from portal_datasources 
	where datasource_id = :ds_id"]} {
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
	if {[db_0or1row get_datasource_id_select \
	"select datasource_id from portal_datasources 
	where name = :ds_name"]} {
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
	db_dml make_datasource_available_insert "
	insert into portal_datasource_avail_map
	(portal_datasource_id, portal_id, datasource_id)
	values
	(:new_p_ds_id, :portal_id, :ds_id)"
    }
    
    ad_proc -private make_datasource_unavailable {portal_id ds_id} {
	Make the datasource unavailable to the given portal.  
	
	@param portal_id
	@param ds_id
    } {
	
	#    ad_require_permission $portal_id portal_admin_portal
	db_dml make_datasource_unavailable_delete "
	delete from portal_datasource_avail_map
	where portal_id =  :portal_id
	and datasource_id = :ds_id"
    }
    
    ad_proc -private toggle_datasource_availability {portal_id ds_id} {
	Toggle
	
	@param portal_id
	@param ds_id
    } {
	ad_require_permission $portal_id portal_admin_portal
	
	if { [db_0or1row toggle_datasource_availability_select "select 1  
	from portal_datasource_avail_map
	where portal_id = :portal_id and
	datasource_id = :ds_id"] } {
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
	
	return [db_list select_element_ids \
		"select element_id from portal_element_map
	where portal_id= :portal_id 
	and datasource_id= :ds_id"]
    }
    
    ad_proc -private get_layout_id { portal_id } {
	Get the layout_id of a layout template for a portal.
	
	@param portal_id The portal_id.
	@return A layout_id.
    } {
	db_1row get_layout_id_select {
	    select layout_id from portals where portal_id = :portal_id
	}
	
	return $layout_id
    }    
    
    ad_proc -private exists_p { portal_id } {
	Check if a portal by that id exists.
	
	@return 1 on success, 0 on failure
	@param a portal_id
    } {
	if { [db_0or1row exists_p_select "select 1 from portals where portal_id = :portal_id"]} { 
	    return 1
	} else { 
	    return 0 
	}
    }
    
        
}
