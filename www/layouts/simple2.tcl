# www/templates/simple2.tcl
ad_page_contract {
    @cvs_id $Id$
} {
    {element_list:trim,optional ""}
    {element_src:trim,optional ""}
    {theme_id:integer,optional ""}
    {action_string:trim,optional ""}

} -properties {
    element_list:onevalue
    element_src:onevalue
    action_string:onevalue
    theme_id:onevalue
}


portal::layout_elements $element_list
