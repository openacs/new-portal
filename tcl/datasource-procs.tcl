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

ad_library {

    portal datasource procs

    @version $Id$

}

# DRB: fold this into the new portal code ASAP!  Also add Simon's datasource_new etc
# into this namespace when folding

namespace eval portal::datasource {

    ad_proc new_from_spec {
        -spec:required
    } {

        Create a new portal datasource from a specification.  Why use this to define
        your portal datasources?  Because calling this procedure from your package's
        post-install procedure is easier than writing PL/SQL for Oracle and PL/pgSQL
        for Oracle.

        @author Don Baccus (dhogaza@pacifier.com)

        @param spec The specification (format described below)

        The specification is a list of name-value pairs.  Possible names are

        name          The name of the new datasource
        description   A human-readable description (defaults to name)
        params        A list of param key/attributes and their values

        Each parameter key can be followed by a colon then comma-separated list of flags
        in the familiar style of ad_page_contract or ad_form.  Do not include spaces
        in the list of flags.  Only two flags are allowed - "config_required_p"
        and "configured_p".  There should be a single value following the param name and
        flags, and one parameter/value pair per line if declared in the style of the
        example below.

        See the portal package documentation for the meaning of these two attributes.

        An example of a specification:

        { name "my_name"
          description "my_description"
          spec { shadeable_p:config_required t
                 hideable_p:configured,config_required t
               }
        }

    } {

        array set datasource $spec

        # Default datasource description to its name
        if { ![info exists datasource(description)] } {
            set datasource(description) $datasource(name)
        }

        db_transaction {

            set datasource_id [portal::datasource_new \
                -name $datasource(name) \
                -description $datasource(description)]

            foreach param $datasource(params) {

                if { ![regexp {^([^ \t:]+)(?::([a-zA-Z0-9_,(|)]*))([ \t]+)(.+)$} \
                           $param match param_name flags blanks value] } {
                    ad_return -code error "Parameter '$param' doesn't have the right format. It must be var\[:flag\[,flag ...\]\] value"
                }

                # set defaults for attributes
                set config_required_p f
                set configured_p f

                # now set the parameter flags
                foreach flag [split [string tolower $flags] ","] {
                    switch -exact $flag {
                        configured { set configured_p t }
                        config_required { set config_required_p t}
                        default { ad_return -code error "\"$flag\" is not a legal portal datasource attribute" }
                    }
                }

                # and define the parameter
                portal::datasource_set_def_param -datasource_id $datasource_id \
                    -config_required_p $config_required_p \
                    -configured_p $configured_p \
                    -key $param_name \
                    -value $value

            }
        }
    }
}
