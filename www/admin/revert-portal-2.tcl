#
#  Copyright (C) 2004 MIT
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

ad_page_contract {
    Reverts users to the default template. Very perfomance intensive. Use
    only in extreme occasions.
}  {
    {referer:optional "index"}
    portal_id:naturalnum,notnull
}

set form [ns_getform]
set name [portal::get_name $portal_id]

set portal_type [db_string get_current_type {
    select type
    from  dotlrn_portal_types_map 
    where portal_id = :portal_id
}]


ad_return_template


if {$portal_type == "user"}  {
    db_dml revert_user_portals_to_default {
	update dotlrn_user_profile_rels set portal_id = :portal_id
    }
    
    util_memoize_flush_regexp "^dotlrn::get_portal_id_not_cached -user_id"
} else {
    # it is a community
    
    if {$portal_type != "dotlrn_class_instance"} {
	db_exec_plsql revert_community_portals_to_default {
	    update dotlrn_communities set portal_id = :portal_id where community_type = :portal_type
	}
	
    } else {
	# For dotlrn_class_instance, community_type is not equal
	# to portal_type.  I believe this is a bug because all the other types match.
	# So we'll update everything where the community_type doesn not equal the portal_type.
	
	db_exec_plsql revert_community_portals_to_default {
	    update dotlrn_communities set portal_id = :portal_id where 
	    community_type not in (select type from  dotlrn_portal_types_map)
	}										      
    }
    
    util_memoize_flush_regexp "^dotlrn_community::get_portal_id_not_cached -community_id"    
}




