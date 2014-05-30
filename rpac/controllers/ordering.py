# -*- coding: utf-8 -*-
'''
Created on 2014-2-17
@author: CL.lam
'''
import os
import random
import traceback
import transaction
import shutil
import json
from datetime import datetime as dt
from html2text import HTML2Text
from tg import expose, redirect, flash, request, config, session
from repoze.what import authorize
from tg.decorators import paginate
from sqlalchemy.sql.expression import and_, desc, or_
from repoze.what.predicates import has_permission

from rpac.lib.base import BaseController
from rpac.util.common import tabFocus, logError, serveFile, \
    ReportGenerationException, sendEmail
from rpac.widgets.ordering import order_search_form
from rpac.model import qry, DBSession, ORDER_INPROCESS, ORDER_COMPLETE, ORDER_NEW, ORDER_CANCEL, \
                        AddressBook, OrderHeader, Product, OrderDetail, OrderDetailSubItem, Option
from rpac.util.excel_helper import CABReport, getExcelVersion, CABOrder


__all__ = ['OrderingController', ]

DEFAULT_SENDER = 'r-pac-cabelas-order-system@r-pac.com.hk'


class OrderingController(BaseController):
    allow_only = authorize.not_anonymous()

    @expose('rpac.templates.ordering.index')
    @paginate("result", items_per_page = 20)
    @tabFocus(tab_type = "main")
    def index(self , **kw):
        ws = [OrderHeader.active == 0, ]
        if kw.get("no", False) : ws.append(OrderHeader.no.op("ilike")("%%%s%%" % kw["no"]))
        if kw.get("customerpo", False) : ws.append(OrderHeader.customerpo.op("ilike")("%%%s%%" % kw["customerpo"]))
        if kw.get("vendorpo", False) : ws.append(OrderHeader.vendorpo.op("ilike")("%%%s%%" % kw["vendorpo"]))
        if kw.get("status", False) : ws.append(OrderHeader.status == kw["status"])
#        if kw.get( "printShopId", False ) : ws.append( OrderHeader.printShopId == kw["printShopId"] )
        if not has_permission("MAIN_ORDERING_CHECKING_ALL"): ws.append(OrderHeader.createById == request.identity["user"].user_id)

        result = qry(OrderHeader).filter(and_(*ws)).order_by(desc(OrderHeader.createTime)).all()
        return { "result" : result , "values" : kw, "widget" : order_search_form}


    @expose()
    def export(self, **kw):
        ws = [OrderHeader.active == 0]
        if kw.get("no", False) : ws.append(OrderHeader.no.op("ilike")("%%%s%%" % kw["no"]))
        if kw.get("customerpo", False) : ws.append(OrderHeader.customerpo.op("ilike")("%%%s%%" % kw["customerpo"]))
        if kw.get("vendorpo", False) : ws.append(OrderHeader.vendorpo.op("ilike")("%%%s%%" % kw["vendorpo"]))
        if kw.get("status", False) : ws.append(OrderHeader.status == kw["status"])
