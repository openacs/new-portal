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

<div class="portlet-wrapper">
<multiple name=element_multi>

<if @element_multi.rownum@ eq 1>
    <form method=post action=@action_string@>
        <input type=hidden name=portal_id value=@portal_id@>
        <input type=hidden name=region value=@region@>
        <input type=hidden name=page_id value=@page_id@>
</if>
<div class="portlet-header">
    <div class="portlet-title">
        <h1>@element_multi.name;noquote@</h1>
    </div>
    <div class="portlet-controls">
    
        <if @element_multi.state@ ne "pinned">
            <!-- hide/remove link and arrows begin - refactor with tempate -->

            <a href="@action_string@?anchor=@page_id@&portal_id=@portal_id@&op_hide=1&element_id=@element_multi.element_id@&return_url=@return_url@">
                <img src=@imgdir@/delete.gif border=0 alt="remove portlet">
            </a>

            <if @element_multi:rowcount gt 1>
                <if @element_multi.rownum@ gt 1>
                    <a href="@action_string@?anchor=@page_id@&portal_id=@portal_id@&region=@region@&op_swap=1&element_id=@element_multi.element_id@&direction=up&page_id=@page_id@&return_url=@return_url@">
                        <img border="0" src="@imgdir@/arrow-up.gif" alt="move up">
                    </a>
                </if>

                <if @element_multi:rowcount@ gt @element_multi.rownum@>
                    <a href="@action_string@?anchor=@page_id@&portal_id=@portal_id@&region=@region@&op_swap=1&element_id=@element_multi.element_id@&direction=down&page_id=@page_id@&return_url="@return_url@">
                        <img border="0" src="@imgdir@/arrow-down.gif" alt="move down">
                    </a>
                </if>
            </if>

            <if @num_regions@ gt 1>
                <if @region@ eq 1>
                    <a href="@action_string@?anchor=@page_id@&portal_id=@portal_id@&op_move=1&element_id=@element_multi.element_id@&direction=right&region=@region@&return_url=@return_url@">
                        <img border="0" src="@imgdir@/arrow-right.gif" alt="move right">
                    </a>
                </if>

                <if @region@ gt 1 and @region@ lt @num_regions@>
                    <a href="@action_string@?anchor=@page_id@&portal_id=@portal_id@&op_move=1&element_id=@element_multi.element_id@&direction=left&region=@region@&return_url=@return_url@">
                        <img border="0" src="@imgdir@/arrow-left.gif" alt="move left">
                    </a>
                    <a href="@action_string@?portal_id=@portal_id@&op_move=1&element_id=@element_multi.element_id@&direction=right&region=@region@&return_url=@return_url@">
                        <img border="0" src="@imgdir@/arrow-right.gif" alt="move right">
                    </a>
                </if>

                <if @region@ eq @num_regions@>
                    <a href="@action_string@?anchor=@page_id@&portal_id=@portal_id@&op_move=1&element_id=@element_multi.element_id@&direction=left&region=@region@&return_url=@return_url@">
                        <img border="0" src="@imgdir@/arrow-left.gif" alt="move left">
                    </a>
                </if>
            </if>

        </if>
    </div>
<!-- hide/remove link and arrows end -->
</form>
</div>
<div class="portlet">
    <include src=place-element-other-page &="element_multi" portal_id=@portal_id@ page_id=@page_id@ action_string=@action_string@ anchor=@page_id@ return_url=@return_url@>
</div>
</multiple>
</div>
<include src="show-here" portal_id=@portal_id@ action_string=@action_string@ region=@region@ page_id=@page_id@ anchor=@page_id@    return_url=@return_url@>


