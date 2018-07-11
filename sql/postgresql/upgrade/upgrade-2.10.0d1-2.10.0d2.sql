

DO $$
BEGIN
   update acs_object_types set
      table_name = lower(table_name),
      id_column = lower(id_column)
    where object_type in (
          'portal_datasource',
          'portal_layout',
          'portal_element_theme',
          'portal',
          'portal_page');
END$$;
