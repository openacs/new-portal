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





<img src="@title.resource_dir@/minimize.gif" alt="Minimize" border="0">
<img src="@title.resource_dir@/up.gif" alt="Move Up" border="0">
<img src="@title.resource_dir@/down.gif" alt="Move Down" border="0">
<img src="@title.resource_dir@/close.gif" alt="Remove" border="0">

<!--
In this file, display title buttons.

check for:

button image directory, use the default if it's not specified.

add "shade" button if the option's turned on for the instance.

add "move up/down" buttons if the option's enabled for the instance, and if:
  the user's working with his/her own version of the portal, or
  the "copy automatically on appropriate titlebar action" option is turned on

remove button, with the same conditions as above.

"customize" button, if a customization URL has been provided.

-->
