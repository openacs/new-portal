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

--- XXX fix directories 
--- layouts in www/layouts
--- ?? why /layouts/components? try to get rid of it
--- elements in www/elements
--- ds's in www/datasources


declare
	layout_id	portal_layouts.layout_id%TYPE;
	theme_id	portal_element_themes.theme_id%TYPE;
begin

-- two-column layout, without a header.
	layout_id := portal_layout.new (
		name => 'Simple 2-Column',
		description => 'A simple 2-column layout',
		filename => 'layouts/simple2',
		resource_dir => 'layouts/components/simple2');

-- the supported regions for that layout.
	portal_layout.add_region (layout_id => layout_id, region => '1');
	portal_layout.add_region (layout_id => layout_id, region => '2');

-- same as above, only, three columns.
	layout_id := portal_layout.new (
		name => 'Simple 3-Column',
		description => 'A simple 3-column layout',
		filename => 'layouts/simple3',
		resource_dir => 'layouts/components/simple3');

	portal_layout.add_region (layout_id => layout_id, region => '1');
	portal_layout.add_region (layout_id => layout_id, region => '2');
	portal_layout.add_region (layout_id => layout_id, region => '3');

-- three columns with a header.
	layout_id := portal_layout.new (
		name => '3-column w/ Header',
		description => 'A 3-column layout with a header area.',
		filename => 'layouts/header3',
		resource_dir => 'layouts/components/header3');

	portal_layout.add_region (layout_id => layout_id, region => '1');
	portal_layout.add_region (layout_id => layout_id, region => '2');
	portal_layout.add_region (layout_id => layout_id, region => '3');
	portal_layout.add_region (layout_id => layout_id, region => 'i1', immutable_p => 't');

-- Now, some element themes.

	theme_id := portal_element_theme.new (
		name => 'Simple table-based element theme',
		description => 'A simple element theme.',
		filename => 'themes/simple-theme',
		resource_dir => 'themes/simple-theme/simple-theme');

-- used to just insert into portal_available_mime_type_map

--	portal_theme.add_type ( theme_id => theme_id, mime_type => 'text/html' );
--	portal_theme.add_type ( theme_id => theme_id, mime_type => 'text/plain' );
--	portal_theme.add_type ( theme_id => theme_id, mime_type => 'application/x-ats' );
end;
/


-- create a very simple  ds.

-- XXX path for the content_varchar

declare
	datasource_id	portal_datasources.datasource_id%TYPE;
begin
	datasource_id := portal_datasource.new (
		data_type => 'raw',
		mime_type => 'application/x-ats',
		name => 'NULL datasource',
		description => 'NULL DS for testing',
		content_varchar => '/packages/new-portal/www/datasources/null/null'
	);

end;
/

commit;

-- test ds
declare
	datasource_id	portal_datasources.datasource_id%TYPE;
begin
	datasource_id := portal_datasource.new (
		data_type => 'raw',
		mime_type => 'application/x-ats',
		name => 'Portal Connector',
		description => 'Connects the current portal with others at the same level on the site-map.',
		content_varchar => '/packages/new-portal/www/datasources/connector/connector'
	);

end;
/

commit;
