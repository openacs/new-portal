<master src="@master_template@">
<property name=title>Add Element</property>
<property name=context_bar>"Add Element"</property>

<form method=get action="element-add-2">
<%= [export_form_vars portal_id region] %>

Elements that you aren't currently using:<br>
<select name=element_ids size=8 multiple>
<multiple name=element_ids>
  <option value=@element_ids.element_id@>@element_ids.name@</option>
</multiple>
</select>

<table border=0>
<tr>
<td>
  <input type=submit value="Add">
  </form>
</td>
<td>
  <form method=get action="element-layout">
  <%= [export_form_vars portal_id region] %>
  <input type=submit value="Cancel">
  </form>
</td>
</tr>
</table>
