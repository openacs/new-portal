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
--  FOR A PARTICULAR PURPOSE.  See the GNU General Public License foreign key more
--  details.
--

--
-- The New Portal Package
--
-- @author Arjun Sanyal(arjun@openforce.net)
-- @version $Id$
--

create function inline_0 ()
returns integer as '
declare
    layout_id                       portal_layouts.layout_id%TYPE;
    theme_id                        portal_element_themes.theme_id%TYPE;
begin

    -- two-column layout, without a header.
    layout_id := portal_layout__new(
        ''#new-portal.simple_2column_layout_name#'',
        ''#new-portal.simple_2column_layout_description#'',
        ''layouts/simple2'',
        ''layouts/components/simple2''
    );

    -- the supported regions for that layout.
    perform portal_layout__add_region(layout_id, ''1'');
    perform portal_layout__add_region(layout_id, ''2'');

    -- one-column layout, without a header.
    layout_id := portal_layout__new(
        ''#new-portal.simple_1column_layout_name#'',
        ''#new-portal.simple_1column_layout_description#'',
        ''layouts/simple1'',
        ''layouts/components/simple1''
    );

    -- the supported regions for that layout.
    perform portal_layout__add_region(layout_id, ''1'');

    -- same as above, only, three columns.
    layout_id := portal_layout__new(
        ''#new-portal.simple_3column_layout_name#'',
        ''#new-portal.simple_3column_layout_description#'',
        ''layouts/simple3'',
        ''layouts/components/simple3''
    );

    perform portal_layout__add_region(layout_id, ''1'');
    perform portal_layout__add_region(layout_id, ''2'');
    perform portal_layout__add_region(layout_id, ''3'');

    -- Now, some element themes.
    theme_id := portal_element_theme__new(
        ''#new-portal.simple_red_theme_name#'',
        ''#new-portal.simple_red_theme_description#'',
        ''themes/simple-theme'',
        ''themes/simple-theme''
    );

    theme_id := portal_element_theme__new(
        ''#new-portal.nada_theme_name#'',
        ''#new-portal.nada_theme_description#'',
        ''themes/nada-theme'',
        ''themes/nada-theme''
    );

    theme_id := portal_element_theme__new(
        ''#new-portal.deco_theme_name#'',
        ''#new-portal.deco_theme_description#'',
        ''themes/deco-theme'',
        ''themes/deco-theme''
    );

    return 0;

end;' language 'plpgsql';

select inline_0();

drop function inline_0();
