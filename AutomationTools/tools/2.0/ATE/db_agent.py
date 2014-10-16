#!/usr/bin/python -u
# -*- coding: utf-8 -*-
#
#       db_agent.py
#
#       Copyright 2012 rayofox <lhu@actiontec.com>
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#
#
#------------------------------------------------------------------------------

"""

"""
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2012, Rayofox"
__version__ = "0.1"
__license__ = "MIT"
__history__ = """
Rev 0.1 : 2012/11/05
    Initial version
"""
#------------------------------------------------------------------------------
from types import *
import sys, time, os
import re
from optparse import OptionParser
from optparse import OptionGroup
import logging
from pprint import pprint
from pprint import pformat
import xml.etree.ElementTree as etree
import subprocess, signal, select
from copy import deepcopy
import syslog
import traceback
from datetime import datetime
from datetime import timedelta
import MySQLdb

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
import time
import gobject


def check_uniq():
    """
    """
    pid = os.getpid()
    opid = 0
    # Get pid from pid file
    f_pid = '/var/run/db_agent.pid'
    if os.path.exists(f_pid):
        try:
            fd = open(f_pid)
            if fd:
                opid = int(fd.read().strip())
                fd.close()
        except:
            print 'Illegal pid in file ' + f_pid

    # Find progress by pid
    if opid > 0:
        cmd = 'ps -p %d | grep -c %d' % (opid, opid)
        res = os.popen(cmd).read().strip()
        if res != '0':
            syslog.syslog(syslog.LOG_ERR, 'db_agent is already in running! the pid is ' + str(opid))
            ATE_LOGGER.error('EXIT : ATE is already running!')
            exit(99)

    # Update the new pid
    print 'Update the db_agent latest pid : ' + str(pid)
    os.system('echo ' + str(pid) + ' >' + f_pid)
    return True


SERVICE_NAME = "com.actiontec.automation"
SERVICE_PATH = "/com/actiontec/automation"
INTERFACE_NAME = "com.actiontec.automation"



#SERVICE_NAME    = "org.freedesktop.DBus.foo"
#SERVICE_PATH    = "/org/freedesktop/DBus/foo"
#INTERFACE_NAME  = SERVICE_NAME

TIMEFORMAT = "%H:%M:%S"


