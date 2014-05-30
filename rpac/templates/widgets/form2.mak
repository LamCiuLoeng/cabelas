<%namespace name="tw" module="tw.core.mako_util"/>
% if hidden_fields:
    % for field in hidden_fields:
        ${field.display(value_for(field), **args_for(field))}
    % endfor
% endif

<%def name="showGroup(l)">
    <div class="case-list-one">
    	%for field in l:
    		<ul>
    			<li class="label"><label ${tw.attrs([('id', '%s.label' % field.id),('for', field.id)])} class="fieldlabel">${tw.content(field.label_text)}</label></li>
    			<li>${field.display(value_for(field), **args_for(field))}</li>
    		</ul>
    	%endfor
    </div>
</%def>


<%
	gs = [[],[]]
	for index,field in enumerate(fields): gs[index%2].append(field)
%>

%for g in gs:
	${showGroup(g)}
%endfor