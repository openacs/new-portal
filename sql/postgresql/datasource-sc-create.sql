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

	  select acs_sc_contract__new (
		    /* contract_name */ 'portal_datasource',
		    /* contract_desc */ 'Portal Datasource interface'
	  );

	  -- Get my name - not to be confused with the pretty_name
	  select acs_sc_msg_type__new (
		    /* msg_type_name */ 'portal_datasource.GetMyName.InputType',
		    /* msg_type_spec */ ''
	  );

	  select acs_sc_msg_type__new (
		    /* msg_type_name */ 'portal_datasource.GetMyName.OutputType',
		    /* msg_type_spec */ 'get_my_name:string'
	  );

	  select acs_sc_operation__new (
		    'portal_datasource',
		    'GetMyName',
		    'Get the name',
		    't', -- not cacheable
		    0,   -- n_args
		    'portal_datasource.GetMyName.InputType',
		    'portal_datasource.GetMyName.OutputType'
	  );




	-- Get a pretty name
	  select acs_sc_msg_type__new (
		    /* msg_type_name */ 'portal_datasource.GetPrettyName.InputType',
		    /* msg_type_spec */ ''
	  );

	  select acs_sc_msg_type__new (
		    /* msg_type_name */ 'portal_datasource.GetPrettyName.OutputType',
		    /* msg_type_spec */ 'pretty_name:string'
	  );

	  select acs_sc_operation__new (
		    'portal_datasource',
		    'GetPrettyName',
		    'Get the pretty name',
		    't', -- not cacheable
		    0,   -- n_args
		    'portal_datasource.GetPrettyName.InputType',
		    'portal_datasource.GetPrettyName.OutputType'
	  );




	-- Link: Where is the href target for this PE?
	  select acs_sc_msg_type__new (
		    /* msg_type_name */ 'portal_datasource.Link.InputType',
		    /* msg_type_spec */ ''
	  );

	  select acs_sc_msg_type__new (
		    /* msg_type_name */ 'portal_datasource.Link.OutputType',
		    /* msg_type_spec */ 'pretty_name:string'
	  );

	  select acs_sc_operation__new (
		    'portal_datasource',
		    'Link',
		    'Get the link ie the href target for this datasource',
		    't', -- not cacheable
		    0,   -- n_args
		    'portal_datasource.Link.InputType',
		    'portal_datasource.Link.OutputType'
	  );



	-- Tell the datasource  to add itself to a portal page
	-- add_self_to_page
	-- The "args" string is an ns_set of extra arguments 
	  select acs_sc_msg_type__new(
		    /* msg_type_name */ 'portal_datasource.AddSelfToPage.InputType',
		    /* msg_type_spec */ 'page_id:integer,instance_id:integer,args:string'
	  );

	  select acs_sc_msg_type__new(
		    /* msg_type_name */ 'portal_datasource.AddSelfToPage.OutputType',
		    /* msg_type_spec */ 'element_id:integer'
	  );
	  
	  select acs_sc_operation__new (
		    'portal_datasource',
		    'AddSelfToPage',
		    'Adds itself to the given page returns an element_id',
		    'f', -- not cacheable
		    3,   -- n_args
		    'portal_datasource.AddSelfToPage.InputType',
		    'portal_datasource.AddSelfToPage.OutputType'
	  );



	-- Edit: the datasources' edit html
	  select acs_sc_msg_type__new(
		    /* msg_type_name */ 'portal_datasource.Edit.InputType',
		    /* msg_type_spec */ 'element_id:integer'
	  );

	  select acs_sc_msg_type__new(
		    /* msg_type_name */ 'portal_datasource.Edit.OutputType',
		    /* msg_type_spec */ 'output:string'
	  );
	  
	  select acs_sc_operation__new (
		    'portal_datasource',
		    'Edit',
		    'Returns the edit html',
		    'f', -- not cacheable
		    1,   -- n_args
		    'portal_datasource.Edit.InputType',
		    'portal_datasource.Edit.OutputType'
	  );




	-- Show: the portal element's display proc
	  select acs_sc_msg_type__new(
		    /* msg_type_name */ 'portal_datasource.Show.InputType',
		    /* msg_type_spec */ 'cf:string'
	  );

	  select acs_sc_msg_type__new(
		    /* msg_type_name */ 'portal_datasource.Show.OutputType',
		    /* msg_type_spec */ 'output:string'
	  );
	  
	  select acs_sc_operation__new (
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
	  select acs_sc_msg_type__new(
	    /* msg_type_name */ 'portal_datasource.RemoveSelfFromPage.InputType',
	    /* msg_type_spec */ 'page_id:integer,instance_id:integer'
	  );

	  select acs_sc_msg_type__new(
	    /* msg_type_name */ 'portal_datasource.RemoveSelfFromPage.OutputType',
	    /* msg_type_spec */ ''
	  );
	  
	  select acs_sc_operation__new (
		    'portal_datasource',
		    'RemoveSelfFromPage',
		    ' remove itself from the given page',
		    'f', -- not cacheable
		    2,   -- n_args
		    'portal_datasource.RemoveSelfFromPage.InputType',
		    'portal_datasource.RemoveSelfFromPage.OutputType'
	  );
