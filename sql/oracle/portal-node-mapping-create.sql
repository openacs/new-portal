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
       object_id                constraint portal_node_map_obj_id_fk
                                references acs_objects(object_id)
                                on delete cascade
                                constraint portal_node_map_obj_id_pk
                                primary key,
       node_id                  constraint portal_node_map_node_id_fk
                                references site_nodes(node_id)
                                on delete cascade
                                constraint portal_node_map_node_id_nn
                                not null
);


create or replace package portal_node_mapping
as
        procedure new (
                  object_id     in portal_node_mappings.object_id%TYPE,
                  node_id       in portal_node_mappings.node_id%TYPE
        );

        procedure del (
                  object_id     in portal_node_mappings.object_id%TYPE
        );


end portal_node_mapping;
/
show errors


create or replace package body portal_node_mapping
as
        procedure new (
                  object_id     in portal_node_mappings.object_id%TYPE,
                  node_id       in portal_node_mappings.node_id%TYPE
        ) is
        begin
                del(new.object_id);

                insert into portal_node_mappings
                (object_id, node_id) values
                (new.object_id, new.node_id);
        end new;

        procedure del (
                  object_id     in portal_node_mappings.object_id%TYPE
        ) is
        begin
                delete from portal_node_mappings where object_id= del.object_id;
        end del;


end portal_node_mapping;
/
show errors
