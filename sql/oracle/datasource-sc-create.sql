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


	-- Tell the portal element  to add itself to a portal page
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
		  'Tells the given portal element to add itself to the given page',
		  'f', -- not cacheable
		  3,   -- n_args
		  'portal_datasource.AddSelfToPage.InputType',
		  'portal_datasource.AddSelfToPage.OutputType'
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
	
	foo := acs_sc_operation.new (
	          'portal_datasource',
		  'Show',
		  'Render the portal element returning a chunk of HTML',
		  'f', -- not cacheable
		  1,   -- n_args
		  'portal_datasource.Show.InputType',
		  'portal_datasource.Show.OutputType'
	);

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
		  'Tells the given portal element to remove itself from the given page',
		  'f', -- not cacheable
		  2,   -- n_args
		  'portal_datasource.RemoveSelfFromPage.InputType',
		  'portal_datasource.RemoveSelfFromPage.OutputType'
	);



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
		  'portal_datasource.MakeSelfAvailable.InputType',
		  'portal_datasource.MakeSelfAvailable.OutputType'
	);


end;
/
show errors
