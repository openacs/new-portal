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

# get the complete, evaluated element.
# if there's an error, report it.
if { [catch {set element_data [portal::evaluate_element $element_id $theme_id] } errmsg ] } {
    
    ns_log Error "aks18 render-element.tcl (after eval): $errmsg"
    
    if { [ad_parameter show_datasource_errors_p] == 1} {
	set element(content) "<div class=portal_alert>$errmsg</div>"
    } else {
	return
    }
} else {
    array set element $element_data
}

# Added by Ben to bypass rendering if there's nada"
if {[empty_string_p [string trim $element(content)]]} {
    set empty_p 1
} else {
    set empty_p 0
} 

ad_return_template


