# -*- coding: utf-8 -*-
import json
import traceback
from datetime import datetime as dt
from sqlalchemy import Column
from sqlalchemy.types import Integer, DateTime, Text
from sqlalchemy.sql.expression import and_, desc
from sqlalchemy.ext.declarative import declared_attr
from sqlalchemy.orm import synonym
from sqlalchemy.schema import Sequence
from tg import request

from rpac.model import qry, DBSession


__all__ = ['SysMixin', 'nextVal' ]

def getUserID():
    user_id = 1
    try:
        user_id = request.identity["user"].user_id
    finally:
        return user_id



def nextVal( seq ):
    try:
        s = Sequence( seq )
        s.create( DBSession.bind, checkfirst = True )    # if the seq is existed ,don't create again
        return DBSession.execute( s )
    except:
        traceback.print_exc()
        raise SystemError( 'Can not get the next value for sequence "%s"' % seq )





class SysMixin( object ):

    remark = Column( 'remark', Text, doc = u'Remark' )
    createTime = Column( 'create_time', DateTime, default = dt.now )
    updateTime = Column( 'update_time', DateTime, default = dt.now )
    createById = Column( 'create_by_id', Integer, default = getUserID )
    updateById = Column( 'update_by_id', Integer, default = getUserID )

    sysCreateTime = Column( 'system_create_time', DateTime, default = dt.now )
    sysUpdateTime = Column( 'system_update_time', DateTime, default = dt.now, onupdate = dt.now )

    active = Column( 'active', Integer, default = 0 )    # 0 is active ,1 is inactive


    @property
    def createBy( self ):
        from auth import User
        return qry( User ).get( self.createById )

    @property
    def updateBy( self ):
        from auth import User
        return qry( User ).get( self.updateById )

    @property
    def approveBy( self ):
        from auth import User
        return qry( User ).get( self.approveById )


    def _getAttachment( self ):
        from logic import FileObject
        ids = filter( bool, self._attachment.split( "|" ) )
        if not ids : return []
        return qry( FileObject ).filter( and_( FileObject.active == 0, FileObject.id.in_( ids ) ) ).order_by( FileObject.id )


    def _setAttachment( self, v ):
        ids = None
        if v :
            if type( v ) == list:
                ids = "|".join( map( unicode, v ) )
            elif isinstance( v, basestring ):
                ids = v
        self._attachment = ids


    @declared_attr
    def attachment( self ): return synonym( '_attachment', descriptor = property( self._getAttachment, self._setAttachment ) )
