<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="portal::datasource::new.new_datasource">
        <querytext>
             select portal_datasource__new(
    		:name,
    		:description     
  	     )
        </querytext>
    </fullquery>

    <fullquery name="portal::datasource::set_def_param.set_def_param">
        <querytext>
            select portal_datasource__set_def_param(
		:datasource_id,
		:config_required_p,
		:configured_p, 
		:key, 
		:value
	    )
        </querytext>
    </fullquery>

    <fullquery name="portal::datasource::delete.delete_datasource">
        <querytext>
             select portal_datasource__delete(
    		:datasource_id
  	     )
        </querytext>
    </fullquery>

</queryset>
