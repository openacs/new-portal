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
	contract_id integer;
	msg_type_id integer;
	op_id integer;
begin
	
	-- drop MyName
	  op_id := acs_sc_operation.get_id (
		  contract_name => 'portal_datasource',
		  operation_name => 'MyName'
	  );
	  
	  acs_sc_operation.delete (
		  operation_id => op_id,
		  contract_name => 'portal_datasource',
		  operation_name => 'MyName'
	  );

	  msg_type_id := acs_sc_msg_type.get_id (
		  msg_type_name => 'portal_datasource.MyName.InputType'
	  );

	  acs_sc_msg_type.delete (
		  msg_type_name => 'portal_datasource.MyName.InputType',
		  msg_type_id => msg_type_id
	  );

	  msg_type_id := acs_sc_msg_type.get_id (
		  msg_type_name => 'portal_datasource.MyName.OutputType'
	  );

	  acs_sc_msg_type.delete (
		  msg_type_name => 'portal_datasource.MyName.OutputType',
		  msg_type_id => msg_type_id
	  );

	  -- drop GetPrettyName	
	  op_id := acs_sc_operation.get_id (
		  contract_name => 'portal_datasource',
		  operation_name => 'GetPrettyName'
	  );
	  
	  acs_sc_operation.delete (
		  operation_id => op_id,
		  contract_name => 'portal_datasource',
		  operation_name => 'GetPrettyName'
	  );

	  msg_type_id := acs_sc_msg_type.get_id (
		  msg_type_name => 'portal_datasource.GetPrettyName.InputType'
	  );

	  acs_sc_msg_type.delete (
		  msg_type_name => 'portal_datasource.GetPrettyName.InputType',
		  msg_type_id => msg_type_id
	  );

	  msg_type_id := acs_sc_msg_type.get_id (
		  msg_type_name => 'portal_datasource.GetPrettyName.OutputType'
	  );

	  acs_sc_msg_type.delete (
		  msg_type_name => 'portal_datasource.GetPrettyName.OutputType',
		  msg_type_id => msg_type_id
	  );


	  -- Drop add_self_to_page
	  op_id := acs_sc_operation.get_id (
		  contract_name => 'portal_datasource',
		  operation_name => 'AddSelfToPage'
	  );
	  
	  acs_sc_operation.delete (
		  operation_id => op_id,
		  contract_name => 'portal_datasource',
		  operation_name => 'AddSelfToPage'
	  );

	  msg_type_id := acs_sc_msg_type.get_id (
		  msg_type_name => 'portal_datasource.AddSelfToPage.InputType'
	  );

	  acs_sc_msg_type.delete (
		  msg_type_name => 'portal_datasource.AddSelfToPage.InputType',
		  msg_type_id => msg_type_id
	  );

	  msg_type_id := acs_sc_msg_type.get_id (
		  msg_type_name => 'portal_datasource.AddSelfToPage.OutputType'
	  );

	  acs_sc_msg_type.delete (
		  msg_type_name => 'portal_datasource.AddSelfToPage.OutputType',
		  msg_type_id => msg_type_id
	  );


	  -- Delete Show
	  op_id := acs_sc_operation.get_id (
		  contract_name => 'portal_datasource',
		  operation_name => 'Show'
	  );
	  
	  acs_sc_operation.delete (
		  operation_id => op_id,
		  contract_name => 'portal_datasource',
		  operation_name => 'Show'
	  );

	  msg_type_id := acs_sc_msg_type.get_id (
		  msg_type_name => 'portal_datasource.Show.InputType'
	  );

	  acs_sc_msg_type.delete (
		  msg_type_name => 'portal_datasource.Show.InputType',
		  msg_type_id => msg_type_id
	  );

	  msg_type_id := acs_sc_msg_type.get_id (
		  msg_type_name => 'portal_datasource.Show.OutputType'
	  );

	  acs_sc_msg_type.delete (
		  msg_type_name => 'portal_datasource.Show.OutputType',
		  msg_type_id => msg_type_id
	  );


	  -- rem RemoveSelfFromPage
	  op_id := acs_sc_operation.get_id (
		  contract_name => 'portal_datasource',
		  operation_name => 'RemoveSelfFromPage'
	  );
	  
	  acs_sc_operation.delete (
		  operation_id => op_id,
		  contract_name => 'portal_datasource',
		  operation_name => 'RemoveSelfFromPage'
	  );

	  msg_type_id := acs_sc_msg_type.get_id (
	  msg_type_name => 'portal_datasource.RemoveSelfFromPage.InputType'
	  );

	  acs_sc_msg_type.delete (
	  msg_type_name => 'portal_datasource.RemoveSelfFromPage.InputType',
	  msg_type_id => msg_type_id
	  );

	  msg_type_id := acs_sc_msg_type.get_id (
	  msg_type_name => 'portal_datasource.RemoveSelfFromPage.OutputType'
	  );

	  acs_sc_msg_type.delete (
	  msg_type_name => 'portal_datasource.RemoveSelfFromPage.OutputType',
	  msg_type_id => msg_type_id
	  );


	  -- rem MakeSelfAvailable
	    op_id := acs_sc_operation.get_id (
		    contract_name => 'portal_datasource',
		    operation_name => 'MakeSelfAvailable'
	    );
	    
	    acs_sc_operation.delete (
		    operation_id => op_id,
		    contract_name => 'portal_datasource',
		    operation_name => 'MakeSelfAvailable'
	    );


	    msg_type_id := acs_sc_msg_type.get_id (
	    msg_type_name => 'portal_datasource.MakeSelfAvailable.InputType'
	    );

	    acs_sc_msg_type.delete (
	    msg_type_name => 'portal_datasource.MakeSelfAvailable.InputType',
	    msg_type_id => msg_type_id
	    );

	    msg_type_id := acs_sc_msg_type.get_id (
	    msg_type_name => 'portal_datasource.MakeSelfAvailable.OutputType'
	    );

	    acs_sc_msg_type.delete (
	    msg_type_name => 'portal_datasource.MakeSelfAvailable.OutputType',
	    msg_type_id => msg_type_id
	    );


	  -- rem MakeSelfUnavailable
	    op_id := acs_sc_operation.get_id (
		    contract_name => 'portal_datasource',
		    operation_name => 'MakeSelfUnavailable'
	    );
	    
	    acs_sc_operation.delete (
		    operation_id => op_id,
		    contract_name => 'portal_datasource',
		    operation_name => 'MakeSelfUnavailable'
	    );

	    msg_type_id := acs_sc_msg_type.get_id (
	    msg_type_name => 'portal_datasource.MakeSelfUnavailable.InputType'
	    );

	    acs_sc_msg_type.delete (
	    msg_type_name => 'portal_datasource.MakeSelfUnavailable.InputType',
	    msg_type_id => msg_type_id
	    );

	    msg_type_id := acs_sc_msg_type.get_id (
	    msg_type_name => 'portal_datasource.MakeSelfUnavailable.OutputType'
	    );

	    acs_sc_msg_type.delete (
	    msg_type_name => 'portal_datasource.MakeSelfUnavailable.OutputType',
	    msg_type_id => msg_type_id
	    );


end;
/
show errors
