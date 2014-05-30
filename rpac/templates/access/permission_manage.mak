<%inherit file="rpac.templates.master"/>

<%def name="extTitle()">r-pac - Access</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/custom/access.css" type="text/css" />
</%def>

<%def name="extJavaScript()">
	<script language="JavaScript" type="text/javascript">
    //<![CDATA[
		$(document).ready(function(){
	        $("form").submit(function(){
	        	var igs = new Array();
	        	$("option","#inGroup").each(function(){
	        		igs.push( $(this).val() );
	        	});

	        	var ogs = new Array();
	        	$("option","#outGroup").each(function(){
	        		ogs.push( $(this).val() );
	        	});

	        	$(this).append("<input type='hidden' name='igs' value='"+igs.join("|")+"'/>");
	        	$(this).append("<input type='hidden' name='ogs' value='"+ogs.join("|")+"'/>");

	        });
	    });

	    function toSave(){
	    	$("form").submit();
	    }

	    function addOption(d1,d2){
	    	var div1 = $("#"+d1);
	    	var div2 = $("#"+d2);
	    	$(":selected",div1).each(function(){
	    		div2.append(this);
	    	});
	    }

    //]]>
   </script>
</%def>


<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/access/index"><img src="/images/images/menu_am_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="toSave()"><img src="/images/images/menu_save_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Access&nbsp;&nbsp;&gt;&nbsp;&nbsp;Permission Manage</div>

<div>
	${widget(values,action="/access/save_permission")|n}
</div>

<div style="clear:both"><br /></div>

<div class="s_m_div">
  <div class="select_div">
    <ul>
      <li>
        <label for="inGroup">Groups with permission : </label>
      </li>
      <li>
        <select name="inGroup" id="inGroup" multiple="">
        	%for g in included:
        		<option value="${g.group_id}">${g.group_name}</option>
        	%endfor
        </select>
      </li>
    </ul>
  </div>
  <div class="bt_div">
    <input type="image" value="Add" onclick="addOption('outGroup','inGroup');return false;" src="/images/images/right2left.jpg"/>
    <br/>
    <br/>
    <input type="image" value="Delete" onclick="addOption('inGroup','outGroup');return false;" src="/images/images/left2right.jpg"/>
  </div>
  <div class="select_div">
    <ul>
      <li>
        <label for="inGroup">Groups without permission : </label>
      </li>
      <li>
        <select name="outGroup" id="outGroup" multiple="">
        %for g in excluded:
    		<option value="${g.group_id}">${g.group_name}</option>
    	%endfor
        </select>
      </li>
    </ul>
  </div>
</div>