#        if kw.get( "printShopId", False ) : ws.append( OrderHeader.printShopId == kw["printShopId"] )
        if not has_permission("MAIN_ORDERING_CHECKING_ALL"): ws.append(OrderHeader.createById == request.identity["user"].user_id)

        data = []
        for h in  qry(OrderHeader).filter(and_(*ws)).order_by(desc(OrderHeader.createTime)):
            data.append(map(unicode, [ h.no, h.customerpo, h.vendorpo, h.createTime.strftime("%Y/%m/%d %H:%M"),
                                      h.createBy, h.showStatus(),
                                      h.completeDate.strftime("%Y/%m/%d %H:%M") if h.completeDate else '',
                                      h.shipQty or '',
                                     ]))

        try:
            v = getExcelVersion()
            if not v : raise ReportGenerationException()
            if v <= "2003" :  # version below 2003
                templatePath = os.path.join(config.get("public_dir"), "TEMPLATE", "CAB_REPORT_TEMPLATE.xls")
            else :  # version above 2003
                templatePath = os.path.join(config.get("public_dir"), "TEMPLATE", "CAB_REPORT_TEMPLATE.xlsx")

            tempFileName, realFileName = self._getReportFilePath(templatePath)
            sdexcel = CABReport(templatePath = tempFileName, destinationPath = realFileName)
            sdexcel.inputData(data)
            sdexcel.outputData()
        except:
            traceback.print_exc()
            logError()
            if sdexcel:sdexcel.clearData()
            raise ReportGenerationException()
        else:
            return serveFile(realFileName)



    def _getReportFilePath(self, templatePath):
        current = dt.now()
        dateStr = current.strftime("%Y%m%d")
        fileDir = os.path.join(config.get("public_dir"), "cabelas", dateStr)
        if not os.path.exists(fileDir): os.makedirs(fileDir)
        v = getExcelVersion()
        if not v : raise ReportGenerationException()
        if v <= "2003" :  # version below 2003
            tempFileName = os.path.join(fileDir, "%s_%s_%d.xls" % (request.identity["user"].user_name,
                                                               current.strftime("%Y%m%d%H%M%S"), random.randint(0, 1000)))
            realFileName = os.path.join(fileDir, "%s_%s.xls" % (request.identity["user"].user_name, current.strftime("%Y%m%d%H%M%S")))
        else:
            tempFileName = os.path.join(fileDir, "%s_%s_%d.xlsx" % (request.identity["user"].user_name,
                                                               current.strftime("%Y%m%d%H%M%S"), random.randint(0, 1000)))
            realFileName = os.path.join(fileDir, "%s_%s.xlsx" % (request.identity["user"].user_name, current.strftime("%Y%m%d%H%M%S")))
        shutil.copy(templatePath, tempFileName)
        return tempFileName, realFileName



    @expose('rpac.templates.ordering.detail')
    @paginate("result", items_per_page = 20)
    @tabFocus(tab_type = "main")
    def detail(self, **kw):
        hid = kw.get('id', None)
        if not hid :
            flash("No ID provides!", "warn")
            return redirect('/ordering/index')

        try:
            obj = qry(OrderHeader).filter(and_(OrderHeader.active == 0 , OrderHeader.id == hid)).one()
        except:
            flash("The record does not exist!", "warn")
            return redirect('/ordering/index')


        return {
                'obj' : obj ,

                }


    @expose('rpac.templates.ordering.listItems')
    @paginate("result", items_per_page = 20)
    @tabFocus(tab_type = "main")
    def listItems(self, **kw):
        return {}


    @expose('rpac.templates.ordering.placeorder')
    @tabFocus(tab_type = "main")
    def placeorder(self , **kw):
