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

# get the complete, evaluated element.
# if there's an error, report it.
# (note: here we just show the portal element)
if { [catch {set element_data [portal::evaluate_element_raw $element_id] } errmsg ] } {
    
    ns_log Error "aks18 render-element.tcl (after eval): $errmsg"
    return -code error "in render-element: $errmsg"
    
    if { [ad_parameter show_datasource_errors_p] == 1} {
	set element(content) "<div class=portal_alert>$errmsg</div>"
    } else {
	return
    }
} else {
    array set element $element_data
}

ad_return_template

