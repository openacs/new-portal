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

<a href="@page_url@?&amp;portal_id=@portal_id@&amp;referer=@referer@&amp;anchor=#custom">#new-portal.lt_Manage_Custom_Portlet#</a>

@rendered_page;noquote@
<hr>

<a name="custom"><h2></a>#new-portal.Custom_Portlets#</h2>
<p> #new-portal.lt_-_Note_custom_portlet#</p>
<include src="/packages/static-portlet/www/static-admin-portlet" package_id="@portal_id;literal@" template_portal_id="@portal_id;literal@" return_url="@return_url;literal@">
