<master src="@master_template@">
<property name="title">Edit Portal - Place Elements</property>

<form method=get action="element-layout-2">
<%= [export_form_vars portal_id ] %>
<include src="@portal.template@" element_list="@element_list@" element_src="@element_src@">
</form>

<center>
<form method=get action="revert">
<%= [export_form_vars portal_id ] %>
<input type=submit value="Revert To The Default">
</form>
</center>
