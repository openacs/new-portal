<master src="/www/site-master-kelp">
  <property name="header_stuff">
     <link rel="stylesheet" type="text/css" href="/resources/dotlrn/dotlrn-master-kelp.css" media="all">
     <link rel="stylesheet" type="text/css" href="/resources/calendar/calendar.css" media="all">
     @header_stuff;noquote@
     @header_customized_css;noquote@ 
  </property>
  <if @context@ not nil>
     <property name="context">@context;noquote@</property>
  </if>
  <else><if @context_bar@ not nil><property name="context_bar">@context_bar;noquote@</property></if></else>
  <if @focus@ not nil><property name="focus">@focus;noquote@</property></if>
  <if @doc_type@ not nil><property name="doc_type">@doc_type;noquote@</property></if>
  <if @title@ not nil><property name="title">@title;noquote@</property></if>



<div id="page-body">
  <div id="container-navbar-body">
    <if @navbar@ not nil>@navbar;noquote@</if>
  </div>  
  <div style="clear: both;"></div>

  <div id="main-container">
  <if @title@ not nil>
   <h1 class="page-title">@title;noquote@</h1> 
  </if> 
  <slave>

  <div style="clear: both;"></div>
  </div><!-- main-container -->

</div><!-- page-body -->