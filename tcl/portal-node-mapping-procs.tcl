#
#  Copyright (C) 2001, 2002 OpenForce, Inc.
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

# tcl/portal-node-mapping-procs.tcl

ad_library {
    Portal Node Mappings

    @author Ben Adida (ben@openforce)
    @creation-date April 2002
    @cvs-id $Id$
}

namespace eval portal::mapping {

    ad_proc -public set {
        {-object_id:required}
        {-node_id:required}
    } {
        db_exec_plsql set_node_mapping {}
    }

    ad_proc -public unset {
        {-object_id:required}
    } {
        db_exec_plsql unset_node_mapping {}
    }

    ad_proc -public get_node_id {
        {-object_id:required}
    } {
        return [db_string select_node_mapping {} -default ""]
    }

    ad_proc -public get_url {
        {-object_id:required}
    } {
        set node_id [get_node_id -object_id $object_id]

        if {[empty_string_p $node_id]} {
            return $node_id
        }

        return [site_nodes::get_url_from_node_id -node_id $node_id]
    }

}
