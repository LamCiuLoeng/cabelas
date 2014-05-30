<%inherit file="rpac.templates.master"/>

<%
    from repoze.what.predicates import in_any_group,in_group,has_permission
%>


<%def name="extTitle()">r-pac - Access</%def>

<div class="main-div">
	<div id="main-content">
	    %if has_permission("ACCESS_USER"):
    	    <div class="block">
    	    	<a href="/access/user"><img src="/images/user.jpg" width="55" height="55" alt="" /></a>
    	    	<p><a href="/access/user">User</a></p>
    	    </div>
	    %endif
	    
	    %if has_permission("ACCESS_ROLE"):
	        <div class="block">
                <a href="/access/group"><img src="/images/group.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/access/group">Role</a></p>
            </div>
        %endif
      
      <!--
      <div class="block">
        <a href="/access/permission"><img src="/images/permission.jpg" width="55" height="55" alt="" /></a>
        <p><a href="/access/permission">Permission Management</a></p>
        <div class="block-content">The module is for the "Permission Management" .</div>
      </div>
      -->


	</div>
</div>