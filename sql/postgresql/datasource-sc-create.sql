--
--  Copyright (C) 2001, 2002 MIT
--
--  This file is part of dotLRN.
--
--  dotLRN is free software; you can redistribute it and/or modify it under the
--  terms of the GNU General Public License as published by the Free Software
--  Foundation; either version 2 of the License, or (at your option) any later
--  version.
--
--  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
--  FOR A PARTICULAR PURPOSE.  See the GNU General Public License foreign key more
--  details.
--

--
-- The data source (portlet) contract
--
-- @author arjun@openforce.net
-- @version $Id$
--

CREATE OR REPLACE FUNCTION inline_0 () RETURNS integer AS $$
BEGIN

    perform acs_sc_contract__new(
        'portal_datasource',
        'Portal Datasource interface'
    );

    -- Get my name - not to be confused with the pretty_name
    perform acs_sc_msg_type__new(
        'portal_datasource.GetMyName.InputType',
        ''
    );

    perform acs_sc_msg_type__new(
        'portal_datasource.GetMyName.OutputType',
        'get_my_name:string'
    );

    perform acs_sc_operation__new(
        'portal_datasource',
        'GetMyName',
        'Get the name',
        't',
        0,
        'portal_datasource.GetMyName.InputType',
        'portal_datasource.GetMyName.OutputType'
    );

    -- Get a pretty name
    perform acs_sc_msg_type__new(
        'portal_datasource.GetPrettyName.InputType',
        ''
    );

    perform acs_sc_msg_type__new(
        'portal_datasource.GetPrettyName.OutputType',
        'pretty_name:string'
    );

    perform acs_sc_operation__new(
        'portal_datasource',
        'GetPrettyName',
        'Get the pretty name',
        't',
        0,
        'portal_datasource.GetPrettyName.InputType',
        'portal_datasource.GetPrettyName.OutputType'
    );

    -- Link: Where is the href target for this PE?
    perform acs_sc_msg_type__new(
        'portal_datasource.Link.InputType',
        ''
    );

    perform acs_sc_msg_type__new(
        'portal_datasource.Link.OutputType',
        'pretty_name:string'
    );

    perform acs_sc_operation__new(
        'portal_datasource',
        'Link',
        'Get the link ie the href target for this datasource',
        't',
        0,
        'portal_datasource.Link.InputType',
        'portal_datasource.Link.OutputType'
    );

    -- Tell the datasource  to add itself to a portal page
    -- add_self_to_page
    -- The "args" string is an ns_set of extra arguments
    perform acs_sc_msg_type__new(
        'portal_datasource.AddSelfToPage.InputType',
        'page_id:integer,instance_id:integer,args:string'
    );

    perform acs_sc_msg_type__new(
        'portal_datasource.AddSelfToPage.OutputType',
        'element_id:integer'
    );

    perform acs_sc_operation__new(
        'portal_datasource',
        'AddSelfToPage',
        'Adds itself to the given page returns an element_id',
        'f',
        3,
        'portal_datasource.AddSelfToPage.InputType',
        'portal_datasource.AddSelfToPage.OutputType'
    );

    perform acs_sc_msg_type__new(
        'portal_datasource.Edit.InputType',
        'element_id:integer'
    );

    perform acs_sc_msg_type__new(
        'portal_datasource.Edit.OutputType',
        'output:string'
    );

    perform acs_sc_operation__new(
        'portal_datasource',
        'Edit',
        'Returns the edit html',
        'f',
        1,
        'portal_datasource.Edit.InputType',
        'portal_datasource.Edit.OutputType'
    );

    perform acs_sc_msg_type__new(
        'portal_datasource.Show.InputType',
        'cf:string'
    );

    perform acs_sc_msg_type__new(
        'portal_datasource.Show.OutputType',
        'output:string'
    );

    perform acs_sc_operation__new(
        'portal_datasource',
        'Show',
        'Render the portal element returning a chunk of HTML',
        'f',
        1,
        'portal_datasource.Show.InputType',
        'portal_datasource.Show.OutputType'
    );

    -- Tell the PE to remove itself from a page
    -- remove_self_from_page
    perform acs_sc_msg_type__new(
        'portal_datasource.RemoveSelfFromPage.InputType',
        'page_id:integer,instance_id:integer'
    );

    perform acs_sc_msg_type__new(
        'portal_datasource.RemoveSelfFromPage.OutputType',
        ''
    );

    perform acs_sc_operation__new(
        'portal_datasource',
        'RemoveSelfFromPage',
        ' remove itself from the given page',
        'f',
        2,
        'portal_datasource.RemoveSelfFromPage.InputType',
        'portal_datasource.RemoveSelfFromPage.OutputType'
    );

    return 0;

END;
$$ LANGUAGE plpgsql;

select inline_0();

drop function inline_0();
