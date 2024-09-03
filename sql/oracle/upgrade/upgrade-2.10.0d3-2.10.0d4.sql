-- upgrade 2.10.0d3 to 2.10.0d4
--
-- Add additional indexes

BEGIN;

    -- table "portal_datasource_def_params"
    create index portal_datasource_def_params_datasource_id_idx on portal_datasource_def_params(datasource_id);

    -- table "portal_element_map"
    create index portal_element_map_datasource_id_idx on portal_element_map(datasource_id);
    create index portal_element_map_page_id_idx on portal_element_map(page_id);

    -- table "portal_element_parameters"
    create index portal_element_parameters_element_id_idx on portal_element_parameters(element_id);
    create index portal_element_parameters_value_idx on portal_element_parameters(value);

END;