class DB_AGENT(dbus.service.Object):
    """
    """
    _logger = None
    _sqls = []

    _dbinfo = {
        'host': '192.168.20.106', #'127.0.0.1',
        'username': 'root',
        'password': '123qaz',
        'dbname': 'automation_test',
    }

    def __init__(self, bus, object_path):
        """
        """
        dbus.service.Object.__init__(self, bus, object_path)
        self.initLog()
        #

    def initLog(self):
        """
        """
        logpath = '/var/log/ATE'
        logfile = os.path.join(logpath, 'db_agent')
        if not os.path.exists(logpath):
            os.makedirs(logpath)


        # backup log file each 30 days
        BACKUP_INTERVAL = 30 * (60 * 60 * 24)
        #BACKUP_INTERVAL = 30
        if os.path.exists(logfile):
            si = os.stat(logfile)
            dt_create = datetime.fromtimestamp((si.st_ctime))
            dt_now = datetime.now()
            diff_secs = (dt_now - dt_create).total_seconds()
            #print '--> ',diff_secs
            if diff_secs >= BACKUP_INTERVAL:
                bkfile = logfile + '-' + datetime.today().strftime('%Y%m%d')
                os.system('mv %s %s' % (logfile, bkfile))
            else:
                pass

        #
        self._logger = logging.getLogger('ATE_DB_AGENT')
        syshdlr = logging.FileHandler(logfile)
        FORMAT = '[pid=%(process)d][%(asctime)-15s][%(levelname)s]%(message)s'
        syshdlr.setFormatter(logging.Formatter(FORMAT))
        self._logger.addHandler(syshdlr)
        self._logger.setLevel(11)


    def info(self, msg):
        """
        log log
        """
        print '==[INFO]==', msg
        if self._logger:
            self._logger.info(msg)


    def error(self, msg):
        """
        log error
        """
        print '==[ERR]==', msg
        if self._logger:
            self._logger.error(msg)

    @dbus.service.method(dbus_interface=INTERFACE_NAME,
                         in_signature='', out_signature='s')
    def say_hello(self):
        return "hello, exported method"

    @dbus.service.method(dbus_interface=INTERFACE_NAME,
                         in_signature='s', out_signature='')
    def addSQL(self, sql):
        self._sqls.append(sql)
        #self.construct_msg()

    @dbus.service.signal(dbus_interface=INTERFACE_NAME,
                         signature='as')
    def msg_signal(self, msg_list):
        """
        """
        self.dojobs()

    def construct_msg(self):
        timeStamp = time.strftime(TIMEFORMAT)
        self.msg_signal(["LOG", timeStamp, "This is the content", "alive!"])
        return True

    def dojobs(self):
        """
        """
        rc = True
        len_sent = 0
        _db = None

        if 0 == len(self._sqls):
            exit(0)
            #return True
        try:
            # 1. open db
            #
            host = self._dbinfo['host']
            user = self._dbinfo['username']
            passwd = self._dbinfo['password']
            dbname = self._dbinfo['dbname']

            _db = MySQLdb.connect(host, user, passwd, dbname, connect_timeout=10)
            max_sent = 30

            # do sqls ,
            cursor = _db.cursor()
            for sql in self._sqls:
                retry_cnt = 3
                i = 0
                while (i < retry_cnt):
                    i += 1
                    rc = self.doSQL(cursor, sql)
                    if rc: break
                if rc:
                    self.info('==DONE : ' + sql)
                else:
                    self.info('==FAIL : ' + sql)
                    time.sleep(1)

                len_sent += 1
                if len_sent >= max_sent:
                    break
            cursor.close()
        except Exception, e:
            formatted_lines = traceback.format_exc().splitlines()
            #self.error('Exception : ' + pformat(formatted_lines))
            self.error('Exception : %s' % e)
            rc = False

        # clear
        if len_sent > 0:
            del self._sqls[:len_sent]
        if _db: _db.close()

        return rc

    def doSQL(self, cursor, sql):
        """
        """
        rc = True
        try:
            cursor.execute('Set AUTOCOMMIT = 1')
            cursor.execute(sql)
        except Exception, e:
            formatted_lines = traceback.format_exc().splitlines()
            #self.error('Exception : ' + pformat(formatted_lines))
            self.error('Exception : %s' % e)
            rc = False
        return rc


def checkDbus():
    """
    """
    need_relaunch = False
    pid = os.getenv('DBUS_SESSION_BUS_PID', None)
    if pid:
        cmd = 'ps -p %s | grep -c %s ' % (pid, pid)
        res = os.popen(cmd).read().strip()
        if res != '0':
            pass
        else:
            need_relaunch = True
    else:
        need_relaunch = True

    if need_relaunch:
        print '==> Need to relaunch dbus-launch'
        os.system('env | grep DBUS_')
        cmd = 'dbus-launch '
        res = os.popen(cmd).read().strip()
        lines = res.splitlines()
        for line in lines:
            m = r'(\w*)=(.*)'
            rr = re.findall(m, line)
            if len(rr):
                k, v = rr[0]
                print '--> putenv :', k, v
                os.environ[k] = v
    return True


def start_server():
    """
    """
    #check_uniq()
    print '==> Work as server'
    #checkDbus()
    DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()
    #bus = dbus.SystemBus()
    try:
        bus_name = INTERFACE_NAME
        #bus_name = dbus.service.BusName(bus_name,
        #                                bus, allow_replacement = False, replace_existing = True, do_not_queue = True)

        dbs = DB_AGENT(bus, SERVICE_PATH)
        name = dbus.service.BusName(INTERFACE_NAME, bus)
        gobject.timeout_add(2000, dbs.construct_msg)
        loop = gobject.MainLoop()
        loop.run()
    except Exception, e:
        #print '======> Service already exist!'
        print '==|', e
        formatted_lines = traceback.format_exc().splitlines()
        print ('Exception : ' + pformat(formatted_lines))
        pass

    #print '==','db_agent Server Done'
    return True


