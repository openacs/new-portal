# www/element-layout.tcl

ad_page_contract {
    Generate a page with the same layout as the portal, for editing.

    @author Ian Baker (ibaker@arsdigita.com)
    @creation-date 12/6/2000
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
order by name" {

    set resource_dir "$resource_dir"

    # this is evil and broken.  
    # I should be able to pass it a list, straight from db_list.
    template::multirow append layouts $layout_id $name $description $filename $resource_dir $checked
    incr layout_count
}

set title "Edit Your Portal"

# the portal we're editing exists.  Return it.
db_1row get_portal "select
name,
layout_id
from portals
where portal_id = :portal_id"

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
