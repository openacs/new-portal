<form method=post action=@action_string@>
<input type=hidden name=portal_id value=@portal_id@>

<if @other_page_avail_p@ ne 0>
  <input type=hidden name=element_id value=@element_id@>
  <input type=submit name="op" value="Move to page">
  <select name=page_id>
  <multiple name=pages>
  <option value=@pages.page_id@>@pages.pretty_name@</option>
  </multiple>
  </select>

<!-- 
<a href="@target_stub@-2?portal_id=@portal_id@&op=move_to_page&element_id=@element_multi.element_id@&page_id=@pages.page_id@">move to @pages.pretty_name@</a>]</small>
-->

</if>

</form>
