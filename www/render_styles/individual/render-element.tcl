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

# we get element_id, element_num, element_first_num, action_string, theme_id, region, portal_id,
# edit_p, return_url, hide_links_p, page_id, and layout_id from the layout_template

# DRB: With the creation of the accessible Zen theme, portlets are numbered for the
# convenience of reading devices.  The numbering is done by the layout template.  Since
# old layouts (in particular custom ones not part of the standard .LRN release)
# don't number portlets, we check and set a dummy value if it doesn't exist.

if { ![info exists element_num] } {
    set element_num 0
} else {
    incr element_num $element_first_num
}

if { [catch {set element_data [portal::evaluate_element -portal_id $portal_id -edit_p $edit_p $element_id $theme_id] }  errmsg ]  } { 
    # An uncaught error happened when trying to evaluate the element.
    # If the error is in the element's "show" proc, the error will
    # be shown in the content of the portlet. This is for errors other
    # than with the "show" proc. It hides the entire PE
    global errorInfo
    ns_log error "\n\n *** Error in portal/www/render_sytles_/indiviudal/render-element.tcl \n Uncaught exception when calling portal::evaluate_element \n with element_id $element_id. errmsg: $errmsg\n\n$errorInfo"
    array set element {content {}}

} else {
    # all is ok
    array set element $element_data
}

# Added by Ben to bypass rendering if there's nada"
if {[empty_string_p $element(content)]} {
    set empty_p 1
} else {
    set empty_p 0
} 

