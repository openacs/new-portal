--
--  Copyright (C) 2001, 2002 OpenForce, Inc.
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

	theme_id := portal_element_theme.new (
		name => 'Sloan',
		description => 'MIT Sloan theme',
		filename => 'themes/sloan-theme',
		resource_dir => 'themes/sloan-theme');


end;
/





