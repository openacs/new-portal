
<table border=1 width="100%">
<tr>
<td align=center>

<multiple name=element_multi>
    <if @state@ ne "locked"><input type=checkbox name=element_ids value="@element_multi.element_id@"></if>
    @element_multi.name@
    <if @element_multi:rowcount gt 1>
      <if @element_multi.rownum@ gt 1>
        (<a href="@target_stub@-2?portal_id=@portal_id@&op=swap&element_id=@element_multi.element_id@&region=@region@&sort_key=@element_multi.sort_key@&direction=up">up</a>)
      </if>
      <if @element_multi:rowcount@ gt @element_multi.rownum@>
        (<a href="@target_stub@-2?portal_id=@portal_id@&op=swap&element_id=@element_multi.element_id@&region=@region@&sort_key=@element_multi.sort_key@&direction=down">down</a>)
      </if>
    </if>
    <br>
</multiple>

<if @immutable_p@ ne 1>
<br>

<if @add_avail_p@ ne 0>
@add_html@
</select><input type=submit name="op@region@" value="Add Here">
</if>


<if @region_count@ ne @all_count@ and @all_count@ gt 0>
  <input type=submit name="op@region@" value="Move All Checked Here"> <br>
</if>

</if>



<if @would_be_immutable_p@ eq 1>
<p>
<b>This region may not be edited by normal users.</b>
</p>
</if>

</td>
</tr>
</table>
