--
-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- Arjun Sanyal (arjun@openforce.net)
-- $Id$
--

-- populate the portal_mime_types table.
insert
    into portal_mime_types (name, pretty_name)
    values ('text/html', 'HTML');

insert
    into portal_mime_types (name, pretty_name)
    values ('text/plain', 'Plain Text');

insert
    into portal_mime_types (name, pretty_name)
    values ('application/x-ats', 'ATS Template Ref');

-- populate the portal_data_types table.
--
-- the difference between tcl_proc and tcl_raw is that
-- it's possible to pass parameters to a procedure, so
-- element attributes can be sent to it.

insert
    into portal_data_types (name, pretty_name)
    values ('tcl_proc', 'Tcl Procedure');

insert
    into portal_data_types (name, pretty_name)
    values ('tcl_raw', 'Raw Tcl');

insert
    into portal_data_types (name, pretty_name)
    values ('plsql', 'Oracle PL/SQL Procedure');

insert
    into portal_data_types (name, pretty_name)
    values ('adp', 'AOLserver ADP');

insert
    into portal_data_types (name, pretty_name, secure_p)
    values ('raw', 'Raw Data', 't');

insert
    into portal_data_types (name, pretty_name)
    values ('url', 'URL');


-- ampersands break if I don't do this.
set scan off

-- Insert some default templates.

--- XXX todo fix me not done yet

declare
	template_id	portal_templates.template_id%TYPE;
begin

-- two-column template, without a header.
	template_id := portal_template.new (
		name => 'Simple 2-Column',
		description => 'A simple 2-column layout',
		type => 'layout',
		filename => 'templates/simple2',
		resource_dir => 'templates/components/simple2');

-- the supported regions for that template.
	portal_template.add_region (template_id => template_id, region => '1');
	portal_template.add_region (template_id => template_id, region => '2');

-- same as above, only, three columns.
	template_id := portal_template.new (
		name => 'Simple 3-Column',
		description => 'A simple 3-column layout',
		type => 'layout',
		filename => 'templates/simple3',
		resource_dir => 'templates/components/simple3');

	portal_template.add_region (template_id => template_id, region => '1');
	portal_template.add_region (template_id => template_id, region => '2');
	portal_template.add_region (template_id => template_id, region => '3');

-- three columns with a header.
	template_id := portal_template.new (
		name => '3-column w/ Header',
		description => 'A 3-column layout with a header area.',
		type => 'layout',
		filename => 'templates/header3',
		resource_dir => 'templates/components/header3');

	portal_template.add_region (template_id => template_id, region => '1');
	portal_template.add_region (template_id => template_id, region => '2');
	portal_template.add_region (template_id => template_id, region => '3');
	portal_template.add_region (template_id => template_id, region => 'i1', immutable_p => 't');

-- Now, some element themes.

	template_id := portal_template.new (
		name => 'Simple table-based thing',
		description => 'A test template.  Pretty crappy overall',
		type => 'theme',
		filename => 'templates/simple-element',
		resource_dir => 'templates/components/simple-element');

	portal_template.add_type ( template_id => template_id, mime_type => 'text/html' );
	portal_template.add_type ( template_id => template_id, mime_type => 'text/plain' );
	portal_template.add_type ( template_id => template_id, mime_type => 'application/x-ats' );
end;
/


-- create a test ds.
declare
	datasource_id	portal_datasources.datasource_id%TYPE;
begin
	datasource_id := portal_datasource.new (
		data_type => 'raw',
		mime_type => 'application/x-ats',
		name => 'Portal Connector',
		description => 'Connects the current portal with others at the same level on the site-map.',
		content_varchar => '/packages/portal/www/datasources/connector/connector'
	);

end;
/

commit;
