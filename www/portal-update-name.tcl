# www/portal-update-name.tcl
ad_page_contract {
    Update the portal's name
} {
    portal_id:naturalnum,notnull
    new_name:trim,notnull,nohtml
}

portal::update_name $portal_id $new_name

ad_returnredirect "portal-config?[export_url_vars portal_id]"


