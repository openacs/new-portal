#
#  Copyright (C) 2004 MIT
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

ad_page_contract {
    Reverts users to the default template. Very perfomance intensive. Use
    only in extreme occasions.
}  {
    {referer:optional "index"}
    portal_id:naturalnum,notnull
}

set form [ns_getform]
set name [portal::get_name $portal_id]

ad_return_template

db_foreach get_dotlrn_users "select portal_id from dotlrn_users" {
   portal::configure_dispatch -portal_id $portal_id -form $form
}












