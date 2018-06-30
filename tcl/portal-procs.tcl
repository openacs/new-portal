#
#  Copyright (C) 2001, 2002 MIT
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

namespace eval portal {}

#
# acs-service-contract procs
#

ad_proc -public portal::datasource_call {
    {-datasource_name ""}
    ds_id
    op
    list_args
} {
    Call a particular ds op
} {
    if {$datasource_name eq ""} {
        set datasource_name [get_datasource_name $ds_id]
    }

    return [acs_sc::invoke -contract portal_datasource -operation $op -call_args $list_args -impl $datasource_name]
}

ad_proc -public portal::list_datasources {
    {portal_id ""}
} {
    Lists the datasources available to a portal or in general
} {
    return [expr {$portal_id eq "" ? \
                      [db_list select_all_datasources {}] : \
                      [db_list select_datasources {}]}]
}

ad_proc -public portal::datasource_dispatch {
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

# The management is not responsible for the results of multi-mounting

ad_proc -private portal::package_key {} {
    Returns the package_key
} {
    return $::portal::package_key
}

ad_proc -public portal::get_package_id {} {
    returns the package ID
} {
    return $::portal::get_package_id
}

# Work around for template::util::url_to_file
ad_proc -private portal::www_path {} {
    Returns the path of the www dir of the portal package. We
    need this for stupid template tricks.
} {
   return $::portal::www_path
}

ad_proc -public portal::mount_point {} {
    caches the mount point
} {
    return $::portal::mount_point
}

ad_proc -public portal::automount_point {} {
    packages such as dotlrn can automount the portal here
} {
    return $::portal::automount_point
}

#
# Main portal procs
#

ad_proc -public portal::create {
    {-name "Untitled"}
    {-template_id ""}
    {-layout_name ""}
    {-theme_name ""}
    {-default_page_name "Page 1"}
    {-default_accesskey "1"}
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

    set page_name_list [list $default_page_name]
    set page_accesskey_list [list $default_accesskey]
    if {$layout_name eq ""} {
        set layout_name_list [list [parameter::get_from_package_key \
            -package_key new-portal \
            -parameter default_layout]]
    } else {
        set layout_name_list [list $layout_name]
    }

    if {$csv_list ne ""} {
        set page_name_and_layout_list [split [string trimright $csv_list ";"] ";"]
        set page_name_list [list]
        set page_accesskey_list [list]
        set layout_name_list [list]

        # separate name and layout
        foreach item $page_name_and_layout_list {
            lassign [split $item ","] page_name layout_name page_accesskey
            lappend page_name_list $page_name
            lappend layout_name_list $layout_name
            lappend page_accesskey_list $page_accesskey
        }
    }

    set default_page_name [lindex $page_name_list 0]
    set default_accesskey [lindex $page_accesskey_list 0]
    set layout_name [lindex $layout_name_list 0]

    # get the default layout_id - simple2
    set layout_id [get_layout_id]
    if {$layout_name ne ""} {
        set layout_id [get_layout_id -layout_name $layout_name]
    }

    # get the default theme name from param, if no theme given
    if {$theme_name eq ""} {
        set theme_name [parameter::get -package_id $::portal::get_package_id -parameter default_theme_name]
    }

    set theme_id [get_theme_id_from_name -theme_name $theme_name]

    db_transaction {
        # create the portal and the first page

        set portal_id [db_exec_plsql create_new_portal {}]

        permission::grant -party_id $user_id -object_id $portal_id -privilege portal_read_portal
        permission::grant -party_id $user_id -object_id $portal_id -privilege portal_edit_portal
        permission::grant -party_id $user_id -object_id $portal_id -privilege portal_admin_portal

        # ignore the csv list if we have a template
        if {$csv_list ne "" && $template_id eq ""} {
        # if there are more pages in the csv_list, create them
            for {set i 1} {$i < [llength $page_name_list]} {incr i} {
                portal::page_create -portal_id $portal_id \
                    -pretty_name [lindex $page_name_list $i] \
                    -accesskey [lindex $page_accesskey_list $i] \
                    -layout_name [lindex $layout_name_list $i]
            }
        }

    }

    return $portal_id
}

ad_proc -public portal::delete {
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

ad_proc -public portal::get_name {
    portal_id
} {
    Get the name of this portal
} {
    return [lang::util::localize [util_memoize [list portal::get_name_not_cached -portal_id $portal_id]]]
}

ad_proc -private portal::get_name_not_cached {
    {-portal_id:required}
} {
    Memoizing helper
} {
    return [db_string get_name_select {} -default ""]
}

ad_proc -public portal::render {
    {-page_id ""}
    {-page_num ""}
    {-hide_links_p "f"}
    {-render_style "individual"}
    portal_id
} {
    Get a portal by id. If it's not found, say so.
    FIXME: right now the render style is totally ignored (ben)

    @return Fully rendered portal as an html string
    @param portal_id
} {
    permission::require_permission -object_id $portal_id -privilege portal_read_portal
    set edit_p [permission::permission_p -object_id $portal_id -privilege portal_edit_portal]

    set master_template [parameter::get -parameter master_template]

    # if no page_num set, render page 0
    if {$page_id eq "" && $page_num eq ""} {
        set sort_key 0
    } elseif {$page_num ne ""} {
        set sort_key $page_num
    }

    # get the portal and layout
    if {[db_0or1row portal_select {} -column_array portal]} {
        set page_id $portal(page_id)
    } else {
        return_complaint 1 [_ new-portal.Page_not_found]
        ad_script_abort
    }

    db_foreach element_select {} -column_array entry {
    # put the element IDs into buckets by region...
        lappend element_ids($entry(region)) $entry(element_id)
    } if_no_rows {
        set element_ids {}
    }

    set element_list [array get element_ids]

    # set up the template, it includes the layout template,
    # which in turn includes the theme, then elements
    set template "<master src=\"@master_template@\">
    <property name=\"title\">@portal.name@</property>"
    if { $element_list ne "" } {
        set element_src "${::portal::www_path}/render_styles/${render_style}/render-element"
        append template [subst {
            <include src="@portal.layout_filename@"
            element_list="@element_list@"
            element_src="@element_src@"
            theme_id="@portal.theme_id@"
            portal_id="@portal.portal_id@"
            edit_p="@edit_p@"
            hide_links_p="@hide_links_p@"
            page_id="@page_id@"
            layout_id="@portal.layout_id@"
            resource_dir="@portal.layout_resource_dir@">
        }]
    }

    # Necessary hack to work around the acs-templating system
    set __adp_stub "[acs_root_dir]${::portal::www_path}/."
    set {master_template} \"master\"

    # Compile and evaluate the template
    set code [template::adp_compile -string $template]
    return [template::adp_eval code]
}

ad_proc -private portal::layout_elements {
    element_list
    {var_stub "element_ids"}
} {
    Split a list up into a bunch of variables for inserting into a
    layout template. This seems pretty kludgy (probably because it is),
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

    foreach idx [list 1 2 3 4 5 6] {
        upvar "${var_stub}_$idx" group
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

ad_proc -private portal::update_name {
    portal_id new_name
} {
    Update the name of this portal

    @param portal_id
    @param new_name
} {

    permission::require_permission -object_id $portal_id -privilege portal_read_portal
    permission::require_permission -object_id $portal_id -privilege portal_edit_portal

    db_dml update {}
}

ad_proc -public portal::configure {
    {-referer ""}
    {-template_p f}
    {-allow_theme_change_p 1}
    portal_id
    return_url
} {
    Return a portal or portal template configuration page.
    All form targets point to file_stub-2.

    FIXME REFACTOR ME

    @param portal_id
    @param return_url
} {

    #
    # check perms
    #

    set edit_p [permission::permission_p \
        -object_id $portal_id \
        -privilege portal_edit_portal]

    if {!$edit_p} {
        permission::require_permission -object_id $portal_id -privilege portal_admin_portal
        set edit_p 1
    }

    #
    # Set up some whole page stuff
    #

    set master_template [parameter::get -parameter master_template]
    set action_string [generate_action_string]

    set element_src ${::portal::www_path}/[expr {$template_p == "f" ? "place-element" : "template-place-element"}]

    if {$referer eq ""} {
        set return_text [subst {
            <a href="@return_url@" title="[_ new-portal.Go_back]">[_ new-portal.Go_back]</a>
        }]
    } else {
        set return_text ""
        set return_url $referer
    }

    #
    # Begin creating the template
    #

    set template "
    <master src=\"@master_template@\">
    <p>$return_text</p>"

    #
    # Theme selection chunk
    #

    set theme_chunk [subst {
        <form method='post' action="@action_string@">
        <div><input type="hidden" name="portal_id" value="@portal_id@"></div>
        <div><input type="hidden" name="return_url" value="@return_url@"></div>
        <p><strong>[_ new-portal.Change_Theme]</strong></p>
    }]

    set current_theme_id [portal::get_theme_id -portal_id $portal_id]

    foreach theme [get_theme_info_not_cached] {
        set theme_id [ns_set get $theme theme_id]
        set name [ns_set get $theme name]
        set description [ns_set get $theme description]

        append theme_chunk "<div><label><input type=radio name=theme_id value=$theme_id"
        set one_theme_chunk "&nbsp;$name - $description"

        if {$current_theme_id == $theme_id } {
            append theme_chunk " checked><b>$one_theme_chunk</b>"
        } else {
            append theme_chunk ">$one_theme_chunk"
        }
        append theme_chunk "</label></div>"
    }

    append theme_chunk [subst {
        <div><input type="submit" name="op_change_theme" value="[_ new-portal.Change_Theme_1]"></div>
        </form>
    }]
    if {$allow_theme_change_p} {
        append template "$theme_chunk"
    }

    #
    # Per-page template chunks
    #

    set list_of_page_ids [list_pages_tcl_list -portal_id $portal_id]

    set last_page [lindex $list_of_page_ids [llength $list_of_page_ids]-1]
    #ns_log warning "last_page is $last_page"
    foreach page_id $list_of_page_ids {

        set first_page_p [portal::first_page_p -portal_id $portal_id -page_id $page_id]
        # We allow portal page names to have embedded message keys that we localize on the fly
        db_1row get_page_info {}
        set page_name [lang::util::localize $pretty_name_unlocalized]
        set page_layout_id [portal::get_layout_id -page_id $page_id]
        if {$hidden_p == "t"} {
            set tab_toggle_label [lang::util::localize "\#new-portal.Show_in_main_navigation\#"]
        } else {
            set tab_toggle_label [lang::util::localize "\#new-portal.Hide_in_main_navigation\#"]
        }

        append template "<table style=\"background-color:#eeeeee\" border=0 width=\"100%\">"

        #
        # Page rename chunk
        #
        set page_name_chunk [subst {
            <table border="0" width="100%" class="portal-page-config" cellpadding="0" cellspacing="0">
            <tr>
            <td align="center">
            <a name="$page_id"></a>
            <h2 class="portal-page-name">$page_name</h2>
            </td>
            <td align="right">
            <a name="$page_id"></a>
            <form name="op_rename_page" method="post" action="@action_string@" class="inline-form">
            <div><input type="hidden" name="portal_id" value="@portal_id@"></div>
            <div><input type="hidden" name="page_id" value=$page_id></div>
            <div><input type="hidden" name="return_url" value="@return_url@#$page_id"></div>
            <div><input type="hidden" name="anchor" value="$page_id"></div>
            <div><input type="submit" name="op_rename_page" value="[_ new-portal.Rename_Page]"></div>
            <div><input type="text" name="pretty_name" value="[ns_quotehtml $page_name]"></div>
            </form>
            <form name="op_toggle_tab_visibility" method="post" action="@action_string@">
            <div><input type="hidden" name="portal_id" value="@portal_id@"></div>
            <div><input type="hidden" name="page_id" value="$page_id"></div>
            <div><input type="hidden" name="return_url" value="@return_url@#$page_id"></div>
            <div><input type="hidden" name="anchor" value="$page_id"></div>
            <div><input type="submit" name="op_toggle_tab_visibility" value="$tab_toggle_label"></div>
            </form>
            </td>
            </tr>
            <tr>
            <td colspan="2" class="bottom-border">
            <img src="/resources/acs-subsite/spacer.gif" height="1" alt="">
            </td>
            </tr>
            </table>
        }]

        append template "<tr><td>$page_name_chunk</td></tr>"

        if {[portal::non_hidden_elements_p -page_id $page_id] || $first_page_p} {

        #
        # Page with non-hidden elements OR the first page of the portal
        #

            db_1row portal_and_page_info_select {} -column_array portal

            # fake some elements for the <list> in the template
            set regions [get_layout_region_list -layout_id $portal(layout_id)]
            foreach region $regions {
                lappend fake_element_ids($region) $portal_id
            }

            set element_list [array get fake_element_ids]

            # DRB: This is a horrible, short-term (I hope!) hack to allow
            # the portal config page to work correctly when a page's given
            # layout is div-based rather than table-based.

            set layout layouts/simple[llength $regions]
            db_1row layout_id_select {}

            append template [subst {
                <tr>
                <td>
                <table class="portal-page-config" style="background-color:#eeeeee" border="0" width="100%">
                <tr valign="middle">
                <td valign="middle">
                <include src="$layout"
                element_list="$element_list"
                action_string="@action_string@" portal_id="@portal_id@"
                return_url="@return_url@" element_src="@element_src@"
                hide_links_p="f"
                page_id="$page_id"
                layout_id="$layout_id"
                edit_p="@edit_p@">
                </td>
                </tr>
                </table>
                </td>
                </tr>}]


                # clear out the region array
            array unset fake_element_ids
        }

        if {![portal::non_hidden_elements_p -page_id $page_id]} {

        #
        # Non first page with all hidden elements
        #

        #
        # Remove page chunk - don't allow removal of the first page
        #


            if {! $first_page_p } {

                append template [subst {
                    <tr>
                    <td>
                    <include src="show-here" portal_id="$portal_id"
                    action_string="@action_string@"
                    region="1"
                    page_id="$page_id"
                    anchor="$page_id"
                    return_url="@return_url@">
                    </td>
                    </tr>
                }]

                append template [subst {
                    <tr valign="middle">
                    <td valign="middle">
                    <div style="text-align:center">
                    [_ new-portal.lt_No_Elements_on_this_p]
                    <form method="post" action="@action_string@">
                    [export_vars -form { portal_id page_id return_url { anchor $page_id } }]
                    <div><input type="submit" name="op_remove_empty_page" value="[_ new-portal.Remove_Empty_Page]"></div>
                    </form>
                    </div>
                    </td>
                    </tr>}]
            }

            #
            # Layout change chunk - only shown when there are no visible elements on the page
            #

            set layout_chunk ""

            foreach layout [get_layout_info] {
                set layout_id [ns_set get $layout layout_id]
                set layout_name [ns_set get $layout layout_name]
                set layout_description [ns_set get $layout layout_description]
                set one_layout_chunk "&nbsp;$layout_name - $layout_description"
                append layout_chunk "<div><label><input type='radio' name='layout_id' value='$layout_id'"

                if {$page_layout_id == $layout_id} {
                    append layout_chunk " checked><b>$one_layout_chunk</b>"
                } else {
                    append layout_chunk ">$one_layout_chunk"
                }

                append layout_chunk "</label></div>"
            }


            append template [subst {
                <tr>
                <td>
                <br>
                <form method="post" action="@action_string@">
                <p><b>[_ new-portal.Change_page_layout]</b></p>
                <div><input type="hidden" name="portal_id" value="$portal_id"></div>
                <div><input type="hidden" name="page_id" value="$page_id"></div>
                <div><input type="hidden" name="return_url" value="@return_url@"></div>
                <div><input type="hidden" name="anchor" value="$page_id"></div>
                $layout_chunk
                <div><input type="submit" name="op_change_page_layout" value="[_ new-portal.Change_Page_Layout]"></div>
                </form>
                </td>
                </tr>}]

        }


        # close the page's table
        append template "</table>"

    }

    #
    # New page chunk
    #

    set new_page_num [expr {[page_count -portal_id $portal_id] + 1}]

    append template [subst {<br>
                            <table class="portal-page-config" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                            <td>
                            <h2 class="portal-page-name">[_ new-portal.Create_a_new_page]</h2>
                            </td>
                            </tr>
                            <tr>
                            <td>
                            <a name="add_a_new_page"></a>
                            <form name="op_add_page" method="post" action="@action_string@">
                            <div><input type="hidden" name="portal_id" value="@portal_id@"></div>
                            <div><input type="hidden" name="return_url" value="@return_url@#$page_id"></div>
                            <div><input type="hidden" name="anchor" value="add_a_new_page"></div>
                            <div style="text-align:center">
                            <input type="text" name="pretty_name" value="[_ new-portal.Page] $new_page_num">
                            <input type="submit" name="op_add_page" value="[_ new-portal.Add_Page]">
                            </div>
                            </form>
                            </td>
                            </tr>
                            </table>}]

                            #
                            # Revert page chunk
                            #

    if {[get_portal_template_id $portal_id] ne ""} {
        append template [subst {<br>
                                <table class="portal-page-config" width="100%" cellpadding="0" border="0" cellspacing="0">
                                <tr>
                                <td>
                                <form name="op_revert" method="post" action="@action_string@">
                                <div><input type="hidden" name="portal_id" value="@portal_id@"></div>
                                <div><input type="hidden" name="return_url" value="@return_url@"></div>
                                <h2 class="portal-page-name">[_ new-portal.lt_Revert_the_entire_por]</h2>
                                <div style="text-align:center">
                                <input type="submit" name="op_revert" value="[_ new-portal.Revert]">
                                </div>
                                </form>
                                </td>
                                </tr>
                                </table>}]
    }

    if { [db_string sub_portals {}] } {
    # Portal has other portals using it as a template
        append template [subst {<br>
                                <table class="portal-page-config" width="100%" cellpadding="0" border="0" cellspacing="0">
                                <tr>
                                <td>
                                <form name="op_revert_all" method="post" action="@action_string@">
                                <div><input type="hidden" name="portal_id" value="@portal_id@"></div>
                                <div><input type="hidden" name="return_url" value="@return_url@"></div>
                                <h2 class="portal-page-name">[_ new-portal.lt_Revert_all_portals_us]</h2>
                                <div style="text-align:center">
                                <input type="submit" name="op_revert_all" value="[_ new-portal.Revert_All]">
                                <br>
                                <i>[_ new-portal.lt_Note_Please_be_patien]</i>
                                </div>
                                </form>
                                </td>
                                </tr>
                                </table>}]
    }

    #
    # Templating system hacks
    #

    set __adp_stub "[acs_root_dir]${::portal::www_path}/."
    set master_template \"master\"

    set code [template::adp_compile -string $template]
    set output [template::adp_eval code]

    return $output
}

ad_proc -public portal::configure_dispatch {
    {-template_p "f"}
    {-portal_id:required}
    {-form:required}
} {
    Dispatches the configuration operation.
    We get the target region number from the op.

    @param portal_id the portal to edit
    @param formdata an ns_set with all the formdata
} {
    set edit_p \
        [permission::permission_p \
        -object_id $portal_id \
        -privilege portal_edit_portal
    ]

    if {!$edit_p} {
        permission::require_permission -object_id $portal_id -privilege portal_admin_portal
        set edit_p 1
    }


    if { [ns_set get $form "op_revert_all"] ne "" } {
        set template_id [ns_set get $form "portal_id"]
        ns_log notice "REVERTING ALL template_id='${template_id}'"
        set revert_all_set_id [ns_set create]

        ns_set put $revert_all_set_id op_revert "op_revert"
        set portal_id_list [db_list get_all_portals "select portal_id from portals where template_id=:template_id"]
        ns_log notice "PORTAL_ID_LIST $portal_id_list"
        foreach portal_id $portal_id_list {
            portal::configure_dispatch -portal_id $portal_id -form $revert_all_set_id
        }

    } elseif { [ns_set get $form "op_revert"] ne "" } {
        #Transaction here was causeing uncaught deadlocks so it was removed. - CM 9-11-02
        #It doesn't seem necessary to have a transaction here. Its not a big deal if this fails in the middle. The user can just revert again.

        set template_id [get_portal_template_id $portal_id]

        # revert theme
        set theme_id [get_theme_id -portal_id $template_id]
        db_dml revert_theme_update {}

        # revert pages

        # Roel - 03-10-2005, fix for revert problems
        # This fix tries to match the target portal with the
        # template before the revert via the pages' sort keys

        # First, create source pages that aren't in the target portal
        db_foreach revert_source_pages {} {
            if { ! [db_0or1row revert_get_target_page_id {}] } {
                set pretty_name "portal revert dummy page $sort_key"
                set page_id [page_create \
                                    -pretty_name $pretty_name \
                                    -portal_id $portal_id]

            # Now set the page's sort_key
            db_dml revert_set_target_page_sort_key {}
            }
        }

        # Second, delete target pages that aren't in the source
        # portal
        db_foreach revert_target_pages {} {
            if { ! [db_0or1row revert_get_source_page_id {}] } {
                set move_to_page_id [db_string revert_min_page_id_select {}]

                db_foreach revert_move_elements_for_del {} {
                    portal::move_element_to_page \
                        -page_id $move_to_page_id \
                        -element_id $element_id \
                        -region 1
                }

                page_delete -page_id $page_id
            }
        }

        # now that they have the same number of pages, get to it
        foreach source_page_id [list_pages_tcl_list -portal_id $template_id] {

            db_1row revert_get_source_page_info {}

            set target_page_id [db_string revert_get_target_page_id {}]

            db_dml revert_page_update {}

            # First, hide all elements.
            # If there are new content portlets that are not
            # in the default template, this will ensure they don't come
            # up.

            db_dml hide_all_elements {
                update portal_element_map
                set  state = 'hidden'
                where page_id = :target_page_id
            }

            # revert elements in two steps like "swap"
            db_foreach revert_get_source_elements {} {
                # the element might not be on the target page...
                set target_element_id \
                    [db_string revert_get_target_element {} -default {}]

                    # now, lets check if this is one new applet
                    # added, that was not originally mapped
                    # usually with custom portlets

                if {$target_element_id ne ""} {
                    db_dml revert_element_update {}
                }
            }
        }
    } elseif { [ns_set get $form "op_rename"] ne "" } {
        portal::update_name $portal_id [ns_set get $form new_name]

    } elseif { [ns_set get $form "op_swap"] ne "" } {
        portal::swap_element $portal_id \
            [ns_set get $form element_id] \
            [ns_set get $form region] \
            [ns_set get $form direction]
    } elseif { [ns_set get $form "op_move"] ne "" } {
        portal::move_element $portal_id \
            [ns_set get $form element_id] \
            [ns_set get $form region] \
            [ns_set get $form direction]
    } elseif { [ns_set get $form "op_show_here"] ne "" } {
        set region [ns_set get $form region]
        set element_id [ns_set get $form element_id]
        set page_id [ns_set get $form page_id]

        db_transaction {
            # The new element's sk will be the last in the region
            db_dml show_here_update_sk {}
            db_dml show_here_update_state {}
        }
    } elseif { [ns_set get $form "op_move_to_page"] ne "" } {
        portal::move_element_to_page \
            -page_id [ns_set get $form page_id] \
            -element_id [ns_set get $form element_id]
    } elseif { [ns_set get $form "op_hide"] ne "" } {
        set element_id_list [list]

        # iterate through the set, destructive!
        while { [ns_set find $form "element_id"] + 1 } {
            lappend element_id_list [ns_set get $form "element_id"]
            ns_set delkey $form "element_id"
        }

        if {$element_id_list ne "" } {
            db_transaction {
                foreach element_id $element_id_list {
                    db_dml hide_update {}

                    # after hiding an element, add
                    # it to the _first_ page
                    # of the portal.
                    portal::move_element_to_page \
                        -page_id [portal::get_page_id -portal_id $portal_id] \
                        -element_id $element_id
                }
            }
        }
    } elseif { [ns_set get $form "op_change_theme"] ne "" } {
        set theme_id [ns_set get $form theme_id]

        db_dml update_theme {}
    } elseif { [ns_set get $form "op_add_page"] ne "" } {
        set pretty_name [ns_set get $form pretty_name]
        if {$pretty_name eq ""} {
            ad_return_complaint 1 [_ new-portal.lt_You_must_enter_new_na]
            ad_script_abort
        }
        page_create -pretty_name $pretty_name -portal_id $portal_id
    } elseif { [ns_set get $form "op_remove_empty_page"] ne "" } {
        set page_id [ns_set get $form page_id]
        page_delete -page_id $page_id
    } elseif { [ns_set get $form "op_change_page_layout"] ne "" } {
        set_layout_id \
            -portal_id $portal_id \
            -page_id [ns_set get $form page_id] \
            -layout_id [ns_set get $form layout_id]
    } elseif { [ns_set get $form "op_rename_page"] ne "" } {
        set pretty_name [ns_set get $form pretty_name]
        set page_id [ns_set get $form page_id]

        if {$pretty_name eq ""} {
            ad_return_complaint 1 [_ new-portal.lt_You_must_enter_new_na]
            ad_script_abort
        }
        set_page_pretty_name -pretty_name $pretty_name -page_id $page_id
    } elseif { [ns_set get $form "op_toggle_tab_visibility"] ne "" } {
        set page_id [ns_set get $form page_id]
        db_dml toggle_tab_visibility {}
    } elseif { [ns_set get $form "op_toggle_pinned"] ne "" } {
        set element_id [ns_set get $form element_id]

        if {[db_string toggle_pinned_select {}] eq "full"} {

            db_dml toggle_pinned_update_pin {}

            # "pinned" implies not user hideable, shadable
            set_element_param $element_id "hideable_p" "f"
            set_element_param $element_id "shadeable_p" "f"

        } else {
            db_dml toggle_pinned_update_unpin {}
        }
    } elseif { [ns_set get $form "op_toggle_hideable"] ne "" } {
        set element_id [ns_set get $form element_id]
        toggle_element_param -element_id $element_id -key "hideable_p"
    } elseif { [ns_set get $form "op_toggle_shadeable"] ne "" } {
        set element_id [ns_set get $form element_id]
        toggle_element_param -element_id $element_id -key "shadeable_p"
    }
}

#
# portal template procs - util and configuration
#

ad_proc -private portal::get_portal_template_id {
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

ad_proc -public portal::template_configure {
    portal_id
    return_url
} {
    Just a wrapper for the configure proc.

    @param portal_id
    @return A portal configuration page
} {
    portal::configure -template_p "t" $portal_id $return_url
}

ad_proc -public portal::template_configure_dispatch {
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

ad_proc -public portal::get_page_id {
    {-create:boolean}
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
    if { $page_name ne "" } {
    # Get page by page_name

        set page_id [db_string get_page_id_from_name {} -default ""]

        if { $page_id eq "" } {
            if { $create_p } {
            # there is no page by that name in the portal, create it
                return [portal::page_create \
                    -portal_id $portal_id \
                    -pretty_name $page_name]
            } else {
            # Call ourselves with portal_id and sort_key 0 to get the first page
                return [get_page_id -portal_id $portal_id -sort_key 0]
            }
        } else {
            return $page_id
        }
    } else {
    # Get page by sort key
        return [db_string get_page_id_select {}]
    }
}

ad_proc -public portal::first_page_p {
    {-portal_id:required}
    {-page_id:required}
} {
    Returns 1 if the given page_id is the first page in the given portal. Otherwise 0.
} {
    if {$page_id == [portal::get_page_id -portal_id $portal_id -sort_key 0]} {
        return 1
    } else {
        return 0
    }
}

ad_proc -public portal::page_count {
    {-portal_id:required}
} {
    1 when there's only one page

    @param portal_id
    @param page_id
} {
    return [db_string page_count_select {}]
}

ad_proc -public portal::get_page_pretty_name {
    {-page_id:required}
} {
    Gets the pn
} {
    return [db_string get_page_pretty_name_select {}]
}

ad_proc -public portal::set_page_pretty_name {
    {-page_id:required}
    {-pretty_name:required}
} {
    Updates the pn
} {
    return [db_dml set_page_pretty_name_update {}]
}

ad_proc -public portal::page_delete {
    {-page_id:required}
} {
    deletes the page
} {
    return [db_exec_plsql page_delete {}]
}

ad_proc -public portal::page_create {
    {-layout_name ""}
    {-pretty_name:required}
    {-portal_id:required}
    {-accesskey ""}
} {
    Appends a new blank page for the given portal_id.

    @return the id of the page
    @param portal_id
} {
# get the layout_id
    if {$layout_name ne ""} {
        set layout_id [get_layout_id -layout_name $layout_name]
    } else {
        set layout_id [get_layout_id]
    }

    return [db_exec_plsql page_create_insert {}]
}

ad_proc -public portal::list_pages_tcl_list {
    {-portal_id:required}
} {
    Returns a Tcl list of the page_ids for the given portal_id

    @return Tcl list of the pages
    @param portal_id
} {
    set foo [list]

    db_foreach list_pages_tcl_list_select {} {
        lappend foo $page_id
    }
    return $foo
}

ad_proc -public portal::navbar {
    {-portal_id:required}
    {-td_align "left"}
    {-link ""}
    {-pre_html ""}
    {-post_html ""}
    {-link_all 0}
    {-extra_td_html ""}
    {-table_html_args ""}
    {-extra_td_selected_p 0}
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

    set ad_dim_struct "{ page_num [list [_ new-portal.Page_1]] 0 [list $ad_dim_struct] }"

    return [dimensional -no_header \
        -no_bars \
        -link_all $link_all \
        -td_align $td_align \
        -pre_html $pre_html \
        -post_html $post_html \
        -extra_td_html $extra_td_html \
        -extra_td_selected_p $extra_td_selected_p \
        -table_html_args $table_html_args \
        $ad_dim_struct \
        $link]
}

#
# Element Procs
#

ad_proc -public portal::add_element {
    {-portal_id:required}
    {-portlet_name:required}
    {-force_region ""}
    {-sort_key ""}
    {-page_name ""}
    {-pretty_name ""}
} {
    Add an element to a portal given a datasource name. Used for procs
    that have no knowledge of regions

    @param sort_key If provided will be used to insert the element. Other elements won't be reordered
    @return the id of the new element
} {
    if {$pretty_name eq ""} {
        set pretty_name $portlet_name
    }

    set page_id [get_page_id -create -portal_id $portal_id -page_name $page_name]

    # Balance the portal by adding the new element to the region
    # with the fewest number of elements, the first region w/ 0 elts,
    # or, if all else fails, the first region
    set min_num 99999
    set min_region 0

    # get the layout for some page
    set layout_id [get_layout_id -page_id $page_id $portal_id]

    # get the regions in this layout
    foreach region [get_layout_region_list -layout_id $layout_id] {
        lappend region_list $region
    }

    if {$force_region eq ""} {
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
            ad_return_complaint 1 "portal::add_element region $force_region not in layout $layout_id"
            ad_script_abort
        }
    }

    return [add_element_to_region \
        -page_name $page_name \
        -layout_id $layout_id \
        -pretty_name $pretty_name \
        -sort_key $sort_key \
        $portal_id \
        $portlet_name \
        $min_region \
        ]
}

ad_proc -public portal::remove_element {
    {-element_id ""}
    {-portlet_name ""}
    {-portal_id ""}
} {
    Remove an element from a portal. Can either specify 1. the element_id to remove
    or 2. the portal_id and the datasource_name which will remove all elements of
    that datasource on the portal. An element_id overrides all other params
} {
    if {$element_id ne ""} {
        db_dml delete {}
    } else {
        if {$portal_id eq "" && $portlet_name eq ""} {
            ad_return_complaint 1 "portal::remove_element [_ new-portal.lt_Error_bad_params_n___]"
            ad_script_abort
        }

        set element_ids [portal::get_element_ids_by_ds \
            $portal_id \
            $portlet_name
        ]

        db_transaction {
            foreach element_id $element_ids {
                portal::remove_element -element_id $element_id
            }
        }
    }
}

ad_proc -private portal::add_element_to_region {
    {-layout_id:required}
    {-page_name ""}
    {-pretty_name ""}
    {-sort_key ""}
    portal_id
    ds_name
    region
} {
    Add an element to a portal in a region, given a datasource name

    @return the id of the new element
    @param sort_key If set will be used to insert the element. The other elements won't be reordered
    @param portal_id
    @param ds_name
} {

# XXX AKS: The whole issue of datasource/portlet naming must
# be cleaned up! FIXME

    if {$pretty_name eq ""} {
        set pretty_name $ds_name
    }

    set page_id [get_page_id -portal_id $portal_id -page_name $page_name]
    set ds_id [get_datasource_id $ds_name]

    # First, check if this portal 1) has a portal template and
    # 2) that that template has an element of this DS in it. If
    # so, copy stuff. If not, just insert normally.
    if {[db_0or1row get_template_info_select {}] == 1} {

        set new_element_id [db_nextval acs_object_id_seq]
        set target_page_id [get_page_id \
            -portal_id $portal_id \
            -page_name $page_name \
            -sort_key $template_page_sort_key
        ]

        db_dml template_insert {}
        db_dml template_params_insert {}

    } else {
    # no template, or the template doesn't have this D

    # sort_key will be used only on insert
        if { $sort_key eq "" } {
            set sort_key [db_string get_sort_key {} -default "1"]
            set sort_key [ad_decode $sort_key "" "1" $sort_key]
        }

        db_transaction {
            set new_element_id [db_nextval acs_object_id_seq]
            db_dml insert {}
            db_dml params_insert {}
        }
    }

    # The caller must now set the necessary params or else!
    return $new_element_id
}

ad_proc -private portal::swap_element {
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

    permission::require_permission -object_id $portal_id -privilege portal_read_portal
    permission::require_permission -object_id $portal_id -privilege portal_edit_portal

    # get this element's sk
    db_1row get_my_sort_key_and_page_id {}

    if { $dir eq "up" } {
        # get the sort_key and id of the element above
        if {[db_0or1row get_prev_sort_key {}] == 0} {
            return
        }
    } elseif { $dir eq "down"} {
        # get the sort_key and id of the element below
        if {[db_0or1row get_next_sort_key {}] == 0} {
            return
        }
    } else {
        ad_return_complaint 1 \
            "portal::swap_element: [_ new-portal.Bad_direction] $dir"
        ad_script_abort
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
        ad_return_complaint 1 "portal::swap_element: [_ new-portal.transaction_failed]"
        ad_script_abort
    }
}

ad_proc -private portal::move_element {
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

    permission::require_permission -object_id $portal_id -privilege portal_read_portal
    permission::require_permission -object_id $portal_id -privilege portal_edit_portal

    if { $direction eq "right" } {
        set target_region [expr {$region + 1}]
    } elseif { $direction eq "left" } {
        set target_region [expr {$region - 1}]
    } else {
        ad_return_complaint 1 "portal::move_element [_ new-portal.Bad_direction_1]"
        ad_script_abort
    }

    # get this element's page_id
    db_1row get_my_page_id {}

    db_dml update {}
}

ad_proc -private portal::get_element_region {
    {-element_id:required}
} {
    Gets the region an element is in
} {
    return [db_string get_element_region_select {}]
}

ad_proc -private portal::move_element_to_page {
    {-page_id:required}
    {-element_id:required}
    {-region ""}
} {
    Moves a PE to the given page
} {
    if {$region eq ""} {
        set curr_reg [get_element_region -element_id $element_id]
    } else {
        set curr_reg $region
    }

    set target_reg_num [get_layout_region_count_not_cached \
        -layout_id [get_layout_id -page_id $page_id]
    ]

    if {$curr_reg > $target_reg_num} {
    # the new page dosent have this region, set to max region
        set region $target_reg_num
    } else {
        set region $curr_reg
    }

    db_dml update {}
}

ad_proc -private portal::hideable_p {
    {-element_id:required}
} {
    Check if an element is hideable
} {
    return [util_memoize "portal::hideable_p_not_cached -element_id $element_id"]
}

ad_proc -private portal::hideable_p_not_cached {
    {-element_id:required}
} {
    Check if an element is hideable
} {
    return [db_string select_hideable_p {}]
}

ad_proc -private portal::hidden_elements_list {
    {-portal_id:required}
} {
    Returns a list of "hidden" element available to a portal. Use a 1 second cache here
    to fake a per-connection cache.
} {
    return [util_memoize "portal::hidden_elements_list_not_cached -portal_id $portal_id" 1]
}

ad_proc -private portal::hidden_elements_list_not_cached {
    {-portal_id:required}
} {
    Memoizing helper
} {
    return [db_list_of_lists select_hidden_elements {}]
}

ad_proc -private portal::non_hidden_elements_p {
    {-page_id:required}
} {
    Returns 1 when this page has at least 1 non-hidden element on it.
} {
    return [db_string non_hidden_elements_p_select {} -default 0]

}

ad_proc -private portal::set_element_param {
    element_id
    key
    value
} {
    Set an element param named key to value

    @param element_id
    @param key
    @param value
} {
#ns_log notice "aks80 set_element_param $element_id / $key / $value / [db_list_of_lists foo {
# select * from portal_element_parameters where element_id = :element_id}] "

    db_dml update {}

    util_memoize_flush "portal::element_params_not_cached $element_id"

    # ns_log notice "aks81 [get_element_param $element_id $key]"
    return 1
}

ad_proc -private portal::toggle_element_param {
    {-element_id:required}
    {-key:required}
} {
    toggles a boolean (t or f) element_param

    @param element_id
    @param key
} {
    if { [get_element_param $element_id $key] == "t" } {
        set_element_param $element_id $key "f"
    } else {
        set_element_param $element_id $key "t"
    }
}

ad_proc -private portal::get_element_param_list {
    {-element_id:required}
    {-key:required}
} {
    Get the list of parameter values for a particular element

    @author ben@openforce
} {
    return [db_list select {}]
}

ad_proc -private portal::add_element_param_value {
    {-element_id:required}
    {-key:required}
    {-value:required}
} {
    This adds a value for a param (instead of resetting a single value)

    @author ben@openforce
} {
    db_dml insert {}

    util_memoize_flush "portal::element_params_not_cached $element_id"

}

ad_proc -private portal::remove_element_param_value {
    {-element_id:required}
    {-key:required}
    {-value:required}
} {
    removes a value for a param
} {
    db_dml delete {}

    # DRB: Remove the cached copy of this element, too.
    util_memoize_flush "portal::element_params_not_cached $element_id"

}

ad_proc -private portal::remove_all_element_param_values {
    {-element_id:required}
    {-key:required}
} {
    removes a value for a param
} {
    db_dml delete {}
}

ad_proc -private portal::get_element_param { element_id key } {
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

ad_proc -private portal::element_params_not_cached element_id {
    Return a list of lists of key value pairs for this portal element.
} {
    return [db_list_of_lists params_select {}]
}

ad_proc -private portal::get_element_id_from_unique_param {
    {-portal_id:required}
    {-key:required}
    {-value:required}
} {
    If you know that on a given portal there is a _unique_ element
    identified by a parameter value and you want to find said element,
    this is your proc. Will error out if the param is not found (poor-man's
    ASSERT)
} {
    return [db_string select {
        select portal_element_map.element_id
        from portal_element_map, portal_element_parameters
        where portal_element_map.page_id in (select page_id
        from portal_pages
        where portal_id = :portal_id)
        and portal_element_parameters.element_id = portal_element_map.element_id
        and portal_element_parameters.key = :key
        and portal_element_parameters.value = :value
    }]
}

ad_proc -private portal::evaluate_element {
    {-portal_id:required}
    {-edit_p:required}
    element_id
    theme_id
} {
    Combine the datasource, template, etc. Return a chunk of HTML.

    @return A string containing the fully-rendered content for $element_id.
} {
    # get the element data and theme
    db_1row element_select {} -column_array element

    # get the element's params
    set element_params [util_memoize "portal::element_params_not_cached $element_id" 86400]
    if {[llength $element_params]} {
        foreach param $element_params {
            lassign $param key value
            lappend config($key) $value
        }
    } else {
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

    #
    # do the callback for the ::show proc
    # evaluate the datasource.
    #
    ad_try {
        datasource_call \
            -datasource_name $element(ds_name) \
            $element(datasource_id) \
            "Show" \
            [list [array get config]]

    } on error {errorMsg} {
        ad_log error "*** portal::evaluate_element callback Error! *** errormsg: $errorMsg\n config='[array get config]'\n"
        set element(content) ""
        append element(content) "You have found a bug in our code. " \
            "<p>Please notify the webmaster and include the following text. Thank You." \
            "<p><pre><small>*** portal::evaluate_element callback Error! ***\n\n [ns_quotehtml $errorMsg]</small></pre>\n\n"

    } on ok {content} {
        set element(content) $content
    }

    # trim the element's content
    set element(content) [string trim $element(content)]

    # We use the actual pretty name from the DB (ben)
    # FIXME: this is not as good as it should be
    if {$element(ds_name) eq $element(pretty_name)} {

        set element(name) \
            [datasource_call \
            -datasource_name $element(ds_name) \
            $element(datasource_id) \
            "GetPrettyName" \
            [list]]
    } else {
        set element(name) $element(pretty_name)
    }

    # Peter: we allow the element name to contain embedded message catalog keys
    # that we localize on the fly
    set element(name) [lang::util::localize $element(name)]

    # The idea for the link proc in the datasource API is that
    # it is the target for the href for the title of the portlet,
    # but since we are using "hide_links_p" all the time, the
    # value this returns is ignored
    set element(link) \
        [datasource_call \
        -datasource_name $element(ds_name) \
        $element(datasource_id) \
        "Link" \
        [list]]

        # done with callbacks, now set config params
    set element(shadeable_p) $config(shadeable_p)
    set element(shaded_p) $config(shaded_p)
    set element(hideable_p) $config(hideable_p)
    set element(user_editable_p) $config(user_editable_p)
    set element(link_hideable_p) $config(link_hideable_p)

    # apply the path hack to the filename and the resourcedir
    # Only do this if the element filename does not start with "/packages"
    if {[string first "/packages" $element(filename)] < 0} {
        set element(filename) "${::portal::www_path}/$element(filename)"
    }

    # DRB: don't ruin URLs that start with "/", i.e. the form "/resources/package-key/..."
    if { [string index $element(resource_dir) 0] ne "/" } {
    # notice no "/" after mount point
        set element(resource_dir) "[mount_point]$element(resource_dir)"
    }

    return [array get element]
}

ad_proc -private portal::evaluate_element_raw { element_id } {
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
    # evaluate the datasource.
    ad_try {
        datasource_call \
            $element(datasource_id) "Show" [list [array get config] ]
    } on error {errorMsg} {
        ad_log error "*** portal::evaluate_element_raw callback Error ! *** $errorMsg"
        ad_return_complaint 1 "*** portal::evaluate_element_raw show callback Error! *** <p> [ns_quotehtml $errorMsg]"
        ad_script_abort
    }

    set element(name) \
        [datasource_call \
        $element(datasource_id) "GetPrettyName" [list]]

        # Peter: we allow the element name to contain embedded message catalog keys
        # that we localize on the fly
    set element(name) [lang::util::localize $element(name)]

    # no "Link" for raw elements
    set element(link) {}

    # done with callbacks, now set config params
    set element(shadeable_p) $config(shadeable_p)
    set element(shaded_p) $config(shaded_p)
    set element(hideable_p) $config(hideable_p)
    set element(user_editable_p) $config(user_editable_p)
    set element(link_hideable_p) $config(link_hideable_p)

    # THE HACK - BEN OVERRIDES TO RAW
    set element(filename) "themes/raw-theme"

    # apply the path hack to the filename and the resourcedir
    set element(filename) "${::portal::www_path}/$element(filename)"
    # notice no "/" after mount point
    # set element(resource_dir) "[mount_point]$element(resource_dir)"

    return [array get element]
}

ad_proc -public portal::configure_element {
    {-noconn ""}
    element_id
    op
    return_url
} {
    Dispatch on the element_id and op requested

    @param element_id
    @param op
    @param return_url
} {

    if { [db_0or1row select {}] } {
        # passed in element_id is good, do they have perms?
        if {$noconn eq ""} {
            permission::require_permission -object_id $portal_id -privilege portal_read_portal
            permission::require_permission -object_id $portal_id -privilege portal_edit_portal
        }
    } else {
        ad_returnredirect $return_url
        ad_script_abort
    }

    switch $op {
        "edit" {
            # Get the edit html by callback
            # Notice that the "edit" proc takes only the element_id
            set html_string [datasource_call $datasource_id "Edit" \
                [list $element_id]]

            if { $html_string eq "" } {
                ns_log Error "portal::configure_element op = edit, but
                portlet's edit proc returned null string"

                ad_returnredirect $return_url
                ad_script_abort
            }

            # Set up some template vars, including the form target
            set master_template [parameter::get -parameter master_template]
            set action_string [generate_action_string]

            # the <include> sources /www/place-element.tcl
            set template [subst {
                <master src="@master_template@">
                <b><a href="@return_url@">Return to your portal</a></b>
                <p>
                <form action="@action_string@">
                <b>Edit this element's parameters:</b>
                <P>
                @html_string@
                <P>
                </form>
            }]
            set __adp_stub "[acs_root_dir]${::portal::www_path}/."
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
            ad_script_abort
        }
        "hide" {
            db_dml hide_update {}

            if {$return_url ne ""} {
                ad_returnredirect $return_url
                ad_script_abort
            }
        }
    }
}

ad_proc -private portal::set_pretty_name {
    {-element_id:required}
    {-pretty_name:required}
} {
    Set the element's pretty name shown in the title bar.
} {
    db_dml update {
        update portal_element_map
        set pretty_name = :pretty_name
        where element_id = :element_id
    }
}

#
# Datasource helper procs
#

ad_proc -private portal::get_datasource_name { ds_id } {
    Get the ds name from the id or the null string if not found.

    @param ds_id
    @return ds_name
} {
    if { ![catch {db_1row select {}} errmsg] } {
        return $name
    } else {
        set error_text "portal::get_datasource_name error! No datasource with id \"$ds_id\" found"
        ns_log Error $error_text
        ns_log Error "$::errorInfo"
        ad_return_complaint 1 $error_text
        ad_script_abort
    }
}

ad_proc -private portal::get_datasource_id { ds_name } {
    Get the ds id from the name

    @param ds_name
    @return ds_id
} {
    if { ![catch {db_1row select {}} errmsg] } {
        return $datasource_id
    } else {
        set error_text "portal::get_datasource_name error! No datasource with name \"$ds_name\" found"
        ns_log Error $error_text\n$::errorInfo
        ad_return_complaint 1 $error_text
        ad_script_abort
    }
}

ad_proc -private portal::make_datasource_available {portal_id ds_id} {
    Make the datasource available to the given portal.

    @param portal_id
    @param ds_id
} {
    if {![datasource_available_p -portal_id $portal_id -datasource_id $ds_id]} {
        set new_p_ds_id [db_nextval acs_object_id_seq]
        db_dml insert {}
    }
}

ad_proc -private portal::datasource_available_p {
    {-portal_id:required}
    {-datasource_id:required}
} {
    Check is the given ds is available to the given portal

    @param portal_id
    @param ds_id
} {
    return [db_string select {}]
}

ad_proc -private portal::make_datasource_unavailable {portal_id ds_id} {
    Make the datasource unavailable to the given portal.

    @param portal_id
    @param ds_id
} {
# permission::require_permission -object_id $portal_id -privilege portal_admin_portal
    db_dml delete {}
}

ad_proc -private portal::toggle_datasource_availability {portal_id ds_id} {
    Toggle

    @param portal_id
    @param ds_id
} {
    permission::require_permission -object_id $portal_id -privilege portal_admin_portal

    if { [db_0or1row select {}] } {
        [make_datasource_unavailable $portal_id $ds_id]
    } else {
        [make_datasource_available $portal_id $ds_id]
    }
}

#
# Misc procs
#

ad_proc -private portal::generate_action_string {
} {
    Portal configuration pages need this to set up
    the target for the generated links. It's just the
    current location with "-2" appended to the name of the
    page.
} {
    return "[lindex [ns_conn urlv] [ns_conn urlc]-1]-2"
}

ad_proc -private portal::get_element_ids_by_ds {portal_id ds_name} {
    Get element IDs for a particular portal and a datasource name
} {
    set ds_id [get_datasource_id $ds_name]
    return [db_list select {}]
}

ad_proc -private portal::get_element_id_by_pretty_name {
    {-portal_id:required}
    {-pretty_name:required}
} {
    Get the element IDs with the given pn on the portal, returns
    the empty string if none is found
} {
    return [db_string select {} -default ""]
}

ad_proc -private portal::get_layout_region_count {
    {-layout_id:required}
} {
    Get the number of regions (aka columns) this layout supports
} {
    return [util_memoize "portal::get_layout_region_count_not_cached -layout_id $layout_id"]
}

ad_proc -private portal::get_layout_region_count_not_cached {
    {-layout_id:required}
} {
    return [db_string select {}]
}

ad_proc -private portal::get_layout_region_list {
    {-layout_id:required}
} {
    Get a list of the regions that a layout supports
} {
    return [util_memoize "portal::get_layout_region_list_not_cached -layout_id $layout_id"]
}

ad_proc -private portal::get_layout_region_list_not_cached {
    {-layout_id:required}
} {
    Memoizing helper
} {
    return [db_list select_region_list {}]
}

ad_proc -private portal::get_layout_info {
} {
    Returns a list of all the layouts in the system asns_sets with
    keys being: name, description, and number of regions.
} {
    return [db_list_of_ns_sets select_layout_info {}]
}

ad_proc -private portal::set_layout_id {
    {-portal_id:required}
    {-page_id:required}
    {-layout_id:required}
} {
    Updates a page's layout.
} {
    db_dml update_layout_id {}
    db_flush_cache -cache_key_pattern portal::get_page_header_stuff_${portal_id}_*
}

ad_proc -private portal::get_layout_id {
    {-page_num ""}
    {-page_id ""}
    {-layout_name ""}
    {portal_id ""}
} {
    Get the layout_id of a layout template for a portal page.

    @param page_num the page of the portal to look at, def page 0
    @param portal_id The portal_id.
    @return A layout_id.
} {
    if { $layout_name eq "" } {
        set layout_name [parameter::get_from_package_key \
            -package_key new-portal \
            -parameter default_layout]
    }
    if { $page_num ne "" } {
        db_1row get_layout_id_num_select {}
    } elseif { $page_id ne "" } {
        db_1row get_layout_id_page_select {}
    } elseif { $layout_name ne "" } {
        db_1row get_layout_id_name_select {}
    } else {
        ad_return_complaint 1 "portal::get_layout_id bad params!"
        ns_log error "portal::get_layout_id bad params!"
        ad_script_abort
    }

    return $layout_id
}

ad_proc -private portal::exists_p { portal_id } {
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

ad_proc -public portal::add_element_parameters {
    {-portal_id:required}
    {-portlet_name:required}
    {-value:required}
    {-key "package_id"}
    {-page_name ""}
    {-pretty_name ""}
    {-extra_params ""}
    {-force_region ""}
    {-sort_key ""}
    {-param_action "overwrite"}
} {
    A helper proc for portlet "add_self_to_page" procs.
    Adds the given portlet as an portal element to the given
    page. If the portlet is already in the given portal page,
    it appends the value to the element's parameters with the
    given key. Returns the element_id used.

    IMPROVE ME: refactor

    @return element_id The new element's id

    @param portal_id The page to add the portlet to
    @param portlet_name The name of the portlet to add
    @param value the value of the key
    @param key the key for the value (defaults to package_id)
    @param extra_params a list of extra key/value pairs to insert or append
    @param sort_key If set, will be used to insert a new element. Other elements of the region won't be reordered
} {

    if {$param_action eq ""} {
        set param_action "overwrite"
    }

    # Find out if this portlet already exists in this page
    set element_id_list [get_element_ids_by_ds $portal_id $portlet_name]

    if {[llength $element_id_list] == 0} {
        db_transaction {
        # Tell portal to add this element to the page
            set element_id [add_element \
                -portal_id $portal_id \
                -portlet_name $portlet_name \
                -pretty_name $pretty_name \
                -page_name $page_name \
                -force_region $force_region \
                -sort_key $sort_key
            ]

            # There is already a value for the param which is overwritten
            set_element_param $element_id $key $value

            if {$extra_params ne ""} {
                check_key_value_list $extra_params

                for {set x 0} {$x < [llength $extra_params]} {incr x 2} {
                    set_element_param $element_id \
                        [lindex $extra_params $x] \
                        [lindex $extra_params $x+1]
                }
            }
        }
    } else {
        db_transaction {
            set element_id [lindex $element_id_list 0]

            if {$param_action eq "append"} {
                add_element_param_value -element_id $element_id -key $key -value $value
            } elseif {$param_action eq "overwrite"} {
                set_element_param $element_id $key $value
            } else {
                error "portal::add_element_parameters error: bad param action! $param_action 1"
            }

            if {$extra_params ne ""} {
                check_key_value_list $extra_params

                for {set x 0} {$x < [llength $extra_params]} {incr x 2} {
                    if {$param_action eq "append"} {
                        add_element_param_value \
                            -element_id $element_id \
                            -key [lindex $extra_params $x] \
                            -value [lindex $extra_params $x+1]
                    } elseif {$param_action eq "overwrite"} {
                        set_element_param $element_id [lindex $extra_params $x] [lindex $extra_params $x+1]
                    } else {
                        error "portal::add_element_parameters error: bad param action! $param_action 2"
                    }
                }
            }
        }
    }
    return $element_id
}

ad_proc -public portal::remove_element_parameters {
    {-portal_id:required}
    {-portlet_name:required}
    {-value:required}
    {-key "package_id"}
    {-extra_params ""}
} {
    A helper proc for portlet "remove_self_from_page" procs.
    The inverse of the above proc.

    Removes the given parameters from all the portlets
    of this type on the given page. If by removing this param,
    there are no more params (say instace_id's) of this type,
    that means that the portlet has become empty and can be

    @param portal_id The portal page to act on
    @param portlet_name The name of the portlet to (maybe) remove
    @param key the key for the value (defaults to package_id)
    @param value the value of the key
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
                -value $value

            if {$extra_params ne ""} {
                check_key_value_list $extra_params

                for {set x 0} {$x < [llength $extra_params]} {incr x 2} {

                    remove_element_param_value -element_id $element_id \
                        -key [lindex $extra_params $x] \
                        -value [lindex $extra_params $x+1]
                }
            }
        }
    }

    # step 2: Check if we should really remove the element
    db_transaction {
        foreach element_id $element_ids {
            if {[llength [get_element_param_list \
                    -element_id $element_id \
                -key $key]] == 0} {
                remove_element -element_id $element_id
            }
        }
    }
}

ad_proc -private portal::check_key_value_list {
    list_to_check
} {
    rat-simple consistency check for the above 2 procs
} {
    if {[llength $list_to_check] % 2 != 0} {
        ns_log error "portal::check_key_value_list bad var list_to_check!"
        ad_return_complaint 1 "portal::check_key_value_list bad var list_to_check!"
        ad_script_abort
    }
}

ad_proc -public portal::show_proc_helper {
    {-template_src ""}
    {-package_key:required}
    {-config_list:required}
} {
    hides ugly templating calls for portlet "show" procs
} {

    if { $template_src eq ""} {
        set template_src $package_key
    }

    # some stupid upvar tricks to get them set right
    upvar __ts ts
    set ts $template_src

    upvar __pk pk
    set pk $package_key

    upvar __cflist cflist
    set cflist $config_list

    ns_log Debug "portal::show_proc_helper - package_key=$package_key, template=$template_src"

    uplevel 1 {
        set template "<include src=\"$__ts\" cf=\"$__cflist\">"
        set __adp_stub "[acs_root_dir]/packages/$__pk/www/."
        set code [template::adp_compile -string $template]
        set output [template::adp_eval code]
        return $output
    }
}

ad_proc -public portal::get_theme_id {
    {-portal_id:required}
} {
    self explanatory
} {
    return [db_string get_theme_id_select {}]
}

ad_proc -public portal::get_theme_id_from_name {
    {-theme_name:required}
} {
    self explanatory
} {
    if { [db_0or1row get_theme_id_from_name_select {} ]} {
        return $theme_id
    } else {
        ns_log error "portal::get_theme_id_from_name_select bad theme_id!"
        ad_return_complaint 1 "portal::get_theme_id_from_name_select bad theme_id!"
        ad_script_abort
    }

}

ad_proc -private portal::get_theme_info {
} {
    Returns a list of all the themes in the system as ns_sets with
    keys being: theme_id, name, description
} {
    return [util_memoize "portal::get_theme_info_not_cached"]
}

ad_proc -private portal::get_theme_info_not_cached {
} {
    Memoizing helper
} {
    return [db_list_of_ns_sets get_theme_info_select {}]
}

ad_proc portal::dimensional {
    {-no_header:boolean}
    {-no_bars:boolean}
    {-link_all 0}
    {-names_in_cells_p 1}
    {-th_bgcolor "#ECECEC"}
    {-td_align "center"}
    {-extra_td_html ""}
    {-table_html_args "border=0 cellspacing=0 cellpadding=3 width=100%"}
    {-class_html ""}
    {-pre_html ""}
    {-post_html ""}
    {-extra_td_selected_p 0}
    option_list
    {url {}}
    {options_set ""}
    {optionstype url}
} {
    An enhanced ad_dimensional. see that proc for usage details
} {
    if {$option_list eq ""} {
        return
    }

    if {$options_set eq ""} {
        set options_set [ns_getform]
    }

    if {$url eq ""} {
        set url [ad_conn url]
    }

    set html "\n<table $table_html_args>\n"

    if {!$no_header_p} {
        foreach option $option_list {
            append html "<tr>    <th bgcolor=\"$th_bgcolor\">[lindex $option 1]</th>\n"
        }
    }

    append html "  <tr>\n"

    foreach option $option_list {

        if {!$no_bars_p} {
            append html "\["
        }


        if { $names_in_cells_p } {
            set pre_td_html "<td class=\"navbar\">"
            set pre_selected_td_html "<td class=\"navbar-selected\">"
            set post_html "$post_html</a></td>"
            set end_html ""
            set break_html ""
            set post_selected_html "$post_html"
        } else {
            append html "    <td align=$td_align>"
            set td_html ""
            set pre_selected_td_html "<strong>"
            set post_selected_html "</strong>$post_html"
            set end_html ""
            set td_html ""
            post_html "$post_html</a>"
            if {!$no_bars_p} {
                set break_html " | "
            } else {
                append break_html " &nbsp; "
            }
        }

        # find out what the current option value is.
        # check if a default is set otherwise the first value is used
        lassign $option option_key . option_val
        if {$options_set ne ""} {
            set options_set_val [ns_set get $options_set $option_key]
            if { $options_set_val ne "" } {
                set option_val $options_set_val
            }
        }

        set first_p 1
        foreach option_value [lindex $option 3] {
            set thisoption_name [lindex $option_value 0]
            # We allow portal page names to have embedded message catalog keys
            # that we localize on the fly
            set thisoption_value [ns_quotehtml [lang::util::localize [lindex $option_value 1]]]
            set thisoption_link_p 1
            if {[llength $option_value] > 3} {
                set thisoption_link_p [lindex $option_value 3]
            }

            if {$first_p} {
                set first_p 0
            } else {
                append html $break_html
            }

            if {($option_val eq $thisoption_name && !$link_all) || !$thisoption_link_p} {
                append html "${pre_selected_td_html}${pre_html}${thisoption_value}${post_selected_html}\n"
            } else {
                set href "$url?[export_ns_set_vars url $option_key $options_set]&[ns_urlencode $option_key]=[ns_urlencode $thisoption_name]"
                append html [subst {
                    ${pre_td_html}<a href="[ns_quotehtml $href]">${pre_html}${thisoption_value}${post_html}
                }]
            }
        }

        if {!$no_bars_p} {
            append html "\]"
        }
        if {$extra_td_selected_p} {
            append html "${pre_selected_td_html}${pre_html}$extra_td_html${post_html}\n"
        } else {
            append html "${pre_td_html}$extra_td_html${post_html}\n"
        }
    }

    append html "  </tr>\n$end_html</table>\n"
}

ad_proc portal::set_page_css {
    resource_dir
} {
    Set the CSS in the HTML head tag for the given resource dir.
    This proc is to be called from the layout templates.
} {

    if { [string first /resources/ $resource_dir] == 0 } {
        set l [split $resource_dir /]
        set path [acs_package_root_dir [lindex $l 2]]/www/resources/[join [lrange $l 3 end] /]
    } else {
        set path [acs_package_root_dir new-portal]/www/$resource_dir
    }

    foreach file [file tail [glob -nocomplain -directory $path *.css]] {
        template::head::add_css -href $resource_dir/$file
    }

}

ad_proc portal::portlet_visible_p {
    -portal_id
    -portlet_name
} {
    Check if a portlet is on a portal

    @param portal_id ID of portal to check
    @param portlet_name Name of the portlet to look for

    @return 0 if portlet does not exist, 1 if it exists

} {
    set ds_id [get_datasource_id $portlet_name]
    if {[db_string portlet_visible "" -default 0]} {
        return 1
    } else {
        return 0
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