#        locations = qry( PrintShop ).filter( and_( PrintShop.active == 0 ) ).order_by( PrintShop.name )
        address = qry(AddressBook).filter(and_(AddressBook.active == 0, AddressBook.createById == request.identity['user'].user_id)).order_by(AddressBook.createTime).all()
        values = {}
        if len(address) > 0 :
            for f in ['shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3',
                      'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax', 'shipEmail', 'shipRemark',
                      'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3',
                      'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax', 'billEmail', 'billRemark'] :
                values[f] = unicode(getattr(address[0], f) or '')

        products = []
        for p in session.get('items', []) :
            p['productobj'] = qry(Product).get(p['id'])
            products.append(p)

        return {
#                'locations' : locations ,
                'products' : products, 'address' : address,
                'values' : values,
                'address' : address,
                }


    def _countAmount(self, qty, price, uom):
        if not qty or not price : return 0
        try:
            if uom == 'EA': return int(qty) * float(price)  # count by pieces
            if uom == 'JA' : return float(price)  # count by job
        except:
            traceback.print_exc()
        return 0



    @expose()
    def saveorder(self, **kw):
        try:
            addressFields = [
                              'shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3', 'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax', 'shipEmail', 'shipRemark',
                              'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3', 'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax', 'billEmail', 'billRemark',
                             ]
            fields = [ 'customerpo', 'vendorpo', 'shipInstructions']
            params = {}
            for f in addressFields: params[f] = kw.get(f, None) or None
            if kw.get('addressID', None) == 'OTHER': DBSession.add(AddressBook(**params))
            for f in fields: params[f] = kw.get(f, None) or None

            hdr = OrderHeader(**params)
            DBSession.add(hdr)
            qtys, subqtys, dtlamounts, subamounts = [], [], [], []
            for item in session.get('items' , []):
                pdt = DBSession.merge(item['productobj'])
                #===============================================================
                # save the master detail
                #===============================================================
                params = {
                          'header' : hdr, 'productId' : pdt.id,
                          'productParentId' : pdt.productParentId,
                          'itemCode' : pdt.itemCode, 'desc' : pdt.desc, 'size' : pdt.size, 'combo' : pdt.combo,
                          'qty' : item['qty'] or None,
                          'price' : item['price'],
                          'leadTime' : item['leadTime'],
                          }
                if item.get('values', None) or None : params['optionContent'] = json.dumps(item.get('values', []))
                if item.get('optionstext', None) or None : params['optionText'] = json.dumps(item['optionstext'])
                amount = self._countAmount(item['qty'], item['price'], item['uom'])
                params['amount'] = self._countAmount(item['qty'], item['price'], item['uom'])
                dtl = OrderDetail(**params)
                DBSession.add(dtl)
                qtys.append(item['qty'])
                dtlamounts.append(amount)
                #===============================================================
                # save the sub-item detail
                #===============================================================
                for sp in pdt.getChildrenLeaf():
                    spo = sp.getPriceObj(item['qty'] or None)
                    sparams = {
                               'header' : hdr, 'detail' : dtl , 'productParentId' : sp.productParentId,
                               'productId' : sp.id, 'itemCode' : sp.itemCode, 'desc' : sp.desc, 'size' : sp.size, 'combo' : sp.combo,
                               'qty' :  item['qty'] or None,
                               'price' : None if spo is None else spo.price,
                               'leadTime' : None if spo is None else spo.leadTime,
                               }
                    # get the option value for the sub-item
                    soptionvalue, soptiontext = [], []
                    for op in sp.getOptions():
                        for v in item.get('values', []):
                            if v['key'] == ("option_a_%s" % op.id):
                                soptionvalue.append(v)
                                soptiontext.append("%s : %s" % (op.name, v['text']))
                    sparams['optionContent'] = json.dumps(soptionvalue) if soptionvalue else None
                    sparams['optionText'] = json.dumps(soptiontext) if soptiontext else None
                    samount = self._countAmount(item['qty'], spo.price, spo.uom)
                    sparams['amount'] = samount
                    DBSession.add(OrderDetailSubItem(**sparams))
                    subqtys.append(item['qty'])
                    subamounts.append(samount)
            DBSession.flush()
            #===================================================================
            # count the qty ,amount for dtl, sub-dtls
            #===================================================================
            hdr.totalDtlQty = sum(map(int, filter(unicode.isdigit , qtys)))
            hdr.totalDtlAmount = sum(dtlamounts)
            hdr.totalSubDtlQty = sum(map(int, filter(unicode.isdigit , subqtys)))
            hdr.totalSubDtlAmount = sum(subamounts)
            #===================================================================
            # generate excel
            #===================================================================

            xls = self._genExcel(hdr)
            subject = "[Cabela’s] Order(%s) is placed" % hdr.no
            content = [
                       "Dear User:",
                       "Order(%s) is placed, please check the below link to check the detail." % hdr.no,
                       "%s/ordering/detail?id=%s" % (config.get('website_url', ''), hdr.id),
                       "Thanks.", "",
                       "*" * 80,
                       "This e-mail is sent by the r-pac Cabela’s ordering system automatically.",
                       "Please don't reply this e-mail directly!",
                       "*" * 80,
                       ]
            #=======================================================================
            # send email to user and print shop
            #=======================================================================
            self._toVendor(hdr, subject, content)
