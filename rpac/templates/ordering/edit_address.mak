<%inherit file="rpac.templates.master"/>

<%
	from repoze.what.predicates import in_group
%>

<%def name="extTitle()">r-pac - Manage Ship Info</%def>

<%def name="extCSS()">
<style type="text/css">
    td {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 12px;
        text-decoration: none;
        line-height: normal;
    }
    
	.input-width{
		width : 300px
	}
	
	#warning {
		font:italic small-caps bold 16px/1.2em Arial;
	}
	
	.error {
	   background-color: #FFEEEE !important;
        border: 1px solid #FF6600 !important;
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
    
    .input-style1 {
        border:#aaa solid 1px;
        width: 250px;
        background-color:#FFe;
    }
    .textarea-style {
        border:#aaa solid 1px;
        width:250px;
        background-color:#FFe;
    }
</style>
</%def>

<%def name="extJavaScript()">
<script language="JavaScript" type="text/javascript">
//<![CDATA[
        $(document).ready(function(){
            
        });
    
    
    function toConfirm(){
        var msg = [];
        $(".error").removeClass("error");        
        var fields = ['shipCompany','billCompany','shipAddress','billAddress',\
                      'shipCity','billCity','shipState','billState',\
                      'shipCountry','billCountry','shipTel','billTel','shipEmail','billEmail',\
                      ];
        
        var allOK = true;         
        for(var i=0;i<fields.length;i++){
            var name = fields[i];
            if(!$("#"+name).val()){
                $("#"+name).addClass('error');
                allOK = false;
            }
        }
        if(!allOK){ msg.push('Please fill in the required field(s)!'); }
        
        if(msg.length > 0){
            alert(msg.join('\n'));
            return;        
        }else{
            $("form").submit();
        }
    }
    
    function toCancel(){
        if(confirm('Are you sure to leave this page without saving your editing ?')){
            window.location.href = '/ordering/manageAddress' ;
        }else{
            return ;
        }
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

<div class="nav-tree">Manage Ship Info&nbsp;&nbsp;&gt;&nbsp;&nbsp;Edit</div>

<form id="orderForm" action="/ordering/saveAddress" method="post">
<input type="hidden" name="id" value="${values.get('id','')}"/>

<table width="1000" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="15">&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
    <tr>
		<td>&nbsp;</td>
		<td>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="850" align="left" valign="top">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr class="address_tr">
						<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="70">
									<strong>&nbsp;&nbsp;&nbsp;&nbsp;Ship To&nbsp;:</strong>
								</td>
								<td>
									<img src="/images/search_10.jpg" width="330" height="2" />
								</td>
							</tr>
						</table>
						</td>
						<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="70">
									<strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bill To&nbsp;:</strong>
								</td>
								<td>
									<img src="/images/search_10.jpg" width="330" height="2" />
								</td>
							</tr>
						</table>
						</td>
					</tr>
					<tr class="address_tr">
						<td width="50%" valign="top">
    						<table border="0" cellpadding="0" cellspacing="0" style="padding: 0; margin: 0;" id="shipTbl">
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
                                            <td align="right" height="26" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Company&nbsp;Name:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="shipCompany" class="input-style1 valid required" name="shipCompany" size="30" style="margin: 4px 0 4px 0;" type="text" value="${values.get('shipCompany','')}">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" height="26" class="label">
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
                                            <td align="right"  class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Address
                                                    1&nbsp;:&nbsp; 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <textarea id="shipAddress" class="textarea-style valid required" cols="45" name="shipAddress" rows="3">${values.get('shipAddress','')}</textarea>
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
                                            <td align="right" height="26" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;City/Town&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="shipCity" class="input-style1 valid required" name="shipCity" size="30" type="text" value="${values.get('shipCity','')}">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" height="26" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;State&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="shipState" class="input-style1 valid required" name="shipState" size="30" type="text" value="${values.get('shipState','')}">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" height="26" class="label">
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
                                            <td align="right" height="26" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Country&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="shipCountry" class="input-style1 valid required" name="shipCountry" size="30" type="text" value="${values.get('shipCountry','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" height="26" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Phone
                                                    #&nbsp;: 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="shipTel" class="input-style1 valid required" name="shipTel" size="30" type="text" value="${values.get('shipTel','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" height="26" class="label">
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
                                            <td align="right" height="26" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Email&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="shipEmail" class="input-style1 valid required" name="shipEmail" size="30" type="text" value="${values.get('shipEmail','')}"/>
                                            </td>
                                        </tr>
                                        
                                        
                                        <tr>
                                            <td align="right" height="26" class="label">
                                                Remark&nbsp;:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <textarea id="shipRemark" class="textarea-style" cols="45" name="shipRemark" rows="3">${values.get('shipRemark','')}</textarea>
                                            </td>
                                        </tr>
                                    </tbody></table>
						</td>
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
                                            <td align="right" height="26" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Company
                                                    Name&nbsp;: 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billCompany" class="input-style1 valid required" name="billCompany" size="30" style="margin: 4px 0 4px 0;" type="text" value="${values.get('billCompany','')}">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" height="26" class="label">
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
                                                <sup><span style="color:red">*</span></sup> &nbsp;Address
                                                    1&nbsp;:&nbsp; 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <textarea id="billAddress" class="textarea-style valid required" cols="45" name="billAddress" rows="3">${values.get('billAddress','')}</textarea>
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
                                            <td align="right" height="26" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;City/Town&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billCity" class="input-style1 valid required" name="billCity" size="30" type="text" value="${values.get('billCity','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" height="26" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;State&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billState" class="input-style1 valid required" name="billState" size="30" type="text" value="${values.get('billState','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" height="26" class="label">
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
                                            <td align="right" height="26" class="label">
                                                
                                                <sup><span style="color:red">*</span></sup> &nbsp;Country&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billCountry" class="input-style1 valid required" name="billCountry" size="30" type="text" value="${values.get('billCountry','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" height="26" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Phone
                                                    #&nbsp;: 
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billTel" class="input-style1 valid required" name="billTel" size="30" type="text" value="${values.get('billTel','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" height="26" class="label">
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
                                            <td align="right" height="26" class="label">
                                                <sup><span style="color:red">*</span></sup> &nbsp;Email&nbsp;:
                                                
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <input id="billEmail" class="input-style1 valid required" name="billEmail" size="30" type="text" value="${values.get('billEmail','')}"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" height="26" class="label">
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
					</tr>
					<tr><td>&nbsp;</td></tr>

                    <!-- new field begin -->
                   
                    <!-- new field end -->
				</table>
                                            
                <p style="text-align:right">
                    <input type="button" value="Confirm" class="btn" onclick="toConfirm()"/>&nbsp;
                    <input type="button" value="Cancel" class="btn" onclick="toCancel()"/>
                </p>        
				</td>
				<td>&nbsp;</td>
			</tr>
		</table>
		</td>
	</tr>

</table>

</form>
<div style="clear:both"><br/><br/></div>