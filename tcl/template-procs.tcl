# www/tcl/template-procs.tcl

ad_library {
    Procs for use in presentation.
    
    @author Ian Baker (ibaker@arsdigita.com)
    @creation-date 12/11/2000
    @cvs-id $Id$
}

ad_proc -public portal_layout_elements { element_list {var_stub "element_ids"} } {
    Split a list up into a bunch of variables for inserting into a layout
    template.  This seems pretty kludgy (probably because it is), but a
    template::multirow isn't really well suited to data of this shape.  It'll setup a set
    of variables, $var_stub_1 - $var_stub_8 and $var_stub_i1 - $var_stub_i8, each
    contining the portal_ids that belong in that region.

    @creation-date 12/11/2000
    @param element_id_list An [array get]'d array, keys are regions, values are lists of element_ids.
    @param var_stub A name upon which to graft the bits that will be passed to the template.
} {
    array set elements $element_list
    
    foreach idx [list 1 2 3 4 5 6 7 8 9 i1 i2 i3 i4 i5 i6 i7 i8 i9 ] {
	upvar [join [list $var_stub "_" $idx] ""] group
	if { [info exists elements($idx) ] } {
	    set group $elements($idx)
	} else {
	    set group {}
	}
    }
}

