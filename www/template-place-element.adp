
<!-- template-place-element.adp begin -->
<form method=post action=@action_string@>
<input type=hidden name=portal_id value=@portal_id@>
<input type=hidden name=region value=@region@>

<table border=1 width="100%">
<tr>
<td align=left>

<multiple name=element_multi>
    @element_multi.name@ - @element_multi.description@
    <if @element_multi:rowcount gt 1>
      <if @element_multi.rownum@ gt 1>
        <a href="@target_stub@-2?portal_id=@portal_id@&region=@region@&op=swap&element_id=@element_multi.element_id@&sort_key=@element_multi.sort_key@&direction=up"><img border=0 src="@dir@/finger-up.gif" alt="move up"></a>
      </if>
      <if @element_multi:rowcount@ gt @element_multi.rownum@>
        <a href="@target_stub@-2?portal_id=@portal_id@&region=@region@&op=swap&element_id=@element_multi.element_id@&sort_key=@element_multi.sort_key@&direction=down"><img border=0 src="@dir@/finger-down.gif" alt="move down"></a>
      </if>
    </if>

    <if @region@ eq 1>
    <a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=right&region=@region@"><img border=0 src="@dir@/finger-right.gif" alt="move right"></a>
    </if>

    <if @region@ gt 1 and @region@ lt @num_regions@>
    <a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=left&region=@region@"><img border=0 src="@dir@/finger-left.gif" alt="move left"></a>
    <a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=right&region=@region@"><img border=0 src="@dir@/finger-right.gif" alt="move right"></a></if>
    <if @region@ eq @num_regions@><a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=left&region=@region@"><img border=0 src="@dir@/finger-left.gif" alt="move left"></a></if>
</if>

<p align=left>

Action: (<a href="@target_stub@-2?portal_id=@portal_id@&op=hide&element_id=@element_multi.element_id@">hide this element</a>)

<BR>

<if @state@ ne "locked">
Locked? unlocked (<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_lock&element_id=@element_multi.element_id@">set lock</a>)
</if>
<else>Locked? locked (<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_lock&element_id=@element_multi.element_id@">unlock</a>)
</else>

<BR>

<if @hideable_p@ eq "t">
Hideable? true (<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_hideable&element_id=@element_multi.element_id@">don't allow hiding</a>)
</if>
<else>Hideable? false (<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_hideable&element_id=@element_multi.element_id@">allow hiding</a>)
</else>

<BR>

<if @shadeable_p@ eq "t">
Shadeable? true (<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_shadeable&element_id=@element_multi.element_id@">don't allow shading</a>)
</if>
<else>Shadeable? false (<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_shadeable&element_id=@element_multi.element_id@">allow shading</a>)
</else>

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
