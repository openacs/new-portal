
<!-- The ''nada'' theme, I'm a ''code'' hero!  -->

<!-- Element: '@name@' begin (text+html) -->
<table border="0" width="100%" cellpadding="0" cellspacing="0" >

<!-- Title/button bar begin -->
<tr>
<td>
  <table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tbody>
    <tr>
    <td align=left valign=middle width=88%  bgcolor="#eeeee7">
      <font face="verdana,arial,helvetica" size="+1">
	<if @link_hideable_p@ eq "t" and @hide_links_p@ eq "t">	
          <b>@name@</b>
        </if><else>
          <a style="text-decoration: none" href=@link@><b>@name@</b></a>
        </else>
      </font>
    </td>



		<if @user_editable_p@ eq "t">	
                  <td align=right width=7%>
			<a href=configure-element?element_id=@element_id@&op=edit>[edit]</a></td>
		</if>

		<if @shadeable_p@ eq "t">		
                  <td align=right width=7%>
		    <a href=configure-element?element_id=@element_id@&op=shade>
		    <if @shaded_p@ eq "f"> [shade]</a></td>
		    </if><else> [unshade]</a></td>
		    </else>
		</if>

		<if @hideable_p@ eq "t">		
                  <td align=right width=7%>
			<a href=configure-element?element_id=@element_id@&op=hide> [hide]</a></td>
		</if>

                </tr>
              </tbody>
            </table>

</td>
<!-- title/button bar end -->
</tr>
<tr>
<td align="left" valign="middle" bgcolor="#ffffff">
<br>
<div align="justify">
<font face="verdana,arial,helvetica" color="#333333">
<!-- Content: '@name@' begin -->
<slave>
<!-- Content: '@name@' end @dir@ -->
</font>
</td>
</tr>
</table>

<!-- Element: '@name@' end -->
