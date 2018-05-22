
#
### Portal immutable properties
#

set ::portal::package_key "new-portal"
set ::portal::get_package_id [apm_package_id_from_key $::portal::package_key]
set ::portal::www_path /packages/${::portal::package_key}/www
set ::portal::mount_point [site_node::get_url_from_object_id \
                               -object_id $::portal::get_package_id]
set ::portal::automount_point "portal"

###
