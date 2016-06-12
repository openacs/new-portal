-- 
-- cleanup of old definitions, where booleans were varchars
--
drop function if exists portal_page__new(p_page_id integer, p_pretty_name character varying, p_accesskey character varying, p_portal_id integer, p_layout_id integer, p_hidden_p character, p_object_type character varying, p_creation_date timestamp with time zone, p_creation_user integer, p_creation_ip character varying, p_context_id integer);

drop function if exists portal_layout__add_region(p_layout_id integer, p_region character varying, p_immutable_p character);

drop function if exists portal_datasource__set_def_param(p_datasource_id integer, p_config_required_p character varying, p_configured_p character varying, p_key character varying, p_value character varying);
