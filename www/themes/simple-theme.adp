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

<table class="element" border="0" cellpadding="1" cellspacing="0" width="100%">
<tr>
  <td class="element-header-text">
    <if @link_hideable_p;literal@ true and @hide_links_p;literal@ true>
      <big><strong>@name;noquote@</strong></big>
    </if>
    <else>
      <!-- set up the link; a workaround for now-->
      <big><strong>@name@</strong></big>
    </else>
  </td>

  <td class="element-header-buttons" align="right">
    <if @user_editable_p;literal@ true>
      <a href="configure-element?element_id=@element_id@&amp;op=edit">
        <img border="0" src="@dir@/e.gif" alt="edit"></a>
    </if>
    <if @shadeable_p;literal@ true>
      <a href="configure-element?element_id=@element_id@&amp;op=shade">
        <if @shaded_p;literal@ false>
          <img border="0" src="@dir@/shade.gif" alt="shade"></a>
    </if>
    <else>
          <img border="0" src="@dir@/unshade.gif" alt="shade"></a>
    </else>
    </if>
    <if @hideable_p;literal@ true>
      <a href="configure-element?element_id=@element_id@&amp;op=hide">
      <img border="0"  src="@dir@/x.gif" alt="hide"></a>
    </if>
    <if @user_editable_p;literal@ false and @shadeable_p;literal@ false and
     @hideable_p;literal@ false>
     &nbsp;
    </if>
  </td>
</tr>

<tr>
  <td colspan="2">

<table border="0" bgcolor="black" cellpadding="1" cellspacing="0" width="100%">
<tr>
<td>
<table border="0" bgcolor="white" cellpadding="2" cellspacing="0" width="100%">
<tr>
<td>

    <slave>
</td>
</tr>
</table>

</td>
</tr>
</table>

  </td>
</tr>
</table>
