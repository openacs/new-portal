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

    @author Ben Adida
    @creation-date 
    @cvs-id $Id$
} -properties {
    element_id:onevalue
    region:onevalue
}

ad_try {
    portal::evaluate_element -portal_id $portal_id -edit_p f $element_id $theme_id

} on error {errorMsg} {
    # An uncaught error happened when trying to evaluate the element.
    # If the error is in the element's "show" proc, the error will
    # be shown in the content of the portlet. This is for errors other
    # than with the "show" proc. 
    ns_log error "\n\n *** Error in portal/www/render_styles/all_in_one/render-element.tcl\n Uncaught exception when calling portal::evaluate_element\n with element_id $element_id\n\n ERROR $errorMsg"
    
    return -code error "error during rendering portal element $element_id (render_style all_in_one)"
} on ok {element_data} {
    # all is ok
    array set element $element_data
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
