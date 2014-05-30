<%inherit file="rpac.templates.master"/>

<%def name="extTitle()">r-pac - Access</%def>

<%def name="extCSS()">
<link rel="stylesheet" href="/css/custom/access.css" type="text/css" />
</%def>

<%def name="extJavaScript()">
	<script language="JavaScript" type="text/javascript">
    //<![CDATA[
        function toSave(){
            %if type == "user":
                if(!$("#userForm_user_name").val()){
                   alert("Please input the user name!");
                   return false;
                }else{
                   $("form").submit();
                }
            %elif type == "group":
                if(!$("#groupForm_group_name").val()){
                   alert("Please input the role's name!");
                   return false;
                }else{
                    var pigs = [];
                    $("option","#permissionInGroup").each(function(){
                        pigs.push( $(this).val() );
                    });
                    $("form").append("<input type='hidden' name='pers_yes' value='"+pigs.join("|")+"'/>");
                    $("form").submit();
                }            
            %endif
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
    <td width="176" valign="top" align="left"><a href="#" onclick="toSave()"><img src="/images/images/menu_save_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>
</div>

<div class="nav-tree">Access&nbsp;&nbsp;&gt;&nbsp;&nbsp;New</div>

<div style="margin: 10px 0px; overflow: hidden;">
  <div style="float: left;">
    %if type == "user":
    <div>
      <form name="userForm" class="tableform" method="post" action="/access/save_new">
      	<input type="hidden" name="type" value="user"/>
        <div class="case-list-one">
          <div class="case-list">
            <ul>
              <li class="label">
                <label for="userForm_user_name" class="fieldlabel">User Name</label>
              </li>
              <li>
                <input type="text" id="userForm_user_name" name="user_name" class="textfield" style="width: 250px;"/>
              </li>
            </ul>
            <ul>
              <li class="label">
                <label for="userForm_password" class="fieldlabel">Password</label>
              </li>
              <li>
                <input type="text" id="userForm_password" name="password" class="textfield" style="width: 250px;"/>
              </li>
            </ul>
            <ul>
              <li class="label">
                <label for="userForm_role" class="fieldlabel">Role</label>
              </li>
              <li>
                <table>
                %for g in groups:
                    <tr>
                        <td><input type="checkbox" name="groups" value="${g.group_id}" style="width:30px"/></td>
                        <td>&nbsp;${g}&nbsp;</td>
                    </tr>
                %endfor
                </table>
              </li>
            </ul>
            
          </div>
        </div>
        <div class="case-list-one">
          <div class="case-list">
            <ul>
              <li class="label">
                <label for="userForm_display_name" class="fieldlabel">Display Name</label>
              </li>
              <li>
                <input type="text" id="userForm_display_name" name="display_name" class="textfield" style="width: 250px;"/>
              </li>
            </ul>
            <ul>
              <li class="label">
                <label for="userForm_email_address" class="fieldlabel">E-mail</label>
              </li>
              <li>
                <input type="text" id="userForm_email_address" name="email_address" class="textfield" style="width: 250px;"/><br />(multiple email separated by commas(;))
              </li>
            </ul>
          </div>
        </div>
        <div style="clear: both;"><br/>
        </div>
      </form>
    </div>
    
    
    
    
    %elif type=="group":
    <div>
      <form name="groupForm" class="tableform" method="post" action="/access/save_new">
      	<input type="hidden" name="type" value="group"/>
        <div class="case-list-one">
          <div class="case-list">
            <ul>
              <li class="label">
                <label for="groupForm_group_name" class="fieldlabel">Group Name</label>
              </li>
              <li>
                <input type="text" id="groupForm_group_name" name="group_name" class="textfield" style="width: 250px;"/>
              </li>
            </ul>
          </div>
        </div>
        <div class="case-list-one">
          <div class="case-list">
            <ul>
              <li class="label">
                <label for="groupForm_display_name" class="fieldlabel">Display Name</label>
              </li>
              <li>
                <input type="text" id="groupForm_display_name" name="display_name" class="textfield" style="width: 250px;"/>
              </li>
            </ul>
          </div>
        </div>
        <div style="clear: both;"><br/></div>
      </form>
        
        <div style="overflow: auto; width: 1300px;">        
            <div class="s_m_div">
                <div class="select_div">
                    <ul>
                        <li><label for="permissionInGroup">Get the permissions : </label></li>
                        <li>
                            <select name="permissionInGroup" id="permissionInGroup" multiple="">
                                %for p in per_yes:
                                    <option value="${p.permission_id}">${p}</option>
                                %endfor
                            </select>
                        </li>
                    </ul>
                </div>
                <div class="bt_div">
                    <input type="image" value="Add" onclick="addOption('permissionOutGroup','permissionInGroup');return false;" src="/images/images/right2left.jpg"/>
                    <br/><br/>
                    <input type="image" value="Delete" onclick="addOption('permissionInGroup','permissionOutGroup');return false;" src="/images/images/left2right.jpg"/>
                </div>
                <div class="select_div">
                    <ul>
                        <li><label for="permissionOutGroup">Don't get the permissions : </label></li>
                        <li>
                            <select name="permissionOutGroup" id="permissionOutGroup" multiple="">
                                %for p in per_not:
                                    <option value="${p.permission_id}">${p}</option>
                                %endfor
                            </select>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
                
        
    </div>
    %endif
  </div>
</div>