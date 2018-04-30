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
#
# /www/dotlrn-master.tcl
#
# This is the "default-master" template for dotlrn sites.
#
# Instructions:
#
# 1. Put this file and its .adp file into the server's /www directory.
# That's the one with the "default-master" Tcl and adp files. You don't
# have to edit or remove the "default-master" files, since they will be
# ignored by the next step.
# 
# 2. Change the "Main Site"'s "DefaultMaster" parameter
# from "/www/default-master" to "/www/dotlrn-master"
# at http://yoursite.com/admin/site-map
#
# This tells OpenACS to use these files instead of the "default-master"
#
# 3. Edit these files to chage the look of the site including the banner
# at the top of the page, the title of the pages, the fonts of the portlets, etc.
#
# WARNING: All current portlet themes (table, deco, nada, etc) depend on some
# of the CSS defined below. Be careful when you edit the CSS below,
# and check how themes use it.
#
#
# Author: Arjun Sanyal (arjun@openforce.net), yon@openforce.net
#
# $Id$

set user_id [ad_conn user_id] 
set community_id [dotlrn_community::get_community_id]
set dotlrn_url [dotlrn::get_url]


#Scope Related graphics/css parameters
# Set everything for user level scope as default then modify it later as we refine the scope.
set scope_name "user"
set scope_main_color "#003366"
set scope_header_color "#6DB2C9"
set scope_highlight_text "white"
set scope_z_dark "#C9D7DC"
set scope_z_light "#EAF0F2"
set scope_light_border "#DDEBF5"
set help_url "[dotlrn::get_url]/control-panel"
set header_font "Arial, Helvetica, sans-serif"
set header_font_size "medium"
set header_font_color "black"
set header_logo_item_id ""
set header_img_url "/resources/dotlrn/logo" 
set header_img_file "[acs_root_dir]/packages/dotlrn/www/resources/logo"
set header_img_alt_text "Header Logo"

set extra_spaces "<img src=\"/resources/dotlrn/spacer.gif\" border=0 width=15>"
set td_align "align=\"center\" valign=\"top\""


if {$community_id ne ""} {
    set have_comm_id_p 1
} else {
    set have_comm_id_p 0
}



# navbar vars
set show_navbar_p 1
if {([info exists no_navbar_p] && $no_navbar_p ne "") && $no_navbar_p} {
    set show_navbar_p 0
} 

if {![info exists link_all]} {
    set link_all 0
}

if {![info exists return_url]} {
    set link [ad_conn -get extra_url]
} else {
    set link $return_url
}

if {![info exists link_control_panel]} {
    set link_control_panel 1
}

if { [ad_conn package_key] ne [dotlrn::package_key] } {
    # Peter M: We are in a package (an application) that may or may not be under a dotlrn instance 
    # (i.e. in a news instance of a class)
    # and we want all links in the navbar to be active so the user can return easily to the class homepage
    # or to the My Space page
    set link_all 1
}

if {$have_comm_id_p} {
    # in a community or just under one in a mounted package like /calendar 
    # get this comm's info
    set control_panel_text "Administer"

    set text [dotlrn_community::get_community_header_name $community_id] 
    set link [dotlrn_community::get_community_url $community_id]
    set admin_p [dotlrn::user_can_admin_community_p -user_id $user_id -community_id $community_id]

   if { $show_navbar_p } {
         set make_navbar_p 1
    } else {
	set make_navbar_p 0

    }
} elseif {[parameter::get -parameter community_type_level_p] == 1} {
    set control_panel_text "Administer"

    set extra_td_html ""
    set link_all 1
    set link [dotlrn::get_url]
    # in a community type
    set text \
            [dotlrn_community::get_community_type_name [dotlrn_community::get_community_type]]
    
   if {$show_navbar_p} {
	set make_navbar_p 1
    } else {
	set make_navbar_p 0
    }

} else {
    # we could be anywhere (maybe under /dotlrn, maybe not)
    set control_panel_text "My Account"
    set link "[dotlrn::get_url]/"
    set community_id ""
    set text ""
    set make_navbar_p 1
    if {$show_navbar_p} {
    } else {
    set make_navbar_p 0
    }
}

# Set up some basic stuff
set user_id [ad_conn user_id]
if { [ad_conn untrusted_user_id] == 0 } {
    set user_name {}
} else {
    set user_name [acs_user::get_element -user_id [ad_conn untrusted_user_id] -element name]
}

if {(![info exists title] || $title eq "")} {
    set title [ad_system_name]
}

if {[dotlrn_community::get_parent_community_id -package_id [ad_conn package_id] eq ""]} {
    set parent_comm_p 0
} else {
    set parent_comm_p 1
}

set community_id [dotlrn_community::get_community_id]

set control_panel_text [_ "dotlrn.control_panel"]

