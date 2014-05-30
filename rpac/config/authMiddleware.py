# -*- coding: utf-8 -*-
import ldap
from repoze.what.adapters import SourceError
ldap.set_option(ldap.OPT_REFERRALS, 0)
from tg import config
from repoze.who.plugins.sa import SQLAlchemyAuthenticatorPlugin, SQLAlchemyUserMDPlugin
from sqlalchemy.orm.exc import NoResultFound, MultipleResultsFound
from repoze.what.plugins.sql import SqlGroupsAdapter
from sqlalchemy.orm import eagerload



class MyAuthMixin(object):
    def get_user(self, value):
        try:
            return self.user_class.identify(value)
        except (NoResultFound, MultipleResultsFound):
            return None

SQLAlchemyAuthenticatorPlugin.__bases__ = (MyAuthMixin,) + SQLAlchemyAuthenticatorPlugin.__bases__
SQLAlchemyUserMDPlugin.__bases__ = (MyAuthMixin,) + SQLAlchemyUserMDPlugin.__bases__




class MySQLAlchemyAuthenticatorPlugin(SQLAlchemyAuthenticatorPlugin):

    def authenticate(self, environ, identity):

        def _auth_db():
            print '@@@@@auth_db:%s' % identity['login']
            validator = getattr(user, self.translations['validate_password'])
            if validator(identity['password']):
                return identity['login']

        def _auth_ad():
            print '@@@@@auth_ad:%s' % identity['login']
            password = identity['password']
            del identity['password']
            try:
                rc = ldapcon.simple_bind(dn, password)
                ldapcon.result(rc)
                return identity['login']
            except ldap.INVALID_CREDENTIALS:
                return None
            finally:
                try:
                    ldapcon.unbind()
                except ldap.LDAPError, e:
                    pass

        if not ('login' in identity and 'password' in identity): return None
        if not identity["login"] or not identity["password"]: return None
        user = self.get_user(identity['login'])
        if user:
            ignore_user_list = config.get('ignore_user_list', '').split(',')
            for i in ignore_user_list:
                if i.strip().upper() == identity['login'].upper(): return _auth_db()
            ldapConfig = config.ldap
            ldapcon = ldap.initialize("ldap://%s:%d" % (ldapConfig.host, ldapConfig.port))
            ldapcon.simple_bind_s(ldapConfig.initdn, ldapConfig.initpw)
            filter = "(sAMAccountName=%s)" % identity['login']
            dn = None

            for bdn in ldapConfig.basedn:
                rc = ldapcon.search(bdn, ldap.SCOPE_SUBTREE, filter)
                objects = ldapcon.result(rc)[1]
                if len(objects) == 1:
                    dn = objects[0][0]
                    break
            else:  #check with DB
                return _auth_db()
            return _auth_ad()


# add by DengChao
from repoze.who.plugins.friendlyform import FriendlyFormPlugin

class FriendlyTimeoutPlugin(FriendlyFormPlugin):
    def identify(self, environ):
        identity = super(FriendlyTimeoutPlugin, self).identify(environ)
        if identity:
            identity['max_age'] = 600  #10 mins,set by CL on 2010-06-18
        return identity






def _get_item_as_row(self, item_name):
    """
    Return the SQLAlchemy row for the item called ``item_name``.

    When dealing with a group source, the item is a user. And when dealing
    with a permission source, the item is a group.

    """
    # "field" usually equals to {tg_package}.model.User.user_name
    # or {tg_package}.model.Group.group_name
    field = getattr(self.children_class, self.translations['item_name'])
    query = self.dbsession.query(self.children_class).options(eagerload(self.translations['sections']))
    try:
#        item_as_row = query.filter(field == item_name).one()
        #change by CL.Lam on 20101-12-21 , to solve the login case-insensitive problem.
        item_as_row = query.filter(field.op("ilike")(item_name)).one()
    except NoResultFound:
        msg = 'Item (%s) "%s" does not exist in the child table'
        msg = msg % (self.translations['item_name'], item_name)
        raise SourceError(msg)
    return item_as_row

SqlGroupsAdapter._get_item_as_row = _get_item_as_row

