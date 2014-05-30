# -*- coding: utf-8 -*-
'''
Created on 2014-2-10
@author: CL.lam
'''
from components import RPACForm, RPACText, RPACCalendarPicker, RPACSelect
from rpac.model.logic import STATUS_NEW, STATUS_UNDER_DEV, STATUS_APPROVE, \
    STATUS_CANCEL, STATUS_DISCONTINUE


__all__ = ['search_form', 'approve_search_form']

class SearchForm(RPACForm):
    fields = [
              RPACText("jobNo", label_text = "Item Code"),
              RPACText("systemNo", label_text = "r-trac #"),
              RPACText("desc", label_text = "Description"),
              RPACSelect("status", label_text = "Status", options = [("", ""), (str(STATUS_NEW), "New"),
                                                                     (str(STATUS_UNDER_DEV), "Under Development"),
                                                                     (str(STATUS_APPROVE), "Approved for production"),
                                                                     (str(STATUS_CANCEL), "Cancelled"),
                                                                     (str(STATUS_DISCONTINUE), "Discontinued")]),
              RPACCalendarPicker("create_time_from", label_text = "Create Date(from)"),
              RPACCalendarPicker("create_time_to", label_text = "Create Date(to)"),
              ]

search_form = SearchForm()



class ApproveSearchForm(RPACForm):
    fields = [
              RPACText("jobNo", label_text = "Item Code"),
              RPACText("systemNo", label_text = "r-trac #"),
              RPACCalendarPicker("approve_time_from", label_text = "Approve Date(from)"),
              RPACCalendarPicker("approve_time_to", label_text = "Approve Date(to)"),
              RPACText("desc", label_text = "Description"),
              ]

approve_search_form = ApproveSearchForm()
