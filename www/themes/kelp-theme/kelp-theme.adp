<%

    #
   #  Copyright (C) 2001, 2002 MIT
   #
    #  This file is part of dotLRN.
    #
    #  dotLRN is free software; you can redistribute it and/or modify it under the
    #  terms of the GNU General Public License as published by the Free Software
    #  Foundation; either version 2 of the License, or (at your option) any later
    #  version.
    #
    #  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
    #  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    #  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
    #  details.
    #

%>
		<div id="scheda-container-sfondo"> 
		 <div id="scheda-container-00"> 
		  <div id="scheda-container">
		  <div id="scheda-container-top">
			 <div id="scheda-titolo">@name@</div>		
				<div id="scheda-valori">
                    <if @user_editable_p;literal@ true><a href="configure-element?element_id=@element_id@&amp;op=edit">&nbsp;<img borde	r=0 src="@dir@/00_headport_puls_edit.png" alt="edit"></a></if>
                    <if @shadeable_p;literal@ true><a href="configure-element?element_id=@element_id@&amp;op=shade">
	                   <if @shaded_p;literal@ false>&nbsp;<img border="0" src="@dir@/00_headport_puls_min.png" alt="shade"></a></if> 	
		               <else>
		               &nbsp;<img border="0" src="@dir@/00_headport_puls_max.png" alt="unshade"></a>
		               </else>
                  </if>
                  <if @hideable_p;literal@ true><a href="configure-element?element_id=@element_id@&amp;op=hide">&nbsp;<img border="0" src="@dir@/00_headport_puls_chiudi.png" alt="hide"></a></if>
			</div>		 
			</div>
			<%	 
                        set forums_name [lang::util::localize #forums-portlet.pretty_name#]
                        set groups_name [lang::util::localize #dotlrn.dotlrn_main_portlet_pretty_name#]
                        set day_summary_name [lang::util::localize #dotlrn-calendar.Day_Summary#]
                        set calendar_name    [lang::util::localize #calendar-portlet.pretty_name#]

                        set faqs_name [lang::util::localize #faq-portlet.pretty_name#]
                        set full_calendar_name [lang::util::localize #calendar-portlet.full_portlet_pretty_name#]
                        set documents_name [lang::util::localize #fs-portlet.pretty_name#]
                        set news_name [lang::util::localize #news-portlet.pretty_name#]
                        set survey_name [lang::util::localize #survey.Survey#]
                        set subgroups_name [lang::util::localize #dotlrn.subcommunities_pretty_plural#]
                        set lorsm_name [lang::util::localize #lorsm-portlet.Learning_materials#]

                   %>

                   <if @name@ eq @groups_name@>
                     <div id="scheda-immagine"><img border="0" src="resources/00_headport_imm_group.jpg" alt="hide"></div>
		   </if>

                   <if @name@ eq @lorsm_name@>
                     <div id="scheda-immagine"><img border="0" src="resources/00_headport_imm_lobj.jpg" alt="hide"></div>
		     </if>

                   <if @name@ eq @subgroups_name@>
                    <div id="scheda-immagine"><img border="0" src="resources/00_headport_imm_group.jpg" alt="hide"></div>
		   </if>
                   
		   <if @name@ eq @forums_name@>
                    <div id="scheda-immagine"><img border="0" src="resources/00_headport_imm_forum.jpg" alt="hide"></div>
		   </if> 
                   
		   <if @name@ eq @faqs_name@>
                     <div id="scheda-immagine"><img border="0" src="resources/00_headport_imm_faq.jpg" alt="hide"></div>
		   </if> 
                   
		   <if @name@ eq @day_summary_name@>
                     <div id="scheda-immagine"><img border="0" src="resources/00_headport_imm_calendar.jpg" alt="hide"></div>
		   </if> 
                   
		   <if @name@ eq @full_calendar_name@>
                     <div id="scheda-immagine"><img border="0" src="resources/00_headport_imm_calendar.jpg" alt="hide"></div>
		   </if>

                   <if @name@ eq @calendar_name@>
                     <div id="scheda-immagine"><img border="0" src="resources/00_headport_imm_calendar.jpg" alt="hide"></div>
		   </if>

                    <if @name@ eq @survey_name@>
                      <div id="scheda-immagine"><img border="0" src="resources/00_headport_imm_vuoto.jpg" alt="hide"></div>
		    </if>
                    
		    <if @name@ eq @documents_name@>
                      <div id="scheda-immagine"><img border="0" src="resources/00_headport_imm_vuoto.jpg" alt="hide"></div>
		    </if>         	

                  <div id="scheda-contenuto"><slave></div>
		  </div> 
		 </div>
		</div>
		<div id="scheda-footer">
		   <div id="scheda-footer-sin"></div>
		   <div id="scheda-footer-des"></div>		 
    </div>  

        





