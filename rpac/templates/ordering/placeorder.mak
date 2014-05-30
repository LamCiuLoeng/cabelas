<%inherit file="rpac.templates.master"/>
<%namespace name="tw" module="tw.core.mako_util"/>
<%
	from repoze.what.predicates import in_group
%>

<%def name="extTitle()">r-pac - Apparel Trim Ordering</%def>

<%def name="extCSS()">
<link rel="stylesheet" type="text/css" href="/css/nyroModal.css" media="screen,print"/>
<style type="text/css">
	.input-width{
		width : 300px
	}
	
	td {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 12px;
        line-height: normal;
    }
	
	.input-style1 {
        border: #aaa solid 1px;
        width: 250px;
        background-color: #FFe;
    }
    
    .textarea-style {
        border: #aaa solid 1px;
        width: 250px;
        background-color: #FFe;
    }
	
	#warning {
		font:italic small-caps bold 16px/1.2em Arial;
	}
	
	.error {
	   background-color: #FFEEEE !important;
	   border: 1px solid #FF6600 !important;
	}
	        
    .num{
        text-align : right;
        width : 80px;
    }
    
    .label{
       background-color: #4e7596;
        border-bottom: #FFF solid 1px;
        padding-right: 10px;
        font-family: Tahoma, Geneva, sans-serif;
        color: #fff;
        font-size: 12px;
        font-weight: bold;
        text-decoration: none;
    }
    
    .file_textarea {
        width:100px;
        height:50px;
        border: #aaa solid 1px;
        background-color: #FFe;
    }
</style>
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/js/jquery.nyroModal.custom.min.js" language="javascript"></script>
<script type="text/javascript" src="/js/numeric.js" language="javascript"></script>
<script type="text/javascript" src="/js/custom/item_common.js" language="javascript"></script>
<script type="text/javascript" src="/js/custom/placeorder.js" language="javascript"></script>
<script language="JavaScript" type="text/javascript">
//<![CDATA[
        $(document).ready(function(){
            $(".num").numeric();
            $('.nyroModal').nyroModal();
            
            $( "#option-div" ).dialog({
                  modal: true,
                  autoOpen: false,
                  width: 600,
                  height: 200 ,
                  buttons: {
                    "Submit" : function() { 
                        savetocart();
                    },
                    "Cancel" : function() { $( this ).dialog( "close" ); }
                  }
             });
        });
        
        function showAddress(k){
            var obj = $(k);
            if(obj.val() == 'View Detail'){
                $(".address_tr").show();
                obj.val('Hide Detail');
            }else{
                $(".address_tr").hide();
                obj.val('View Detail');
            }
        }
        
        function changeAdd(){
            var v = $("#addressID").val();
            if(v == 'OTHER'){
                $("input,textarea","#billTbl").val('');
                $("input,textarea","#shipTbl").val('');
                $(".address_tr").show();
                $("#viewbtn").val('Hide Detail');
            }else{
                var params = {
                    addressID : v,
                    t : Date.parse(new Date())
                }
                $.getJSON('/oncl/ajaxAddress',params,function(r){
                    if(r.code != 0 ){
                        alert(r.msg);                    
                    }else{
                        var fs = ["shipCompany","shipAttn","shipAddress","shipAddress2","shipAddress3","shipCity","shipState",\
                                "shipZip","shipCountry","shipTel","shipFax","shipEmail","shipRemark","billCompany","billAttn",\
                                "billAddress","billAddress2","billAddress3","billCity","billState","billZip","billCountry","billTel",\
                                "billFax","billEmail","billRemark",];
                        for(var i=0;i<fs.length;i++){
                            $("#"+fs[i]).val(r[fs[i]]);
                        }
                        
                        $(".address_tr").hide();
                        $("#viewbtn").val('View Detail');
                    }
                })
            }
        }
//]]>
</script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
  	<td width="64" valign="top" align="left"><a href="/index"><img src="/images/images/menu_return_g.jpg"/></a></td>
  	<td width="64" valign="top" align="left"><a href="#" onclick="toSave()"><img src="/images/images/menu_confirm_g.jpg"/></a></td>
  	<td width="64" valign="top" align="left"><a href="#" onclick="toCancel()"><img src="/images/images/menu_cancel_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Service Bureau Ordering</div>

