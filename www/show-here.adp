<p>
<center>
<table class="z_light" cellpadding=0 cellspacing=0 border="0" bground="white" width="95%">
    <tr><td>
<h5>Unused Portlets</h5>
</td></tr>
<tr><td>
<if @show_avail_p@ ne 0>
<form method=post action=@action_string@>
<input type=hidden name=portal_id value=@portal_id@>
<input type=hidden name=region value=@region@>
<input type=hidden name=page_id value=@page_id@>
<input type=hidden name=return_url value=@return_url@>
<input type=hidden name="op" value="Show Here">
<input type=hidden name=anchor value=@page_id@>
@show_html@
</select>
<input type=submit name="submit" value="Add This Portlet Here">
</if>
<else>
<i>None. You can not add any portlets to this page because they are all in use.</i>
</else>
</center>
</form>
</td></tr>
</table>

