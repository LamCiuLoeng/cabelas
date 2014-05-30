<%namespace name="tw" module="tw.core.mako_util"/>

% if hidden_fields:
    % for field in hidden_fields:
        ${field.display(value_for(field), **args_for(field))}
    % endfor
% endif