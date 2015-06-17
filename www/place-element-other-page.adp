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

<form name="op_move_to_page" method=post action=@action_string@ class="inline-form">
<div><input type="hidden" name="portal_id" value="@portal_id@"></div>
<div><input type="hidden" name="return_url" value="@return_url@"></div>

<if @other_page_avail_p@ ne 0>
  <div><input type="hidden" name="element_id" value="@element_id@"></div>
  <div><input type="hidden" name="anchor" value="@page_id@"></div>
  <div><input type="submit" name="op_move_to_page" value="#new-portal.Move_to_page#"></div>
  <div>
  <select name=page_id>
  <multiple name=pages>
  <option value=@pages.page_id@><%= [lang::util::localize "@pages.pretty_name@"] %></option>
  </multiple>
  </select>
  </div>
</if>

</form>
