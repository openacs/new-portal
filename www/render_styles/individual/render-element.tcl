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

# www/render-element.tcl
ad_page_contract {
    Render an element.

    @author 
    @creation-date 
    @cvs_id $Id$
} -properties {
    element_id:onevalue
    region:onevalue
}

# we get element_id, action_string, theme_id, region, portal_id,
# edit_p, return_url, hide_links_p, page_id, and layout_id from the layout_template

if { [catch {set element_data [portal::evaluate_element -portal_id $portal_id -edit_p $edit_p $element_id $theme_id] }  errmsg ]  } { 
    # An uncaught error happened when trying to evaluate the element.
    # If the error is in the element's "show" proc, the error will
    # be shown in the content of the portlet. This is for errors other
    # than with the "show" proc. It hides the entire PE
    ns_log error "\n\n *** Error in portal/www/render_sytles_/indiviudal/render-element.tcl \n Uncaught exception when calling portal::evaluate_element \n with element_id $element_id\n\n"
    array set element {content {}}

} else {
    # all is ok
    array set element $element_data
}

# Added by Ben to bypass rendering if there's nada"
if {[empty_string_p $element(content)]} {
    ns_log Notice "BMA-debug: empty!"
    set empty_p 1
} else {
    set empty_p 0
} 

