alter table portal_datasources add column css_dir varchar(200);


-- old define_function_args('portal_datasource__new','datasource_id,name,description,css_dir,object_type;portal_datasource,creation_date,creation_user,creation_ip,context_id')
-- new
select define_function_args('portal_datasource__new','datasource_id;null,name;null,description;null,css_dir,object_type;portal_datasource,creation_date;now(),creation_user;null,creation_ip;null,context_id;null');




--
-- procedure portal_datasource__new/9
--
CREATE OR REPLACE FUNCTION portal_datasource__new(
   p_datasource_id integer,     -- default null
   p_name varchar,              -- default null
   p_description varchar,       -- default null
   p_css_dir varchar,
   p_object_type varchar,       -- default 'portal_datasource'
   p_creation_date timestamptz, -- default now()
   p_creation_user integer,     -- default null
   p_creation_ip varchar,       -- default null
   p_context_id integer         -- default null

) RETURNS integer AS $$
DECLARE
    v_datasource_id                 portal_datasources.datasource_id%TYPE;
BEGIN

    v_datasource_id := acs_object__new(
        p_datasource_id,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        p_context_id,
        't'
    );

    insert into portal_datasources
    (datasource_id, name, description, css_dir)
    values
    (v_datasource_id, p_name, p_description, p_css_dir);

    return v_datasource_id;

END;
$$ LANGUAGE plpgsql;



--
-- procedure portal_datasource__new/8
--
CREATE OR REPLACE FUNCTION portal_datasource__new(
   p_datasource_id integer,     -- default null
   p_name varchar,              -- default null
   p_description varchar,       -- default null
   p_object_type varchar,       -- default 'portal_datasource'
   p_creation_date timestamptz, -- default now()
   p_creation_user integer,     -- default null
   p_creation_ip varchar,       -- default null
   p_context_id integer         -- default null

) RETURNS integer AS $$
--
-- portal_datasource__new/8 maybe obsolete, when we define proper defaults for /9
--
DECLARE
    v_datasource_id                 portal_datasources.datasource_id%TYPE;
BEGIN

    v_datasource_id := portal_datasource__new(null,
				  p_name,
				  p_description,
                                  null,
				  p_object_type,
				  p_creation_date,
				  p_creation_user,
				  p_creation_ip,
				  p_context_id);

    return v_datasource_id;

END;
$$ LANGUAGE plpgsql;




--
-- procedure portal_datasource__new/3
--
CREATE OR REPLACE FUNCTION portal_datasource__new(
   p_name varchar,        -- default null
   p_description varchar, -- default null
   p_css_dir varchar

) RETURNS integer AS $$
--
-- portal_datasource__new/3 maybe obsolete, when we define proper defaults for /9
--
DECLARE
    v_datasource_id                 portal_datasources.datasource_id%TYPE;
BEGIN

    v_datasource_id := portal_datasource__new(null,
				  p_name,
				  p_description,
                                  p_css_dir,
				  'portal_datasource',
				  now(),
				  null,
				  null,
				  null);

    return v_datasource_id;

END;
$$ LANGUAGE plpgsql;

