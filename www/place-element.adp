
<!-- place-element.adp begin -->
<form method=post action=@action_string@>
<input type=hidden name=portal_id value=@portal_id@>
<input type=hidden name=region value=@region@>

<table border=1 width="100%">
<tr>
<td align=center>

<multiple name=element_multi>
    @element_multi.name@
    <if @element_multi:rowcount gt 1>
      <if @element_multi.rownum@ gt 1>
        <a href="@target_stub@-2?portal_id=@portal_id@&region=@region@&op=swap&element_id=@element_multi.element_id@&sort_key=@element_multi.sort_key@&direction=up"><img border=0 src="@dir@/finger-up.gif" alt="move up"></a>
      </if>
      <if @element_multi:rowcount@ gt @element_multi.rownum@>
        <a href="@target_stub@-2?portal_id=@portal_id@&region=@region@&op=swap&element_id=@element_multi.element_id@&sort_key=@element_multi.sort_key@&direction=down"><img border=0 src="@dir@/finger-down.gif" alt="move down"></a>
      </if>
    </if>

    <if @state@ ne "locked">
	<if @region@ eq 1>
	<a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=right&region=@region@"><img border=0 src="@dir@/finger-right.gif" alt="move right"></a>
	</if>
	<if @region@ gt 1 and @region@ lt @num_regions@>
	<a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=left&region=@region@"><img border=0 src="@dir@/finger-left.gif" alt="move left"></a>
	<a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=right&region=@region@"><img border=0 src="@dir@/finger-right.gif" alt="move right"></a>
	</if>
	<if @region@ eq @num_regions@><a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=left&region=@region@"><img border=0 src="@dir@/finger-left.gif" alt="move left"></a>
	</if>

(<a href="@target_stub@-2?portal_id=@portal_id@&op=hide&element_id=@element_multi.element_id@">hide</a>)    
    </if>





    <br>
</multiple>



<if @show_avail_p@ ne 0>
<br>
@show_html@
</select><input type=submit name="op" value="Show Here">
</if>

</td>
</tr>
</table>

</form>

<!-- place-element.adp end -->
