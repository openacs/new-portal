--
--  Copyright (C) 2001, 2002 OpenForce, Inc.
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
-- The "New" Portal Package
-- A mechanism for associating location with a certain chunk of data.
--
-- Ben Adida (ben@openforce)
-- $Id$
--



create table portal_node_mappings (
       object_id                integer not null
                                constraint portal_node_map_obj_id_fk
                                references acs_objects(object_id)
                                constraint portal_node_map_obj_id_pk
                                primary key,
       node_id                  integer not null
                                constraint portal_node_map_node_id_fk
                                references site_nodes(node_id)
);


select define_function_args('portal_node_mapping__new', 'object_id,node_id');
select define_function_args('portal_node_mapping__del', 'object_id');

create function portal_node_mapping__del(integer)
returns integer as '
DECLARE
        p_object_id             alias for $1;
BEGIN
       delete from portal_node_mappings where object_id= p__object_id;
END;
' language 'plpgsql';

create function portal_node_mapping__new(integer,integer)
returns integer as '
DECLARE
        p_object_id             alias for $1;
        p_node_id               alias for $2;
BEGIN
        PERFORM portal_node_mapping__del(p_object_id);

        insert into portal_node_mappings
        (object_id, node_id) values
        (p_object_id, p_node_id);
END;
' language 'plpgsql';
