#!/usr/bin/python -u
# -*- coding: utf-8 -*-
#
#       db_mysql.py
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


def getJobFullpath(job):
    """
    """
    fullpath = []
    sz = len(job['filepath'])
    for i in range(0, sz):
        if i == sz - 1:
            fullpath.append(job['filepath'][i])
        else:
            fullpath.append(job['filepath'][i] + ':' + str(job['linenum'][i]))
    tst_path = '-->'.join(fullpath)
    return tst_path


def strFullPath(job):
    """
    """
    fullpath = ''
    for idx, fp in enumerate(job['filepath']):
        fn = os.path.basename(fp)
        ln = job['linenum'][idx]
        #if len(fullpath) : fullpath += '/'
        fullpath = os.path.join(fullpath, fn + ':' + str(ln))
    fn = os.path.basename(job['param'])
    fullpath = os.path.join(fullpath, fn)

    return fullpath


def strFullParentPath(job):
    """
    """
    fullpath = ''
    for idx, fp in enumerate(job['filepath']):
        fn = os.path.basename(fp)
        ln = job['linenum'][idx]
        #if len(fullpath) : fullpath += '/'
        fullpath = os.path.join(fullpath, fn + ':' + str(ln))
    fullpath = fullpath[0:fullpath.rfind(':')]
    return fullpath


