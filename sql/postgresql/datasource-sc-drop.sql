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

	-- drop GetMyName	  
	  select acs_sc_operation__delete (
		  /* contract_name */ 'portal_datasource',
		  /* operation_name */ 'GetMyName'
	  );

	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.GetMyName.InputType'
	  );

	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.GetMyName.OutputType'
	  );

	  -- drop GetPrettyName		  
	  select acs_sc_operation__delete (
		  /* contract_name */ 'portal_datasource',
		  /* operation_name */ 'GetPrettyName'
	  );

	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.GetPrettyName.InputType'
	  );

	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.GetPrettyName.OutputType'
	  );


	  -- drop Link
	  select acs_sc_operation__delete (
		  /* contract_name */ 'portal_datasource',
		  /* operation_name */ 'Link'
	  );


	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.Link.InputType'
	  );

	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.Link.OutputType'
	  );


	  -- Drop add_self_to_page	  
	  select acs_sc_operation__delete (
		  /* contract_name */ 'portal_datasource',
		  /* operation_name */ 'AddSelfToPage'
	  );
	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.AddSelfToPage.InputType'
	  );

	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.AddSelfToPage.OutputType'
	  );


	  -- Delete Show	  
	  select acs_sc_operation__delete (
		  /* contract_name */ 'portal_datasource',
		  /* operation_name */ 'Show'
	  );

	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.Show.InputType'
	  );

	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.Show.OutputType'
	  );


	  -- Delete Edit
	  
	  select acs_sc_operation__delete (
		  /* contract_name */ 'portal_datasource',
		  /* operation_name */ 'Edit'
	  );

	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.Edit.InputType'
	  );

	  select acs_sc_msg_type__delete (
		  /* msg_type_name */ 'portal_datasource.Edit.OutputType'
	  );


	  -- rem RemoveSelfFromPage
	  
	  select acs_sc_operation__delete (
		  /* contract_name */ 'portal_datasource',
		  /* operation_name */ 'RemoveSelfFromPage'
	  );

	  select acs_sc_msg_type__delete (
	  /* msg_type_name */ 'portal_datasource.RemoveSelfFromPage.InputType'
	  );

	  select acs_sc_msg_type__delete (
	  /* msg_type_name */ 'portal_datasource.RemoveSelfFromPage.OutputType'
	  );


	    -- drop the contract 
	    select acs_sc_contract__delete (
	    /* contract_name */ 'portal_datasource'
	    );

