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
if { [catch {set element_data [portal::evaluate_element $element_id] } errmsg ] } {
    if { [ad_parameter log_datasource_errors_p] } {
	ns_log Error "portal: $errmsg"
    }
    
    if { [ad_parameter show_datasource_errors_p] } {
	set element(content) "<div class=portal_alert>$errmsg</div>"
	set element(mime_type) "text/html"
    } else {
	return
    }
} else {
    array set element $element_data
}

# consistency is good.
set element(region) $region

ns_log notice  "AKS5: element array get : [array get element]"

# return the appropriate template for that element.
# AKS ???
ad_return_template "layouts/mime-types/$element(mime_type_noslash)"

