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
    @cvs-id $Id$
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

# DRB: We're not actually using these numbers after all.  However, the works done, it
# doesn't hurt anything to keep this code, so in case someone wants to number portlets
# in the future, the code's already here (trust me, it ain't all that easy to figure out
# how to do this)

if { ![info exists element_num] } {
    set element_num 0
} else {
    incr element_num $element_first_num
}

ad_try {
    portal::evaluate_element -portal_id $portal_id -edit_p $edit_p $element_id $theme_id

} on error {errorMsg} {
    # An uncaught error happened when trying to evaluate the element.
    # If the error is in the element's "show" proc, the error will
    # be shown in the content of the portlet. This is for errors other
    # than with the "show" proc. It hides the entire PE
    ns_log error "\n\n *** Error in portal/www/render_styles_/individual/render-element.tcl\n Uncaught exception when calling portal::evaluate_element \n with element_id $element_id. errmsg: $errorMsg\n\n$::errorInfo"

    return -code error "error during rendering portal element $element_id (render_style individual)"
} on ok {element_data} {
    # all is ok
    array set element $element_data
}

# Added by Ben to bypass rendering if there's nada"
if {$element(content) eq ""} {
    set empty_p 1
} else {
    set empty_p 0
} 


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
