# www/index.tcl

ad_page_contract {
    Page that displays a list of the user's portals and gives
    the option to create a new/additional portal

    @author Arjun Sanyal (arjun@openforce.net)
    @creation-date 
    @cvs-id $Id$
} { }


set user_id [ad_conn user_id]
set master_template [ad_parameter master_template]

set query "select 
           portal_id, name 
           from portals"

template::query get_users_portals users_portals multirow $query 

ad_return_template

