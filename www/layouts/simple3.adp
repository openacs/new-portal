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

<!-- A simple 3-column layout. -->

<table border="0" width="100%">
  <tr>
    <td valign="top" style="width:33%">
      <list name="element_ids_1">
        <include src="@element_src;literal@"
                 element_id="@element_ids_1:item;literal@"
                 action_string="@action_string;literal@"
                 theme_id="@theme_id;literal@"
                 region="1"
                 portal_id="@portal_id;literal@"
                 edit_p="@edit_p;literal@"
                 return_url="@return_url;literal@"
                 hide_links_p="@hide_links_p;literal@"
                 page_id="@page_id;literal@"
                 layout_id="@layout_id;literal@">
        <br>
      </list>
    </td>
    <td valign="top" style="width:33%">
      <list name="element_ids_2">
        <include src="@element_src;literal@"
                 element_id="@element_ids_2:item;literal@"
                 action_string="@action_string;literal@"
                 theme_id="@theme_id;literal@"
                 region="2"
                 portal_id="@portal_id;literal@"
                 edit_p="@edit_p;literal@"
                 return_url="@return_url;literal@"
                 hide_links_p="@hide_links_p;literal@"
                 page_id="@page_id;literal@"
                 layout_id="@layout_id;literal@">
        <br>
      </list>
    </td>
    <td valign="top" style="width:33%">
      <list name="element_ids_3">
        <include src="@element_src;literal@"
                 element_id="@element_ids_3:item;literal@"
                 action_string="@action_string;literal@"
                 theme_id="@theme_id;literal@"
                 region="3"
                 portal_id="@portal_id;literal@"
                 edit_p="@edit_p;literal@"
                 return_url="@return_url;literal@"
                 hide_links_p="@hide_links_p;literal@"
                 page_id="@page_id;literal@"
                 layout_id="@layout_id;literal@">
        <br>
      </list>
    </td>
  </tr>
</table>
