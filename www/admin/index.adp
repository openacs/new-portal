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

<master src="@master_template@">
<property name="title">Welcome to Portals</property>


<if @users_portals:rowcount@ eq 0>
    You have not configured any portals. <a href="test-api">Create a portal</a> now	
</if>

<multiple name=users_portals>
    <if @users_portals:rowcount@ gt 0>
    Goto portal <b><a href="portal-show.tcl?portal_id=@users_portals.portal_id@">@users_portals.name@</a></b> (<b><a href="portal-config?portal_id=@users_portals.portal_id@">edit</a></b>|<b><a href="portal-delete.tcl?portal_id=@users_portals.portal_id@">delete</a></b>)
    </if>
    <br>
</multiple>

<if @users_portals:rowcount@ gt 0>
    <a href="test-api">Create another portal</a>
</if>
