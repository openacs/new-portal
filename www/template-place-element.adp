<%

    #
    #  Copyright (C) 2001, 2002 MIT
    #
    #  This file is part of dotLRN.
    #
    #  dotLRN is free software; you can redistribute it and/or modify it under the
    #  terms of the GNU General Public License as published by the Free Software
    #  Foundation; either version 2 of the License, or (at your option) any later
    #  version.
    #
    #  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
    #  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    #  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
    #  details.
    #

%>

<!-- template-place-element.adp begin -->
<form method=post action=@action_string@>

<table border=1 width="100%">
<tr>
<td align=left>

<multiple name=element_multi>
<hr>

@element_multi.name@ - @element_multi.description@</a>

<br>

<!-- refactor with other? -->

    <if @element_multi:rowcount gt 1>
      <if @element_multi.rownum@ gt 1>
        <a href="@target_stub@-2?portal_id=@portal_id@&region=@region@&op_swap=1&element_id=@element_multi.element_id@&sort_key=@element_multi.sort_key@&direction=up&return_url=@return_url@&anchor=@page_id@"><img border=0 src="@dir@/arrow-up.gif" alt="move up"></a>
      </if>
      <if @element_multi:rowcount@ gt @element_multi.rownum@>
        <a href="@target_stub@-2?portal_id=@portal_id@&region=@region@&op_swap=1&element_id=@element_multi.element_id@&sort_key=@element_multi.sort_key@&direction=down&return_url=@return_url@&anchor=@page_id@"><img border=0 src="@dir@/arrow-down.gif" alt="move down"></a>
      </if>
    </if>

    <if @num_regions@ gt 1>
        <if @region@ eq 1>
        <a href="@target_stub@-2?portal_id=@portal_id@&op_move=1&element_id=@element_multi.element_id@&direction=right&region=@region@&return_url=@return_url@&anchor=@page_id@"><img border=0 src="@dir@/arrow-right.gif" alt="move right"></a>
        </if>

        <if @region@ gt 1 and @region@ lt @num_regions@>
        <a href="@target_stub@-2?portal_id=@portal_id@&op_move=1&element_id=@element_multi.element_id@&direction=left&region=@region@&return_url=@return_url@&anchor=@page_id@"><img border=0 src="@dir@/arrow-left.gif" alt="move left"></a>
        <a href="@target_stub@-2?portal_id=@portal_id@&op_move=1&element_id=@element_multi.element_id@&direction=right&region=@region@&return_url=@return_url@&anchor=@page_id@"><img border=0 src="@dir@/arrow-right.gif" alt="move right"></a>
        </if>
        <if @region@ eq @num_regions@><a href="@target_stub@-2?portal_id=@portal_id@&op_move=1&element_id=@element_multi.element_id@&direction=left&region=@region@&return_url=@return_url@&anchor=@page_id@"><img border=0 src="@dir@/arrow-left.gif" alt="move left"></a>     
        </if>
    </if>

<!-- refactor with other? -->

<p align=left>

Shown? Yes [<a href="@target_stub@-2?portal_id=@portal_id@&op_hide=1&element_id=@element_multi.element_id@&return_url=@return_url@&anchor=@page_id@">hide this element</a>]

<BR>

<if @element_multi.state@ ne "pinned">
User Movable? Yes, Unpinned [<a href="@target_stub@-2?portal_id=@portal_id@&op_toggle_pinned=1&element_id=@element_multi.element_id@&return_url=@return_url@&anchor=@page_id@">Pin</a>]
</if>
<else>User Movable? No, Pinned [<a href="@target_stub@-2?portal_id=@portal_id@&op_toggle_pinned=1&element_id=@element_multi.element_id@&return_url=@return_url@&anchor=@page_id@">Unpin</a>]
</else>

<BR>

<if @element_multi.hideable_p@ eq "t">
User Hideable? Yes [<a href="@target_stub@-2?portal_id=@portal_id@&op_toggle_hideable=1&element_id=@element_multi.element_id@&return_url=@return_url@&anchor=@page_id@">don't allow hiding</a>]
</if>
<else>User Hideable? No [<a href="@target_stub@-2?portal_id=@portal_id@&op_toggle_hideable=1&element_id=@element_multi.element_id@&return_url=@return_url@&anchor=@page_id@">allow hiding</a>]
</else>

<BR>

<if @element_multi.shadeable_p@ eq "t">
User Shadeable? Yes [<a href="@target_stub@-2?portal_id=@portal_id@&op_toggle_shadeable=1&element_id=@element_multi.element_id@&return_url=@return_url@&anchor=@page_id@&anchor=@page_id@">don't allow shading</nobr></a>]
</if>
<else>User Shadeable? No [<a href="@target_stub@-2?portal_id=@portal_id@&op_toggle_shadeable=1&element_id=@element_multi.element_id@&return_url=@return_url@&anchor=@page_id@">allow shading</a>]
</else>

</form>

    <include src=place-element-other-page &="element_multi" 
             target_stub=@target_stub@
             portal_id=@portal_id@
             page_id=@element_multi.page_id@
             return_url=@return_url@
             action_string=@action_string@>


</multiple>

<if @show_avail_p@ ne 0>
<form method=post action=@action_string@>

@show_html;noquote@
</select><input type=submit name="op_show_here" value="Show Here">
<input type=hidden name=portal_id value=@portal_id@>
<input type=hidden name=page_id value=@page_id@>
<input type=hidden name=region value=@region@>
<input type=hidden name=return_url value=@return_url@
<input type=hidden name=anchor value=@page_id@>
</form>

</if>

</td>
</tr>
</table>



