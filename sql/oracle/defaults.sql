--
-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- Arjun Sanyal (arjun@openforce.net)
-- $Id$
--


-- ampersands break if I don't do this.
set scan off

-- Insert some default templates.
declare
	layout_id	portal_layouts.layout_id%TYPE;
	theme_id	portal_element_themes.theme_id%TYPE;
begin

-- two-column layout, without a header.
	layout_id := portal_layout.new (
		name => 'Simple 1-Column',
		description => 'A simple 1-column layout',
		filename => 'layouts/simple1',
		resource_dir => 'layouts/components/simple1');

-- the supported regions for that layout.
	portal_layout.add_region (layout_id => layout_id, region => '1');

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
		name => 'simple',
		description => 'A simple red table-based theme',
		filename => 'themes/simple-theme',
		resource_dir => 'themes/simple-theme');

	theme_id := portal_element_theme.new (
		name => 'nada',
		description => 'The un-theme. No graphics.',
		filename => 'themes/nada-theme',
		resource_dir => 'themes/nada-theme');

	theme_id := portal_element_theme.new (
		name => 'deco',
		description => 'An Art Deco theme',
		filename => 'themes/deco-theme',
		resource_dir => 'themes/deco-theme');


end;
/

