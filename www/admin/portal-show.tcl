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

# www/show-portal.tcl

ad_page_contract {
    Just a test script to display the portal.

    @author AKS
    @creation-date 
    @cvs-id $Id$
} {
    {referer:notnull}
    portal_id:naturalnum,notnull
    {page_num:naturalnum,notnull 0}
}

set name [portal::get_name $portal_id]
set html "[portal::navbar -portal_id $portal_id] [portal::render -page_num $page_num $portal_id]"



# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
