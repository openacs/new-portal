--
--  Copyright(C) 2001, 2002 MIT
--
--  This file is part of dotLRN.
--
--  dotLRN is free software; you can redistribute it and/or modify it under the
--  terms of the GNU General Public License as published by the Free Software
--  Foundation; either version 2 of the License, or(at your option) any later
--  version.
--
--  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
--  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
--  details.
--

--
-- The data source(portlet) contract
--
-- @author arjun@openforce.net
-- @version $Id$
--

declare
    sc_dotlrn_contract integer;
    foo integer;
begin

    sc_dotlrn_contract := acs_sc_contract.new(
        contract_name => 'portal_datasource',
        contract_desc => 'Portal Datasource interface'
    );

    -- Get my name - not to be confused with the pretty_name
    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.GetMyName.InputType',
        msg_type_spec => ''
    );

    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.GetMyName.OutputType',
        msg_type_spec => 'my_name:string'
    );

    foo := acs_sc_operation.new(
        'portal_datasource',
        'GetMyName',
        'Get the name',
        't', -- not cacheable
        0,   -- n_args
        'portal_datasource.GetMyName.InputType',
        'portal_datasource.GetMyName.OutputType'
    );

    -- Get a pretty name
    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.GetPrettyName.InputType',
        msg_type_spec => ''
    );

    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.GetPrettyName.OutputType',
        msg_type_spec => 'pretty_name:string'
    );

    foo := acs_sc_operation.new(
        'portal_datasource',
        'GetPrettyName',
        'Get the pretty name',
        't', -- not cacheable
        0,   -- n_args
        'portal_datasource.GetPrettyName.InputType',
        'portal_datasource.GetPrettyName.OutputType'
    );

    -- Link: Where is the href target for this PE?
    -- ** not currently implimented ***
    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.Link.InputType',
        msg_type_spec => ''
    );

    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.Link.OutputType',
        msg_type_spec => 'pretty_name:string'
    );

    foo := acs_sc_operation.new(
        'portal_datasource',
        'Link',
        'Get the link ie the href target for this datasource',
        't', -- not cacheable
        0,   -- n_args
        'portal_datasource.Link.InputType',
        'portal_datasource.Link.OutputType'
    );

    -- AddSelfToPage: Tell the datasource to add itself to a portal
    -- The "args" string is an ns_set of extra arguments
    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.AddSelfToPage.InputType',
        msg_type_spec => 'page_id:integer,args:string'
    );

    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.AddSelfToPage.OutputType',
        msg_type_spec => 'element_id:integer'
    );

    foo := acs_sc_operation.new(
        'portal_datasource',
        'AddSelfToPage',
        'Adds itself to the given page returns an element_id',
        'f', -- not cacheable
        2,   -- n_args
        'portal_datasource.AddSelfToPage.InputType',
        'portal_datasource.AddSelfToPage.OutputType'
    );

    -- RemoveSelfFromPage: Tell the PE to remove itself from a page
    -- The "args" string is an ns_set of extra arguments
    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.RemoveSelfFromPage.InputType',
        msg_type_spec => 'page_id:integer,args:string'
    );

    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.RemoveSelfFromPage.OutputType',
        msg_type_spec => ''
    );

    foo := acs_sc_operation.new(
        'portal_datasource',
        'RemoveSelfFromPage',
        ' remove itself from the given page',
        'f', -- not cacheable
        2,   -- n_args
        'portal_datasource.RemoveSelfFromPage.InputType',
        'portal_datasource.RemoveSelfFromPage.OutputType'
    );

    -- Show: the portal element's display proc
    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.Show.InputType',
        msg_type_spec => 'cf:string'
    );

    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.Show.OutputType',
        msg_type_spec => 'output:string'
    );

    foo := acs_sc_operation.new(
        'portal_datasource',
        'Show',
        'Render the portal element returning a chunk of HTML',
        'f', -- not cacheable
        1,   -- n_args
        'portal_datasource.Show.InputType',
        'portal_datasource.Show.OutputType'
    );

    -- Edit: the datasources' edit html
    -- ** not currently implimented **
    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.Edit.InputType',
        msg_type_spec => 'element_id:integer'
    );

    foo := acs_sc_msg_type.new(
        msg_type_name => 'portal_datasource.Edit.OutputType',
        msg_type_spec => 'output:string'
    );

    foo := acs_sc_operation.new(
        'portal_datasource',
        'Edit',
        'Returns the edit html',
        'f', -- not cacheable
        1,   -- n_args
        'portal_datasource.Edit.InputType',
        'portal_datasource.Edit.OutputType'
    );

end;
/
show errors
