--
-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- Arjun Sanyal (arjun@openforce.net)
-- $Id$
--


-- ampersands break if I don't do this.
-- set scan off

-- Insert some default templates.
create function inline_0 ()
returns integer as '
declare
	layout_id	portal_layouts.layout_id%TYPE;
	theme_id	portal_element_themes.theme_id%TYPE;
begin


-- two-column layout, without a header.
	layout_id := portal_layout__new (
		/* name */ ''Simple 2-Column'',
		/* description */ ''A simple 2-column layout'',
		/* filename */ ''layouts/simple2'',
		/* resource_dir */ ''layouts/components/simple2'');

-- the supported regions for that layout.
	perform portal_layout__add_region (/* layout_id */ layout_id, /* region */ ''1'');
	perform portal_layout__add_region (/* layout_id */ layout_id, /* region */ ''2'');

-- one-column layout, without a header.
	layout_id := portal_layout__new (
		/* name */ ''Simple 1-Column'',
		/* description */ ''A simple 1-column layout'',
		/* filename */ ''layouts/simple1'',
		/* resource_dir */ ''layouts/components/simple1'');

-- the supported regions for that layout.
	perform portal_layout__add_region (/* layout_id */ layout_id, /* region */ ''1'');

-- same as above, only, three columns.
	layout_id := portal_layout__new (
		/* name */ ''Simple 3-Column'',
		/* description */ ''A simple 3-column layout'',
		/* filename */ ''layouts/simple3'',
		/* resource_dir */ ''layouts/components/simple3'');

	perform portal_layout__add_region (/* layout_id */ layout_id, /* region */ ''1'');
	perform portal_layout__add_region (/* layout_id */ layout_id, /* region */ ''2'');
	perform portal_layout__add_region (/* layout_id */ layout_id, /* region */ ''3'');

-- Now, some element themes.

	theme_id := portal_element_theme__new (
		/* name */ ''simple'',
		/* description */ ''A simple red table-based theme'',
		/* filename */ ''themes/simple-theme'',
		/* resource_dir */ ''themes/simple-theme'');

	theme_id := portal_element_theme__new (
		/* name */ ''nada'',
		/* description */ ''The un-theme. No graphics.'',
		/* filename */ ''themes/nada-theme'',
		/* resource_dir */ ''themes/nada-theme'');

	theme_id := portal_element_theme__new (
		/* name */ ''deco'',
		/* description */ ''An Art Deco theme'',
		/* filename */ ''themes/deco-theme'',
		/* resource_dir */ ''themes/deco-theme'');

    return 0;

end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();
