# www/templates/title-buttons.tcl

ad_page_contract {
    Display the appropriate buttons in a portal's titlebar-like area.

    @author Ian Baker (ibaker@arsdigita.com)
    @creation-date 2/14/2001
    @cvs_id $Id$
}

# should this come from the template or something?  how does it work?
set title(resource_dir) "/packages/portal/www/templates/components/simple-element"

set title_noshade_p [ad_parameter title_noshade_p]
set title_nomove_p [ad_parameter title_nomove_p]
