<%inherit file="rpac.templates.master"/>

<%
    from repoze.what.predicates import in_any_group,in_group,has_permission
    from rpac.model import STATUS_NEW,STATUS_UNDER_DEV,STATUS_APPROVE,STATUS_CANCEL,STATUS_DISCONTINUE
%>

<%def name="extTitle()">r-pac - Item Development</%def>

<%def name="extCSS()">
    <style type="text/css">
        .gridTable td {
            padding : 5px;
        }
        
        .file_textarea {
            width:200px;
            height:30px;
        }
        
        .template{
            display : none;
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
	        $( ".datePicker" ).datepicker({"dateFormat":"yy/mm/dd"});
	        var counter = 10;
	        
	        
	        $( "#new-item-div" ).dialog({
                  modal: true,
                  autoOpen: false,
                  width: 800,
                  height: 450 ,
                  buttons: {
                    "Add File" : function(){                       
                        var t = $(".template").clone().removeClass("template");
                        $("input[type='file'],textarea,input[type='checkbox'],input[type='hidden']",t).each(function(){
                            var obj = $(this);
                            var name = obj.attr("name");
                            obj.attr("name",name.replace("_x","_"+counter));
                        });
                        $("#filetb").append(t);
                        counter++;                        
                    },
                    "Submit" : function() { 
                        var jobNo = $("#f_jobNo").val();
                        if(!jobNo){
                            alert("Please input the Item Code!");
                            return;
                        }
                        
                        var hasfile = false;
                        $("[name^='file_']").each(function(){
                            var t = $(this);
                            if(t.val()){ hasfile = true; }
                        });
                        
                        if(!hasfile){
                            alert("Please select at least one file to create item.");
                            return;
                        }else{
                            var params = {
                                jobNo :jobNo,
                                t : Date.parse(new Date())
                            }
                            $.getJSON('/logic/ajaxCheckDuplidate',params,function(r){
                                if(r.flag != 0){
                                    alert(r.msg);
                                    return;
                                }else{
                                    $("#newitemform").submit();
                                }
                            })
                        }
                        
                    },
                    "Cancel" : function() { $( this ).dialog( "close" ); }
                  }
              });
	    });
	    
	    function toSearch(){
	    	$(".searchform").attr("action","/logic/index");
	       $(".searchform").submit();
	    }
	    
	    function toExport(){
	       $(".searchform").attr("action","/logic/export");
	       $(".searchform").submit();
	    }
	    
	    function toNewItem(){
	       $( "#new-item-div" ).dialog( "open" );
	    }
	    
	    function delFile(obj){
	       var t = $(obj);
	       $(t.parents("tr")[0]).remove();
	    }

    //]]>
   </script>
</%def>


<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/logic/index"><img src="/images/images/menu_title_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toSearch()"><img src="/images/images/menu_search_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toExport()"><img src="/images/images/menu_export_g.jpg"/></a></td>
    %if has_permission('ITEM_DEV_CREATE_ITEM'):
    	<td width="176" valign="top" align="left"><a href="#" onclick="toNewItem()"><img src="/images/images/menu_new_item_g.jpg"/></a></td>
    %endif 
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Item Development&nbsp;&nbsp;&gt;&nbsp;&nbsp;Index</div>

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
	${widget(values,action="/logic/index")|n}
</div>

<div style="clear:both"></div>

<%
    my_page = tmpl_context.paginators.result
    pager = my_page.pager(symbol_first="<<",show_if_single_page=True)
%>
<div id="recordsArea" style="margin:5px 0px 10px 10px">
    <table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1350px">
        <thead>
          %if my_page.item_count > 0 :
              <tr>
                <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="20">
                  ${pager}, <span>${my_page.first_item} - ${my_page.last_item}, ${my_page.item_count} records</span>
                </td>
              </tr>
          %endif
            <tr>
                <th width="100" height="25">r-trac #</th>
                <th width="250">Item Code</th>
                <th width="400">Description</th>
                <th width="200">Create Date (HKT)</th>
                <th width="200">Status</th>
                <th width="250">Estimated Ready Date</th>
                <th width="200">Approved Date</th>
                <th width="150">Estimated Price</th>
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
                    <td style="border-left:1px solid #ccc;"><a href="/logic/detail?id=${obj.id}">${obj.systemNo}</a></td>
                    <td>${obj.jobNo}</td>
                    <td>${obj.desc}</td>
                    <td>${obj.createTime.strftime("%Y/%m/%d %H:%M")}</td>
                    <td class="status${obj.status}">${obj.showStatus()}</td>
                    <td>${obj.estimatedReadyDate}</td>
                    <td>${obj.approveTime.strftime("%Y/%m/%d %H:%M") if obj.approveTime else ''}</td>
                    <td>${obj.estimatedPrice}</td>
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




<div id="new-item-div" title="Create New Item">
    <form action="/logic/save" id="newitemform" method="POST" enctype="multipart/form-data">
    <table >
        <tr>
            <td valign="top" width="120">Item Code</td>
            <td><input type="text" name="f_jobNo" id="f_jobNo"/></td>
        </tr>
        <tr>
            <td valign="top">Description</td>
            <td><textarea name="f_desc" id="f_desc"></textarea></td>
        </tr>
        <tr>
            <td valign="top">Files</td>
            <td>
                <table class="gridTable" cellpadding="0" cellspacing="0" border="1" id="filetb">
                    <tr>
                        %if has_permission('ITEM_DEV_SHARE_FILE'):
                            <td style="width:150px">Share with Cabela's</td>
                        %endif
                        <td style="width:250px">File</td>
                        <td style="width:250px">Description</td>
                        <td style="width:50px">Action</td>
                    </tr>
                    <tr>
                        %if has_permission('ITEM_DEV_SHARE_FILE'):
                            <td><input type="checkbox" name="share_00" value="Y"/></td>
                        %else:
                            <input type="hidden" name="share_00" value="Y"/>
                        %endif
                        <td><input type="file" name="file_00"/></td>
                        <td><textarea name="desc_00" class="file_textarea"></textarea></td>
                        <td><input type="button" value="Del" class="btn" onclick="delFile(this)"/></td>
                    </tr>
                    <tr class="template">
                        %if has_permission('ITEM_DEV_SHARE_FILE'):
                            <td><input type="checkbox" name="share_x" value="Y"/></td>
                        %else:
                            <input type="hidden" name="share_x" value="Y"/>
                        %endif
                        <td><input type="file" name="file_x"/></td>
                        <td><textarea name="desc_x" class="file_textarea"></textarea></td>
                        <td><input type="button" value="Del" class="btn" onclick="delFile(this)"/></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    </form>
</div>
