# www/template-place-element.tcl
ad_page_contract {
    Place elements in a portal template.

    @author Arjun Sanyal (arjun@openforce.net)
    @cvs_id $Id$
} -properties {
    region:onevalue
    action_string:onevalue
    portal_id:onevalue
    return_url:onevalue
}

set layout_id [portal::get_layout_id $portal_id]

db_1row select_num_regions "
select count(*) as num_regions
from portal_supported_regions
where layout_id = :layout_id"

# get the elements for this region.
set region_count 0
template::multirow create element_multi element_id name sort_key state hideable_p shadeable_p description
db_foreach select_elements_by_region {
    select pem.element_id, pem.name, sort_key, state, pd.description
     from portal_element_map pem, portal_datasources pd 
     where
       portal_id = :portal_id 
       and pem.datasource_id  = pd.datasource_id
       and region = :region 
       and state != 'hidden'
    order by sort_key } {
	
	db_1row select_shadeable_p \
		"select value as shadeable_p from portal_element_parameters where key = 'shadeable_p' and element_id = :element_id"

	db_1row select_hideable_p \
		"select value as hideable_p from portal_element_parameters where key = 'hideable_p' and element_id = :element_id"
	
	template::multirow append element_multi \
		$element_id $name $sort_key $state $hideable_p $shadeable_p $description
	incr region_count
	
    }
    
    db_1row select_all_noimm_count \
	    "select count(*) as all_count
    from portal_element_map
    where
    portal_id = :portal_id
    and state != 'hidden'
    and region not like 'i%'"
    
    # Set up the form target
    set target_stub [lindex [ns_conn urlv] [expr [ns_conn urlc] - 1]]
    set show_avail_p 0
    set show_html ""
    
    append show_html "<select name=element_id>"
    
    db_foreach hidden_elements {
	select element_id, name
	from portal_element_map pem
	where
	pem.portal_id = :portal_id 
	and pem.state = 'hidden'
	order by name
    } {
	set show_avail_p 1
	append show_html "<option value=$element_id>$name</option>\n"
    }
    
    


set dir "[portal::mount_point]/place-element-components"

append show_html ""
        

