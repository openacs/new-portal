# www/master.tcl

ad_page_contract {
    Portal master template.

    @author Arjun Sanyal
    @creation-date 9/28/2001
    @cvs-id $Id$
}

# This could be implemented entirely using the default master if it
# supplied a method for adding stuff to the document header.  I heard
# somewhere that it will soon, so maybe we'll switch to doing that
# soon.

set css_path [ad_parameter css_path]

if { [exists_and_not_null css_path] } {
    # if it starts with a "/", it's outside of this package.
    if { [regexp {^/} $css_path] } {
	set extra_stuff "<link rel=\"stylesheet\" href=\"$css_path\" type=\"text/css\">"
    } else {
	set extra_stuff "<link rel=\"stylesheet\" href=\"[ad_conn package_url]$css_path\" type=\"text/css\">"
    }
} else {
    set extra_stuff {}
}
