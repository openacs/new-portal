# moving to other pages
set element_id $element_multi(element_id)

template::multirow create pages page_id pretty_name element_id
set other_page_avail_p 0

db_foreach other_pages_select {} {
    set other_page_avail_p 1

    template::multirow append pages \
            $page_id $pretty_name
}
