<%inherit file="rpac.templates.master"/>

<%
    from repoze.what.predicates import in_any_group,in_group,has_permission
    from rpac.model import FILE_CHECK_IN,FILE_CHECK_OUT,STATUS_NEW,STATUS_UNDER_DEV
%>

<%def name="extTitle()">r-pac - Item Development - Detail</%def>

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
    
    
</style>
</%def>

<%def name="extJavaScript()">
	<script type="text/javascript" src="/js/numeric.js" language="javascript"></script>
	<script language="JavaScript" type="text/javascript">
    //<![CDATA[
		$(document).ready(function(){
		    $(".num").numeric();
	        $( ".datePicker" ).datepicker({"dateFormat":"yy/mm/dd"});
	        var counter = 10;
	        
	        // new file begin
	        $( "#new-file-div" ).dialog({
                  modal: true,
                  autoOpen: false,
                  width: 800,
                  height: 400 ,
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
                            var hasfile = false;
                            $("[name^='newfile_']").each(function(){
                                var t = $(this);
                                if(t.val()){ hasfile = true; }
                            });
                            
                            if(!hasfile){
                                alert("Please select at least one file to create item.");
                                return;
                            }else{
                                $("#newfileform").submit();
                            }
                        },                    
                    "Cancel" : function() { $( this ).dialog( "close" ); }
                  }
              });
              
              // new file end
              
              // checkin file begin
              $( "#checkin-div" ).dialog({
                  modal: true,
                  autoOpen: false,
                  width: 800,
                  height: 300 ,
                  buttons: {
                    "Submit" : function() {                            
                            if( !$("input[name='updatefile']").val() ){
                                alert("Please upload a file to check in!");
                                return;
                            }else{
                                var form = $("#checkinfileform");
                                $("input[name='']",form).val();                          
                                form.submit();
                            }
                        },                    
                    "Cancel" : function() { $( this ).dialog( "close" ); }
                  }
              });
              //checkin file end    
              
              //start development begin;
              $( "#start-div" ).dialog({
	              modal: true,
	              autoOpen: false,
	              width: 500,
	              height: 250 ,
	              buttons: {
	                "Submit" : function() { 
	                    var d= $("#estimatedReadyDate").val();
	                    if(!d){
	                        alert("Please input the 'Estimated Ready Date' !");
	                        return;
	                    }
	                    
	                    var p= $("#estimatedPrice").val();
	                    if(!p){
	                        alert("Please input the 'Estimated Price' !");
	                        return;
	                    }
	                    
	                    $("#startform").submit();                    
	                },
	                "Cancel" : function() { $( this ).dialog( "close" ); }
	              }
	          });
              //start development end                        
	    });

	    
	    function toNewFile(){
	       $( "#new-file-div" ).dialog( "open" );
	    }
	    
	    function delFile(obj){
	       var t = $(obj);
	       $(t.parents("tr")[0]).remove();
	    }
	    
	    function toCancel(){
	       if(confirm("Are you sure to cancel this job?")){
	           window.location.href = "/logic/change_status?id=${obj.id}&status=-1";
	       }
	    }
	    
	    
	    function toStart(){
	       $( "#start-div" ).dialog( "open" );
	    }
               
	    function toApprove(){
	       var checked = $("[name='files']:checked");
	       if(checked.length < 1){
	           alert("Please select at least one file to approve the job!");
	           return;
           }
           
           var allOK = true;
           checked.each(function(){
               var t = $(this);
               var tr = $(t.parents("tr")[0]);
               var btn = $("input[type='button']",tr);
               if(btn.attr("ref")=='1'){ allOK = false; }
           });
           	    
	       if(!allOK){
	           alert("Some file(s) are in check out status, can't approve for production!");
	           return;
	       }else{
    	       if(confirm("Are you sure to approve this job for production?")){
    	       var ids = []
    	       $("[name='files']:checked").each(function(){
    	           ids.push($(this).val());
    	       });
                    window.location.href = "/logic/change_status?id=${obj.id}&status=2&ids=" + ids.join("|");
               }
	       }	    
	    }
	    
	    function toCheckInOut(obj,id){
	       var t = $(obj); 
	       if(t.attr("ref")==0){  //if the orignal status is check in
               var params = {
                   id : id,
                   changeto : t.attr("ref") == '0' ? 1 : 0 ,
                   time : Date.parse(new Date())
               }
               $.getJSON('/logic/ajaxCheckOut',params,function(r){
                   if(r.flag != 0){
                       alert(r.msg);
                       return;
                   }else{
                       var k = $("#td_fid_"+id);
                       t.attr("ref",1);
                       t.val("Check In");
                       k.html(k.text());
                       $("#td_updateBy_"+id).text(r.updateBy);
                       $("#td_updateTime_"+id).text(r.updateTime);
                   }
               })
           }else{ //if the orignal status is check out
               var div = $( "#checkin-div" );
               $("input[name='fid']",div).val(id);
               div.dialog( "open" );
           }
	    }
	    

	       

	    function toDel(obj,id){
	       if(confirm("Are you sure to delete this file?")){
               var params = {
                   id : id,
                   time : Date.parse(new Date())
               }	           
                   
	           $.getJSON('/logic/ajaxDelFile',params,function(r){
	               if(r.flag!=0){
	                   alert(r.msg);
	                   return;
	               }else{
	                   alert('Delete the file successfully!');
	                   var t = $(obj);
	                   $(t.parents("tr")[0]).remove();
	               }
	           })
	       }else{
	           return;
	       }
        }
        
        
        function toShare(id){
            if(confirm("Are you sure to share this file with Cabela's users?")){
               var params = {
                   id : id,
                   time : Date.parse(new Date())
               }               
                   
               $.getJSON('/logic/ajaxShareFile',params,function(r){
                   if(r.flag!=0){
                       alert(r.msg);
                       return;
                   }else{
                       alert('The file is shared successfully!');
                       window.location.reload(true);
                   }
               })
           }else{
               return;
           }
        }
        
        function selectAllShare(obj,css){
            var t = $(obj);
            if(t.is( ":checked" )){
                $(css).prop("checked",true);
            }else{
                $(css).prop("checked",false);
            }
        }
    //]]>
   </script>