class dbAgent():
    """

    describe tasks
    (('id', 'int(11)', 'NO', 'PRI', None, 'auto_increment'),
     ('TUID', 'varchar(255)', 'NO', '', None, ''),
     ('Name', 'varchar(255)', 'NO', '', None, ''),
     ('Tester', 'varchar(255)', 'NO', '', None, ''),
     ('Testbed', 'varchar(255)', 'NO', '', None, ''),
     ('AT_Version', 'varchar(255)', 'NO', '', None, ''),
     ('DutType', 'varchar(255)', 'NO', '', None, ''),
     ('DutVersion', 'varchar(255)', 'NO', '', None, ''),
     ('DutLibVersion', 'varchar(255)', 'NO', '', None, ''),
     ('Status', 'varchar(255)', 'NO', '', None, ''),
     ('StartTime', 'datetime', 'NO', '', None, ''),
     ('EndTime', 'datetime', 'NO', '', None, ''),
     ('Duration', 'int(11)', 'NO', '', None, ''),
     ('LogPath', 'varchar(255)', 'NO', '', None, ''),
     ('TestType', 'varchar(255)', 'NO', '', None, '')),
     ('LastError', 'text', 'NO', '', None, ''))


     describe records
    (('id', 'int(11)', 'NO', 'PRI', None, 'auto_increment'),
     ('TUID', 'varchar(255)', 'NO', '', None, ''),
     ('Index', 'int(11)', 'NO', '', None, ''),
     ('RunIndex', 'int(11)', 'NO', '', None, ''),
     ('CaseName', 'varchar(255)', 'NO', '', None, ''),
     ('CaseType', 'varchar(255)', 'NO', '', None, ''),
     ('CaseStatus', 'varchar(255)', 'NO', '', None, ''),
     ('StartTime', 'datetime', 'NO', '', None, ''),
     ('EndTime', 'datetime', 'NO', '', None, ''),
     ('Duration', 'int(11)', 'NO', '', None, ''),
     ('LastError', 'text', 'NO', '', None, ''),
     ('LogPath', 'varchar(255)', 'NO', '', None, ''),
     ('SuiteFullname', 'varchar(255)', 'NO', '', None, ''),
     ('CaseFullName', 'varchar(255)', 'NO', '', None, ''),
     ('CaseFileFullPath', 'varchar(255)', 'NO', '', None, ''),
     ('CaseDescription', 'text', 'NO', '', None, ''),
     ('AgileIssueID', 'int(11)', 'NO', '', None, ''),
     ('AgileIssueTitle', 'varchar(255)', 'NO', '', None, ''))

    """
    # private members
    _logger = None


    def __init__(self):
        """
        """
        pass

    def info(self, msg):
        """
        log info
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

    def addTask(self, jobs):
        """
        """

        cols_names = ['TUID', 'Name', 'Tester', 'Testbed', 'AT_Version', 'DutType', 'DutVersion', 'DutLibVersion',
                      'Status', 'StartTime', 'EndTime', 'Duration', 'LogPath', 'TestType']
        cols = {
            'TUID': "'%s'" % os.getenv('G_AT_UUID'),
            'Name': "'%s'" % os.getenv('G_AT_TASK_NAME', ''),
            'Tester': "'%s'" % os.getenv('G_TESTER', 'UNKNOWN'),
            'Testbed': "'%s'" % os.getenv('G_TBNAME', 'UNKNOWN'),
            'AT_Version': "'%s'" % os.getenv('G_AT_SW_VER', 'UNKNOWN'),
            'DutType': "'%s'" % os.getenv('U_DUT_TYPE', 'UNKNOWN'),
            'DutVersion': "'%s'" % os.getenv('U_DUT_SW_VERSION', 'UNKNOWN'),
            'DutLibVersion': "'%s'" % os.getenv('U_DUT_FW_VERSION', 'UNKNOWN'),
            'Status': "'%s'" % 'Precondition',
            'StartTime': 'Now()',
            'EndTime': 'Now()',
            'Duration': "'%s'" % '0',
            'LogPath': "'%s'" % os.path.realpath(os.getenv('G_CURRENTLOG', '/root/automation/logs/current')),
            'TestType': "'%s'" % os.getenv('G_AT_TAGS', 'full'),
            'LastError': "'%s'" % '',
        }





        # combine sql sentence
        sqlfmt = 'INSERT INTO tasks (%s) VALUES (%s);'
        # rearrange cols value
        vals = []
        for k in cols_names:
            v = cols.get(k, '')
            if 0 == len(v):
                vals.append("'" + v + "'")
            else:
                vals.append(v)

        for i in range(len(cols_names)):
            cols_names[i] = ("`%s`" % str(cols_names[i]) )

        sql = sqlfmt % (','.join(cols_names), ','.join(vals)  )
        self.emitSQL(sql)

        #
        #exit(1)
        pass

    def addAllCases(self, jobs):
        """
        """

        cols = {
            'TUID': "'%s'" % os.getenv('G_AT_UUID'),
            'Index': '',
            'RunIndex': '',
            'CaseName': '',
            'CaseType': '',
            'CaseStatus': '',
            'StartTime': '',
            'EndTime': '',
            'Duration': '',
            'LastError': '',
            'LogPath': '',
            'SuiteFullName': '',
            'CaseFullName': '',
            'CaseFileFullPath': '',
            'CaseDescription': '',
            'AgileIssueID': '',
            'AgileIssueTitle': '',
        }

        sqls = []
        # combine sql sentence
        sqlfmt = 'INSERT INTO records (%s) VALUES (%s);'
        # rearrange cols value
        caseIndex = 0
        for job in jobs:
            record = None#deepcopy(cols)
            if job['type'] == 'TCASE' or job['type'] == 'NCASE':
                caseIndex += 1
                cols_names = ['TUID', 'Index', 'RunIndex', 'CaseName', 'CaseType', 'CaseStatus', 'StartTime', 'EndTime',
                              'Duration', 'LastError', 'LogPath', 'SuiteFullName', 'CaseFullName', 'CaseFileFullPath',
                              'CaseDescription', 'AgileIssueID', 'AgileIssueTitle']
                record = deepcopy(cols)
                record['Index'] = str(caseIndex)
                record['RunIndex'] = str(0)
                record['CaseName'] = "'%s'" % os.path.basename(job['param'])
                record['CaseType'] = "'%s'" % job['type']
                record['CaseStatus'] = "'%s'" % job.get('status', '')
                record['SuiteFullName'] = "'%s'" % strFullParentPath(job)
                record['CaseFullName'] = "'%s'" % strFullPath(job)
                record['CaseFileFullPath'] = "'%s'" % job.get('param', '')
                #record['CaseDescription'] = "'%s'"% job['case'].get('description','')

                # combine sql sentence
                sqlfmt = 'INSERT INTO records (%s) VALUES (%s);'
                # rearrange cols value
                vals = []
                for k in cols_names:
                    v = record.get(k, '')
                    if 0 == len(v):
                        vals.append("'" + v + "'")
                    else:
                        vals.append(v)

                #
                for i in range(len(cols_names)):
                    cols_names[i] = ("`%s`" % str(cols_names[i]) )

                sql = sqlfmt % (','.join(cols_names), ','.join(vals)  )
                sqls.append(sql)
                #self.emitSQL(sql)
                #exit(1)
            else:
                continue

        #
        self.emitSQLs(sqls)


    def updateTask(self, status, last_error):
        """
        """
        TUID = os.getenv('G_AT_UUID', '')
        sqlfmt = "UPDATE tasks SET %s WHERE TUID='%s'; "
        cols = {
            'DutVersion': "'%s'" % os.getenv('U_DUT_FW_VERSION', 'UNKNOWN'),
            'DutLibVersion': "'%s'" % os.getenv('U_DUT_SW_VERSION', 'UNKNOWN'),
            'Status': '',
            #'StartTime' : 'Now()',
            'EndTime': '',
            #'Duration' : '0',
            #'LastError' : '',
        }
        record = deepcopy(cols)
        record['Status'] = "'%s'" % str(status)
        record['EndTime'] = 'Now()'
        #record['LastError'] = "'%s'"% pformat(last_error)
        ups = ''
        for k, v in record.items():
            if len(ups):
                ups += ','

            if not v:
                v = ("'" + str(v) + "'")
            ups += ("`%s`=%s" % (k, v) )

        sql = sqlfmt % (ups, TUID)
        self.emitSQL(sql)
        return

    def updateCase(self, job):
        """
        """
        TUID = os.getenv('G_AT_UUID', '')
        if job['type'] == 'TCASE' or job['type'] == 'NCASE':
            cols = {
                #'TUID' : os.getenv('G_AT_UUID'),
                #'Index' : '',
                'RunIndex': '',
                #'CaseName' : '',
                #'CaseType' : '',
                'CaseStatus': '',
                'StartTime': '',
                'EndTime': '',
                #'Duration' : '',
                'LastError': '',
                #'LogPath' : '',
                #'SuiteFullName' : '',
                #'CaseFullName' : '',
                #'CaseFileFullPath' : '',
                #'CaseDescription' : '',
                #'AgileIssueID' : '',
                #'AgileIssueTitle' : '',
            }

            sqlfmt = "UPDATE records SET %s WHERE `TUID`='%s' AND `CaseFullName`='%s';"

            record = deepcopy(cols)

            case = job['case']
            record['RunIndex'] = job.get('case_index', 0)

            record['CaseStatus'] = "'%s'" % job.get('status', '')
            record['StartTime'] = "'%s'" % case.get('dt_start', '')
            record['EndTime'] = "'%s'" % case.get('dt_end', )
            #record['duration'] =
            record['LastError'] = "'%s'" % MySQLdb.escape_string(case.get('last_error', ''))
            record['LogPath'] = "'%s'" % job.get('logpath', '')

            CaseFullName = strFullPath(job)
            ups = ''
            for k, v in record.items():
                if len(ups):
                    ups += ','

                if not v:
                    v = ("'" + str(v) + "'")

                ups += ("`%s`=%s" % (k, str(v)) )

            #
            sql = sqlfmt % (ups, TUID, CaseFullName)
            self.emitSQL(sql)
        else:
            return

    def emitSQL(self, sql):
        """
        """
        self.info('==EMIT_SQL==> %s' % sql)

        try:
            import db_agent

            db_agent.emit_sql(sql)
            #cmd = 'dbus-launch --exit-with-session at_db_agent.py -c -v "%s" ' % (sql)

            #self.checkDbus()
            #os.system(cmd)
            #self.emit_sql(sql)

        except Exception, e:
            self.error(str(e))
            cmd = 'at_db_agent.py -c -v "%s" ' % (sql)
            os.system(cmd)
            #exit(1)

        return True


    def emitSQLs(self, sqls):
        """
        """
        #self.info('==EMIT_SQL==> %s'%sql)

        try:
            import db_agent

            for sql in sqls:
                db_agent.emit_sql(sql)
        except Exception, e:
            self.error(str(e))
            #exit(1)
            max_str_len = 6000
            cmd = ''
            for idx, sql in enumerate(sqls):
                if 0 == len(cmd):
                    #cmd = 'dbus-launch --exit-with-session at_db_agent.py -c '
                    cmd = 'at_db_agent.py -c '

                cmd += ('-v "%s" ' % (sql) )
                if len(cmd) > max_str_len:
                    #self.checkDbus()
                    os.system(cmd)
                    cmd = ''
                else:
                    pass

            # send remains
            if len(cmd):
                os.system(cmd)

        return True

    def checkDbus(self):
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


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ("\nGet more info with command : pydoc " + os.path.abspath(__file__) + "\n")
    parser = OptionParser(usage=usage)

    parser.add_option("-s", "--saveas", dest="SAVEAS",
                      help="Save result to")

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

    dbi = dbAgent()

    print '--' * 16
    print '==DONE!'
    exit(0)


if __name__ == '__main__':
    """
    """

    main()


















