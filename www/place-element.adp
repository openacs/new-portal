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
        <div><input type="hidden" name="portal_id" value="@portal_id@"></div>
        <div><input type="hidden" name="region" value="@region@"></div>
        <div><input type="hidden" name="page_id" value="@page_id@"></div>
</if>
  <div class="portlet-header">
    <div class="portlet-title">
        <h1>@element_multi.name;noquote@</h1>
    </div>
    <div class="portlet-controls">
    
        <if @element_multi.state@ ne "pinned">
            <!-- hide/remove link and arrows begin - refactor with tempate -->

            <!-- hide_remove_url -->
            <span class="screen-reader-only">[</span>
            <a href="@element_multi.hide_remove_url@" title="#new-portal.remove_portlet#">
                <img src="@imgdir@/delete.gif" style="border:0" alt="#new-portal.remove#">
            </a>
            <span class="screen-reader-only">]</span>

            <if @element_multi:rowcount gt 1>
                <if @element_multi.rownum@ gt 1>
                    <!-- move_up_url -->
                <span class="screen-reader-only">[</span>
                    <a href="@element_multi.move_up_url@" title="#new-portal.move_portlet_up#">
                        <img style="border:0" src="@imgdir@/arrow-up.gif" alt="#new-portal.move_up#">
                    </a>
                <span class="screen-reader-only">]</span>
                </if>

                <if @element_multi:rowcount@ gt @element_multi.rownum@>
                    <!-- move_down_url -->
                <span class="screen-reader-only">[</span>
                    <a href="@element_multi.move_down_url@" title="#new-portal.move_portlet_down#">
                        <img style="border:0" src="@imgdir@/arrow-down.gif" alt="#new-portal.move_down#">
                    </a>
                <span class="screen-reader-only">]</span>
                </if>
            </if>

            <if @num_regions@ gt 1>
                <if @region@ eq 1>
                    <!-- move_right_with_anchor_url -->
                <span class="screen-reader-only">[</span>
                    <a href="@element_multi.move_right_wa_url@" title="#new-portal.move_portlet_right#">
                        <img style="border:0" src="@imgdir@/arrow-right.gif" alt="#new-portal.move_right#">
                    </a>
                <span class="screen-reader-only">]</span>
                </if>

                <if @region@ gt 1 and @region@ lt @num_regions@>
                    <!-- move_left_with_anchor_url -->
                <span class="screen-reader-only">[</span>
                    <a href="@element_multi.move_left_wa_url@" title="#new-portal.move_portlet_left#">
                        <img style="border:0" src="@imgdir@/arrow-left.gif" alt="#new-portal.move_left#">
                    </a>
                <span class="screen-reader-only">]</span>
                    <!-- move_right_url -->
                <span class="screen-reader-only">[</span>
                    <a href="@element_multi.move_right_url@" title="#new-portal.move_portlet_right#">
                        <img style="border:0" src="@imgdir@/arrow-right.gif" alt="#new-portal.move_right#">
                    </a>
                <span class="screen-reader-only">]</span>
                </if>

                <if @region@ eq @num_regions@>
                    <!-- move_left_with_anchor_url -->
                <span class="screen-reader-only">[</span>
                    <a href="@element_multi.move_left_wa_url@" title="#new-portal.move_portlet_left#">
                        <img style="border:0" src="@imgdir@/arrow-left.gif" alt="#new-portal.move_left#">
                    </a>
                <span class="screen-reader-only">]</span>
                </if>
            </if>
        </if>
    </div> <!-- portlet-controls -->
   </div> <!-- portlet-header -->
   <if @element_multi.rownum@ eq 1>
     </form>
   </if>
   <div class="portlet">
     <include src=place-element-other-page &="element_multi" portal_id="@portal_id;literal@" page_id="@page_id;literal@" action_string="@action_string;literal@" anchor="@page_id;literal@" return_url="@return_url;literal@">
   </div>
  </multiple>
</div> <!-- portlet-wrapper -->

<include src="show-here" portal_id="@portal_id;literal@" action_string="@action_string;literal@" region="@region;literal@" page_id="@page_id;literal@" anchor="@page_id;literal@"    return_url="@return_url;literal@">


