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


def pp_duration(dur):
    """
    """
    dur = str(dur)

    nDur = int(float(dur))
    nHour = int(nDur) / 3600
    nMin = (int(nDur) - nHour * 3600) / 60
    nSec = int(nDur) % 60
    #nMilSec = (int) ((float(dur) - nDur) * 1000)
    #print '==nMilSec',nMilSec
    #return (nHour, nMin, nSec, nMilSec)
    return (nHour, nMin, nSec)


def asctime2datetime(asctime):
    """
    """
    t = None
    try:
        t = datetime.strptime(asctime, '%a %b %d %H:%M:%S %Y')
    except:
        pass
    return t


def diffDatetimeSecs(a, b):
    """
    """
    t = None
    try:
        t = (a - b).total_seconds()
    except:
        pass
    return t


class TestResultsParser():
    """
    _case = {
    'idx' : '',
    'run_idx' : '',
    'name' : '',
    'tsuite' : '',
    'fullpath' : '',
    'status' : '',
    'type' : '',
    'redmine_issue_id' : '',

    'duration' : '',
    'starttime' : '',
    'last_error' : '',
    'error_detail' : '',

    'description' : '',
    'logpath' : '',
    'casepath' : '',
    }

    """

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
    _tst2est = {}

    def __init__(self):
        """
        """
        self._cases = []
        self._logger = None
        self._loghdlr = None
        self._cfg = {}
        self._tst2iid = {}
        self._tst2est = {}
        pass

    def prepare_log(self, path):
        """
        prepare the log
        """
        if not os.path.exists(path):
            #self._logfile = None
            return
            #path = '/root'
        logfile = os.path.join(path, 'rpt_html.log')
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

    def log(self, msg):
        """
        log log
        """
        print '==', msg
        if self._logger:
            self._logger.info(msg)


    def error(self, msg):
        """
        log error
        """
        print '==', msg
        if self._logger:
            self._logger.error(msg)

    def parse(self, logpath):
        """
        """
        if not os.path.exists(logpath):
            return False

        self.prepare_log(logpath)

        # Load from files
        fn_env = os.path.join(logpath, 'runtime_env')
        fn_cases = os.path.join(logpath, 'cases.rpt')
        fn_result = os.path.join(logpath, 'result.log')
        fn_redmine = os.path.join(logpath, 'redmine_issues')

        # Load issues first
        self.loadEnv(fn_env)
        self.loadRedmineIssuesFromFile(fn_redmine)
        # Load cases info
        self.loadCasesListFromFile(fn_cases)
        self.loadCaseReultsFromFile(fn_result)
        #
        self.loadTstEstimateFile()

    def loadEnv(self, fn):
        """
        """
        #os.system('cat ' + fn)
        #exit(0)
        if not os.path.exists(fn):
            self.error("File not exist : " + fn)
            return False

        lines = []
        try:
            fd = open(fn, 'r')
            if fd:
                lines = fd.readlines()
                fd.close()
                #
            ate_pid = 0
            for line in lines:
                # export G_BINVERSION="2.0"
                m = r'export\s*(\w*)\s*=\s*(.*)'
                res = re.findall(m, line)
                if len(res):
                    k, v = res[0]
                    if v.startswith('"') and v.endswith('"'):
                        v = v[1:-1]

                    if len(k):
                        self._cfg[k] = v
                        print '---->Load Env :', k, v
        except Exception, e:
            self.error('Exception : ' + str(e))
            #traceback.print_exc()
            formatted_lines = traceback.format_exc().splitlines()
            self.error('Exception : ' + pformat(formatted_lines))
            exit(0)

    def loadCasesListFromFile(self, fn):
        """
        """
        rpt_file = fn
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


    def loadCaseReultsFromFile(self, fn):
        """
        """
        res_file = fn
        lines = []
        if not os.path.exists(res_file):
            return False
        try:
            fd = open(res_file, 'r')
            if fd:
                lines = fd.readlines()
                fd.close()
                #
            next_is_last_error = False
            next_is_error_detail = False

            case = None
            idx = 0
            for line in lines:
                #
                # [0015] NCASE PASSED B-GEN-ENV.PRE-DUT.DEFVAR-001.xml

                if not case:
                    m = r'^\[(\d*)\]\s*([NT]CASE)\s*(\w*)\s*(.*)'
                    res = re.findall(m, line)
                    if len(res):
                        idx += 1
                        (run_idx, tp, st, case_name) = res[0]
                        case = self.findCase(run_idx, case_name)
                        if not case:
                            #continue
                            case = self.findCaseByIdx(idx, case_name)
                        if not case:
                            #print '===>',res[0],idx
                            #exit(1)
                            continue

                        case['status'] = st
                        case['type'] = tp
                        next_is_last_error = False
                        next_is_error_detail = False
                        continue

                if line.startswith('Last Error'):
                    next_is_last_error = True
                    continue
                elif line.startswith('error message details'):
                    next_is_error_detail = True
                    next_is_last_error = False
                    continue
                elif line.startswith('------'):
                    if case:
                        #if case['run_idx'] == '0059' :
                        #    print case
                        #    exit(0)
                        pass
                    case = None
                    continue
                elif line.startswith('######'):
                    if case:
                        #if case['run_idx'] == '0059' :
                        #    print case
                        #    exit(0)
                        pass
                    case = None
                    continue

                #if 0 == len(line.strip()) :
                #    continue

                if not case: continue

                if next_is_last_error:
                    case['last_error'] += (line + '\n')
                elif next_is_error_detail:
                    case['error_detail'] += (line + '\n')
                else:
                    m = r'([^:]*)\s*:\s*(.*)'
                    res = re.findall(m, line)
                    if len(res):
                        k, v = res[0]
                        k = k.strip()
                        if k == 'Description':
                            case['description'] = v

                        elif k == 'Log Path':
                            case['logpath'] = v

                        elif k == 'Duration':
                            case['duration'] = v
                        elif k == 'Start time':
                            case['starttime'] = v
                        elif k == 'Testcase Path':
                            case['casepath'] = v

        except Exception, e:
            self.error('Exception : ' + str(e))
            #traceback.print_exc()
            formatted_lines = traceback.format_exc().splitlines()
            self.error('Exception : ' + pformat(formatted_lines))
            #exit(1)


            #case = self.findCaseByRunIndx('0005')
            #pprint(self._cases)
            #exit(1)

    def loadRedmineIssuesFromFile(self, fn):
        """
        """
        try:
            # Load issues reported
            self._tst2iid = {}

            if os.path.exists(fn):
                print '==', 'Load cfg file :', fn
                fd = open(fn, 'r')
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


        except Exception, e:
            self.error('Exception : ' + str(e))
            #traceback.print_exc()
            formatted_lines = traceback.format_exc().splitlines()
            self.error('Exception : ' + pformat(formatted_lines))

        pprint(self._tst2iid)
        #exit(1)


    def updateCaseStatus(self, idx, run_idx, st, tp, case_fullpath):
        """
        Update the test case status
        """
        #print "==","Enter updateCaseStatus"
        dpath = os.path.dirname(case_fullpath)
        case_name = os.path.basename(case_fullpath)
        tst_name = dpath[:dpath.rfind(':')]

        iid = ''
        if st == 'FAILED' or st == 'SKIPPED':
            iid = self._tst2iid.get(tst_name, '')
            #print tst_name,iid

        #if len(iid) :
        #    print('Redmine issue id : ' + iid)
        #    #exit(1)

        case = deepcopy(self._case)
        case['idx'] = idx
        case['run_idx'] = run_idx
        case['name'] = case_name
        case['tsuite'] = tst_name
        case['fullpath'] = case_fullpath
        case['status'] = st
        case['type'] = tp

        case['redmine_issue_id'] = iid

        #self.fillCaseDetail(case)

        self._cases.append(case)
        #pprint(case)

    def findCase(self, idx, casename):
        """
        """
        for case in self._cases:
            if case['run_idx'] == idx:
                if case['name'] == casename:
                    return case
                else:
                    pass
                    #print '||||',idx,casename,case
                    #exit(1)

        return None

    def findCaseByIdx(self, idx, casename):
        """
        """
        for case in self._cases:
            if case['idx'] == ('%04d') % idx:
                #print '!!',case
                return case

        return None


    def getAllData(self):
        """
        """
        return self._cfg, self._cases

    def loadTstEstimateFile(self, fn=None):
        """
        """
        if not fn:
            fn = '/root/automation/testsuites/2.0/common/tst_estimate.cfg'

        if not os.path.exists(fn):
            return

        #
        # tst_estt = {
        # 'default' : 0,
        # 'wi_sec_ssid1.tst' : 300,
        # 'wi_sec_ssid1.tst:WECB' : 120,
        # 'wi_sec_ssid1.tst:TV2KH:31.122L.01' : 500,
        #}

        tst_estimate = {}

        lines = []
        fd = open(fn, 'r+')
        if fd:
            lines = fd.readlines()
            fd.close()

        #
        m = r'-E\s*([^\s]*)\s*:\s*(\d*):(\d*):(\d*)'
        for line in lines:
            sz = line.strip()
            if sz.startswith('#'):
                continue
            elif 0 == len(sz):
                continue
            else:
                res = re.findall(m, sz)
                if len(res):
                    tstname, hh, mm, ss = res[0]
                    #print res[0]
                    try:
                        tst_estimate[tstname] = int(hh) * 3600 + int(mm) * 60 + int(ss)
                    except:
                        pass


        #
        self._cfg['_tst2est_'] = tst_estimate
        #pprint(tst_estimate)
        #exit(1)


