
<!-- template-place-element.adp begin -->
<form method=post action=@action_string@>

<table border=1 width="100%">
<tr>
<td align=left>

<multiple name=element_multi>
@element_multi.name@ - @element_multi.description@

<br>

    <if @element_multi:rowcount gt 1>
      <if @element_multi.rownum@ gt 1>
        <a href="@target_stub@-2?portal_id=@portal_id@&region=@region@&op=swap&element_id=@element_multi.element_id@&sort_key=@element_multi.sort_key@&direction=up&return_url=@return_url@"><img border=0 src="@dir@/arrow-up.gif" alt="move up"></a>
      </if>
      <if @element_multi:rowcount@ gt @element_multi.rownum@>
        <a href="@target_stub@-2?portal_id=@portal_id@&region=@region@&op=swap&element_id=@element_multi.element_id@&sort_key=@element_multi.sort_key@&direction=down&return_url=@return_url@"><img border=0 src="@dir@/arrow-down.gif" alt="move down"></a>
      </if>
    </if>

    <if @num_regions@ gt 1>
        <if @region@ eq 1>
        <a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=right&region=@region@&return_url=@return_url@"><img border=0 src="@dir@/arrow-right.gif" alt="move right"></a>
        </if>

        <if @region@ gt 1 and @region@ lt @num_regions@>
        <a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=left&region=@region@&return_url=@return_url@"><img border=0 src="@dir@/arrow-left.gif" alt="move left"></a>
        <a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=right&region=@region@&return_url=@return_url@"><img border=0 src="@dir@/arrow-right.gif" alt="move right"></a>
        </if>
        <if @region@ eq @num_regions@><a href="@target_stub@-2?portal_id=@portal_id@&op=move&element_id=@element_multi.element_id@&direction=left&region=@region@&return_url=@return_url@"><img border=0 src="@dir@/arrow-left.gif" alt="move left"></a>     
        </if>
    </if>

<p align=left>

Shown? Yes [<a href="@target_stub@-2?portal_id=@portal_id@&op=hide&element_id=@element_multi.element_id@&return_url=@return_url@">hide this element</a>]

<BR>

<if @element_multi.state@ ne "pinned">
User Movable? Yes, Unpinned [<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_pinned&element_id=@element_multi.element_id@&return_url=@return_url@">Pin</a>]
</if>
<else>User Movable? No, Pinned [<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_pinned&element_id=@element_multi.element_id@&return_url=@return_url@">Unpin</a>]
</else>

<BR>

<if @element_multi.hideable_p@ eq "t">
User Hideable? Yes [<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_hideable&element_id=@element_multi.element_id@&return_url=@return_url@">don't allow hiding</a>]
</if>
<else>User Hideable? No [<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_hideable&element_id=@element_multi.element_id@&return_url=@return_url@">allow hiding</a>]
</else>

<BR>

<if @element_multi.shadeable_p@ eq "t">
User Shadeable? Yes [<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_shadeable&element_id=@element_multi.element_id@&return_url=@return_url@">don't allow shading</nobr></a>]
</if>
<else>User Shadeable? No [<a href="@target_stub@-2?portal_id=@portal_id@&op=toggle_shadeable&element_id=@element_multi.element_id@&return_url=@return_url@">allow shading</a>]
</else>

<br>

    <include src=place-element-other-page &="element_multi" 
             target_stub=@target_stub@
             portal_id=@portal_id@
             page_id=@element_multi.page_id@>
    <br>
<P>

</multiple>



<if @show_avail_p@ ne 0>
<br>
@show_html@
</select><input type=submit name="op" value="Show Here">
<input type=hidden name=portal_id value=@portal_id@>
<input type=hidden name=page_id value=@page_id@>
<input type=hidden name=region value=@region@>
<input type=hidden name=return_url value=@return_url@>

</if>

</td>
</tr>
</table>

</form>

<!-- place-element.adp end -->
