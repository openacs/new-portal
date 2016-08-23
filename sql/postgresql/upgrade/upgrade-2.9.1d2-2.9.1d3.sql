-- 
-- cleanup of old definition, introduced on oacs 5.3
--
drop function if exists portal_page__new(p_page_id integer, p_pretty_name character, p_accesskey character varying, p_portal_id integer, p_layout_id integer, p_hidden_p character, p_object_type character varying, p_creation_date timestamp with time zone, p_creation_user integer, p_creation_ip character varying, p_context_id integer);

