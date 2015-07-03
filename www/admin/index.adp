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

<master>
<property name="doc(title)">Welcome to Portals</property>

<P>

Portals in the system:

<P>

<if @portals:rowcount@ eq 0>
    You have not configured any portals. 
</if>
<else>
  <ul>
    <multiple name=portals>
      <li><a href="portal-show.tcl?portal_id=@portals.portal_id@&amp;referer=index">@portals.name@ (@portals.portal_id@ | @portals.template_id@)</a> 
      <small>[<a href="portal-config?portal_id=@portals.portal_id@&amp;referer=index">edit</a>]</li></small>
    </multiple>
  </ul>
</else>
