<%inherit file="rpac.templates.master"/>

<%
	from repoze.what.predicates import in_group
%>

<%def name="extTitle()">r-pac - Manage Ship Info</%def>

<%def name="extCSS()">
<style type="text/css">
	.input-width{
		width : 300px
	}
	
	#warning {
		font:italic small-caps bold 16px/1.2em Arial;
	}
	
	.option {
	   display : none;
	}
	
	.gridTable td{
	   padding : 5px 2px 5px 2px;
	   height : 20px;
	}
</style>
</%def>

<%def name="extJavaScript()">
<script language="JavaScript" type="text/javascript">
//<![CDATA[
      function toSearch(){
          $("form").submit();
      }
       
//]]>
</script>

</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
  	<td width="64" valign="top" align="left"><a href="/ordering/manageAddress"><img src="/images/images/menu_manage_info_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Manage Ship Info&nbsp;&nbsp;&gt;&nbsp;&nbsp;Index</div>

<div style="margin: 10px 0px; overflow: hidden;">
<div id="recordsArea" style="margin: 5px 0px 10px 10px">
<%
    my_page = tmpl_context.paginators.result
    pager = my_page.pager(symbol_first="<<",show_if_single_page=True)
%>
<table cellspacing="0" cellpadding="0" border="0" id="dataTable" class="gridTable" style="width:1300px;">
    <thead>
        <tr>
            <th colspan="3" style="width:500px">Ship To</th>
            <th colspan="3" style="width:500px">Bill To</th>
            <th style="width:100px" rowspan="2">Action</th>
        </tr>
        <tr>     
            <th style="width:200px">Company Name</th>
            <th style="width:150px">Attention</th>
            <th style="width:150px">Address 1</th>            
            <th style="width:200px">Company Name</th>
            <th style="width:150px">Attention</th>
            <th style="width:150px">Address 1</th>           
        </tr>
    </thead>
    <tbody>
        %if len(result) < 1:
            <tr>
                <td colspan="20" style="border-left:1px solid #ccc">No records found!</td>
            </tr>
        %else:
            % for index,h in enumerate(result):
                <tr>
                    <td style="border-left:1px solid #cccccc;">&nbsp;${h.shipCompany or ''}</td>
                    <td>&nbsp;${h.shipAttn or ''}</td>
                    <td>&nbsp;${h.shipAddress or ''}</td>
                    <td>&nbsp;${h.billCompany or ''}</td>
                    <td>&nbsp;${h.billAttn or ''}</td>
                    <td>&nbsp;${h.billAddress or ''}</td>
                    <td><a href="/ordering/editAddress?id=${h.id}">Edit</a>&nbsp;<a href="/ordering/delAddress?id=${h.id}">Delete</a></td>                  
                </tr>
            %endfor
        %endif
        %if my_page.item_count > 0 :
            <tr>
                <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="20">
                    ${pager}, <span>${my_page.first_item} - ${my_page.last_item}, ${my_page.item_count} records</span>
                </td>
            </tr>
        %endif
    </tbody>            
</table>       
</div>
