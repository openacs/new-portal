# www/element-layout.tcl

ad_page_contract {
    Generate a page with the same layout as the portal, for editing.

    @author Ian Baker (ibaker@arsdigita.com)
    @creation-date 12/6/2000
    @cvs-id $Id$
} {
    portal_id:naturalnum,notnull,object_write
}

set user_id [ad_conn user_id]
set master_template [ad_parameter master_template]

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
set element_src "[portal::portal_path]/www/place-element"

ad_return_template
