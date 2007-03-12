alter table portal_datasources add css_dir varchar(200);

create or replace package portal_datasource
as

    function new (
        datasource_id               in portal_datasources.datasource_id%TYPE default null,
        name                        in portal_datasources.name%TYPE default null,
        description                 in portal_datasources.description%TYPE default null,
        css_dir                     in portal_datasources.css_dir%TYPE default null,
        object_type                 in acs_object_types.object_type%TYPE default 'portal_datasource',
        creation_date               in acs_objects.creation_date%TYPE default sysdate,
        creation_user               in acs_objects.creation_user%TYPE default null,
        creation_ip                 in acs_objects.creation_ip%TYPE default null,
        context_id                  in acs_objects.context_id%TYPE default null
    ) return portal_datasources.datasource_id%TYPE;

    procedure del (
        datasource_id               in portal_datasources.datasource_id%TYPE
    );

    procedure set_def_param (
        datasource_id               in portal_datasource_def_params.datasource_id%TYPE,
        config_required_p           in portal_datasource_def_params.config_required_p%TYPE default null,
        configured_p                in portal_datasource_def_params.configured_p%TYPE default null,
        key                         in portal_datasource_def_params.key%TYPE,
        value                       in portal_datasource_def_params.value%TYPE default null
    );

end portal_datasource;
/
show errors

create or replace package body portal_datasource
as

    function new (
        datasource_id               in portal_datasources.datasource_id%TYPE default null,
        name                        in portal_datasources.name%TYPE default null,
        description                 in portal_datasources.description%TYPE default null,
        css_dir                     in portal_datasources.css_dir%TYPE default null,
        object_type                 in acs_object_types.object_type%TYPE default 'portal_datasource',
        creation_date               in acs_objects.creation_date%TYPE default sysdate,
        creation_user               in acs_objects.creation_user%TYPE default null,
        creation_ip                 in acs_objects.creation_ip%TYPE default null,
        context_id                  in acs_objects.context_id%TYPE default null
    ) return portal_datasources.datasource_id%TYPE
    is
        v_datasource_id             portal_datasources.datasource_id%TYPE;
    begin

        v_datasource_id := acs_object.new(
            object_id => datasource_id,
            object_type => object_type,
            creation_date => creation_date,
            creation_user => creation_user,
            creation_ip => creation_ip,
            context_id => context_id
        );

        insert into portal_datasources
        (datasource_id, name, description, css_dir)
        values
        (v_datasource_id, name, description, css_dir);

        return v_datasource_id;

    end new;

    procedure del (
        datasource_id               in portal_datasources.datasource_id%TYPE
    )
    is
    begin
        acs_object.del(datasource_id);
    end del;

    procedure set_def_param (
        datasource_id               in portal_datasource_def_params.datasource_id%TYPE,
        config_required_p           in portal_datasource_def_params.config_required_p%TYPE default null,
        configured_p                in portal_datasource_def_params.configured_p%TYPE default null,
        key                         in portal_datasource_def_params.key%TYPE,
        value                       in portal_datasource_def_params.value%TYPE default null
    )
    is
    begin

        insert into portal_datasource_def_params
        (parameter_id, datasource_id, config_required_p, configured_p, key, value)
        values
        (acs_object_id_seq.nextval, datasource_id, config_required_p, configured_p, key, value);

    end set_def_param;

end portal_datasource;
/
show errors
