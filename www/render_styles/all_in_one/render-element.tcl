# www/render-element.tcl
ad_page_contract {
    Render an element.

    @author Ben Adida
    @creation-date 
    @cvs_id $Id$
} -properties {
    element_id:onevalue
    region:onevalue
}

if { [catch {set element_data [portal::evaluate_element_raw $element_id] }  errmsg ]  } { 
    # An uncaught error happened when trying to evaluate the element.
    # If the error is in the element's "show" proc, the error will
    # be shown in the content of the portlet. This is for errors other
    # than with the "show" proc. 
    ns_log error "\n\n *** Error in portal/www/render_sytles/all_in_one/render-element.tcl \n Uncaught exception when calling portal::evaluate_element \n with element_id $element_id\n\n"
} else {
    # all is ok
    array set element $element_data
}