#             self._toPrintshop(hdr, subject, content, [xls, ])
        except:
            transaction.doom()
            traceback.print_exc()
            flash('Error occur on the server side!', "warn")
            return redirect('/ordering/placeorder')
        else:
            try:
                del session['items']
                session.save()
            except:
                pass
            flash("Save the order successfully!", "ok")
            return redirect('/ordering/detail?id=%s' % hdr.id)



    def _genExcel(self, hdr):
        v = getExcelVersion()
        if not v : raise ReportGenerationException()
        if v <= "2003" :  # version below 2003
            templatePath = os.path.join(config.get("public_dir"), "TEMPLATE", "CAB_DETAIL_TEMPLATE.xls")
        else :  # version above 2003
            templatePath = os.path.join(config.get("public_dir"), "TEMPLATE", "CAB_DETAIL_TEMPLATE.xlsx")

        current = dt.now()
        dateStr = current.strftime("%Y%m%d")
        fileDir = os.path.join(config.get("public_dir"), "excel", dateStr)
        if not os.path.exists(fileDir): os.makedirs(fileDir)

        if v <= "2003" :  # version below 2003
            tempFileName = os.path.join(fileDir, "%s_%s_%d.xls" % (request.identity["user"].user_name,
                                                               current.strftime("%Y%m%d%H%M%S"), random.randint(0, 1000)))
            realFileName = os.path.join(fileDir, "%s_%s.xls" % (request.identity["user"].user_name, current.strftime("%Y%m%d%H%M%S")))
        else:
            tempFileName = os.path.join(fileDir, "%s_%s_%d.xlsx" % (request.identity["user"].user_name,
                                                               current.strftime("%Y%m%d%H%M%S"), random.randint(0, 1000)))
            realFileName = os.path.join(fileDir, "%s_%s.xlsx" % (hdr.no, current.strftime("%Y%m%d%H%M%S")))

        shutil.copy(templatePath, tempFileName)
        data = { 'createTime' : hdr.createTime.strftime("%Y-%m-%d %H:%M") }
        for f in [ 'no', 'shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3',
                   'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax',
                   'shipEmail', 'shipRemark',
                   'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3',
                   'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax',
                   'billEmail', 'billRemark',
                   'customerpo', 'vendorpo', 'shipInstructions' ]:
            data[f] = unicode(getattr(hdr, f) or '')

        content = []
        for d in hdr.subdtls:
            _desc = HTML2Text().handle(d.desc).strip()  if d.desc else ''
            _size = HTML2Text().handle(d.size).strip()  if d.size else ''
            content.append(map(lambda v : unicode(v or ''), [
                            d.itemCode, _desc, _size, d.leadTime,
                            '\n'.join(json.loads(d.optionText)) if d.optionText else '', d.price, d.qty, '%.2f' % d.amount if d.amount else '',
                                                            ]))
        content.append([''] * 5 + ['Total', hdr.totalSubDtlQty, '%.2f' % hdr.totalSubDtlAmount if hdr.totalSubDtlAmount else '', ])
        data['details'] = content
        try:
            sdexcel = CABOrder(templatePath = tempFileName, destinationPath = realFileName)
            sdexcel.inputData(data)
            sdexcel.outputData()
            return realFileName
        except Exception, e:
            traceback.print_exc()
            raise e



    @expose()
    def getexcel(self, **kw):
        hid = kw.get('id', None)
        if not hid :
            flash("No ID provided!")
            return redirect('/index')

        hdr = DBSession.query(OrderHeader).get(hid)
        xls = self._genExcel(hdr)
        return serveFile(unicode(xls))


    @expose("json")
    def ajaxOrderInfo(self, **kw):
        hid = kw.get('id', None)
        if not hid : return {'flag' : 1 , 'msg' : 'No ID provided!'}
        try:
            data = []
            for d in qry(OrderDetail).filter(and_(OrderDetail.active == 0, OrderDetail.headerId == hid)).order_by(OrderDetail.id):
                data.append({'id' : d.id, 'code' : d.itemCode , 'qty' : d.qty})
            return {'flag' : 0, 'data' : data}
        except:
            traceback.print_exc()
            return {'flag' : 1 , 'msg' : 'Error occur on the server side!'}


    @expose('json')
    def ajaxSearch(self, **kw):
        code = kw.get('term', None) or None
        if not code : return {'flag' : 0 , 'data' : []}
        code = code.strip().replace("_", "").replace("-", "")
        ws = [Product.active == 0, ]
        ws.append(or_(Product.combo != 'Y', Product.productParentId == None))
        ws.append(Product.itemCode.op('ilike')("%%%s%%" % code))
        ps = qry(Product).filter(and_(*ws)).order_by(Product.itemCode)
        return {'flag' : 0 , 'data' : [{"id" : p.id, "value" : unicode(p) , "label" : unicode(p)} for p in ps]}


    @expose('rpac.templates.ordering.manage_address')
    @paginate("result", items_per_page = 20)
    @tabFocus(tab_type = "ship")
    def manageAddress(self, **kw):
        result = DBSession.query(AddressBook).filter(and_(AddressBook.active == 0, AddressBook.createById == request.identity['user'].user_id)).order_by(desc(AddressBook.createTime))
        return {'result' : result}



    @expose('rpac.templates.ordering.edit_address')
    @tabFocus(tab_type = "ship")
    def editAddress(self, **kw):
        _id = kw.get('id', None)
        if not _id :
            flash('No id provided!' , "warn")
            return redirect('/index')

        obj = DBSession.query(AddressBook).get(_id)
        values = {'id' : obj.id}
        for f in ['shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3',
                  'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax', 'shipEmail', 'shipRemark',
                  'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3',
                  'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax', 'billEmail', 'billRemark'] :
            values[f] = unicode(getattr(obj, f) or '')
        return {'values' : values}


    @expose()
    def saveAddress(self, **kw):
        _id = kw.get('id', None)
        if not _id :
            flash('No id provided!', 'warn')
            return redirect('/ordering/manageAddress')

        fields = ['shipCompany', 'shipAttn', 'shipAddress', 'shipAddress2', 'shipAddress3',
                  'shipCity', 'shipState', 'shipZip', 'shipCountry', 'shipTel', 'shipFax', 'shipEmail', 'shipRemark',
                  'billCompany', 'billAttn', 'billAddress', 'billAddress2', 'billAddress3',
                  'billCity', 'billState', 'billZip', 'billCountry', 'billTel', 'billFax', 'billEmail', 'billRemark']

        try:
            obj = DBSession.query(AddressBook).get(_id)
            for f in fields : setattr(obj, f, kw.get(f, None) or None)
            flash('Save the record successfully!', 'ok')
        except:
            traceback.print_exc()
            flash('Error occur on the server side!', 'warn')
        return redirect('/ordering/manageAddress')


    @expose()
    def delAddress(self, **kw):
        oid = kw.get('id', None)
        if not oid :
            flash('No id provided!', 'warn')
            return redirect('/ordering/manageAddress')

        obj = DBSession.query(AddressBook).get(oid)
        if not obj :
            flash('The record does not exist!', 'warn')
            return redirect('/ordering/manageAddress')

        obj.active = 1
        flash('Update the record successfully!', 'ok')
        return redirect('/ordering/manageAddress')



    @expose('json')
    def ajaxAddress(self, **kw):
        aid = kw.get('addressID', None)
        if not aid : return {'code' : 1 , 'msg' : 'No ID provided!'}

        obj = qry(AddressBook).get(aid)
        if not obj : return {'code' : 1 , 'msg' : 'The record does not exist!'}

        result = {'code' : 0}
        for f in ["shipCompany", "shipAttn", "shipAddress", "shipAddress2", "shipAddress3", "shipCity", "shipState",
                  "shipZip", "shipCountry", "shipTel", "shipFax", "shipEmail", "shipRemark",
                  "billCompany", "billAttn", "billAddress", "billAddress2", "billAddress3", "billCity", "billState",
                  "billZip", "billCountry", "billTel", "billFax", "billEmail", "billRemark", ] :
            result[f] = unicode(getattr(obj, f) or '')
        return result


    def _filterAndSorted(self, prefix, kw):
        return sorted(filter(lambda (k, v): k.startswith(prefix), kw.iteritems()), cmp = lambda x, y:cmp(x[0], y[0]))



    def _getProductInfo(self, obj):
        options = []
        product = {'id' : obj.id , 'moq' : obj.moq , 'roundup' : obj.roundup }
        for opt in obj.getOptions() :
            tmp = {
                   'name' : opt.name, 'type' : opt.type,
                   'id' : opt.id,
                   'css' :  json.loads(opt.css) if opt.css else {'SELECT' : [], 'TEXT' : []}
                   }
            if opt.type == 'TEXT':
                pass
            elif opt.type == 'SELECT' :
                if opt.masterValues:
                    tmp['values'] = [{'key' : obj['key'], 'val' : obj['value']} for obj in json.loads(opt.masterValues)]
                elif opt.master:
                    pass