from pyh import *


class HTMLPageCreator():
    """
    """
    _cfg = {}
    _cases = []
    _suites = {}
    _tst = {
        'name': '',
        'tcase_total': 0,
        'tcase_pass': 0,
        'tcase_fail': 0,
        'tcase_skip': 0,
        'tcase_todo': 0,
        'dt_start': None,
        'dt_end': None,
        'duration': None,
        'duration_avg': None,
        'bugs': [],
    }
    _page = None

    _tbInfo = {}
    _testInfo = {}

    _dur_fmt = '%02dH:%02dM:%02dS'

    def __init__(self, project='Automation Test'):
        """
        """
        self._cfg = {}
        self._cases = []
        self._page = None

        self._tbInfo = {}
        self._testInfo = {}

        self._page = PyH('%s test report' % project)
        self._page << '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'

        self._dur_fmt = '%02d:%02d:%02d'

    def prepare_log(self, path):
        """
        prepare the log
        """
        if not os.path.exists(path):
            #self._logfile = None
            return
            #path = '/root'
        logfile = os.path.join(path, 'rpt_html.log')
        #
        print '--> setup log :', logfile
        if not self._logger:
            self._logger = logging.getLogger('RPT_HTML.SYS')

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

    def log(self, msg):
        """
        log log
        """
        if self._logger:
            self._logger.info(msg)


    def error(self, msg):
        """
        log error
        """
        if self._logger:
            self._logger.error(msg)


    def importDatas(self, env, cases):
        """
        """
        self._cfg = env
        self._cases = cases

        #
        self.reviseCases()
        self.reviseSuites()
        #
        self.adjustEnv()
        # combine testinfo
        self._testInfo = self.cmb_testInfo()
        # combine tbinfo
        self._tbInfo = self.cmb_tbInfo()


    def adjustEnv(self):
        """
        """
        # Copy Env
        # From Key to newKey, value is the same
        cpEnvs = {}
        cpEnvs['AT_TAG'] = 'AT_SW_VER'

        cpEnvs['G_AT_TAGS'] = 'TEST_TYPE'

        cpEnvs['U_DUT_TYPE'] = 'DUT_PRODUCT_TYPE'
        cpEnvs['U_DUT_MODELNAME'] = 'DUT_MODEL_NAME'
        cpEnvs['U_DUT_HW'] = 'DUT_HW'
        cpEnvs['U_DUT_SW_VERSION'] = 'DUT_FW'

        cpEnvs['U_DUT_SN'] = 'DUT_SN'
        #cpEnvs['DUT_POST_FILES_VER'] = 'U_DUT_TYPE'
        #cpEnvs['DUT_FW'] = 'AT_SW_VER'





        for (k, nk) in cpEnvs.items():
            if self._cfg.get(k, None):
                self._cfg[nk] = self._cfg.get(k, None)

        self._cfg['DUT_POST_FILES_VER'] = self._cfg.get('U_DUT_TYPE', 'UNKNOWN') + '_' + self._cfg.get(
            'U_DUT_FW_VERSION', 'UNKNOWN')


        #
        if not self._cfg.get('TEST_TYPE', None):
            self._cfg['TEST_TYPE'] = 'full'

    def cmb_tbInfo(self):
        """
        """
        tbInfo = {}
        tbInfo['groups'] = []
        #
        title = 'DUT Information'
        tbInfo['groups'].append(title)
        tbInfo[title] = {}
        keys = []
        keys.append('DUT_PRODUCT_TYPE')
        keys.append('DUT_MODEL_NAME')
        #keys.append('DUT_HW')
        keys.append('TEST_TYPE')
        keys.append('DUT_FW')
        keys.append('DUT_SN')
        keys.append('DUT_POST_FILES_VER')

        tbInfo[title]['keys'] = keys
        for key in keys:
            tbInfo[title][key] = self._cfg.get(key, 'UNKNOWN')

        #
        title = 'Testbed Information'
        tbInfo['groups'].append(title)
        tbInfo[title] = {}
        keys = []
        keys.append('AT_SW_VER')
        keys.append('G_TBNAME')
        keys.append('G_TESTER')

        tbInfo[title]['keys'] = keys
        for key in keys:
            tbInfo[title][key] = self._cfg.get(key, 'UNKNOWN')
            #
        title = 'Time Information'
        tbInfo['groups'].append(title)
        tbInfo[title] = {}
        keys = []
        keys.append('TEST_BEGIN')
        if self._cfg.get('TEST_END', None):
            keys.append('TEST_END')
        else:
            keys.append('REPORT_TIME')
        keys.append('DURATION')

        tbInfo[title]['keys'] = keys
        for key in keys:
            tbInfo[title][key] = self._cfg.get(key, 'UNKNOWN')

        return tbInfo

    def reviseCases(self):
        """
        """
        cases = self._cases
        # add dt_start, dt_end
        for case in cases:
            dt_start = None
            dt_end = None
            if case['starttime'] and not 'None' == case['starttime']:
                dt_start = asctime2datetime(case['starttime'])
                secs = float(case['duration'])
                delta = timedelta(seconds=secs)
                dt = dt_start + delta
                str_dt = dt.strftime('%a %b %d %H:%M:%S %Y')
                dt_end = asctime2datetime(str_dt)

            case['dt_start'] = dt_start
            case['dt_end'] = dt_end

    def reviseSuites(self):
        """
        we only process the tst in run.cfg
        """
        self._suites = {}
        self._suites['_TST_ORDER'] = []
        cases = self._cases
        cfgs = self._cfg
        # add dt_start, dt_end
        #
        cfgs['DURATION'] = ''
        cfgs['TEST_BEGIN'] = ''
        cfgs['TEST_END'] = ''
        cfgs['REPORT_TIME'] = ''
        cfgs['TCASE_AVG'] = 0

        test_done = True
        total_tcase_done = 0
        dt_start = None
        for case in cases:
            #pprint(case)
            if case['status'] == 'checked':
                test_done = False

            tst_name = case['tsuite']
            tst = None

            # find tst
            # run.cfg:45/WAN_eth_untagged_static.tst:6/pre_swap_eth_static.tst
            # we only select the 2 level path from run.cfg
            z = tst_name.split('/')
            if case['dt_start']:
                if not dt_start:
                    dt_start = case['dt_start']
                    if not cfgs['TEST_BEGIN']:
                        cfgs['TEST_BEGIN'] = dt_start
                    if not cfgs['REPORT_TIME'] and case['dt_end']:
                        cfgs['REPORT_TIME'] = case['dt_end']

            if len(z) < 2:
                continue
            else:
                #tst_name = '/'.join(z[:2])
                #tst_name = tst_name[:tst_name.rfind(':')]
                p = tst_name.find('.tst')
                if p > 0:
                    p2 = tst_name.find('.tst', p + 4)
                    if p2 > 0:
                        tst_name = tst_name[:p2 + 4]
                        pass
                    else:
                        tst_name = tst_name[:p + 4]

            #print tst_name
            if tst_name not in self._suites['_TST_ORDER']:
                self._suites['_TST_ORDER'].append(tst_name)
                tst = deepcopy(self._tst)
                self._suites[tst_name] = tst
            else:
                tst = self._suites[tst_name]

            #print '--------->',case['fullpath'],tst_name,tst
            if not tst: continue

            # name
            tst['name'] = os.path.basename(tst_name)

            # dt
            if not tst['dt_start']:
                tst['dt_start'] = dt_start
                tst['dt_end'] = dt_start

            if case['dt_end']:
                #print '--->',case['dt_end']
                tst['dt_end'] = case['dt_end']
                dt_start = tst['dt_end']
                #if not cfgs['REPORT_TIME'] :
                cfgs['REPORT_TIME'] = case['dt_end']

            # sum
            if 'TCASE' == case['type']:
                st = case['status']
                tst['tcase_total'] += 1
                if 'PASSED' == st:
                    tst['tcase_pass'] += 1
                    total_tcase_done += 1
                elif 'FAILED' == st:
                    tst['tcase_fail'] += 1
                    total_tcase_done += 1
                elif 'SKIPPED' == st:
                    tst['tcase_skip'] += 1
                elif 'checked' == st:
                    tst['tcase_todo'] += 1
                # bugs
            if case['redmine_issue_id'] not in tst['bugs']:
                tst['bugs'].append(case['redmine_issue_id'])
                # dt
            tst['duration'] = tst['dt_end'] - tst['dt_start']
            tst['duration_avg'] = tst['duration']
            cases_done = tst['tcase_pass'] + tst['tcase_fail']
            if cases_done > 0:
                tst['duration_avg'] = tst['duration'] / cases_done

        if test_done:
            cfgs['TEST_END'] = cfgs['REPORT_TIME']
        else:
            pass

        #
        print '%s | %s ' % (cfgs['REPORT_TIME'], cfgs['TEST_BEGIN'])
        cfgs['DURATION'] = cfgs['REPORT_TIME'] - cfgs['TEST_BEGIN']

        #exit(1)
        tot_dur = cfgs['DURATION']
        tcase_avg = tot_dur
        if total_tcase_done > 0:
            tcase_avg = tcase_avg / total_tcase_done

        cfgs['TCASE_AVG'] = tcase_avg

        #pprint(self._suites)
        #exit(1)

    def getAvgEstimateByTstname(self, tstname):
        """
        """
        avg_time = 0

        if self._cfg.has_key('_tst2est_'):
            tst2est = self._cfg['_tst2est_']
            if isinstance(tst2est, dict):
                # 1. first to get default
                avg_time = tst2est.get('default', 600)
                product_id = self._cfg.get('U_DUT_TYPE')
                sw_version = self._cfg.get('U_DUT_SW_VERSION')
                # 2. get tst without product id and sw version
                avg_time = tst2est.get(tstname, avg_time)
                # 3. get tst with product
                if product_id:
                    avg_time = tst2est.get(('%s:%s') % (tstname, product_id), avg_time)
                    if sw_version:
                        avg_time = tst2est.get(('%s:%s:%s') % (tstname, product_id, sw_version), avg_time)
            #
        if not avg_time:
            avg_time = cfgs.get('TCASE_AVG', 600)

        return timedelta(seconds=avg_time)


    def cmb_testInfo(self):
        """
        """
        #
        cfgs = self._cfg
        testInfo = {}
        testInfo['groups'] = []

        #
        tcase_avg = cfgs['TCASE_AVG']

        group_tested = None
        group_inqueue = None
        #
        gname = 'SuitesTested'
        testInfo['groups'].append(gname)
        testInfo[gname] = {}

        group = testInfo[gname]
        group['title_cols'] = ['Index', 'SuiteTested', 'Cases', 'Pass', 'Fail', 'Skip', 'BugID', 'TotalTime', 'AvgTime']
        group['title_vals'] = {}
        for k in group['title_cols']: group['title_vals'][k] = k
        group['title_vals']['SuiteTested'] = 'Suite Tested'

        group['keys'] = []
        group['total'] = {}
        group_tested = group
        #
        gname = 'SuitesInQueue'
        testInfo['groups'].append(gname)
        testInfo[gname] = {}
        group = testInfo[gname]

        group['title_cols'] = ['Index', 'SuiteInQueue', 'Cases', 'Pass', 'Fail', 'Skip', 'BugID', 'TotalTime',
                               'AvgTime']
        group['title_vals'] = {}

        for k in group['title_cols']: group['title_vals'][k] = k
        #group['title_vals']['Index'] = 'Index'
        group['title_vals']['SuiteInQueue'] = 'Suite In Queue'
        group['title_vals']['TotalTime'] = 'TotalTime(Estimate)'

        group['keys'] = []
        group['total'] = {}
        group_inqueue = group

        #self._suites = {}
        dt_start = None
        done_idx = 0
        todo_idx = 0
        total_tc_done = 0
        total_tc_pass = 0
        total_tc_fail = 0
        total_tc_skip = 0
        total_tc_todo = 0
        total_tc_todo2 = 0
        total_est_time = timedelta()

        for tst_name in self._suites['_TST_ORDER']:
            tst = self._suites.get(tst_name)
            if not tst: continue

            if not dt_start:
                dt_start = tst['dt_start']

            if 0 == tst['tcase_total']: # precondition tst
                continue

            if tst['tcase_todo'] == tst['tcase_total']: # all in queue
                group_inqueue['keys'].append(tst_name)
                group_inqueue[tst_name] = {}

                gt = group_inqueue[tst_name]

                todo_idx += 1

                est_time = 0
                tcase_avg = self.getAvgEstimateByTstname(os.path.basename(tst_name))
                if tcase_avg:
                    est_time = tcase_avg * tst['tcase_todo']

                total_est_time += est_time
                #est_time = ( )
                print('Estimate time : %s  for tst [%s]' % (str(est_time), tst_name) )

                #s_dur = ('%02dH:%02dM:%02dS' % pp_duration(est_time))
                s_dur = (self._dur_fmt % pp_duration(est_time.total_seconds()))

                #total_time_est += est_time
                #print tst_name,n_tc_done,n_tc_todo
                gt['Index'] = todo_idx
                gt['SuiteInQueue'] = os.path.basename(tst_name)
                gt['Cases'] = tst['tcase_total']
                gt['Pass'] = ''
                gt['Fail'] = ''
                gt['Skip'] = ''
                gt['BugID'] = ''
                gt['TotalTime'] = s_dur
                gt['AvgTime'] = ''

                total_tc_todo2 += tst['tcase_total']
            else:
                # add record
                group_tested['keys'].append(tst_name)
                group_tested[tst_name] = {}

                gt = group_tested[tst_name]
                # calc cols
                done_idx += 1

                gt['Index'] = done_idx
                gt['SuiteTested'] = os.path.basename(tst_name)
                gt['Cases'] = tst['tcase_total']
                gt['Pass'] = tst['tcase_pass']
                gt['Fail'] = tst['tcase_fail']
                gt['Skip'] = tst['tcase_skip']
                #
                total_tc_done += gt['Cases'] - tst['tcase_todo']
                total_tc_pass += gt['Pass']
                total_tc_fail += gt['Fail']
                total_tc_skip += gt['Skip']
                total_tc_todo += tst['tcase_todo']
                #print '2-->',total_tc_pass
                #print '2-->',n_tc_done + n_tc_todo

                #gt['BugID'] = ','.join(tst['issues'])
                gt['BugID'] = ''
                for iid in tst['bugs']:
                    #
                    #'<a href="http://dfasdf" target="_blank">abc</a>'
                    if not len(iid): continue
                    base_url = 'http://192.168.20.105/redmine'
                    slink = '<a href="' + (base_url + '/issues/' + iid) + '" target="_blank">' + ('#' + iid) + '</a>'
                    if len(gt['BugID']):
                        gt['BugID'] += '<br>'
                    gt['BugID'] += slink


                #

                #s_dur = ('%02dH:%02dM:%02dS' % pp_duration(dur))
                #avg = 0
                #if n_tc_done > 0 :
                #    avg = dur/n_tc_done
                #s_avg = ('%02dH:%02dM:%02dS' % pp_duration(avg))
                #print s_dur
                #print s_avg
                #exit(1)
                dur = tst['dt_end'] - dt_start
                dt_start = tst['dt_end']
                avg = dur
                cases_done = tst['tcase_pass'] + tst['tcase_fail']
                if cases_done > 0:
                    avg = dur / cases_done
                    #avg.microseconds = 0
                s_dur = (self._dur_fmt % pp_duration(dur.total_seconds()))
                s_avg = (self._dur_fmt % pp_duration(avg.total_seconds()))

                # testsuite in testing
                if tst['tcase_todo'] > 0:
                    tcase_avg = self.getAvgEstimateByTstname(os.path.basename(tst_name))
                    dt_left = tcase_avg * tst['tcase_todo']
                    s_dur += ( '(%s)' % (self._dur_fmt % pp_duration(dt_left.total_seconds())) )

                gt['TotalTime'] = s_dur
                gt['AvgTime'] = s_avg

        # tested total
        gt = group_tested['total']
        gt['Index'] = ''
        gt['SuiteTested'] = 'Total'
        gt['Cases'] = total_tc_done + total_tc_todo
        gt['Pass'] = total_tc_pass
        gt['Fail'] = total_tc_fail
        gt['Skip'] = total_tc_skip
        gt['BugID'] = ''
        #s_dur = ('%02dH:%02dM:%02dS' % pp_duration(total_time_done))
        #avg = 0
        #if total_tc_done > 0 :
        #    avg = total_time_done/total_tc_done
        #s_avg = ('%02dH:%02dM:%02dS' % pp_duration(avg))
        s_dur = cfgs['DURATION']
        s_avg = cfgs['TCASE_AVG']
        s_dur = (self._dur_fmt % pp_duration(s_dur.total_seconds()))
        s_avg = (self._dur_fmt % pp_duration(s_avg.total_seconds()))

        gt['TotalTime'] = s_dur
        gt['AvgTime'] = s_avg

        #print gt
        #exit(1)
        # todo total
        gt = group_inqueue['total']
        gt['Index'] = ''
        gt['SuiteInQueue'] = 'Total'
        gt['Cases'] = total_tc_todo2
        gt['Pass'] = ''
        gt['Fail'] = ''
        gt['Skip'] = ''
        gt['BugID'] = ''
        #s_dur = ('%02dH:%02dM:%02dS' % pp_duration(total_time_est))
        #s_dur = (total_tc_todo2 * cfgs['TCASE_AVG'])
        s_dur = total_est_time
        s_dur = (self._dur_fmt % pp_duration(s_dur.total_seconds()))
        gt['TotalTime'] = s_dur
        gt['AvgTime'] = ''

        #adjust title line
        gt = group_tested['title_vals']
        gt['SuiteTested'] = ('Suite Tested(' + str(done_idx) + ')')

        gt = group_inqueue['title_vals']
        gt['SuiteInQueue'] = ('Suite In Queue(' + str(todo_idx) + ')')
        gt['TotalTime'] = ('Estimate(' + s_dur + ')')
        if len(group_inqueue['keys']):
            gt['Cases'] = total_tc_todo2
            gt['Pass'] = ''
            gt['Fail'] = ''
            gt['Skip'] = ''
            gt['BugID'] = ''
            #s_dur = ('%02dH:%02dM:%02dS' % pp_duration(total_time_est))
            #s_dur = total_tc_todo2 * cfgs['TCASE_AVG']
            s_dur = total_est_time
            s_dur = (self._dur_fmt % pp_duration(s_dur.total_seconds()))
            #gt['TotalTime'] = 'Estimate : %s' % s_dur
            gt['TotalTime'] = s_dur
            gt['AvgTime'] = ''
            #
        return testInfo


    def cmb_testInfo2(self):
        """
        """
        cases = self._cases
        cfgs = self._cfg
        # We need to calc values
        cfgs['DURATION_SECONDS'] = 0
        cfgs['DURATION'] = ''
        cfgs['TEST_BEGIN'] = ''
        cfgs['TEST_END'] = ''
        cfgs['REPORT_TIME'] = ''

        #
        testInfo = {}
        testInfo['groups'] = []

        group_tested = None
        group_inqueue = None
        #
        gname = 'SuitesTested'
        testInfo['groups'].append(gname)
        testInfo[gname] = {}

        group = testInfo[gname]
        group['title_cols'] = ['Index', 'SuiteTested', 'Cases', 'Pass', 'Fail', 'Skip', 'BugID', 'TotalTime', 'AvgTime']
        group['title_vals'] = {}
        for k in group['title_cols']: group['title_vals'][k] = k
        group['title_vals']['SuiteTested'] = 'Suite Tested'

        group['keys'] = []
        group['total'] = {}
        group_tested = group
        #
        gname = 'SuitesInQueue'
        testInfo['groups'].append(gname)
        testInfo[gname] = {}
        group = testInfo[gname]

        group['title_cols'] = ['Index', 'SuiteInQueue', 'Cases', 'Pass', 'Fail', 'Skip', 'BugID', 'TotalTime',
                               'AvgTime']
        group['title_vals'] = {}

        for k in group['title_cols']: group['title_vals'][k] = k
        #group['title_vals']['Index'] = 'Index'
        group['title_vals']['SuiteInQueue'] = 'Suite In Queue'
        group['title_vals']['TotalTime'] = 'TotalTime(Estimate)'

        group['keys'] = []
        group['total'] = {}
        group_inqueue = group

        #parse cases
        starttime = None
        endtime = None
        # get time from env
        #cfgs['TEST_BEGIN'] = cfgs.get('G_TIME_AT_START','')
        #cfgs['TEST_END'] = cfgs.get('G_TIME_AT_END','')
        #cfgs['REPORT_TIME'] = cfgs.get('G_TIME_AT_LAST_UPDATE','')
        #cfgs['DURATION'] = cfgs.get('G_TIME_AT_TEST_DURATION',0)
        #cfgs['DURATION_SECONDS'] = 0


        # get time from cases
        lastCase = None
        lastDone = None
        if len(cases):
            #firstCase = cases[0]
            lastCase = cases[-1]
            for case in cases:
                if case['starttime'] and not 'None' == case['starttime']:
                    if not starttime:
                        starttime = asctime2datetime(case['starttime'])
                    lastDone = case
            #
        if lastDone:
        #try :
            # offset datetime
            str_dt = lastDone['starttime']
            print lastDone
            dt = datetime.strptime(str_dt, '%a %b %d %H:%M:%S %Y')
            secs = float(lastDone['duration'])
            delta = timedelta(seconds=secs)
            dt += delta
            str_dt = dt.strftime('%a %b %d %H:%M:%S %Y')
            endtime = asctime2datetime(str_dt)
            #except :
            #    pass

        # update TEST_BEGIN if not exist in env
        if not cfgs['TEST_BEGIN'] and starttime:
            cfgs['TEST_BEGIN'] = starttime.strftime('%a %b %d %H:%M:%S %Y')
        else:
            pass

        # check last

        if not cfgs['REPORT_TIME'] and endtime:
            #
            print '====update REPORT_TIME'
            cfgs['REPORT_TIME'] = endtime.strftime('%a %b %d %H:%M:%S %Y')
            print 'REPORT_TIME', cfgs['REPORT_TIME']

        if not 'checked' == lastCase['status']:
            print '====Done', endtime
            # last is done, means all done
            if not cfgs['TEST_END'] and endtime:
                # offset datetime
                cfgs['TEST_END'] = endtime.strftime('%a %b %d %H:%M:%S %Y')
                print 'TEST_END', cfgs['TEST_END']
                #exit(1)

        # calc duration
        if starttime and endtime:
            duration = diffDatetimeSecs(endtime, starttime)
            s_dur = ('%02dH:%02dM:%02dS' % pp_duration(duration))
            cfgs['DURATION'] = s_dur
            cfgs['DURATION_SECONDS'] = duration


        #print cfgs['TEST_BEGIN']
        #print cfgs['REPORT_TIME']
        #print cfgs['DURATION']
        #exit(0)

        _tst = {
            'tc_done': [],
            'tc_todo': [],
            'starttime': 0,
            'endtime': 0,
            'tpass': 0,
            'tfail': 0,
            'tskip': 0,
            'issues': [],
        }

        group = None
        all_tst = {}
        all_tst['TST_IDX'] = []
        tst = None

        last_starttime = None
        # tst collecting
        for case in cases:
            tst_name = case['tsuite']
            if not last_starttime and case['starttime'] and not 'None' == case['starttime']:
                last_starttime = case['starttime']
                #print tst_name
            if not tst_name in all_tst.keys():
                # record
                if tst and case['starttime'] and not 'None' == case['starttime']:
                    tst['endtime'] = case['starttime']
                    #
                all_tst['TST_IDX'].append(tst_name)

                #print '||add tst',tst_name
                #print all_tst['TST_IDX']

                all_tst[tst_name] = {}
                tst = all_tst[tst_name]
                tst['tc_done'] = []
                tst['tc_todo'] = []
                tst['tpass'] = 0
                tst['tfail'] = 0
                tst['tskip'] = 0
                tst['starttime'] = 0
                tst['endtime'] = 0
                tst['issues'] = []
                #
                if case['starttime'] and not 'None' == case['starttime']:
                    tst['starttime'] = case['starttime']
                    #tst['endtime'] = case['starttime']

            #else :
            if True:
                tst = all_tst[tst_name]

                str_dt = case['starttime']

                #print '----|',case
                if str_dt and not 'None' == str_dt:
                    #try :
                    #print '---->',case
                    dt = datetime.strptime(str_dt, '%a %b %d %H:%M:%S %Y')
                    secs = float(case['duration'])
                    delta = timedelta(seconds=secs)
                    dt += delta
                    str_dt = dt.strftime('%a %b %d %H:%M:%S %Y')
                    #except :
                    #    pass
                    tst['endtime'] = str_dt

                    #exit(1)
                else:

                    pass

            if 'TCASE' == case['type']:
                if 'checked' == case['status']:
                    tst['tc_todo'].append(case)
                else:
                    if 'PASSED' == case['status']:
                        tst['tpass'] += 1
                    elif 'FAILED' == case['status']:
                        tst['tfail'] += 1
                    elif 'SKIPPED' == case['status']:
                        tst['tskip'] += 1

                    tst['tc_done'].append(case)
                    iid = case['redmine_issue_id']
                    if iid and iid not in tst['issues']:
                        tst['issues'].append(iid)
                        #print tst['issues']
                        #exit(1)

        #print (all_tst['TST_IDX'])
        #exit(1)
        done_idx = 0
        todo_idx = 0
        total_tc_done = 0
        total_tc_todo = 0
        total_tc_todo2 = 0
        total_tc_pass = 0
        total_tc_fail = 0
        total_tc_skip = 0

        #total_ts_done = 0
        total_time_done = 0
        total_time_est = 0
        starttime = None
        tst = None
        for tst_name in all_tst['TST_IDX']:
            tst = all_tst.get(tst_name, None)
            if not tst: continue


            #
            if not starttime:
                starttime = tst['starttime']

            n_tc_done = len(tst['tc_done'])
            n_tc_todo = len(tst['tc_todo'])

            print '====', tst_name, n_tc_done, n_tc_todo, tst['endtime']

            #print tst
            #total_tc_todo += n_tc_todo
            total_tc_done += n_tc_done
            #print 'total_tc_todo',total_tc_todo
            #print 'total_tc_done',total_tc_done,tst_name,n_tc_done

            if n_tc_done == 0 and n_tc_todo == 0:
                pass
            elif n_tc_done > 0 and n_tc_todo == 0:
                # all done
                #total_ts_done += 1
                #group['title_cols'] = ['Index','SuiteTested','Cases','Pass','Fail','Skip','BugID','TotalTime','AvgTime']

                # add record
                group_tested['keys'].append(tst_name)
                group_tested[tst_name] = {}

                gt = group_tested[tst_name]
                # calc cols
                done_idx += 1

                gt['Index'] = done_idx
                gt['SuiteTested'] = os.path.basename(tst_name)
                gt['Cases'] = n_tc_done + n_tc_todo
                gt['Pass'] = tst['tpass']
                gt['Fail'] = tst['tfail']
                gt['Skip'] = tst['tskip']
                #
                total_tc_pass += gt['Pass']
                total_tc_fail += gt['Fail']
                total_tc_skip += gt['Skip']
                total_tc_todo += n_tc_todo
                #print '2-->',total_tc_pass
                #print '2-->',n_tc_done + n_tc_todo

                #gt['BugID'] = ','.join(tst['issues'])
                gt['BugID'] = ''
                for iid in tst['issues']:
                    #
                    #'<a href="http://dfasdf" target="_blank">abc</a>'
                    base_url = 'http://192.168.20.105/redmine'
                    slink = '<a href="' + (base_url + '/issues/' + iid) + '" target="_blank">' + ('#' + iid) + '</a>'
                    if len(gt['BugID']):
                        gt['BugID'] += '<br>'
                    gt['BugID'] += slink


                #
                endtime = tst['endtime']
                #print starttime ,endtime

                dur = 0
                if starttime and endtime:
                    dt_end = asctime2datetime(endtime)
                    dt_start = asctime2datetime(starttime)

                    dur = diffDatetimeSecs(dt_end, dt_start)

                print '---TST :', tst_name
                print 'starttime :', starttime
                print 'endtime :', endtime
                print dur

                total_time_done += dur

                starttime = None
                s_dur = ('%02dH:%02dM:%02dS' % pp_duration(dur))
                avg = 0
                if n_tc_done > 0:
                    avg = dur / n_tc_done
                s_avg = ('%02dH:%02dM:%02dS' % pp_duration(avg))
                #print s_dur
                #print s_avg
                #exit(1)

                gt['TotalTime'] = s_dur
                gt['AvgTime'] = s_avg

                #print gt
                #exit(1)


            elif n_tc_done > 0 and n_tc_todo > 0:
            # In testing
            #total_ts_done += 1
            #group['title_cols'] = ['Index','SuiteTested','Cases','Pass','Fail','Skip','BugID','TotalTime','AvgTime']

                # add record
                group_tested['keys'].append(tst_name)
                group_tested[tst_name] = {}

                gt = group_tested[tst_name]
                # calc cols
                done_idx += 1
                gt['Index'] = done_idx
                gt['SuiteTested'] = os.path.basename(tst_name)
                gt['Cases'] = n_tc_done + n_tc_todo
                gt['Pass'] = tst['tpass']
                gt['Fail'] = tst['tfail']
                gt['Skip'] = tst['tskip']
                #
                total_tc_pass += gt['Pass']
                total_tc_fail += gt['Fail']
                total_tc_skip += gt['Skip']
                total_tc_todo += n_tc_todo
                #print '1-->',total_tc_pass
                #print '1-->',n_tc_done + n_tc_todo

                #gt['BugID'] = ','.join(tst['issues'])
                gt['BugID'] = ''
                for iid in tst['issues']:
                    #
                    #'<a href="http://dfasdf" target="_blank">abc</a>'
                    base_url = 'http://192.168.20.105/redmine'
                    slink = '<a href="' + (base_url + '/issues/' + iid) + '" target="_blank">' + ('#' + iid) + '</a>'
                    if len(gt['BugID']):
                        gt['BugID'] += '<br>'
                    gt['BugID'] += slink


                #


                endtime = tst['endtime']

                dt_end = asctime2datetime(endtime)
                dt_start = asctime2datetime(starttime)


                #print '------>873'
                #print tst_name
                #print starttime ,dt_start
                #print endtime,dt_end


                if starttime and endtime:
                    dur = diffDatetimeSecs(dt_end, dt_start)
                    total_time_done += dur

                    s_dur = ('%02dH:%02dM:%02dS' % pp_duration(dur))
                    avg = 0
                    if n_tc_done > 0:
                        avg = dur / n_tc_done
                    s_avg = ('%02dH:%02dM:%02dS' % pp_duration(avg))

                else:
                    print starttime, endtime
                    pprint(tst_name)
                    #pprint(tst)
                    #exit(1)
                #print s_dur
                #print s_avg
                #exit(1)
                starttime = None

                gt['TotalTime'] = s_dur
                gt['AvgTime'] = s_avg

                #print gt
                #exit(1)

            elif n_tc_done == 0 and n_tc_todo > 0:
                #TODO
                # add record

                group_inqueue['keys'].append(tst_name)
                group_inqueue[tst_name] = {}

                gt = group_inqueue[tst_name]

                todo_idx += 1
                sum_time = cfgs['DURATION_SECONDS']

                est_time = 0
                if total_tc_done > 0:
                    #print '---'
                    est_time = sum_time / total_tc_done * n_tc_todo
                else:
                    #print '---2 :',sum_time,n_tc_todo
                    est_time = sum_time * n_tc_todo

                print 'Estimate time :', est_time

                s_dur = ('%02dH:%02dM:%02dS' % pp_duration(est_time))

                total_time_est += est_time
                #print tst_name,n_tc_done,n_tc_todo
                gt['Index'] = todo_idx
                gt['SuiteInQueue'] = os.path.basename(tst_name)
                gt['Cases'] = n_tc_done + n_tc_todo
                gt['Pass'] = ''
                gt['Fail'] = ''
                gt['Skip'] = ''
                gt['BugID'] = ''
                gt['TotalTime'] = s_dur
                gt['AvgTime'] = ''

                total_tc_todo2 += n_tc_todo
            else:
                continue




        #exit(1)
        # tested total
        gt = group_tested['total']
        gt['Index'] = ''
        gt['SuiteTested'] = 'Total'
        gt['Cases'] = total_tc_done + total_tc_todo
        gt['Pass'] = total_tc_pass
        gt['Fail'] = total_tc_fail
        gt['Skip'] = total_tc_skip
        gt['BugID'] = ''
        s_dur = ('%02dH:%02dM:%02dS' % pp_duration(total_time_done))
        avg = 0
        if total_tc_done > 0:
            avg = total_time_done / total_tc_done
        s_avg = ('%02dH:%02dM:%02dS' % pp_duration(avg))
        gt['TotalTime'] = s_dur
        gt['AvgTime'] = s_avg

        #print gt
        #exit(1)
        # todo total
        gt = group_inqueue['total']
        gt['Index'] = ''
        gt['SuiteInQueue'] = 'Total'
        gt['Cases'] = total_tc_todo2
        gt['Pass'] = ''
        gt['Fail'] = ''
        gt['Skip'] = ''
        gt['BugID'] = ''
        s_dur = ('%02dH:%02dM:%02dS' % pp_duration(total_time_est))
        gt['TotalTime'] = s_dur
        gt['AvgTime'] = ''

        #adjust title line
        gt = group_tested['title_vals']
        gt['SuiteTested'] = ('Suite Tested(' + str(done_idx) + ')')

        gt = group_inqueue['title_vals']
        gt['SuiteInQueue'] = ('Suite In Queue(' + str(todo_idx) + ')')
        gt['TotalTime'] = ('Estimate(' + s_dur + ')')
        if len(group_tested['keys']):
            gt['Cases'] = total_tc_todo2
            gt['Pass'] = ''
            gt['Fail'] = ''
            gt['Skip'] = ''
            gt['BugID'] = ''
            s_dur = ('%02dH:%02dM:%02dS' % pp_duration(total_time_est))
            gt['TotalTime'] = s_dur
            gt['AvgTime'] = ''

        return testInfo

    def packageHTML(self):
        """
        """
        self.packageTBinfo()
        self.packageTestInfo()

    def packageTBinfo(self):
        """
        """
        pg = self._page
        #
        sum_div = div(b('Test Information'), id='Test_Information')
        pg << sum_div
        tab_task = pg << table()
        self.tablecss(tab_task)
        tab_task = tab_task << tr()
        self.tr_title_css(tab_task)

        tbinfo = self._tbInfo
        for title in tbinfo['groups']:
            ginfo = tbinfo[title]

            #add task column title
            _td = tab_task << td('<b>' + title + '</b>')
            self.td_title_css(_td)
            _td.attributes['colspan'] = 2

            #add column value


            for k in ginfo['keys']:
                v = str(ginfo[k])
                #print inf
                value_tr_task = tab_task << tr()
                self.tr_normal_css(value_tr_task)

                _td = value_tr_task << td(k)
                self.td_normal_css(_td, '10%')
                _td = value_tr_task << td(v)
                #self.td_normal_css(_td)
            #
        pg << br()

    def packageTestInfo(self):
        """
        """
        pg = self._page
        #
        sum_div = div(b('Test Results'), id='Test_Results')
        pg << sum_div
        tab_task = pg << table()
        self.tablecss(tab_task)
        tab_task = tab_task << tr()
        self.tr_title_css(tab_task)

        ti = self._testInfo
        for gname in ti['groups']:
            group = ti[gname]
            #print gname
            #if 0 == len(group['keys']) :
            #    continue
            #add task column title
            title_cols = group['title_cols']
            for idx, col in enumerate(title_cols):
                val = str(group['title_vals'][col])
                _td = tab_task << td('<b>' + val + '</b>')
                if idx == 1:
                    self.td_title_css(_td, width='20%')
                else:
                    self.td_title_css(_td)
                # Add records
            for tstname in group['keys']:
                tst = group[tstname]
                _tr = value_tr_task = tab_task << tr()

                f = tst.get('Fail', '')
                s = tst.get('Skip', '')
                #print(tst)
                if len(str(f)) and len(str(s)):
                    if f > 0 or s > 0:
                        self.tr_red_css(_tr)
                        #print('tr red css')
                    else:
                        self.tr_normal_css(_tr)
                        #print('tr normal css')
                        pass
                    pass
                else:
                    self.tr_normal_css(_tr)

                for col in title_cols:
                    cell = tst.get(col, 'NONE')
                    fine_tune_str = True
                    if fine_tune_str:
                        cell = str(cell)
                        if len(cell) > 60 and cell.find('href=') < 0:
                            cell = '%s...%s' % (cell[:30], cell[-30:])
                    _td = value_tr_task << td(str(cell))


                    #value_tr_task << td(v)
                # Total
            tot = group['total']
            value_tr_task = tab_task << tr()
            for col in title_cols:
                cell = tot.get(col, 'NONE')
                #print cell
                _td = value_tr_task << td('<b>' + str(cell) + '</b>')


    def save2file(self, fn):
        """
        """
        self._page.printOut(fn)
        #self._page.printOut('')


    def tablecss(self, table=None, width='80%'):
        table.attributes['cellSpacing'] = 0
        table.attributes['cellPadding'] = 1
        table.attributes['border'] = 1

        table.attributes['borderColor'] = '#003399'
        table.attributes['width'] = width

        #table.attributes['style'] = "background-color:#EEEEEE;"

    def tr_title_css(self, tr=None):
        tr.attributes['style'] = "background-color:#DFC5A4;font-family:Arial;font-size:18px;"
        pass

    def td_title_css(self, td=None, width=None):
        #tr.attributes['bgcolor'] = '#CCCC00'
        td.attributes['style'] = "background-color:#DFC5A4;font-family:Arial;font-size:14px;"
        if width:
            td.attributes['width'] = width

    def td_red_css(self, td=None):
        #tr.attributes['bgcolor'] = '#CCCC00'
        td.attributes['style'] = "color:#FF0000;font-family:Arial;font-size:14px;"

    def tr_red_css(self, tr=None):
        tr.attributes['style'] = "color:#FF0000;font-family:Arial;font-size:14px;"


    def td_normal_css(self, td=None, width=None):
        #tr.attributes['bgcolor'] = '#CCCC00'
        td.attributes['style'] = "color:#000000;font-family:Arial;font-size:14px;"
        if width:
            td.attributes['width'] = width

    def tr_normal_css(self, tr=None):
        tr.attributes['style'] = "color:#000000;font-family:Arial;font-size:14px;"


