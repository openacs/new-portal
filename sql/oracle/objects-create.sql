-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- arjun@openforce.net
-- $Id$

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
 attr_id acs_attributes.attribute_id%TYPE; 
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

  attr_id := acs_attribute.create_attribute ( 
    object_type    => 'portal_datasource', 
    attribute_name => 'CONTENT', 
    pretty_name    => 'Content', 
    pretty_plural  => 'Contents', 
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
 attr_id acs_attributes.attribute_id%TYPE; 
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
    attribute_name => 'TYPE', 
    pretty_name    => 'Type', 
    pretty_plural  => 'Types', 
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
    table_name    => 'PORTAL_THEMES',
    id_column     => 'THEME_ID',
    package_name  => 'portal_themes'
  );
end;
/
show errors;

-- and its attributes
declare 
 attr_id acs_attributes.attribute_id%TYPE; 
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
    attribute_name => 'TYPE', 
    pretty_name    => 'Type', 
    pretty_plural  => 'Types', 
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
 attr_id acs_attributes.attribute_id%TYPE; 
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
