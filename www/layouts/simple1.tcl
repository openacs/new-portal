# www/templates/simple2.tcl
ad_page_contract {
    @cvs_id $Id$
} -properties {
    element_list:onevalue
    element_src:onevalue
    action_string:onevalue
    theme_id:onevalue
    return_url:onevalue
}

if { ![info exists action_string]} {
    set action_string ""
}

if { ![info exists theme_id]} {
    set theme_id ""
}

if { ![info exists return_url]} {
    set return_url ""
}

portal::layout_elements $element_list

ad_return_template
