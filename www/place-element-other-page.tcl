# moving to other pages
set element_id $element_multi(element_id)

template::multirow create pages page_id pretty_name element_id
set other_page_avail_p 0

db_foreach other_pages_select {
    select page_id, pretty_name
     from portal_pages pp
     where
       pp.portal_id = :portal_id 
       and pp.page_id != :page_id
    order by sort_key
} {
    set other_page_avail_p 1

    template::multirow append pages \
            $page_id $pretty_name
}
