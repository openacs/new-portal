
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
	<if @link_hideable_p@ eq "t" and @hide_links_p@ eq "t">	
          <strong>@name@</strong>
        </if>
        <else>
          <a href=@link@><strong>@name@</strong></a>
        </else>
      </big>
    </td>

    <td class="element-header-buttons-plain">
          
      <if @user_editable_p@ eq "t">	
          <a href=configure-element?element_id=@element_id@&op=edit>[edit]</a>
      </if>
  
      <if @shadeable_p@ eq "t">		
        <a href=configure-element?element_id=@element_id@&op=shade>
          <if @shaded_p@ eq "f">
            [shade]</a>
          </if>
          <else>
            [unshade]</a>
          </else>
      </if>
  
      <if @hideable_p@ eq "t">		
        <a href=configure-element?element_id=@element_id@&op=hide> [hide]</a>
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
