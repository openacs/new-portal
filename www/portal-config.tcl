# www/portal-config.tcl

ad_page_contract {
    Main configuration page for a portal

    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 10/20/2001
    @cvs-id $Id$
} {
    portal_id:naturalnum,notnull
}

# Check for permission
ad_require_permission $portal_id portal_read_portal
ad_require_permission $portal_id portal_edit_portal

# Set up some template vars
set master_template [ad_parameter master_template]

# get the layouts
set layout_count 0
template::multirow create layouts layout_id name description filename resource_dir checked

db_foreach get_layouts "
select 
layout_id, 
name, 
description, 
filename, 
resource_dir, 
' ' as checked
from portal_layouts 
order by name "  {
    set resource_dir "$resource_dir"
    # I should be able to pass it a list, straight from db_list.
    template::multirow append layouts $layout_id $name $description $filename $resource_dir $checked
    incr layout_count
}

# get the portal.
db_1row select_portal {
    select
    p.portal_id,
    p.name,
    t.filename as template,
    t.layout_id
    from portals p, portal_layouts t
    where p.layout_id = t.layout_id and p.portal_id = :portal_id
} -column_array portal

# fake some elements so that the <list> in the template has something to do.
foreach region [ portal::get_regions $portal(layout_id) ] {
    # pass the portal_id along here instead of the element_id.
    lappend fake_element_ids($region) $portal_id
}

set element_list [array get fake_element_ids]
set element_src "[portal::www_path]/place-element"

ad_return_template
