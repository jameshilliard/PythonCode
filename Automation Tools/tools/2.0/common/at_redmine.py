#!/usr/bin/python -u
# -*- coding: utf-8 -*-
#
#       ATE.py
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
This tool is plugin for ATE, automatic report issue to redmine
Options :

--timer_check           : the inverval to check result, default is 300 seconds

--per_case              :  one case one bug
--per_suite             :  on suite one bug, the default type

--with_ncase            :  report bug if ncase failed
--without_nase          :  not report bug if ncase failed,the default type


--tbname=TBNAME         :  Test bed name
--issue_parent=PID      :  parent issue id
--issue_assignee=AS     :  the assignee of the issue
--issue_trackid=TID     :  Track id ,default is 13 , QA Bug
--issue_version_id=VID  :  version id, default is AT Bug List
--issue_project=PROJ    :  project id, default is automation-test

--redmine_url=RM_URL    : redmine url
--redmine_username=RM_USR
                        redmine login user
--redmind_password=RM_PWD
                        redmine login password

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


def_cfg = {
    # redmine parameters
    'RM_URL': 'http://192.168.20.105/redmine',
    'RM_USR': '',
    'RM_PWD': '',
    'RM_KEY': 'c5c28afa96fbf4887fd132d76bec42492731a303',
    # issue parameters
    'TBNAME': 'TB_UNKNOWN',
    'PID': '28356',
    'AS': '0', # rnobody
    'TID': '13', # QA Bug
    'VID': '0', # 126, # NEXT (2012)
    'PROJ': 'automation-test',
    'TITLE': '',
    'DESP': '',

    # Others
    'TIMER': 300,
    'PER_CASE': False,
    'WITH_NCASE': False,
    'SYSLOG': False,
    'AS_RULE_FILE': '/root/automation/testsuites/2.0/common/redmine_rules',
    'TST_FULLPATH': '',
}


def pp_duration(dur):
    """
    """
    nDur = int(float(dur))
    nHour = int(nDur) / 3600
    nMin = (int(nDur) - nHour * 3600) / 60
    nSec = int(nDur) % 60
    #nMilSec = (int) ((float(dur) - nDur) * 1000)
    #print '==nMilSec',nMilSec
    #return (nHour, nMin, nSec, nMilSec)
    return (nHour, nMin, nSec)