if {$community_id ne ""} {
    # in a community or just under one in a mounted package like /calendar 
    set comm_type [dotlrn_community::get_community_type_from_community_id $community_id]
    set control_panel_text [_ acs-subsite.Admin]

    if {[dotlrn_community::subcommunity_p -community_id $community_id]} {
	#The colors for a subgroup are set by the parent group with a few overwritten.
	set comm_type [dotlrn_community::get_community_type_from_community_id [dotlrn_community::get_parent_id -community_id $community_id]]
    }

    if {$comm_type eq "dotlrn_club"} {
	    #community colors
	    set scope_name "comm"
	    set scope_main_color "#"
	    set scope_header_color "#"
	    set scope_z_dark "#"
	    set scope_z_light "#"
	    set scope_light_border "#"
	if {[dotlrn_community::subcommunity_p -community_id $community_id]} {
	    set scope_z_dark "#"
	    set scope_z_light "#"
	}
    } else {
	set scope_name "course"
	set scope_main_color "#6C9A83"
	set scope_header_color $scope_main_color
	set scope_z_dark "#CDDED5"
	set scope_z_light "#E6EEEA"
	set scope_light_border "#D0DFD9"
	if {[dotlrn_community::subcommunity_p -community_id $community_id]} {
	    set scope_z_dark "#D0DFD9"
	    set scope_z_light "#ECF3F0"
	}
    }
  
    # DRB: default logo for dotlrn is a JPEG provided by Collaboraid.  This can
    # be replaced by custom gifs if preferred (as is done by SloanSpace)

    if { [file exists "$header_img_file-$scope_name.jpg"] } {
        set header_img_url "$header_img_url-$scope_name.jpg"
    } elseif { [file exists "$header_img_file-$scope_name.gif"] } {
        set header_img_url "$header_img_url-$scope_name.gif"
    }
  
   # set header_img_url "$header_img_url-$scope_name.gif"

   # font hack
   set community_header_font [dotlrn_community::get_attribute \
        -community_id $community_id \
        -attribute_name header_font
    ]

    if {$community_header_font ne ""} {
	set header_font "$community_header_font,$header_font"
    }


    set header_font_size [dotlrn_community::get_attribute \
        -community_id $community_id \
        -attribute_name header_font_size
    ]

    set header_font_color [dotlrn_community::get_attribute \
        -community_id $community_id \
        -attribute_name header_font_color
    ]

    # logo hack 
    set header_logo_item_id [dotlrn_community::get_attribute \
        -community_id $community_id \
        -attribute_name header_logo_item_id
    ]

    if {$header_logo_item_id ne ""} {

	# Need filename
        set header_img_url "[dotlrn_community::get_community_url $community_id]/file-storage/download/?version_id=$header_logo_item_id" 
    }
	
   
    set header_logo_alt_text [dotlrn_community::get_attribute \
        -community_id $community_id \
        -attribute_name header_logo_alt_text
    ]

    if {$header_logo_alt_text ne ""} {
        set header_img_alt_text $header_logo_alt_text
    } 

    set text [dotlrn::user_context_bar -community_id $community_id]

    if {[ad_conn package_key] eq [dotlrn::package_key]} {
        set text "<span class=\"header-text\">$text</span>"
    }

} elseif {[parameter::get -parameter community_type_level_p] == 1} {
    # in a community type (subject)
    set text \
            [dotlrn_community::get_community_type_name [dotlrn_community::get_community_type]]
} else {
    # under /dotlrn

    # DRB: default logo for dotlrn is a JPEG provided by Collaboraid.  This can
    # be replaced by custom gifs if preferred (as is done by SloanSpace)

    if { [file exists "$header_img_file-$scope_name.jpg"] } {
        set header_img_url "$header_img_url-$scope_name.jpg"
    } elseif { [file exists "$header_img_file-$scope_name.gif"] } {
        set header_img_url "$header_img_url-$scope_name.gif"
    }

    set text ""
}

if { $make_navbar_p } {
    if {$link_control_panel} {
	set link_control_panel 1
    } else {
	set link_control_panel 0
    }
    set extra_spaces "<img src=\"/resources/dotlrn/spacer.gif\" border=0 width=15>"    
    set navbar [dotlrn::portal_navbar \
        -user_id $user_id \
        -link_control_panel $link_control_panel \
        -control_panel_text $control_panel_text \
	-pre_html "$extra_spaces" \
	-post_html $extra_spaces \
        -link_all $link_all
    ]
} else {
    set navbar "<br>"
}


if { [info exists text] } {
    set text [lang::util::localize $text]
}

# Developer-support support
set ds_enabled_p [parameter::get_from_package_key \
    -package_key acs-developer-support \
    -parameter EnabledOnStartupP \
    -default 0
]

