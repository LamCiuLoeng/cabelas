<%inherit file="rpac.templates.master"/>

<%
    from repoze.what.predicates import in_any_group,in_group,has_permission
%>

<%def name="extTitle()">r-pac - Check Order Status</%def>

<%def name="extCSS()">
    <link rel="stylesheet" type="text/css" href="/css/custom/status.css" media="screen,print"/>
    <style type="text/css">
        .gridTable td {
            padding : 5px;
        }
        
        .num {
            text-align : right;
        }    
    </style>
</%def>

<%def name="extJavaScript()">
    <script type="text/javascript" src="/js/numeric.js" language="javascript"></script>
	<script language="JavaScript" type="text/javascript">
    //<![CDATA[
		$(document).ready(function(){
	        $( ".datePicker" ).datepicker({"dateFormat":"yy/mm/dd"});
	        $(".num").numeric();
	        
	        $(".cboxClass").click(function(){
               isCompleteOK();            
	        });
	        
	        $( "#so-div" ).dialog({
                modal: true,
                autoOpen: false,
                width: 400,
                height: 200 ,
                buttons: {
                "Submit" : function() { 
                    var so = $("#so").val();
                    if(!so){
                        alert("Please input the SO number!");
                        return;
                    }else{
                        var params = {
                            id : $(".cboxClass:checked").val(),
                            status : 1,                            
                            so : so,
                            t : $.now()
                        };
                        $.getJSON('/ordering/ajaxChangeStatus',params,function(r){
                            if(r.flag != 0){
                                alert(r.msg);
                            }else{
                                alert('Update the record successfully!');
                                window.location.reload(true);
                            }
                        })
                    }
            
                },
                "Cancel" : function() { $( this ).dialog( "close" ); }
                }
            });
            
            
            $( "#ship-div" ).dialog({
                modal: true,
                autoOpen: false,
                width: 600,
                height: 400 ,
                buttons: {
                "Submit" : function() { 
                    var params = {
                        id : $(".cboxClass:checked").val(),
                        status : 2,
                        t : $.now()
                    };
                    
                    var allQtyOK = true;
                    $(".shipinput").each(function(){
                        var tmp = $(this);
                        if(!tmp.val()){ allQtyOK = false; }
                        else{ params[tmp.attr("name")] = tmp.val(); }
                    });
                    if(!allQtyOK){
                        alert('Please input all the ship qty!');
                        return;
                    }
                    
                    $.getJSON('/ordering/ajaxChangeStatus',params,function(r){
                        if(r.flag != 0){
                            alert(r.msg);
                        }else{
                            alert('Update the record successfully!');
                            window.location.reload(true);
                        }
                    })
            
                },
                "Cancel" : function() { $( this ).dialog( "close" ); }
                }
            });
            
	    });
	    
	    function isCompleteOK(){
	       var one = false;               
           $(".cboxClass").each(function(){
               var t = $(this);
               if(t.attr("status") == "1" && t.is(":checked")){
                   one = true;
               }
           });
           if(one){
               $("#completebtn").addClass("btn").removeClass("btndisable");
           }else{
               $("#completebtn").addClass("btndisable").removeClass("btn");
           }
	    }
	    
	    function toSearch(){
	       $(".ordersearchform").attr("action","/ordering/index");
	       $(".ordersearchform").submit()
	    }
	    
	    function toExport(){
	       $(".ordersearchform").attr("action","/ordering/export");
           $(".ordersearchform").submit()
	    }

        
        function selectAll(obj){
            if($(obj).is( ":checked" )){
                $(".cboxClass").prop("checked",true);
            }else{
                $(".cboxClass").prop("checked",false);
            }
            isCompleteOK();
        }
        
        function toAssign(){
            var cb = $(".cboxClass:checked");
            if(cb.length != 1){
                alert("Please select one and only one record to assign so!");
                return;        
            }else if(cb.attr("status") != 0){
                alert("The record is not in New status!");
                return;
            }else{
                $( "#so-div" ).dialog( "open" );
            }
        }
        
        function toComplete(){
            var cb = $(".cboxClass:checked");
            if(cb.length != 1){
                alert("Please select one and only one record to edit status!");
                return;        
            }else if(cb.attr("status") != 1){
                alert("The record is not in process status!");
                return;
            }else{
                var params = {
                    id : cb.val(),                       
                    t : $.now()
                }
                $.getJSON("/ordering/ajaxOrderInfo",params,function(r){
                    if(r.flag != 0 ){
                        alert(r.msg);
                        return;
                    }else{
                        var html = '';
                        for(var i=0;i<r.data.length;i++){
                            var tmp = r.data[i];
                            html += '<tr><td style="border-left:1px solid #ccc;">'+tmp.code+'</td><td>'+tmp.qty+'</td><td><input type="text" class="shipinput num" name="ship_'+tmp.id+'" value=""/></td></tr>';
                        }
                        $("#shipbody").html(html);
                        $(".num","#ship-div").numeric();
                        $( "#ship-div" ).dialog( "open" );
                    }
                });
            }     
        }
    //]]>
   </script>
