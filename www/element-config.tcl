# www/element-config.tcl
ad_page_contract {
    Configure an element then go back to element-add-2
} {
    portal_id:naturalnum,notnull,permission(write)
    name:trim,notnull,nohtml
    region:notnull
    ds_ids:naturalnum,multiple,notnull
    ds_to_configure:naturalnum,notnull
}

# get all the params we need to configure
# order them by if they are optional or not

# show the DS's config page
