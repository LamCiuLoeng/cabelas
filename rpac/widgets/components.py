# -*- coding: utf-8 -*-

from tw.api import CSSLink, JSLink, JSSource
from tw.forms.fields import InputField, SingleSelectField, TextArea, RadioButtonList, Form, ListFieldSet, HiddenField, MultipleSelectField
from tg import config


FIXED_WIDTH_CLASS = "width-250"
OPTION_WIDTH_CLASS = "width-220"
FIXED_HEIGHT_CLASS = "height-70"

class RPACBasicWidget( InputField ):
    css_class = FIXED_WIDTH_CLASS


#*********************************************
#   fields class
#*********************************************

class RPACHidden( HiddenField ):
    displays_on = config.default_renderer

class RPACText( RPACBasicWidget ):
    displays_on = config.default_renderer
    type = "text"

class RPACSelect( SingleSelectField ):
    displays_on = config.default_renderer
    css_class = FIXED_WIDTH_CLASS


class RPACMultipleSelect( MultipleSelectField ):
    displays_on = config.default_renderer
    css_class = " ".join( [OPTION_WIDTH_CLASS, "jqery_multiSelect"] )

class RPACTextarea( TextArea ):
    displays_on = config.default_renderer
    css_class = " ".join( [FIXED_WIDTH_CLASS, FIXED_HEIGHT_CLASS] )

class RPACRadio( RadioButtonList ):
    displays_on = config.default_renderer
    template = "rpac.templates.widgets.selection_list"


class RPACJQueryFields( RPACBasicWidget ):
    params = ["jquery_class"]
    jquery_class = ""

    def update_params( self, d ):
        super( RPACJQueryFields, self ).update_params( d )
        if self.jquery_class not in d.css_classes :
            d.css_classes.append( self.jquery_class )

class RPACSearchText( RPACJQueryFields ):
    type = "text"
    jquery_class = "ajaxSearchField"

class RPACCalendarPicker( RPACJQueryFields ):

    type = "text"
    jquery_class = "datePicker"

class RPACNumeric( RPACJQueryFields ):

    type = "text"
    jquery_class = "numeric"

class RPACAjaxText( RPACJQueryFields ):

    type = "text"
    jquery_class = "ajaxSearchField"

class RPACRequiredMixin():
    params = ["attrs", "isRequired"]

class RPACRequiredTextField( RPACRequiredMixin, RPACSearchText ):
    pass

class RPACRequiredSingleSelectField( RPACRequiredMixin, RPACSelect ):
    pass

class RPACNumberText( RPACJQueryFields ):
    type = "text"
    jquery_class = "v_is_number"

class RPACList( ListFieldSet ):
    def __init__( self, id = None, parent = None, children = [], **kw ):
        super( RPACList, self )
        self.children = [RPACText()]

#*********************************************
#   form class
#*********************************************

class RPACForm( Form ):
    template = "rpac.templates.widgets.form1"

    def __init__( self, id = None, parent = None, children = [], **kw ):
        super( Form, self ).__init__( id, parent, children, **kw )

class RPACNoForm( Form ):
    template = "rpac.templates.widgets.form2"

    def __init__( self, id = None, parent = None, children = [], ** kw ):
        super( Form, self ).__init__( id, parent, children, ** kw )

class RPACDesplay( Form ):
    template = "rpac.templates.widgets.column1"

    def __init__( self, id = None, parent = None, children = [], **kw ):
        super( Form, self ).__init__( id, parent, children, **kw )

class RPACHiddenForm( Form ):
    template = "rpac.templates.widgets.column2"

    def __init__( self, id = None, parent = None, children = [], ** kw ):
        super( Form, self ).__init__( id, parent, children, ** kw )
