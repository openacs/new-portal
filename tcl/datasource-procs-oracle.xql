<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="portal::datasource::new.new_datasource">
        <querytext>
           begin
             :1 := portal_datasource.new(
                     name => :name,
                     description => :description     
             );
           end;
        </querytext>
    </fullquery>

    <fullquery name="portal::datasource::set_def_param.set_def_param">
        <querytext>
           begin
             portal_datasource.set_def_param(
                 datasource_id => :datasource_id,
                 config_required_p => :config_required_p,
                 configured_p => :configured_p, 
                 key => :key, 
                 value => :value
             );
           end;
        </querytext>
    </fullquery>

    <fullquery name="portal::datasource::delete.delete_datasource">
        <querytext>
           begin
             portal_datasource.del(
               datasource_id => :datasource_id
             );
           end;
        </querytext>
    </fullquery>

</queryset>
