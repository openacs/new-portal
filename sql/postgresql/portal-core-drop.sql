-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- arjun@openforce.net
-- 
-- $Id$

-- Reverse order from the creation script

drop sequence portal_element_map_sk_seq;

drop table portal_datasource_avail_map;
drop table portal_element_parameters;
drop table portal_element_map;
drop table portal_pages;
drop table portals;
drop table portal_element_themes;
drop table portal_supported_regions;
drop table portal_layouts;
drop table portal_datasource_def_params;
drop table portal_datasources;

    select acs_privilege__remove_child('read','portal_read_portal');
    select acs_privilege__remove_child('portal_edit_portal','portal_read_portal');
    select acs_privilege__remove_child('portal_admin_portal','portal_edit_portal');
    select acs_privilege__remove_child('create','portal_create_portal');
    select acs_privilege__remove_child('delete','portal_delete_portal');
    select acs_privilege__remove_child('admin','portal_admin_portal');

    select acs_privilege__drop_privilege('portal_create_portal');
    select acs_privilege__drop_privilege('portal_delete_portal');
    select acs_privilege__drop_privilege('portal_read_portal');
    select acs_privilege__drop_privilege('portal_edit_portal');
    select acs_privilege__drop_privilege('portal_admin_portal');