#                 tmp['values'] = [{'key' : obj['key'], 'val' : obj['value']} for obj in self._getMaster(opt)]
#            elif opt.type == 'SELECT+TEXT':
#                tmp['values'] = [{'key' : obj.key, 'val' : obj.value} for obj in self._getMaster( opt )]
            options.append(tmp)
        return product, options


    @expose('json')
    def ajaxGetProduct(self, **kw):
        _id = kw.get('id', None) or None
        if not _id: return {'flag' : 1 , 'msg' : 'No ID provided!'}
        try:
            obj = qry(Product).get(_id)
            return {'flag' : 0 , 'id' : obj.id, 'itemCode' : obj.itemCode, 'desc' : obj.desc ,
                    'size' : obj.size, 'image' : obj.image,
                    }
        except:
            traceback.print_exc()
            return {'flag' : 1, 'msg' : 'Error occur on the sever side !'}


    @expose('json')
    def ajaxProductInfo(self, **kw):
        _id = kw.get('id', None) or None
        if not _id: return {'flag' : 1 , 'msg' : 'No ID provided!'}

        try:
            obj = qry(Product).get(_id)
            product, options = self._getProductInfo(obj)
            return {'flag' : 0 , 'product' : product, 'options' : options}
        except:
            traceback.print_exc()
            return {'flag' : 1, 'msg' : 'Error occur on the sever side !'}


    def _formatKW(self, kw):
        values, optionstext = [], []
        for k, v in self._filterAndSorted("option_", kw):
            val, text = v.split("|")
            values.append({ 'key' : k, 'value' : val, 'text' : text })
            oid = k.split("_")[2]
            option = qry(Option).get(oid)
            optionstext.append("%s : %s" % (option.name, text))
        return values, optionstext


    @expose('json')
    def ajaxAddtoCart(self, **kw):
        _id = kw.get('id', None) or None
        if not _id : return {'flag' : 1 , 'msg' : 'No ID provided!'}

        try:
            items = session.get('items', [])
            p = qry(Product).get(_id)
            po = p.getPriceObj(kw.get('qty', None))
            tmp = {
                   '_k' : "%s%s" % (dt.now().strftime("%Y%m%d%H%M%S"), random.randint(100, 10000)) ,
                   'id' : _id,
                   'qty' : kw.get('qty', None),
                   'price' : unicode(po.price) if po else 0,
                   'leadTime' : po.leadTime if po else '',
                   'uom' : po.uom,
                   }

            tmp['values'], tmp['optionstext'] = self._formatKW(kw)
            items.append(tmp)
            session['items'] = items
            session.save()
            return {'flag' : 0 , 'total' : len(session['items'])}
        except:
            traceback.print_exc()
            return {'flag' : 1, 'msg':'Error occur on the sever side!'}


    @expose('json')
    def ajaxEditItem(self, **kw):
        _k = kw.get('_k', None) or None
        if not _k: return {'flag' : 1 , 'msg' : 'No ID provided!'}
        try:
            for s in session.get('items', []):
                if s['_k'] != _k : continue
                obj = qry(Product).get(s['id'])
                product, options = self._getProductInfo(obj)
                product['qty'] = s.get('qty', '')
                return {'flag' : 0 , 'product' : product, 'options' : options , 'values' : s.get('values', []) }
        except:
            traceback.print_exc()
            return {'flag' : 1, 'msg' : 'Error occur on the sever side !'}
        return {'flag' : 1 , 'msg' : 'No such item!'}


    @expose('json')
    def ajaxRemoveItem(self, **kw):
        _k = kw.get("_k", None)
        if not _k : return {'flag' : 1 , 'msg' : 'No ID provided!'}

        try:
            session['items'] = filter(lambda item : item['_k'] != _k, session.get('items', []))
            session.save()
            return {'flag' : 0 }
        except:
            traceback.print_exc()
            return {'flag' : 1, 'msg':'Error occur on the sever side!'}


    @expose('json')
    def ajaxSavetoCart(self, **kw):
        _k = kw.get("_k", None)
        if not _k : return {'flag' : 1 , 'msg' : 'No ID provided!'}

        try:
            items = session.get('items', [])
            for index, item in enumerate(items):
                if item['_k'] != _k : continue
                qty = kw.get('qty', None) or None
                p = qry(Product).get(item['id'])
                po = p.getPriceObj(qty)

                item['qty'] = qty
                item['values'], item['optionstext'] = self._formatKW(kw)
                item['price'] = unicode(po.price) if po else ''
                item['leadTime'] = po.leadTime if po else ''
                item['uom'] = po.uom
                items[index] = item
                session['items'] = items
                session.save()
                return {'flag' : 0 , 'optionstext' : item['optionstext'], 'price' : item['price'] , 'leadTime' : item['leadTime'] }
        except:
            traceback.print_exc()
            return {'flag' : 1 , 'msg' : 'Error occur on the sever side!'}
        return {'flag' : 1 , 'msg' : 'No such item!'}



    @expose('json')
    def ajaxChangeStatus(self, **kw):
        _id, status = kw.get('id', None) or None , kw.get('status', None) or None
        if not _id or not status:
            return {'flag' : 1 , 'msg' : 'No enough parameter(s) provided!'}

        if status not in map(unicode, [ORDER_INPROCESS, ORDER_COMPLETE, ]):
            return {'flag' : 1 , 'msg' : 'No such operation!'}

        try:
            hdr = qry(OrderHeader).get(_id)

            if status == unicode(ORDER_INPROCESS):
                so = kw.get('so', None) or None
                if not so : return {'flag' : 1 , 'msg' : 'No enough parameter(s) provided!'}
                if hdr.status != ORDER_NEW:
                    return {'flag' : 1 , 'msg' : 'The record is not in NEW status!'}
                hdr.so, hdr.status = so, ORDER_INPROCESS
            elif status == unicode(ORDER_COMPLETE):
                if hdr.status != ORDER_INPROCESS:
                    return {'flag' : 1 , 'msg' : 'The record is not in process status!'}
                hdr.status, hdr.completeDate = ORDER_COMPLETE, dt.now()
                totalqty = 0
                for d in hdr.dtls:
                    key = "ship_%s" % d.id
                    if kw.get(key, None) :
                        d.shipQty = kw[key]
                        try:
                            totalqty += int(d.shipQty)
                        except:
                            pass
                hdr.shipQty = totalqty
