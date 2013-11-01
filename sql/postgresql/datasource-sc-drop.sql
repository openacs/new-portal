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
--  FOR A PARTICULAR PURPOSE.  See the GNU General Public License foreign key more
--  details.
--      

--
-- The data source(portlet) contract
--
-- @author arjun@openforce.net
-- @version $Id$
--

CREATE OR REPLACE FUNCTION inline_0 () RETURNS integer AS $$
BEGIN

    -- drop GetMyName	  
    perform acs_sc_operation__delete(
        'portal_datasource',
        'GetMyName'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.GetMyName.InputType'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.GetMyName.OutputType'
    );

    -- drop GetPrettyName		  
    perform acs_sc_operation__delete(
        'portal_datasource',
        'GetPrettyName'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.GetPrettyName.InputType'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.GetPrettyName.OutputType'
    );

    -- drop Link
    perform acs_sc_operation__delete(
        'portal_datasource',
        'Link'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.Link.InputType'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.Link.OutputType'
    );

    -- Drop add_self_to_page	  
    perform acs_sc_operation__delete(
        'portal_datasource',
        'AddSelfToPage'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.AddSelfToPage.InputType'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.AddSelfToPage.OutputType'
    );

    -- Delete Show	  
    perform acs_sc_operation__delete(
        'portal_datasource',
        'Show'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.Show.InputType'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.Show.OutputType'
    );

    -- Delete Edit
    perform acs_sc_operation__delete(
        'portal_datasource',
        'Edit'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.Edit.InputType'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.Edit.OutputType'
    );

    -- RemoveSelfFromPage
    perform acs_sc_operation__delete(
        'portal_datasource',
        'RemoveSelfFromPage'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.RemoveSelfFromPage.InputType'
    );

    perform acs_sc_msg_type__delete(
        'portal_datasource.RemoveSelfFromPage.OutputType'
    );

    -- drop the contract 
    perform acs_sc_contract__delete(
        'portal_datasource'
    );

    return 0;

END;
$$ LANGUAGE plpgsql;

select inline_0();

drop function inline_0();
