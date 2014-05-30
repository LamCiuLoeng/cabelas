# -*- coding: utf-8 -*-
'''
Created on 2014-2-10
@author: CL.lam
'''
import logging
import os
import random
import traceback
import zipfile, zlib
from datetime import datetime as dt
from repoze.what import authorize
from tg import expose, flash, redirect, config, request
from tg.decorators import paginate
from sqlalchemy.sql.expression import and_, desc, or_, func
import transaction


from rpac.lib.base import BaseController
from rpac.util.common import tabFocus, serveFile, sendEmail, \
    ReportGenerationException, logError
from rpac.widgets.logic import search_form, approve_search_form
from rpac.model import STATUS_APPROVE, STATUS_NEW, STATUS_UNDER_DEV, \
    STATUS_CANCEL, STATUS_DISCONTINUE, Group, Item, qry, DBSession, FileObject, FileVersion
from repoze.what.predicates import has_permission
from rpac.model.logic import FILE_CHECK_IN, FILE_CHECK_OUT
from rpac.util.excel_helper import getExcelVersion, CABItemReport
import shutil



log = logging.getLogger( __name__ )
EMAIL_SENDFROM = 'r-pac-cabelas-system@r-pac.com.hk'
EMAIL_SUFFIX = [
                "*" * 80,
                "This e-mail is sent by the r-pac Cabela's system automatically.",
                "Please don't reply this e-mail directly!",
                "*" * 80,
                ]


