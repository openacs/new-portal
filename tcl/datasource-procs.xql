<?xml version="1.0"?>

<queryset>

    <fullquery name="portal::datasource::delete.get_datasource_id">
        <querytext>
           select datasource_id
           from portal_datasources
           where name = :name;
        </querytext>
    </fullquery>

</queryset>
