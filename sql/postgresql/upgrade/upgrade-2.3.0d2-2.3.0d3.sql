alter table portal_datasources add column css_dir varchar(200);

select define_function_args('portal_datasource__new','datasource_id,name,description,css_dir,object_type;portal_datasource,creation_date,creation_user,creation_ip,context_id');

create or replace function portal_datasource__new (integer,varchar,varchar,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
    p_datasource_id                 alias for $1; -- default null
    p_name                          alias for $2; -- default null
    p_description                   alias for $3; -- default null
    p_css_dir                       alias for $4;
    p_object_type                   alias for $5; -- default ''portal_datasource''
    p_creation_date                 alias for $6; -- default now()
    p_creation_user                 alias for $7; -- default null
    p_creation_ip                   alias for $8; -- default null
    p_context_id                    alias for $9; -- default null
    v_datasource_id                 portal_datasources.datasource_id%TYPE;
begin

    v_datasource_id := acs_object__new(
        p_datasource_id,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        p_context_id,
        ''t''
    );

    insert into portal_datasources
    (datasource_id, name, description, css_dir)
    values
    (v_datasource_id, p_name, p_description, p_css_dir);

    return v_datasource_id;

end;' language 'plpgsql';

create or replace function portal_datasource__new (integer,varchar,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
    p_datasource_id                 alias for $1; -- default null
    p_name                          alias for $2; -- default null
    p_description                   alias for $3; -- default null
    p_object_type                   alias for $4; -- default ''portal_datasource''
    p_creation_date                 alias for $5; -- default now()
    p_creation_user                 alias for $6; -- default null
    p_creation_ip                   alias for $7; -- default null
    p_context_id                    alias for $8; -- default null
    v_datasource_id                 portal_datasources.datasource_id%TYPE;
begin

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

end;' language 'plpgsql';


create or replace function portal_datasource__new (varchar,varchar,varchar)
returns integer as '
declare
    p_name                          alias for $1; -- default null
    p_description                   alias for $2; -- default null
    p_css_dir                       alias for $3;
    v_datasource_id                 portal_datasources.datasource_id%TYPE;
begin

    v_datasource_id := portal_datasource__new(null,
				  p_name,
				  p_description,
                                  p_css_dir,
				  ''portal_datasource'',
				  now(),
				  null,
				  null,
				  null);

    return v_datasource_id;

end;' language 'plpgsql';

