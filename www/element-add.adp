<master src="@master_template@">
<property name=title>Add Element</property>
<property name=context_bar>"Add Element"</property>

<form method=get action="element-add-2">
<%= [export_form_vars portal_id region] %>

<multiple name="datasources">
   <input type=radio name=datasource_id value="@datasources.datasource_id@">
    <b>@datasources.name@</b> @datasources.description@<br>
</multiple>

<p>
What should this element be named (XXX - fixme unique names):<br>
<b>Name:</b> <input type="text" name="name" value="Untitled">
</p>


<table border=0>
<tr>
<td>
  <input type=submit value="Add">
  </form>
</td>
<td>
  <form method=get action="element-layout">
  <%= [export_form_vars portal_id region name] %>
  <input type=submit value="Cancel">
  </form>
</td>
</tr>
</table>