class ATE_AUTO_REDMINE():
    """
    This class support AT redmine all functions
    """
    _cfg = {}
    _trpt = {
        'current_path': '/root/automation/logs/current',
        'rpt_file': 'cases.rpt',

        'last_path': '',
        'last_case': '',
        'tst_done': '',
        'cases_not_done': -1,
    }
    _cases = []
    _case = {
        'idx': '',
        'run_idx': '',
        'name': '',
        'tsuite': '',
        'fullpath': '',
        'status': '',
        'type': '',
    }
    _cfgfile = '/etc/ate_auto_remine'
    _logger = None
    _loghdlr = None
    _user2id = {}
    _tst2user = {}
    _dut2pid = {}
    #
    _tst2iid = {}
    _tb2author = {}


    #
    _issues2rpt = []

    def __init__(self, opts):
        """
        Initial
        """
        self._cfg = deepcopy(def_cfg)
        #self._cfg.update(opts)

        # parse rules file first
        AS_RULE_FILE = opts.get('AS_RULE_FILE')
        if not AS_RULE_FILE:
            AS_RULE_FILE = self._cfg.get('AS_RULE_FILE')

        if AS_RULE_FILE:
            self.load_rules(AS_RULE_FILE)

        # overwritten by command line parameters
        for k, v in opts.items():
            if v and len(str(v).strip()):
                print '==|', k, v
                self._cfg[k] = v

    def load_rules(self, fn):
        """
        Load all rules in file
        """
        if not os.path.exists(fn):
            return
        fd = open(fn, 'r')
        lines = []
        if fd:
            lines = fd.readlines()
            fd.close()

        for line in lines:
            if line.startswith('#'):
                pass
            elif line.startswith('-A '):
                # remove head
                ss = line[2:]
                # remove comment
                ss = ss.split('#')[0]
                #
                m = r'(\w*)\s*:\s*(\d*)'
                res = re.findall(m, ss)
                if len(res):
                    k, v = res[0]
                    self._user2id[k] = v

            elif line.startswith('-T '):
                # remove head
                ss = line[2:]
                # remove comment
                ss = ss.split('#')[0]
                #
                m = r'([\w\.]*)\s*:\s*(.*)'
                res = re.findall(m, ss)
                if len(res):
                    #print res
                    k, v = res[0]
                    self._tst2user[k] = v
            elif line.startswith('-V '):
                # remove head
                ss = line[2:]
                # remove comment
                ss = ss.split('#')[0]
                #
                m = r'([\w\.]*)\s*:\s*(.*)'
                res = re.findall(m, ss)
                if len(res):
                    #print res
                    k, v = res[0]
                    if v and len(v):
                        self._cfg[k] = v
                        print 'load env :', k, v
            elif line.startswith('-P '):
                # remove head
                ss = line[2:]
                # remove comment
                ss = ss.split('#')[0]
                #
                m = r'([\w\.]*)\s*:\s*(.*)'
                res = re.findall(m, ss)
                if len(res):
                    #print res
                    k, v = res[0]
                    if v and len(v):
                        self._dut2pid[k] = v
            elif line.startswith('-B '):
                # remove head
                ss = line[2:]
                # remove comment
                ss = ss.split('#')[0]
                #
                m = r'([\w\.]*)\s*:\s*(.*)'
                res = re.findall(m, ss)
                if len(res):
                    #print res
                    k, v = res[0]
                    if v and len(v):
                        self._tb2author[k] = v
            else:
                pass
                #
                #pprint(self._user2id)
                #pprint(self._tst2user)
                #pprint(self._cfg)
                #exit(0)


    def prepare_log(self, path):
        """
        prepare the log
        """
        if not os.path.exists(path):
            #self._logfile = None
            return
            #path = '/root'
        logfile = os.path.join(path, 'at_redmine.log')
        #
        print '--> setup log :', logfile
        if not self._logger:
            self._logger = logging.getLogger('AT_REDMINE.SYS')

        if self._loghdlr:
            self._logger.removeHandler(self._loghdlr)
            self._loghdlr.close()
            self._loghdlr = None

        #

        self._loghdlr = logging.FileHandler(logfile)
        #FORMAT = '[%(asctime)-15s %(levelname)-8s] %(message)s'
        #self._loghdlr.setFormatter(logging.Formatter(FORMAT))
        self._logger.addHandler(self._loghdlr)
        self._logger.setLevel(11)

    def info(self, msg):
        """
        log info
        """
        print '==', str(msg)
        if self._cfg['SYSLOG']:
            syslog.syslog(str(msg))

        if self._logger:
            self._logger.info(msg)
            #print '--> log : ',msg


    def error(self, msg):
        """
        log error
        """
        print '==', str(msg)
        if self._cfg['SYSLOG']:
            syslog.syslog(syslog.LOG_ERR, str(msg))
        if self._logger:
            self._logger.error(msg)

    def loadcfg(self):
        """
        load config file , which saved all history info, to make jobs going on if the app is retart
        """
        try:
            print '==', 'Load cfg file :', self._cfgfile
            if not os.path.exists(self._cfgfile):
                print '==', 'Not exist cfg file :', self._cfgfile
            else:
                fd = open(self._cfgfile, 'r')
                lines = []
                if fd:
                    lines = fd.readlines()
                    fd.close()

                pt = {}
                for line in lines:
                    m = r'(\w*)\s*=\s*(.*)'
                    res = re.findall(m, line)
                    if len(res):
                        k, v = res[0]
                        pt[k] = v

                self._trpt['last_path'] = pt.get('LAST_PATH', '').strip()
                self._trpt['last_case'] = pt.get('LAST_CASE', '').strip()
                self._trpt['tst_done'] = pt.get('TST_DONE', '').strip()


            # Load issues reported
            self._tst2iid = {}
            hf = os.path.join(self._trpt['last_path'], 'redmine_issues')
            if os.path.exists(hf):
                print '==', 'Load cfg file :', hf
                fd = open(hf, 'r')
                lines = []
                if fd:
                    lines = fd.readlines()
                    fd.close()

                pt = {}
                for line in lines:
                    # [Tue Oct 30 13:30:27 2012] Add new issue for testsuite(run.cfg:112/sec_upnp.tst) to redmine [29466] : [QA Bug][TB_RAYOFOX][BAR1KH]test suites(sec_upnp.tst) cases failed(1)
                    m = r'testsuite\(([^\)]*)\)\s*to\s*redmine\s*\[(\d*)\]\s*:\s*(.*)'
                    res = re.findall(m, line)
                    if len(res):
                        tstname, iid, title = res[0]
                        self._tst2iid[tstname] = iid

                        #pprint(self._tst2iid)
                        #exit(1)


        except Exception, e:
            self.error('Exception : ' + str(e))
            #traceback.print_exc()
            formatted_lines = traceback.format_exc().splitlines()
            pprint('Exception : ' + pformat(formatted_lines))

    def savecfg(self):
        """
        Save history jobs into config file
        """
        try:
            print '==', 'To save cfg file :', self._cfgfile
            fd = open(self._cfgfile, 'w+')
            if fd:
                msg = ''
                msg += ('LAST_PATH=' + self._trpt['last_path'] + '\n')
                msg += ('LAST_CASE=' + self._trpt['last_case'] + '\n')
                msg += ('TST_DONE=' + self._trpt['tst_done'] + '\n')
                fd.write(msg)
                fd.close()
                print '==', 'Saved cfg file :', self._cfgfile
                print '==', msg
        except Exception, e:
            self.error('Exception : ' + str(e))
            #traceback.print_exc()
            formatted_lines = traceback.format_exc().splitlines()
            pprint('Exception : ' + pformat(formatted_lines))


    def check_test_result(self):
        """
        Timer check test result
        """
        self.info('OnTimer : check test result')
        # check last path

        if self._cfg.get('DEST_PATH'):
            self._trpt['last_path'] = os.path.realpath(self._cfg.get('DEST_PATH'))

        lpath = self._trpt['last_path']
        if lpath and os.path.exists(self._trpt['current_path']):
            self.info('== ' + 'Check last path : ' + lpath)
            self.prepare_log(self._trpt['last_path'])
        elif os.path.exists(self._trpt['current_path']):
            lpath = os.path.realpath(self._trpt['current_path'])
            self._trpt['last_path'] = lpath
            self.prepare_log(self._trpt['last_path'])
            self.info('== ' + 'Check current path : ' + lpath)
        else:
            self.info('==' + 'No log to check! ')
            return False
            #
        # Initial all
        #
        self._trpt['cases_not_done'] = -1
        self._cases = []

        rpt_file = os.path.join(lpath, self._trpt['rpt_file'])
        #self._trpt['cases_not_done'] =
        #
        lines = []
        try:
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

        if self._cfg['PER_CASE']:
            self.handle_per_case()
        else:
            self.handle_per_tsuite()

        # update
        if os.path.exists(self._trpt['current_path']):
            realpath = os.path.realpath(self._trpt['current_path'])
            if self._trpt['last_path'] != realpath:
                self.info('== ' + 'current path changed! From (' + self._trpt['last_path'] + ') to (' + realpath + ')')

                self._trpt['last_path'] = realpath
                self._trpt['last_case'] = ''
                self._trpt['tst_done'] = ''
                self._trpt['cases_not_done'] = -1

                self.prepare_log(self._trpt['last_path'])
                #self._trpt['last_path']
                #if 0 == self._trpt['cases_not_done'] :


    def handle_per_case(self):
        """
        Handle result per case
        """
        # To pick out all cases to handle
        cases_to_handle = []
        begin = False
        new_last_case = None
        last_case = self._trpt['last_case']
        if not last_case:
            begin = True

        for case in self._cases:
            if 'checked' == case['status']:
                if begin:
                    break
                else:
                    continue
            else:
                if begin:
                    cases_to_handle.append(case)
                else:
                    if case['fullpath'] == last_case:
                        begin = True

        #
        for case in cases_to_handle:
            rc = self.post_issue_by_case(case)
            if not rc: break

    def handle_per_tsuite(self):
        """
        Handle result per test suite
        """
        # To arrange all tsuites
        self.info('== ' + 'Enter handle_per_tsuite')
        map_tst = {}
        tsuite = {
            'name': '',
            'cases_done': [],
            'cases_not_done': [],
        }
        case = {
            'idx': '',
            'run_idx': '',
            'name': '',
            'tsuite': '',
            'fullpath': '',
            'status': '',
            'type': '',
        }
        for case in self._cases:
            #pprint(case)
            tst_name = case['tsuite']
            tst = None
            if tst_name in map_tst.keys():
                tst = map_tst[tst_name]
            else:
                tst = deepcopy(tsuite)
                tst['name'] = tst_name
                map_tst[tst_name] = tst
            if tst:
                if 'checked' == case['status']:
                    tst['cases_not_done'].append(case)
                else:
                    tst['cases_done'].append(case)
            #
        pprint(map_tst.keys())
        s_tst_last_done = self._trpt['tst_done']
        tst_last_done = s_tst_last_done.split(',')
        self.info('===>tst last done : ' + pformat(tst_last_done))
        tst_done = []
        for tst_name, tst in map_tst.items():
            self.info('Done(%d) \t Not Done(%d) \t tst[%s] ' % (
            len(tst['cases_done']), len(tst['cases_not_done']), tst_name ))
            if tst_name in tst_last_done:
                # already handled
                tst_done.append(tst_name)
                self.info("== tst %s has posted issue" % tst_name)
                continue
            elif 0 == len(tst['cases_not_done']):
                # all done

                rc = self.post_issue_by_tst(tst)
                if rc:
                    tst_done.append(tst_name)
                pass
            else:
                # not done
                pass
            # update tst done
        s_tst_done = ','.join(tst_done)
        self._trpt['tst_done'] = s_tst_done
        return


    def updateCaseStatus(self, idx, run_idx, st, tp, case_fullpath):
        """
        Update the test case status
        """
        #print "==","Enter updateCaseStatus"
        dpath = os.path.dirname(case_fullpath)
        case_name = os.path.basename(case_fullpath)
        tst_name = dpath[:dpath.rfind(':')]
        p = tst_name.find('.tst')
        if p > 0:
            p2 = tst_name.find('.tst', p + 4)
            if p2 > 0:
                tst_name = tst_name[:p2 + 4]
                pass
            else:
                tst_name = tst_name[:p + 4]

        case = deepcopy(self._case)
        case['idx'] = idx
        case['run_idx'] = run_idx
        case['name'] = case_name
        case['tsuite'] = tst_name
        case['fullpath'] = case_fullpath
        case['status'] = st
        case['type'] = tp

        self.fillCaseDetail(case)

        self._cases.append(case)
        #pprint(case)
        if self._trpt['cases_not_done'] < 0:
            self._trpt['cases_not_done'] = 0
            #
        if case['status'] == 'checked':
            self._trpt['cases_not_done'] += 1
            #print '==> Case not done :',self._trpt['cases_not_done']
        else:
            pass
            #print '==> Case status : ',case['status']

    def post_issue_by_case(self, case):
        """
        post issue case by case
        """
        if not self._cfg['WITH_NCASE'] and 'NCASE' == case['type']:
            return True

        # combine title and description
        # [QA Bug][SHTB12][TDS V2200H]Failed test case : xxx.xml
        tbname = self._cfg.get('TBNAME', 'UNKNOWN')
        product_id = self._cfg.get('DUT_PRODUCT_TYPE', 'UNKNOWN')
        tst_name = os.path.basename(tst['name'])

        title = '[QA Bug][%s][%s]Failed test case (%s) in test suite(%s) ' % (
        tbname, product_id, case['name'], tst_name)

        # descption
        # DUT_PRODUCT_TYPE :
        # DUT_MODEL_NAME :
        # DUT_SN :
        # DUT_FW :
        #
        # Log path :
        # ####################
        desp = ''
        desp += ('AT_TAG            : ' + self._cfg.get('AT_TAG', 'UNKNOWN') + '\n')
        desp += ('DUT_PRODUCT_TYPE  : ' + self._cfg.get('DUT_PRODUCT_TYPE', '') + '\n')
        desp += ('DUT_MODEL_NAME    : ' + self._cfg.get('DUT_MODEL_NAME', '') + '\n')
        desp += ('DUT_SN            : ' + self._cfg.get('DUT_SN', '') + '\n')
        desp += ('DUT_FW            : ' + self._cfg.get('DUT_FW', '') + '\n')
        desp += '\n'
        if 'FAILED' == case['status']:
            desp += (
            'Log path : ' + self._trpt['last_path'] + '/' + case['run_idx'] + '__' + case['name'] + '_FAILED' + '\n')
        desp += '#################\n'


        # post issue
        self._cfg['TITLE'] = title
        self._cfg['DESP'] = desp

        self.updateIssueInfo(tst_name)
        self.post_new_issue()

        return True

    def post_issue_by_tst(self, tst):
        """
        post issue tst by tst
        """
        #print '==','Enter post_issue_by_tst'
        # sort cases by status
        cases_failed = []
        cases_skipped = []
        cases_passed = []

        tst_spendtime = 0.0
        tst_spendtime_avg = 0.0
        tst_starttime = None
        for case in tst['cases_done']:
            #
            if not self._cfg['WITH_NCASE'] and 'NCASE' == case['type']:
                continue
                #
            if not tst_starttime:
                tst_starttime = case.get('start_time')
                #
            tst_spendtime += case.get('duration', 0.0)
            #
            if 'FAILED' == case['status']:
                cases_failed.append(case)
            elif 'SKIPPED' == case['status']:
                cases_skipped.append(case)
            elif 'PASSED' == case['status']:
                cases_passed.append(case)
            else:
                pass


        #
        if 0 == (len(cases_failed) + len(cases_skipped) ):
            # ALL PASSED do not post issue
            self.info('== ' + 'tst (' + tst['name'] + ') ALL PASSED ,so that do not post issue')
            return True

        #
        cnt_cases_done = len(cases_failed) + len(cases_passed)
        tst_spendtime_avg = 0
        if cnt_cases_done > 0:
            tst_spendtime_avg = tst_spendtime / cnt_cases_done

        # combine title and description
        # [QA Bug][SHTB12][TDS V2200H]test suites(xxx.tst) failed 5 cases
        tbname = self._cfg.get('TBNAME', 'UNKNOWN')
        product_id = self._cfg.get('DUT_PRODUCT_TYPE', 'UNKNOWN')
        tst_name = os.path.basename(tst['name'])

        author = self._tb2author.get(tbname, None)
        if author:
            self._cfg['RM_KEY'] = author

        #pprint(self._tb2author)
        #print '==RM_KEY==>',self._cfg['RM_KEY'],author
        #exit(1)

        tst_fullname = tst['name']
        iid = self._tst2iid.get(tst_fullname)
        self._cfg['TST_FULLPATH'] = tst_fullname

        #print '----->tst_fullname :',tst_fullname
        #print self._tst2iid.keys()
        # check issues reported
        if tst_fullname in self._tst2iid.keys():
            self.info('Issue(%s) is already reported to redmine for testsuite(%s) ' % (iid, tst_fullname))
            return True
            #
        failed_cnt_cases = len(cases_failed)
        skipped_cnt_cases = len(cases_skipped)
        passed_cnt_cases = len(cases_passed)
        title = ''
        if failed_cnt_cases > 0 and skipped_cnt_cases == 0 and passed_cnt_cases == 0:
            title = '[QA Bug][%s][%s]test suites(%s) cases all failed(%d)' % (
            tbname, product_id, tst_name, failed_cnt_cases)
        elif failed_cnt_cases == 0 and skipped_cnt_cases > 0 and passed_cnt_cases == 0:
            title = '[QA Bug][%s][%s]test suites(%s) cases all skipped(%d)' % (
            tbname, product_id, tst_name, skipped_cnt_cases)
        elif failed_cnt_cases > 0 and skipped_cnt_cases > 0:
            title = '[QA Bug][%s][%s]test suites(%s) failed %d cases, skipped %d cases' % (
            tbname, product_id, tst_name, failed_cnt_cases, skipped_cnt_cases)
        elif failed_cnt_cases > 0 and skipped_cnt_cases == 0:
            title = '[QA Bug][%s][%s]test suites(%s) cases failed(%d)' % (
            tbname, product_id, tst_name, failed_cnt_cases)
        elif failed_cnt_cases == 0 and skipped_cnt_cases > 0:
            title = '[QA Bug][%s][%s]test suites(%s) cases skipped(%d)' % (
            tbname, product_id, tst_name, skipped_cnt_cases)
        else:
            pass

        # descption
        # DUT_PRODUCT_TYPE :
        # DUT_MODEL_NAME :
        # DUT_SN :
        # DUT_FW :
        #
        # Log path :
        # ####################
        # xxx.tst(20)
        # FAILED(2)
        # 0005 case1.xml
        # 0009 case2.xml
        # SKIPPED(1)
        # 0005 case3.xml
        #
        desp = ''
        desp += ('AT_TAG            : ' + self._cfg.get('AT_TAG', 'UNKNOWN') + '\n')
        desp += ('DUT_PRODUCT_TYPE  : ' + self._cfg.get('DUT_PRODUCT_TYPE', 'UNKNOWN') + '\n')
        desp += ('DUT_MODEL_NAME    : ' + self._cfg.get('DUT_MODEL_NAME', 'UNKNOWN') + '\n')
        desp += ('DUT_SN            : ' + self._cfg.get('DUT_SN', 'UNKNOWN') + '\n')
        desp += ('DUT_FW            : ' + self._cfg.get('DUT_FW', 'UNKNOWN') + '\n')
        desp += '\n'
        desp += ('Log path : ' + self._trpt['last_path'] + '\n')
        desp += '--------------\n'

        fmt = '\n'
        fmt += 'Test Suite Name : %s\n'
        fmt += 'Expected: %d, Executed: %d, Passed: %d, Failed: %d, Skipped: %d, Missed: %d\n'
        fmt += 'Total test time of the test suite   : %s \n'
        fmt += 'Average test time of the test suite : %s \n'
        fmt += '\n'

        s_dur = ('%02dH:%02dM:%02dS' % pp_duration(tst_spendtime))
        s_avg = ('%02dH:%02dM:%02dS' % pp_duration(tst_spendtime_avg))
        total = failed_cnt_cases + skipped_cnt_cases + passed_cnt_cases

        desp += fmt % (tst_name, total, total, passed_cnt_cases, failed_cnt_cases, skipped_cnt_cases, 0, s_dur, s_avg)

        desp += '--------------\n'
        if failed_cnt_cases > 0:
            desp += 'FAILED (%d)  \n' % (failed_cnt_cases)
            for case in cases_failed:
                desp += '\t%s %s' % (case['run_idx'], case['name'] + '\n')
        if skipped_cnt_cases > 0:
            desp += 'SKIPPED (%d)  \n' % (skipped_cnt_cases)
            for case in cases_skipped:
                desp += '\t%s %s' % (case['run_idx'], case['name'] + '\n')

        desp += '--------------\n'
        desp += 'Cases failed messages : \n'
        if failed_cnt_cases > 0:
            for case in cases_failed:
                desp += '%s %s' % (case['run_idx'], case['name'] + '\n')
                desp += 'Last Error : \n'
                desp += (case.get('last_error', '') + '\n')
                desp += 'Detail message : \n'
                desp += (case.get('error_detail', '') + '\n')
                desp += '======\n'


        # raw format in redmine
        desp = ('\n<pre>\n' + desp + '\n</pre>\n')
        # post issue
        self._cfg['TITLE'] = title
        self._cfg['DESP'] = desp

        # debug
        #print '\n---->\n',title
        #print '\n---->\n',desp
        #exit(0)

        self.updateIssueInfo(tst_name)
        rc = self.post_new_issue()
        #if rc :
        #    if len(self._trpt['tst_done']) :
        #        self._trpt['tst_done'] += ','
        #    self._trpt['tst_done'] += tst_name

        return rc


    def updateIssueInfo(self, tst_name):
        """
        update issue inforation from redmine rules
        """
        #update Assignee
        uid = None
        user = self._tst2user.get(tst_name)

        if user:
            uid = self._user2id.get(user)
            if not uid:
                uid = self._user2id.get('default')
        else:
            uid = self._user2id.get('default')

        if uid:
            self._cfg['AS'] = str(uid)
            self.info('Update Issue Assignee id : ' + str(uid))

        # update Parent
        pid = None
        dut = self._cfg.get('DUT_PRODUCT_TYPE', 'UNKNOWN')
        pid = self._dut2pid.get(dut)
        if not pid:
            pid = self._dut2pid.get('default')
        if pid:
            self._cfg['PID'] = str(pid)
            self.info('Update Issue parent id : ' + str(pid))


    def post_new_issue(self):
        """
        try post new issue to redmine, retry 3 times
        """
        #return True

        retry = 3
        delay = 10
        i = 0

        self._issues2rpt.append(self._cfg['TITLE'])
        while (i < retry):
            try:
                i += 1
                self.info('Try (' + str(i) + ') to add new issue to redmine : ' + self._cfg['TITLE'] + '\n')
                issue = self.do_post_new_issue(self._cfg)
                iid = issue['id']
                self.info('Added new issue to redmine : ' + str(iid) + ' : ' + self._cfg['TITLE'] + '\n')
                # log to file
                lpath = self._trpt['last_path']
                if os.path.exists(lpath):
                    msg = '"[%s] Add new issue for testsuite(%s) to redmine [%s] : %s "' % (
                    time.asctime(), self._cfg['TST_FULLPATH'], str(iid), self._cfg['TITLE'] )
                    os.system('echo ' + msg + ' >> ' + os.path.join(lpath, 'redmine_issues'))

                self.updateIssueInDB(iid, self._cfg['TITLE'])

                self._issues2rpt.pop()
                return True

                #break
            except Exception, e:
                self.error('Exception : ' + str(e))
                #traceback.print_exc()
                formatted_lines = traceback.format_exc().splitlines()
                self.error('Exception : ' + pformat(formatted_lines))
                self.error('Add new issue to redmine failed ! \n')
                time.sleep(delay)
            #
        return False

    def start(self):
        """
        start service
        """
        toExit = False
        while (not toExit):
            try:
                cmd = 'pgrep ATE'
                res = os.popen(cmd).read().strip()
                if 0 == len(res):
                    self.info('No ATE exist!')
                    #toExit = True

                self.loadcfg()
                self.check_test_result()
                self.savecfg()
                if 0 == self._trpt['cases_not_done']:
                    self.info('---> Now all cases done')
                    break
                else:
                    self.info('---> Case not done :' + str(self._trpt['cases_not_done']))
            except Exception, e:
                self.error('Exception : ' + str(e))
                #traceback.print_exc()
                formatted_lines = traceback.format_exc().splitlines()
                self.error('Exception : ' + pformat(formatted_lines))

            if toExit: break
            self.info('== Enter sleep interval ' + str(self._cfg['TIMER']))

            delay = self._cfg['TIMER']
            #print '--->',type(delay)
            if type(delay) is StringType:
                delay = int(delay)
            nSeg = 30
            while (delay > 0):
                self.info('\n===> [%s] %d seconds away from next checking ...\n' % (time.asctime(), delay ))
                os.system('sync')
                if delay > nSeg:
                    time.sleep(nSeg)
                    delay -= nSeg
                else:
                    time.sleep(delay)
                    delay = 0


    def fillCaseDetail(self, case):
        """
        """
        idx = case['run_idx']
        tp = case['type']
        st = case['status']
        fn = os.path.join(self._trpt['last_path'], 'result.log')

        cmd = "sed -n '/^\[%s\] %s %s/,/^----/p' %s " % (idx, tp, st, fn )
        ss = os.popen(cmd).read().strip()
        #print '==> CaseDetail :\n',ss

        prop = {}
        lines = ss.splitlines()

        next_is_last_error = False
        next_is_error_detail = False

        case['last_error'] = ''
        case['error_detail'] = ''

        for line in lines:
            if line.startswith('Last Error'):
                next_is_last_error = True
                continue
            elif line.startswith('error message details'):
                next_is_error_detail = True
                next_is_last_error = False
                continue
            elif line.startswith('------'):
                break
            elif line.startswith('######'):
                break

            if 0 == len(line.strip()):
                continue

            if next_is_last_error:
                case['last_error'] += (line + '\n')
            elif next_is_error_detail:
                case['error_detail'] += (line + '\n')
            else:
                m = r'([^:]*)\s*:\s*(.*)'
                res = re.findall(m, line)
                if len(res):
                    k, v = res[0]
                    prop[k.strip()] = v.strip()

        #pprint(prop)
        #
        tm = prop.get('Duration')
        if tm:
            try:
                tm = float(tm)
            except:
                tm = 0
            case['duration'] = tm

        #case['last_error'] = prop.get('Last Error')
        #case['error_detail'] = prop.get('error message details')
        case['start_time'] = prop.get('Start time')

        #if case['status'] == 'FAILED' :
        #    pprint(case)
        #    exit(1)


    def do_post_new_issue(self, Xhash):
        """
        This function is to post a new issue to redmine
        All parameters required are all saved in the input parameter Xhash, a hash variable
        """

        title = str(Xhash['TITLE'])
        description = str(Xhash['DESP'])

        self.info('---------------')
        self.info('PROJ      : ' + Xhash['PROJ'])
        self.info('URL       : ' + Xhash['RM_URL'])
        self.info('RM_KEY    : ' + Xhash['RM_KEY'])
        self.info('TITLE     : ' + title)
        #self.info('DESCPTION : ' + description)

        #exit(1)
        # Open project
        demo = redmine.Redmine(Xhash['RM_URL'], key=Xhash['RM_KEY'])
        project = demo.getProject(Xhash['PROJ'])


        # Add new issue
        xdata = {
            'fixed_version_id': str(Xhash['VID']),
            'tracker_id': str(Xhash['TID']),
            'assigned_to_id': str(Xhash['AS']),
            'estimated_hours': '1.0',
            'ignore_estimated_hours_conflict': '1',
            'parent_issue_id': str(Xhash['PID']),
        }

        self.info('Hash table for issue : ' + pformat(xdata))
        #issue = demo.getIssue(15412)
        issue = project.newIssue(title, description, Xdata=xdata)
        #issue_id = issue['id']
        #pprint(issue)
        return issue

    def updateIssueInDB(self, iid, title):
        """
        """
        TUID = os.getenv('G_AT_UUID', '')
        if not TUID:
            self.info('G_AT_UUID is not defined, ignore to report to DB')
            return

        tst_name = self._cfg['TST_FULLPATH']
        sqls = []
        for case in self._cases:
            if tst_name == case['tsuite'] and 'TCASE' == case['type']:
                st = case['status']
                if st in ['FAILED', 'SKIPPED']:
                    caseFullName = case['fullpath']
                    sets = ''
                    sets += (" %s='%s'," % ('AgileIssueID', iid) )
                    sets += (" %s='%s' " % ('AgileIssueTitle', title) )

                    sql = "UPDATE records SET %s WHERE TUID='%s' AND CaseFullName='%s'; " % (sets, TUID, caseFullName)
                    sqls.append(sql)
                    pass

        if len(sqls):
            cmd = 'dbus-launch at_db_agent.py -c '
            for sql in sqls:
                cmd += ('-v "%s" ' % (sql) )

            os.system(cmd)
            self.info('==>' + cmd)


