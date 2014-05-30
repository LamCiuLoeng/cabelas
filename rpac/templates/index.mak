<%inherit file="rpac.templates.master"/>

<%
  from repoze.what.predicates import not_anonymous, in_group, has_permission
%>

<%def name="extTitle()">r-pac - Item Development</%def>

<div class="main-div">
	<div id="main-content">
        %if has_permission("MAIN_ORDERING_PLACEORDER"):
            <div class="block">
                <a href="/ordering/listItems"><img src="/images/cabelas.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/ordering/listItems">Place an order</a></p>
            </div>
        %endif
        %if has_permission("MAIN_ORDERING_CHECKING"):
            <div class="block">
                <a href="/ordering/index"><img src="/images/cabelas.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/ordering/index">Check Order Status</a></p>
            </div>
        %endif
	</div>
</div>