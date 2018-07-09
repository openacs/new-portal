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
-- The New Portal Package
--
-- @author arjun@openforce.net
-- @version $Id$
--

-- datasources
begin  
    acs_object_type.create_type ( 
        supertype     => 'acs_object',
        object_type   => 'portal_datasource',
        pretty_name   => 'Portal Data Source',
        pretty_plural => 'Portal Data Sources',
        table_name    => 'PORTAL_DATASOURCES',
        id_column     => 'DATASOURCE_ID',
        package_name  => 'portal_datasource'
    ); 
end;
/
show errors;

-- datasource attributes
declare 
    attr_id                         acs_attributes.attribute_id%TYPE; 
begin

    attr_id := acs_attribute.create_attribute ( 
        object_type    => 'portal_datasource', 
        attribute_name => 'NAME', 
        pretty_name    => 'Name', 
        pretty_plural  => 'Names', 
        datatype       => 'string' 
    ); 

    attr_id := acs_attribute.create_attribute ( 
        object_type    => 'portal_datasource', 
        attribute_name => 'DESCRIPTION', 
        pretty_name    => 'Description', 
        pretty_plural  => 'Descriptions', 
        datatype       => 'string' 
    ); 

end; 
/ 
show errors;

-- portal_layouts
begin  
    acs_object_type.create_type (
        supertype     => 'acs_object',
        object_type   => 'portal_layout',
        pretty_name   => 'Portal Layout',
        pretty_plural => 'Portal Layouts',
        table_name    => 'PORTAL_LAYOUTS',
        id_column     => 'LAYOUT_ID',
        package_name  => 'portal_layout'
    );
end;
/
show errors;

-- and its attributes
declare 
    attr_id                         acs_attributes.attribute_id%TYPE; 
begin

    attr_id := acs_attribute.create_attribute ( 
        object_type    => 'portal_layout', 
        attribute_name => 'NAME', 
        pretty_name    => 'Name', 
        pretty_plural  => 'Names', 
        datatype       => 'string' 
    ); 

    attr_id := acs_attribute.create_attribute ( 
        object_type    => 'portal_layout', 
        attribute_name => 'DESCRIPTION', 
        pretty_name    => 'Description', 
        pretty_plural  => 'Descriptions', 
        datatype       => 'string' 
    ); 

    attr_id := acs_attribute.create_attribute (
        object_type    => 'portal_layout',
        attribute_name => 'FILENAME',
        pretty_name    => 'Filename',
        pretty_plural  => 'Filenames',
        datatype       => 'string'
    ); 

    attr_id := acs_attribute.create_attribute (
        object_type    => 'portal_layout',
        attribute_name => 'resource_dir',
        pretty_name    => 'Resource Directory',
        pretty_plural  => 'Resource Directory',
        datatype       => 'string'
    ); 

end; 
/ 
show errors;

-- poratal_element_themes
begin  
    acs_object_type.create_type (
        supertype     => 'acs_object',
        object_type   => 'portal_element_theme',
        pretty_name   => 'Portal Element Theme',
        pretty_plural => 'Portal Element Themes',
        table_name    => 'PORTAL_ELEMENT_THEMES',
        id_column     => 'THEME_ID',
        package_name  => 'portal_element_theme'
    );
end;
/
show errors;

-- and its attributes
declare 
    attr_id                         acs_attributes.attribute_id%TYPE; 
begin

    attr_id := acs_attribute.create_attribute ( 
        object_type    => 'portal_element_theme', 
        attribute_name => 'NAME', 
        pretty_name    => 'Name', 
        pretty_plural  => 'Names', 
        datatype       => 'string' 
    ); 

    attr_id := acs_attribute.create_attribute ( 
        object_type    => 'portal_element_theme', 
        attribute_name => 'DESCRIPTION', 
        pretty_name    => 'Description', 
        pretty_plural  => 'Descriptions', 
        datatype       => 'string' 
    ); 

    attr_id := acs_attribute.create_attribute (
        object_type    => 'portal_element_theme',
        attribute_name => 'FILENAME',
        pretty_name    => 'Filename',
        pretty_plural  => 'Filenames',
        datatype       => 'string'
    ); 

    attr_id := acs_attribute.create_attribute (
        object_type    => 'portal_element_theme',
        attribute_name => 'resource_dir',
        pretty_name    => 'Resource Directory',
        pretty_plural  => 'Resource Directory',
        datatype       => 'string'
    ); 

end; 
/ 
show errors;

-- portal
begin  
    acs_object_type.create_type ( 
        supertype     => 'acs_object', 
        object_type   => 'portal', 
        pretty_name   => 'Portal', 
        pretty_plural => 'Portals', 
        table_name    => 'PORTALS', 
        id_column     => 'PORTAL_ID',
        package_name  => 'portal'
    ); 
end;
/
show errors;

declare 
    attr_id                         acs_attributes.attribute_id%TYPE; 
begin
    attr_id := acs_attribute.create_attribute ( 
        object_type    => 'portal', 
        attribute_name => 'NAME', 
        pretty_name    => 'Name', 
        pretty_plural  => 'Names', 
        datatype       => 'string' 
    );
end; 
/ 
show errors;

-- portal_page
begin  
    acs_object_type.create_type ( 
        supertype     => 'acs_object', 
        object_type   => 'portal_page', 
        pretty_name   => 'Portal Page', 
        pretty_plural => 'Portal Pages', 
        table_name    => 'PORTAL_PAGES', 
        id_column     => 'page_id',
        package_name  => 'portal_page'
    ); 
end;
/
show errors;
