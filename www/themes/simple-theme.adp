<!-- Element: '@name@' begin (application/x-ats) -->
    <table border=0 bgcolor=#cc0000 cellpadding=1 cellspacing=0 width=100% class="portal_border">
    <tr>
      <td>
        <table border=0 cellpadding=3 width=100% cellspacing=0>
	  <tr>
            <td class="portal_header" bgcolor="#cc0000" align=left>
              <a style="text-decoration: none" href=@link@>
	      <font face="arial,helvetica" size="+1" color="#cccccc">
	       <b>@name@</b></font></a>
            </td>
            <td align=right class="portal_header" bgcolor="#cc0000">
		<!-- include title buttons here -->
		<if @user_editable_p@ eq "t">	
		  <a href=configure-element?element_id=@element_id@&op=edit>
	          <img border=0 src="@dir@/e.gif" alt="edit"></a>
		</if>
		<if @shadeable_p@ eq "t">		
   		  <a href=configure-element?element_id=@element_id@&op=shade>
		  <if @shaded_p@ eq "f">
	            <img border=0 src="@dir@/shade.gif" alt="shade"></a>
		  </if>
		  <else>
	              <img border=0 src="@dir@/unshade.gif" alt="shade"></a>
		  </else>
		</if>
		<if @hideable_p@ eq "t">		
		  <a href=configure-element?element_id=@element_id@&op=hide>
		  <img border=0 src="@dir@/x.gif" alt="hide"></a>
		</if>
            </td>
	  </tr>

          <tr>
            <td class="portal_body" colspan=2 bgcolor="#ffffff">
<!-- Content: '@name@' begin -->
	      <slave>
<!-- Content: '@name@' end -->
            </td>
          </tr>
	</table>
	</td>
    </tr>
  </table>
<!-- Element: '@name@' end -->