def do_job(opts):
    """
    """
    cfg = {}
    excludes = ['read_file', 'read_module', 'ensure_value']
    for k in dir(opts):
        if k.startswith('_') or k in excludes:
            continue
            #
        v = getattr(opts, k)
        cfg[k] = v

    atar = ATE_AUTO_REDMINE(cfg)
    atar.start()


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ("\nGet more info with command : pydoc " + os.path.abspath(__file__) + "\n")
    parser = OptionParser(usage=usage)

    parser.add_option("--timer_check", dest="TIMER", type="int",
                      help="the inverval to check result")

    parser.add_option("--rulefile", dest="AS_RULE_FILE",
                      help="The rule file")
    parser.add_option("-d", "--destination", dest="DEST_PATH",
                      help="Destination log path to parse")

    group = OptionGroup(parser, "Issue report type", "Define the type to report issue(bug)")

    group.add_option("--per_case", dest="PER_CASE", action="store_true", default=False,
                     help="one case one bug")
    #group.add_option("--per_suite", dest="per_suite", action="store_true", default=True,
    #                        help="on suite one bug, the default type")
    group.add_option("--with_ncase", dest="WITH_NACSE", action="store_true", default=False,
                     help="report bug if ncase failed")
    #group.add_option("--without_ncase", dest="without_ncase", action="store_true", default=True,
    #                        help="not report bug if ncase failed,the default type ")

    parser.add_option_group(group)

    group = OptionGroup(parser, "Issue elements", "Define the elements for the issue report")

    group.add_option("--tbname", dest="TBNAME", default="TB_UNKNOWN",
                     help="Test bed name")
    group.add_option("--Issue_parent", dest="PID", default="",
                     help="parent issue id")

    group.add_option("--issue_assignee", dest="AS", default="",
                     help="the assignee of the issue")
    group.add_option("--issue_tracker", dest="TID", #default="QA Bug",
                     help="Track id ,default is 13 , QA Bug")
    group.add_option("--issue_version", dest="VID", #default="AT Bug List",
                     help="version id, default is AT Bug List")
    group.add_option("--issue_project", dest="PROJ", #default="automation-test",
                     help="project id, default is automation-test")

    parser.add_option_group(group)

    group = OptionGroup(parser, "Redmine parameters", "Custom the parameters for redmine")

    group.add_option("--redmine_url", dest="RM_URL", default="",
                     help="redmine url")
    group.add_option("--redmine_username", dest="RM_USR", default="",
                     help="redmine login user")

    group.add_option("--redmine_password", dest="RM_PWD", default="",
                     help="redmine login password")

    group.add_option("--redmine_key", dest="RM_KEY", default="",
                     help="redmine login key without plaintext of username/password")

    parser.add_option_group(group)

    (options, args) = parser.parse_args()


    # output the options list
    print '==' * 32
    print 'Options :'
    excludes = ['read_file', 'read_module', 'ensure_value']
    for k in dir(options):
        if k.startswith('_') or k in excludes:
            continue
            #
        v = getattr(options, k)
        print k, ':', v

    return options
    #------------------------------------------------------------------------------


def check_uniq():
    """
    """
    pid = os.getpid()
    opid = 0
    # Get pid from pid file
    f_pid = '/var/run/at_redmine.pid'
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
            syslog.syslog(syslog.LOG_ERR, 'at_redmine is already in running! the pid is ' + str(opid))
            exit(99)

    # Update the new pid
    print 'Update the latest pid : ' + str(pid)
    os.system('echo ' + str(pid) + ' >' + f_pid)
    return True


def main():
    """
    main entry
    """
    opts = parseCommandLine()
    syslog.openlog('at_redmine', syslog.LOG_PID | syslog.LOG_PERROR)
    check_uniq()
    syslog.syslog('at_redmine instance created!')

    do_job(opts)

    syslog.syslog('at_redmine instance finished!')
    exit(0)


if __name__ == '__main__':
    """
    """

    main()
