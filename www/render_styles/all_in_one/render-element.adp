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

<master src="@element.filename@">
<property name="name">@element.name;literal@</property>
<property name="dir">@element.resource_dir;literal@</property>
<property name="element_id">@element.element_id;literal@</property>
<property name="link">@element.link;literal@</property>
<property name="shadeable_p">@element.shadeable_p;literal@</property>
<property name="shaded_p">@element.shaded_p;literal@</property>
<property name="hideable_p">@element.hideable_p;literal@</property>
<property name="user_editable_p">@element.user_editable_p;literal@</property>
<property name="link_hideable_p">@element.link_hideable_p;literal@</property>
<property name="hide_links_p">@hide_links_p;literal@</property>

<h1>@element.name@</h1>
@element.content;noquote@
