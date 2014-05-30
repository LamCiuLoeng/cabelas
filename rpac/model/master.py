# -*- coding: utf-8 -*-
'''
Created on 2014-3-11
@author: CL.Lam
'''
import json
from sqlalchemy import Table
from sqlalchemy.orm import backref, relation
from sqlalchemy.schema import Column, ForeignKey
from sqlalchemy.types import Text, Integer, Numeric
from sqlalchemy.sql.expression import and_, desc
from rpac.model import DeclarativeBase, qry, metadata
from interface import SysMixin


__all__ = ['ProductMixin', 'Product', 'PriceList', 'Option']

product_option_table = Table('master_product_option', metadata,
    Column('product_id', Integer, ForeignKey('master_product.id',
        onupdate = "CASCADE", ondelete = "CASCADE"), primary_key = True),
    Column('option_id', Integer, ForeignKey('master_option.id',
        onupdate = "CASCADE", ondelete = "CASCADE"), primary_key = True)
 )


class ProductMixin(object):

    productParentId = Column("product_parent_id", Integer)  # link to the combo item
    itemCode = Column("item_code", Text, nullable = False)
    desc = Column(Text)
    size = Column(Text)


class Product(DeclarativeBase , SysMixin , ProductMixin):
    __tablename__ = 'master_product'

    id = Column(Integer, primary_key = True)
    combo = Column(Text, default = None)  # Y is combo ,NONE is single
    moq = Column(Integer, default = None)
    roundup = Column(Integer, default = None)
    image = Column(Text)
    options = relation('Option', secondary = product_option_table)


    def __str__(self): return self.itemCode
    def __unicode__(self): return self.itemCode

    def getPriceObj(self, qty):
        if not qty : return None
        return  qry(PriceList).filter(and_(
                                         PriceList.active == 0,
                                         PriceList.productId == self.id,
                                         qty >= PriceList.qty)).order_by(desc(PriceList.qty)).first()


    def _getDirectChildren(self):
        clz = self.__class__
        return qry(clz).filter(and_(clz.active == 0 , clz.productParentId == self.id)).order_by(clz.itemCode).all()


    def getOptions(self):
        options = set(self.options)
        if self.combo != 'Y' : return list(options)
        for c in self._getDirectChildren():
            options.update(c.getOptions())
        return list(options)

    def getChildrenLeaf(self):
        if self.combo != 'Y' : return [self]  # is single item, return []
        leaf = []
        for c in self._getDirectChildren():
            leaf.extend(c.getChildrenLeaf())
        return leaf



class PriceList(DeclarativeBase , SysMixin):
    __tablename__ = 'master_price_list'

    id = Column(Integer, primary_key = True)

    productId = Column("product_id", Integer, ForeignKey('master_product.id'))
    product = relation(Product, backref = backref("prices", order_by = id), primaryjoin = "and_(Product.id == PriceList.productId,PriceList.active == 0)")

    qty = Column(Integer, nullable = False)
    uom = Column('uom', Text, default = "EA")  # EA  is every piece ,JA is every job
    price = Column('price', Numeric(15, 6), default = None)
    leadTime = Column("lead_time", Text)







class Option(DeclarativeBase , SysMixin):
    __tablename__ = 'master_option'

    id = Column(Integer, primary_key = True)

    name = Column(Text)
    type = Column(Text)
    multiple = Column(Text)  # Y is multiple
    css = Column(Text)  # json value for css
    master = Column(Text, default = None)
    masterValues = Column("master_values", Text, default = None)
    order = Column(Integer)


    def __str__(self): return self.name
    def __unicode__(self): return self.name

    def _getMaster(self):
        if self.master :
            pass
        elif self.masterValues:
            return json.loads(self.masterValues)
        return []
