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
                    <if @user_editable_p@ eq "t"><a href=configure-element?element_id=@element_id@&op=edit>&nbsp;<img borde	r=0 src="@dir@/00_headport_puls_edit.png" alt="edit"></a></if>
                    <if @shadeable_p@ eq "t"><a href=configure-element?element_id=@element_id@&op=shade>
	                   <if @shaded_p@ eq "f">&nbsp;<img border=0 src="@dir@/00_headport_puls_min.png" alt="shade"></a></if> 	
		               <else>
		               &nbsp;<img border=0 src="@dir@/00_headport_puls_max.png" alt="unshade"></a>
		               </else>
                  </if>
                  <if @hideable_p@ eq "t"><a href=configure-element?element_id=@element_id@&op=hide>&nbsp;<img border=0 src="@dir@/00_headport_puls_chiudi.png" alt="hide"></a></if>
			</div>		 
			</div>
		 <switch @name@>			
			    <case value="Groups">
				<div id="scheda-immagine"><img border=0 src="resources/00_headport_imm_group.jpg" alt="hide"></div>
			    </case>
			    <case value="Forums">
				<div id="scheda-immagine"><img border=0 src="resources/00_headport_imm_forum.jpg" alt="hide"></div>
			    </case>
			    <case value="Frequently Asked Questions (FAQs)">
				<div id="scheda-immagine"><img border=0 src="resources/00_headport_imm_faq.jpg" alt="hide"></div>
			    </case>
			    <case value="Day Summary">
				<div id="scheda-immagine"><img border=0 src="resources/00_headport_imm_calendar.jpg" alt="hide"></div>
			    </case>				
			    <case value="Learning Materials">
				<div id="scheda-immagine"><img border=0 src="resources/00_headport_imm_lobj.jpg" alt="hide"></div>
			    </case>					
			    <case value="Full Calendar">
				<div id="scheda-immagine"><img border=0 src="resources/00_headport_imm_calendar.jpg" alt="hide"></div>
			    </case>			
			    <case value="Survey">
				<div id="scheda-immagine"><img border=0 src="resources/00_headport_imm_vuoto.jpg" alt="hide"></div>
			    </case>	
			    <case value="News">
				<div id="scheda-immagine"><img border=0 src="resources/00_headport_imm_vuoto.jpg" alt="hide"></div>
			    </case>	
			    <case value="Documents">
				<div id="scheda-immagine"><img border=0 src="resources/00_headport_imm_vuoto.jpg" alt="hide"></div>
			    </case>					
				<default>
			    </default>
			</switch>
			<div id="scheda-contenuto"><slave></div>
		  </div> 
		 </div>
		</div>
		<div id="scheda-footer">
		   <div id="scheda-footer-sin"></div>
		   <div id="scheda-footer-des"></div>		 
    </div>  

        





