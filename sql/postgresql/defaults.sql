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
begin

    -- two-column layout, without a header.
    layout_id := portal_layout__new(
        ''Simple 2-Column'',
        ''A simple 2-column layout'',
        ''layouts/simple2'',
        ''layouts/components/simple2''
    );

    -- the supported regions for that layout.
    perform portal_layout__add_region(layout_id, ''1'');
    perform portal_layout__add_region(layout_id, ''2'');

    -- one-column layout, without a header.
    layout_id := portal_layout__new(
        ''Simple 1-Column'',
        ''A simple 1-column layout'',
        ''layouts/simple1'',
        ''layouts/components/simple1''
    );

    -- the supported regions for that layout.
    perform portal_layout__add_region(layout_id, ''1'');

    -- same as above, only, three columns.
    layout_id := portal_layout__new(
        ''Simple 3-Column'',
        ''A simple 3-column layout'',
        ''layouts/simple3'',
        ''layouts/components/simple3''
    );

    perform portal_layout__add_region(layout_id, ''1'');
    perform portal_layout__add_region(layout_id, ''2'');
    perform portal_layout__add_region(layout_id, ''3'');

    -- Now, some element themes.
    perform portal_element_theme__new(
        ''simple'',
        ''A simple red table-based theme'',
        ''themes/simple-theme'',
        ''themes/simple-theme''
    );

    perform portal_element_theme__new(
        ''nada'',
        ''The un-theme. No graphics.'',
        ''themes/nada-theme'',
        ''themes/nada-theme''
    );

    perform portal_element_theme__new(
        ''deco'',
        ''An Art Deco theme'',
        ''themes/deco-theme'',
        ''themes/deco-theme''
    );

    perform portal_element_theme__new (
              ''Sloan'',    -- name
              ''MIT Sloan theme'', -- description
              ''themes/sloan-theme'', -- filename
              ''themes/sloan-theme'' -- directory
            );

    return 0;

end;' language 'plpgsql';

select inline_0();

drop function inline_0();
