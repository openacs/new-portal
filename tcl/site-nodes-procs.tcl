#
#  Copyright (C) 2001, 2002 MIT
#
#  This file is part of dotLRN.
#
#  dotLRN is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.
#

ad_library {
    Tcl procs for interface with the site-node data model.

    @author yon@openforce.net
    @creation-date 2001-12-07
    @version $Id$
}

namespace eval site_nodes {

    ad_proc -public get_node_id_from_child_name {
        {-parent_node_id:required}
        {-name:required}
    } {
        return [db_string get_child_node_id {
            select node_id from site_nodes where parent_id = :parent_node_id
            and name = :name} -default ""]
    }

    ad_proc -public get_parent_name {
        {-package_id ""}
    } {
        get the name of the parent of this instance
    } {
        return [util_memoize "site_nodes::get_parent_name_not_cached -package_id $package_id"]
    }

    ad_proc -public get_parent_name_not_cached {
        {-package_id ""}
    } {
        memoizing helper
    } {
        return [db_string select_parent_name_by_id {} -default ""]
    }

    # site_nodes_list procs

    ad_proc -public get_site_nodes_list {
    } {
        Return the list-ified site_nodes array.
    } {
        return [nsv_array get site_nodes]
    }

    ad_proc -public get_site_nodes_list_key {
        {-site_nodes_list:required}
        {-index:required}
    } {
        return [lindex $site_nodes_list $index]
    }

    ad_proc -public get_site_nodes_list_value {
        {-site_nodes_list:required}
        {-index:required}
    } {
        return [lindex $site_nodes_list [expr $index + 1]]
    }

    ad_proc -public get_site_nodes_list_value_param {
        {-site_nodes_list:required}
        {-index:required}
        {-param:required}
    } {
        The 'site_nodes' nsv_array is chock full of information
        about every package mounted on every node in the system, let's
        access that information.

        Here's a sample:
        key = /portal/

        value = directory_p t
        object_type apm_package
        package_key new-portal
        package_id 3482
        pattern_p t
        node_id 3481
        url /portal/
        object_id 3482

        @author arjun@openforce.net
    } {
        array set snlv [get_site_nodes_list_value \
                -site_nodes_list $site_nodes_list \
                -index $index]

	switch $param {
	    "directory_p" {
                return $snlv(directory_p)
	    }
	    "object_type" {
                return $snlv(object_type)
	    }
	    "package_key" {
                return $snlv(package_key)
	    }
	    "package_id" {
                return $snlv(package_id)
	    }
	    "pattern_p" {
                return $snlv(pattern_p)
	    }
	    "node_id" {
                return $snlv(node_id)
	    }
	    "url" {
                return $snlv(url)
	    }
	    "object_id" {
                return $snlv(object_id)
	    }
            default {
 		ns_log Error \
			"site_nodes::get_site_nodes_list_value_param failed! \n
                bad param ($param) was specified"
		ad_return_complaint 1 \
			"site_nodes::get_site_nodes_list_value_param failed! \n
                bad param ($param) was specified"
            }
        }
    }

    ad_proc -private get_info {
        {-return:required}
        {-param ""}
        {-package_key:required}
    } {
        returns either 1. number of times this package_key is mounted
        2. the url a singleton is mounted at (or the first match it finds
        for a multi-mounted package) or 3. a singleon's param (see list above).
        Same deal appiles to non-singletons

        ret = count, url, param
    } {

        set get_count_p 0
        set get_url_p 0
        set get_param_p 0

        if {$return == "count"} {
            set get_count_p 1
            set $param "package_key"
        } elseif {$return == "url"} {
            set get_url_p 1
        } elseif {$return == "param"} {
            if {[empty_string_p $param]} {
 		ns_log Error \
			"site_nodes::get_info failed! \n
                no param specified to get"
		ad_return_complaint 1 \
			"site_nodes::get_info failed! \n
                no param specified to get"
            } else {
                set get_param_p 1
            }
        }

        set site_nodes_list [get_site_nodes_list]

        # iterate through the array, counting the number of times the
        # passed in package key is in the site_nodes array
        set count 0

        for {set x 0} {$x < [llength $site_nodes_list]} {incr x 2} {

            set key [get_site_nodes_list_key \
                    -site_nodes_list $site_nodes_list \
                    -index $x]

            if {$get_url_p} { return $key }

            set poss_key_match [get_site_nodes_list_value_param \
                    -site_nodes_list $site_nodes_list \
                    -index $x \
                    -param "package_key"]

            if { $poss_key_match == $package_key} {

                if {$get_param_p} {
                    return [get_site_nodes_list_value_param \
                            -site_nodes_list $site_nodes_list \
                            -index $x \
                            -param $param]
                }

                incr count
            }
        }

        if {$get_count_p} {
            return $count
        } else {
            ns_log error "site_nodes::get_info get_count_p assertion failed! We should never get here return=$return param=$param package_key=$package_key"
        }
    }
}