if {$ds_enabled_p} {
    set ds_link [ds_link]
} else {
    set ds_link {}
}

set change_locale_url [export_vars -base /acs-lang { { package_id "[ad_conn package_id]" } }]

# Hack for title and context bar outside of dotlrn

set in_dotlrn_p [expr [string match "[dotlrn::get_url]/*" [ad_conn url]]]

if { [info exists context] } {
    set context_bar [eval ad_context_bar $context]
}

set acs_lang_url [apm_package_url_from_key "acs-lang"]
set lang_admin_p [permission::permission_p \
                      -object_id [site_node::get_element -url $acs_lang_url -element object_id] \
                      -privilege admin \
                      -party_id [ad_conn untrusted_user_id]]
set toggle_translator_mode_url [export_vars -base "${acs_lang_url}admin/translator-mode-toggle" { { return_url [ad_return_url] } }]

# Curriculum bar
set curriculum_bar_p [llength [site_node::get_children -all -filters { package_key "curriculum" } -node_id $community_id]]

#################################
# CLASS/COMMUNITY-SPECIFIC COLORS
#################################

set recolor_css_template {
/* $scope_name substitutions: C8D8BE -> ${color1} */

#page-body {
  border-top: 1px solid #${color1};
  border-bottom: 1px solid #${color1};
  }

#system-name {
  color: #${color1};
  }

#main-container {
  background: #${color1};
  }

#footer li {
  color: #${color1};
  }

#locale li {
  color: #${color1};
  }

/* $scope_name substitutions: 95BC7E -> ${color2} */

/* This messes up the tabs in IE6 -- see dotlrn-master.css for more info.

a:hover {
  border-bottom: 1px solid #${color2};
  color: #${color2};
  }

*/

#main-container {
  border-top: 5px solid #${color2};
  border-bottom: 1px solid #${color2};
}

.portlet h2 {
  background-color: #${color2};
}

.portlet ul li {
  color: #${color2};
}

.actions a:hover {
  border-bottom: 1px solid #${color2};
  color: #${color2};
}

#admin-portlet {
    background-color: white;
    border: 1px solid #${color2};
    padding: .5em;
  }

/* $scope_name substitutions: 035156 -> ${color3} */

a:link, a:visited {
  border-bottom: 1px solid #${color3};
  color: #${color3};
  }

a:visited {
  border-bottom: 1px solid #${color3};
  /* Mangler visited color */
  color: #${color3};
  }

a:active {
  border-bottom: 1px solid #${color3};
  color: #${color3};
  }

h1 {
  color: #${color3};
  }

#breadcrumbs li {
  color: #${color3};
  }

#breadcrumbs a {
  color: #${color3};
  }

#login-status {
  color: #${color3};
  }

#login-status a {
  color: #${color3};
  }

#main-navigation a:hover {
  color: #${color3};
  }

#main-navigation li.current a {
  color: #${color3};
  }

#locale .current {
  color: #${color3};
  }

.portlet h2 {
  color: #${color3};
  border-top: 1px solid #${color3};
  border-bottom: 1px solid #${color3};
  } 

.portlet ul ul li {
  color: #${color3};
  }

/* $scope_name substitutions: E8F0E3 -> ${color4} */

#page-body {
  background-color: #${color4};
  }

.calendar-week-summary .odd {
  background-color: #${color4};
  }

/* $scope_name substitutions: E35203 -> ${color5} */

#message-bar {
  background-color: #${color5};
  }

/* $scope_name substitutions: tabs */

#main-navigation li {
  background: url("/resources/dotlrn/01_tab_pass_des.png") no-repeat right top;
  }

#main-navigation a {
  background: url("/resources/dotlrn/01_tab_pass_sin.png") no-repeat left top;
  }

#main-navigation li.current {
  background-image: url("/resources/dotlrn/01_tab_act_des.png");
  }

#main-navigation li.current a {
  background-image: url("/resources/dotlrn/01_tab_act_sin.png");
  }

#admin-portlet h1 {
    font-size: 1.5em;
  }

}

switch $scope_name {
    course {
	set color1 white
	set color2 white
	set color3 white
	set color4 white
	set color5 white
	set tabscope course
	set recolor_css [subst $recolor_css_template]
    }
    comm {
	set color1 white
	set color2 white
        set color3 white
        set color4 white
	set color5 white
	set tabscope comm
	set recolor_css [subst $recolor_css_template]
    }
    default {
	set recolor_css ""
    }
}
    
template::head::add_style -style "
$recolor_css

.page-body {
    FONT-SIZE: $header_font_size;
    COLOR: $header_font_color;
    FONT-FAMILY: $header_font;
}
"
template::head::add_css -href "/resources/dotlrn/dotlrn-master-kelp.css"

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
