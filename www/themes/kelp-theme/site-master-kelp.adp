<master src="/www/blank-master">
  <if @title@ not nil>
    <property name="doc(title)">@title;literal@</property>
  </if>
  <if @signatory@ not nil>
    <property name="signatory">@signatory;literal@</property>
  </if>
  <if @focus@ not nil>
    <property name="focus">@focus;literal@</property>
  </if>


<!-- Header -->

<div id="site-header">
   <div class="system-name">
      <if @system_url@ not nil><a href="@system_url@">@system_name@</a></if>
      <else>@system_name@</else>
   </div> <!-- system-name -->
</div> <!-- site-header -->

<!--  [ HEADER ] Added by www.sii.it -->
<div id="header">
   <div id="header-00-gen">       
      <div id="header-top-gen">
	     <div id="header-top-logo">
            <a href="#"><img border="0" src="/resources/logo-dotlrn.png"></a>
</div>		 
      </div> <!-- header-top-gen -->  
   </div> <!-- header-00-gen -->	
   <div id="header-dati">
	     <div id="header-dati-des">
            <div class="action-list permanent-navigation">
               <ul>
                  <li><img border="0" src="/resources/02_header_dati_members.png" class="imm-header"><a href="@whos_online_url@">@num_users_online@ <if @num_users_online@ eq 1>member</if><else>members</else> online</a></li>
                  <if @admin_url@ not nil>
                     |<li><img border="0" src="/resources/02_header_dati_cp.png" class="imm-header"><a href="@admin_url@" title="#acs-subsite.Site_wide_administration#">#acs-subsite.Admin#</a></li>
                  </if>
			      <if @num_of_locales@ gt 1>
				     |<li><img border="0" src="/resources/02_header_dati_ilocal.png" class="imm-header"><a href="@change_locale_url@">#acs-subsite.Change_locale_label#</a></li>
			      </if>
                  <else>
                  <if @locale_admin_url@ not nil>
				     |<li><img border="0" src="/resources/02_header_dati_ilocal.png" class="imm-header"><a href="@locale_admin_url@">Install locales</a></li>
                  </if>
                  </else>		   
                  <if @pvt_home_url@ not nil>
                     |<li><img border="0" src="/resources/02_header_dati_account.png" class="imm-header"><a href="@pvt_home_url@" title="#acs-subsite.Change_pass_email_por#">@pvt_home_name@</a></li>
                  </if>
                  <if @login_url@ not nil>
                     |<li><img border="0" src="/resources/02_header_dati_log.png" class="imm-header"><a href="@login_url@" title="#acs-subsite.Log_in_to_system#">#acs-subsite.Log_In#</a></li>
                  </if>
                  <if @logout_url@ not nil>
                     |<li><img border="0" src="/resources/02_header_dati_log.png" class="imm-header"><a href="@logout_url@" title="#acs-subsite.Logout_from_system#">#acs-subsite.Logout#</a></li>
                  </if>
               </ul>
            </div> <!-- action-list permanent-navigation -->   
	   </div> <!-- header-dati-des -->
	  </div> <!-- header-dati -->
 </div>
<!-- / [ HEADER ] Added by www.sii.it -->

<!-- / Header -->

<div style="clear: both;"></div>

<!--  [ CONTAINER] Added by www.sii.it -->
<div id="container">
   <div id="container-00-gen"> 
      <div id="container-gen">
         <div id="container-top-gen">
            <div id="container-puls-home"><a href="#"><img border="0" src="/resources/01_cont_puls_kelp.png"></a></div>
		    <div id="container-valori-gen">
	           <div class="user-greeting">
		          <if @untrusted_user_id@ ne 0>#acs-subsite.Welcome_user#</if>
                  <else>#acs-subsite.Not_logged_in#</else>
	           </div> <!-- user-greeting -->
            </div> <!-- container-valori-gen -->
         </div> <!-- container-top-gen -->  
      </div> <!-- container-gen -->
   </div> <!-- container-00-gen -->	   
   <div id="container-shadows-des">
      <div id="container-shadows-sin">    
         <slave>
       <!--   <div id="site-footer">
            <div class="action-list">
               <ul>
                  <if @num_of_locales@ gt 1>
				     <li><a href="@change_locale_url@">#acs-subsite.Change_locale_label#</a></li>
				  </if>
                  <else>
                  <if @locale_admin_url@ not nil>
				     <li><a href="@locale_admin_url@">Install locales</a></li>
                  </if>
                  </else>
               </ul>
            </div> <!-- action-list  
         </div> <!-- site-footer -->
      </div> <!-- container-shadows-des -->
      <div id="container-footer">	 
         <div id="container-footer-sin">	   
            <div id="container-footer-des"></div>		   
         </div> <!-- container-footer-sin -->
      </div> <!-- container-footer -->
   </div> <!-- container-shadows-des -->
<!--  [ CONTAINER ] Added by www.sii.it -->

<if @curriculum_bar_p;literal@ true>
  <p><include src="/packages/curriculum/lib/bar" >
</if>