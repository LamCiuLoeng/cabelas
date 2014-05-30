# -*- coding: utf-8 -*-
'''
Created on 2014-2-17
@author: CL.lam
'''
from sqlalchemy.sql.expression import and_
from rpac.widgets.components import RPACForm, RPACText, RPACCalendarPicker, \
    RPACSelect
from rpac.model import ORDER_NEW, ORDER_INPROCESS, ORDER_COMPLETE, qry
from rpac.model.ordering import ORDER_CANCEL



__all__ = ['order_search_form', ]

'''
def getPrintShop():
    return [( "", "" ), ] + [( unicode( p.id ), unicode( p ) ) for p in qry( PrintShop ).filter( and_( PrintShop.active == 0 ) ).order_by( PrintShop.name ).all()]
'''

class OrderSearchForm(RPACForm):
    fields = [
              RPACText("no", label_text = "Job No"),
              RPACText("customerpo", label_text = "Cabela’s PO#"),
              RPACText("vendorpo", label_text = "Vendor PO"),
              RPACCalendarPicker("create_time_from", label_text = "Create Date(from)"),
              RPACCalendarPicker("create_time_to", label_text = "Create Date(to)"),
              RPACSelect("status", label_text = "Status", options = [("", ""), (str(ORDER_NEW), "New"),
                                                                     (str(ORDER_INPROCESS), "In Process"),
                                                                     (str(ORDER_COMPLETE), "Completed"),
                                                                     (str(ORDER_CANCEL), "Cancelled"),
                                                                     ]),
#              RPACSelect( "printShopId", label_text = "Print Shop", options = getPrintShop ),
              ]

order_search_form = OrderSearchForm()
