-- The New Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- arjun@openforce.net
-- $Id$

-- datasources

select  acs_object_type__create_type ( 
    /* object_type   */ 'portal_datasource',
    /* pretty_name   */ 'Portal Data Source',
    /* pretty_plural */ 'Portal Data Sources',
    /* supertype     */ 'acs_object',
    /* table_name    */ 'PORTAL_DATASOURCES',
    /* id_column     */ 'DATASOURCE_ID',
    /* package_name  */ 'portal_datasource',
    /* abstract_p    */ 'f',
    /* type_extension_table */ null,
    /* name_method   */ null
  ); 

-- datasource attributes

select acs_attribute__create_attribute ( 
    /* object_type    */ 'portal_datasource', 
    /* attribute_name */ 'NAME',  
    /* datatype       */ 'string',
    /* pretty_name    */ 'Name', 
    /* pretty_plural  */ 'Names', 
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  ); 

select acs_attribute__create_attribute ( 
    /* object_type    */ 'portal_datasource', 
    /* attribute_name */ 'DESCRIPTION',
    /* datatype       */ 'string', 
    /* pretty_name    */ 'Description', 
    /* pretty_plural  */ 'Descriptions',
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'  
  ); 

select acs_attribute__create_attribute ( 
    /* object_type    */ 'portal_datasource', 
    /* attribute_name */ 'CONTENT', 
    /* datatype       */ 'string',
    /* pretty_name    */ 'Content', 
    /* pretty_plural  */ 'Contents', 
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  );



-- portal_layouts
  
select  acs_object_type__create_type (
    /* object_type   */ 'portal_layout',
    /* pretty_name   */ 'Portal Layout',
    /* pretty_plural */ 'Portal Layouts',
    /* supertype     */ 'acs_object',
    /* table_name    */ 'PORTAL_LAYOUTS',
    /* id_column     */ 'LAYOUT_ID',
    /* package_name  */ 'portal_layout',
    /* abstract_p    */ 'f',
    /* type_extension_table */ null,
    /* name_method   */ null
  );


-- and its attributes
select acs_attribute__create_attribute ( 
    /* object_type    */ 'portal_layout', 
    /* attribute_name */ 'NAME',
    /* datatype       */ 'string', 
    /* pretty_name    */ 'Name', 
    /* pretty_plural  */ 'Names', 
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  ); 

select acs_attribute__create_attribute ( 
    /* object_type    */ 'portal_layout', 
    /* attribute_name */ 'DESCRIPTION',
    /* datatype       */ 'string', 
    /* pretty_name    */ 'Description', 
    /* pretty_plural  */ 'Descriptions', 
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  ); 

select acs_attribute__create_attribute ( 
    /* object_type    */ 'portal_layout', 
    /* attribute_name */ 'TYPE', 
    /* datatype       */ 'string',
    /* pretty_name    */ 'Type', 
    /* pretty_plural  */ 'Types', 
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  ); 

select acs_attribute__create_attribute (
    /* object_type    */ 'portal_layout',
    /* attribute_name */ 'FILENAME',
    /* datatype       */ 'string',
    /* pretty_name    */ 'Filename',
    /* pretty_plural  */ 'Filenames',
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  ); 

select acs_attribute__create_attribute (
    /* object_type    */ 'portal_layout',
    /* attribute_name */ 'resource_dir',
    /* datatype       */ 'string',
    /* pretty_name    */ 'Resource Directory',
    /* pretty_plural  */ 'Resource Directory',
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  ); 

-- portal_element_themes  
select  acs_object_type__create_type (
    /* object_type   */ 'portal_element_theme',
    /* pretty_name   */ 'Portal Element Theme',
    /* pretty_plural */ 'Portal Element Themes',
    /* supertype     */ 'acs_object',
    /* table_name    */ 'PORTAL_THEMES',
    /* id_column     */ 'THEME_ID',
    /* package_name  */ 'portal_themes',
    /* abstract_p    */ 'f',
    /* type_extension_table */ null,
    /* name_method   */ null
  );

-- and its attributes
select acs_attribute__create_attribute ( 
    /* object_type    */ 'portal_element_theme', 
    /* attribute_name */ 'NAME', 
    /* datatype       */ 'string',
    /* pretty_name    */ 'Name', 
    /* pretty_plural  */ 'Names', 
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  ); 

select acs_attribute__create_attribute ( 
    /* object_type    */ 'portal_element_theme', 
    /* attribute_name */ 'DESCRIPTION', 
    /* datatype       */ 'string', 
    /* pretty_name    */ 'Description', 
    /* pretty_plural  */ 'Descriptions',
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  ); 

select acs_attribute__create_attribute ( 
    /* object_type    */ 'portal_element_theme', 
    /* attribute_name */ 'TYPE', 
    /* datatype       */ 'string',
    /* pretty_name    */ 'Type', 
    /* pretty_plural  */ 'Types', 
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  ); 

select acs_attribute__create_attribute (
    /* object_type    */ 'portal_element_theme',
    /* attribute_name */ 'FILENAME',
    /* datatype       */ 'string',
    /* pretty_name    */ 'Filename',
    /* pretty_plural  */ 'Filenames',
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  ); 

select acs_attribute__create_attribute (
    /* object_type    */ 'portal_element_theme',
    /* attribute_name */ 'resource_dir',
    /* datatype       */ 'string',
    /* pretty_name    */ 'Resource Directory',
    /* pretty_plural  */ 'Resource Directory',
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  );


-- portal  
select  acs_object_type__create_type ( 
    /* object_type   */ 'portal', 
    /* pretty_name   */ 'Portal', 
    /* pretty_plural */ 'Portals', 
    /* supertype     */ 'acs_object', 
    /* table_name    */ 'PORTALS', 
    /* id_column     */ 'PORTAL_ID',
    /* package_name  */ 'portal',
    /* abstract_p    */ 'f',
    /* type_extension_table */ null,
    /* name_method   */ null
  ); 

select acs_attribute__create_attribute ( 
    /* object_type    */ 'portal', 
    /* attribute_name */ 'NAME', 
    /* datatype       */ 'string', 
    /* pretty_name    */ 'Name', 
    /* pretty_plural  */ 'Names',
    /* table_name     */ null,                
    /* column_name    */ null,
    /* default_value  */ null,
    /* mix_n_values   */ 1,
    /* max_n_values   */ 1,
    /* sort_order     */ null,
    /* storage        */ 'type_specific',
    /* static_p       */ 'f'
  );


-- portal_page  
select acs_object_type__create_type (  
    /* object_type   */ 'portal_page', 
    /* pretty_name   */ 'Portal Page', 
    /* pretty_plural */ 'Portal Pages',
    /* supertype     */ 'acs_object', 
    /* table_name    */ 'PORTAL_PAGES', 
    /* id_column     */ 'page_id',
    /* package_name  */ 'portal_page',
    /* abstract_p    */ 'f',
    /* type_extension_table */ null,
    /* name_method   */ null
  );
