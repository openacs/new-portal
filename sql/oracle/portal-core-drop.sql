--
--  Copyright (C) 2001, 2002 MIT
--
--  This file is part of dotLRN.
--
--  dotLRN is free software; you can redistribute it and/or modify it under the
--  terms of the GNU General Public License as published by the Free Software
--  Foundation; either version 2 of the License, or (at your option) any later
--  version.
--
--  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
--  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
--  details.
--

-- 
-- The New Portal Package
--
-- @author arjun@openforce.net
-- @version $Id$
-- 

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

declare
begin
    acs_privilege.remove_child('read','portal_read_portal');
    acs_privilege.remove_child('portal_edit_portal','portal_read_portal');
    acs_privilege.remove_child('portal_admin_portal','portal_edit_portal');
    acs_privilege.remove_child('create','portal_create_portal');
    acs_privilege.remove_child('delete','portal_delete_portal');
    acs_privilege.remove_child('admin','portal_admin_portal');
    acs_privilege.drop_privilege('portal_create_portal');
    acs_privilege.drop_privilege('portal_delete_portal');
    acs_privilege.drop_privilege('portal_read_portal');
    acs_privilege.drop_privilege('portal_edit_portal');
    acs_privilege.drop_privilege('portal_admin_portal');
end;
