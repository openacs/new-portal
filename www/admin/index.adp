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

Portals in the system:
<P>

<if @users_portals:rowcount@ eq 0>
    You have not configured any portals. 
</if>
<else>
  <ul>
    <multiple name=users_portals>
      <li><a href="portal-show.tcl?portal_id=@users_portals.portal_id@">@users_portals.name@</a> 
      <small>[<a href="portal-config?portal_id=@users_portals.portal_id@">edit</a>]</li></small>
    </multiple>
  </ul>
</else>
