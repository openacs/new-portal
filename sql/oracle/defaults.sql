--
--  Copyright(C) 2001, 2002 MIT
--
--  This file is part of dotLRN.
--
--  dotLRN is free software; you can redistribute it and/or modify it under the
--  terms of the GNU General Public License as published by the Free Software
--  Foundation; either version 2 of the License, or(at your option) any later
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
-- @author Arjun Sanyal(arjun@openforce.net)
-- @version $Id$
--

-- ampersands break if I don't do this.
set scan off

declare
    layout_id                       portal_layouts.layout_id%TYPE;
    theme_id                        portal_element_themes.theme_id%TYPE;
begin

    -- two-column layout, without a header.
    layout_id := portal_layout.new(
        name => '#new-portal.simple_2column_layout_name#',
        description => '#new-portal.simple_2column_layout_description#',
        filename => 'layouts/simple2',
        resource_dir => 'layouts/components/simple2'
    );

    -- the supported regions for that layout.
    portal_layout.add_region(layout_id => layout_id, region => '1');
    portal_layout.add_region(layout_id => layout_id, region => '2');

    -- one-column layout, without a header.
    layout_id := portal_layout.new(
        name => '#new-portal.simple_1column_layout_name#',
        description => '#new-portal.simple_1column_layout_description#',
        filename => 'layouts/simple1',
        resource_dir => 'layouts/components/simple1'
    );

    -- the supported regions for that layout.
    portal_layout.add_region(layout_id => layout_id, region => '1');

    -- same as above, only, three columns.
    layout_id := portal_layout.new(
        name => '#new-portal.simple_3column_layout_name#',
        description => '#new-portal.simple_3column_layout_description#',
        filename => 'layouts/simple3',
        resource_dir => 'layouts/components/simple3'
    );

    portal_layout.add_region(layout_id => layout_id, region => '1');
    portal_layout.add_region(layout_id => layout_id, region => '2');
    portal_layout.add_region(layout_id => layout_id, region => '3');

    -- Now, some element themes.
    theme_id := portal_element_theme.new(
        name => '#new-portal.simple_red_theme_name#',
        description => '#new-portal.simple_red_theme_description#',
        filename => 'themes/simple-theme',
        resource_dir => 'themes/simple-theme'
    );

    theme_id := portal_element_theme.new(
        name => '#new-portal.nada_theme_name#',
        description => '#new-portal.nada_theme_description#',
        filename => 'themes/nada-theme',
        resource_dir => 'themes/nada-theme'
    );

    theme_id := portal_element_theme.new(
        name => '#new-portal.deco_theme_name#',
        description => '#new-portal.deco_theme_description#',
        filename => 'themes/deco-theme',
        resource_dir => 'themes/deco-theme'
    );

    theme_id := portal_element_theme.new (
        name => '#new-portal.sloan_theme_name#',
        description => '#new-portal.sloan_theme_description#',
        filename => 'themes/sloan-theme',
        resource_dir => 'themes/sloan-theme');

    theme_id := portal_element_theme.new (
        name => 'KELP',
        description => 'Knowledge E-Learning Portal',
        filename => 'themes/kelp-theme',
        resource_dir => 'themes/kelp-theme');

end;
/
show errors
