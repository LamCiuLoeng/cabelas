<%inherit file="rpac.templates.master"/>

<%
    from repoze.what.predicates import in_any_group,in_group,has_permission
    from rpac.model import STATUS_NEW,STATUS_UNDER_DEV,STATUS_APPROVE,STATUS_CANCEL,STATUS_DISCONTINUE
%>

<%def name="extTitle()">r-pac - Production</%def>

<%def name="extCSS()">
    <style type="text/css">
    .gridTable td {
        padding : 5px;
    }
    .status0{ color: black;font-weight: bold; }
    .status1{ color: blue;font-weight: bold; }
    .status2{ color: green;font-weight: bold; }
    .status-1{ color: red;font-weight: bold; }
    .status9{ color: grey;font-weight: bold; }
</style>
</%def>

<%def name="extJavaScript()">
	<script language="JavaScript" type="text/javascript">
    //<![CDATA[
		$(document).ready(function(){
            $( ".datePicker" ).datepicker({"dateFormat":"yy-mm-dd"});
	    });
	    
	    function toSearch(){
	       $("form").attr("action","/logic/production");
	       $("form").submit();
	    }
	    
	    function toExport(){
	       $("form").attr("action","/logic/production_export");
	       $("form").submit();
	    }

    //]]>
   </script>
</%def>


<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/logic/production"><img src="/images/images/menu_title_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toSearch()"><img src="/images/images/menu_search_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toExport()"><img src="/images/images/menu_export_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Production&nbsp;&nbsp;&gt;&nbsp;&nbsp;Index</div>

<div style="margin:10px 0px 10px 10px">
    <table class="gridTable" cellpadding="0" cellspacing="0" border="0">
        <tr>
            <td style="width:100px;border-left:1px solid #ccc;border-top:1px solid #ccc;background-color:#369;color:white;">Status</td>
            <td class="status${STATUS_NEW}" style="width:150px;border-top:1px solid #ccc;">New</td>
            <td class="status${STATUS_UNDER_DEV}" style="width:150px;border-top:1px solid #ccc;">Under Development</td>
            <td class="status${STATUS_APPROVE}" style="width:150px;border-top:1px solid #ccc;">Approved</td>
            <td class="status${STATUS_CANCEL}" style="width:150px;border-top:1px solid #ccc;">Cancelled</td>
            <td class="status${STATUS_DISCONTINUE}" style="width:150px;border-top:1px solid #ccc;">Discontinued</td>
        </tr>
        <tr>
            <td style="border-left:1px solid #ccc;background-color:#369;color:white;">Summary</td>
            %for v in [STATUS_NEW,STATUS_UNDER_DEV,STATUS_APPROVE,STATUS_CANCEL,STATUS_DISCONTINUE]:
                <td>${ summary.get(v,0)}</td>
            %endfor
        </tr>
    </table>
</div>

<div>
	${widget(values,action="/logic/production")|n}
</div>

<div style="clear:both"></div>

<%
    my_page = tmpl_context.paginators.result
    pager = my_page.pager(symbol_first="<<",show_if_single_page=True)
%>
<div id="recordsArea" style="margin:5px 0px 10px 10px">
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
                <th width="150" height="25">r-trac #</th>
                <th width="150">Item Code</th>
                <th width="500">Description</th>
                <th width="250">Create Date(HKT)</th>
                <th width="200">Status</th>
                <th width="200">Approved Date</th>
                <th width="150">Action</th>
            </tr>
        </thead>
        <tbody>
            %if len(result) < 1:
                <tr>
                    <td colspan="8" style="border-left:1px solid #ccc">No match record(s) found!</td>
                </tr>
            %else:
                %for obj in result:
                <tr>
                    <td style="border-left:1px solid #ccc;"><a href="/logic/approve_detail?id=${obj.id}">${obj.systemNo}</a></td>
                    <td>${obj.jobNo}</td>
                    <td>${obj.desc}</td>
                    <td>${obj.createTime.strftime("%Y/%m/%d %H:%M")}</td>
                    <td class="status${obj.status}">${obj.showStatus()}</td>
                    <td>${obj.approveTime.strftime("%Y/%m/%d %H:%M")}</td>
                    <td><a href="/download?id=${obj.approveFilesZipID}" class="btn">Download</a></td>
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


