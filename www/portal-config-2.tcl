# www/element-layout-2.tcl
ad_page_contract {
    Do the actual moving/removing of the elements, or redirect to add.

    @author Arjun Sanyal
    @creation-date 9/28/2001
    @cvs_id $Id$
} {
    portal_id:naturalnum,notnull,permission(write)
    {element_ids:naturalnum,multiple,optional ""}
}

# What did the user want to do?  It's necessary to access the query
# string directly here, because we don't know for sure what the
# parameter is called, and you need to know that sort of thing for
# ad_page_contract to work.

# aks: region here is the "target" region
if { ! [regexp {[\?&](add|move|remove)_(i?\d+)} [ad_conn query] match mode region ]} {
    ad_return_complaint 1 "No mode.  (region $region, mode $mode, match $match, query [ad_conn query])"
} else { ns_log Notice "AKS: mode is $mode" }

set layout_id [portal::get_layout_id $portal_id]
portal::get_regions $layout_id

if { [portal::region_immutable_p $region] } {
    ad_return_complaint 1 "You don't have permission to manipulate this region."
    return
}
set skip_region_sql " m.region not like 'i%' and "


if { $mode == "add" } {
    ad_returnredirect "element-add?[export_url_vars portal_id region]"
}


# AFAIK, this can't be done nicely with bind variables.  there's no
# need to check $element_ids for nasty things, since the
# ad_page_contract filter should only let in positive numbers...
#
# The larger apparent security problem, that of a user providing valid
# element_ids to add elements to which he doesn't have access to his
# portal, isn't an issue since permission on the elements must be
# checked every time they're loaded anyway.
#
# - AKS: we are not going the route above.

set element_id_list $element_ids

if { $mode == "remove" && ! [empty_string_p $element_id_list] } {
    if { [ad_parameter local_remove_p] } {
	db_dml remove_elements_region "delete from portal_element_map m
          where m.portal_id = :portal_id and
          m.region = :region and
          $skip_region_sql
          m.element_id in ($element_id_list)"
    } else {
	db_dml remove_elements_all "delete from portal_element_map m
          where m.portal_id = :portal_id and
          $skip_region_sql
          m.element_id in ($element_id_list)"
    }
}

if { $mode == "move" && ! [empty_string_p $element_id_list] } {

    portal::move_elements $portal_id $element_id_list $region 

} elseif { $mode == "move" && [empty_string_p $element_id_list] } {

    ns_returnredirect "portal-config.tcl?[export_url_vars portal_id]"
}

ns_returnredirect "portal-config.tcl?[export_url_vars portal_id]"
