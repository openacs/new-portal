<%

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

%>

<form method=post action=@action_string@>
<input type=hidden name=portal_id value=@portal_id@>
<input type=hidden name=return_url value=@return_url@>

<if @other_page_avail_p@ ne 0>
  <input type=hidden name=element_id value=@element_id@>
  <input type=hidden name=anchor value=@page_id@>
  <input type=submit name="op" value="Move to page">
  <select name=page_id>
  <multiple name=pages>
  <option value=@pages.page_id@>@pages.pretty_name@</option>
  </multiple>
  </select>

</if>

</form>
