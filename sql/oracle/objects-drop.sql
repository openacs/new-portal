--
-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- Arjun Sanyal (arjun@openforce.net)
-- $Id$
--

-- XXX - FIX ME Do this the "right way"

delete from acs_permissions where object_id in (
	(select object_id from acs_objects where object_type in (
	'portal', 'portal_element_theme','portal_layout', 'portal_datasource'
	))
);

delete from acs_permissions where object_id in (
	(select package_id from apm_packages where package_key = 'portal')
);

delete from acs_objects where object_type in (
	'portal', 'portal_element_theme','portal_layout', 'portal_datasource'
);

begin
	acs_object_type.drop_type('portal');
	acs_object_type.drop_type('portal_element_theme');
	acs_object_type.drop_type('portal_layout');
	acs_object_type.drop_type('portal_datasource');
end;
/
show errors
