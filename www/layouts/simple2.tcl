# www/templates/simple2.tcl
ad_page_contract {
    @cvs_id $Id$
} -properties {
    element_list:onevalue
    element_src:onevalue
    action_string:onevalue
}

if { ![info exists action_string]} {
    set action_string ""
}

portal::layout_elements $element_list
