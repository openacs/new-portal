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


<master src="portal-admin-master">
<property name=referer>@referer@</property>
<property name=name>@name@</property>

<a href=@page_url@?&portal_id=@portal_id@&referer=@referer@&anchor=#custom>Manage Custom Portlets</a>

@rendered_page;noquote@
<hr>

<a name="custom"><h2></a>Custom Portlets</h2> - Note custom portlets for portal templates are very fragile right now. Only use this during system set up before any portlets have been created with this template.  Better solution coming soon.
<include src="/packages/static-portlet/www/static-admin-portlet" package_id="@portal_id@" template_portal_id="@portal_id@" return_url="@return_url@">


<a name="revert"> </a><h2>Revert</h2>

<form name="op_revert" method=post action=revert-portal>
	<input type=hidden name=referer value=@return_url@>
	<input type=hidden name=portal_id value=@portal_id@>

	Revert to the default portal arrangement.

<center>
<input type=submit name="op_revert" value="Revert">
</form></center>

</if>
