<!-- Portal Element '@name@' begin -->
<table class="element">
<tr>
 
  <td class="element_header_text">
    <if @link_hideable_p@ eq "t" and @hide_links_p@ eq "t">	
      <b>@name@</b>
    </if>
    <else>
      <!-- set up the link; a workaround for now-->
        <b>@name@</b>
    </else>
  </td>
  
  <td class="element_header_buttons" align=right>
    <if @user_editable_p@ eq "t">   
      <a href="configure-element?element_id=@element_id@&op=edit">
        <img src="@dir@/e.gif" alt="edit"></a>
    </if>
    <if @shadeable_p@ eq "t">		
      <a href="configure-element?element_id=@element_id@&op=shade">
        <if @shaded_p@ eq "f">
          <img src="@dir@/shade.gif" alt="shade"></a>
	</if>
	<else>
          <img src="@dir@/unshade.gif" alt="shade"></a>
	</else>
    </if>
    <if @hideable_p@ eq "t">		
      <a href="configure-element?element_id=@element_id@&op=hide">
      <img src="@dir@/x.gif" alt="hide"></a>
    </if>
  </td>
</tr>

<tr>
  <td class="element_content" colspan=2>
  <!-- Portal Element '@name@' Content begin -->
    <slave>
  <!-- Portal Element '@name@' Content end -->
  </td>
</tr>
</table>
<!-- Portal Element '@name@' end -->
