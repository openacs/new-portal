# tcl/datasource-procs.tcl

ad_library {
    Private procs that evaluate specific content- and data-types for datasources.
    
    @author Ian Baker (ibaker@arsdigita.com)
    @creation-date 12/6/2000
    @cvs-id $Id$
}


ad_proc -private portal_render_datasource_raw { ds cf } {
    Accepts no parameters.
} {
    array set src $ds

    if { [empty_string_p $src(content) ] } {
	return -code error "No content for raw datasource '$src(name)'"
    }

    return $src(content)
}

ad_proc -private portal_render_datasource_tcl_proc { ds cf } {
    Accepts params.
} {
    array set src $ds

    if [catch {set output [ eval "$src(content) { $cf }" ] } errmsg ] {
	return -code error "Error processing datasource '$src(name)': $errmsg"
    }

    # in case the data feed code didn't explicitly return.
    return $output
}

ad_proc -private eval_raw {input} {
    A helper proc for portal_render_datasource_tcl_raw.  It's there because
    return doesn't work right with eval from within a catch.
} {
    return [eval $input]
}

ad_proc -private portal_render_datasource_tcl_raw { ds cf } {
    Accepts no params.
} {
    array set src $ds

    if [catch {set output [ eval_raw $src(content) ] } errmsg ] {
	return -code error "Error processing datasource '$src(name)': $errmsg"
    }

    # in case the data feed code didn't explicitly return.
    return $output
}

ad_proc -private portal_render_datasource_url { ds cf } {
    Accepts params.
} {
    array set conf $cf
    array set src $ds

    # this is complicated.  There's argument processing and caching and stuff.
    return -code error "URL data_type not currently implemented.  Sorry...<br>
            Your URL was: <pre>$src(content)</pre>"
}

ad_proc -private portal_render_datasource_adp { ds cf } {
    Accepts no params.
} {
    array set src $ds

    # this should actually "compile" the ADP into Tcl, and cache the
    # compiled code.
    return [ ns_adp_parse $src(content) ]
}


ad_proc -public portal_export { exports } {
    Exports the same variables as where received by this connection,
    but with variables in exports added or overridden.
    
    @author Lee Denison (lee@arsdigita.com)
    @return the export list
    @param exports the values to be exported
} {
    set output [list]
    set form_set [ns_getform]
    
    if {![empty_string_p $form_set]} {
	set form_set [ns_set copy $form_set]
    } else {
	set form_set [ns_set new]
    }
    
    foreach {name value} $exports {
	ns_set update $form_set $name $value
    }
    
    set size [ns_set size $form_set]
    for {set i 0} {$i < $size} {incr i} {
	set name [ns_set key $form_set $i]
	set value [ns_set value $form_set $i]
	
	lappend output [ad_export_vars [list [list $name $value]]]      
    }
    
    return [join $output "&"]
}
