<master src="@master_template@">
<property name="title">Edit Portal: @portal.name@</property>



<form action="portal-update-name">
Change Name:
<P>
<input type="text" name="new_name" value="@portal.name@">
<%= [export_form_vars portal_id ] %>
<center>
<input type=submit value="Update Name">
</form>
</center>

<P>

<form method=get action="portal-config-2">
<%= [export_form_vars portal_id ] %>
<include src="@portal.template@" element_list="@element_list@" element_src="@element_src@">
</form>

<center>
<form method=get action="revert">
<%= [export_form_vars portal_id ] %>
<input type=submit value="Revert To The Default">
</form>
</center>

<form action="update_layout">
<if @layout_count@ gt 1>
<p>
Change Layout:
<br>

<table border=0>
<tr>

<multiple name="layouts">
<td>
  <table border=0>
  <tr>
  <td>
   <input type=radio name=layout_id value="@layouts.layout_id@" <if @layout_id@ eq @layouts.layout_id@>checked</if>>
    <b>@layouts.name@</b><br>
    <table border=0 align=center>
      <tr><td>
        <include src="@layouts.resource_dir@/example" resource_dir="@layouts.resource_dir@">
      </td></tr>
    </table>
    <font size=-1>
    @layouts.description@
    </font>
  </td>
  </tr>
  </table>
</td>
</multiple>

</tr>
</table>
</p>
</if>

<center>
<input type=submit value="Update Layout">
</center>
</form>

