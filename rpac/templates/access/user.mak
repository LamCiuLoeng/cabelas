<%inherit file="rpac.templates.master"/>

<%def name="extTitle()">r-pac - Access</%def>

<%def name="extJavaScript()">
	<script language="JavaScript" type="text/javascript">
    //<![CDATA[
          function toSearch(){
          	$("form").submit()
          }
    //]]>
   </script>
</%def>


<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/access/index"><img src="/images/images/menu_am_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toSearch()"><img src="/images/images/menu_search_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="/access/add?type=user"><img src="/images/images/menu_new_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Access&nbsp;&nbsp;&gt;&nbsp;&nbsp;User Management</div>

<div>
	${widget(action="/access/user",value=values)|n}
</div>

<%
    my_page = tmpl_context.paginators.result
    pager = my_page.pager(symbol_first="<<",show_if_single_page=True)
%>

<div style="clear:both"><br /></div>

%if result:

	<table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1000px">
		<thead>
			%if my_page.item_count > 0 :
      <tr>
        <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="20">
          ${pager}, <span>${my_page.first_item} - ${my_page.last_item}, ${my_page.item_count} records</span>
        </td>
      </tr>
      %endif
			<tr>
				<th width="200">User Name</th>
				<th width="200">Display Name</th>
				<th width="250">E-mail</th>
				<th>Role</th>
			</tr>
		</thead>
		<tbody>
			%for u in result:
			<tr>
				<td><a href="/access/edit?id=${u.user_id}&type=user">${u.user_name}</a>&nbsp;</td>
				<td>${u.display_name}</td>
				<td>${u.email_address}</td>
				<td>${" , ".join([g.group_name for g in u.groups])}&nbsp;</td>
			</tr>
			%endfor
			%if my_page.item_count > 0 :
      <tr>
        <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="20">
          ${pager}, <span>${my_page.first_item} - ${my_page.last_item}, ${my_page.item_count} records</span>
        </td>
      </tr>
      %endif
		</tbody>
	</table>

%endif