def emit_sql(sql, logger=None):
    """
    """
    rc = True
    try:
        #checkDbus()
        bus = dbus.SessionBus()
        bus_obj = bus.get_object(INTERFACE_NAME, SERVICE_PATH)
        sender = dbus.Interface(bus_obj, INTERFACE_NAME)
        sender.addSQL(sql)

    except Exception, e:
        formatted_lines = traceback.format_exc().splitlines()
        if logger:
            logger.error('Exception : ' + pformat(formatted_lines))
        else:
            print('Exception : ' + pformat(formatted_lines))
        rc = False

    #print '==',os.getpid(),'emit_sql Done!'
    return rc


def doSQL(cursor, sql):
    """
    """
    rc = True
    try:
        cursor.execute('Set AUTOCOMMIT = 1')
        cursor.execute(sql)
    except Exception, e:
        formatted_lines = traceback.format_exc().splitlines()
        #self.error('Exception : ' + pformat(formatted_lines))
        print('Exception : %s' % e)
        rc = False
    return rc


def dojobs(_sqls):
    """
    """
    rc = True
    len_sent = 0
    _db = None

    if 0 == len(_sqls): return True
    try:
        # 1. open db
        #
        host = self._dbinfo['host']
        user = self._dbinfo['username']
        passwd = self._dbinfo['password']
        dbname = self._dbinfo['dbname']

        _db = MySQLdb.connect(host, user, passwd, dbname)
        max_sent = 30

        # do sqls ,
        cursor = _db.cursor()
        for sql in _sqls:
            #retry_cnt = 3
            i = 0
            while (i < retry_cnt):
                i += 1
                rc = doSQL(cursor, sql)
                if rc: break
            if rc:
                print('==DONE : ' + sql )
            else:
                print('==FAIL : ' + sql )

            len_sent += 1
            if len_sent >= max_sent:
                break
        cursor.close()
    except Exception, e:
        formatted_lines = traceback.format_exc().splitlines()
        #self.error('Exception : ' + pformat(formatted_lines))
        print('Exception : %s' % e)
        rc = False

    # clear
    #if len_sent > 0 :
    #    del self._sqls[:len_sent]
    if _db: _db.close()

    return rc


def emit_sql2(sql, logger=None):
    """
    """
    rc = True
    dojobs(sql)

    return rc


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ("\nGet more info with command : pydoc " + os.path.abspath(__file__) + "\n")
    parser = OptionParser(usage=usage)

    parser.add_option("-s", "--server", dest="SERVER", action="store_true", default=True,
                      help="")

    parser.add_option("-c", "--client", dest="CLIENT", action="store_true", default=False,
                      help="")

    parser.add_option("-v", "--verbs", dest="VERBS", action="append", default=[],
                      help="Action to do")

    (options, args) = parser.parse_args()


    # output the options list
    print '==' * 32
    print 'Args :'
    for arg in args:
        print arg
        # output the options list
    print '==' * 32
    print 'Options :'
    excludes = ['read_file', 'read_module', 'ensure_value']
    for k in dir(options):
        if k.startswith('_') or k in excludes:
            continue
            #
        v = getattr(options, k)
        print '%-16s : %s' % (k, v)
    print '==' * 32
    print '\n' * 2

    return args, options


def main():
    """
    main entry
    """

    args, opts = parseCommandLine()

    if opts.SERVER and not opts.CLIENT:
        start_server()
    else:
        if opts.VERBS:
            for sql in opts.VERBS:
                emit_sql(sql)

    print '--' * 16
    print '==DONE!'
    exit(0)


if __name__ == '__main__':
    """
    """

    main()


















