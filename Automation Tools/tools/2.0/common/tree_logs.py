#!/usr/bin/python -u
# -*- coding: utf-8 -*-
#
#       tree_logs.py
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
Rev 0.1 : 2012/10/24
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
import redmine
from datetime import datetime
from datetime import timedelta


class ATE_TREE_LOGS():
    """
    """
    _logpath = '.'
    _logger = None
    _cases = []
    _case = {
        'idx': '',
        'run_idx': '',
        'name': '',
        'tsuite': '',
        'fullpath': '',
        'status': '',
        'type': '',
        'redmine_issue_id': '',
        'duration': '',
        'starttime': '',
        'last_error': '',
        'error_detail': '',
        'description': '',
        'logpath': '',
        'casepath': '',
    }

    _logger = None
    _loghdlr = None
    _cfg = {}
    _tst2iid = {}

    def __init__(self, logpath='.'):
        """
        """
        self._logpath = logpath

    def log(self, msg):
        """
        log log
        """
        print '[INFO]', msg
        if self._logger:
            self._logger.info(msg)


    def error(self, msg):
        """
        log error
        """
        print '[ERROR]', msg
        if self._logger:
            self._logger.error(msg)


    def do_job(self):
        """
        """
        caseListFile = os.path.join(self._logpath, 'cases.rpt')
        if not os.path.exists(caseListFile):
            self.error("File not exist : %s" % caseListFile)
            return False

        self.log('Load File...')
        rc = self.loadCasesListFromFile(caseListFile)
        if not rc:
            return False

        self.log('Tree logs...')
        rc = self.treeLogs()


    def loadCasesListFromFile(self, fn):
        """
        """
        rpt_file = fn
        lines = []
        rc = True
        try:
            print '-------------'
            fd = open(rpt_file, 'r')
            if fd:
                lines = fd.readlines()
                fd.close()
                #
            ate_pid = 0
            for line in lines:
                # 
                #print '--->',line
                if line.startswith('####'):
                    # 
                    m = r'(\w*)\s*:\s*(.*)'
                    res = re.findall(m, line)
                    if len(res):
                        k, v = res[0]
                        k = k.strip()
                        v = v.strip()
                        self._cfg[k] = v
                        continue

                else:
                    m = r'(\d*)\s*(\d*)\s*(\w*)\s*(\w*)\s*(.*)'

                    res = re.findall(m, line)

                    if len(res):
                        #print '++',res[0]
                        idx, run_idx, st, tp, case_fullpath = res[0]
                        #print '+++++++++'
                        case_fullpath = case_fullpath.strip()
                        rc = self.updateCaseStatus(idx, run_idx, st, tp, case_fullpath)
                        #print 'xxxxxxxxxxxxx'
        except Exception, e:
            self.error('Exception : ' + str(e))
            #traceback.print_exc()
            formatted_lines = traceback.format_exc().splitlines()
            self.error('Exception : ' + pformat(formatted_lines))
            rc = False
        print '-------------Done :', rc
        return rc

    def updateCaseStatus(self, idx, run_idx, st, tp, case_fullpath):
        """
        Update the test case status
        """
        #print "==","Enter updateCaseStatus"
        dpath = os.path.dirname(case_fullpath)
        case_name = os.path.basename(case_fullpath)
        tst_name = dpath[:dpath.rfind(':')]

        case = deepcopy(self._case)
        case['idx'] = idx
        case['run_idx'] = run_idx
        case['name'] = case_name
        case['tsuite'] = tst_name
        case['fullpath'] = case_fullpath
        case['status'] = st
        case['type'] = tp

        #case['redmine_issue_id'] = iid

        #self.fillCaseDetail(case)

        self._cases.append(case)
        return True


    def treeLogs(self):
        """
        """
        #print self._cases
        rpath = os.path.join(self._logpath, '__treelogs__')
        if len(self._cases):
            if os.path.exists(rpath):
                cmd = 'rm -rf ' + rpath
                os.system(cmd)

        for case in self._cases:
            """
            """
            if case['status'] == 'SKIPPED':
                continue

            # Get case log path
            case_logdir = '%s__%s' % (case['run_idx'], case['name'])
            #case_logpath = os.path.join(self._logpath,case_logpath)

            if case['status'] != 'checked':
                case_logdir = '%s_%s' % (case_logdir, case['status'])
                case_logpath = os.path.join(self._logpath, case_logdir)
            else:
                case_logpath = os.path.join(self._logpath, case_logdir)
                if not os.path.exists(case_logpath):
                    continue

            print '\n\n'
            print '--' * 16
            # Get new log path
            tstp = case['fullpath']
            #tstp.split('/')
            m = r'([^:]*):([^/]*)/'
            res = re.findall(m, tstp)

            z = []
            np = ''
            for r in res:
                (fn, lineno) = r
                z.append(fn)
                #
                zz = lineno.split('-')
                zz[0] = "%04d" % int(zz[0])
                lineno = '-'.join(zz)
                z.append('%s' % lineno)

            if len(z) > 1:
                z = z[1:-1]

            i = 0
            while (i < len(z)):
                if (i % 2):
                    np += "__"
                else:
                    if len(np):
                        np += '/'
                    np += "LINE_"
                np += (z[i])

                i += 1

            #print np





            ppath = os.path.join(rpath, np)

            print ppath
            #
            if not os.path.exists(ppath):
                os.makedirs(ppath)

            npath = os.path.join(ppath, case_logdir)
            #print case_logpath,npath
            os.symlink(case_logpath, npath)


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ("\nGet more info with command : pydoc " + os.path.abspath(__file__) + "\n")
    parser = OptionParser(usage=usage)

    parser.add_option("-d", "--destination", dest="DEST",
                      help="destination log path,default is current")

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
    #if len(args) < 1 :
    #    print '==','1 arguments required'
    #    parser.print_help()
    #    exit(1)
    return args, options


def main():
    """
    main entry
    """

    args, opts = parseCommandLine()

    dest = '.'
    if opts.DEST:
        dest = opts.DEST

    if os.path.exists(dest) and os.path.isdir(dest):
        pass
    else:
        print '----> Illegal Path :', dest
        exit(1)

    dp = os.path.realpath(dest)

    atl = ATE_TREE_LOGS(dp)

    atl.do_job()

    print '--' * 16
    print '==DONE!'
    exit(0)


if __name__ == '__main__':
    """
    """

    main()