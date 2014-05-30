# -*- coding: utf-8 -*-

# turbogears imports
from tg import expose, redirect, validate, flash, session, request
from tg.decorators import *

# third party imports
from repoze.what.predicates import not_anonymous, in_group, has_permission
from sqlalchemy.sql.expression import and_

# project specific imports
from rpac.lib.base import BaseController
from rpac.model import *


from rpac.util.common import *
from rpac.widgets.access import *


class AccessController( BaseController ):
    # Uncomment this line if your controller requires an authenticated user
#    allow_only = authorize.in_group( 'Admin' )


    @expose( 'rpac.templates.access.index' )
    @tabFocus( tab_type = "access" )
    def index( self ):
        return dict( page = 'index' )

    @expose( 'rpac.templates.access.user' )
    @paginate( "result", items_per_page = 20 )
    @tabFocus( tab_type = "access" )
    def user( self, **kw ):
        conditions = []
        if kw.get( 'user_name', None ) or None : conditions.append( User.user_name.op( "ilike" )( "%%%s%%" % kw["user_name"] ) )
        if kw.get( 'display_name', None ) or None : conditions.append( User.display_name.op( "ilike" )( "%%%s%%" % kw["display_name"] ) )

        if not conditions:
            result = DBSession.query( User ).order_by( User.user_name ).all()
        else:
            result = DBSession.query( User ).filter( and_( *conditions ) ).order_by( User.user_name ).all()
        return {"widget" : user_search_form, "result" : result, "values" : kw}



    @expose( 'rpac.templates.access.group' )
    @paginate( "result", items_per_page = 20 )
    @tabFocus( tab_type = "access" )
    def group( self, **kw ):
        conditions = []
        if kw.get( 'group_name', None ) or None : conditions.append( Group.group_name.op( "ilike" )( "%%%s%%" % kw["group_name"] ) )
        if kw.get( 'display_name', None ) or None : conditions.append( Group.display_name.op( "ilike" )( "%%%s%%" % kw["display_name"] ) )

        if not conditions:
            result = DBSession.query( Group ).order_by( Group.group_name ).all()
        else:
            result = DBSession.query( Group ).filter( and_( *conditions ) ).order_by( Group.group_name ).all()
        return {"widget" : group_search_form, "result" : result, "values" : kw}


    '''
    @expose( 'rpac.templates.access.permission' )
    @paginate( "result", items_per_page = 20 )
    @tabFocus( tab_type = "access" )
    def permission( self, **kw ):
        if not kw:
            result = []
        else:
            result = DBSession.query( Permission ).filter( Permission.__table__.c.permission_name.op( "ilike" )( "%%%s%%" % kw["permission_name"] ) ).order_by( Permission.permission_name ).all()
        return {"widget" : permission_search_form, "result" : result, "values" : kw}

    '''


    @expose( 'rpac.templates.access.add' )
    @tabFocus( tab_type = "access" )
    def add( self, **kw ):
        values = {}
        if not kw.get( "type", None ) :
            flash( "No such operation!" )
            redirect( "/access/index" )

        values['type'] = kw['type']

        if kw['type'] == 'user':
            values["groups"] = qry( Group ).order_by( Group.display_name )

        if kw['type'] == 'group':
            values['per_not'] = qry( Permission ).order_by( Permission.permission_name )
            values['per_yes'] = []

        return values




    @expose()
    def save_new( self, **kw ):
        if kw["type"] == "user" :
            password = kw["password"] if kw["password"] else "11111111"

            user_name = kw.get( 'user_name', None ) or None
            if not user_name :
                flash( "Please input the user name!" )
                return redirect( '/access/add?type=user' )

            try:
                tmp = qry( User ).filter( User.user_name.op( "ilike" )( user_name ) ).one()
            except:
                u = User( user_name = user_name, display_name = kw.get( "display_name", None ) or None,
                          email_address = kw.get( "email_address", None ), password = password )
                DBSession.add( u )
                if kw.get( 'groups', None ):
                    groups = kw['groups']
                    if type( groups ) != list : groups = [groups]
                    u.groups = qry( Group ).filter( Group.group_id.in_( groups ) ).all()
                flash( "Save the user successfully!" )
                redirect( "/access/user" )
            else:
                flash( "The user name already exist!" )
                return redirect( '/access/add?type=user' )


        elif kw["type"] == "group" :
            group_name = kw.get( "group_name", None ) or None
            if not group_name:
                flash( "Please input the group name!" )
                return redirect( "/access/add?type=group" )
            try:
                tmp = qry( Group ).filter( Group.group_name.op( "ilike" )( group_name ) ).one()
            except:
                g = Group( group_name = group_name, display_name = kw.get( "display_name", None ) or None )
                DBSession.add( g )
                pers_yes = kw.get( 'pers_yes', '' ) or ''
                if pers_yes : g.permissions = qry( Permission ).filter( Permission.permission_id.in_( pers_yes.split( '|' ) ) ).all()
                flash( "Save the group successfully!" )
                redirect( "/access/group" )
            else:
                flash( "The group name already exist!" )
                return redirect( "/access/add?type=group" )


        elif kw["type"] == "permission" :
            p = Permission( permission_name = kw["permission_name"], description = kw["description"] )
            ag = DBSession.query( Group ).filter_by( group_name = "Admin" ).one()
            ag.permissions.append( p )
            DBSession.add( p )
            DBSession.flush()
            redirect( "/access/permission_manage?id=%d" % p.permission_id )
        else:
            flash( "No such type operation!" )
            redirect( "/access/index" )


    @expose( "rpac.templates.access.edit" )
    @tabFocus( tab_type = "access" )
    def edit( self, **kw ):
        values = {}
        if not kw.get( "type", None ) :
            flash( "No such operation!" )
            redirect( "/access/index" )

        values['type'] = kw['type']
        if values['type'] == 'user':
            obj = getOr404( User, kw["id"] )
            options = qry( Group ).order_by( Group.display_name )
            values.update( {
                           'user_id' : obj.user_id,
                           'user_name' : obj.user_name or '',
                           'display_name' : obj.display_name or '',
                           'email_address' : obj.email_address or '',
                           'groups' : [g.group_id for g in obj.groups],
                           'options' : options,
                           } )
        elif values['type'] == 'group':
            obj = getOr404( Group, kw["id"] )
            values.update( {
                           'group_id' : obj.group_id,
                           'group_name' : obj.group_name or '',
                           'display_name' : obj.display_name or '',
                           'pers_yes' : obj.permissions,
                           'pers_no' : qry( Permission ).filter( ~Permission.groups.any( Group.group_id == obj.group_id ) ).order_by( Permission.order ),
                           } )

        return {'values' : values}



    @expose()
    def save_edit( self, **kw ):
        if kw["type"] == "user" :
            u = getOr404( User, kw["id"] )

            username = kw.get( "user_name", None ) or None
            if not username :
                flash( "The user name could not be blank!" )
                return redirect( '/access/edit?id=%s&type=user' % u.user_id )

            if u.user_name.upper() != username.upper():
                try:
                    tmp = qry( User ).filter( User.user_name.op( "ilike" )( username ) ).one()
                except:
                    pass
                else:
                    flash( "The user name already exist!" )
                    return redirect( '/access/edit?id=%s&type=user' % u.user_id )

            u.user_name = username
            if kw.get( "password", None ) or None: u.password = kw["password"]
            u.display_name = kw.get( "display_name", None ) or None
            u.email_address = kw.get( "email_address", None )

            groups = kw.get( "groups", [] )
            if type( groups ) != list : groups = [groups]
            u.groups = DBSession.query( Group ).filter( Group.group_id.in_( groups ) ).all()

            flash( "Save the update successfully!" )
            redirect( "/access/user" )


        elif kw["type"] == "group" :
            g = getOr404( Group, kw["id"] )

            group_name = kw.get( "group_name", None ) or None
            if not group_name:
                flash( "The role name could not be blank!" )
                return redirect( '/access/edit?id=%s&type=group' % g.group_id )

            if g.group_name.upper() != group_name.upper():
                try:
                    tmp = qry( Group ).filter( Group.group_name.op( "ilike" )( group_name ) ).one()
                except:
                    pass
                else:
                    flash( "The group name already exist!" )
                    return redirect( '/access/edit?id=%s&type=group' % u.group_id )

            g.group_name = group_name
            g.display_name = kw.get( "display_name", None ) or None
            pers_yes = kw.get( "pers_yes", '' ) or ''

            if not pers_yes : g.permissions = []
            else : g.permissions = DBSession.query( Permission ).filter( Permission.permission_id.in_( pers_yes.split( "|" ) ) ).all()
            flash( "Save the update successfully!" )
            redirect( "/access/group" )



        elif kw["type"] == "permission" :
            p = Permission( permission_name = kw["permission_name"], description = kw["description"] )
            ag = DBSession.query( Group ).filter_by( group_name = "Admin" ).one()
            ag.permissions.append( p )
            DBSession.add( p )
            DBSession.flush()
            redirect( "/access/permission_manage?id=%d" % p.permission_id )
        else:
            flash( "No such type operation!" )
            redirect( "/access/index" )


    '''
    @expose( "rpac.templates.access.user_manage" )
    @tabFocus( tab_type = "access" )
    def user_manage( self, **kw ):
        u = getOr404( User, kw["id"] )
        included = u.groups
        excluded = DBSession.query( Group ).filter( ~Group.users.any( User.user_id == u.user_id ) ).order_by( Group.group_name )
        return {
                "widget" : user_update_form,
                "values" : {"id" : u.user_id, "user_name" : u.user_name, "email_address" : u.email_address, "display_name" : u.display_name},
                "included" : included,
                "excluded" : excluded,
                }

    @expose()
    def save_user( self, **kw ):
        u = getOr404( User, kw["id"] )
        if kw.get( "user_name", None ) : u.user_name = kw["user_name"]
        if kw.get( "password", None ) : u.password = kw["password"]
        if kw.get( "display_name", None ) : u.display_name = kw["display_name"]
        if kw.get( "email_address", None ) : u.email_address = kw["email_address"]

        if not kw["igs"] : u.groups = []
        else : u.groups = DBSession.query( Group ).filter( Group.group_id.in_( kw["igs"].split( "|" ) ) ).all()
        flash( "Save the update successfully!" )
        redirect( "/access/user" )



    @expose( "rpac.templates.access.permission_manage" )
    @tabFocus( tab_type = "access" )
    def permission_manage( self, **kw ):
        p = getOr404( Permission, kw["id"] )

        included = p.groups
        excluded = DBSession.query( Group ).filter( ~Group.permissions.any( Permission.permission_id == p.permission_id ) ).order_by( Group.group_name )

        return {"widget" : permission_update_form,
                "values" : {"id" : p.permission_id, "permission_name" : p.permission_name},
                "included" : included,
                "excluded" : excluded
                }

    @expose()
    def save_permission( self, **kw ):
        p = getOr404( Permission, kw["id"] )
        p.permission_name = kw["permission_name"]
        if not kw["igs"] : p.groups = []
        else : p.groups = DBSession.query( Group ).filter( Group.group_id.in_( kw["igs"].split( "|" ) ) ).all()
        flash( "Save the update successfully!" )
        redirect( "/access/permission" )



    @expose( 'rpac.templates.access.group_manage' )
    @tabFocus( tab_type = "access" )
    def group_manage( self, **kw ):
        g = getOr404( Group, kw["id"] )
        included = g.users
        excluded = DBSession.query( User ).filter( ~User.groups.any( Group.group_id == g.group_id ) ).order_by( User.user_name )

        got = g.permissions

        # myLog(got)

        lost = DBSession.query( Permission ).filter( ~Permission.groups.any( Group.group_id == g.group_id ) ).order_by( Permission.permission_name )
        return {"widget" : group_update_form , "values" : { "id" : g.group_id, "group_name" : g.group_name },
                "included" : included , "excluded" : excluded,
                "got" : got, "lost" : lost }


    @expose()
    def save_group( self, **kw ):
        g = getOr404( Group, kw["id"] )

        g.group_name = kw["group_name"]

        uigs = kw["uigs"]
        pigs = kw["pigs"]

        if not uigs : g.users = []
        else : g.users = DBSession.query( User ).filter( User.user_id.in_( uigs.split( "|" ) ) ).all()

        if not pigs : g.permissions = []
        else : g.permissions = DBSession.query( Permission ).filter( Permission.permission_id.in_( pigs.split( "|" ) ) ).all()

        flash( "Save the update successfully!" )
        redirect( "/access/group" )
    '''