</%def>


<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/logic/index"><img src="/images/images/menu_title_g.jpg"/></a></td>
    %if obj.status == 0:
        %if has_permission("ITEM_DEV_START_DEV"):
            <td width="176" valign="top" align="left"><a href="#" onclick="toStart()"><img src="/images/images/menu_start_dev_g.jpg"/></a></td>
        %endif            
    %endif  
    %if obj.status in [0,1]:   
        %if has_permission("ITEM_DEV_ADD_FILE"):
            <td width="176" valign="top" align="left"><a href="#" onclick="toNewFile()"><img src="/images/images/menu_new_file_g.jpg"/></a></td>
        %endif
        %if has_permission("ITEM_DEV_CANCEL_ITEM"):
            <td width="176" valign="top" align="left"><a href="#" onclick="toCancel()"><img src="/images/images/menu_cancel_job_g.jpg"/></a></td>
        %endif
        %if has_permission("ITEM_DEV_APPROVE_ITEM"):    
            <td width="176" valign="top" align="left"><a href="#" onclick="toApprove()"><img src="/images/images/menu_approve_g.jpg"/></a></td>
        %endif            
    %endif
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

    
<div class="nav-tree">Item Development&nbsp;&nbsp;&gt;&nbsp;&nbsp;Detail</div>

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
            <li class="label"><label class="fieldlabel">Status</label></li>
            <li>${obj.showStatus()}</li>
        </ul>
        <ul>
            <li class="label"><label class="fieldlabel">Estimated Price</label></li>
            <li>${obj.estimatedPrice or ''}</li>
        </ul>
    </div>
    <div class="case-list-one">
        <ul>
            <li class="label"><label class="fieldlabel">r-trac #</label></li>
            <li>${obj.systemNo}</li>
        </ul>
        <ul>
            <li class="label"><label class="fieldlabel">Create date</label></li>
            <li>${obj.createTime.strftime("%Y/%m/%d %H:%M")}</li>
        </ul>
        <ul>
            <li class="label"><label class="fieldlabel">Estimated Ready Date</label></li>
            <li>${obj.estimatedReadyDate or ''}</li>
        </ul>
    </div>
