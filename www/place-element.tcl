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

ad_page_contract {
    Place elements on the configure page. This template gets its vars
    from the layout template (e.g. simple2.adp) which is sourced
    by portal::configure

    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 9/28/2001
    @cvs_id $Id$
} -properties {
    region:onevalue
    action_string:onevalue
    portal_id:onevalue
    element_multi:multirow
}

set num_regions [portal::get_layout_region_count -layout_id $layout_id]

template::multirow create element_multi \
    element_id \
    name \
    sort_key \
    state \
    hideable_p \
    page_id \
    hide_remove_url \
    move_up_url \
    move_down_url \
    move_right_wa_url \
    move_left_wa_url \
    move_right_url

set region_count 0

db_foreach select_elements_by_region {} {
    set name [lang::util::localize "$name"]    

    # URLs for actions
    set hide_remove_url [export_vars -base $action_string {{anchor $page_id} {op_hide 1} portal_id element_id return_url}]
    set move_up_url [export_vars -base $action_string {{anchor $page_id} {op_swap 1} {direction up} portal_id region element_id page_id return_url}]
    set move_down_url [export_vars -base $action_string {{anchor $page_id} {op_swap 1} {direction down} portal_id region element_id page_id return_url}]
    set move_right_wa_url [export_vars -base $action_string {{anchor $page_id} {op_move 1} {direction right} portal_id element_id region return_url}]
    set move_left_wa_url [export_vars -base $action_string {{anchor $page_id} {op_move 1} {direction left} portal_id element_id region return_url}]
    set move_right_url [export_vars -base $action_string {{op_move 1} {direction right} portal_id element_id region return_url}]

    template::multirow append element_multi \
	    $element_id \
        $name \
        $sort_key \
        $state \
        [portal::hideable_p -element_id $element_id] \
        $page_id \
        $hide_remove_url \
        $move_up_url \
        $move_down_url \
        $move_right_wa_url \
        $move_left_wa_url \
        $move_right_url

    incr region_count
}


# generate some html for the hidden elements
set show_avail_p 0
set show_html ""

append show_html "<select name=element_id>"

foreach element [portal::hidden_elements_list_not_cached -portal_id $portal_id] {
    set show_avail_p 1
    append show_html "<option value=[lindex $element 0]>[lindex $element 1]</option>\n"
}

set imgdir /resources/new-portal/images
set location [ad_conn location]
