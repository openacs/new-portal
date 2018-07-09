ad_library {
    
    APM callback procs for new-portal.

    @author Don Baccus (dhogaza@pacifier.com)
}

namespace eval new-portal {}

ad_proc -private new-portal::after_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    After upgrade callback for new-portal.
} {
    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
        -spec {
            2.3.0d1 2.3.0d2 {

                # DRB: Those fuckers at Open Force (and you can quote me on this)
                # defined the type "portal_element_theme" with table and package set
                # to "portal_themes" and "portal_theme" respectively.  These don't exist,
                # which breaks package_instantiate_object.

                db_dml update_type {}

            }
            2.10.0d0 2.10.0d1 {
                set deleted_attributes [list]
                lappend deleted_attributes [db_string get_attribute {
                    select attribute_id from acs_attributes
                    where object_type = 'portal_datasource'
                    and lower(attribute_name) = 'content'} -default ""]
                lappend deleted_attributes [db_string get_attribute {
                    select attribute_id from acs_attributes
                    where object_type = 'portal_element_theme'
                    and lower(attribute_name) = 'type'} -default ""]
                lappend deleted_attributes [db_string get_attribute {
                    select attribute_id from acs_attributes
                    where object_type = 'portal_layout'
                    and lower(attribute_name) = 'type'} -default ""]
                foreach attribute_id $deleted_attributes {                
                    if {$attribute_id ne ""} {
                        attribute::delete $attribute_id
                    }
                }
            }
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
