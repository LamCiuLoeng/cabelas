<%inherit file="rpac.templates.master"/>
<%namespace name="tw" module="tw.core.mako_util"/>
<%
	from repoze.what.predicates import in_group
%>

<%def name="extTitle()">r-pac - Place an order</%def>

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
<script type="text/javascript" src="/js/custom/listItems.js" language="javascript"></script>
<script language="JavaScript" type="text/javascript">
//<![CDATA[
        $(document).ready(function(){
        	$('.nyroModal').nyroModal();
        	
			$( "#option-div" ).dialog({
                  modal: true,
                  autoOpen: false,
                  width: 600,
                  height: 200 ,
                  buttons: {
                    "Submit" : function() { 
                        addtocart();
                    },
                    "Cancel" : function() { $( this ).dialog( "close" ); }
                  }
             });
        });
        
        
        function checkout(){
            window.location.href = '/ordering/placeorder';
        }
        
//]]>
</script>
</%def>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
  	<td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
  	<td width="64" valign="top" align="left"><a href="/index"><img src="/images/images/menu_return_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Place an order</div>

<div>
    <div class="case-list-one">
        <ul>
            <li class="label"><label for="itemCode" class="fieldlabel">Item Code</label></li>
            <li><input type="text" id="itemCode" class="width-250 inputText" name="itemCode" value=""></li>
        </ul>
    </div>
</div>
<div style="clear:both"></div>

<div style="width:1200px;padding-left:10px">
	<p style="text-align:right; padding:0px 0px 0px 0px">
        <input type="button" onclick="checkout()" class="btn checkoutbtn" value="Shopping Cart [${len(session.get('items',[]))}],Checkout">
    </p>
    <table cellspacing="0" cellpadding="0" border="0" class="gridTable" style="background:white">
    <thead>
        <tr style="text-align: center;">                     
            <th style="width:200px;height:30px;">Item Code</th>
            <th style="width:330px">Description</th>
            <th style="width:120px">Size</th>
            <th style="width:150px">Image</th>
            <th style="width:100px">Action</th>
        </tr>
    </thead>
    <tbody id="producttb">
    	<%doc>
        %for index,p in enumerate(result):
            %if index % 2 == 0:
                <tr class="even">
            %else:
                <tr class="odd">
            %endif
                <td style="border-left:1px solid #ccc;">${p.itemCode}</td>
                <td>${p.desc}</td>
                <td>${p.size}</td>
                <td style="padding:5px;">
					<a href='/images/products/${p.image}.jpg' class="nyroModal" title="${p.itemCode}">
                    <img src="/images/products/${p.image}_s.jpg"/>
                    </a>                
                </td>
                <td><input type="button" class="btn" value="Add To Cart" onclick="showoptions(${p.id})"/></td>
            </tr>
        %endfor
        </%doc>
    </tbody>
    </table>
</div>

<div style="clear:both"></div>



<div id="option-div" title="Select Item's Option">
    <input type="hidden" id="current_item" value=""/>
    <table class="" cellpadding="3" cellspacing="3" border="1" id="option-tb" style="width:500px">
        
    </table>
</div>
