# packages/new-portal/tcl/test/new-portal-test-procs.tcl
ad_library {
    Tests for portals
}

aa_register_case -cats api -procs {
    portal::create
    portal::delete
    portal::page_create
    portal::page_delete
    portal::page_count
    portal::get_page_id
    portal::get_page_pretty_name
    portal::set_page_pretty_name
    portal::first_page_p
    portal::exists_p
} create_portal_from_template {
    Create and delete a portal from a template
} {
    aa_run_with_teardown -rollback -test_code {
        #
        # Create a test user
        #
        array set test_user [acs::test::user::create]
        #
        # Create template portal for user
        #
        set template_id [portal::create $test_user(user_id)]
        set first_page  [portal::get_page_id -portal_id $template_id]
        aa_true "Portal exists" [portal::exists_p $template_id]
        #
        # Create pages
        #
        portal::page_create -pretty_name "Page 2" -portal_id $template_id
        portal::page_create -pretty_name "Page 3" -portal_id $template_id
        #
        # Create another page, to be deleted
        #
        set page_to_delete [portal::page_create \
            -pretty_name "Page to delete" \
            -portal_id $template_id]
        aa_equals "Number of pages in portal before deletion" \
            [portal::page_count -portal_id $template_id] "4"
        #
        # Get page_id from a portal page
        #
        aa_equals "ID of a portal page by name" \
            [portal::get_page_id -portal_id $template_id \
                -page_name "Page to delete"] "$page_to_delete"
        #
        # Get pretty_name from a portal page
        #
        aa_equals "Name of a portal by portal_id" \
            [portal::get_page_pretty_name -page_id $page_to_delete] \
            "Page to delete"
        #
        # Change pretty_name from a portal page
        #
        set new_pretty_name "New pretty name"
        portal::set_page_pretty_name \
            -page_id $page_to_delete \
            -pretty_name $new_pretty_name
        aa_equals "Name of a portal after change" \
            [portal::get_page_pretty_name -page_id $page_to_delete] \
            "$new_pretty_name"
        #
        # Check for first page in portal
        #
        aa_true "Check for first page in portal" \
            [portal::first_page_p \
                -portal_id $template_id \
                -page_id $first_page]
        #
        # Delete the portal page
        #
        portal::page_delete -page_id $page_to_delete
        aa_equals "Number of pages in portal after deletion" \
            [portal::page_count -portal_id $template_id] "3"

        #
        # Create another user and a portal based on the template
        #
        array set test_user_2 [acs::test::user::create]
        set portal_id_2 [portal::create \
                            -template_id $template_id $test_user_2(user_id)]
        #
        # Make sure the pages exist and are in the same order
        #
        set correct_page_count [db_string count_correct_pages "
            select count(*)
              from portal_pages p1, portal_pages p2
             where p1.portal_id = :template_id
               and p2.portal_id = :portal_id_2
               and p1.pretty_name = p2.pretty_name
        "]
        aa_equals "Pages in correct order" "$correct_page_count" "3"
        #
        # Delete portal
        #
        portal::delete $portal_id_2
        aa_false "Portal exists after deletion" [portal::exists_p $portal_id_2]
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
