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
    Add porlet form

    @author Caroline@meekshome.com
    @creation-date 9/28/2001
    @cvs_id $Id$
} -properties {
    region:onevalue
    action_string:onevalue
    portal_id:onevalue
}

# generate some html for the hidden elements
set show_avail_p 0
set show_html ""

append show_html "<select name=element_id>"

foreach element [portal::hidden_elements_list_not_cached -portal_id $portal_id] {
    set show_avail_p 1
    append show_html "<option value=\"[ad_quotehtml [lindex $element 0]]\">[ad_quotehtml [lang::util::localize [lindex $element 1]]]</option>\n"
}

set imgdir "[portal::mount_point]/place-element-components"        
set location [ad_conn location]



