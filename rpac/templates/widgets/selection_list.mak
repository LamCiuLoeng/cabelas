<%namespace name="tw" module="tw.core.mako_util"/>\



% for value, desc, attrs in options:
	<% id_c = str(id_counter.next()) %>
	<input ${tw.attrs(
            [('type', field_type),
             ('name', name),
             ('id', (context.get('id') or '') + '_' + id_c),
             ('value', value)],
            attrs=attrs
        )} />\
    <label for="${(context.get('id') or '')}_${id_c}">${tw.content(desc)}</label>
	&nbsp;&nbsp;&nbsp;
%endfor
