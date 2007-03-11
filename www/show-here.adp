<div class="portlet-wrapper">
    <div class="portlet-header">
        <div class="portlet-title-no-controls">
            <h1>#new-portal.Unused_Portlets#</h1>
        </div>
    </div>
    <div class="portlet">
<if @show_avail_p@ ne 0>
    <form method="post" action="@action_string@">
        <input type=hidden name=portal_id value=@portal_id@>
        <input type=hidden name=region value=@region@>
        <input type=hidden name=page_id value=@page_id@>
        <input type=hidden name=return_url value=@return_url@>
        <input type=hidden name="op_show_here" value="Show Here">
        <input type=hidden name=anchor value=@page_id@>
        <!--<select>-->
            @show_html;noquote@
        </select>
    <input type=submit name="op_show_here" value="#new-portal.lt_Add_This_Portlet_Here#">
</if>
<else>
    <span class="small">#new-portal.lt_None_You_can_not_add_#</span>
</else>
</form>
</div>
</div>
