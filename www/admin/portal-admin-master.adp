<%
    #
    #  Copyright (C) 2001, 2002 OpenForce, Inc.
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

<master>

<P>
Portal: <strong>@name@</strong>
<P>
Go to <a href=index>portal admin</a> 
<if @no_edit_p@ nil>
  or <a href=portal-config?portal_id=@portal_id@>edit this portal</a>
</if>
<if @no_view_p@ nil>
  or <a href=portal-show?portal_id=@portal_id@>view this portal</a>
</if>
<P>

<slave>
