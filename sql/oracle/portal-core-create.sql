--
-- The "New" Portal Package
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
--
-- arjun@openforce.net
-- started Sept. 26, 2001
--

-- p_page = portal page
-- pe = portal element i.e. a "box" on a p_page
-- "->" arrows point to a "to-one" relationship

-- p_page_id sequence

-- p_page table
-- name varchar
-- acs_object?
-- restrict_to_party_p
-- owning_party
-- fk(layout)
-- perms?

-- pe table
-- perms?

-- layout table

-- pe_configs table
-- config_id pk
-- portal_id?

-- pe_parameters table
-- this is needed for default configs not associated with no p_page
-- param_id pk
-- config_id refs(pe_configs)
-- key
-- value

-- datasource table
-- configureable_p?
-- default_config_id refs(portal_element_configs)



-- pe <-> datasource map

-- p_page <-> pe mapping table, with config_id
-- unique(p_page, pe), index

-- config_id <- attr table