</%def>


<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/ordering/index"><img src="/images/images/menu_title_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Check Order Status</div>

<div>
	${widget(values,action="/ordering/index")|n}
</div>
<div style="clear:both"></div>

<div style="margin:5px 0px 10px 10px">
    <input type="button" class="btn" value="Search" onclick="toSearch()"/>&nbsp;
    %if has_permission("MAIN_ORDERING_EXPORT"):
        <input type="button" class="btn" value="Export" onclick="toExport()"/>&nbsp;
    %endif
    %if has_permission("MAIN_ORDERING_ASSIGN_SO"):
        <input type="button" class="btn" value="Add SO" onclick="toAssign()"/>&nbsp;
    %endif
    %if has_permission("MAIN_ORDERING_EDIT_STATUS"):
        <input type="button" class="btndisable" value="Complete" onclick="toComplete()" id="completebtn"/>&nbsp;
    %endif
</div>
<%
    my_page = tmpl_context.paginators.result
    pager = my_page.pager(symbol_first="<<",show_if_single_page=True)
%>
<div id="recordsArea" style="margin:5px 0px 10px 10px">
    <table class="gridTable" cellpadding="0" cellspacing="0" border="0" style="width:1430px">
        <thead>
          %if my_page.item_count > 0 :
              <tr>
                <td style="text-align:right;border-right:0px;border-bottom:0px" colspan="20">
                  ${pager}, <span>${my_page.first_item} - ${my_page.last_item}, ${my_page.item_count} records</span>
                </td>
              </tr>
          %endif
            <tr>
                <th width="50"><input type="checkbox" onclick="selectAll(this)"/></th>
                <th width="150" height="25">Job No</th>
                <th width="250">Cabela’s PO#</th>
                <th width="250">Vendor PO</th>
                <th width="200">Create Date (HKT)</th>
                <th width="150">Create By</th>
                <!-- <th width="200">Production Location</th> -->
                <th width="150">Status</th>
                <th width="150">r-pac SO</th>
                <th width="180">Completed Date</th>
                <th width="200">Shipped Quantity</th>
            </tr>
        </thead>
        <tbody>
            %if len(result) < 1:
                <tr>
                    <td colspan="20" style="border-left:1px solid #ccc">No match record(s) found!</td>
                </tr>
            %else:
                %for obj in result:
                <tr>
                    <td style="border-left:1px solid #ccc;"><input type="checkbox" value="${obj.id}" class="cboxClass" status="${obj.status}"/></td>
                    <td><a href="/ordering/detail?id=${obj.id}">${obj.no}</a></td>
                    <td>${obj.customerpo}</td>
                    <td>${obj.vendorpo}</td>
                    <td>${obj.createTime.strftime("%Y/%m/%d %H:%M")}</td>
                    <td>${obj.createBy}</td>
                    <!-- <td></td> -->
                    <td class="status${obj.status}">${obj.showStatus()}</td>
                    <td>${obj.so or ''}</td>
                    <td>${obj.completeDate.strftime("%Y/%m/%d %H:%M") if obj.completeDate else ''}</td>
                    <td>${obj.shipQty or ''}</td>
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





<div id="so-div" title="Assign SO">
    <table >
        <tr>
            <td valign="top" width="120">SO#</td>
            <td><input type="text" id="so" value=""/></td>
        </tr>        
    </table>
</div>

<div id="ship-div" title="Input Ship Qty">
    <table class="gridTable" cellpadding="0" cellspacing="0" border="0">
        <thead>
            <tr>
                <th style="width:200px">Item Code</th>
                <th style="width:200px">Order Qty</th>
                <th style="width:200px">Ship Qty</th>
            </tr>
        <thead>
        <tbody id="shipbody"></tbody>   
    </table>
</div>