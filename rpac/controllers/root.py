# -*- coding: utf-8 -*-
import logging
from datetime import datetime as dt
import random, traceback, transaction
from tg import expose, flash, require, url, request, redirect
from repoze.what.predicates import not_anonymous, in_group
import json


from rpac.lib.base import BaseController
from rpac.model import DBSession
from rpac.util.common import *
from rpac.controllers import *

logger = logging.getLogger( __name__ )

__all__ = ['RootController']

import thread
myLock = thread.allocate_lock()

class RootController( BaseController ):

    access = AccessController()
    logic = LogicController()
    ordering = OrderingController()

    @require( not_anonymous() )
    @expose( 'rpac.templates.index' )
    @tabFocus( tab_type = "main" )
    def index( self ):
        if has_permission( "MAIN" ): return {}
        if has_permission( "ITEM_DEV" ) : return redirect( '/item' )
        if has_permission( "PRODUCTION" ) : return redirect( '/production' )
        return dict( page = 'index' )


    @require( not_anonymous() )
    @expose( 'rpac.templates.item' )
    @tabFocus( tab_type = "item" )
    def item( self ):
        return dict( page = 'item' )


    @require( not_anonymous() )
    @expose( 'rpac.templates.production' )
    @tabFocus( tab_type = "production" )
    def production( self ):
        return dict( page = 'production' )


    @expose( 'rpac.templates.login' )
    def login( self, came_from = url( '/' ) ):
        """Start the user login."""
        if request.identity: redirect( came_from )

        login_counter = request.environ['repoze.who.logins']
        if login_counter > 0:
            flash( 'Wrong credentials', 'warning' )
        return dict( page = 'login', login_counter = str( login_counter ), came_from = came_from )

    @expose()
    def post_login( self, came_from = url( '/' ) ):
        if not request.identity:
            login_counter = request.environ['repoze.who.logins'] + 1
            redirect( url( '/login', came_from = came_from, __logins = login_counter ) )

        redirect( came_from )

    @expose()
    def post_logout( self, came_from = url( '/' ) ):
        redirect( url( "/" ) )



    @expose()
    def download( self, **kw ):
        try:
            obj = DBSession.query( FileObject ).get( kw["id"] )
            return serveFile( obj.filePath, obj.fileName )
        except:
            traceback.print_exc()
            flash( "No such file!" )
            redirect( "/index" )


    '''
    @expose()
    def upload( self, **kw ):
        try:
            print "*-" * 30
            print type( kw["attachment"] )
            print "*-" * 30

            file_path = kw["attachment"].filename
            ( pre, ext ) = os.path.splitext( file_path )

            path_prefix = os.path.join( config.download_dir, "sys" )
            if not os.path.exists( path_prefix ) : os.makedirs( path_prefix )

            file_name = "%s%.4d%s" % ( dt.now().strftime( "%Y%m%d%H%M%S" ), random.randint( 1, 1000 ), ext )

            print file_name
            print "*-" * 30

            full_path = os.path.join( path_prefix, file_name )

            f = open( full_path, "wb" )
            f.write( kw["attachment"].file.read() )
            f.close()

            db_file_name = kw.get( "attachment_name", None ) or file_name
            if db_file_name.find( "." ) < 0 : db_file_name = db_file_name + ext

            obj = UploadObject( file_name = db_file_name, file_path = os.path.join( "sys", file_name ) )
            DBSession.add( obj )
            DBSession.flush()
            return obj.id
        except:
            traceback.print_exc()
            return None
    '''
