--
--  Copyright (C) 2001, 2002 OpenForce, Inc.
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

-- The data source (portlet) contract
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- for Oracle 8/8i. (We're guessing 9i works, too).
--
-- arjun@openforce.net
-- started November, 2001
--
-- $Id$

declare
	sc_dotlrn_contract integer;
	foo integer;
begin
	  sc_dotlrn_contract := acs_sc_contract.new (
		    contract_name => 'portal_datasource',
		    contract_desc => 'Portal Datasource interface'
	  );

	  -- Get my name - not to be confused with the pretty_name
	  foo := acs_sc_msg_type.new (
		    msg_type_name => 'portal_datasource.MyName.InputType',
		    msg_type_spec => ''
	  );

	  foo := acs_sc_msg_type.new (
		    msg_type_name => 'portal_datasource.MyName.OutputType',
		    msg_type_spec => 'my_name:string'
	  );

	  foo := acs_sc_operation.new (
		    'portal_datasource',
		    'MyName',
		    'Get the name',
		    't', -- not cacheable
		    0,   -- n_args
		    'portal_datasource.MyName.InputType',
		    'portal_datasource.MyName.OutputType'
	  );


end;
/
show errors

declare
	sc_dotlrn_contract integer;
	foo integer;
begin

	-- Get a pretty name
	  foo := acs_sc_msg_type.new (
		    msg_type_name => 'portal_datasource.GetPrettyName.InputType',
		    msg_type_spec => ''
	  );

	  foo := acs_sc_msg_type.new (
		    msg_type_name => 'portal_datasource.GetPrettyName.OutputType',
		    msg_type_spec => 'pretty_name:string'
	  );

	  foo := acs_sc_operation.new (
		    'portal_datasource',
		    'GetPrettyName',
		    'Get the pretty name',
		    't', -- not cacheable
		    0,   -- n_args
		    'portal_datasource.GetPrettyName.InputType',
		    'portal_datasource.GetPrettyName.OutputType'
	  );


end;
/
show errors

declare
	sc_dotlrn_contract integer;
	foo integer;
begin

	-- Link: Where is the href target for this PE?
	  foo := acs_sc_msg_type.new (
		    msg_type_name => 'portal_datasource.Link.InputType',
		    msg_type_spec => ''
	  );

	  foo := acs_sc_msg_type.new (
		    msg_type_name => 'portal_datasource.Link.OutputType',
		    msg_type_spec => 'pretty_name:string'
	  );

	  foo := acs_sc_operation.new (
		    'portal_datasource',
		    'Link',
		    'Get the link ie the href target for this datasource',
		    't', -- not cacheable
		    0,   -- n_args
		    'portal_datasource.Link.InputType',
		    'portal_datasource.Link.OutputType'
	  );


end;
/
show errors


declare
	sc_dotlrn_contract integer;
	foo integer;
begin
	-- Tell the datasource  to add itself to a portal page
	-- add_self_to_page
	-- The "args" string is an ns_set of extra arguments 
	  foo := acs_sc_msg_type.new(
		    msg_type_name => 'portal_datasource.AddSelfToPage.InputType',
		    msg_type_spec => 'page_id:integer,instance_id:integer,args:string'
	  );

	  foo := acs_sc_msg_type.new(
		    msg_type_name => 'portal_datasource.AddSelfToPage.OutputType',
		    msg_type_spec => 'element_id:integer'
	  );
	  
	  foo := acs_sc_operation.new (
		    'portal_datasource',
		    'AddSelfToPage',
		    'Adds itself to the given page returns an element_id',
		    'f', -- not cacheable
		    3,   -- n_args
		    'portal_datasource.AddSelfToPage.InputType',
		    'portal_datasource.AddSelfToPage.OutputType'
	  );

end;
/
show errors

declare
	sc_dotlrn_contract integer;
	foo integer;
begin

	-- Edit: the datasources' edit html
	  foo := acs_sc_msg_type.new(
		    msg_type_name => 'portal_datasource.Edit.InputType',
		    msg_type_spec => 'element_id:integer'
	  );

	  foo := acs_sc_msg_type.new(
		    msg_type_name => 'portal_datasource.Edit.OutputType',
		    msg_type_spec => 'output:string'
	  );
	  
	  foo := acs_sc_operation.new (
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

declare
	sc_dotlrn_contract integer;
	foo integer;
begin

	-- Show: the portal element's display proc
	  foo := acs_sc_msg_type.new(
		    msg_type_name => 'portal_datasource.Show.InputType',
		    msg_type_spec => 'cf:string'
	  );

	  foo := acs_sc_msg_type.new(
		    msg_type_name => 'portal_datasource.Show.OutputType',
		    msg_type_spec => 'output:string'
	  );
	  
	  foo := acs_sc_operation.new (
		    'portal_datasource',
		    'Show',
		    'Render the portal element returning a chunk of HTML',
		    'f', -- not cacheable
		    1,   -- n_args
		    'portal_datasource.Show.InputType',
		    'portal_datasource.Show.OutputType'
	  );


end;
/
show errors

declare
	sc_dotlrn_contract integer;
	foo integer;
begin
	-- Tell the PE to remove itself from a page
	-- remove_self_from_page
	  foo := acs_sc_msg_type.new(
	    msg_type_name => 'portal_datasource.RemoveSelfFromPage.InputType',
	    msg_type_spec => 'page_id:integer,instance_id:integer'
	  );

	  foo := acs_sc_msg_type.new(
	    msg_type_name => 'portal_datasource.RemoveSelfFromPage.OutputType',
	    msg_type_spec => ''
	  );
	  
	  foo := acs_sc_operation.new (
		    'portal_datasource',
		    'RemoveSelfFromPage',
		    ' remove itself from the given page',
		    'f', -- not cacheable
		    2,   -- n_args
		    'portal_datasource.RemoveSelfFromPage.InputType',
		    'portal_datasource.RemoveSelfFromPage.OutputType'
	  );


end;
/
show errors

declare
	sc_dotlrn_contract integer;
	foo integer;
begin

	  -- Make self available
	  foo := acs_sc_msg_type.new(
	    msg_type_name => 'portal_datasource.MakeSelfAvailable.InputType',
	    msg_type_spec => 'portal_id:integer'
	  );

	  foo := acs_sc_msg_type.new(
	    msg_type_name => 'portal_datasource.MakeSelfAvailable.OutputType',
	    msg_type_spec => ''
	  );
	  
	  foo := acs_sc_operation.new (
		    'portal_datasource',
		    'MakeSelfAvailable',
		    'Makes this PE available to this portal page',
		    'f', -- not cacheable
		    1,   -- n_args
		    'portal_datasource.MakeSelfAvailable.InputType',
		    'portal_datasource.MakeSelfAvailable.OutputType'
	  );

end;
/
show errors


declare
	sc_dotlrn_contract integer;
	foo integer;
begin

	  -- Make self unavailable
	  foo := acs_sc_msg_type.new(
	    msg_type_name => 'portal_datasource.MakeSelfUnavailable.InputType',
	    msg_type_spec => 'portal_id:integer'
	  );

	  foo := acs_sc_msg_type.new(
	    msg_type_name => 'portal_datasource.MakeSelfUnavailable.OutputType',
	    msg_type_spec => ''
	  );
	  
	  foo := acs_sc_operation.new (
		    'portal_datasource',
		    'MakeSelfUnavailable',
		    'Makes this PE UNavailable to this portal page',
		    'f', -- not cacheable
		    1,   -- n_args
		    'portal_datasource.MakeSelfUnavailable.InputType',
		    'portal_datasource.MakeSelfUnavailable.OutputType'
	  );

end;
/
show errors
