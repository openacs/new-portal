<!-- Portal Element '@name@' begin -->
<table class="element" border="0" cellpadding="1" cellspacing="0" width="100%">
<tr> 
  <td class="element-header-text">
    <if @link_hideable_p@ eq "t" and @hide_links_p@ eq "t">	
      <big><strong>@name@</strong></big>
    </if>
    <else>
      <!-- set up the link; a workaround for now-->
      <big><strong>@name@</strong></big>
    </else>
  </td>
  
  <td class="element-header-buttons" align="right">
    <if @user_editable_p@ eq "t">   
      <a href="configure-element?element_id=@element_id@&amp;op=edit">
        <img border=0 src="@dir@/e.gif" alt="edit"></a>
    </if>
    <if @shadeable_p@ eq "t">		
      <a href="configure-element?element_id=@element_id@&amp;op=shade">
        <if @shaded_p@ eq "f">
          <img border=0 src="@dir@/shade.gif" alt="shade"></a>
	</if>
	<else>
          <img border=0 src="@dir@/unshade.gif" alt="shade"></a>
	</else>
    </if>
    <if @hideable_p@ eq "t">		
      <a href="configure-element?element_id=@element_id@&amp;op=hide">
      <img border=0  src="@dir@/x.gif" alt="hide"></a>
    </if>
    <if @user_editable_p@ eq "f" and @shadeable_p@ eq "f" and 
     @hideable_p@ eq "f">
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

  <!-- Portal Element '@name@' Content begin -->
    <slave>
  <!-- Portal Element '@name@' Content end -->
</td>
</tr>
</table>

</td>
</tr>
</table>

  </td>
</tr>
</table>
<!-- Portal Element '@name@' end -->
