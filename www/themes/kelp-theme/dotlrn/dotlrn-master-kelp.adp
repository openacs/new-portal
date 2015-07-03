<master src="/www/site-master-kelp">
  <if @context@ not nil>
     <property name="context">@context;literal@</property>
  </if>
  <else><if @context_bar@ not nil><property name="context_bar">@context_bar;literal@</property></if></else>
  <if @focus@ not nil><property name="focus">@focus;literal@</property></if>
  <if @doc_type@ not nil><property name="doc_type">@doc_type;literal@</property></if>
  <if @title@ not nil><property name="doc(title)">@title;literal@</property></if>



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