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
--  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
--  details.
--

--
-- The data source (portlet) contract
--
-- @author arjun@openforce.net
-- @version $Id$
--

declare
    contract_id                     integer;
    msg_type_id                     integer;
    op_id                           integer;
begin

    -- drop GetMyName
    op_id := acs_sc_operation.get_id (
        contract_name => 'portal_datasource',
        operation_name => 'GetMyName'
    );

    acs_sc_operation.del (
        operation_id => op_id,
        contract_name => 'portal_datasource',
        operation_name => 'GetMyName'
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.GetMyName.InputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.GetMyName.InputType',
        msg_type_id => msg_type_id
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.GetMyName.OutputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.GetMyName.OutputType',
        msg_type_id => msg_type_id
    );

    -- drop GetPrettyName
    op_id := acs_sc_operation.get_id (
        contract_name => 'portal_datasource',
        operation_name => 'GetPrettyName'
    );

    acs_sc_operation.del (
        operation_id => op_id,
        contract_name => 'portal_datasource',
        operation_name => 'GetPrettyName'
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.GetPrettyName.InputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.GetPrettyName.InputType',
        msg_type_id => msg_type_id
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.GetPrettyName.OutputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.GetPrettyName.OutputType',
        msg_type_id => msg_type_id
    );


    -- drop Link
    op_id := acs_sc_operation.get_id (
        contract_name => 'portal_datasource',
        operation_name => 'Link'
    );

    acs_sc_operation.del (
        operation_id => op_id,
        contract_name => 'portal_datasource',
        operation_name => 'Link'
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.Link.InputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.Link.InputType',
        msg_type_id => msg_type_id
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.Link.OutputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.Link.OutputType',
        msg_type_id => msg_type_id
    );

    -- Drop add_self_to_page
    op_id := acs_sc_operation.get_id (
        contract_name => 'portal_datasource',
        operation_name => 'AddSelfToPage'
    );

    acs_sc_operation.del (
        operation_id => op_id,
        contract_name => 'portal_datasource',
        operation_name => 'AddSelfToPage'
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.AddSelfToPage.InputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.AddSelfToPage.InputType',
        msg_type_id => msg_type_id
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.AddSelfToPage.OutputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.AddSelfToPage.OutputType',
        msg_type_id => msg_type_id
    );

    -- Delete Show
    op_id := acs_sc_operation.get_id (
        contract_name => 'portal_datasource',
        operation_name => 'Show'
    );

    acs_sc_operation.del (
        operation_id => op_id,
        contract_name => 'portal_datasource',
        operation_name => 'Show'
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.Show.InputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.Show.InputType',
        msg_type_id => msg_type_id
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.Show.OutputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.Show.OutputType',
        msg_type_id => msg_type_id
    );

    -- Delete Edit
    op_id := acs_sc_operation.get_id (
        contract_name => 'portal_datasource',
        operation_name => 'Edit'
    );

    acs_sc_operation.del (
        operation_id => op_id,
        contract_name => 'portal_datasource',
        operation_name => 'Edit'
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.Edit.InputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.Edit.InputType',
        msg_type_id => msg_type_id
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.Edit.OutputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.Edit.OutputType',
        msg_type_id => msg_type_id
    );

    -- RemoveSelfFromPage
    op_id := acs_sc_operation.get_id (
        contract_name => 'portal_datasource',
        operation_name => 'RemoveSelfFromPage'
    );

    acs_sc_operation.del (
        operation_id => op_id,
        contract_name => 'portal_datasource',
        operation_name => 'RemoveSelfFromPage'
    );

    msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.RemoveSelfFromPage.InputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.RemoveSelfFromPage.InputType',
        msg_type_id => msg_type_id
    );

    acs_sc_msg_type.del (
        msg_type_id := acs_sc_msg_type.get_id (
        msg_type_name => 'portal_datasource.RemoveSelfFromPage.OutputType'
    );

    acs_sc_msg_type.del (
        msg_type_name => 'portal_datasource.RemoveSelfFromPage.OutputType',
        msg_type_id => msg_type_id
    );

    -- drop the contract
    contract_id := acs_sc_contract.get_id ('portal_datasource');

    acs_sc_contract.del (
        contract_id => contract_id,
        contract_name => 'portal_datasource'
    );

end;
/
show errors
