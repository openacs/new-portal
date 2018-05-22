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


<!-- The ''nada'' theme, I'm a ''code'' hero!  -->

<!-- Element: '@name@' begin (text+html) -->
<table border="0" width="100%" cellpadding="0" cellspacing="0" >

<!-- Title/button bar begin -->
<tr>
<td>
  <table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tbody>
    <tr>
    <td class="element-header-text-plain">
      <big>
        <if @link_hideable_p;literal@ true and @hide_links_p;literal@ true>
          <strong>@name;noquote@</strong>
        </if>
        <else>
          <a href="@link@"><strong>@name@</strong></a>
        </else>
      </big>
    </td>

    <td class="element-header-buttons-plain">

      <if @user_editable_p;literal@ true>
          <a href="configure-element?element_id=@element_id@&amp;op=edit">[edit]</a>
      </if>

      <if @shadeable_p;literal@ true>
        <a href="configure-element?element_id=@element_id@&amp;op=shade">
          <if @shaded_p;literal@ false>
            [shade]</a>
          </if>
          <else>
            [unshade]</a>
          </else>
      </if>

      <if @hideable_p;literal@ true>
        <a href="configure-element?element_id=@element_id@&amp;op=hide"> [hide]</a>
      </if>

    </td>

    </tr>

    </tbody>

  </table>

</td>
<!-- title/button bar end -->
</tr>
<tr>
  <td align="left" valign="middle" bgcolor="#ffffff">
  <br>
  <!-- Content: '@name@' begin -->
  <slave>
  <!-- Content: '@name@' end @dir@ -->
  </td>
</tr>
</table>

<!-- Element: '@name@' end -->
