
--
-- The portal element (aka portlet or PE) contract
-- copyright 2001, OpenForce, Inc.
-- distributed under the GNU GPL v2
--
-- for Oracle 8/8i. (We're guessing 9i works, too).
--
-- arjun@openforce.net
-- started November, 2001
--

-- This is the service contract for PEs

declare
	sc_dotlrn_contract integer;
	foo integer;
begin
	sc_dotlrn_contract := acs_sc_contract.new (
		  contract_name => 'portal_element',
		  contract_desc => 'Portal Element interface'
	);

	-- Get my name - not to be confused with the pretty_name
	foo := acs_sc_msg_type.new (
	          msg_type_name => 'portal_element.MyName.InputType',
		  msg_type_spec => ''
	);

	foo := acs_sc_msg_type.new (
	          msg_type_name => 'portal_element.MyName.OutputType',
		  msg_type_spec => 'my_name:string'
	);

	foo := acs_sc_operation.new (
	          'portal_element',
		  'MyName',
		  'Get the name',
		  't', -- not cacheable
		  0,   -- n_args
		  'portal_element.MyName.InputType',
		  'portal_element.MyName.OutputType'
	);


	-- Get a pretty name
	foo := acs_sc_msg_type.new (
	          msg_type_name => 'portal_element.GetPrettyName.InputType',
		  msg_type_spec => ''
	);

	foo := acs_sc_msg_type.new (
	          msg_type_name => 'portal_element.GetPrettyName.OutputType',
		  msg_type_spec => 'pretty_name:string'
	);

	foo := acs_sc_operation.new (
	          'portal_element',
		  'GetPrettyName',
		  'Get the pretty name',
		  't', -- not cacheable
		  0,   -- n_args
		  'portal_element.GetPrettyName.InputType',
		  'portal_element.GetPrettyName.OutputType'
	);


	-- Tell the portal element  to add itself to a portal page
	-- add_self_to_page
	foo := acs_sc_msg_type.new(
		  msg_type_name => 'portal_element.AddSelfToPage.InputType',
		  msg_type_spec => 'page_id:integer,instance_id:integer'
	);

	foo := acs_sc_msg_type.new(
	          msg_type_name => 'portal_element.AddSelfToPage.OutputType',
		  msg_type_spec => 'element_id:integer'
	);
	
	foo := acs_sc_operation.new (
	          'portal_element',
		  'AddSelfToPage',
		  'Tells the given portal element to add itself to the given page',
		  'f', -- not cacheable
		  2,   -- n_args
		  'portal_element.AddSelfToPage.InputType',
		  'portal_element.AddSelfToPage.OutputType'
	);

	-- Show: the portal element's display proc
	foo := acs_sc_msg_type.new(
		  msg_type_name => 'portal_element.Show.InputType',
		  msg_type_spec => 'cf:string'
	);

	foo := acs_sc_msg_type.new(
	          msg_type_name => 'portal_element.Show.OutputType',
		  msg_type_spec => 'output:string'
	);
	
	foo := acs_sc_operation.new (
	          'portal_element',
		  'Show',
		  'Render the portal element returning a chunk of HTML',
		  'f', -- not cacheable
		  1,   -- n_args
		  'portal_element.Show.InputType',
		  'portal_element.Show.OutputType'
	);

	-- Tell the PE to remove itself from a page
	-- remove_self_from_page
	foo := acs_sc_msg_type.new(
	  msg_type_name => 'portal_element.RemoveSelfFromPage.InputType',
	  msg_type_spec => 'page_id:integer,instance_id:integer'
	);

	foo := acs_sc_msg_type.new(
          msg_type_name => 'portal_element.RemoveSelfFromPage.OutputType',
	  msg_type_spec => ''
	);
	
	foo := acs_sc_operation.new (
	          'portal_element',
		  'RemoveSelfFromPage',
		  'Tells the given portal element to remove itself from the given page',
		  'f', -- not cacheable
		  2,   -- n_args
		  'portal_element.RemoveSelfFromPage.InputType',
		  'portal_element.RemoveSelfFromPage.OutputType'
	);



	-- Make self available
	foo := acs_sc_msg_type.new(
	  msg_type_name => 'portal_element.MakeSelfAvailable.InputType',
	  msg_type_spec => 'portal_id:integer'
	);

	foo := acs_sc_msg_type.new(
	  msg_type_name => 'portal_element.MakeSelfAvailable.OutputType',
	  msg_type_spec => ''
	);
	
	foo := acs_sc_operation.new (
	          'portal_element',
		  'MakeSelfAvailable',
		  'Makes this PE available to this portal page',
		  'f', -- not cacheable
		  1,   -- n_args
		  'portal_element.MakeSelfAvailable.InputType',
		  'portal_element.MakeSelfAvailable.OutputType'
	);

	-- Make self unavailable
	foo := acs_sc_msg_type.new(
	  msg_type_name => 'portal_element.MakeSelfUnavailable.InputType',
	  msg_type_spec => 'portal_id:integer'
	);

	foo := acs_sc_msg_type.new(
	  msg_type_name => 'portal_element.MakeSelfUnavailable.OutputType',
	  msg_type_spec => ''
	);
	
	foo := acs_sc_operation.new (
	          'portal_element',
		  'MakeSelfUnavailable',
		  'Makes this PE UNavailable to this portal page',
		  'f', -- not cacheable
		  1,   -- n_args
		  'portal_element.MakeSelfAvailable.InputType',
		  'portal_element.MakeSelfAvailable.OutputType'
	);


end;
/
show errors
