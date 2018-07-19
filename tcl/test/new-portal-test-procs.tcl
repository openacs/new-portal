# packages/new-portal/tcl/test/new-portal-test-procs.tcl
ad_library {
    Tests for portals
}

aa_register_case -cats api create_portal_from_template {
    Create a portal from a template
} {
    aa_run_with_teardown \
	-rollback \
	-test_code {
	    # create a new portal template


	    # create a test user
	    set user_info [ns_mktemp userXXXXXX]
	    array set test_user [auth::create_user \
				  -username $user_info \
				  -first_names $user_info \
				  -last_name $user_info \
				  -email "${user_info}@test.test"]

	    set template_id [portal::create $test_user(user_id)]

	    portal::page_create \
		-pretty_name "Page 3" \
		-portal_id $template_id

	    portal::page_create \
		-pretty_name "Page 2" \
		-portal_id $template_id

	    # create a portal based on the template
            set user_info_2 [ns_mktemp userXXXXXX]
	    array set test_user_2 [auth::create_user \
				  -username $user_info_2 \
				  -first_names $user_info_2 \
				  -last_name $user_info_2 \
				  -email "${user_info_2}@test.test"]
	    
	    
	    set portal_id_2 [portal::create  -template_id $template_id $test_user_2(user_id)]

	    # make sure the pages exist and are in the same order
            set correct_page_count [db_string count_correct_pages "
	        select count(*) from portal_pages p1, portal_pages p2
                where p1.portal_id = :template_id
                and p2.portal_id = :portal_id_2
                and p1.pretty_name = p2.pretty_name
                "]

            aa_true "Pages in correct order" {$correct_page_count == 3}
	}

}
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
