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


<!-- Element: '@name@' begin (text+html) -->
<table border="0" width="100%" cellpadding="0" cellspacing="0" >
<tr> <td width="11" height="11" background="@dir@/tbl-tleft.gif"><img src="@dir@/tbl-tleft.gif" alt=" " width="11" height="11"></td>
<td width="100%" align="center" valign="top" background="@dir@/tbl-top.gif"><img src="@dir@/tbl-top.gif" alt=" " width="1" height="11"></td>
<td width="11" background="@dir@/tbl-tright.gif"><img src="@dir@/tbl-tright.gif" alt=" " width="11" height="11"></td>
</tr>

<!-- Title/button bar begin -->
<tr>
<td height="15" background="@dir@/tbl-left.gif" rowspan="2"><img src="@dir@/tbl-left.gif" alt=" " width="11" height="1"></td>
<td>
  <table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tbody>
    <tr>
    <td align="left" valign="middle" width="88%"  bgcolor="#eeeee7">
	<if @link_hideable_p;literal@ true and @hide_links_p;literal@ true>
          <strong>@name;noquote@</strong>
        </if><else>
          <a style="text-decoration: none" href="@link@"><strong>@name;noquote@</strong></a>
        </else>
    </td>
		<if @user_editable_p;literal@ true>
                  <td align="right" width="7%">

			<a href="configure-element?element_id=@element_id@&amp;op=edit"><img border="0" src="@dir@/edit.gif" alt="edit"></a></td>
		</if>

		<if @shadeable_p;literal@ true>
                  <td align="right" width="7%">
		    <a href="configure-element?element_id=@element_id@&amp;op=shade">
		    <if @shaded_p;literal@ false>
		    <img border="0" src="@dir@/shade.gif" alt="shade"></a></td>
		    </if><else>
		    <img border="0" src="@dir@/unshade.gif" alt="unshade"></a></td>
		    </else>
		</if>

		<if @hideable_p;literal@ true>
                  <td align="right" width="7%">
			<a href="configure-element?element_id=@element_id@&amp;op=hide"><img border="0" src="@dir@/x.gif" alt="hide"></a></td>
		</if>

                </tr>
              </tbody>
            </table>

</td>

<!-- title/button bar end -->



<td background="@dir@/tbl-right.gif" rowspan="2"><img src="@dir@/tbl-right.gif" alt=" " width="11" height="1"></td>
</tr>
<tr>
<td align="left" valign="middle" bgcolor="#ffffff">
<br>
<div style="font-family:verdana,arial,helvetica; color:#333333">
<!-- Content: '@name@' begin -->
<slave>
<!-- Content: '@name@' end @dir@ -->
</div>
</td>
</tr>
<tr>
<td height="11" background="@dir@/tbl-bleft.gif"><img src="@dir@/tbl-bleft.gif" alt=" " width="11" height="11"></td>
<td align="center" valign="top" background="@dir@/tbl-bottom.gif"><img src="@dir@/tbl-bottom.gif" alt=" " width="1" height="11"></td>
<td background="@dir@/tbl-bright.gif"><img src="@dir@/tbl-bright.gif" alt=" " width="11" height="11"></td>
</tr>
</table>

<!-- Element: '@name@' end -->
