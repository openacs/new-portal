<div class="portlet-wrapper">
    <div class="portlet-header">
        <div class="portlet-title-no-controls">
            <h1>#new-portal.Unused_Portlets#</h1>
        </div>
    </div>
    <div class="portlet">
<if @show_avail_p@ ne 0>
    <form method="post" action="@action_string@">
        <div><input type="hidden" name="portal_id" value="@portal_id@"></div>
        <div><input type="hidden" name="region" value="@region@"></div>
        <div><input type="hidden" name="page_id" value="@page_id@"></div>
        <div><input type="hidden" name="return_url" value="@return_url@"></div>
        <div><input type="hidden" name="op_show_here" value="Show Here"></div>
        <div><input type="hidden" name="anchor" value="@page_id@"></div>
        <div>
          <!--<select>-->
            @show_html;noquote@
          </select>
        </div>
        <div>
          <input type="submit" name="op_show_here" value="#new-portal.lt_Add_This_Portlet_Here#">
        </div>
</form>
</if>
<else>
    <span class="small">#new-portal.lt_None_You_can_not_add_#</span>
</else>
</div>
</div>
