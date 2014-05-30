# -*- coding: utf-8 -*-
import os
from datetime import datetime
import sys
try:
    from hashlib import sha1
except ImportError:
    sys.exit( 'ImportError: No module named hashlib\n'
             'If you are on python2.4 this library is not part of python. '
             'Please install it. Example: easy_install hashlib' )

from sqlalchemy import Table, ForeignKey, Column
from sqlalchemy.types import Unicode, Integer, DateTime, Text
from sqlalchemy.orm import relation, synonym
from sqlalchemy.sql import *

from rpac.model import DeclarativeBase, metadata, DBSession

__all__ = ['User', 'Group', 'Permission']


#{ Association tables


# This is the association table for the many-to-many relationship between
# groups and permissions. This is required by repoze.what.
group_permission_table = Table( 'tg_group_permission', metadata,
    Column( 'group_id', Integer, ForeignKey( 'tg_group.group_id',
        onupdate = "CASCADE", ondelete = "CASCADE" ), primary_key = True ),
    Column( 'permission_id', Integer, ForeignKey( 'tg_permission.permission_id',
        onupdate = "CASCADE", ondelete = "CASCADE" ), primary_key = True )
 )

# This is the association table for the many-to-many relationship between
# groups and members - this is, the memberships. It's required by repoze.what.
user_group_table = Table( 'tg_user_group', metadata,
    Column( 'user_id', Integer, ForeignKey( 'tg_user.user_id',
        onupdate = "CASCADE", ondelete = "CASCADE" ), primary_key = True ),
    Column( 'group_id', Integer, ForeignKey( 'tg_group.group_id',
        onupdate = "CASCADE", ondelete = "CASCADE" ), primary_key = True )
 )


#{ The auth* model itself


class Group( DeclarativeBase ):
    __tablename__ = 'tg_group'

    group_id = Column( Integer, autoincrement = True, primary_key = True )
    group_name = Column( Text, unique = True, nullable = False )
    display_name = Column( Text )
    created = Column( DateTime, default = datetime.now )
    flag = Column( Text )
    users = relation( 'User', secondary = user_group_table, backref = 'groups' )

    def __repr__( self ):
        return self.display_name or self.group_name

    def __unicode__( self ):
        return self.display_name or self.group_name

    def __str__( self ):
        return self.display_name or self.group_name


# The 'info' argument we're passing to the email_address and password columns
# contain metadata that Rum (http://python-rum.org/) can use generate an
# admin interface for your models.
class User( DeclarativeBase ):

    __tablename__ = 'tg_user'

    user_id = Column( Integer, autoincrement = True, primary_key = True )
    user_name = Column( Text, unique = True, nullable = False )
    email_address = Column( Text, nullable = True )
    display_name = Column( Text )
    password = Column( 'password', Text )
    created = Column( DateTime, default = datetime.now )

    def __repr__( self ):
        return self.display_name or self.user_name

    def __unicode__( self ):
        return self.display_name or self.user_name

    def __str__( self ):
        return self.display_name or self.user_name

    @property
    def permissions( self ):
        """Return a set of strings for the permissions granted."""
        perms = set()
        for g in self.groups:
            perms = perms | set( g.permissions )
        return perms

    @classmethod
    def by_email_address( cls, email ):
        """Return the user object whose email address is ``email``."""
        return DBSession.query( cls ).filter( cls.email_address == email ).first()

    @classmethod
    def by_user_name( cls, username ):
        """Return the user object whose user name is ``username``."""
        return DBSession.query( cls ).filter( cls.user_name == username ).first()

    def validate_password( self, password ):
        return self.password == password

    @classmethod
    def identify( cls, value ):
        #return DBSession.query(cls).filter(cls.user_name.match(value)).one()
        return DBSession.query( cls ).filter( cls.user_name.op( "ILIKE" )( value ) ).one()

    def getEmail( self ):
        if not self.email_address : return []
        return self.email_address.split( ";" )


class Permission( DeclarativeBase ):
    __tablename__ = 'tg_permission'


    permission_id = Column( Integer, autoincrement = True, primary_key = True )
    permission_name = Column( Text, unique = True, nullable = False )
    display_name = Column( Text )
    groups = relation( Group, secondary = group_permission_table, backref = 'permissions' )
    order = Column( Integer )

    def __repr__( self ):
        return self.display_name or self.permission_name

    def __unicode__( self ):
        return self.display_name or self.permission_name

    def __str__( self ):
        return self.display_name or self.permission_name
