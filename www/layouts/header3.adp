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

  <!-- A simple 2-column thingy. -->
  <table border="0" width="100%">
    <tr>
      <td colspan="3" valign="top">
        <list name="element_ids_i1">
          <include src="@element_src;literal@" element_id="@element_ids_i1;literal@" region="i1"><br>
        </list>
      </td>
    </tr>
    <tr>
      <td valign="top" width="33%">
        <list name="element_ids_1">
          <include src="@element_src;literal@" element_id="@element_ids_1;literal@" region="1"><br>
        </list>
      </td>
      <td valign="top" width="34%">
        <list name="element_ids_2">
          <include src="@element_src;literal@" element_id="@element_ids_2;literal@" region="2"><br>
        </list>
      </td>
      <td valign="top" width="33%">
        <list name="element_ids_3">
          <include src="@element_src;literal@" element_id="@element_ids_3;literal@" region="3"><br>
        </list>
      </td>
    </tr>
  </table>
