
<!-- place-element.adp begin -->
<form method=post action=@action_string@>
<input type=hidden name=portal_id value=@portal_id@>
<input type=hidden name=region value=@region@>

<table border=1 width="100%">
<tr>
<td align=center>

<multiple name=element_multi>
    <if @state@ ne "locked"><input type=checkbox name=element_ids value="@element_multi.element_id@"></if>
    @element_multi.name@
    <if @element_multi:rowcount gt 1>
      <if @element_multi.rownum@ gt 1>
        (<a href="@target_stub@-2?portal_id=@portal_id@&region=@region@&op=swap&element_id=@element_multi.element_id@&sort_key=@element_multi.sort_key@&direction=up">up</a>)
      </if>
      <if @element_multi:rowcount@ gt @element_multi.rownum@>
        (<a href="@target_stub@-2?portal_id=@portal_id@&region=@region@&op=swap&element_id=@element_multi.element_id@&sort_key=@element_multi.sort_key@&direction=down">down</a>)
      </if>
    </if>
(<a href="@target_stub@-2?portal_id=@portal_id@&op=hide&element_id=@element_multi.element_id@">hide</a>)
    <br>
</multiple>

<br>

<if @show_avail_p@ ne 0>
@show_html@
</select><input type=submit name="op" value="Show Here">
</if>


<if @region_count@ ne @all_count@ and @all_count@ gt 0>
  <input type=submit name="op" value="Move All Checked Here"> <br>
</if>

</td>
</tr>
</table>

</form>

<!-- place-element.adp end -->
