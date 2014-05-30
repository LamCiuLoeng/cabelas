<%inherit file="rpac.templates.master"/>

<%
  from repoze.what.predicates import not_anonymous, in_group, has_permission
%>

<%def name="extTitle()">r-pac - Production</%def>

<div class="main-div">
	<div id="main-content">

	    <div class="block">
	    	<a href="/logic/production"><img src="/images/cabelas.jpg" width="55" height="55" alt="" /></a>
	    	<p><a href="/logic/production">Cabela's</a></p>
	    	<div class="block-content">Items in Production</div>
	    </div>

	</div>
</div>