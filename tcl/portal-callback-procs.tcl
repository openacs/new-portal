ad_library {
    Callbacks for the search package.

    @author Dirk Gomez <openacs@dirkgomez.de>
    @creation-date 2005-06-12
    @cvs-id $Id$
}

##################
# Search callbacks
##################


ad_proc -public -callback search::datasource -impl portal_datasource {} {

    @author openacs@dirkgomez.de
    @creation-date 2005-06-13

    returns a datasource for the search package
    this is the content that will be indexed by the full text
    search engine.

} {
    set bodies {}
    db_foreach all_static_portlets {             
	select body
	from portal_element_map pem,
	    portal_pages pp,
	    portal_element_parameters pep,
	    static_portal_content spc
        where pp.portal_id = :object_id
            and pem.page_id = pp.page_id
            and pem.state != 'hidden'
	    and name = 'static_portlet'
	    and pep.element_id = pem.element_id
	    and pep.key = 'package_id'
            and cast(pep.value as integer) = spc.package_id
    } {
	append bodies [ad_html_text_convert -from text/html -to text/plain -- $body]
    }

    return [list object_id $object_id \
                title {TODO the_communities_title} \
                content $bodies \
                keywords {} \
                storage_type text \
                mime text/plain ]
}

ad_proc -public -callback search::url -impl portal_datasource {} {

    @author openacs@dirkgomez.de
    @creation-date 2005-06-13

    returns a URL for a portal to the search package

} {
    # TODO implement me
    return [ad_url]
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