class LogicController( BaseController ):
    allow_only = authorize.not_anonymous()

    @expose( 'rpac.templates.logic.index' )
    @paginate( "result", items_per_page = 20 )
    @tabFocus( tab_type = "item" )
    def index( self , **kw ):
        ws = [Item.active == 0]
        if kw.get( "jobNo", False ) : ws.append( Item.jobNo.op( "ilike" )( "%%%s%%" % kw["jobNo"] ) )
        if kw.get( "systemNo", False ) : ws.append( Item.systemNo.op( "ilike" )( "%%%s%%" % kw["systemNo"] ) )
        if kw.get( "desc", False ) : ws.append( Item.desc.op( "ilike" )( "%%%s%%" % kw["desc"] ) )
        if kw.get( "create_time_from", False ) : ws.append( Item.createTime >= kw["create_time_from"] )
        if kw.get( "create_time_to", False ) : ws.append( Item.createTime <= kw["create_time_from"] )
        if kw.get( "status", False ) : ws.append( Item.status == kw["status"] )
        result = qry( Item ).filter( and_( *ws ) ).order_by( desc( Item.createTime ) ).all()
        return { "result" : result , "values" : kw, "widget" : search_form, "summary" : self._getSummary()}



    @expose( 'rpac.templates.logic.detail' )
    @tabFocus( tab_type = "item" )
    def detail( self, **kw ):
        _id = kw.get( "id", None )
        if not _id :
            flash( "No ID provide!", "warn" )
            return redirect( "/logic/index" )

        obj = qry( Item ).get( _id )
        if not has_permission( "ITEM_DEV_SEE_ALL_FILE" ):
            files = []
            if obj.files :
                _ids = filter( bool, obj.files.split( "|" ) )
                if _ids :
                    ws = [
                          FileObject.active == 0,
                          FileObject.id.in_( _ids ),
                          or_( FileObject.share == 'Y', FileObject.createById == request.identity["user"].user_id )
                          ]
                    files = qry( FileObject ).filter( and_( *ws ) ).order_by( desc( FileObject.updateTime ) )
        else:
            files = obj.getFiles()
        return {
                'obj' : obj,
                'files' : files,
                }


    @expose( 'rpac.templates.logic.approve_detail' )
    @tabFocus( tab_type = "production" )
    def approve_detail( self, **kw ):
        _id = kw.get( "id", None )
        if not _id :
            flash( "No ID provide!", "warn" )
            return redirect( "/logic/index" )

        obj = qry( Item ).get( _id )
        if not obj:
            flash( "No such record!", "warn" )
            return redirect( "/logic/production" )

        if obj.status != STATUS_APPROVE:
            flash( "No such operation!", "warn" )
            return redirect( "/logic/production" )
        return {
                'obj' : obj,
                'files' : obj.getApproveFiles()
                }


    @expose()
    def save( self, **kw ):
        params = {
                  "jobNo" : kw.get( 'f_jobNo', None ) or None,
                  "desc" : kw.get( 'f_desc', None ) or None,
                  }

        if self._is_duplidate( params['jobNo'] ) :
            flash( "Duplicated job number found!", "warn" )
            return redirect( "/logic/index" )

        try:
            fobjs = []
            for k in sorted( kw.keys() ):
                if not k.startswith( "file_" ) : continue
                _, _id = k.split( "_" )
                fobjs.append( ( kw[k], kw.get( "desc_%s" % _id, None ) or None , kw.get( "share_%s" % _id, None ) or None ) )

            files = self._save_files( fobjs )
            params['files'] = "|".join( map( unicode, [f.id for f in files] ) ) if files else None
            obj = Item( **params )
            DBSession.add( obj )
            DBSession.flush()
            for f in files: f.referto = obj.id
            # send email
            subject = "[Cabela's] New Job number[%s] is added by Bed Bath & Beyond" % obj.jobNo
            to = self._get_email_users( 'AE' )
            content = [
                       "Dear User:",
                       "New job number is added by Cabela's,please check the below URL to check the job's detail.",
                       "%s/logic/detail?id=%s" % ( config.get( 'website_url', '' ), obj.id ),
                       "", "Thanks",
                       ]
            self._sendEmail( subject, to, content )
        except:
            traceback.print_exc()
            flash( "Error when saving the record!", "warn" )
            transaction.doom()
        else:
            flash( "Saving the record successfully!", "ok" )
        return redirect( '/logic/index' )



    @expose()
    def add_new_file( self, **kw ):
        _id = kw.get( "id", None )
        if not _id :
            flash( "No ID provide!", "warn" )
            return redirect( "/logic/index" )

        obj = qry( Item ).get( _id )
        if not obj :
            flash( "The record does not exist!", "warn" )
            return redirect( "/logic/index" )

        if obj.status not in [STATUS_NEW, STATUS_UNDER_DEV]:
            flash( "No such operation!", "warn" )
            return redirect( "/logic/detail?id=%s" % obj.id )

        try:
            fobjs = []
            for k, v in kw.items():
                if not k.startswith( "newfile_" ) or not hasattr( v, "filename" ) : continue
                t, tid = k.split( "_" )
                fobjs.append( ( v, kw.get( "desc_%s" % tid, None ) or None , kw.get( "share_%s" % tid, None ) or None ) )

            files = self._save_files( fobjs )
            obj.files = "|".join( map( unicode, filter( bool, [f.id for f in files] + [obj.files] ) ) )
            for f in files : f.referto = obj.id

            flags = kw.get( "flags", None ) or None
            if flags:
                if type( flags ) != list : flags = [flags, ]
                subject = "[Cabela's] New File(s) are added to job[%s]" % obj.jobNo
                to = self._get_email_users( *flags )
                content = [
                           "Dear User:",
                           "New file(s) are added to job[%s] ,please check the below URL to check the job's detail." % obj.jobNo,
                           "%s/logic/detail?id=%s" % ( config.get( 'website_url', '' ), obj.id ),
                           "", "Thanks",
                           ]
                self._sendEmail( subject, to, content )
        except:
            traceback.print_exc()
            transaction.doom()
            flash( "Error when saving the file(s)!", "warn" )
        else:
            flash( "Save the file(s) successfully!", "ok" )
        return redirect( "/logic/detail?id=%s" % obj.id )


    @expose()
    def change_status( self, **kw ):
        _id, status = kw.get( "id", None ), kw.get( "status", None )
        if not _id :
            flash( "No ID provide!", "warn" )
            return redirect( "/logic/index" )

        if status not in map( unicode, [STATUS_NEW, STATUS_UNDER_DEV, STATUS_APPROVE, STATUS_CANCEL, STATUS_DISCONTINUE] ):
            flash( "No such operation!", "warn" )
            return redirect( "/logic/index" )

        obj = qry( Item ).get( _id )
        if not obj :
            flash( "The record does not exist!", "warn" )
            return redirect( "/logic/index" )

        url = '/logic/detail?id=%s' % _id

        if status == unicode( STATUS_UNDER_DEV ):
            #===================================================================
            # Start the JOB from new to under develop
            #===================================================================
            if obj.status == STATUS_NEW:
                # send email
                obj.estimatedReadyDate, obj.estimatedPrice = kw.get( 'estimatedReadyDate', None ) or None , kw.get( 'estimatedPrice', None ) or None
                subject = "[Cabela's] Job[%s] is started" % obj.jobNo
                to = self._get_email_users( 'AE', 'CABELAS' )
                content = [
                           "Dear User:",
                           "The job[%s] is started ,please check the below URL to check the job's detail." % obj.jobNo,
                           "%s/logic/detail?id=%s" % ( config.get( 'website_url', '' ), obj.id ),
                           "", "Thanks",
                           ]
                self._sendEmail( subject, to, content )
                flash( "Update the record successfully!", "ok" )
            #===================================================================
            # Revise the JOB from approve to under develop
            #===================================================================
            elif obj.status == STATUS_APPROVE:
                obj.approveFileIDs, obj.approveFilesZipID = None, None
                obj.approveTime, obj.approveById = None, None
                flash( "Update the record successfully!", "ok" )

        elif status == unicode( STATUS_APPROVE ):
            _ids = filter( bool, kw.get( "ids", "" ).split( "|" ) )
            if not _ids :
                flash( "No approved file(s) provided!", "warn" )
                return redirect( '/logic/detail?id=%s' % _id )

            files = qry( FileObject ).filter( FileObject.id.in_( _ids ) ).order_by( desc( FileObject.createTime ) )
            if len( [f for f in files if f.status == FILE_CHECK_OUT] ) > 0 :
                flash( "Some file(s) are in check out status, can't approve for production!", "warn" )
                return redirect( '/logic/detail?id=%s' % _id )

            try:
                zipfileName, zipfilePath = self._zip_files( obj.systemNo, files )
                fobj = FileObject( fileName = zipfileName, filePath = zipfilePath )
                DBSession.add( fobj )
                DBSession.flush()
                obj.approveFilesZipID = fobj.id
                obj.approveFileIDs = "|".join( _ids )
                obj.approveTime = dt.now()
                obj.approveById = request.identity["user"].user_id

                # send email
                subject = "[Cabela's] Job[%s] is approved for production" % obj.jobNo
                to = self._get_email_users( 'PRODUCTION' )
                content = [
                           "Dear User:",
                           "The job[%s] is approved for production ,please check the below URL to check the job's detail." % obj.jobNo,
                           "%s/logic/detail?id=%s" % ( config.get( 'website_url', '' ), obj.id ),
                           "", "Thanks",
                           ]
                self._sendEmail( subject, to, content )
            except:
                traceback.print_exc()
                transaction.doom()
                flash( "Error when updating the record's status!", "warn" )
            else:
                flash( "Update the record successfully!", "ok" )

        elif status == unicode( STATUS_DISCONTINUE ):
            url = '/logic/production'

        obj.status = status
        obj.updateTime, obj.updateById = dt.now(), request.identity["user"].user_id
        return redirect( url )




    @expose( 'rpac.templates.logic.production' )
    @paginate( "result", items_per_page = 20 )
    @tabFocus( tab_type = "production" )
    def production( self, **kw ):
        ws = [Item.active == 0, Item.status == STATUS_APPROVE, ]
        if kw.get( "jobNo", False ) : ws.append( Item.jobNo.op( "ilike" )( "%%%s%%" % kw["jobNo"] ) )
        if kw.get( "systemNo", False ) : ws.append( Item.systemNo.op( "ilike" )( "%%%s%%" % kw["systemNo"] ) )
        if kw.get( "desc", False ) : ws.append( Item.desc.op( "ilike" )( "%%%s%%" % kw["desc"] ) )
        if kw.get( "approve_time_from", False ) : ws.append( Item.approveTime >= kw["approve_time_from"] )
        if kw.get( "approve_time_to", False ) : ws.append( Item.approveTime <= kw["approve_time_to"] )
        result = qry( Item ).filter( and_( *ws ) ).order_by( desc( Item.createTime ) ).all()
        return { "result" : result , "values" : kw, "widget" : approve_search_form , "summary" : self._getSummary()}



    def _handle_upload( self, fobj ):
        file_path = fobj.filename
        ( pre, ext ) = os.path.splitext( file_path )
        path_prefix = os.path.join( config.file_dir, "sys" )
        if not os.path.exists( path_prefix ) : os.makedirs( path_prefix )
        file_name = "%s%.4d%s" % ( dt.now().strftime( "%Y%m%d%H%M%S" ), random.randint( 1, 1000 ), ext )
        full_path = os.path.join( path_prefix, file_name )
        f = open( full_path, "wb" )
        f.write( fobj.file.read() )
        f.close()
        return file_path, os.path.join( "sys", file_name )


    def _save_files( self, fobjs ):
        objs = []
        try:
            for ( fobj, desc, share ) in fobjs:
                if not hasattr( fobj, "filename" ) : continue
                fileName, filePath = self._handle_upload( fobj )
                obj = FileObject( fileName = fileName, filePath = filePath, remark = desc, share = share )
                objs.append( obj )
            DBSession.add_all( objs )
            DBSession.flush()
        except:
            traceback.print_exc()
            raise Exception( "Error when saving the file!" )
        return objs



    @expose( "json" )
    def ajaxCheckDuplidate( self, **kw ):
        no = kw.get( "jobNo", None ) or None
        if not no : return {'flag' : 1 , 'msg' : 'job no could not be blank'}
        if self._is_duplidate( no ):
            return {'flag' : 1 , 'msg' :'The job is duplcated!'}
        return {'flag' : 0 }


    @expose( "json" )
    def ajaxCheckOut( self, **kw ):
        _id, changeto = kw.get( "id", None ) or None , kw.get( "changeto", None ) or None
        if not _id :
            return {'flag' : 1, 'msg' : 'No ID provided!'}
        if changeto not in map( unicode, [FILE_CHECK_IN, FILE_CHECK_OUT] ):
            return {'flag' : 1 , 'msg' : 'No such operation!'}

        obj = qry( FileObject ).get( _id )
        if not obj: return {'flag' : 1, 'msg' : 'The record does not exist!'}

        try:
            obj.status = changeto
            obj.updateById = request.identity["user"].user_id
            obj.updateTime = dt.now()
            if changeto == unicode( FILE_CHECK_OUT ) :
                obj.checkoutById = request.identity["user"].user_id
            else:
                obj.checkoutById = None
            return {'flag' : 0 ,
                    'updateBy' : unicode( request.identity["user"] ),
                    'updateTime' : obj.updateTime.strftime( "%Y/%m/%d %H:%M" ),
                    }
        except:
            return {'flag' : 1 , 'msg' : 'Error occur when updating this record!'}


    @expose( 'json' )
    def ajaxDelFile( self, **kw ):
        _id = kw.get( 'id', None ) or None
        if not _id :
            return {'flag' : 1, 'msg' : 'No ID provided!'}

        obj = qry( FileObject ).get( _id )
        if not obj: return {'flag' : 1, 'msg' : 'The record does not exist!'}

        try:
            obj.active = 1
            obj.updateTime = dt.now()
            obj.updateById = request.identity["user"].user_id
            item = qry( Item ).get( obj.referto )
            fids = ( item.files or '' ).split( "|" )
            item.files = "|".join( [fid for fid in fids if fid != _id] )
            return {'flag' : 0}
        except:
            traceback.print_exc()
            return {'flag' : 1, 'msg' : 'Error occur on the server side!'}


    @expose( 'json' )
    def ajaxShareFile( self, **kw ):
        _id = kw.get( 'id', None ) or None
        if not _id :
            return {'flag' : 1, 'msg' : 'No ID provided!'}
        obj = qry( FileObject ).get( _id )
        if not obj: return {'flag' : 1, 'msg' : 'The record does not exist!'}
        try:
            obj.share = 'Y'
            obj.updateTime = dt.now()
            obj.updateById = request.identity["user"].user_id
            # send email to Cabela's
            item = qry( Item ).get( obj.referto )
            subject = "[Cabela's] A file of job[%s] is shared with you" % item.jobNo
            to = self._get_email_users( 'AE', 'CABELAS' )
            content = [
                       "Dear User:",
                       "A file of job[%s] is shared with you ,please check the below URL to check the job's detail." % item.jobNo,
                       "%s/logic/detail?id=%s" % ( config.get( 'website_url', '' ), item.id ),
                       "", "Thanks",
                       ]
            self._sendEmail( subject, to, content )
            return {'flag' : 0}
        except:
            transaction.doom()
            traceback.print_exc()
            return {'flag' : 1, 'msg' : 'Error occur on the server side!'}


    def _append( self, fn ):
        p = fn.rindex( "." )
        if p > -1 : return "%s_Modified%s" % ( fn[:p], fn[p:] )
        return fn + "_Modified"


    @expose()
    def checkInFle( self, **kw ):
        _id = kw.get( 'fid', None ) or None
        if not _id :
            flash( "No ID provided!", "warn" )
            return redirect( '/logic/index' )

        obj = qry( FileObject ).get( _id )
        if not obj:
            flash( 'The record does not exist!', "warn" )
            return redirect( '/logic/index' )

        try:
            # keep the version
            DBSession.add( FileVersion( file = obj,
                                      fileName = self._append( obj.fileName ),
                                      remark = obj.remark, _file_path = obj._file_path,
                                      createTime = obj.createTime, updateTime = obj.updateTime,
                                      createById = obj.createById, updateById = obj.updateById,
                                      ) )
            obj.share = 'Y' if kw.get( 'updateshare', None ) else None
            obj.remark = kw.get( 'updatedesc', None ) or None
            obj.status = FILE_CHECK_IN
            obj.checkoutById = None
            obj.updateTime = dt.now()
            obj.updateById = request.identity["user"].user_id

            # update file
            fobj = kw.get( 'updatefile', None )
            if hasattr( fobj, "filename" ) : obj.fileName, obj.filePath = self._handle_upload( fobj )

            # send email
            item = qry( Item ).get( obj.referto )
            flags = kw.get( "flags", None ) or None
            if flags:
                if type( flags ) != list : flags = [flags, ]
                subject = "[Cabela's] File is modified to job[%s]" % item.jobNo
                to = self._get_email_users( *flags )
                content = [
                           "Dear User:",
                           "File is modified to job[%s] ,please check the below URL to check the job's detail." % item.jobNo,
                           "%s/logic/detail?id=%s" % ( config.get( 'website_url', '' ), item.id ),
                           "", "Thanks",
                           ]
                self._sendEmail( subject, to, content )
            flash( "Update the file successfully!", "ok" )
        except:
            traceback.print_exc()
            transaction.doom()
            flash( "Error occur when updating the file!", "warn" )
        return redirect( '/logic/detail?id=%s' % obj.referto )



    #===========================================================================
    # True -- the record is duplidate
    # False -- The record doesn't exist
    #===========================================================================
    def _is_duplidate( self, no ):
        if not no : return True
        no = no.strip()
        try:
            t = qry( Item ).filter( and_( Item.active == 0 , Item.jobNo.op( "ilike" )( no ) ) ).one()
        except:
            return False
        else:
            return True


    def _zip_files( self, no, files ):
        dlzipFileName = "%s_%s%d.zip" % ( no, dt.now().strftime( "%Y%m%d%H%M%S" ), random.randint( 1, 1000 ) )
        dbFilePath = os.path.join( "sys", dlzipFileName )
        dlzipFilePath = os.path.join( config.file_dir, dbFilePath )
        dlzip = zipfile.ZipFile( dlzipFilePath, "w", zlib.DEFLATED )
        for f in files:
            dlzip.write( str( f.filePath ), f.fileName )
        dlzip.close()
        return dlzipFileName, dbFilePath


    def _get_email_users( self, *flags ):
        emails = set()
        if not flags : return []
        for g in qry( Group ).filter( or_( *[Group.flag == flag for flag in flags] ) ):
            for u in g.users:
                if u.getEmail():
                    for e in u.getEmail() : emails.add( e )
        return list( emails )



    def _sendEmail( self, subject, to, content ):
        defaultsendto = config.get( "default_email_sendto", "" ).split( ";" )
        sendto = defaultsendto + to
        cc = config.get( "default_email_cc", "" ).split( ";" )
        content.extend( EMAIL_SUFFIX )
        if config.get( "sendout_email", None ) != 'F':
            sendEmail( EMAIL_SENDFROM, sendto, subject, '\n'.join( content ), cc )


    def _getSummary( self ):
        summary = {
                   STATUS_NEW : 0,
                   STATUS_UNDER_DEV : 0,
                   STATUS_APPROVE : 0,
                   STATUS_CANCEL : 0,
                   STATUS_DISCONTINUE : 0,
                   }
        for s, c in qry( Item.status, func.count( Item.status ) ).filter( and_( Item.active == 0 ) ).group_by( Item.status ):
            if s in summary : summary[s] += c
        return summary


    def _getReportFilePath( self, templatePath ):
        current = dt.now()
        dateStr = current.strftime( "%Y%m%d" )
        fileDir = os.path.join( config.get( "public_dir" ), "cabelas", dateStr )
        if not os.path.exists( fileDir ): os.makedirs( fileDir )
        v = getExcelVersion()
        if not v : raise ReportGenerationException()
        if v <= "2003" :  # version below 2003
            tempFileName = os.path.join( fileDir, "%s_%s_%d.xls" % ( request.identity["user"].user_name,
                                                               current.strftime( "%Y%m%d%H%M%S" ), random.randint( 0, 1000 ) ) )
            realFileName = os.path.join( fileDir, "%s_%s.xls" % ( request.identity["user"].user_name, current.strftime( "%Y%m%d%H%M%S" ) ) )
        else:
            tempFileName = os.path.join( fileDir, "%s_%s_%d.xlsx" % ( request.identity["user"].user_name,
                                                               current.strftime( "%Y%m%d%H%M%S" ), random.randint( 0, 1000 ) ) )
            realFileName = os.path.join( fileDir, "%s_%s.xlsx" % ( request.identity["user"].user_name, current.strftime( "%Y%m%d%H%M%S" ) ) )
        shutil.copy( templatePath, tempFileName )
        return tempFileName, realFileName


    @expose()
    def export( self, **kw ):
        ws = [Item.active == 0]
        if kw.get( "jobNo", False ) : ws.append( Item.jobNo.op( "ilike" )( "%%%s%%" % kw["jobNo"] ) )
        if kw.get( "systemNo", False ) : ws.append( Item.systemNo.op( "ilike" )( "%%%s%%" % kw["systemNo"] ) )
        if kw.get( "desc", False ) : ws.append( Item.desc.op( "ilike" )( "%%%s%%" % kw["desc"] ) )
        if kw.get( "create_time_from", False ) : ws.append( Item.createTime >= kw["create_time_from"] )
        if kw.get( "create_time_to", False ) : ws.append( Item.createTime <= kw["create_time_from"] )
        if kw.get( "status", False ) : ws.append( Item.status == kw["status"] )

        data = []
        for h in  qry( Item ).filter( and_( *ws ) ).order_by( desc( Item.createTime ) ):
            data.append( map( unicode, [ h.systemNo, h.jobNo, h.desc, h.createTime.strftime( "%Y/%m/%d %H:%M" ),
                                      h.showStatus(), h.estimatedReadyDate or '',
                                      h.approveTime.strftime( "%Y/%m/%d %H:%M" ) if h.approveTime else '',
                                      h.estimatedPrice or '',
                                     ] ) )

        try:
            v = getExcelVersion()
            if not v : raise ReportGenerationException()
            if v <= "2003" :  # version below 2003
                templatePath = os.path.join( config.get( "public_dir" ), "TEMPLATE", "CAB_ITEM_REPORT_TEMPLATE.xls" )
            else :  # version above 2003
                templatePath = os.path.join( config.get( "public_dir" ), "TEMPLATE", "CAB_ITEM_REPORT_TEMPLATE.xlsx" )

            tempFileName, realFileName = self._getReportFilePath( templatePath )
            sdexcel = CABItemReport( templatePath = tempFileName, destinationPath = realFileName )
            sdexcel.inputData( data )
            sdexcel.outputData()
        except:
            traceback.print_exc()
            logError()
            if sdexcel:sdexcel.clearData()
            raise ReportGenerationException()
        else:
            return serveFile( realFileName )


    @expose()
    def production_export( self, **kw ):
        ws = [Item.active == 0, Item.status == STATUS_APPROVE, ]
        if kw.get( "jobNo", False ) : ws.append( Item.jobNo.op( "ilike" )( "%%%s%%" % kw["jobNo"] ) )
        if kw.get( "systemNo", False ) : ws.append( Item.systemNo.op( "ilike" )( "%%%s%%" % kw["systemNo"] ) )
        if kw.get( "desc", False ) : ws.append( Item.desc.op( "ilike" )( "%%%s%%" % kw["desc"] ) )
        if kw.get( "approve_time_from", False ) : ws.append( Item.approveTime >= kw["approve_time_from"] )
        if kw.get( "approve_time_to", False ) : ws.append( Item.approveTime <= kw["approve_time_to"] )
        result = qry( Item ).filter( and_( *ws ) ).order_by( desc( Item.createTime ) ).all()

        data = []
        for h in  qry( Item ).filter( and_( *ws ) ).order_by( desc( Item.createTime ) ):
            data.append( map( unicode, [ h.systemNo, h.jobNo, h.desc, h.createTime.strftime( "%Y/%m/%d %H:%M" ),
                                      h.showStatus(),
                                      h.approveTime.strftime( "%Y/%m/%d %H:%M" ) if h.approveTime else '',
                                     ] ) )

        try:
            v = getExcelVersion()
            if not v : raise ReportGenerationException()
            if v <= "2003" :  # version below 2003
                templatePath = os.path.join( config.get( "public_dir" ), "TEMPLATE", "CAB_PRODUCTION_REPORT_TEMPLATE.xls" )
            else :  # version above 2003
                templatePath = os.path.join( config.get( "public_dir" ), "TEMPLATE", "CAB_PRODUCTION_REPORT_TEMPLATE.xlsx" )

            tempFileName, realFileName = self._getReportFilePath( templatePath )
            sdexcel = CABItemReport( templatePath = tempFileName, destinationPath = realFileName )
            sdexcel.inputData( data )
            sdexcel.outputData()
        except:
            traceback.print_exc()
            logError()
            if sdexcel:sdexcel.clearData()
            raise ReportGenerationException()
        else:
            return serveFile( realFileName )