<form id="orderForm" action="/ordering/saveorder" method="post">
<div style="width:1000px">
<table width="1000" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="15">&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
	   <td>&nbsp;</td>
	   <td height="50" colspan="2" bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;"><strong>Address Books :</strong> 
	       <select id="addressID" name='addressID' class="input-style1" onchange="changeAdd()">
	           %for a in address:
	               <option value="${a.id}">Ship To : ${a.shipCompany} --- Bill To : ${a.billCompany}</option>
	           %endfor
	               <option value="OTHER">Other</option>
	       </select>
	       &nbsp;<input type="button" class="btn" id="viewbtn" value="View Detail" onclick="showAddress(this)"/>
	   </td>
	</tr>
	<tr><td>&nbsp;</td></tr>
    <tr>
		<td>&nbsp;</td>
		<td>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="850" align="left" valign="top">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="70">
									<strong>&nbsp;&nbsp;&nbsp;&nbsp;Bill To&nbsp;:</strong>
								</td>
								<td>
									<img src="/images/search_10.jpg" width="380" height="2" />
								</td>
							</tr>
						</table>
						</td>
						<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="70">
									<strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ship To&nbsp;:</strong>
								</td>
								<td>
									<img src="/images/search_10.jpg" width="380" height="2" />
								</td>
							</tr>
						</table>
						</td>
					</tr>
					%if len(address) > 0:
					   <tr style="display:none" class="address_tr">
					%else:
					   <tr class="address_tr">
					%endif
						<td width="50%" valign="top">
    						<table border="0" cellpadding="0" cellspacing="0" style="padding: 0; margin: 0;" id="billTbl">
                                        <tbody><tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td width="10">
                                                &nbsp;
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Company
                                                    Name&nbsp;: 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billCompany" class="input-style1 valid" name="billCompany" size="30" style="margin: 4px 0 4px 0;" type="text" value="${values.get('billCompany','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                &nbsp;Attention&nbsp;:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billAttn" class="input-style1" name="billAttn" size="30" type="text" value="${values.get('billAttn','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Address 1&nbsp;:&nbsp; 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <textarea id="billAddress" class="textarea-style valid" cols="45" name="billAddress" rows="3">${values.get('billAddress','')}</textarea>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="label">
                                                &nbsp;Address 2&nbsp;:&nbsp;
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <textarea id="billAddress2" class="textarea-style valid" cols="45" name="billAddress2" rows="3" style="margin: 2px 0;">${values.get('billAddress2','')}</textarea>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="label">
                                                &nbsp;Address 3&nbsp;:&nbsp;
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <textarea id="billAddress3" class="textarea-style valid" cols="45" name="billAddress3" rows="3">${values.get('billAddress3','')}</textarea>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;City/Town&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billCity" class="input-style1 valid" name="billCity" size="30" type="text" value="${values.get('billCity','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;State&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billState" class="input-style1 valid" name="billState" size="30" type="text" value="${values.get('billState','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                &nbsp;Zip Code&nbsp;:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billZip" class="input-style1 valid" name="billZip" size="30" type="text" value="${values.get('billZip','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                
                                                <sup><span style="color:red">*</span></sup> &nbsp;Country&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billCountry" class="input-style1 valid" name="billCountry" size="30" type="text" value="${values.get('billCountry','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Phone
                                                    #&nbsp;: 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billTel" class="input-style1 valid" name="billTel" size="30" type="text" value="${values.get('billTel','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                &nbsp;Fax #&nbsp;:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billFax" class="input-style1" name="billFax" size="30" type="text" value="${values.get('billFax','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Email&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billEmail" class="input-style1 valid" name="billEmail" size="30" type="text" value="${values.get('billEmail','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="26" align="right" class="label">
                                                Remark&nbsp;:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <textarea id="billRemark" class="textarea-style" cols="45" name="billRemark" rows="3">${values.get('billRemark','')}</textarea>
                                            </td>
                                        </tr>
                                    </tbody></table>
                        </td>
						<td width="50%" valign="top">
    						<table border="0" cellpadding="0" cellspacing="0" style="padding: 0; margin: 0;" id="shipTbl">
                                <tbody>
                                <tr>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td width="10">
                                        &nbsp;
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;Company&nbsp;Name:
                                        
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipCompany" class="input-style1 valid" name="shipCompany" size="30" style="margin: 4px 0 4px 0;" type="text" value="${values.get('shipCompany','')}"  >
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        &nbsp;Attention&nbsp;:
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipAttn" class="input-style1" name="shipAttn" size="30" type="text" value="${values.get('shipAttn','')}">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;Address 1&nbsp;:&nbsp; 
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <textarea id="shipAddress" class="textarea-style valid" cols="45" name="shipAddress" rows="3">${values.get('shipAddress','')}</textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" class="label">
                                        &nbsp;Address 2&nbsp;:&nbsp;
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <textarea id="shipAddress2" class="textarea-style valid" cols="45" name="shipAddress2" rows="3" style="margin: 2px 0;">${values.get('shipAddress2','')}</textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" class="label">
                                        &nbsp;Address 3&nbsp;:&nbsp;
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <textarea id="shipAddress3" class="textarea-style valid" cols="45" name="shipAddress3" rows="3">${values.get('shipAddress3','')}</textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;City/Town&nbsp;:
                                        
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipCity" class="input-style1 valid" name="shipCity" size="30" type="text" value="${values.get('shipCity','')}">
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;State&nbsp;:
                                        
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipState" class="input-style1 valid" name="shipState" size="30" type="text" value="${values.get('shipState','')}">
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        &nbsp;Zip Code&nbsp;:
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipZip" class="input-style1 valid" name="shipZip" size="30" type="text" value="${values.get('shipZip','')}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;Country&nbsp;:
                                        
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipCountry" class="input-style1 valid" name="shipCountry" size="30" type="text" value="${values.get('shipCountry','')}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;Phone
                                            #&nbsp;: 
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipTel" class="input-style1 valid" name="shipTel" size="30" type="text" value="${values.get('shipTel','')}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        &nbsp;Fax #&nbsp;:
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipFax" class="input-style1" name="shipFax" size="30" type="text" value="${values.get('shipFax','')}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup> &nbsp;Email&nbsp;:
                                        
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input id="shipEmail" class="input-style1 valid" name="shipEmail" size="30" type="text" value="${values.get('shipEmail','')}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        Remark&nbsp;:
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <textarea id="shipRemark" class="textarea-style" cols="45" name="shipRemark" rows="3">${values.get('shipRemark','')}</textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        Special Instructions&nbsp;:
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <textarea id="shipInstructions" class="textarea-style" cols="45" name="shipInstructions" rows="3"></textarea>
                                    </td>
                                </tr>                                              
                            </tbody></table>
						</td>
						
					</tr>
					<tr><td>&nbsp;</td></tr>

                    <!-- new field begin -->
                    <tr>
                        <td valign="top" colspan="2">
                            <table border="0" cellspacing="0" cellpadding="0" style="width:850px">
                                <tbody><tr>
                                    <td style="width:200px">&nbsp;</td>
                                    <td style="width:10px;">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span></sup>Cabela's PO#
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <input name="customerpo" id="customerpo" type="text" class="input-style1">
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">
                                        <sup><span style="color:red">*</span>Vendor PO
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>
                                        <input name="vendorpo" id="vendorpo" type="text" class="input-style1">
                                    </td>
                                </tr>

                            </tbody></table>
                        </td>
                    </tr>        
				</table>
                                            
                  
				</td>

			</tr>
		</table>
		</td>
	</tr>
</table>
</div>
<br />

<div style="width:1150px;padding-left:15px">
    <table cellspacing="0" cellpadding="0" border="0" class="gridTable" style="background:white">
    <thead>
        <tr style="text-align: center;">                     
            <th style="width:150px;height:30px;">Item Code</th>
            <th style="width:250px">Description</th>
            <th style="width:200px">Size</th>
            <th style="width:100px">Image</th>
            <th style="width:100px">Options</th>
            <th style="width:80px">Qty</th>
            <th style="width:80px">Price</th>
            <th style="width:100px">Lead Time</th>
            <th style="width:150px">Action</th>
        </tr>
    </thead>
    <tbody>
        %for index,p in  enumerate(products):
            %if index % 2 == 0:
                <tr class="even">
            %else:
                <tr class="odd">
            %endif
                <td style="border-left:1px solid #ccc;">${p['productobj'].itemCode}</td>
                <td style="padding:5px;">${p['productobj'].desc|n}</td>
                <td style="padding:5px;">${p['productobj'].size|n}</td>
                <td style="padding:5px;">
                    <a href='/images/products/${p['productobj'].itemCode.replace("#","")}.jpg' class="nyroModal" title="${p['productobj'].itemCode}">
                    <img src="/images/products/${p['productobj'].itemCode}_s.jpg"/>
                    </a>
                </td>
                <td style="text-align:left;padding:5px" id="ot_${p["_k"]}">
                    <ul>
                        %for o in p.get('optionstext',[]):
                            <li>${o}</li>
                        %endfor
                    </ul>
                </td>
                <td id="qty_${p["_k"]}">${p['qty']}</td>
				<td id="price_${p["_k"]}">${p['price']}</td>
				<td id="leadTime_${p["_k"]}">${p['leadTime']}</td>                
                <td>
                    <input type="button" class="btn" value="Edit" onclick="editItem('${p["_k"]}')"/>&nbsp;
                    <input type="button" class="btn" value="Remove" onclick="removeItem('${p["_k"]}',this)"/>
                </td>
            </tr>
        %endfor
    </tbody>
    </table>
    
    <p style="text-align:right; padding:0px 0px 0px 50px">
        <input type="button" onclick="toSave()" class="btn" value="Confirm">&nbsp;&nbsp;
        <input type="button" onclick="toCancel()" class="btn" value="Cancel">
    </p>    
    
</div>
</form>

<div style="clear:both"></div>


<div id="option-div" title="Edit Item's Option">
    <input type="hidden" id="current_item" value=""/>
    <table class="" cellpadding="3" cellspacing="3" border="1" id="option-tb" style="width:500px">
        
    </table>
</div>
