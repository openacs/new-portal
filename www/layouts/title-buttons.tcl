#
#  Copyright (C) 2001, 2002 MIT
#
#  This file is part of dotLRN.
#
#  dotLRN is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.
#

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
