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
-- $Id$
--


-- Insert some default templates.
create function inline_0() 
returns integer as ' 
begin
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

