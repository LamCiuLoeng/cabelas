<%inherit file="rpac.templates.master"/>

<%
import json
from rpac.model import ORDER_COMPLETE,ORDER_NEW
from repoze.what.predicates import in_group, has_permission
%>

<%def name="extTitle()">r-pac - Check Order Screen</%def>

<%def name="extCSS()">
<link rel="stylesheet" type="text/css" href="/css/nyroModal.css" media="screen,print"/>
<style type="text/css">
	.input-width{
		width : 300px
	}

	#warning {
		font:italic small-caps bold 16px/1.2em Arial;
	}

	td {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 12px;
        line-height: normal;
    }

	.title2{
	   color : #4e7596;
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

	.tdct {
	   border-bottom : 1px solid #ccc;
	   border-left : 1px solid #ccc;
	   border-right : 1px solid #ccc;
       background-color: #feffdc;
       padding-left: 10px;
	}

	.tdcttop {
	   border-top : 1px solid #ccc;
	}

    .gridTable td{
        padding : 5px;
    }


</style>
</%def>

<%def name="extJavaScript()">
<script type="text/javascript" src="/js/jquery.nyroModal.custom.min.js" language="javascript"></script>
<script language="JavaScript" type="text/javascript">
//<![CDATA[
    $(document).ready(function(){
        $('.nyroModal').nyroModal();
    });

    function toCancel(){
        if(window.confirm("Are you sure to cancel this order?")){
            window.location.href="/ordering/cancelOrder?id=${obj.id}";
        }
    }

//]]>
</script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="64" valign="top" align="left"><a href="/ordering/index"><img src="/images/images/menu_return_g.jpg"/></a></td>
    %if has_permission("MAIN_ORDERING_EXPORT_ORDER_FILE"):
        <td width="64" valign="top" align="left"><a href="/ordering/getexcel?id=${obj.id}"><img src="/images/images/export_order_g.jpg"/></a></td>
    %endif
    
    %if obj.status in [ORDER_NEW,]:
        <td width="64" valign="top" align="left"><a href="#" onclick="toCancel()"><img src="/images/images/menu_cancel_g.jpg"/></a></td>
    %endif

    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Check Order Screen</div>
<div style="width:1000px">
<table width="1000" border="0" cellspacing="0" cellpadding="0">
        <tbody>
        <tr>
            <td width="15">&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tbody>

                  <tr>
                    <td align="left" valign="top">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tbody>
                         <tr>
                            <td height="50"  bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;">Order No : ${obj.no}</td>
                            <td>&nbsp;</td>
                            <td height="50"  bgcolor="#669999" style="color:#FFF; padding:0px 0px 0px 30px; font-size:14px;">Order Date : ${obj.createTime.strftime("%Y-%m-%d %H:%M")}</td>
                          </tr>
                        <tr><td>&nbsp;</td></tr>
                        <tr>
                            <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tbody><tr>
                                    <td width="70">
                                        <strong>&nbsp;&nbsp;&nbsp;&nbsp;Bill To&nbsp;:</strong>
                                    </td>
                                    <td><img src="/images/search_10.jpg" width="380" height="2"></td>
                                </tr>
                            </tbody></table>
                            </td>
                            <td width="10">&nbsp;</td>
                            <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tbody><tr>
                                    <td width="70">
                                        <strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ship To&nbsp;:</strong>
                                    </td>
                                    <td><img src="/images/search_10.jpg" width="380" height="2"></td>
                                </tr>
                            </tbody></table>
                            </td>
                        </tr>
                        <tr>

                            <td width="50%" align="left" valign="top">
                            <table border="0" cellspacing="0" cellpadding="0" style="width:100%">
                                <tbody><tr>
                                    <td width="120">&nbsp;</td>
                                    <td>&nbsp;</td>
                                    <td width="30">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Company Name&nbsp;: </td>
                                    <td class="tdct tdcttop">${obj.billCompany}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Attention&nbsp;:&nbsp;</td>
                                    <td class="tdct">${obj.billAttn}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 1&nbsp;:</td>
                                    <td class="tdct">${obj.billAddress}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 2&nbsp;:</td>
                                    <td class="tdct">${obj.billAddress2}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 3&nbsp;:</td>
                                    <td class="tdct">${obj.billAddress3}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;City/Town</td>
                                    <td class="tdct">${obj.billCity}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;State&nbsp;:</td>
                                    <td class="tdct">${obj.billState}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Zip Code&nbsp;:</td>
                                    <td class="tdct">${obj.billZip}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Country&nbsp;:</td>
                                    <td class="tdct">${obj.billCountry}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Phone&nbsp;:</td>
                                    <td class="tdct">${obj.billTel}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Fax #&nbsp;:</td>
                                    <td class="tdct">${obj.billFax}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Email&nbsp;:</td>

                                    <td class="tdct">${obj.billEmail}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Remark&nbsp;:</td>
                                    <td class="tdct">${obj.billRemark}</td>
                                    <td>&nbsp;</td>
                                </tr>
                            </tbody></table>
                            </td>
                            <td>&nbsp;</td>
                            <td width="50%" align="left" valign="top">
                            <table border="0" cellspacing="0" cellpadding="0" style="width:100%">
                                <tbody><tr>
                                    <td width="120">&nbsp;</td>
                                    <td>&nbsp;</td>
                                    <td width="30">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Company Name&nbsp;: </td>
                                    <td class="tdct tdcttop">${obj.shipCompany}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Attention&nbsp;:&nbsp;</td>
                                    <td class="tdct">${obj.shipAttn}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 1&nbsp;:</td>
                                    <td class="tdct">${obj.shipAddress}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 2&nbsp;:</td>
                                    <td class="tdct">${obj.shipAddress2}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Address 3&nbsp;:</td>
                                    <td class="tdct">${obj.shipAddress3}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;City/Town</td>
                                    <td class="tdct">${obj.shipCity}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;State&nbsp;:</td>
                                    <td class="tdct">${obj.shipState}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Zip Code&nbsp;:</td>
                                    <td class="tdct">${obj.shipZip}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Country&nbsp;:</td>
                                    <td class="tdct">${obj.shipCountry}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Phone&nbsp;:</td>
                                    <td class="tdct">${obj.shipTel}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Fax #&nbsp;:</td>
                                    <td class="tdct">${obj.shipFax}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Email&nbsp;:</td>
                                    <td class="tdct">${obj.shipEmail}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">&nbsp;Remark&nbsp;:</td>
                                    <td class="tdct">${obj.shipRemark}</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td height="26" align="right" class="label">Special Instructions&nbsp;:</td>
                                    <td class="tdct">${obj.shipInstructions}</td>
                                    <td>&nbsp;</td>
                                </tr>
                            </tbody></table>
                            </td>
                        </tr>
                    </tbody></table>
                    </td>
                </tr>
                <!-- new field begin -->
                <tr>
                    <td valign="top" colspan="2">
                        <table border="0" cellspacing="0" cellpadding="0" style="width:500px">
                            <tbody><tr>
                                <td style="width:200px">&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td height="26" align="right" class="label">Cabela's PO#&nbsp;:</td>
                                <td class="tdct tdcttop">${obj.customerpo}</td>
                            </tr>
                            <tr>
                                <td height="26" align="right" class="label">Vendor PO&nbsp;:</td>
                                <td class="tdct">${obj.vendorpo}</td>
                            </tr>
                            <tr>
                                <td height="26" align="right" class="label">r-pac SO&nbsp;:</td>
                                <td class="tdct">${obj.so}</td>
                            </tr>
                        </tbody></table>
                    </td>
                </tr>
                <!-- new field end -->
            </tbody></table>
            </td>
        </tr>

    </tbody></table>
</div>

<br />
<div style="width:1150px;padding-left:15px">
    <table cellspacing="0" cellpadding="0" border="0" class="gridTable" id="sizetb" style="background-color: #feffdc;width:100%">
        <thead>
        	<tr style="text-align: center;">                     
	            <th style="width:150px;height:30px;">Item Code</th>
	            <th style="width:330px">Description</th>
	            <th style="width:120px">Size</th>
	            <th style="width:100px">Image</th>
                <th style="width:200px">Options</th>
	            <th style="width:150px">Lead Time</th>
                <th style="width:100px">Price</th>
                <th style="width:100px">Qty</th>
                <th style="width:100px">Amount</th>
                %if obj.status == ORDER_COMPLETE:
                    <th style="width:150px">Shipped QTY</th>
                %endif
	        </tr>
        </thead>
        <tbody>
            %for d in obj.dtls :
                <tr>
                    <td style="border-left:1px solid #ccc;">${d.itemCode}</td>
                    <td>${d.desc|n}</td>
                    <td>${d.size|n}</td>                  
                    <td style="padding:5px;">
                        <a href='/images/products/${d.itemCode}.jpg' class="nyroModal" title="${d.itemCode}">
                        <img src="/images/products/${d.itemCode}_s.jpg"/>
                        </a>
                    </td>
                    <td style="text-align:left;padding:5px">
                        %if d.optionText:
                            <ul>
                                %for o in json.loads(d.optionText):
                                    <li>${o}</li>
                                %endfor
                            </ul>
                        %endif
                    </td>
                    <td>${d.leadTime}</td>
                    <td>${d.price}</td>
                    <td>${d.qty}</td>
                    <td>${'%.2f' %d.amount}</td>
                    %if obj.status == ORDER_COMPLETE:
                        <td>${d.shipQty or ''}</td>
                    %endif
                </tr>
            %endfor
                <tr>
                    <td colspan="7" style="border-left:1px solid #ccc;text-align:right;">Total&nbsp;:&nbsp;</td>
                    <td>${obj.totalDtlQty}</td>
                    <td>${obj.totalDtlAmount}</td>
                    %if obj.status == ORDER_COMPLETE:
                        <td>${obj.shipQty or ''}</td>
                    %endif
                </tr>
        </tbody>
    </table>
</div>

<div style="clear:both"></div>
