#
#  Copyright (C) 2001, 2002 OpenForce, Inc.
#
#  This file is part of dotLRN.
#
#  dotLRN is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.
#

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


    ad_proc -private log_time {str} {
        global old_time
        set time "[expr [expr [clock clicks] + 1000000000] / 1000]"

        if {![info exists old_time]} {
            set diff "--"
        } else {
            set diff [expr "$time - $old_time"]
        }
        
        set old_time $time

        ns_log Notice "DEBUG-TIME: $time ($diff) - $str"
    }

    ad_proc -public datasource_call {
        {-datasource_name ""}
        ds_id
        op
        list_args
    } {
        Call a particular ds op
    } {
        if {[empty_string_p $datasource_name]} {
            set datasource_name [get_datasource_name $ds_id]
        }
        
        ns_log notice "portal::datasource_call op=$op ds_id=$ds_id ds_name=$datasource_name"

        log_time "aks2A before ds call"        
        set result [acs_sc_call portal_datasource $op $list_args $datasource_name]
        log_time "aks2A after ds call"        
        return $result
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

    ad_proc -public get_package_id {} {
        returns the package ID
    } {
        return [apm_package_id_from_key [package_key]]
    }

    # Work around for template::util::url_to_file
    ad_proc -private  www_path {} {
        Returns the path of the www dir of the portal package. We
        need this for stupid template tricks.
    } { 
        return "/packages/[package_key]/www"
    }

    ad_proc -private mount_point_no_cache {} {
        Returns the mount point of the portal package. 
        Sometimes we need to know this for like <include>ing 
        templates from tcl
    } { 
        return [site_nodes::get_info -return param \
                -param url \
                -package_key [package_key]]
    }

    ad_proc -public mount_point {} {
        caches the mount point
    } {
        return [util_memoize portal::mount_point_no_cache]
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
        {-layout_name ""}
        {-theme_name ""}
        {-default_page_name ""}
        {-context_id ""} 
        {-csv_list ""}
        user_id 
    } {
        Create a new portal for the passed in user id. 

        @return The newly created portal's id
        @param user_id
        @param layout_name optional
    } {
        # if we have a cvs list in the form "page_name1, layout1;
        # page_name2, layout2...", we get the required first page_name
        # and first page layout from it, overriding any other params

        set page_name_list [list "Page 1"]
        set layout_name_list [list "Simple 2-Column"]

        if {![empty_string_p $csv_list]} {
            set page_name_and_layout_list [split [string trimright $csv_list ";"] ";"]
            set page_name_list [list]
            set layout_name_list [list]

            # seperate name and layout
            foreach item $page_name_and_layout_list {
                lappend page_name_list [lindex [split $item ","] 0]
                lappend layout_name_list [lindex [split $item ","] 1]
            }
        }

        set default_page_name [lindex $page_name_list 0]
        set layout_name [lindex $layout_name_list 0]

        # get the default layout_id - simple2
        set layout_id [get_layout_id]
        if {![empty_string_p $layout_name]} {
            set layout_id [get_layout_id -layout_name $layout_name]
        }

        # get the default theme name from param, if no theme given
        if {[empty_string_p $theme_name]} {
            set theme_name [ad_parameter -package_id [get_package_id] default_theme_name]
        } 

        set theme_id [get_theme_id_from_name -theme_name $theme_name]

        db_transaction {
            # create the portal and the first page

            set portal_id [db_exec_plsql create_new_portal_and_perms {}]

            if {![empty_string_p $csv_list]} {
                # if there are more pages in the csv_list, create them
                for {set i 1} {$i < [expr [llength $page_name_list]]} {incr i} {
                    portal::page_create -portal_id $portal_id \
                        -pretty_name [lindex $page_name_list $i] \
                        -layout_name [lindex $layout_name_list $i]
                }
            }

        }

        return $portal_id
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
        {-page_id ""}
        {-page_num ""}
        {-hide_links_p "f"} 
        {-render_style "individual"}
        portal_id
        {theme_id ""} 
    } {
        Get a portal by id. If it's not found, say so.
        FIXME: right now the render style is totally ignored (ben)

        @return Fully rendered portal as an html string
        @param portal_id
    } {
        ad_require_permission $portal_id portal_read_portal
        set edit_p [ad_permission_p $portal_id portal_edit_portal]

        set master_template [ad_parameter master_template]

        # if no page_num set, render page 0
        if {[empty_string_p $page_id] && [empty_string_p $page_num]} {
            set page_id [get_page_id -portal_id $portal_id -sort_key 0]
        } elseif {![empty_string_p $page_num]} {
            set page_id [get_page_id -portal_id $portal_id -sort_key $page_num]
        } 

        # get the portal and layout
        db_1row portal_select {} -column_array portal

        # theme_id override  
        if { $theme_id != "" } { set portal(theme_id) $theme_id }

        log_time "entering element_select"
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
            set element_src "[www_path]/render_styles/${render_style}/render-element"
            set template "<master src=\"@master_template@\">
            <property name=\"title\">@portal.name@</property>
            <include src=\"@portal.layout_filename@\" 
            element_list=\"@element_list@\"
            element_src=\"@element_src@\"
            theme_id=@portal.theme_id@
            portal_id=@portal.portal_id@
            edit_p=@edit_p@
            hide_links_p=@hide_links_p@
            page_id=@page_id@ 
            layout_id=@portal.layout_id@>"
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
        {-page_id ""}
        {-template_p "f"}
        portal_id
        return_url
    } {
        Return a portal or portal template configuration page. 
        All form targets point to file_stub-2.

        XXX REFACTOR ME

        @param page_num the page of the portal to config, def 0
        @param template_p is this portal a template?
        @param portal_id
        @return_url
        @return A portal configuration page        
    } {
        set edit_p [permission::permission_p -object_id $portal_id -privilege portal_edit_portal]

        if {!$edit_p} {
            ad_require_permission $portal_id portal_admin_portal
            set edit_p 1
        }

        # Set up some template vars, including the form target
        set master_template [ad_parameter master_template]
        set action_string [generate_action_string]

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

        # set up the page creation stuff
        set new_page_num [expr [page_count -portal_id $portal_id] + 1]

        set page_data \
                "<br>
        <input type=text name=pretty_name value=\"Page $new_page_num\">
        <input type=submit name=op value=\"Add Page\">"


        # XXXX page support 
        if { $template_p == "f" } {
            set element_src "[portal::www_path]/place-element"
        }  else {
            set element_src "[portal::www_path]/template-place-element"
        }

        set portal_name [get_name $portal_id]

        set template "        
        <master src=\"@master_template@\">
        <p>
        <big><a href=@return_url@>Go back</a></big>
        <P>
        <form method=post action=@action_string@>
        <input type=hidden name=portal_id value=@portal_id@>
        <input type=hidden name=return_url value=@return_url@>
        <big>Change Theme:</big> 
        @theme_data@
        </form>
        <P>"

        set list_of_page_ids [list $page_id]

        if {[empty_string_p $page_id]} {
            set list_of_page_ids [list_pages_tcl_list -portal_id $portal_id]
        }

        foreach page_id $list_of_page_ids {

            # get the portal.            
            db_1row portal_select {} -column_array portal

            # get the numer of elements in this region
            set element_count [db_string portal_element_count_select "
            select count(*) 
            from portal_element_map
            where page_id = :page_id"]


            # fake some elements for the <list> in the template 
            set layout_id [get_layout_id -page_id $page_id $portal_id]

            db_foreach get_regions {}  {
                lappend fake_element_ids($region) $portal_id
            }

            set element_list [array get fake_element_ids]

            if {$element_count == 0} {
                append template "
                <P> <b>$portal(page_name)</b> has no Elements"
            } else {
                append template "
                <P> <b>$portal(page_name)</b> Page
                <include src=\"$portal(template)\" element_list=\"$element_list\" 
                action_string=@action_string@ portal_id=@portal_id@
                return_url=\"@return_url@\" element_src=\"@element_src@\"
                hide_links_p=f page_id=$page_id layout_id=$layout_id edit_p=@edit_p@>
                "
            }

            # clear out the region array
            array unset fake_element_ids
        }


        append template "
        <form method=post action=@action_string@>
        <input type=hidden name=portal_id value=@portal_id@>
        <input type=hidden name=return_url value=@return_url@>
        <b>Add a new page:</b> 
        @page_data@
        </form>
        <P>"


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
                set page_id [ns_set get $form page_id]

                db_transaction {
                    # The new element's sk will be the last in the region
                    db_dml show_here_update_sk {} 
                    db_dml show_here_update_state {}
                }                
            }
            "move_to_page" {
                set page_id [ns_set get $form page_id]
                set element_id [ns_set get $form element_id]
                set curr_reg [db_string move_to_page_curr_select {}] 
                set target_reg_num [db_string move_to_page_target_select {}] 

                if {$curr_reg > $target_reg_num} {
                    # the new page dosent have this region, set to max region
                    set region $target_reg_num
                } else {
                    set region $curr_reg
                }

                db_dml move_to_page_update {} 
            }
            "Move to page" {
                set page_id [ns_set get $form page_id]
                set element_id [ns_set get $form element_id]
                set curr_reg [db_string move_to_page_curr_select {}] 
                set target_reg_num [db_string move_to_page_target_select {}] 

                if {$curr_reg > $target_reg_num} {
                    # the new page dosent have this region, set to max region
                    set region $target_reg_num
                } else {
                    set region $curr_reg
                }

                db_dml move_to_page_update {} 
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
            "Add Page" {
                set pretty_name [ns_set get $form pretty_name]
                if {[empty_string_p $pretty_name]} {
                    ad_return_complaint 1 "You must enter a name for the new page."
                }
                page_create -pretty_name $pretty_name -portal_id $portal_id
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
    # Page Procs
    #

    ad_proc -public get_page_id {
        {-portal_id:required}
        {-page_name ""}
        {-sort_key "0"}
    } {
        Gets the id of the page with the given portal_id and sort_key
        if no sort_key is given returns the first page of the portal
        which is always there. 

        @return the id of the page
        @param portal_id 
        @param sort_key - optional, defaults to page 0
    } {
        if {![empty_string_p $page_name]} {
            return [db_string get_page_id_from_name {} -default ""]
        } else {
                return [db_string get_page_id_select {}]
        }
    }

    ad_proc -public page_count {
        {-portal_id:required}
    } {
        1 when there's only one page

        @param portal_id 
        @param page_id 
    } {
        return [db_string page_count_select {}]
    }

    ad_proc -public get_page_pretty_name {
        {-page_id:required}
    } {
        Gets the pn
    } {
        return [db_string get_page_pretty_name_select {}]
    }

    ad_proc -public page_create {
        {-layout_name ""}
        {-pretty_name:required}
        {-portal_id:required}
    } {
        Appends a new blank page for the given portal_id. 

        @return the id of the page
        @param portal_id 
    } {
        # get the layout_id
        if {![empty_string_p $layout_name]} {
            set layout_id [get_layout_id -layout_name $layout_name]
        } else {
            set layout_id [get_layout_id]
        }

        return [db_exec_plsql page_create_insert {}]
    }

    ad_proc -public list_pages_tcl_list {
        {-portal_id:required}
    } {
        Returns a tcl list of the page_ids for the given portal_id

        @return tcl list of the pages
        @param portal_id 
    } {
        set foo [list]

        db_foreach list_pages_tcl_list_select {} {
            lappend foo $page_id
        } 
        return $foo
    }

    ad_proc -public navbar {
        {-portal_id:required}
        {-td_align "left"}
        {-link ""}
        {-pre_html ""}
        {-post_html ""}
        {-link_all 0}
        {-extra_td_html ""}
        {-table_html_args ""}
    } {
        Wraps portal::dimensional to create a dotlrn navbar

        @return the id of the page
        @param portal_id 
        @param link the relative link to set for hrefs
        @param current_page_link f means that there is no link for the current page
    } {
        set ad_dim_struct [list]

        db_foreach list_page_nums_select {} {
            lappend ad_dim_struct [list $page_num $pretty_name [list]]
        } 

        set ad_dim_struct "{ page_num \"Page:\" 0  [list $ad_dim_struct] }"

        return [dimensional -no_header \
                -no_bars \
                -link_all $link_all \
                -td_align $td_align \
                -pre_html $pre_html \
                -post_html $post_html \
                -extra_td_html $extra_td_html \
                -table_html_args $table_html_args \
                $ad_dim_struct \
                $link]
    }

    #
    # Element Procs
    #

    ad_proc -public add_element { 
        {-force_region ""}
        {-page_id ""}
        {-page_num ""}
        {-pretty_name ""}
        portal_id
        ds_name
    } {
        Add an element to a portal given a datasource name. Used for procs
        that have no knowledge of regions

        @return the id of the new element
        @param portal_id 
        @param page_num the number of the portal page to add to, def 0 
        @param ds_name
    } {
        if {[empty_string_p $pretty_name]} {
            set pretty_name $ds_name
        }

        if { [empty_string_p $page_num] && [empty_string_p $page_id] } {
            # neither page_num or page_id given, default to 0
            set page_id [portal::get_page_id -portal_id $portal_id -sort_key 0]
        } 

        # Balance the portal by adding the new element to the region
        # with the fewest number of elements, the first region w/ 0 elts,
        # or, if all else fails, the first region
        set min_num 99999
        set min_region 0

        # get the layout for some page
        set layout_id [get_layout_id -page_id $page_id $portal_id]

        # get the regions in this layout
        db_foreach get_regions {} {
            lappend region_list $region
        }

        if {[empty_string_p $force_region]} {
            # find the "best" region to put it in
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

            if { $min_region == 0 } { 
                set min_region 1
            }
        } else {
            # verify that the region given is in this layout
            set min_region 0

            foreach region $region_list {
                if {$force_region == $region} {
                    set min_region $region
                    break
                }
            }

            if {$min_region == 0} {
                # the region asked for was not in the list
                ns_log error "portal::add_element region $force_region not in layout $layout_id"
                ad_return_complaint 1  "portal::add_element region $force_region not in layout $layout_id"
            }
        }
        return [add_element_to_region \
                    -page_id $page_id \
                    -layout_id $layout_id \
                    -pretty_name $pretty_name \
                    $portal_id $ds_name $min_region]
    }


    ad_proc -public remove_element {
        element_id
    } {
        Remove an element from a portal
    } {
        db_dml delete {}
    }

    ad_proc -private add_element_to_region { 
        {-layout_id:required}
        {-page_id ""}
        {-pretty_name ""}
        portal_id
        ds_name
        region
    } {
        Add an element to a portal in a region, given a datasource name

        @return the id of the new element
        @param portal_id 
        @param ds_name
    } {
        if {[empty_string_p $pretty_name]} {
            set pretty_name $ds_name
        }

        set ds_id [get_datasource_id $ds_name]        

        # First, check if this portal 1) has a portal template and
        # 2) that that template has an element of this DS in it. If 
        # so, copy stuff. If not, just insert normally. 
        if { [db_0or1row get_template_info_select {}] == 1 } {

            db_transaction {
                set new_element_id [db_nextval acs_object_id_seq]
                db_1row get_target_page_id {}
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
        region
        dir
    } {
        Moves a PE in the up or down by swapping its sk with its neighbor's

        @param portal_id 
        @param element_id 
        @param region
        @param dir either up or down
    } {

        ad_require_permission $portal_id portal_read_portal
        ad_require_permission $portal_id portal_edit_portal

        # get this element's sk
        db_1row get_my_sort_key_and_page_id {}

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

        # get this element's page_id
        db_1row get_my_page_id {}

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

    ad_proc -private evaluate_element { 
        {-portal_id:required}
        {-edit_p:required}
        element_id
        theme_id 
    } {
        Combine the datasource, template, etc.  Return a chunk of HTML.

        @return A string containing the fully-rendered content for $element_id.
    } {

        log_time "aks1 portal::evaluate_element START"

        # get the element data and theme
        db_1row element_select {} -column_array element 

        log_time "ben1 portal::evaluate_element after element_select"

        # get the element's params
        db_foreach params_select {} {
            lappend config($key) $value
        } if_no_rows {
            # this element has no config, set up some defaults
            set config(shaded_p) "f"
            set config(shadeable_p) "f"
            set config(hideable_p) "f"
            set config(user_editable_p) "f"
            set config(link_hideable_p) "f"
        }

        if {!$edit_p} {
            set config(shadeable_p) "f"
            set config(hideable_p) "f"
            set config(user_editable_p) "f"
        }

        # HACK FIXME (ben)
        # setting editable to false
        set config(user_editable_p) "f"

        log_time "aks2 portal::evaluate_element about to call Show"

        # do the callback for the ::show proc
        # evaulate the datasource.
        if { [catch { set element(content) \
                        [datasource_call \
                          -datasource_name $element(ds_name) \
                          $element(datasource_id) \
                          "Show" \
                          [list [array get config]]
                        ]\
                    } \
                errmsg \
             ] \
            } {
        
        ns_log error "*** portal::render_element show callback Error! ***\n\n $errmsg\n\n"        
        # ad_return_complaint 1 "*** portal::render_element show callback Error! *** <P> $errmsg\n\n"
        
        set element(content)  " You have found a bug in our code. <P>Please notify the webmaster and include the following text. Thank You.<P> <pre><small>*** portal::render_element show callback Error! ***\n\n $errmsg</small></pre>\n\n" 
        
    }
    
    log_time "aks3 portal::evaluate_element done with call to Show"

    # trim the element's content
    set element(content) [string trim $element(content)]

        # We use the actual pretty name from the DB (ben)
        # FIXME: this is not as good as it should be
        if {$element(ds_name) == $element(pretty_name)} {
            set element(name) \
                    [datasource_call \
                    $element(datasource_id) "GetPrettyName" [list]]
        } else {
            set element(name) $element(pretty_name) 
        }

        set element(link) \
                [datasource_call $element(datasource_id) "Link" [list]]
        
        log_time "ben3 portal::evalute_element not quite END"

        # done with callbacks, now set config params
        set element(shadeable_p) $config(shadeable_p) 
        set element(shaded_p) $config(shaded_p) 
        set element(hideable_p) $config(hideable_p) 
        set element(user_editable_p) $config(user_editable_p)
        set element(link_hideable_p) $config(link_hideable_p)

        # apply the path hack to the filename and the resourcedir
        set element(filename) "[www_path]/$element(filename)"
        # notice no "/" after mount point
        log_time "ben3 portal::evalute_element not quite END v2"
        set element(resource_dir) "[mount_point]$element(resource_dir)"


        log_time "aks3 portal::evaluate_element END"

        return [array get element]
    }


    ad_proc -private evaluate_element_raw { element_id } {
        Just call show on the element

        @param element_id
        @return A string containing the fully-rendered content for $element_id.
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
            set config(link_hideable_p) "f"
        }

        # do the callback for the ::show proc
        # evaulate the datasource.
        if { [catch {        set element(content) \
                [datasource_call \
                $element(datasource_id) "Show" [list [array get config] ]] } \
                errmsg ] } {
            ns_log error "*** portal::render_element show callback Error! ***\n\n $errmsg\n\n"        
            ad_return -error
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
        set element(link_hideable_p) $config(link_hideable_p)

        # THE HACK - BEN OVERRIDES TO RAW
        set element(filename) "themes/raw-theme"

        # apply the path hack to the filename and the resourcedir
        set element(filename) "[www_path]/$element(filename)"
        # notice no "/" after mount point
        # set element(resource_dir) "[mount_point]$element(resource_dir)"

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
                set action_string [generate_action_string]

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
            ns_log error "portal::get_datasource_name error! No datasource
            by that name found!"
            ad_return_complaint 1 "portal::get_datasource_name error! No datasource
            by that name found!"
        }
    }

    ad_proc -private get_datasource_id { ds_name } {
        Get the ds id from the name

        @param ds_name
        @return ds_id
    } { 
        if {[db_0or1row select {}]} {
            return $datasource_id
        } else {
            ns_log error "portal::get_datasource_id error! No datasource
            by that name found!"
            ad_return_complaint 1 "portal::get_datasource_id error! No datasource
            by that name found!"
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

    ad_proc -private generate_action_string {
    } {
        Portal configuration pages need this to set up 
        the target for the generated links. It's just the 
        current location with "-2" appended to the name of the
        page.
    } {
        return "[lindex [ns_conn urlv] [expr [ns_conn urlc] - 1]]-2"
    }

    ad_proc -private get_element_ids_by_ds {portal_id ds_name} {
        Get element IDs for a particular portal and a datasource name
    } {
        set ds_id [get_datasource_id $ds_name]
        return [db_list select {}]
    }

    ad_proc -private get_layout_region_count { 
        {-layout_id:required}
    } {
        return [db_1row select_region_count {}]
    }

    ad_proc -private get_layout_id { 
        {-page_num ""}
        {-page_id ""}
        {-layout_name "Simple 2-Column"}
        {portal_id ""}
    } {
        Get the layout_id of a layout template for a portal page.

        @param page_num the page of the portal to look at, def page 0
        @param portal_id The portal_id.
        @return A layout_id.
    } {
        if { ![empty_string_p $page_num] } {
            db_1row get_layout_id_num_select {}
        } elseif { ![empty_string_p $page_id] } {
            db_1row get_layout_id_page_select {}
        } elseif { ![empty_string_p $layout_name] } {
            db_1row get_layout_id_name_select {}
        } else {
            ad_return_complaint 1 "portal::get_layout_id bad params!"
            ns_log error "portal::get_layout_id bad params!"
        }

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

    ad_proc -public add_element_or_append_id { 
        {-portal_id:required}
        {-page_id ""}
        {-pretty_name ""}
        {-portlet_name:required}
        {-value_id:required}
        {-key "instance_id"}
        {-extra_params ""}
        {-force_region ""}
    } {
        A helper proc for portlet "add_self_to_page" procs.
        Adds the given portlet as an portal element to the given
        page. If the portlet is already in the given portal page,
        it appends the value_id to the element's parameters with the 
        given key. Returns the element_id used.

         @return element_id The new element's id
        @param portal_id The page to add the portlet to
        @param portlet_name The name of the portlet to add
        @param key the key for the value_id (defaults to instance_id)
        @param value_id the value of the key
        @param extra_params a list of extra key/value pairs to insert or append
    } {

        # Find out if this portlet already exists in this page
        set element_id_list [get_element_ids_by_ds $portal_id $portlet_name]

        if {[llength $element_id_list] == 0} {
            db_transaction {

                # Tell portal to add this element to the page
                set element_id [add_element \
                        -pretty_name $pretty_name \
                        -page_id $page_id \
                        -force_region $force_region \
                        $portal_id \
                        $portlet_name ]

                # There is already a value for the param which is overwritten
                set_element_param $element_id $key $value_id

                if {![empty_string_p $extra_params]} {
                    check_key_value_list $extra_params

                    for {set x 0} {$x < [llength $extra_params]} {incr x 2} {
                        set_element_param $element_id \
                                [lindex $extra_params $x] \
                                [lindex $extra_params [expr $x + 1]]
                    }        
                }
            }
        } else {
            db_transaction {
                set element_id [lindex $element_id_list 0]

                # There are existing values which should NOT be overwritten
                add_element_param_value -element_id $element_id \
                        -key $key \
                        -value $value_id

                if {![empty_string_p $extra_params]} {
                    check_key_value_list $extra_params

                    for {set x 0} {$x < [llength $extra_params]} {incr x 2} {
                        add_element_param_value -element_id $element_id \
                                -key [lindex $extra_params $x] \
                                -value [lindex $extra_params [expr $x + 1]]
                    }        
                }
            }
        }

        return $element_id
    }

    ad_proc -public remove_element_or_remove_id { 
        {-portal_id:required} 
        {-portlet_name:required}
        {-value_id:required}
        {-key "instance_id"}
        {-extra_params ""}
    } {
        A helper proc for portlet "remove_self_from_page" procs.
        The inverse of the above proc.

        Removes the given parameters from all the the portlets 
        of this type on the given page. If by removing this param, 
        there are no more params (say instace_id's) of this type,
        that means that the portlet has become empty and can be

        @param portal_id The portal page to act on
        @param portlet_name The name of the portlet to (maybe) remove 
        @param key the key for the value_id (defaults to instance_id)
        @param value_id the value of the key
        @param extra_params a list of extra key/value pairs to remove
    } {
        # get the element IDs (could be more than one!)
        set element_ids [get_element_ids_by_ds $portal_id $portlet_name]

        # step 1: remove all the given param(s) from all of the pe's
        db_transaction {
            foreach element_id $element_ids {

                remove_element_param_value \
                    -element_id $element_id \
                    -key $key \
                    -value $value_id

                if {![empty_string_p $extra_params]} {
                    check_key_value_list $extra_params

                    for {set x 0} {$x < [llength $extra_params]} {incr x 2} {

                        remove_element_param_value -element_id $element_id \
                                -key [lindex $extra_params $x] \
                                -value [lindex $extra_params [expr $x + 1]]
                    }
                }                
            }
        }

        # step 2:  Check if we should really remove the element
        db_transaction {
            foreach element_id $element_ids {
                if {[llength [get_element_param_list \
                        -element_id $element_id \
                        -key $key]] == 0} {
                    remove_element $element_id
                }
            }
        }
    }

    ad_proc -private check_key_value_list { 
        list_to_check
    } {
        rat-simple consistency check for the above 2 procs
    } {              
        if {[expr [llength $list_to_check] % 2] != 0} {
            ns_log error "portal::check_key_value_list bad var list_to_check!"
            ad_return_complaint 1  "portal::check_key_value_list bad var list_to_check!"
        }    
    }

    ad_proc -public show_proc_helper { 
        {-template_src ""}
        {-package_key:required}
        {-config_list:required}
    } {
        hides ugly templating calls for portlet "show" procs
    } {

        if { $template_src == ""} {
            set template_src $package_key
        }

        # some stupid upvar tricks to get them set right
        upvar __ts ts
        set ts $template_src

        upvar __pk pk
        set pk $package_key

        upvar __cflist cflist
        set cflist $config_list

        uplevel 1 {
            set template "<include src=\"$__ts\" cf=\"$__cflist\">"
            set __adp_stub "[get_server_root]/packages/$__pk/www/."
            set code [template::adp_compile -string $template]        
            set output [template::adp_eval code]
            return $output
        }
    }

    ad_proc -public get_theme_id_from_name { 
        {-theme_name:required}
    } {
        self explanatory
    } {
        if { [db_0or1row get_theme_id_from_name_select {} ]} { 
            return $theme_id
        } else { 
            ns_log error "portal::get_theme_id_from_name_select bad theme_id!"
            ad_return_complaint 1 "portal::get_theme_id_from_name_select bad theme_id!"
        }

    }

    ad_proc dimensional {
        {-no_header:boolean}
        {-no_bars:boolean}
        {-link_all 0}
        {-th_bgcolor "#ECECEC"}
        {-td_align "center"}
        {-extra_td_html ""}
        {-table_html_args "border=0 cellspacing=0 cellpadding=3 width=100%"}
        {-pre_html ""}
        {-post_html ""}
        option_list 
        {url {}} 
        {options_set ""} 
        {optionstype url}
    } {
        An enhanced ad_dimensional. see that proc for usage details
    } {
        if {[empty_string_p $option_list]} {
            return
        }

        if {[empty_string_p $options_set]} {
            set options_set [ns_getform]
        }

        if {[empty_string_p $url]} {
            set url [ad_conn url]
        }

        set html "\n<table $table_html_args>\n  <tr>\n"

        if {!$no_header_p} {
            foreach option $option_list { 
                append html "    <th bgcolor=\"$th_bgcolor\">[lindex $option 1]</th>\n"
            }
        }

        append html "  </tr>\n  <tr>\n"

        foreach option $option_list { 
            append html "    <td align=$td_align>"

            if {!$no_bars_p} {
                append html "\["
            }

            # find out what the current option value is.
            # check if a default is set otherwise the first value is used
            set option_key [lindex $option 0]
            set option_val [lindex $option 2]
            if {![empty_string_p $options_set]} {
                set option_val [ns_set get $options_set $option_key]
            }

            set first_p 1
            foreach option_value [lindex $option 3] { 
                set thisoption_name [lindex $option_value 0]
                set thisoption_value [lindex $option_value 1]
                set thisoption_link_p 1
                if {[llength $option_value] > 3} {
                    set thisoption_link_p [lindex $option_value 3]
                }

                if {$first_p} {
                    set first_p 0
                } else {
                    if {!$no_bars_p} {
                        append html " | "
                    } else {
                        append html " &nbsp; "                    
                    }
                } 

                if {([string equal $option_val $thisoption_name] == 1 && !$link_all) || !$thisoption_link_p} {
                    append html "${pre_html}<strong>${thisoption_value}</strong>${post_html}"
                } else {
                    append html "<a href=\"$url?[export_ns_set_vars url $option_key $options_set]&[ns_urlencode $option_key]=[ns_urlencode $thisoption_name]\">${pre_html}${thisoption_value}${post_html}</a>"
                }
            }

            if {!$no_bars_p} {
                append html "\]"
            } 

            append html "$extra_td_html</td>\n"
        }

        append html "  </tr>\n</table>\n"
    }
}
