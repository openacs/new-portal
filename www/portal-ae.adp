<!-- www/admin/portal-ae.adp-->

<master src="@master_template@">
<property name="title">@title@</property>

<form action="portal-ae-2">
<%= [export_form_vars portal_id] %>

<p>
First, tell us what this portal should be named:<br>
<b>Name:</b> <input type="text" name="name" value="@name@">
</p>


<if @layout_count@ gt 1>
<p>
Next, tell us what sort of layout should be used for this portal

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
<input type=submit value="Next &gt;&gt;">
</center>
</form>