#                 self._sendEmailToVendor(hdr)
#                 self._sendEmailToPrintshop(hdr)
        except:
            transaction.doom()
            traceback.print_exc()
            return {'flag' : 1, 'msg' : 'Error occur on the sever side !'}
        return {'flag' : 0}



    def _toVendor(self, hdr , subject, content, files = []):
        defaultsendto = config.get("default_email_sendto", "").split(";")
        if hdr.createBy.email_address:  to = hdr.createBy.email_address.split(";")
        else: to = []
        sendto = defaultsendto + to
        cc = config.get("default_email_cc", "").split(";")
        if config.get("sendout_email", None) != 'F': sendEmail(DEFAULT_SENDER, sendto, subject, '\n'.join(content), cc, files)


    def _toPrintshop(self, hdr, subject, content, files = []):
        pass
        '''
        defaultsendto = config.get( "default_email_sendto", "" ).split( ";" )
        if hdr.printShopId and hdr.printShop.email: to = hdr.printShop.email
        else: to = []
        sendto = defaultsendto + to
        cc = config.get( "default_email_cc", "" ).split( ";" )
        if config.get( "sendout_email", None ) != 'F': sendEmail( DEFAULT_SENDER, sendto, subject, '\n'.join( content ), cc, files )
        '''



    @expose()
    def cancelOrder(self, **kw):
        _id = kw.get("id", None) or None
        if not _id :
            flash("No ID provided!")
            return redirect('/ordering/index')

        hdr = qry(OrderHeader).get(_id)
        hdr.status = ORDER_CANCEL
        subject = "[Cabela’s] Order(%s) is cancelled" % hdr.no
        content = [
                   "Dear User:",
                   "Order(%s) is cancelled." % hdr.no,
                   "Thanks.", "",
                   "*" * 80,
                   "This e-mail is sent by the r-pac Cabela's ordering system automatically.",
                   "Please don't reply this e-mail directly!",
                   "*" * 80,
                   ]
        #=======================================================================
        # send email to user
        #=======================================================================
        self._toVendor(hdr, subject, content)
        #=======================================================================
        # send email to print shop
        #=======================================================================
#         self._toPrintshop(hdr, subject, content)
        flash("Cancel the order successfully!")
        return redirect('/ordering/index')
