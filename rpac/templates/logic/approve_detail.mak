<%inherit file="rpac.templates.master"/>

<%
    from repoze.what.predicates import in_any_group,in_group,has_permission
    from rpac.model import STATUS_APPROVE
%>

<%def name="extTitle()">r-pac - Production - Detail</%def>

<%def name="extCSS()">
<style type="text/css">
    .gridTable td {
        padding : 5px;
    }

</style>
</%def>

<%def name="extJavaScript()">
	<script language="JavaScript" type="text/javascript">
    //<![CDATA[
		$(document).ready(function(){

	    });
    
	    function toDiscontinue(){
	       if(confirm("Are you sure to discontinue this job?")){
                window.location.href = "/logic/change_status?id=${obj.id}&status=9";
           }
	    }
	    
	    function toRevise(){
	       if(confirm("Are you sure to revise this job back to development?")){
                window.location.href = "/logic/change_status?id=${obj.id}&status=1";
           }
	    }

    //]]>
   </script>
</%def>


<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/logic/production"><img src="/images/images/menu_title_g.jpg"/></a></td>
    %if obj.status in [STATUS_APPROVE,]:
        %if has_permission("PRODUCTION_REVISE"):
            <td width="64" valign="top" align="left"><a href="#" onclick="toRevise()"><img src="/images/images/menu_revise_g.jpg"/></a></td>
        %endif
        %if has_permission("PRODUCTION_DISCONTINUE_ITEM"):
            <td width="176" valign="top" align="left"><a href="#" onclick="toDiscontinue()"><img src="/images/images/menu_discontinue_g.jpg"/></a></td>
        %endif
    %endif        
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>
  

<div class="nav-tree">Production&nbsp;&nbsp;&gt;&nbsp;&nbsp;Detail</div>

<div>
	<div class="case-list-one">
        <ul>
            <li class="label"><label class="fieldlabel">Item Code</label></li>
            <li>${obj.jobNo}</li>
        </ul>      
        <ul>
            <li class="label"><label class="fieldlabel">Description</label></li>
            <li>${obj.desc}</li>
        </ul>   
        <ul>
            <li class="label"><label class="fieldlabel">Create Date</label></li>
            <li>${obj.createTime.strftime("%Y/%m/%d %H:%M")}</li>
        </ul>
    </div>
    <div class="case-list-one">
        <ul>
            <li class="label"><label class="fieldlabel">r-trac #</label></li>
            <li>${obj.systemNo}</li>
        </ul>
        <ul>
            <li class="label"><label class="fieldlabel">Status</label></li>
            <li>${obj.showStatus()}</li>
        </ul>
        <ul>
            <li class="label"><label class="fieldlabel">Approve Date</label></li>
            <li>${obj.approveTime.strftime("%Y/%m/%d %H:%M") if obj.approveTime else ''}</li>
        </ul>
    </div>
</div>

<div style="clear:both"><br /></div>

<div id="recordsArea" style="margin:5px 0px 10px 10px">
    <table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:800px">
        <thead>
            <tr>
                <th width="250" height="25">File Name</th>
                <th width="400">Description</th>
                <th width="150">Last Modified Date</th>
            </tr>
        </thead>
        <tbody>
                %for f in files:
                <tr>
                    <td style="border-left:1px solid #ccc;"><a href="/download?id=${f.id}">${f.fileName}</a></td>
                    <td>${f.remark}</td>
                    <td>${f.createTime.strftime("%Y/%m/%d %H:%M")}</td>
                </tr>
                %endfor
        </tbody>
    </table>
</div>

