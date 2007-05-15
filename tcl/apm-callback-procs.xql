<?xml version="1.0"?>

<queryset>

  <fullquery name="new-portal::after_upgrade.update_type">
    <querytext>
      update acs_object_types
      set package_name = 'portal_element_theme',
        table_name = 'PORTAL_ELEMENT_THEMES'
      where object_type = 'portal_element_theme'
    </querytext>
  </fullquery>

</queryset>