</div>

<div style="clear:both"><br /></div>

<div id="recordsArea" style="margin:5px 0px 10px 10px">
    <table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1350px">
        <thead>
            <tr>
                %if obj.status in [STATUS_NEW,STATUS_UNDER_DEV,] :
                    <th width="30"></th>
                %endif
                <th width="250" height="25">File Name</th>
                <th width="400">Description</th>
                %if obj.status in [STATUS_NEW,STATUS_UNDER_DEV,] :
                    <th width="100">Check In/Out</th>
                %endif
                <th width="150">Last Modified Date</th>
                <th width="150">Last Modified By</th>
                %if has_permission('ITEM_DEV_SEE_ALL_FILE'):
                    <th width="180">Shared with Cabela's users</th>
                %endif
                %if has_permission('ITEM_DEV_DEL_FILE'):
                    <th width="160">Action</th>
                %endif
            </tr>
        </thead>
        <tbody>
            %for f in files:
                <tr>
                	%if obj.status in [STATUS_NEW,STATUS_UNDER_DEV,] :
                    	<td class="bl" style="border-right:none" rowspan="${len(f.versions) + 1}" valign="top">
                    		<input type="checkbox" name="files" value="${f.id}"/>
                    	</td>
                    %endif
                	<td class="bl" style="text-align:left" id="td_fid_${f.id}">
                		%if f.status == FILE_CHECK_IN:
                            <a href="/download?id=${f.id}">${f.fileName}</a>
                        %else:
                            ${f.fileName}
                        %endif
                	</td>
                    <td style="text-align:left">${f.remark}</td>
                    %if obj.status in [STATUS_NEW,STATUS_UNDER_DEV,] :
                        <td>
                            %if has_permission("ITEM_DEV_CHECK_IN_OUT_FILE"):
                                %if f.status == FILE_CHECK_IN :
                                    <input type="button" id="btn_${f.id}" value="Check Out" class="btn" onclick="toCheckInOut(this,${f.id})" ref="${f.status}"/>
                                %elif f.checkoutById == request.identity["user"].user_id or in_group("Admin"): 
                                    <input type="button" id="btn_${f.id}" value="Check In" class="btn" onclick="toCheckInOut(this,${f.id})" ref="${f.status}"/>
                                %endif
                            %endif
                        </td>
                    %endif
                    <td id="td_updateTime_${f.id}">${f.updateTime.strftime("%Y/%m/%d %H:%M")}</td>
                    <td id="td_updateBy_${f.id}">${f.updateBy}</td>
                    %if has_permission('ITEM_DEV_SEE_ALL_FILE'):
                        <td>${'YES' if f.share == 'Y' else 'NO'}</td>
                    %endif
                    %if has_permission('ITEM_DEV_DEL_FILE'):
                        <td>
                        	%if obj.status in [STATUS_NEW,STATUS_UNDER_DEV,] :
	                            <input type="button" class="btn" value="Del" onclick="toDel(this,${f.id})"/>&nbsp;
	                            %if f.share != 'Y':
	                                <input type="button" class="btn" value="Share with Cabela's" onclick="toShare(${f.id})"/>
	                            %endif
                            %endif
                        </td>
                    %endif
                </tr>
                %for v in f.versions:
            		<tr class="version">
                		<td class="bl" style="text-align:left"><a href="/logic/downloadFromVersion?id=${v.id}">${v.fileName}</a></td>
                		<td style="text-align:left">${v.remark}</td>
                		%if obj.status in [STATUS_NEW,STATUS_UNDER_DEV,] :
                			<td>&nbsp;</td>
                		%endif
                		<td>${v.updateTime.strftime("%Y/%m/%d %H:%M")}</td>
                		<td>${v.updateBy}</td>
                		%if has_permission('ITEM_DEV_SEE_ALL_FILE'):
                			<td>&nbsp;</td>
                		%endif
                		%if has_permission('ITEM_DEV_DEL_FILE'):
                			<td>&nbsp;</td>
                		%endif
            		</tr>
            	%endfor
            %endfor
        </tbody>
    </table>
