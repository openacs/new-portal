<%
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
%>

<master src="portal-admin-master">
<property name=referer>@referer@</property>
<property name=name>@name@</property>

<h2><font color=red>Warning</font></h2>
<p>
Continuing will revert all portals of type "@name@" to the default layout.  This will overwrite any changes users have made.
<p>
Do you really wish to continue?

<form name="op_revert" method=post action=revert-portal-2>
	<input type=hidden name=referer value=@referer@>
	<input type=hidden name=portal_id value=@portal_id@>
	<center>
	<input type=submit name="op_revert" value="Yes, Revert">
	</center>
</form>


