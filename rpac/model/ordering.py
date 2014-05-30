# -*- coding: utf-8 -*-
'''
Created on 2014-2-17
@author: CL.lam
'''
from sqlalchemy.schema import Column, ForeignKey
from sqlalchemy.types import DateTime, Integer, Text, Numeric
from sqlalchemy.orm import relation, synonym, backref
from sqlalchemy.ext.declarative import declared_attr

from rpac.model import DeclarativeBase, Product, ProductMixin
from interface import SysMixin, nextVal


__all__ = [
           'ORDER_NEW', 'ORDER_INPROCESS', 'ORDER_COMPLETE', 'ORDER_CANCEL',
           'OrderHeader', 'OrderDetail', 'OrderDetailSubItem', 'AddressBook',
           ]

ORDER_NEW = 0
ORDER_INPROCESS = 1
ORDER_COMPLETE = 2
ORDER_CANCEL = -1



class OrderHeader(DeclarativeBase , SysMixin):
    __tablename__ = 'ordering_order_header'

    id = Column(Integer, primary_key = True)
    no = Column("no", Text)

    shipCompany = Column("ship_company", Text, default = None)
    shipAttn = Column("ship_attn", Text, default = None)
    shipAddress = Column("ship_address", Text, default = None)
    shipAddress2 = Column("ship_address2", Text, default = None)
    shipAddress3 = Column("ship_address3", Text, default = None)
    shipCity = Column("ship_city", Text, default = None)
    shipState = Column("ship_state", Text, default = None)
    shipZip = Column("ship_zip", Text, default = None)
    shipCountry = Column("ship_country", Text, default = None)
    shipTel = Column("ship_tel", Text, default = None)
    shipFax = Column("ship_fax", Text, default = None)
    shipEmail = Column("ship_email", Text, default = None)
    shipRemark = Column("ship_remark", Text, default = None)
    shipInstructions = Column("ship_instructions", Text)

    billCompany = Column("bill_company", Text, default = None)
    billAttn = Column("bill_attn", Text, default = None)
    billAddress = Column("bill_address", Text, default = None)
    billAddress2 = Column("bill_address2", Text, default = None)
    billAddress3 = Column("bill_ddress3", Text, default = None)
    billCity = Column("bill_city", Text, default = None)
    billState = Column("bill_state", Text, default = None)
    billZip = Column("bill_zip", Text, default = None)
    billCountry = Column("bill_country", Text, default = None)
    billTel = Column("bill_tel", Text, default = None)
    billFax = Column("bill_fax", Text, default = None)
    billEmail = Column("bill_email", Text, default = None)
    billRemark = Column("bill_remark", Text, default = None)

    customerpo = Column("customerpo", Text)
    vendorpo = Column("vendorpo", Text)

    so = Column(Text)
    completeDate = Column('complete_date', DateTime)
    totalDtlQty = Column("total_dtl_qty" , Text)
    totalDtlAmount = Column('total_dtl_amount', Numeric(15, 2), default = None)
    totalSubDtlQty = Column("total_sub_dtl_qty" , Text)
    totalSubDtlAmount = Column('total_sub_dtl_amount', Numeric(15, 2), default = None)
    shipQty = Column("ship_qty", Text)
    status = Column("status", Integer, default = ORDER_NEW)


    def __unicode__(self): return self.no
    def __str__(self): return self.no

    def __init__(self, *args, **kwargs):
        super(self.__class__, self).__init__(*args, **kwargs)
        seq = nextVal('ordering_header_seq')
        self.no = 'CABPO%.9d' % seq

    def showStatus(self):
        return {
                ORDER_NEW : 'New', ORDER_INPROCESS : 'In Process' , ORDER_COMPLETE : 'Completed' , ORDER_CANCEL : 'Cancelled'
                }.get(self.status, '')



class DtlMixin(object):

    productId = Column("product_id", Integer)
    options = Column(Text)
    qty = Column(Integer, default = 0)
    price = Column('price', Numeric(15, 6), default = None)
    leadTime = Column("lead_time", Text)
    optionContent = Column("option_content", Text)
    optionText = Column("option_text", Text)
    shipQty = Column("ship_qty", Text)
    combo = Column(Text, default = None)  # Y is combo ,NONE is single
    amount = Column('amount', Numeric(15, 6), default = None)


class OrderDetail(DeclarativeBase , SysMixin, ProductMixin, DtlMixin):
    __tablename__ = 'ordering_order_detail'

    id = Column(Integer, primary_key = True)

    headerId = Column("header_id", Integer, ForeignKey('ordering_order_header.id'))
    header = relation(OrderHeader, backref = backref("dtls", order_by = id), primaryjoin = "and_(OrderHeader.id == OrderDetail.headerId,OrderDetail.active == 0)")


class OrderDetailSubItem(DeclarativeBase , SysMixin, ProductMixin, DtlMixin):
    __tablename__ = 'ordering_order_detail_subitem'

    id = Column(Integer, primary_key = True)

    headerId = Column("header_id", Integer, ForeignKey('ordering_order_header.id'))
    header = relation(OrderHeader, backref = backref("subdtls", order_by = id), primaryjoin = "and_(OrderHeader.id == OrderDetailSubItem.headerId,OrderDetailSubItem.active == 0)")

    detailId = Column("detail_id", Integer, ForeignKey('ordering_order_detail.id'))
    detail = relation(OrderDetail, backref = backref("subitems", order_by = id), primaryjoin = "and_(OrderDetail.id == OrderDetailSubItem.detailId,OrderDetailSubItem.active == 0)")


class AddressBook(DeclarativeBase, SysMixin):
    __tablename__ = 'ordering_address_book'

    id = Column(Integer, primary_key = True)
    shipCompany = Column("ship_company", Text, default = None)
    shipAttn = Column("ship_attn", Text, default = None)
    shipAddress = Column("ship_address", Text, default = None)
    shipAddress2 = Column("ship_address2", Text, default = None)
    shipAddress3 = Column("ship_address3", Text, default = None)
    shipCity = Column("ship_city", Text, default = None)
    shipState = Column("ship_state", Text, default = None)
    shipZip = Column("ship_zip", Text, default = None)
    shipCountry = Column("ship_country", Text, default = None)
    shipTel = Column("ship_tel", Text, default = None)
    shipFax = Column("ship_fax", Text, default = None)
    shipEmail = Column("ship_email", Text, default = None)
    shipRemark = Column("ship_remark", Text, default = None)

    billCompany = Column("bill_company", Text, default = None)
    billAttn = Column("bill_attn", Text, default = None)
    billAddress = Column("bill_address", Text, default = None)
    billAddress2 = Column("bill_address2", Text, default = None)
    billAddress3 = Column("bill_ddress3", Text, default = None)
    billCity = Column("bill_city", Text, default = None)
    billState = Column("bill_state", Text, default = None)
    billZip = Column("bill_zip", Text, default = None)
    billCountry = Column("bill_country", Text, default = None)
    billTel = Column("bill_tel", Text, default = None)
    billFax = Column("bill_fax", Text, default = None)
    billEmail = Column("bill_email", Text, default = None)
    billRemark = Column("bill_remark", Text, default = None)
