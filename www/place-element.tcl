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
        hideable_p 

set region_count 0

db_foreach select_elements_by_region {} {
    
    template::multirow append element_multi \
	    $element_id \
            $name \
            $sort_key \
            $state \
            [portal::get_element_param $element_id "hideable_p"] \
            $page_id

    incr region_count
}


# generate some html for the hidden elements
set show_avail_p 0
set show_html ""

append show_html "<select name=element_id>"

db_foreach hidden_elements {} {
    set show_avail_p 1
    append show_html "<option value=$element_id>$pretty_name</option>\n"
}

set imgdir "[portal::mount_point]/place-element-components"        
set location [ad_conn location]
