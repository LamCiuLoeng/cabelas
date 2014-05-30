<%inherit file="rpac.templates.master"/>

<%
  from repoze.what.predicates import not_anonymous, in_group, has_permission
%>

<%def name="extTitle()">r-pac - Item Development</%def>

<div class="main-div">
	<div id="main-content">
        %if has_permission("ITEM_DEV"):
    	    <div class="block">
                <a href="/logic/index"><img src="/images/cabelas.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/logic/index">Cabela's</a></p>
                <div class="block-content">Item Development</div>
            </div>
        %endif
	</div>
</div>