</div>




<div id="new-file-div" title="Add New File(s)">
    <form action="/logic/add_new_file" id="newfileform" method="POST" enctype="multipart/form-data">
        <input type="hidden" name="id" value="${obj.id}"/>
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
                    <td><input type="checkbox" name="share_00" value="Y" class="newfilecb"/>
                %else:
                    <input type="hidden" name="share_00" value="Y"/>
                %endif
                <td><input type="file" name="newfile_00"/></td>
                <td><textarea name="desc_00" class="file_textarea"></textarea></td>
                <td><input type="button" value="Del" class="btn" onclick="delFile(this)"/></td>
            </tr>
            <tr class="template">
                %if has_permission('ITEM_DEV_SHARE_FILE'):
                    <td><input type="checkbox" name="share_x" value="Y" class="newfilecb"/>
                %else:
                    <input type="hidden" name="share_x" value="Y"/>
                %endif
                <td><input type="file" name="newfile_x"/></td>
                <td><textarea name="desc_x" class="file_textarea"></textarea></td>
                <td><input type="button" value="Del" class="btn" onclick="delFile(this)"/></td>
            </tr>
        </table>
        %if has_permission('ITEM_DEV_SHARE_FILE'):
        <p>
            <input type="checkbox" name="flags" value="CABELAS" onclick="selectAllShare(this,'.newfilecb')"/>&nbsp;Notify Bed Bath &amp; Beyond<br />
            <input type="checkbox" name="flags" value="AE"/>&nbsp;Notify r-pac AE<br />
        </p>
        %else:
            <input type="hidden" name="flags" value="AE"/>
        %endif
    </form>
</div>



<div id="checkin-div" title="Check In File">
    <form action="/logic/checkInFle" id="checkinfileform" method="POST" enctype="multipart/form-data">
        <input type="hidden" name="id" value="${obj.id}"/>
        <input type="hidden" name="fid" value=""/>
        <table class="gridTable" cellpadding="0" cellspacing="0" border="1" id="filetb">
            <tr>
                %if has_permission('ITEM_DEV_SHARE_FILE'):
                    <td style="width:150px">Share with Cabela's</td>
                %endif
                <td style="width:250px">File</td>
                <td style="width:250px">Description</td>
            </tr>
            <tr>
                %if has_permission('ITEM_DEV_SHARE_FILE'):
                    <td><input type="checkbox" name="updateshare" value="Y" class="chickincb"/>
                %else:
                    <input type="hidden" name="updateshare" value="Y"/>
                %endif
                <td><input type="file" name="updatefile"/></td>
                <td><textarea name="updatedesc" class="file_textarea"></textarea></td>
            </tr>
        </table>
        %if has_permission('ITEM_DEV_SHARE_FILE'):
        <p>
            <input type="checkbox" name="flags" value="CABELAS" onclick="selectAllShare(this,'.chickincb')"/>&nbsp;Notify Bed Bath &amp; Beyond<br />
            <input type="checkbox" name="flags" value="AE"/>&nbsp;Notify r-pac AE<br />
        </p>
        %else:
            <input type="hidden" name="flags" value="AE"/>
        %endif
    </form>
</div>


<div id="start-div" title="Start Development">
    <form action="/logic/change_status" id="startform" method="POST" enctype="multipart/form-data">
    <input type="hidden" name="id" value="${obj.id}"/>
    <input type="hidden" name="status" value="${STATUS_UNDER_DEV}"/>
    <table >
        <tr>
            <td valign="top" width="200">Estimated ready Date</td>
            <td><input type="text" name="estimatedReadyDate" id="estimatedReadyDate" class="datePicker"/></td>
        </tr>
        <tr>
            <td valign="top">Estimated Price</td>
            <td><input type="text" name="estimatedPrice" id="estimatedPrice" class="num"/></td>
        </tr>
    </table>
    </form>
</div>