def createRptHtml(logpath):
    """
    """
    rc = True
    buf = ''
    return (rc, buf)


def createRptHtmlFile(logpath, fn):
    """
    """
    rc = True
    #fn = ''
    try:
        os.system('sync')
        tp = TestResultsParser()

        dp = logpath
        tp.parse(dp)

        cfg, cases = tp.getAllData()

        hpc = HTMLPageCreator('Automation Test')
        hpc.importDatas(cfg, cases)
        hpc.packageHTML()
        hpc.save2file(fn)
    except Exception, e:
        print('Exception : ' + str(e))
        #traceback.print_exc()
        formatted_lines = traceback.format_exc().splitlines()
        print('Exception : ' + pformat(formatted_lines))
        #exit(0)
    return (rc, fn)


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog logpath [options]\n"
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
    if len(args) < 1:
        print '==', '1 arguments required'
        parser.print_help()
        exit(1)
    return args, options


def main():
    """
    main entry
    """

    args, opts = parseCommandLine()

    tp = TestResultsParser()
    #'logs2012-10-30_085531__BAR1KH'
    #dp = '/root/automation/logs/'
    #dp += 'current'
    #dp += 'logs2012-10-30_085531__BAR1KH'
    dp = args[0]
    tp.parse(dp)

    cfg, cases = tp.getAllData()

    print '--' * 16
    #pprint(cfg)
    print '--' * 16
    #pprint(cases)

    hpc = HTMLPageCreator('AT Test')
    hpc.importDatas(cfg, cases)
    hpc.packageHTML()
    hpc.save2file('mytest.html')
    print '--' * 16
    print '==DONE!'
    exit(0)


if __name__ == '__main__':
    """
    """

    main()
