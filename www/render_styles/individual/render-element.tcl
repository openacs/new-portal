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

if { [catch {set element_data [portal::evaluate_element $element_id $theme_id] } errmsg ] } {
    if { [ad_parameter show_datasource_errors_p] == 1} {
	
        set element(content) "<div class=portal_alert>$errmsg</div>"
    } else {
	return
    }
} else {
    array set element $element_data
}

ns_log notice "aks85 [array get element]"

set bar $element(content)
# odd workaround needed here or else empty_string_p dies sometimes
set foo [string trim $bar]

# Added by Ben to bypass rendering if there's nada"
if {[empty_string_p $foo]} {
    ns_log Notice "BMA-debug: empty!"
    set empty_p 1
} else {
    set empty_p 0
} 

ad_return_template


