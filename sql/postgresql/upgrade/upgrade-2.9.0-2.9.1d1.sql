--
-- Alter caveman style booleans (type character(1)) to real SQL boolean types.
--

ALTER TABLE portal_element_parameters
      DROP constraint p_element_prms_configured_p_ck,
      ALTER COLUMN configured_p DROP DEFAULT,
      ALTER COLUMN configured_p TYPE boolean
      USING configured_p::boolean,
      ALTER COLUMN configured_p SET DEFAULT false;


ALTER TABLE portal_element_parameters
      DROP constraint p_element_prms_cfg_req_p_ck,
      ALTER COLUMN config_required_p DROP DEFAULT,
      ALTER COLUMN config_required_p TYPE boolean
      USING config_required_p::boolean,
      ALTER COLUMN config_required_p SET DEFAULT false;


ALTER TABLE portal_datasource_def_params
      DROP constraint p_ds_def_prms_configured_p_ck,
      ALTER COLUMN configured_p DROP DEFAULT,
      ALTER COLUMN configured_p TYPE boolean
      USING configured_p::boolean,
      ALTER COLUMN configured_p SET DEFAULT false;


ALTER TABLE portal_datasource_def_params
      DROP constraint p_ds_def_prms_cfg_req_p_ck,
      ALTER COLUMN config_required_p DROP DEFAULT,
      ALTER COLUMN config_required_p TYPE boolean
      USING config_required_p::boolean,
      ALTER COLUMN config_required_p SET DEFAULT false;

ALTER TABLE portal_pages
      DROP constraint portal_pages_hidden_p_ck,
      ALTER COLUMN hidden_p DROP DEFAULT,
      ALTER COLUMN hidden_p TYPE boolean
      USING hidden_p::boolean,
      ALTER COLUMN hidden_p SET DEFAULT false;

ALTER TABLE portal_supported_regions
      DROP constraint p_spprtd_rgns_immtble_p_ck,
      ALTER COLUMN immutable_p DROP DEFAULT,
      ALTER COLUMN immutable_p TYPE boolean
      USING immutable_p::boolean,
      ALTER COLUMN immutable_p SET DEFAULT false;

--
-- procedure portal_page__new/11
--
CREATE OR REPLACE FUNCTION portal_page__new(
   p_page_id integer,
   p_pretty_name varchar,
   p_accesskey varchar,
   p_portal_id integer,
   p_layout_id integer,
   p_hidden_p boolean,
   p_object_type varchar, -- default 'portal_page'
   p_creation_date timestamptz,
   p_creation_user integer,
   p_creation_ip varchar,
   p_context_id integer

) RETURNS integer AS $$
DECLARE
    v_page_id                       portal_pages.page_id%TYPE;
    v_layout_id                     portal_pages.layout_id%TYPE;
    v_sort_key                      portal_pages.sort_key%TYPE;
BEGIN

    v_page_id := acs_object__new(
        null,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        p_context_id,
        't'
    );

    if p_layout_id is null then
        select min(layout_id)
        into v_layout_id
        from portal_layouts;
    else
        v_layout_id := p_layout_id;
    end if;

    select coalesce(max(sort_key) + 1, 0)
    into v_sort_key
    from portal_pages
    where portal_id = p_portal_id;

    insert into portal_pages
    (page_id, pretty_name, accesskey, portal_id, layout_id, sort_key, hidden_p)
    values
    (v_page_id, p_pretty_name, p_accesskey, p_portal_id, v_layout_id, v_sort_key, p_hidden_p);

    return v_page_id;

END;
$$ LANGUAGE plpgsql;


drop function if exists portal_layout__add_region(integer, varchar);

--
-- procedure portal_layout__add_region/3
--
CREATE OR REPLACE FUNCTION portal_layout__add_region(
   p_layout_id integer,
   p_region varchar,
   p_immutable_p boolean default false
) RETURNS integer AS $$
DECLARE
BEGIN
    insert
    into portal_supported_regions
    (layout_id, region, immutable_p)
    values
    (p_layout_id, p_region, p_immutable_p);

    return 0;
END;
$$ LANGUAGE plpgsql;

--
-- procedure portal_datasource__set_def_param/5
--
CREATE OR REPLACE FUNCTION portal_datasource__set_def_param(
   p_datasource_id integer,
   p_config_required_p boolean,
   p_configured_p boolean,
   p_key varchar,
   p_value varchar
) RETURNS integer AS $$
DECLARE
BEGIN

    insert into portal_datasource_def_params
    (parameter_id, datasource_id, config_required_p, configured_p, key, value)
    values
    (nextval('t_acs_object_id_seq'), p_datasource_id, p_config_required_p, p_configured_p, p_key, p_value);

    return 0;

END;
$$ LANGUAGE plpgsql;

