<master src="@master_template@">
<property name="title">Welcome to Portals</property>


<if @users_portals:rowcount@ eq 0>
    You have not configured any portals. <a href="test-api">Create a portal</a> now	
</if>

<multiple name=users_portals>
    <if @users_portals:rowcount@ gt 0>
    Goto portal <b><a href="portal-show.tcl?portal_id=@users_portals.portal_id@">@users_portals.name@</a></b> (<b><a href="portal-config.tcl?portal_id=@users_portals.portal_id@">edit</a></b>|<b><a href="portal-delete.tcl?portal_id=@users_portals.portal_id@">delete</a></b>)
    </if>
    <br>
</multiple>

<if @users_portals:rowcount@ gt 0>
    <a href="test-api">Create another portal</a>
</if>
