#!/usr/bin/python -u
# -*- coding: utf-8 -*-
#
#       ATE.py
#
#       Copyright 2011 rayofox <lhu@actiontec.com>
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
This class is the Engine for Automaton Test

Function :
1. Preload all config files
2. Check all lines in config files
3. Output the check result to file specified with -p
4. Output all logs to file specified with -s
5. Run case after checking if -e specified

Support line format :
1. all options of this application :
    -e , -f , -p , -s , -v , -x
2. all flags in automation test config file and test suite file
    -v , -tc , -nc , -label
3. new flags -t to load all environment variables to debug and test script tool
4. new line type added :
    a> -cmdline to run this line as shell command during the case running line by line
    b> -pre_cmdline , to run this line as shell command ,before all cases start
NOTE:
1. all optons can be added in the config file specified with -f
2. -e,-p,-s,-x MUST before all cases
3. nested levels of files MUST less than 5
4. accelerate speed with diable -p if a large number of cases to run


"""
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2011, Rayofox"
__version__ = "1.1"
__license__ = "MIT"
__history__ = """
Rev 1.0 : 2011/09/01
    Initial version
Rev 1.1 : 2011/09/08
    Draft finish all function
Rev 1.2 : 2011/10/26
    Add new flag -s to debug and test tools depend on environment variables
Rev 1.2 : 2012/07/13
    New features :
        a> new command paramter -d to run case with pause after each step to waiting for input from stdin
        b> add new line type -cmdline to run this line as shell command
        c> add new line type -pre_cmdline , to run this line as shell command ,before all cases start
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
#from lxml import etree
import subprocess, signal, select
from copy import deepcopy
import syslog
import traceback
import shutil
#------------------------------------------------------------------------------

def sshcli(ip, port, username, password, cmd):
    """
    """
    try:
        import pexpect
    except:
        print 'ATE_ERROR : Please install pexpect first!'
        #os.system('yum install -y pexpect')
        return False


#------------------------------------------------------------------------------

def capacity_pretty_str(c, precision=2, unit=None):
    """
    """
    ppz = ['', 'K', 'M', 'G', 'T']

    d = float(c)
    u = 1024
    postfix = ''
    idx = 0
    while True:
        if unit:
            if unit == ppz[idx]:
                break
        elif d < 1024 or idx >= len(ppz):
            break
        idx += 1
        d = d / u
        #print idx

    postfix = ppz[idx]
    rc = '%.*f%s' % (precision, d, postfix)
    return rc


def pp_duration(dur):
    """
    """
    nDur = int(float(dur))
    nHour = int(nDur) / 3600
    nMin = (int(nDur) - nHour * 3600) / 60
    nSec = int(nDur) % 60
    #nMilSec = (int) ((float(dur) - nDur) * 1000)

    #return (nHour, nMin, nSec, nMilSec)
    return (nHour, nMin, nSec)


def waiting_input(prompt='', timeout=10):
    if len(prompt):
        sys.stdout.write(prompt)
        sys.stdout.flush()
    to = 1
    for i in range(timeout):
        rd = select.select([sys.stdin], [], [], to)[0]
        if not rd:
            if i > 0:
                if i < 10:
                    sys.stdout.write('\b')
                else:
                    sys.stdout.write('\b')
                    sys.stdout.write('\b')
            sys.stdout.write(str(i + 1))
            sys.stdout.flush()
        else:
            return raw_input()


import datetime


def is_file_last_changed_in_24hour(fileName):
    """
    """
    filemt = time.localtime(os.stat(fileName).st_mtime)
    filetime = datetime.datetime(filemt[0], filemt[1], filemt[2], filemt[3], filemt[4], filemt[5])
    timenow = datetime.datetime.now()
    difftime = (timenow - filetime)
    diffsecs = difftime.total_seconds()
    diffhours = diffsecs / 60 / 60
    #print fileName,filetime,diffhours,diffsecs
    if diffhours <= 24:
        return True
    else:
        return False


def timeNowStr():
    """
    """
    return datetime.datetime.now().strftime('%a %b %d %H:%M:%S %Y')


ATE_LOGGER = None


def INIT_ATE_LOG():
    """
    """
    global ATE_LOGGER
    ATE_LOGGER = logging.getLogger('ATE_LOG')
    logpath = '/var/log/ATE'
    logfile = os.path.join(logpath, 'ATE_LOG')

    # backup log file each 30 days
    BACKUP_INTERVAL = 30 * (60 * 60 * 24)
    #BACKUP_INTERVAL = 30
    if os.path.exists(logfile):
        si = os.stat(logfile)
        dt_create = datetime.datetime.fromtimestamp((si.st_ctime))
        dt_now = datetime.datetime.now()
        diff_secs = (dt_now - dt_create).total_seconds()
        #print '--> ',diff_secs
        if diff_secs >= BACKUP_INTERVAL:
            bkfile = logfile + '-' + datetime.datetime.today().strftime('%Y%m%d')
            os.system('mv %s %s' % (logfile, bkfile))
        else:
            pass

    if not os.path.exists(logpath):
        os.makedirs(logpath)

    syshdlr = logging.FileHandler(logfile)
    FORMAT = '[pid=%(process)d][%(asctime)-15s][%(levelname)s]%(message)s'
    syshdlr.setFormatter(logging.Formatter(FORMAT))
    ATE_LOGGER.addHandler(syshdlr)
    ATE_LOGGER.setLevel(11)


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


def strFullTstPath(job):
    """
    """
    fullpath = ''
    for idx, fp in enumerate(job['filepath']):
        fn = os.path.basename(fp)
        if fn.endswith('.case'): continue
        ln = job['linenum'][idx]
        #if len(fullpath) : fullpath += '/'
        fullpath = os.path.join(fullpath, fn + ':' + str(ln))
    fullpath = fullpath[0:fullpath.rfind(':')]
    return fullpath


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


from glob import glob


def search_file(pattern, search_path=os.environ['PATH'], pathsep=os.pathsep):
    for path in search_path.split(os.pathsep):
        p = os.path.join(path, pattern)
        for match in glob(p):
            yield match

#------------------------------------------------------------------------------
class ATE():
    """
    This class is the Automation Core Engine for running Automation test cases.
    """

    # The envrionment variables table
    m_hash_env = {}
    m_hash_env_bak = {}
    m_hash_case2tools = {}
    m_hash_case2var = {}
    m_hash_tool2var = {}
    m_hash_case2resrc = {}
    m_hash_export = []
    m_all_tools_in_use = []
    m_all_vars_in_use = []

    m_tools = r'[^ ]*\.sh|[^ ]*\.pl|[^ ]*\.py'
    m_vars = r'\$G_[0-9A-Z_]*|\$U_[0-9A-Z_]*'
    m_resrc = r'[^ ]*RPC-[0-9]+ |[^ ]*-[c|C][0-9]+ '
    m_mailto_lst = ''
    #
    m_cfgfiles = []
    # The runtime information
    m_runtime = {
        'filepath': [],
        'linenum': [],
        'line': '',
        'param': '',
        'raw_param': '',
        'type': '', # PUTENV,INCLUDE,CASE,TAG
        'case': None,
        'status': 'checked',
    }
    m_jobs = []
    # print all jobs into file
    m_psfile = None

    m_isMail = False

    m_mappingfile = None

    # log path
    m_log_path = None

    # logs
    m_syslogger = None
    m_reslogger = None
    m_caselogger = None
    m_steplogger = None

    # dynamic log handler
    m_casehdlr = None
    m_stephdlr = None

    # results
    m_results = {
        'G_NCPASS': 0,
        'G_NCFAIL': 0,
        'G_TCPASS': 0,
        'G_TCFAIL': 0,
        'G_IGNUM': 0,
        'G_CASE_INDEX': 0,
    }
    # include files
    m_include = []

    # times
    m_times = {
        'starttime': '',
        'endtime': '',
        'start_check': 0,
        'end_check': 0,
        'start_run': 0,
        'end_run': 0,
        'duration': 0,
        'duration_check': 0,
        'duration_run': 0,
    }
    #
    m_mode = 0 # 0: check only; 1: testcmd; 2: exec
    m_testcmd = None

    m_check_have_case = False


    # VIP
    m_vip = ['G_CURRENTLOG', 'G_LOG']

    #
    m_at_tag = None
    m_debug = False
    m_skip_all = False

    m_tst_all = []
    m_tst_status = {
        'name': '',
        'status': 'Not Start',
        'tc_total': 0,
        'tc_ready': 0,
        'tc_passed': 0,
        'tc_failed': 0,
        'tc_skipped': 0,
        'nc_total': 0,
        'nc_ready': 0,
        'nc_passed': 0,
        'nc_failed': 0,
        'nc_skipped': 0,
        'tc_time': 0,
        'nc_time': 0,


    }

    m_tst_in_testing = None
    # for minicom
    m_pid_minicom = None
    m_pid_local_tcpdump = None
    m_pid_remote_tcpdump = None

    _minicom_last_line_no = 0
    _minicom_last_line_no_case_begin = 0
    #_minicom_last_line_no = 0

    _minicom_log = None
    _no_minicom = False
    _no_lan_tshark = False
    _no_wan_tshark = False

    m_subp_async = []

    m_fixed_env = {}
    m_loglevel_fixed = False

    # required var
    _required_vars = []

    _minicom_dev = None

    _minicom_method = 1

    _tags = []

    _tcases_num = 0


    # db support
    _dbagent = None
    _dbEnable = False

    #
    _tcase_cnt = 0
    _first_job_tcase = None

    #
    _cases_whitelist = []
    _casefile_whitelist = []
    _cases_loaded = []

    _pre_check_methods = []


    #
    _testlink_agent = None

    def __init__(self, debug=False):
        """
        """
        self.m_debug = debug
        self.fetchAutomationReleaseTag()
        self._new_minicom_started = False


    def debug(self, msg):
        """
        """
        self.m_syslogger.debug(msg)

    def info(self, msg):
        """
        """
        self.m_syslogger.info(msg)

    def warning(self, msg):
        """
        """
        self.m_syslogger.warning(msg)

    def error(self, msg):
        """
        """
        self.m_syslogger.error(msg)

    def initDBI(self):
        """
        """
        self._dbEnable = os.getenv('U_CUSTOM_DB_ENABLE', False)
        if not self._dbEnable or self._dbEnable == '0':
            #print '===>','DBI disabled'
            ATE_LOGGER.info('LAST_STATUS : DBI disabled ')
            #exit(1)
            return True
        rc = True
        ATE_LOGGER.info('LAST_STATUS : DBI inital ')
        try:
            import db_mysql

            self._dbagent = db_mysql.dbAgent()
        except Exception, e:
            formatted_lines = traceback.format_exc().splitlines()
            print('== initDBI failed Exception : ' + pformat(formatted_lines))
            self.error('Exception : %s' % e)
            rc = False
            #exit(1)
        if rc:
            ATE_LOGGER.info('LAST_STATUS : DBI inital done')
        else:
            ATE_LOGGER.info('ERROR : DBI inital')

        return rc

    def dbAddTestTask(self):
        """
        """
        if not self._dbagent:
            return
        rc = True
        try:

            ATE_LOGGER.info('LAST_STATUS : DB add test task')
            self._dbagent.addTask(self.m_jobs)
            self._dbagent.addAllCases(self.m_jobs)
            ATE_LOGGER.info('LAST_STATUS : DB add test task done')
        except Exception, e:
            formatted_lines = traceback.format_exc().splitlines()
            print('== dbAddTestTask failed Exception : ' + pformat(formatted_lines))
            self.error('Exception : %s' % e)
            rc = False
            #exit(1)


    def dbUpdateTestTask(self, status, msg=''):
        """
        """
        if not self._dbagent:
            return
        rc = True
        try:

            self._dbagent.updateTask(status=status, last_error=msg)
            self.info("Update Task status : %s" % status)
        except Exception, e:
            formatted_lines = traceback.format_exc().splitlines()
            print('== dbUpdateTestTask failed Exception : ' + pformat(formatted_lines))
            self.error('Exception : %s' % e)
            rc = False
            #exit(1)
        return rc

    def dbUpdateCase(self, job):
        """
        """

        if not self._dbagent:
            return
        rc = True
        try:

            self._dbagent.updateCase(job)
        except Exception, e:
            formatted_lines = traceback.format_exc().splitlines()
            print('== dbUpdateCase failed Exception : ' + pformat(formatted_lines))
            self.error('Exception : %s' % e)
            rc = False
            #exit(1)
        return rc

    def sighandle(self, signum=0, e=0):
        """handle signal"""
        errmsg = 'receive kill signal: %d at %s' % (signum, str(time.ctime(time.time())))
        syslog.syslog(syslog.LOG_ERR, errmsg)

        # killall minicom
        os.system('killall minicom')

        # killall async subproc
        for p in self.m_subp_async:
            pid = p.pid
            rc = self.stop_async_subporc(p, self.m_caselogger)
            #self.m_syslogger.info('exit pid ' + str(pid) + ' code : ' + str(rc))

        self.m_subp_async = []

        self.dbUpdateTestTask(status='ABORTED', msg=errmsg)

        ATE_LOGGER.error('EXIT : ATE killed by signal ' + str(signum))
        sys.exit(2)

    def addVars(self, job):
        """
        """
        if job['comment'].find('[required]') >= 0:
            self._required_vars.append(job)
        return

    def dumpVarsRequired(self):
        """
        """
        msg = '\n'
        msg += ('--' * 16 + '\n')
        msg += ('All required varibles ,please double check them:' + '\n')
        for job in self._required_vars:
            msg += ('--\n')
            msg += ('path    : ' + job['filepath'][-1] + ':' + str(job['linenum'][-1]) + '\n')
            msg += ('comment : ' + job['comment'] + '\n')
            msg += ('rawline : ' + job['raw_param'] + '\n')
            msg += ('realrun : ' + job['param'] + '\n')
            msg += ('--\n')

        return msg

    def diffVarsRequired(self):
        """
        """
        # get last
        lines = []
        last_vars = {}
        comments = {}

        fn = '/etc/ATE/last_required'
        if os.path.exists(fn):
            fd = open(fn, 'r')

            if fd:
                lines = fd.readlines()
                fd.close()

            for line in lines:
                s = line.strip()
                m = r'(\w*)\s*=(.*)'
                res = re.findall(m, s)
                if len(res):
                    (k, v) = res[0]
                    last_vars[k] = v

        # get current
        curr_vars = {}
        for job in self._required_vars:
            s = job['param']
            m = r'(\w*)\s*=(.*)'

            res = re.findall(m, s)
            #print '===',s,res
            if len(res):
                (k, v) = res[0]
                curr_vars[k] = v
                comments[k] = job['comment']
        msg = '\n'
        msg += ('--' * 16 + '\n')

        # diff
        _same = []
        _added = []
        _removed = []
        _diff = []

        keys = last_vars.keys()
        keys += curr_vars.keys()
        ks = set(keys)
        kl = list(ks)
        kl.sort()
        #print '-->',curr_vars
        #print '-->',last_vars
        #print '-->',kl
        for k in kl:
            vc = ''
            vl = ''
            cm = 'None'
            if curr_vars.has_key(k):
                #print k,'in current'
                vc = curr_vars[k]
                cm = comments[k]
                if last_vars.has_key(k):
                    vl = last_vars[k]
                    if vc.strip() != vl.strip():
                        #msg += ('Parameter Changed : ')
                        _diff.append(('[%s] Current(%s) Last(%s) Comment : %s \n' % (k, vc, vl, cm)))
                    else:
                        #msg += ('Parameter Not Changed : ')
                        _same.append(('[%s] Current(%s) Last(%s) Comment : %s \n' % (k, vc, vl, cm)))
                        #continue
                else:
                    #msg += ('Parameter Added : ')
                    _added.append(('[%s] Current(%s) Last(%s) Comment : %s \n' % (k, vc, vl, cm)))
            else:
                vl = last_vars[k]
                #msg += ('Parameter Removed : ')
                _removed.append(('[%s] Current(%s) Last(%s) Comment : %s \n' % (k, vc, vl, cm)))

                #msg += ('[%s] Current(%s) Last(%s) Comment : %s \n' % (k,vc,vl,cm) )

        if len(_same):
            msg += 'Required Parameters Not Changed : \n'
            for ss in _same:
                msg += ss
            msg += '\n'

        if len(_removed):
            msg += 'Required Parameters Removed : \n'
            for ss in _removed:
                msg += ss
            msg += '\n'

        if len(_added):
            msg += 'Required Parameters Added : \n'
            for ss in _added:
                msg += ss
            msg += '\n'

        if len(_diff):
            msg += 'Required Parameters Changed : \n'
            for ss in _diff:
                msg += ss
            msg += '\n'

        #msg += 'Required Parameters Changed : \n'

        msg += ('--' * 16 + '\n')
        return msg

    def saveLastVarsRequired(self):
        """
        """
        fn = '/etc/ATE/last_required'
        path = os.path.dirname(fn)
        if not os.path.exists(path):
            os.makedirs(path)
        fd = open(fn, 'w')
        if fd:
            for job in self._required_vars:
                fd.write(job['param'] + '\n')
            fd.close()


    def fetchAutomationReleaseTag(self):
        """
        """
        rpath = os.getenv('SQAROOT', '/root/automation')

        fpath = rpath + '/' + 'release_note'

        cmd = 'grep -i "release tag" ' + fpath + "| awk -F':' '{print $2}'"

        if not os.path.exists(fpath):
            cmd = "git log -n1 --oneline | awk '{print $1}'"

        self.m_at_tag = os.popen(cmd).read().strip()

        cmd = 'cat $SQAROOT/.git/FETCH_HEAD  | grep `cat $SQAROOT/.git/HEAD`| grep tag | grep -o "\'.*\'" | head -n1'
        ss = os.popen(cmd).read().strip()
        if len(ss) > 2:
            self.m_at_tag = ss[1:-1]
        print '--->', self.m_at_tag
        #exit(0)
        os.environ['G_AT_SW_VER'] = str(self.m_at_tag)
        return self.m_at_tag

    def stop_async_subporc(self, p, plogger=None):
        rc = None
        if not isinstance(p, subprocess.Popen):
            return rc
        inf = os.popen('ps aux | grep -v grep | grep ' + str(p.pid)).read()
        plogger.info('stop async subproc : ' + inf)
        try:
            p.terminate()
            #p.kill()
            #rc = p.wait()
            to = 15
            for i in range(to):
                time.sleep(1)
                rc = p.poll()
                if rc is not None:
                    break


            # force to kill the progress
            if rc == None:
                plogger.info('kill async subproc : ' + inf)
                p.kill()

            for i in range(to):
                time.sleep(1)
                rc = p.poll()
                if rc is not None:
                    break
            if rc == None:
                plogger.info('kill subproc : ' + inf)
                os.system('kill ' + str(p.pid))

            p.stdin.close()
            p.stdout.close()
            p.stderr.close()

            rc = p.returncode
        except Exception, e:
            plogger.error('Exception : ' + str(e))
            rc = False
        return rc

    def start_async_subproc(self, cmd, plogger=None):
        """
        subprogress to run command
        """
        rc = None
        output = ''
        if not plogger: plogger = logging.getLogger()
        #
        plogger.info('start async subproc : ' + cmd)

        try:
            #
            p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                 close_fds=True, shell=True)
            pi, po, pe = p.stdin, p.stdout, p.stderr
            rc = p
            plogger.debug(os.popen('ps | grep -v grep | grep  ' + str(p.pid)).read())
        except Exception, e:
            plogger.error('Exception : ' + str(e))
            rc = False

        return rc


    def subproc(self, cmd, timeout=7200, plogger=None):
        """
        subprogress to run command
        """
        rc = None
        output = ''
        if not plogger: plogger = logging.getLogger()
        #
        cmd2 = self.expandExpr(cmd)
        plogger.info('subproc  : ' + cmd)
        plogger.info('real cmd : ' + cmd2)
        plogger.info('timout   : ' + str(timeout))
        try:
            #
            p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                 close_fds=True, shell=True)
            pi, po, pe = p.stdin, p.stdout, p.stderr
            while_begin = time.time()
            while True:

                to = 600
                fs = select.select([p.stdout, p.stderr], [], [], to)
                #if p.poll() : break
                #print '==>',fs
                if p.stdout in fs[0]:
                    tmp = p.stdout.readline()
                    if tmp:
                        output += tmp
                        plogger.info(tmp)
                    else:
                        #print 'end'
                        #print time.time()
                        while None == p.poll(): pass
                        break
                elif p.stderr in fs[0]:
                    #print "!!!!!!!!!!!!!!!"
                    tmp = p.stderr.readline()
                    if tmp:
                        output += tmp
                        plogger.warning(tmp)
                    else:
                        #print 'end'
                        #print time.time()
                        while None == p.poll(): pass
                        break
                else:
                    #print 'Timeout'
                    #os.system('ps -f')
                    s = os.popen('ps -f| grep -v grep |grep sleep').read()

                    if len(s.strip()):
                        plogger.info('No output in sleep : ' + s)
                        continue

                    plogger.error('Timeout ' + str(to) + ' seconds without any output!')
                    plogger.info(os.popen('ps -p ' + str(p.pid)).read())
                    p.kill()

                    #os.kill(p.pid, signal.SIGKILL)
                    break
                    #timeout = timeout - (time.time() - while_begin)
                # Check the total timeout
                dur = time.time() - while_begin
                if dur > timeout:
                    plogger.error('The subprocess is timeout more than ' + str(timeout))
                    break
                # return
            rc = p.poll()
            # close all fds
            p.stdin.close()
            p.stdout.close()
            p.stderr.close()
            plogger.info('return value : ' + str(rc))

        except Exception, e:
            plogger.error('Exception : ' + str(e))
            rc = False
        return rc, output

    def parseKV(self, env):
        """
        parse equal expression : Key = Value
        """
        match = r'(\w*)\s*=\s*(.*)'
        #kv = os.popen('echo ' + env).read().strip()
        kv = self.expandExpr(env).strip()
        #self.m_runtime['param'] = kv
        az = re.findall(match, kv)
        sz = len(az)
        if sz > 0:
            (key, val) = az[0]
            if key:
                if not val: val = ''
                if val.startswith('"') and val.endswith('"'):
                    val = val[1:-1]
                elif val.startswith('\'') and val.endswith('\''):
                    val = val[1:-1]
                return (key, val)
        return (None, None)

    def addJob(self, job):
        """
        add a job
        """
        sz = len(self.m_jobs)
        j = deepcopy(job)
        self.m_jobs.append(j)
        logger.debug('add job(' + str(sz) + ') : ' + pformat(j))

        # sum all tcases
        if job['type'] == 'TCASE':
            self._tcase_cnt += 1
            fname = job['filepath'][-1]
            if fname.endswith('.case') and len(fname) > 8:
                #idx_str = fname[:8]
                if fname not in self._cases_loaded:
                    self._cases_loaded.append(fname)


        # add case job to tst info
        case = j.get('case', None)
        if case:
            #logger.error('add case job(' + str(sz) + ') : ' + pformat(j))
            fullpath = []
            sz = len(job['filepath'])
            for i in range(0, sz):
                #print '@@@'
                if i == sz - 1:
                    fullpath.append(job['filepath'][i])
                else:
                    fullpath.append(job['filepath'][i] + ':' + str(job['linenum'][i]))

                tst_path = '-->'.join(fullpath)

                res = re.findall(r'(.*):\d*$', tst_path)

                if len(res):
                    tst_path = res[0]

                #tst_path = strFullParentPath(job)
                tst_path = strFullTstPath(job)
                #print '--->','find tst ',tst_path
                tst = None
                for i, t in enumerate(self.m_tst_all):
                    if t['name'] == tst_path:
                        tst = t
                        #break
                if not tst:
                    tst = deepcopy(self.m_tst_status)
                    tst['name'] = tst_path
                    self.m_tst_all.append(tst)
                    #print '--->','add tst ',tst_path

            #
            tst_path = '-->'.join(fullpath)
            #tst_path = strFullParentPath(job)
            tst_path = strFullTstPath(job)
            tst = None
            #print '------>','find tst ',tst_path
            for i, t in enumerate(self.m_tst_all):
                if t['name'] == tst_path:
                    tst = t
                    break

            if tst:
                if 'TCASE' == job['type']:
                    tst['tc_total'] += 1
                    tst['tc_ready'] += 1
                elif 'NCASE' == job['type']:
                    tst['nc_total'] += 1
                    tst['nc_ready'] += 1


    def check_tools(self):
        """
        """
        cnt = 0
        tools = []
        for case in self.m_hash_case2tools.keys():
            for t in self.m_hash_case2tools[case]:
                if t not in tools:
                    tools.append(t)
                    if not os.path.exists(t):
                        cnt += 1
                        self.m_syslogger.error('--->File not found :' + t)
                    else:
                        pass
                        #self.m_syslogger.info('--->File is found :' + t)

        return cnt

    def dump_tools(self):
        """
        """
        msg = '#' * 64
        msg += '\ntools used in each cases :\n\n'
        for case in self.m_hash_case2tools.keys():
            msg = msg + case + ' {\n'

            for t in self.m_hash_case2tools[case]:
                msg = msg + '\t' + t + '\n'
                if not t in self.m_all_tools_in_use:
                    self.m_all_tools_in_use.append(t)
            msg += '\t}\n\n'
            msg += 'Variables :\n'
            msg += '{\n'

            for v in self.m_hash_case2var[case]:
                msg = msg + '\t' + v + '\n'
                if not v in self.m_all_vars_in_use:
                    self.m_all_vars_in_use.append(v)
            msg += '\t}\n\n'
            msg += '#' * 64
            msg += '\n'

        msg += '\nresource files used in each cases :\n\n'
        for case in self.m_hash_case2resrc.keys():
            msg = msg + case + ' {\n'

            for t in self.m_hash_case2resrc[case]:
                msg = msg + '\t' + t + '\n'
            msg += '\t}\n\n'
            msg += '#' * 64
            msg += '\n'

        msg += 'tools and variable mapping :\n\n'
        for tool in self.m_hash_tool2var.keys():

            msg = msg + tool + ': {\n'
            for var in self.m_hash_tool2var[tool]:
                msg = msg + '\t' + var + '\t' + os.getenv(var.split('$')[1], 'NOT_DEFINED') + '\n'

            msg = msg + '\t}\n\n'
        msg += '#' * 64
        msg += '\n'
        msg += '\nall used tools :\n\n'
        for t in self.m_all_tools_in_use:
            msg = msg + '\t' + t + '\n'
        msg += '\nall variables used :\n\n'
        not_defined_msg = '\nnot defined variables :\n\n'
        for v in self.m_all_vars_in_use:
            msg = msg + '\t' + v + '\n'
            if os.getenv(v.split('$')[1], 'NOT_DEFINED') == 'NOT_DEFINED':
                not_defined_msg = not_defined_msg + '\t' + v + '\n'
        msg += not_defined_msg


        #pprint(self.m_hash_tool2var)
        dump_tools_file = self.m_mappingfile

        if dump_tools_file:
            logger.info('Save all case tool variables mapping into file : ' + dump_tools_file)
            fd = open(dump_tools_file, 'w')
            if fd:
                fd.write(msg)
                fd.close()
        else:
            logger.info(msg)

    def dumpJobs(self, name='jobs'):
        """
        dump all jobs, format is python grammar
        """
        msg = ''
        msg += '\n' * 4
        msg += ('# Totoal ' + name + ' : ' + str(len(self.m_jobs)) + '\n')
        msg += name;
        msg += '= [] \n'
        #msg +=
        #print '\n'*4
        #print 'totoal jobs : ' + str(len(self.m_jobs))
        idx = 0
        for job in self.m_jobs:

            msg += ('\n' + '##' * 32)
            msg += ('\njobs[' + str(idx) + '] = \n')
            _job = deepcopy(job)
            if _job.get('case', None):
                _job['case'] = {}
            msg += pformat(_job)
            idx += 1
            #print '\n', str(idx),'\n'
            #pprint(job )
            #pprint(job)
        return msg

    def strFullPath(self, job):
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

    def dumpCases(self):
        """
        """
        msg = '###########All Cases Status##########\r\n'
        pid = os.getpid()
        at_tag = self.m_at_tag
        if at_tag:
            if at_tag.find('AT_') < 0:
                if len(at_tag) > 8:
                    at_tag = at_tag[:8]
        else:
            #print 'AT tag is empty!'
            at_tag = 'UNKNOWN'
            #exit(1)

        msg += ('####ATE_PID                : ' + str(pid) + '\r\n')
        msg += ('####AT_TAG                 : ' + str(at_tag) + '\r\n')
        msg += ('####DUT_PRODUCT_TYPE       : ' + os.getenv('U_DUT_TYPE', 'UNKNOWN') + '\n')
        msg += ('####DUT_MODEL_NAME         : ' + os.getenv('U_DUT_MODELNAME', 'UNKNOWN') + '\n')
        msg += ('####DUT_SN                 : ' + os.getenv('U_DUT_SN', 'UNKNOWN') + '\n')
        msg += ('####DUT_FW                 : ' + os.getenv('U_DUT_SW_VERSION', 'UNKNOWN') + '\n')
        msg += ('####DUT_POST_FILES_VER     : ' + os.getenv('U_DUT_FW_VERSION', 'UNKNOWN') + '\n')
        idx = 0
        for job in self.m_jobs:
            #print '--------->',job['param']
            #print '--------->',job['type']
            jtype = job['type']
            if not jtype in ['TCASE', 'NCASE']: continue

            fullpath = self.strFullPath(job)

            #print '--------->',fullpath

            #status = 'CHECKED'
            status = job['status']
            idx += 1
            ss = '%04d %04d %s %s %s\r\n' % (idx, 0, status, jtype, fullpath)
            msg += ss

        return msg

    def updateCaseReport(self, job=None):
        """
        """

        sln = os.getenv('G_CURRENTLOG', None)
        if not sln:
            #print '===','Enter updateCaseReport, but sln is empty!'
            exit(1)

        #print '===','Enter updateCaseReport'
        #
        if not job:
            #print '===','Initial rpt file'
            msg = self.dumpCases()
            fn = os.path.join(sln, 'cases.rpt')
            try:
                fd = open(fn, 'w')
                if fd:
                    fd.write(msg)
                    fd.close()
            except:
                pass
        else:


            jtype = job['type']
            fullpath = self.strFullPath(job)
            status = job['status']
            fn = os.path.join(sln, 'cases.rpt')
            #print '===','update case status : ',fullpath
            # Open file and read
            lines = []
            try:
                fd = open(fn, 'r')
                if fd:
                    lines = fd.readlines()
                    fd.close()
                else:
                    #print 'can not found file :',fn
                    exit(1)

                # Find line to update
                idx = 0
                fidx = 0
                case_idx = 0
                for idx, line in enumerate(lines):
                    if line.find(fullpath) > 0:
                        fidx = idx
                        m = r'(\d*)\s*(\d*)\s*(\w*)\s*(\w*)\s*(.*)'
                        res = re.findall(m, line)
                        if len(res):
                            case_idx, run_idx, st, tp, fp = res[0]
                        break
                    elif line.startswith('####'):
                        if line.find('DUT_MODEL_NAME') > 0:
                            lines[idx] = ('####DUT_MODEL_NAME   : ' + os.getenv('U_DUT_MODELNAME', 'UNKNOWN') + '\n')
                        elif line.find('DUT_SN') > 0:
                            lines[idx] = ('####DUT_SN           : ' + os.getenv('U_DUT_SN', 'UNKNOWN') + '\n')
                        elif line.find('DUT_FW') > 0:
                            lines[idx] = ('####DUT_FW           : ' + os.getenv('U_DUT_SW_VERSION', 'UNKNOWN') + '\n')
                        elif line.find('DUT_AT_LIB_VER') > 0:
                            lines[idx] = ('####DUT_AT_LIB_VER   : ' + os.getenv('U_DUT_FW_VERSION', 'UNKNOWN') + '\n')

                if fidx > 0:
                    run_idx = job['case_index']
                    newline = '%04d %04d %s %s %s\r\n' % (int(case_idx), int(run_idx), status, jtype, fullpath)
                    lines[fidx] = newline
                    #print '=== udate case status :',case_idx,status,fullpath
                else:
                    #print 'can not found case :',fullpath
                    #exit(1)
                    pass

                #Save file
                fd = open(fn, 'w')
                if fd:
                    fd.writelines(lines)
                    fd.close()
            except Exception, e:
                self.m_syslogger.error('Exception : ' + str(e))
                #traceback.print_exc()
                formatted_lines = traceback.format_exc().splitlines()
                self.m_syslogger.error('Exception : ' + pformat(formatted_lines))


    def exportEnv(self):
        """
        No use
        """
        for expr in m_hash_export:
            self.addEnv(expr)

    def addEnv_fixed(self, expr):
        """
        """
        (key, val) = self.parseKV(expr.strip())
        if key:
            if not val: val = ''

        self.m_fixed_env[key] = val
        os.environ[key] = val

    def addEnv(self, expr):
        """
        putenv with expression "key=value"
        """
        rc = False
        msg = None
        (key, val) = self.parseKV(expr.strip())
        if key:
            if not val: val = ''
            rc = True
            #
            if self.m_fixed_env.has_key(key):
                logger.warning('ignored to add fixed env : %s = %s' % (key, val))
                return rc
                # already exist
            if self.m_hash_env.has_key(key): msg = 'duplicate putenv'
            self.m_hash_env[key] = val
            oldval = os.environ.get(key, None)
            if oldval and not self.m_hash_env_bak.has_key(key):
                self.m_hash_env_bak[key] = oldval
                #os.putenv(key,val)
            os.environ[key] = val
            logger.debug('add env : %s = %s' % (key, val))
            #logger.error('add env : %s = %s' % (key, val))
        else:
            msg = "bad expression to putenv"
        return rc, msg

    def clearEnv(self):
        """
        clear all export environment parameters
        """
        # remove first
        for key in self.m_hash_env.keys():
            #os.unsetenv(key)
            os.environ.pop(key)
            # restore old val
        for key in self.m_hash_env_bak.keys():
            #os.putenv(key,self.m_hash_env_bak[key])
            os.environ[key] = self.m_hash_env_bak[key]

    def dumpEnv(self):
        """
        dump all env exported
        """
        rc = ''
        rc = '# Export environ : ' + str(len(self.m_hash_env)) + '\n'
        rc += 'env = {\n'
        keys = self.m_hash_env.keys()
        keys.sort()
        for key in keys:
            val = os.environ.get(key, 'None')
            #val = os.getenv(key)
            #val = os.popen('echo ${' + key + '}').read().strip()
            if val:
                #rc += (key + '=' +val + '\n')
                rc += ('"' + key + '" : "' + val + '",\n')
        rc += '}\n'
        return rc

    def expandExpr(self, expr):
        """
        expand expression ,replace environment parameters with value
        """
        return os.path.expandvars(expr)

    def addCfg(self, cfg):
        """
        add config file
        """
        self.m_cfgfiles.append(cfg)

    def parseOpts(self, opts):
        """
        parse command line options
        """
        if opts.loglevel:
            self.m_loglevel_fixed = opts.loglevel
            #
        if opts.testcmd:
            self.m_testcmd = opts.testcmd
            self.m_mode = 1
        elif opts.execute:
            self.m_mode = 2
        else:
            self.m_mode = 0
            # cfgfile
        if opts.cfgfile:
            for cfgs in opts.cfgfile:
                vcfg = cfgs.split(';')
                for cfg in vcfg:
                    if os.path.isfile(cfg):
                        self.addCfg(os.path.abspath(cfg))
                    else:
                        logger.error('Config file (%s) is not exist!' % cfg)
                        syslog.syslog(syslog.LOG_ERR, 'Config file (%s) is not exist!' % cfg)
                        exit(1)
        else:
            logger.error('No config file!')
            syslog.syslog(syslog.LOG_ERR, 'No config file!')
            exit(1)
            # variables tables
        if opts.vos:
            m_hash_export = opts.vos
            for kv in opts.vos:
                #print '==>',kv
                self.addEnv_fixed(kv)

        if opts.mail:
            #print 'send email to :',os.path.expandvars('G_USER')
            #self.m_mailto_lst = os.getenv('G_USER')
            self.m_isMail = True

        if opts.mailto:
            if len(opts.mailto) > 0:
                mailto_lst = ','.join(opts.mailto)
                self.m_mailto_lst = mailto_lst
                #else:
                #    self.m_mailto_lst=os.path.expandvars('$G_USER')

        if opts.psfile:
            self.m_psfile = opts.psfile
        if opts.mappingfile:
            self.m_mappingfile = opts.mappingfile

        # flags for capture log
        self._no_minicom = opts.no_minicom
        self._no_lan_tshark = opts.no_lan_tshark
        self._no_wan_tshark = opts.no_wan_tshark

        self._minicom_method = opts.minicom_method

        if opts.tags:
            for tags in opts.tags:
                for tag in tags.split(','):
                    if len(tag):
                        self._tags.append(tag)
                #os.environ('G_AT_TAGS',','.join(self._tags))
            os.environ['G_AT_TAGS'] = ','.join(self._tags)


        #
        if opts.tcases:
            for tcase in opts.tcases:
                zz = tcase.split(',')
                for tc in zz:
                    if len(tc):
                        self.addCaseToRun(tc)

        if opts.fn_tcases:
            for fn in opts.fn_tcases:
                self.loadCaseToRunFromFile(fn)


    def parseJobTags(self, job):
        """
        """
        line = job['raw_param']
        job['tags'] = []
        m = r'tags=([^;]*);?'
        res = re.findall(m, line)
        if len(res):
            tags = res[0].split(',')
            job['tags'] = tags
            # each tcase contains the default tag 'full'
        if 'full' not in job['tags']:
            job['tags'].append('full')

    def checkJobTags(self, job):
        """
        """

        # if no tags specified, all tags are regard as be accepted
        if self._tags:
            #print '---->',job['tags'],self._tags
            for tag in self._tags:
                if tag in job['tags']:
                    return True
        else:
            return True

        return False


    def load_file(self, fname, parent=None):
        """
        load all files line by line ,and transfer to jobs
        """
        fname = os.path.abspath(fname)
        if fname not in self.m_include:
            self.m_include.append(fname)
        logger.info('Load file : ' + fname)
        job = {}

        if not parent:
            job.update(self.m_runtime)
        else:
            job.update(parent)


        #
        logger.debug('file job has parent : %s' % (pformat(parent)))
        logger.debug('file job before load : %s' % (pformat(job)))




        # append a file
        job['filepath'].append(fname)
        job['linenum'].append(0)
        fullpath = '-->'.join(job['filepath'])
        if len(job['filepath']) > 5:
            logger.error('File nesting greater than 5 : ' + '-->'.join(job['filepath']))
            syslog.syslog(syslog.LOG_ERR, 'File nesting greater than 5 : ' + '-->'.join(job['filepath']))
            ATE_LOGGER.error('EXIT : file nesting greater than 5 : ' + str(fullpath))
            exit(2)
            # openf file to parse


        if not self.isCaseToRun(job):
            #logger.warning('Case is not to run : %s'%str(job['filepath']) )
            print('--ignore job : %s' % fname)
            return
        else:
            #logger.info('Case is in run list : %s in [%s]'%(str(job['filepath']),str(self._cases_whitelist) ) )
            pass


        # ignore the pre_xxx if last pre_xxx is the same

        if self.isSame2LastPre(job):
            logger.info('ignore precondition same to last : %s' % str(job['filepath']))
            print('--ignore precondition  : %s' % fname)
            return
        else:
            #logger.info(' Precondition is not same to last : %s'%str(job['filepath']) )
            pass

        fd = open(fname)
        if fd:
            cc = fd.read()
            if fname.endswith('.case'):
                m = r'^-tc\s*.*'
                res = re.findall(m, cc)
                if len(res) == 0:
                    logger.error('No TCASE in file : %s' % (fname))
                    ATE_LOGGER.error('ERROR : No TCASE in file : %s' % (fname))
                    #exit(1)
                pass

            fd.close()

            fd = open(fname)
            lines = fd.readlines()
            fd.close()

            # parse line by line
            linenum = 0
            for line in lines:
                linenum += 1
                job['linenum'][-1] = linenum
                job['line'] = line
                job['comment'] = ''
                # skip comment line
                if line.strip().startswith('#'):
                    continue

                # cut the comment
                pattern = r'(.*)##(.*)'
                res = re.findall(pattern, line)
                if len(res):
                    line, comment = res[0]
                    #if not job.has_key('comment') :
                    job['comment'] = comment.strip()

                words = line.split()
                if len(words) < 1: continue
                k = words[0]
                v = ''
                if len(words) > 1:
                    #v = words[1]
                    v = ' '.join(words[1:])
                    # make lower
                k = k.lower()
                job['raw_param'] = v
                # skip comment line
                if k.startswith('#'):
                    continue

                #print '===>',k,v
                # PUTENV
                if k == '-v' or k == 'putenv':
                    #kv = os.popen('echo ' + v).read().strip()
                    kv = self.expandExpr(v).strip()
                    job['type'] = 'PUTENV'
                    job['param'] = kv
                    self.addJob(job)
                    self.addVars(job)
                    job = deepcopy(job)
                    (rc, msg) = self.addEnv(kv)
                    if rc:
                        if msg:
                            logger.debug(msg + ' ' + pformat(job))
                    else:
                        if msg:
                            logger.error(msg + ' ' + pformat(job))
                            #(key,val) = self.parseKV(kv)
                            #self.m_hash_env[key] = val
                            #os.putenv(key,val)
                            #self.addEnv(key,val)
                # INCLUDE
                elif k == '-t' or k == '-tags' or k == '--tags':
                    if self.m_check_have_case:
                        logger.error('set MUST before all cases : ' + pformat(job))
                        #logger.error('parse line : ')
                        ATE_LOGGER.error('EXIT : -t should be defined before all cases')
                        exit(1)
                        # tags

                    tags = job['raw_param'].split(',')
                    job['type'] = 'TAGS'
                    #print tags,job
                    #exit(0)
                    for tag in tags:
                        if len(tag):
                            self._tags.append(tag)
                    os.environ['G_AT_TAGS'] = ','.join(self._tags)
                    #print 'G_AT_TAGS :',','.join(self._tags), os.environ.get('G_AT_TAGS')
                    #exit(1)

                elif k.startswith('-f'):
                    pattern = r'-f\*(\d*)'
                    res = re.findall(pattern, k)
                    cntRepeat = 1
                    self.parseJobTags(job)
                    if not self.checkJobTags(job): continue

                    if len(res): cntRepeat = int(res[0])
                    #cmd = 'echo ' + v.split(';')[0]
                    #fn = os.popen(cmd).read().strip()
                    i = 0
                    curline = job['linenum'][-1]
                    while i < cntRepeat:
                        i += 1
                        if i > 1:
                            #print '--->', curline
                            job['linenum'][-1] = str(curline) + '-' + str(i)
                            #print '--->', job['linenum'][-1]
                        fn = self.expandExpr(v.split(';')[0]).strip()
                        job['type'] = 'INCLUDE'
                        fn = os.path.abspath(fn)
                        job['param'] = fn
                        self.addJob(job)
                        newjob = deepcopy(job)
                        if os.path.isfile(fn):
                            self.load_file(fn, newjob)

                        else:
                            logger.error('File not found : ' + pformat(job))
                            syslog.syslog(syslog.LOG_ERR, 'File not found : ' + pformat(job))
                            ATE_LOGGER.error('EXIT : file not found : ' + fn)
                            exit(1)
                elif k == '-e':
                    if self.m_check_have_case:
                        logger.error('set MUST before all cases : ' + pformat(job))
                        exit(1)
                    logger.info('set mode : Check and Run')
                    job['type'] = 'SET_EXE'
                    job['param'] = 'TRUE'
                    self.addJob(job)
                    newjob = deepcopy(job)
                    self.m_mod = 2
                elif k == '-p':
                    if self.m_check_have_case:
                        logger.error('set MUST before all cases : ' + pformat(job))
                        ATE_LOGGER.error('EXIT : -p MUST define before all cases')
                        exit(1)
                    logger.info('set resultfile : ' + v)
                    fn = self.expandExpr(v)
                    fn = os.path.abspath(fn)
                    self.m_psfile = fn
                    job['type'] = 'SET_RESLOG'
                    job['param'] = fn
                    self.addJob(job)
                    newjob = deepcopy(job)
                elif k == '-s':
                    if self.m_check_have_case:
                        logger.error('set MUST before all cases : ' + pformat(job))
                        ATE_LOGGER.error('EXIT : -s MUST define before all cases')
                        exit(1)
                    logger.info('set syslogfile : ' + v)
                    fn = self.expandExpr(v)
                    fn = os.path.abspath(fn)
                    job['type'] = 'SET_SYSLOG'
                    job['param'] = fn
                    self.addJob(job)
                    newjob = deepcopy(job)
                    try:
                        global g_hdlr
                        hdlr = logging.FileHandler(fn)
                        logger.addHandler(hdlr)
                        if g_hdlr:
                            logger.removeHandler(g_hdlr)
                        g_hdlr = hdlr
                    except Exception, e:
                        logger.error('bad syslogfile : ' + v)
                        logger.error(e)
                        ATE_LOGGER.error('EXIT : bad syslogfile : ' + str(v))
                        exit(1)
                elif k == '-x':
                    if self.m_check_have_case:
                        logger.error('set MUST before all cases : ' + pformat(job))
                        ATE_LOGGER.error('EXIT : -x MUST define before all cases')
                        exit(1)
                    logger.info('set loglevel : ' + v)
                    job['type'] = 'SET_LOGLEVEL'
                    lvl = self.expandExpr(v)
                    job['param'] = lvl
                    self.addJob(job)
                    newjob = deepcopy(job)
                    try:
                        if False == self.m_loglevel_fixed:
                            lvl = int(lvl)
                            logger.setLevel(lvl)
                        else:
                            logger.warning(
                                'Ignore to setup fixed loglevel ' + str(self.m_loglevel_fixed) + ' to ' + str(v))
                    except Exception, e:
                        logger.error('bad loglevel : ' + v)
                        logger.error(e)
                        ATE_LOGGER.error('EXIT : bad loglevel : ' + str(v))
                        exit(1)
                elif k.startswith('-nc'):
                    pattern = r'-nc\*(\d*)'
                    res = re.findall(pattern, k)
                    cntRepeat = 1
                    #self.parseJobTags(job)
                    #if not self.checkJobTags(job) : continue
                    if len(res): cntRepeat = int(res[0])

                    plist = v.split(';')
                    #cmd = 'echo ' + v.split(';')[0]
                    #fn = os.popen(cmd).read().strip()
                    fn = plist[0]
                    job['raw_param'] = fn
                    fn = self.expandExpr(fn).strip()
                    job['type'] = 'NCASE'
                    fn = os.path.abspath(fn)
                    job['param'] = fn
                    #
                    rc = self.isDuplicatedNCase(job)
                    if rc:
                        print("==> duplicate ncase(%s) in file(%s:%d)" %
                              (line, job['filepath'][-1], linenum))
                        continue
                        #
                    self.m_check_have_case = True
                    if not os.path.isfile(fn):
                        logger.error('File not found : ' + pformat(job))
                        syslog.syslog(syslog.LOG_ERR, 'File not found : ' + pformat(job))
                        ATE_LOGGER.error('EXIT : file not found : ' + str(fn))
                        exit(1)
                    else:
                        if self.isDuplicateInCaseSinceLastPre(job):
                            continue
                            # preload case
                        case = self.preload_case(job)
                        # add job
                        i = 0
                        while i < cntRepeat:
                            i += 1
                            logger.info('add non-testcase : ' + job['param'])
                            bk = job['linenum'][-1]
                            if i > 1:
                                job['linenum'][-1] = str(job['linenum'][-1]) + '_' + str(i)
                            self.addJob(job)
                            job['linenum'][-1] = bk
                            job = deepcopy(job)
                        job.pop('case')
                elif k.startswith('-tc'):
                    pattern = r'-tc\*(\d*)'
                    res = re.findall(pattern, k)
                    cntRepeat = 1
                    self.parseJobTags(job)
                    if not self.checkJobTags(job): continue
                    if len(res): cntRepeat = int(res[0])

                    self.m_check_have_case = True
                    plist = v.split(';')
                    #cmd = 'echo ' + plist[0]
                    #fn = os.popen(cmd).read().strip()
                    fn = plist[0]
                    job['raw_param'] = fn
                    fn = self.expandExpr(fn).strip()
                    job['type'] = 'TCASE'
                    fn = os.path.abspath(fn)
                    job['param'] = fn
                    if not os.path.isfile(fn):
                        logger.error('File not found : ' + pformat(job))
                        ATE_LOGGER.error('EXIT : file not found : ' + str(fn))
                        exit(1)
                    else:
                        # preload case
                        case = self.preload_case(job)
                        # add job
                        i = 0
                        while i < cntRepeat:
                            i += 1
                            self._tcases_num += 1
                            logger.info('add testcase : ' + job['param'])
                            bk = job['linenum'][-1]
                            if i > 1:
                                job['linenum'][-1] = str(job['linenum'][-1]) + '_' + str(i)
                            self.addJob(job)
                            job['linenum'][-1] = bk
                            job = deepcopy(job)
                        job.pop('case')
                elif k == '-label':
                    #cmd = 'echo ' + v
                    #label = os.popen(cmd).read().strip()
                    label = self.expandExpr(v).strip()
                    job['type'] = 'LABEL'
                    job['param'] = label
                    self.addJob(job)
                    job = deepcopy(job)
                    pass
                elif k == '-goto':
                    label = self.expandExpr(v).strip()
                    job['type'] = 'GOTO'
                    job['param'] = label
                    self.addJob(job)
                    job = deepcopy(job)
                    pass
                elif k == '-cmdline':
                    cmd = self.expandExpr(v).strip()
                    job['type'] = 'CMDLINE'
                    job['param'] = cmd
                    self.addJob(job)
                    job = deepcopy(job)
                elif k == '-pre_cmdline':
                    cmd = self.expandExpr(v).strip()
                    job['type'] = 'PRE_CMDLINE'
                    job['param'] = cmd
                    self.addJob(job)
                    job = deepcopy(job)
                    pass
                elif k == '-testlink':
                    p = self.expandExpr(v).strip()
                    job['type'] = 'TESTLINK'
                    job['param'] = p
                    self.addJob(job)
                    job = deepcopy(job)

                    z = v.split()
                    if len(z) < 2:
                        logger.error('Bad format for -testlink ')
                        ATE_LOGGER.error('EXIT : Invalid line : ' + line)
                        exit(1)
                    else:
                        print(z)
                        rc, err_msg = self.load_testplan_from_testlink(z[0], z[1])
                        if not rc:
                            logger.error('Load testplan(%s) from testlink failed ' % (str(p) ))
                            ATE_LOGGER.error('EXIT : Load test plan from testlink : ' + err_msg)
                            exit(1)
                        pass
                    pass
                else:
                    continue
                    #jobs.append(job)
                    #logger.error('job : ' + pformat(runtime) )
                    #logger.error('jobs : ' + pformat(jobs) )

        else:
            logger.error('File not found : ' + pformat(job))
            syslog.syslog(syslog.LOG_ERR, 'File not found : ' + pformat(job))
            ATE_LOGGER.error('EXIT : file not found : ' + str(fullpath))
            exit(1)
        logger.info('PASS : ' + fullpath)

    def load(self):
        """
        load all : config files,suite files
        """
        # load file
        for fname in self.m_cfgfiles:
            self.resetRuntime()
            self.load_file(fname)
            if self._cases_whitelist:
                case_not_load = []
                for case in self._casefile_whitelist:

                    if case not in self._cases_loaded:
                        case_not_load.append(case)
                        pass
                    else:
                        pass
                    #
                if len(case_not_load):
                    ATE_LOGGER.error(
                        'EXIT : some cases(%d) are failed to load : %s' % (len(case_not_load), str(case_not_load) ))
                    exit(1)
            # check environment
        self.check_vip()
        # save jobs into file
        if self.m_psfile:
            self.saveJobs2File(self.m_psfile)

    def saveJobs2File(self, fn):
        """
        """
        if fn:
            logger.info('Save all jobs into file : ' + fn)
            fd = open(fn, 'w')
            if fd:
                fd.write(self.dumpEnv())
                fd.write('##' * 16 + '\n')
                fd.write(self.dumpJobs())
                #                fd.write('##' * 16 + '\n')
                #                fd.write(self.dump_tools())

                fd.close()
            else:
                pass

    def get_disk_free_GB(self, path):
        """
        """
        vfs = os.statvfs(path)
        total = vfs.f_blocks * vfs.f_bsize
        free = vfs.f_bavail * vfs.f_bsize
        free_gb = float(free) / (1024 * 1024 * 1024)
        return free_gb

    def check_disk_free(self):
        """
        check the disk free for logging
        """
        #pprint(self.m_hash_env.keys().sort() )

        logpath = self.m_hash_env['G_LOG']

        exp_df = self.m_hash_env.get('U_CUSTOM_DISK_FREE_GB', '5')
        try:
            exp_df = float(exp_df)
        except:
            exp_df = 5.0

        #print '--','Here'
        #logpath = os.environ.get('G_LOG', None)
        if logpath:
            vfs = os.statvfs('/root')
            total = vfs.f_blocks * vfs.f_bsize
            free = vfs.f_bavail * vfs.f_bsize
            free_gb = float(free) / (1024 * 1024 * 1024)
            if free_gb < exp_df:
                self.m_syslogger.error(
                    'Free disk(expect U_CUSTOM_DISK_FREE_GB=%.2fG) for logging, but now is only %.2fG !' % (
                    exp_df, free_gb))
                syslog.syslog(syslog.LOG_ERR,
                              'Free disk(expect U_CUSTOM_DISK_FREE_GB=%.2fG) for logging, but now is only %.2fG !' % (
                              exp_df, free_gb))
                exit(1)
            else:

                self.m_syslogger.info(
                    'Free disk(expect U_CUSTOM_DISK_FREE_GB=%.2fG) for logging, now is %.2fG' % (exp_df, free_gb))
        else:
            self.m_syslogger.error('LOG path is empty :', str(logpath))
            syslog.syslog(syslog.LOG_ERR, 'LOG path is empty :', str(logpath))
            exit(1)
        return

    def check_vip(self):
        """
        check Very Important Parameters ,such as G_LOG
        """
        #
        rc = False
        if 1 == self.m_mode:
            return True
        for vip in self.m_vip:
            if self.m_hash_env.has_key(vip) and self.m_hash_env[vip]:
                logger.info('VIP Check : ' + vip + ' = ' + self.m_hash_env[vip])
                rc = True
            else:
                logger.error('VIP Check : ' + vip + ' is not exist')
                syslog.syslog(syslog.LOG_ERR, 'VIP Check : ' + vip + ' is not exist')
                exit(1)
        return rc

    def send_report_mail(self, mailto, mailcc=None, sender=None, subject=None):
        """
        to send email with test result report and failed log
        """

        log_location_path = os.path.expandvars('$G_LOG/current/result.log')
        log_location_dir = os.path.realpath(os.path.expandvars('$G_LOG/current/'))

        #print 'with log result : ' , log_location_path

        if os.path.isfile(log_location_path):
            content_file = log_location_dir + '/report.txt'
            ana_cmd = 'python $SQAROOT/tools/2.0/common/analyzeTRL.py -d ' + log_location_path + ' -s ' + content_file + ' -r $SQAROOT/tools/2.0/common/error_keywords'
            os.system(ana_cmd)

            caselog_cmd = 'find  ' + log_location_dir + ' -type d -name "*FAILED"'
            fd = os.popen(caselog_cmd).read().strip()
            if subject:
                subject += ' ' + os.path.basename(log_location_dir)
            else:
                subject = os.path.basename(log_location_dir)

            if '' != fd:

                fd = fd.replace('\n', '/case.log -a ')
                fd = ' -a ' + fd + '/case.log'

                send_cmd = 'cat ' + content_file + '|mail -a ' + log_location_path + fd + ' -s "' + subject + '" '
            else:
                send_cmd = 'cat ' + content_file + '|mail -a ' + log_location_path + ' -s "' + subject + '" '

            if sender:
                send_cmd += '-r ' + sender + ' '

            if mailcc:
                send_cmd += '-c ' + mailcc + ' '

            send_cmd += mailto

            os.system(send_cmd)


    def launchEmailServer(self):
        """
        """
        if self.m_isMail == True:
        # log_fn = '/tmp/schduled_mail_' + time.asctime().replace(' ', '_') + '.log'

            common_tool_dir = os.path.expandvars('$SQAROOT/tools/2.0/common')

            sm_cmd = 'screen -dmS mail ' + 'python ' + common_tool_dir + '/scheduled_mail.py' #+ '|tee ' + log_fn

            os.system(sm_cmd)

        else:
            pass


    def run(self):
        """
        main entry
        """

        #if self.m_isMail == True:
        #    #schedule_mail = 'ps aux|grep \'python .*scheduled_mail.py\'|grep -v "grep"'
        #    schedule_mail = 'ps aux|grep \'python .*scheduled_mail.py\'|grep -v "grep"'
        #    rc_sm, output_sm = self.subproc(schedule_mail)
        #
        #    print 'output_sm>' + str(output_sm) + '< rc_sm ' + str(rc_sm)
        #
        #    if rc_sm == 0:
        #        sm_pid = int(output_sm.strip().split()[1])
        #        print 'INFO : scheduling email is already running as pid ,', sm_pid
        #        #exit(0)
        #    else:
        #        common_tool_dir = os.path.expandvars('$SQAROOT/tools/2.0/common')
        #        #sm_cmd = 'python ' + common_tool_dir + '/scheduled_mail.py'
        #        sm_cmd = 'screen -dmS mail ' + 'python ' + common_tool_dir + '/scheduled_mail.py'
        #        #self.start_async_subproc(sm_cmd)
        #        os.system(sm_cmd)
        #        #exit(0)
        #
        #    #time.sleep(10)

        rc = True
        self.m_times['starttime'] = timeNowStr()
        self.m_times['start_check'] = time.time()
        # check
        logger.info("\n\nPreloading...")

        # load files
        ATE_LOGGER.info('LAST_STATUS : Preloading')
        self.load()
        ATE_LOGGER.info('LAST_STATUS : Preload done')

        # prepare log path
        ATE_LOGGER.info('LAST_STATUS : Prepare log path')
        self.make_logpath()
        ATE_LOGGER.info('LAST_STATUS : Prepare log path done')

        #backup logs
        ATE_LOGGER.info('LAST_STATUS : Backup logs')
        self.backup_logpath()
        ATE_LOGGER.info('LAST_STATUS : Backup logs done')


        # prepare log file
        ATE_LOGGER.info('LAST_STATUS : Prepare log files')
        self.prepare_logs()
        ATE_LOGGER.info('LAST_STATUS : Prepare log files done')

        # Check disk free
        self.m_syslogger.info('\n\nCheck Disk Free : ')
        ATE_LOGGER.info('LAST_STATUS : check disk free')
        self.check_disk_free()
        ATE_LOGGER.info('LAST_STATUS : check disk free done')

        # Check custom tools
        self.m_syslogger.info('\n\nCheck Custom Tools : ')
        ATE_LOGGER.info('LAST_STATUS : check custom tools')
        cnt = self.check_tools()

        if self.m_mappingfile:
            self.dump_tools()

        if cnt > 0:
            ATE_LOGGER.error('EXIT : check custom tools failed ')
            return False

        ATE_LOGGER.info('LAST_STATUS : check custom tools done')
        # save cases to run
        ATE_LOGGER.info('LAST_STATUS : update cases list')
        self.updateCaseReport()
        ATE_LOGGER.info('LAST_STATUS : update cases list done')

        if 2 == self.m_mode:


            if self._tcases_num == 0:
                ATE_LOGGER.info('LAST_STATUS : prompt tester no tcase')
                self.m_syslogger.warn('\n\t\tThere are no tcase to test !')
                waiting_input('\t\tContinue after 10 seconds or input Enter : ', 10)
                ATE_LOGGER.info('LAST_STATUS : prompt tester no tcase done')

            # show all require variables ,and stay 30 seconds
            #msg = self.dumpVarsRequired()

            ATE_LOGGER.info('LAST_STATUS : prompt tester check required variables')
            msg = self.diffVarsRequired()
            self.m_syslogger.info('\n\nPlease double check these required variables : ')
            self.m_syslogger.info(msg)
            self.m_syslogger.info(
                'Please terminate the test with Ctl+C if has any incorrect parameter, and correct them before you restart test!')
            #self.m_syslogger.info('Or input Enter to continue...')
            #time.sleep(30)
            waiting_input('Continue after 10 seconds or input Enter : ', 10)
            self.saveLastVarsRequired()
            ATE_LOGGER.info('LAST_STATUS : prompt tester check required variables done')


            # Do precondition check first, exit if any error occurred

            self.m_syslogger.info('\n\nDo precondition check')
            ATE_LOGGER.info('LAST_STATUS : precondition check')
            rc, st = self.do_jobs(pre_check=True)
            if not rc:
                ATE_LOGGER.error('EXIT : precondition check failed')
                return False

            ATE_LOGGER.info('LAST_STATUS : precondition check done')
            # count check
            #self.m_times['endtime'] = time.asctime()
            self.m_times['end_check'] = time.time()
            duration = self.m_times['end_check'] - self.m_times['start_check']
            self.m_times['duration_check'] = duration
            self.m_syslogger.info('starttime : ' + self.m_times['starttime'])
            self.m_syslogger.info('duration : ' + str(duration))

        # run case
        if 1 == self.m_mode:
            #print "----"
            if self.m_testcmd:
                #print ('TESTCMD : ' + self.m_testcmd)
                self.m_syslogger.info('TESTCMD : ' + self.m_testcmd)
                ATE_LOGGER.info('LAST_STATUS : test mode')
                os.system(self.m_testcmd)
                ATE_LOGGER.info('LAST_STATUS : test mode done')
        elif 2 == self.m_mode:
            # Do cases

            self.m_syslogger.info('\n\nExecute Test')

            # add DBI
            #ATE_LOGGER.info('LAST_STATUS : DBI inital if ')
            self.initDBI()
            self.dbAddTestTask()

            #
            #jobsfile = os.path.join(os.environ.get('G_CURRENTLOG','/root/automation/logs/current'),'all_jobs' )
            #self.saveJobs2File(jobsfile)

            self.m_times['start_run'] = time.time()
            os.environ['G_TIME_AT_START'] = time.asctime()
            ATE_LOGGER.info('LAST_STATUS : do jobs')


            # do custom commands
            d_file = os.path.join(('/root/automation/logs/current'), 'jobs_before_test')
            o_file = os.path.join(os.getenv('G_CURRENTLOG', '/root/automation/logs/current'), 'jobs_before_test.log')
            self.runCmdFromEnvFiles('U_CUSTOM_FILE_JOBS_PRE_TEST', defile=d_file, logfile=o_file)

            rc, st = self.do_jobs()

            # do custom commands
            d_file = os.path.join(os.getenv('G_LOG', '/root/automation/logs/current'), 'jobs_after_test')
            o_file = os.path.join(os.getenv('G_CURRENTLOG', '/root/automation/logs/current'), 'jobs_after_test.log')
            self.runCmdFromEnvFiles('U_CUSTOM_FILE_JOBS_AFTER_TEST', defile=d_file, logfile=o_file)

            ATE_LOGGER.info('LAST_STATUS : do jobs done')

            os.environ['G_TIME_AT_END'] = time.asctime()

            # END
            #self.saveJobs2File(jobsfile)
            status = 'FINISHED'
            if not rc:
                ATE_LOGGER.error('EXIT : %s' % str(st))
                status = st
                self.dbUpdateTestTask(status=status, msg='')
                return rc
            else:
                pass

            self.dbUpdateTestTask(status=status, msg='')

            # save jobs into file
            if self.m_psfile:
                self.saveJobs2File(self.m_psfile)

                ### sendmail

            #            if '' != self.m_mailto_lst:
            #                mailto = self.m_mailto_lst
            #                print 'sending email to ', mailto
            #
            #                self.send_report_mail(mailto)
            #
            #            elif self.m_isMail == True:
            #
            #                mailto = os.getenv('G_USER')
            #                # G_CC G_FROMRCPT G_TB
            #                mailcc = os.getenv('G_CC')
            #                mail_sender = os.getenv('G_FROMRCPT')
            #
            #                test_prod = os.getenv('U_DUT_TYPE')
            #                tb = os.getenv('G_TB')
            #
            #                #, os.getenv('G_HOST_TIP0_0_0')
            #                if tb == None:
            #                    tb = os.getenv('G_HOST_TIP0_0_0')
            #                elif '' == tb:
            #                    tb = os.getenv('G_HOST_TIP0_0_0')
            #
            #                subject = 'From ' + tb + ' DUT: ' + test_prod
            #
            #
            #                print 'sending email to ', mailto
            #                print 'email carbon copy to ', mailcc
            #                print 'sender ', mail_sender
            #
            #                self.send_report_mail(mailto, mailcc, mail_sender, subject)



        else:
            self.m_syslogger.info('PASS : ' + 'Check Only')
            ATE_LOGGER.info('LAST_STATUS : check only done')
            pass

        return True
        #if self.m_mappingfile:
        #    self.dump_tools()

    def backup_logpath(self):
        """
        """
        logpath = self.m_hash_env['G_LOG']
        sln = self.m_hash_env['G_CURRENTLOG']
        ts = time.strftime('%Y-%m-%d_%H%M%S', time.localtime(time.time()))

        #backup old logs
        bkpath = os.getenv('U_CUSTOM_PATH_BACKUP', None)

        logger.info('Check backup path(U_CUSTOM_PATH_BACKUP) : ' + str(bkpath))
        if not bkpath:
            logger.warning('ignore backup log')
            time.sleep(3)

        if bkpath:
            #
            waiting_input('Continue in 10 seconds or input Enter : ', 10)
            #time.sleep(5)

            bkpath = os.path.abspath(bkpath)
            if not bkpath.endswith('/'): bkpath += '/'

            if not os.path.exists(bkpath):
                logger.info('to make dir :' + bkpath)
                os.makedirs(bkpath)

            #exit(2)
            logger.info('The backup path free disk : ')
            os.system('df -h ' + bkpath)
            free_gb = self.get_disk_free_GB(bkpath)
            exp_df = self.m_hash_env.get('U_CUSTOM_DISK_FREE_GB', '5')
            try:
                exp_df = float(exp_df)
            except:
                exp_df = 5.0
            if exp_df > free_gb:
                logger.info(
                    'Free disk(expect U_CUSTOM_DISK_FREE_GB=%.2fG) for path backup log files(%s), but now is only %.2fG !' % (
                    exp_df, bkpath, free_gb))
                exit(55)

            logpath = os.path.abspath(logpath)

            if os.path.exists(logpath):
                for item in os.listdir(logpath):
                    #ff = logpath + '/' + item
                    ff = os.path.join(logpath, item)
                    nf = os.path.join(bkpath, item)
                    if os.path.islink(ff) or os.path.ismount(ff):
                        logger.info('Can not be removed :' + ff)
                    else:
                        if is_file_last_changed_in_24hour(ff):
                            logger.info('Remain the file/dir modified in last 24 hours :' + ff)
                        else:
                            logger.info('Backup path :' + ff)
                            cmd = '\mv -fu "%s" "%s" ' % (ff, bkpath)
                            #print cmd
                            os.system(cmd)
                            cmd = 'ln -s %s %s/ ' % (nf, logpath)
                            os.system(cmd)
                            time.sleep(1)

    def make_logpath(self):
        """
        make all log path
        """
        logpath = self.m_hash_env['G_LOG']
        sln = self.m_hash_env['G_CURRENTLOG']
        ts = time.strftime('%Y-%m-%d_%H%M%S', time.localtime(time.time()))


        # create logs
        self.m_log_path = os.path.abspath(logpath + '/logs' + ts)
        dut_type = os.getenv('U_DUT_TYPE', 'UNKNOWN')
        self.m_log_path += ('__' + dut_type)

        if not os.path.exists(self.m_log_path):
            os.makedirs(self.m_log_path)


        #
        cmd = 'rm -rf ' + sln + ';' + 'ln -s ' + self.m_log_path + ' ' + sln
        logger.info('Prepare log path : ' + cmd)
        os.system(cmd)

        ATE_LOGGER.info('LOG_PATH : ' + str(self.m_log_path))
        # copy all include files
        dp = os.path.join(self.m_log_path, 'cfgfiles')
        os.makedirs(dp)
        # write menu
        fn_menu = os.path.join(dp, 'menu')
        os.system('echo ####Total cfg files : ' + str(len(self.m_include)) + ' >> ' + fn_menu)
        # copy all files
        for idx, fn in enumerate(self.m_include):
            newfn = '%02d__%s' % (idx + 1, os.path.basename(fn))
            newfn = os.path.join(dp, newfn)
            shutil.copy(fn, newfn)

            os.system('echo "%02d : %s" >> %s' % (idx + 1, fn, fn_menu))


    def prepare_logs(self):
        """
        prepare all loggger
        """
        global g_hdlr
        # add sys logger
        self.m_syslogger = logging.getLogger('ATE.SYS')
        syshdlr = logging.FileHandler(self.m_log_path + '/ATE.log')
        FORMAT = '[%(asctime)-15s %(name)s %(filename)8s-%(funcName)s:%(lineno)-4d %(levelname)-8s] %(message)s'
        syshdlr.setFormatter(logging.Formatter(FORMAT))
        self.m_syslogger.addHandler(syshdlr)
        rsyshdlr = logging.FileHandler(self.m_log_path + '/raw_ATE.log')
        self.m_syslogger.addHandler(rsyshdlr)
        if g_hdlr: self.m_syslogger.addHandler(g_hdlr)

        # add result logger
        self.m_reslogger = logging.getLogger('ATE.RESULT')
        hdlr = logging.FileHandler(self.m_log_path + '/result.log')
        self.m_reslogger.addHandler(hdlr)
        self.m_reslogger.addHandler(syshdlr)
        self.m_reslogger.addHandler(rsyshdlr)
        if g_hdlr: self.m_reslogger.addHandler(g_hdlr)

        # add case logger
        self.m_caselogger = logging.getLogger('ATE.TCASE')
        self.m_caselogger.addHandler(syshdlr)
        self.m_caselogger.addHandler(rsyshdlr)
        if g_hdlr: self.m_caselogger.addHandler(g_hdlr)
        # add step log
        self.m_steplogger = logging.getLogger('ATE.TSTEP')
        self.m_steplogger.addHandler(syshdlr)
        self.m_steplogger.addHandler(rsyshdlr)
        if g_hdlr: self.m_steplogger.addHandler(g_hdlr)


    def add_result(self, txt):
        """
        add a result
        """
        for (k, v) in self.m_results.items():
            self.addEnv(k + '=' + str(v))
        self.m_reslogger.info(txt)

        pass

    def set_case_in_testing(self, job):
        """
        """
        case = job['case']

        fullpath = []
        sz = len(job['filepath'])
        for i in range(0, sz):
            if i == sz - 1:
                fullpath.append(job['filepath'][i])
            else:
                fullpath.append(job['filepath'][i] + ':' + str(job['linenum'][i]))
        tst_path = '-->'.join(fullpath)
        #tst_path = strFullParentPath(job)
        tst_path = strFullTstPath(job)
        #
        tst = None
        for i, t in enumerate(self.m_tst_all):
            if t['name'] == tst_path:
                tst = t
                break
        if tst: self.m_tst_in_testing = tst

    def add_case_result(self, job):
        """
        add a case result
        """
        case = job['case']

        fullpath = []
        sz = len(job['filepath'])
        for i in range(0, sz):
            if i == sz - 1:
                fullpath.append(job['filepath'][i])
            else:
                fullpath.append(job['filepath'][i] + ':' + str(job['linenum'][i]))
            #tst_path = '-->'.join(fullpath)
        #tst_path = strFullParentPath(job)
        tst_path = strFullTstPath(job)

        #
        tst = None

        for i, t in enumerate(self.m_tst_all):
            if t['name'] == tst_path:
                tst = t
                break
        if tst:
            if 'TCASE' == job['type']:

                tst['tc_time'] += float(case['duration'])
                tst['tc_ready'] -= 1
                if 'PASSED' == job['status']:
                    tst['tc_passed'] += 1
                elif 'FAILED' == job['status']:
                    tst['tc_failed'] += 1
                elif 'SKIPPED' == job['status']:
                    tst['tc_skipped'] += 1


            elif 'NCASE' == job['type']:
                tst['nc_time'] += float(case['duration'])
                tst['nc_ready'] -= 1
                if 'PASSED' == job['status']:
                    tst['nc_passed'] += 1
                elif 'FAILED' == job['status']:
                    tst['nc_failed'] += 1
                elif 'SKIPPED' == job['status']:
                    tst['nc_skipped'] += 1

        self.update_runtime_info()

        #print '--------------------->'
        self.updateCaseReport(job)
        #exit(1)
        msg = ''
        msg += ('-' * 32 + '\n')
        msg += '\n[%04d] %s %s %s\n'
        msg += 'Description : %s\n'
        msg += 'Log Path : %s\n'
        msg += 'Testcase Path : %s\n'
        msg += 'Start time : %s\n'
        msg += 'Duration : %.3f\n'
        msg += 'In Testsuite : %s\n'

        self.add_result(msg % (job['case_index'], job['type'], job['status'], case['name'].strip(),
                               case['description'].strip(),
                               str(job['logpath']),
                               job['param'].strip(),
                               str(case['starttime']),
                               float(case['duration']),
                               tst_path)
        )

        if 'FAILED' == job['status']:
            self.add_result("Last Error : \n\t\t%s\n" % case['last_error'])

        #
        self.dbUpdateCase(job)
        if self._first_job_tcase:
            self.dbUpdateTestTask(status='IN TESTING')
        else:
            self.dbUpdateTestTask(status='Preconditon')


        # report status to testlink
        if self._testlink_agent:
            if 'TCASE' == job['type']:
                uuid = ''
                result = ''
                comment = ''
                #

                m = r'(\d{8})_(.*)\.case'
                full_path = strFullParentPath(job)
                res = re.findall(m, full_path)
                if len(res):
                    uuid, case_title = res[0]

                    #
                    if 'PASSED' == job['status']:
                        result = 'p'
                    elif 'FAILED' == job['status']:
                        result = 'f'
                        comment = case['last_error']

                    elif 'SKIPPED' == job['status']:
                        #result = 'b'
                        pass

                    if uuid and result:
                        ATE_LOGGER.info('TestLink : report case(%s) result(%s)' % (uuid, result))
                        self._testlink_agent.report_test_result(uuid, result, comment)
                        pass
                    else:
                        ATE_LOGGER.info('TestLink : not report case(%s) result(%s)' % (uuid, result))
                        pass
                    pass
                else:
                    self.m_syslogger.info('Testlink : TSUITE(%s) is not from testlink' % (tst_path))
                    pass

                pass


    def do_jobs(self, pre_check=False):
        """
        go to test
        """
        # job before test startup
        #if not pre_check :
        #    self.launch_at_redmine()
        #    self.launchEmailServer()



        self.clearEnv()
        results = self.m_results
        lbl = None
        case_idx = 0
        failed_cases = []
        passed_cases = []
        skipped_cases = []
        ignored_cases = []

        skip_rest_lbl = '$G_LOG/current/skip_all_rest.LABEL'

        tcase_done = 0
        ncase_done = 0
        self._first_job_tcase = None
        svr_launched = False
        # Do case
        for job in self.m_jobs:
            if not pre_check:
                if 1 == tcase_done:
                    ATE_LOGGER.info('LAST_STATUS : First tcase done')
                    if not svr_launched:

                        if self._first_job_tcase and self._first_job_tcase['status'] != 'SKIPPED':
                            svr_launched = True
                            self.launch_at_redmine()
                            self.launchEmailServer()
                        else:
                            ATE_LOGGER.error('LAST_STATUS : First tcase skipped')
                            return (False, 'Precondition Failed')

                elif 0 == tcase_done:
                    if job['type'] in ['TCASE']:
                        ATE_LOGGER.info('LAST_STATUS : First tcase start')
                        self.dbUpdateTestTask(status='IN TESTING')
                        self._first_job_tcase = job

            if os.path.exists(os.path.expandvars(skip_rest_lbl)):
                lbl = 'DUT unreachable ! maybe hung up !'
            case = job.get('case', None)
            job['case_index'] = 0
            job['logpath'] = ''
            tp = job['type']
            job['param'] = self.expandExpr(job['raw_param'])

            #            print '--'*16+'printing current job'+'--'*16
            #            pprint(job)
            #            print 'label -->',lbl





            # Do cases
            if self.m_skip_all:
                job['status'] = 'SKIPPED'
                if tp == 'TCASE' or tp == 'NCASE':
                    if tp == 'TCASE': tcase_done += 1
                    self.m_syslogger.info('Skip due to flag all skip : ' + job['param'])
                    skipped_cases.append(job['param'])
                    #job['status'] = 'IGNORED'
                    job['case_index'] = case_idx
                    self.add_case_result(job)
                continue

            # process label jump
            if lbl:
                if tp == 'LABEL' and lbl == job['param']:
                    self.m_syslogger.info('Reach label : ' + lbl)
                    lbl = None
                    continue
                else:
                    job['status'] = 'SKIPPED'
                    if tp == 'TCASE' or tp == 'NCASE':
                        if tp == 'TCASE': tcase_done += 1
                        self.m_syslogger.info('Skip for label : ' + lbl + ' : ' + job['param'])
                        skipped_cases.append(job['param'])
                        #job['status'] = 'IGNORED'
                        job['case_index'] = case_idx
                        case['dt_start'] = datetime.datetime.now()
                        case['dt_end'] = datetime.datetime.now()
                        self.add_case_result(job)
                        continue
                    elif tp == 'PUTENV':
                        # DO NOT skip putenv
                        pass
                    else:
                        continue

            #
            if tp == 'PRE_CMDLINE':
                if pre_check:
                    cmd = job['param']
                    raw_cmd = self.expandExpr(cmd)
                    if raw_cmd in self._pre_check_methods:
                        continue
                    else:
                        self._pre_check_methods.append(raw_cmd)

                    rv, output = self.subproc(cmd, plogger=self.m_syslogger)
                    #self.m_syslogger.info('run command line : ' + job['param'] + '\n' + output)
                    #rv = os.system(cmd)
                    rc = '\n\n'
                    rc += ('--' * 32)
                    rc += '\n\n'
                    rc += ('Precondition Check Comment  : ' + job.get('comment', '') + '\n')
                    rc += ('For Test Suite              : ' + os.path.basename(job['filepath'][-1]) + '\n')
                    rc += ('Command Line                : ' + job.get('param', '') + '\n')

                    if str(rv) == '0':
                        job['status'] = 'PASSED'
                        rc += 'Reulst                      : ' + 'PASSED' + '\n\n'

                        self.m_syslogger.info(rc)
                        ATE_LOGGER.info('LAST_STATUS : Precheck PASSED : %s' % job.get('comment', ''))
                    else:
                        job['status'] = 'FAILED'
                        rc += 'Reulst                      : ' + 'FAILED' + '\n\n'
                        self.m_syslogger.error(rc)
                        ATE_LOGGER.info('LAST_STATUS : Precheck FAILED : %s' % job.get('comment', ''))

                        return (False, 'Precheck Failed')
                else:
                    continue
            elif tp == 'PUTENV':
                #job['param'] = self.expandExpr(job['raw_param'])
                self.addEnv(job['param'])
                job['status'] = 'PASSED'
                pass
            elif tp == 'INCLUDE':
                job['status'] = 'PASSED'
                pass
            elif tp == 'TCASE':
                if pre_check: continue
                # process igonre cases
                ign = os.environ.get('U_CUSTOM_IGNORE_TCASES', None)
                if ign:
                    ign_cases = ign.split(';')
                    if job['param'] in jgn_cases:
                        ignored_cases.append("%04d %s" % (case_idx, job['param']))
                        self.m_syslogger.info('ingored case : ' + job['param'])
                        job['status'] = 'IGNORED'
                        job['case_index'] = case_idx
                        self.add_case_result(job)
                        continue
                    #
                case_idx += 1
                job['case_index'] = case_idx
                results['G_CASE_INDEX'] = case_idx
                rc, err = self.do_case(job)
                if rc:
                    job['status'] = 'PASSED'
                    passed_cases.append("%04d %s" % (case_idx, job['param']))
                    results['G_TCPASS'] += 1
                    goto = case.get('pass_goto', None)
                else:
                    job['status'] = 'FAILED'
                    failed_cases.append("%04d %s" % (case_idx, job['param']))
                    results['G_TCFAIL'] += 1
                    goto = case.get('fail_goto', None)
                self.add_case_result(job)
                if goto: lbl = goto
                tcase_done += 1
                pass
            elif tp == 'NCASE':
                if pre_check: continue
                # process igonre cases
                ign = os.environ.get('U_CUSTOM_IGNORE_TCASES', None)
                if ign:
                    ign_cases = ign.split(';')
                    if job['param'] in jgn_cases:
                        ignored_cases.append("%04d %s" % (case_idx, job['param']))
                        self.m_syslogger.info('ingored case : ' + job['param'])
                        job['status'] = 'IGNORED'
                        job['case_index'] = case_idx
                        self.add_case_result(job)
                        continue
                    #
                case_idx += 1
                job['case_index'] = case_idx
                results['G_CASE_INDEX'] = case_idx
                rc, err = self.do_case(job)
                if rc:
                    job['status'] = 'PASSED'
                    passed_cases.append("%04d %s" % (case_idx, job['param']))
                    results['G_NCPASS'] += 1
                    goto = case.get('pass_goto', None)
                else:
                    job['status'] = 'FAILED'
                    failed_cases.append("%04d %s" % (case_idx, job['param']))
                    results['G_NCFAIL'] += 1
                    goto = case.get('fail_goto', None)
                self.add_case_result(job)
                if goto: lbl = goto
                pass
            elif tp == 'LABEL':
                job['status'] = 'PASSED'
                pass
            elif tp == 'GOTO':
                job['status'] = 'PASSED'
                lbl = job['param']
                pass
            elif tp == 'CMDLINE':
                if pre_check: continue
                cmd = job['param']
                rv, output = self.subproc(cmd, plogger=self.m_syslogger)
                #self.m_syslogger.info('run command line : ' + job['param'] + '\n' + output)
                if str(rv) == '0':
                    job['status'] = 'PASSED'
                else:
                    job['status'] = 'FAILED'
                    #lbl = job['param']

        if pre_check:
            return True, ''

        # count results
        self.m_times['endtime'] = time.asctime()
        self.m_times['end_run'] = time.time()
        duration = self.m_times['end_run'] - self.m_times['start_run']
        self.m_times['duration_run'] = duration
        self.m_times['duration'] = self.m_times['end_run'] - self.m_times['start_check']
        msg = ''
        msg += ('##' * 32 + '\n')
        msg += 'Hardware Version : %s\n'
        msg += 'Software Version : %s\n'
        msg += 'Serial Number : %s\n'
        msg += 'Start Time : %s\n'
        msg += 'Duration(%.3f) : Check(%.3f) : Run(%.3f)\n'
        msg += 'Testcase Results : \n'
        msg += 'NCASES(%03d) : PASSED(%03d) -- FAILED(%03d)\n'
        msg += 'TCASES(%03d) : PASSED(%03d) -- FAILED(%03d)\n'
        msg += 'IGNORE(%03d) \n'
        msg += ('\n' + '--' * 32 + '\nInclude files :\n')
        msg += ('\n'.join(self.m_include))
        msg += ('\n' + '--' * 32 + '\nSkipped cases :\n')
        msg += ('\n'.join(skipped_cases))
        msg += ('\n' + '--' * 32 + '\nIgnored cases :\n')
        msg += ('\n'.join(ignored_cases))
        msg += ('\n' + '--' * 32 + '\nPassed cases :\n')
        msg += ('\n'.join(passed_cases))
        msg += ('\n' + '--' * 32 + '\nFailed cases :\n')
        msg += ('\n'.join(failed_cases))

        cnt_msg = (msg % (os.environ.get('G_HW_VERSION', 'None'),
                          os.environ.get('G_SW_VERSION', 'None'),
                          os.environ.get('U_DUT_SN', 'None'),
                          self.m_times['starttime'],
                          (self.m_times['duration']), (self.m_times['duration_check']), (self.m_times['duration_run']),
                          results['G_NCPASS'] + results['G_NCFAIL'], results['G_NCPASS'], results['G_NCFAIL'],
                          results['G_TCPASS'] + results['G_TCFAIL'], results['G_TCPASS'], results['G_TCFAIL'],
                          results['G_IGNUM']))
        self.add_result(cnt_msg)
        #self.m_syslogger.info(cnt_msg )
        return True, ''


    def do_subcase(self, case, idx, parent_case):
        """
        """
        #
        error_details = []
        rc = True
        last_error = ''

        case['last_error'] = last_error
        steps = case['stage']['step']

        fname = case['name']

        # create new path
        caselogpath = os.environ['G_CURRENTLOG'] + '/' + ("step_" + str(idx)) + '__' + fname
        #print "====> ",caselogpath
        if not os.path.exists(caselogpath):
            os.makedirs(caselogpath)
        case['logpath'] = caselogpath
        # update current log
        tlogpath = os.environ['G_CURRENTLOG']
        os.environ['G_CURRENTLOG'] = caselogpath


        # setup case logger
        caselogger = self.m_caselogger
        steplogger = self.m_steplogger

        # add new case handler
        casehdlr = logging.FileHandler(caselogpath + '/case.log')

        case['casehdlr'] = casehdlr

        caselogger.addHandler(casehdlr)
        steplogger.addHandler(casehdlr)

        steplogger.removeHandler(parent_case['stephdlr'])
        # case result log
        res_logfile = caselogpath + '/result.txt'
        #print "====> reslog file : ", res_logfile
        res_hdlr = logging.FileHandler(res_logfile)
        reslogger = logging.getLogger('ATE.CASE.RESULT.' + res_logfile)

        reslogger.addHandler(res_hdlr)
        reslogger.addHandler(self.m_casehdlr)

        if self.m_at_tag:
            caselogger.info('@@@ The Automation Test Release Tag : ' + self.m_at_tag + '\n\n')

        # print case info
        caselogger.info('--' * 16 + '\n' * 4)
        caselogger.info('Run case    : ' + case['name'].strip())
        caselogger.info('Comment     : ' + case.get('comment', 'None').strip())
        caselogger.info('Description : ' + case.get('description', 'None').strip())

        stephdlr = None

        # run steps
        goto_label = None
        case['starttime'] = time.asctime()
        case['dt_start'] = datetime.datetime.now()
        tbegin = time.time()
        # start tcpdump for ethx
        #self.do_eth_tcpdump()

        #
        self.start_before_case(case)

        for step in steps:
            #
            self.updateEnvFromFile()
            self.updateRuntimeEnvToFile()
            # setup step logger
            begin = time.time()
            step['begintime'] = time.asctime()
            step['duration'] = '0'
            idx = int(step['name'])

            skip_rest_step_lbl = '$G_LOG/current/skip_all_rest.LABEL'

            if os.path.exists(os.path.expandvars(skip_rest_step_lbl)):
                #print 'AT_ERROR : skiped all rest steps for DEBUGGING !'
                self.m_skip_all = True
                caselogger.info('skip step ' + str(idx) + ", due to flag all skip")
                step['result'] = 'SKIPPED'
                rc = False
                break
                #exit(1)

            if goto_label:
                #idx = int(step['name'])
                goto_label = int(goto_label)
                if goto_label == idx:
                    goto_label = None
                    caselogger.warning('run expected step ' + str(idx))
                    pass
                elif goto_label > idx:
                    caselogger.info('skip step ' + str(idx) + ",expect step " + str(goto_label))
                    step['result'] = 'SKIPPED'
                    continue
                else:
                    caselogger.warning('run latest step ' + str(idx) + ",expect step " + str(goto_label))
                    goto_label = None
                    pass
                # remove old hdlr
            if casehdlr:
                steplogger.removeHandler(casehdlr)
            if stephdlr:
                steplogger.removeHandler(stephdlr)
                # add new hdlr
            step['logfile'] = case['logpath'] + '/step_' + step['name'] + '.txt'
            stephdlr = logging.FileHandler(step['logfile'])
            steplogger.addHandler(stephdlr)
            steplogger.addHandler(casehdlr)
            case['stephdlr'] = stephdlr
            #
            steplogger.info('==' * 8 + '\n' * 2)
            steplogger.info('desc : ' + step.get('desc', 'None'))
            steplogger.info('name : ' + step.get('name', 'None'))
            steplogger.info('starttime : ' + time.asctime())
            # run
            step_rc = None
            output = ''
            if step['type'] == 'script' or step['type'] == 'getenv':
                cmd = self.expandExpr(step['command'])
                #steplogger.info('command : ' + cmd)
                cmd = cmd.strip()
                step_rc, output = self.subproc(cmd, plogger=steplogger)
                # add error msg
                m = r'AT_Error\s*:\s*(.*)'
                res = re.findall(m, output, re.I)
                err_msg = ';;'.join(res)
                #for r in res : err_msg += (r + ';;')
                #err_msg = os.getenv('U_AT_ERR_MSG',None)
                if err_msg:
                    error_details.append((step.get('name', 'noname'), step.get('desc', 'nodesc'), cmd, err_msg))
                output.strip()
            elif step['type'] == 'sub':
                pass
            elif step['type'] == 'case':
                steplogger.info('subcase : ' + step['case']['name'])
                step_rc, output = self.do_subcase(step['case'], idx, case)
                # add error msg
                m = r'AT_Error\s*:\s*(.*)'
                res = re.findall(m, output, re.I)
                err_msg = ';;'.join(res)
                #for r in res : err_msg += (r + ';;')
                #err_msg = os.getenv('U_AT_ERR_MSG',None)
                if err_msg:
                    error_details.append((step.get('name', 'noname'), step.get('desc', 'nodesc'), cmd, err_msg))
                output.strip()

                pass

            # parse results
            end = time.time()
            step['endtime'] = time.asctime()
            duration = end - begin
            #step['duration'] = str(duration)
            step['duration'] = ("%.3f" % duration)
            steplogger.info('endtime : ' + time.asctime())
            steplogger.info('duration : ' + str(duration))

            if step_rc is not None and step_rc == 0:
                step['result'] = 'PASSED'
                goto_label = step['passed']
                if step['type'] == 'script':
                    pass
                elif step['type'] == 'getenv':
                    self.putenv(output, steplogger)
                    pass
                elif step['type'] == 'sub':
                    pass
                else:
                    pass
            else:
                if step['noerrorcheck'] and step['noerrorcheck'] == '1':
                    step['result'] = 'PASSED:NOERRORCHECK'
                    goto_label = step['passed']
                else:
                    rc = False
                    step['result'] = 'FAILED'
                    goto_label = step['failed']
            steplogger.warning('jump to next step : ' + str(goto_label))
            msg = "[%-8s]Step %-5s: %-8s:%s"
            txt = (msg % (step['duration'], step['name'], step['result'], step['desc']))
            reslogger.info(txt)
            # rename log path
            prefix = step['result'] + '_'
            fn, dn = os.path.basename(step['logfile']), os.path.dirname(step['logfile'])
            newfile = dn + '/' + prefix + fn
            os.renames(step['logfile'], newfile)
            step['logfile'] = newfile
            if not rc and 0 == len(last_error):
                last_error += (txt)
                last_error += '\n'
                last_error += 'error message details :'
                last_error += '\n'
                for (_name, _desc, _cmd, emsg) in error_details:
                    last_error += ('[' + str(_name) + '][' + str(_desc) + '][' + str(_cmd) + '] : ' + str(emsg))
                    last_error += '\n'
            if self.m_debug:
                self.do_step_debugging()
            # case result
        tend = time.time()
        case['endtime'] = time.asctime()
        case['dt_start'] = datetime.datetime.now()
        case['duration'] = str(tend - tbegin)


        # stop tcpdump for ethx
        #self.do_eth_tcpdump(do_stop=True)
        self.end_after_case(case)

        if rc:
            case['result'] = 'PASSED'
        else:
            case['result'] = 'FAILED'
            case['last_error'] = last_error
            #job['status'] = case['result']

        # rename case log path
        postfix = '_' + case['result']
        newpath = case['logpath'] + postfix
        os.renames(case['logpath'], newpath)
        case['logpath'] = newpath
        # return parent path
        os.environ['G_CURRENTLOG'] = tlogpath

        # close fds
        reslogger.removeHandler(res_hdlr)
        res_hdlr.close()
        res_hdlr = None
        # remove handler
        caselogger.removeHandler(casehdlr)
        steplogger.removeHandler(casehdlr)
        steplogger.removeHandler(stephdlr)
        #
        steplogger.addHandler(parent_case['stephdlr'])

        if rc:
            rc = 0
        else:
            rc = 1

        return rc, last_error


    def do_case(self, job):
        """
        run case
        """

        self.set_case_in_testing(job)
        #if self_in_case_testing
        #
        self.update_runtime_info()


        #
        error_details = []
        rc = True
        last_error = ''
        case = job['case']
        case['last_error'] = last_error
        steps = case['stage']['step']
        job['status'] = 'RUNNING'
        # collect info
        job['param'] = os.path.abspath(job['param'])
        fname = os.path.basename(job['param'])

        case_fullpath = strFullPath(job)
        ATE_LOGGER.info('LAST_STATUS : %s %s %s ' % (job['status'], job['type'], str(case_fullpath)))

        results = self.m_results
        #results['G_CASE_INDEX'] += 1
        idx = results['G_CASE_INDEX']
        # create new path
        #caselogpath = os.environ['G_CURRENTLOG'] + '/' + fname + '_' + str(idx)

        #dut_type = os.getenv('U_DUT_TYPE', 'UNKNOWN')
        #caselogpath = os.environ['G_CURRENTLOG'] + '/' + ("%04d" % int(idx)) + '__' + dut_type + '__' + fname
        caselogpath = os.environ['G_CURRENTLOG'] + '/' + ("%04d" % int(idx)) + '__' + fname
        #print "====> ",caselogpath
        if not os.path.exists(caselogpath):
            os.makedirs(caselogpath)

        job['logpath'] = caselogpath
        # update current log
        tlogpath = os.environ['G_CURRENTLOG']
        os.environ['G_CURRENTLOG'] = caselogpath
        # setup case logger
        caselogger = self.m_caselogger
        steplogger = self.m_steplogger
        # remove old case handler
        if self.m_casehdlr:
            caselogger.removeHandler(self.m_casehdlr)
            steplogger.removeHandler(self.m_casehdlr)
            # close handlers
            self.m_casehdlr.close()
            self.m_casehdlr = None
            # add new case handler
        self.m_casehdlr = logging.FileHandler(caselogpath + '/case.log')
        caselogger.addHandler(self.m_casehdlr)
        steplogger.addHandler(self.m_casehdlr)

        case['casehdlr'] = self.m_casehdlr

        # case result log
        res_logfile = caselogpath + '/result.txt'
        #print "====> reslog file : ", res_logfile
        res_hdlr = logging.FileHandler(res_logfile)
        reslogger = logging.getLogger('ATE.CASE.RESULT.' + res_logfile)

        reslogger.addHandler(res_hdlr)
        reslogger.addHandler(self.m_casehdlr)

        if self.m_at_tag:
            caselogger.info('@@@ The Automation Test Release Tag : ' + self.m_at_tag + '\n\n')

        self.log2minicom('Test case :' + job['param'].strip())
        # print case info
        caselogger.info('--' * 16 + '\n' * 4)
        caselogger.info('Run case    : ' + job['param'].strip())
        caselogger.info('Real file   : ' + os.path.realpath(job['param'].strip()))
        caselogger.info('Comment     : ' + job.get('comment', 'None').strip())
        caselogger.info('Description : ' + case.get('description', 'None').strip())

        # run steps
        goto_label = None
        case['starttime'] = time.asctime()
        case['dt_start'] = datetime.datetime.now()
        tbegin = time.time()
        # start tcpdump for ethx
        #self.do_eth_tcpdump()

        #
        self.start_before_case(case)

        for step in steps:
            #
            self.updateEnvFromFile()
            self.updateRuntimeEnvToFile()
            # setup step logger
            begin = time.time()
            step['begintime'] = time.asctime()
            step['duration'] = '0'
            idx = int(step['name'])

            skip_rest_step_lbl = '$G_LOG/current/skip_all_rest.LABEL'

            if os.path.exists(os.path.expandvars(skip_rest_step_lbl)):
                #print 'AT_ERROR : skiped all rest steps for DEBUGGING !'
                self.m_skip_all = True
                caselogger.info('skip step ' + str(idx) + ", due to flag all skip")
                step['result'] = 'SKIPPED'
                rc = False
                break
                #exit(1)

            if goto_label:
                #idx = int(step['name'])
                goto_label = int(goto_label)
                if goto_label == idx:
                    goto_label = None
                    caselogger.warning('run expected step ' + str(idx))
                    pass
                elif goto_label > idx:
                    caselogger.info('skip step ' + str(idx) + ",expect step " + str(goto_label))
                    step['result'] = 'SKIPPED'
                    continue
                else:
                    caselogger.warning('run latest step ' + str(idx) + ",expect step " + str(goto_label))
                    goto_label = None
                    pass
                # remove old hdlr
            #if self.m_casehdlr :
            #   steplogger.removeHandler(self.m_casehdlr)
            if self.m_stephdlr:
                steplogger.removeHandler(self.m_stephdlr)
                self.m_stephdlr.close()
                self.m_stephdlr = None
                # add new hdlr
            step['logfile'] = job['logpath'] + '/step_' + step['name'] + '.txt'
            self.m_stephdlr = logging.FileHandler(step['logfile'])
            steplogger.addHandler(self.m_stephdlr)
            steplogger.addHandler(self.m_casehdlr)
            case['stephdlr'] = self.m_stephdlr
            #
            steplogger.info('==' * 8 + '\n' * 2)
            steplogger.info('desc : ' + step.get('desc', 'None'))
            steplogger.info('name : ' + step.get('name', 'None'))
            steplogger.info('starttime : ' + time.asctime())
            # run
            step_rc = None
            output = ''
            if step['type'] == 'script' or step['type'] == 'getenv':
                cmd = step['command']
                #cmd = self.expandExpr(step['command'])
                #steplogger.info('command : ' + cmd)
                cmd = cmd.strip()
                step_rc, output = self.subproc(cmd, plogger=steplogger)
                # add error msg
                m = r'AT_Error\s*:\s*(.*)'
                res = re.findall(m, output, re.I)
                err_msg = ';;'.join(res)
                #for r in res : err_msg += (r + ';;')
                #err_msg = os.getenv('U_AT_ERR_MSG',None)
                if err_msg:
                    error_details.append((step.get('name', 'noname'), step.get('desc', 'nodesc'), cmd, err_msg))
                output.strip()
            elif step['type'] == 'sub':
                pass
            elif step['type'] == 'case':
                steplogger.info('subcase : ' + step['case']['name'])
                step_rc, output = self.do_subcase(step['case'], idx, case)
                # add error msg
                m = r'AT_Error\s*:\s*(.*)'
                res = re.findall(m, output, re.I)
                err_msg = ';;'.join(res)
                #for r in res : err_msg += (r + ';;')
                #err_msg = os.getenv('U_AT_ERR_MSG',None)
                if err_msg:
                    error_details.append((step.get('name', 'noname'), step.get('desc', 'nodesc'), cmd, err_msg))
                output.strip()

                pass

            # parse results
            end = time.time()
            step['endtime'] = time.asctime()
            duration = end - begin
            #step['duration'] = str(duration)
            step['duration'] = ("%.3f" % duration)
            steplogger.info('endtime : ' + time.asctime())
            steplogger.info('duration : ' + str(duration))

            if step_rc is not None and step_rc == 0:
                step['result'] = 'PASSED'
                goto_label = step['passed']
                if step['type'] == 'script':
                    pass
                elif step['type'] == 'getenv':
                    self.putenv(output, steplogger)
                    pass
                elif step['type'] == 'sub':
                    pass
                else:
                    pass
            else:
                if step['noerrorcheck'] and step['noerrorcheck'] == '1':
                    step['result'] = 'PASSED:NOERRORCHECK'
                    goto_label = step['passed']
                else:
                    rc = False
                    step['result'] = 'FAILED'
                    goto_label = step['failed']
            steplogger.warning('jump to next step : ' + str(goto_label))
            msg = "[%-8s]Step %-5s: %-8s:%s"
            txt = (msg % (step['duration'], step['name'], step['result'], step['desc']))
            reslogger.info(txt)
            self.log2minicom(txt)
            # rename log path
            prefix = step['result'] + '_'
            fn, dn = os.path.basename(step['logfile']), os.path.dirname(step['logfile'])
            newfile = dn + '/' + prefix + fn
            os.renames(step['logfile'], newfile)
            step['logfile'] = newfile
            if not rc and 0 == len(last_error):
                last_error += (txt)
                last_error += '\n'
                last_error += 'error message details :'
                last_error += '\n'
                for (_name, _desc, _cmd, emsg) in error_details:
                    last_error += ('[' + str(_name) + '][' + str(_desc) + '][' + str(_cmd) + '] : ' + str(emsg))
                    last_error += '\n'
            if self.m_debug:
                self.do_step_debugging()

        # remove last step hdlr
        if self.m_stephdlr:
            steplogger.removeHandler(self.m_stephdlr)
            self.m_stephdlr.close()
            self.m_stephdlr = None

        # case result
        tend = time.time()
        case['endtime'] = time.asctime()
        case['dt_end'] = datetime.datetime.now()
        case['duration'] = str(tend - tbegin)


        # stop tcpdump for ethx
        #self.do_eth_tcpdump(do_stop=True)
        self.end_after_case(case)

        if rc:
            case['result'] = 'PASSED'
            ATE_LOGGER.info('LAST_STATUS : %s %s %s ' % (job['status'], job['type'], str(case_fullpath)))
        else:
            case['result'] = 'FAILED'
            case['last_error'] = last_error

        job['status'] = case['result']

        ATE_LOGGER.info('LAST_STATUS : %s %s %s ' % (job['status'], job['type'], str(case_fullpath)))
        # rename case log path
        postfix = '_' + case['result']
        newpath = job['logpath'] + postfix
        os.renames(job['logpath'], newpath)
        job['logpath'] = newpath
        # return parent path
        os.environ['G_CURRENTLOG'] = tlogpath

        # close fds
        reslogger.removeHandler(res_hdlr)
        res_hdlr.close()
        res_hdlr = None
        #
        return rc, last_error

    def putenv(self, s, logger):
        """
        """
        lines = s.splitlines()
        line = ''
        if len(lines):
            line = lines[-1]

        # get keys
        m1 = r'(\w*)='
        keys = re.findall(m1, line)

        cmd = line
        for key in keys:
            cmd += (';echo ' + key + '="$' + key + '"')

        res = os.popen(cmd).read()

        lines = res.splitlines()
        for line in lines:
            logger.info('putenv : ' + line)
            self.addEnv(line)


    def map_case_all_tools(self, case_name, tool_name):
        ""
        #pprint(self.m_hash_case2tools)

        m_tools = self.m_tools
        m_vars = self.m_vars

        t_file = open(tool_name, 'r')
        lines = t_file.readlines()
        t_file.close()

        for line in lines:
            line = line.strip()
            rc_tool = re.findall(m_tools, line)
            rc_var = re.findall(m_vars, line)

            if len(rc_var) > 0:
                for i in range(len(rc_var)):
                    v = rc_var[i]# + '    - ' + os.path.basename(tool_name)
                    if self.m_hash_case2var.has_key(case_name):
                        if not v in self.m_hash_case2var[case_name]:
                            self.m_hash_case2var[case_name].append(v)
                    else:
                        self.m_hash_case2var[case_name] = [v, ]

                    if self.m_hash_tool2var.has_key(tool_name):
                        if not v in self.m_hash_tool2var[tool_name]:
                            self.m_hash_tool2var[tool_name].append(v)
                    else:
                        self.m_hash_tool2var[tool_name] = [v, ]

            if len(rc_tool) > 0:
                for i in range(len(rc_tool)):
                    curr_tool = os.path.expandvars(rc_tool[i])
                    if os.path.exists(curr_tool):
                        if not curr_tool in self.m_hash_case2tools[case_name]:
                            self.m_hash_case2tools[case_name].append(curr_tool)
                            self.map_case_all_tools(case_name, curr_tool)

                            #pprint(self.m_hash_case2tools[case_name])

    def map_case_tools(self, case_name, case_step):
        ''
        #print self.m_hash_case2tools

        m_tools = self.m_tools
        m_vars = self.m_vars
        m_resrc = self.m_resrc

        commands = case_step['command'].strip().split(';')

        for command in commands:
            #print 'cmd : >' + command + '<'
            rc_tool = re.findall(m_tools, command)
            rc_var = re.findall(m_vars, command)
            rc_resrc = re.findall(m_resrc, command)

            if len(rc_tool) > 0:
                for i in range(len(rc_tool)):
                    curr_tool = os.path.expandvars(rc_tool[i])
                    #print 'find tool : >' + curr_tool + '<'

                    if self.m_hash_case2tools.has_key(case_name):
                        if not curr_tool in self.m_hash_case2tools[case_name]:
                            self.m_hash_case2tools[case_name].append(curr_tool)

                            if os.path.exists(curr_tool):
                                self.map_case_all_tools(case_name, curr_tool)

                                #print '== appending >' + curr_tool
                    else:
                        self.m_hash_case2tools[case_name] = [curr_tool, ]

                        if os.path.exists(curr_tool):
                            self.map_case_all_tools(case_name, curr_tool)

            if len(rc_resrc) > 0:
                for i in range(len(rc_resrc)):
                    v = rc_resrc[i] #+ '    - ' + os.path.basename(case_name)
                    if self.m_hash_case2resrc.has_key(case_name):
                        if not os.path.basename(v) in self.m_hash_case2resrc[case_name]:
                            self.m_hash_case2resrc[case_name].append(os.path.basename(v))
                    else:
                        self.m_hash_case2resrc[case_name] = [os.path.basename(v), ]

            if len(rc_var) > 0:
                for i in range(len(rc_var)):
                    v = rc_var[i] #+ '    - ' + os.path.basename(case_name)
                    if self.m_hash_case2var.has_key(case_name):
                        if not v in self.m_hash_case2var[case_name]:
                            self.m_hash_case2var[case_name].append(v)
                    else:
                        self.m_hash_case2var[case_name] = [v, ]
                        #print 'adding >' + curr_tool
                        #self.map_case_all_tools(case_name, '')

    def preload_casefile(self, casefile, level=0):
        """
        """
        fn = self.expandExpr(casefile).strip()
        fn = os.path.abspath(fn)
        #
        max_level = 5
        rc = False
        case = {}
        case['starttime'] = None
        case['duration'] = 0
        logger.info("Preload Case :" + fn)

        if not os.path.exists(fn):
            logger.error("Case file (" + fn + ") is not exist!")
            syslog.syslog(syslog.LOG_ERR, "Case file (" + fn + ") is not exist!")
            exit(1)
            # load in xml parser
        tree = None
        try:
            tree = etree.parse(fn)
        except Exception, e:
            logger.error("Case file (" + fn + ") is not a xml file : " + str(e))
            syslog.syslog(syslog.LOG_ERR, "Case file (" + fn + ") is not a xml file : " + str(e))
            exit(1)
        root = tree.getroot()
        # add 1st-level node text
        nodes = list(root)
        for node in nodes:
            if not node.text: node.text = ''
            case[node.tag] = node.text
            # add step below stage
        #node_step = root.xpath('stage/step')
        node_stage = root.find('stage')
        if etree.iselement(node_stage):
            pass
        else:
            logger.error('/testcase/stage is not found :' + fn)
            syslog.syslog(syslog.LOG_ERR, '/testcase/stage is not found :' + fn)
            exit(1)
        node_step = node_stage.findall('step')
        steps = len(node_step)
        case['stage'] = {}
        case['stage']['step'] = []
        arr_steps = case['stage']['step']
        for step in node_step:
            childs = list(step)
            case_step = {
                'desc': '',
                'name': '',
                'passed': None,
                'failed': None,
                'noerrorcheck': None,
                'result': 'NA',
                'command': '',
                'case': None,
                'type': 'script',
            }
            for child in childs: case_step[child.tag] = child.text
            # check tags
            case_step['result'] = 'NA'
            if not case_step['desc']: case_step['desc'] = ''
            if not case_step.get('name', None):
                logger.error('/testcase/stage/step/name is not found :' + fn)
                syslog.syslog(syslog.LOG_ERR, '/testcase/stage/step/name is not found :' + fn)
                exit(1)
            if level > max_level:
                logger.error('case recursion level more than 5 !')
                syslog.syslog(syslog.LOG_ERR, 'case recursion level more than 5 : ' + fn)
                exit(1)

            # check tag sccript/getenv/sub
            if case_step.get('script', None):
                case_step['type'] = 'script'
                case_step['command'] = case_step['script']
                #case_step['command'] = os.popen('echo "' + case_step['script'] + '"').read().strip()
                pass
            elif case_step.get('getenv', None):
                case_step['type'] = 'getenv'
                case_step['command'] = case_step['getenv']
                #case_step['command'] = os.popen('echo "' + case_step['getenv'] + '"').read().strip()
                pass
            elif case_step.get('sub', None):
                case_step['type'] = 'sub'
                case_step['command'] = case_step['sub']
                #case_step['command'] = os.popen('echo "' + case_step['sub'] + '"').read().strip()
                pass
            elif case_step.get('case', None):
                case_step['type'] = 'case'
                level += 1
                case_step['case'] = self.preload_casefile(case_step['case'], level)
                #case_step['command'] = os.popen('echo "' + case_step['sub'] + '"').read().strip()
                pass
            else:
                case_step['type'] = 'script'
                case_step['command'] = ' '
                #logger.warning('script ,getenv and sub below /testcase/stage/step/ is not found :' + fn + '\n' + pformat(case))
            # add step
            arr_steps.append(case_step)
            #if self.m_mappingfile:
            self.map_case_tools(casefile, case_step)


        # sort case
        arr_steps.sort(lambda x, y: cmp(int(x['name']), int(y['name'])))
        logger.debug(pformat(arr_steps))
        logger.debug(pformat(case))

        return case


    def preload_case(self, job):
        """
        parse xml format case file
        """




        #
        rc = False
        case = {}
        fn = job['param']
        case['starttime'] = None
        case['duration'] = 0
        logger.info("Preload Case :" + fn)
        # parse goto
        line = job['line'].strip()
        segments = line.split(';')
        cnt = len(segments)
        for i in range(1, cnt):
            seg = segments[i]
            (k, v) = self.parseKV(seg)
            if v and len(v):
                k = k.lower()
                if k == 'fail':
                    case['fail_goto'] = v
                elif k == 'pass':
                    case['pass_goto'] = v
                else:
                    logger.error("Preload Case :" + fn)

        # load in xml parser
        tree = None
        try:
            tree = etree.parse(fn)
        except Exception, e:
            #print '!!', e
            syslog.syslog(syslog.LOG_ERR, 'bad xml format file : ' + fn)
            ATE_LOGGER.info('LAST_STATUS : Bad xml format file : %s' % fn)
            exit(1)
        root = tree.getroot()
        # add 1st-level node text
        nodes = list(root)
        for node in nodes:
            if not node.text: node.text = ''
            case[node.tag] = node.text
            # add step below stage
        #node_step = root.xpath('stage/step')
        node_stage = root.find('stage')
        if etree.iselement(node_stage):
            pass
        else:
            logger.error('/testcase/stage is not found :' + fn)
            ATE_LOGGER.info('LAST_STATUS : Xml file loss required node(/testcase/stage): %s' % fn)
            exit(1)
        node_step = node_stage.findall('step')
        steps = len(node_step)
        #if steps > 0 :
        #   pass
        #else :
        #   logger.error('/testcase/stage/step is not found :' + fn)
        #   exit(1)


        case['stage'] = {}
        case['stage']['step'] = []
        arr_steps = case['stage']['step']
        for step in node_step:
            childs = list(step)
            case_step = {
                'desc': '',
                'name': '',
                'passed': None,
                'failed': None,
                'noerrorcheck': None,
                'result': 'NA',
                'command': '',
                'case': None,
                'type': 'script',
            }
            for child in childs: case_step[child.tag] = child.text
            # check tags
            case_step['result'] = 'NA'
            if not case_step['desc']: case_step['desc'] = ''
            if not case_step.get('name', None):
                logger.error('/testcase/stage/step/name is not found :' + fn)
                syslog.syslog(syslog.LOG_ERR, '/testcase/stage/step/name is not found :' + fn)
                exit(1)
                # check tag sccript/getenv/sub
            if case_step.get('script', None):
                case_step['type'] = 'script'
                case_step['command'] = case_step['script']
                #case_step['command'] = os.popen('echo "' + case_step['script'] + '"').read().strip()
                pass
            elif case_step.get('getenv', None):
                case_step['type'] = 'getenv'
                case_step['command'] = case_step['getenv']
                #case_step['command'] = os.popen('echo "' + case_step['getenv'] + '"').read().strip()
                pass
            elif case_step.get('sub', None):
                case_step['type'] = 'sub'
                case_step['command'] = case_step['sub']
                #case_step['command'] = os.popen('echo "' + case_step['sub'] + '"').read().strip()
                pass
            elif case_step.get('case', None):
                case_step['type'] = 'case'
                level = 0
                case_step['case'] = self.preload_casefile(case_step['case'], level)
                #case_step['command'] = os.popen('echo "' + case_step['sub'] + '"').read().strip()
                pass
            else:
                case_step['type'] = 'script'
                case_step['command'] = ' '
                #logger.warning('script ,getenv and sub below /testcase/stage/step/ is not found :' + fn + '\n' + pformat(case))
            # add step
            arr_steps.append(case_step)
            #print "adding case_step for  %s" % (job['param'])
            #pprint(case_step)
            #if self.m_mappingfile:
            self.map_case_tools(job['param'], case_step)

        # sort case
        #print '=='
        arr_steps.sort(lambda x, y: cmp(int(x['name']), int(y['name'])))
        logger.debug(pformat(arr_steps))
        logger.debug(pformat(case))
        # get steps
        #pprint(case)
        job['case'] = case
        return case
        #return arr_steps

    def updateEnvFromFile(self):
        """
        """
        fname = os.getenv('U_CUSTOM_UPDATE_ENV_FILE', None)

        if not fname:
            self.m_syslogger.warning('U_CUSTOM_UPDATE_ENV_FILE is not defined')
            return True

        if fname: fname = self.expandExpr(str(fname))
        if not os.path.exists(fname):
            self.m_syslogger.warning('U_CUSTOM_UPDATE_ENV_FILE(' + fname + ') is not found')
            return True
        fd = open(fname, 'r')
        lines = []
        if fd:
            lines = fd.readlines()
            fd.close()
            #
        os.system('rm -rf ' + fname)
        #
        self.m_syslogger.info('try update the env in U_CUSTOM_UPDATE_ENV_FILE(' + fname + ') : ' + pformat(lines))
        for line in lines:
            ss = line.strip()
            if ss.startswith('#'):
                pass
            else:
                self.addEnv(ss)
                self.m_syslogger.debug('update ENV : ' + ss)


    def updateRuntimeEnvToFile(self):
        """
        """
        # save RunTime ENV

        fname = os.getenv('U_CUSTOM_RUNTIME_ENV_FILE', os.getenv('G_LOG', '/root') + "/current/runtime_env")
        if not fname:
            self.m_syslogger.warning('U_CUSTOM_RUNTIME_ENV_FILE is not defined')
            return True
        if fname: fname = self.expandExpr(str(fname))
        fdir = os.path.dirname(fname)
        if not os.path.exists(fdir):
            os.makedirs(fdir)
        fd = open(fname, 'w')
        if fd:
            for k, v in sorted(os.environ.items(), key=lambda d: d[0]):
                if k.startswith('G_') or k.startswith('U_') or k.startswith('TMP_'):
                    s = 'export ' + k + '="' + v + '"\n'
                    fd.write(s)
            fd.close()

        return True

    def tcpdump_eth_start(self, eth_if, logfile):
        #cmd = 'nohup tshark -a duration:3600 -i ' + str(eth_if) + ' -s 0 -w ' + str(logfile) + ' > /dev/null 2>&1 &'
        #self.lanpc_cmd(cmd)


        #cmd = 'tshark -a duration:3600 -i ' + str(eth_if) + ' -s 0 -w ' + str(logfile)
        cmd = 'tshark -B 10 -i ' + str(eth_if) + ' -s 0 -w ' + str(logfile)
        p = self.lanpc_cmd_async(cmd)
        self.m_subp_async.append(p)

        return True

    def tcpdump_eth_stop(self, eth_if, logfile):
        #pids = os.popen('ps ax | grep -v grep | grep \'' + str(eth_if) + '\'| grep \'' + str(logfile) + '\' | awk \'{print $1}\' | ').read().splitlines()
        #print 'pids:',pids
        #for pid in pids :
        #    os.system('kill  ' + pid)
        #cmd = 'ps ax | grep -v grep | grep \'' + str(eth_if) + '\'| grep \'' + str(logfile) + '\' | awk \'{print $1}\' | xargs -n1 kill '
        #self.lanpc_cmd(cmd)

        if self.m_pid_local_tcpdump:
            rc = self.stop_async_subporc(self.m_pid_local_tcpdump, self.m_caselogger)
            self.m_syslogger.info('exit local tshark code : ' + str(rc))
            self.m_pid_local_tcpdump = None
        return True

    def do_eth_tcpdump(self, do_stop=False):
        """
        """
        currlog = os.getenv('G_CURRENTLOG', None)
        if not currlog:
            return

        eth1 = os.getenv('G_HOST_IF0_1_0', None)
        eth2 = os.getenv('G_HOST_IF0_2_0', None)
        eth1_log = None
        eth2_log = None
        if eth1:
            eth1_log = currlog + '/lan_' + eth1 + '.cap'
            if do_stop:
                self.tcpdump_eth_stop(eth1, eth1_log)
            else:
                self.tcpdump_eth_start(eth1, eth1_log)
        if eth2:
            eth2_log = currlog + '/lan_' + eth2 + '.cap'
            if do_stop:
                self.tcpdump_eth_stop(eth2, eth2_log)
            else:
                self.tcpdump_eth_start(eth2, eth2_log)

    def do_step_debugging(self):
        """
        """
        rc = raw_input("\033[33mInput 'E/e' to exit debug mode and any other to continue :\033[0m")
        if rc == 'E' or rc == 'e':
            self.m_syslogger.info('Exit debug mode and to run cases normally!')
            self.m_debug = False
        else:
            self.m_syslogger.info('Continue debug mode')

    def update_runtime_info(self):
        """
        """
        # save RunTime test suites info
        logroot = os.getenv('G_LOG', None)
        fname = os.getenv('U_CUSTOM_RUNTIME_STATUS_FILE',
                          logroot + '/current/runtime_status_' + os.getenv('U_DUT_TYPE', 'UNKNOWN'))
        if fname: fname = self.expandExpr(str(fname))

        fname = os.path.abspath(fname)

        logger.info('Save Runtime test suites info to ' + fname)
        fd = open(fname, 'w')

        #
        pid = os.getpid()
        at_tag = self.m_at_tag
        if at_tag:
            if at_tag.find('AT_') < 0:
                if len(at_tag) > 8:
                    at_tag = at_tag[:8]
        else:
            #print 'AT tag is empty!'
            at_tag = 'UNKNOWN'
            #exit(1)

        if fd:
            # add product info
            inf = '-----------------------------------\n'
            inf += ('ATE_PID                : ' + str(pid) + '\n')
            inf += ('AT_TAG                 : ' + str(at_tag) + '\n')
            inf += ('DUT_PRODUCT_TYPE       : ' + os.getenv('U_DUT_TYPE', 'UNKNOWN') + '\n')
            inf += ('DUT_MODEL_NAME         : ' + os.getenv('U_DUT_MODELNAME', 'UNKNOWN') + '\n')
            inf += ('DUT_SN                 : ' + os.getenv('U_DUT_SN', 'UNKNOWN') + '\n')
            inf += ('DUT_FW                 : ' + os.getenv('U_DUT_SW_VERSION', 'UNKNOWN') + '\n')
            inf += (
            'DUT_POST_FILES_VER     : ' + os.getenv('U_DUT_TYPE', 'UNKNOWN') + '_' + os.getenv('U_DUT_FW_VERSION',
                                                                                               'UNKNOWN') + '\n')

            fd.write(inf)

            # duration
            tot_dur = time.time() - self.m_times['start_run']
            pretty_dur = ('%02dH:%02dM:%02dS' % pp_duration(tot_dur))
            last_update = time.asctime()

            inf = '-----------------------------------\n'
            inf += ('UPDATE TIME      : ' + last_update + '\n')
            inf += ('TEST BEGIN       : ' + self.m_times['starttime'] + '\n')
            inf += ('DURATION         : ' + pretty_dur + '\n')

            fd.write(inf)

            # add title
            #title  = 'INDEX '
            #title += 'TC_TOTAL   TC_READY  TC_PASSED  TC_FAILED  TC_SKIPPED '
            #title += 'NC_TOTAL   NC_READY  NC_PASSED  NC_FAILED  NC_SKIPPED '
            #title += 'SUITE_NAME\n'
            title = '-----------------------------------\n'
            title += "Column Comment :\n"
            title += 'IDX                 : The order index to run\n'
            title += 'TCT/TCR/TCP/TCF/TCS : The number of Testcase (Total,Ready to run, Passed, Failed, Skipped)\n'
            title += 'NCT/NCR/NCP/NCF/NCS : The number of Noncase (Total,Ready to run, Passed, Failed, Skipped)\n'
            title += '-----------------------------------\n'
            title += 'IDX '
            title += 'TCT TCR TCP TCF TCS '
            title += 'NCT NCR NCP NCF NCS '
            title += 'SUITE_NAME\n'
            #fd.write(title)

            # add item
            #fmt = '%-5s %-32s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s \n'

            fmt = '%03d %03d %03d %03d %03d %03d %03d %03d %03d %03d %03d %s\n'

            tot = [0] * 10

            flag_in_testing = False
            for i, tst in enumerate(self.m_tst_all):
                #name = tst['name']
                tpath = tst['name']
                #name = tpath.split('/')[-1]
                #tabs count
                #cn = len(re.findall(r'-->', tpath))
                name = os.path.basename(tpath)
                cn = len(re.findall(r'/', tpath))

                #name = ( name + '(' + tpath + ')')
                if cn >= 1:
                    name = ('├── ' + name)
                for ii in range(1, cn):
                    name = ('│   ' + name)

                tc_total = (tst['tc_total'])
                tc_ready = (tst['tc_ready'])
                tc_passed = (tst['tc_passed'])
                tc_failed = (tst['tc_failed'])
                tc_skipped = (tst['tc_skipped'])

                nc_total = (tst['nc_total'])
                nc_ready = (tst['nc_ready'])
                nc_passed = (tst['nc_passed'])
                nc_failed = (tst['nc_failed'])
                nc_skipped = (tst['nc_skipped'])

                tot[0] += tc_total
                tot[1] += tc_ready
                tot[2] += tc_passed
                tot[3] += tc_failed
                tot[4] += tc_skipped

                tot[5] += nc_total
                tot[6] += nc_ready
                tot[7] += nc_passed
                tot[8] += nc_failed
                tot[9] += nc_skipped

                st = ''
                if tc_total == 0 and nc_total == 0:
                    st = ''
                elif tc_ready == 0 and nc_ready == 0:
                    if tc_failed == 0 and nc_failed == 0 and tc_skipped == 0 and (tc_passed > 0 or nc_passed > 0):
                        st = '    (ALL PASSED)'
                    elif tc_total == tc_failed and nc_total == nc_failed:
                        st = '    (ALL FAILED)'
                    elif tc_total == tc_skipped and nc_total == nc_skipped:
                        st = '    (ALL SKIPPED)'
                    elif tc_total > 0 and tc_total == tc_passed:
                        st = '    (TCASE ALL PASSED)'
                    elif tc_total > 0 and tc_total == tc_failed:
                        st = '    (TCASE ALL FAILED)'
                    elif tc_total > 0 and tc_total == tc_skipped:
                        st = '    (TCASE ALL SKIPPED)'

                    else:
                        st = '    (ALL DONE)'

                elif self.m_tst_in_testing == tst:
                    st = '    (IN TESTING)'

                if len(st):
                    name += st
                    tst['status'] = st

                ss = fmt % ((i + 1), tc_total, tc_ready, tc_passed, tc_failed, tc_skipped,
                            nc_total, nc_ready, nc_passed, nc_failed, nc_skipped,
                            name)

                #fd.write(ss)
            # write amounts
            ss = '-----------------------------------\n'
            fmt = 'SUM %03d %03d %03d %03d %03d %03d %03d %03d %03d %03d \n'
            ss += (fmt % (tot[0], tot[1], tot[2], tot[3], tot[4], tot[5], tot[6], tot[7], tot[8], tot[9]))
            #fd.write(ss)
            #
            ss = '\n\n-----------------------------------\n'
            ss += 'Test suites results :\n\n'
            fd.write(ss)

            sum_tst = 0
            notrun_tst = 0
            tc_total = 0
            tc_passed = 0
            tc_failed = 0
            tc_skipped = 0
            tc_dur = 0

            for i, tst in enumerate(self.m_tst_all):
                tpath = tst['name']
                #name = tpath.split('/')[-1]
                name = os.path.basename(tpath)
                fmt = '\n'
                fmt += 'Test Suite Name : %s\n'
                fmt += 'Test Status     : %s\n'
                fmt += 'Expected: %d, Executed: %d, Passed: %d, Failed: %d, Skipped: %d, Missed: %d\n'
                fmt += 'Total test time of the test suite   : %s Hours\n'
                fmt += 'Average test time of the test suite : %s Minutes\n'
                fmt += '\n'
                ts_time = float(tst['tc_time'])
                s_dur = ('%02dH:%02dM:%02dS' % pp_duration(ts_time))
                s_avg = '0'
                if (tst['tc_passed'] + tst['tc_failed']) > 0:
                    s_avg = ('%02dH:%02dM:%02dS' % pp_duration(ts_time / (tst['tc_passed'] + tst['tc_failed'])))

                if tst['tc_total'] > 0:
                    sum_tst += 1
                    if tst['status'] == 'Not Start':
                        notrun_tst += 1
                    tc_total += tst['tc_total']
                    tc_passed += tst['tc_passed']
                    tc_failed += tst['tc_failed']
                    tc_skipped += tst['tc_skipped']
                    tc_dur += ts_time

                    ss = fmt % (name, tst['status'],
                                tst['tc_total'], tst['tc_total'] - tst['tc_ready'], tst['tc_passed'], tst['tc_failed'],
                                tst['tc_skipped'], 0,
                                s_dur, s_avg)
                    fd.write(ss)

            fmt = '\n\n-----------------------------------\n'
            fmt += 'Test suites sum results :\n\n'
            fmt += 'Total suites     : %d \n'
            fmt += 'Not start suites : %d \n'
            fmt += 'Tested suites    : %d , Expected: %d, Executed: %d, Passed: %d, Failed: %d, Skipped: %d, Missed: %d\n'
            fmt += 'Total test time of the test suite   : %s \n'
            fmt += 'Average test time of the test suite : %s \n'

            dur = tc_dur
            if (tc_passed + tc_failed) > 0:
                dur = tot_dur

            s_dur = ('%02dH:%02dM:%02dS' % pp_duration(dur))
            s_avg = '0'
            cases_done = tc_passed + tc_failed + nc_passed + nc_failed
            if (cases_done) > 0:
                s_avg = ('%02dH:%02dM:%02dS' % pp_duration(tc_dur / (cases_done)))
            ss = fmt % (sum_tst, notrun_tst,
                        sum_tst - notrun_tst, tc_total, tc_passed + tc_failed + tc_skipped, tc_passed, tc_failed,
                        tc_skipped, 0,
                        s_dur, s_avg)
            fd.write(ss)
            #
            fd.close()

        return True

    def restart_minicom(self):
        """
        """

        self._minicom_log = ''
        currlog = os.getenv('G_CURRENTLOG', None)
        if not currlog:
            return False
            #
        minicom_cap = ''
        pid = ''

        self.getMinicomDevName()

        # force exit minidom
        self.lanpc_cmd('killall minicom')
        for i in range(10):
            pid = os.popen('pgrep minicom').read().strip()
            if len(pid) > 0:
                time.sleep(2)
            else:
                break

        # start minicom
        logroot = os.getenv('G_LOG', '/root')
        o_file = logroot + '/current/minicom.log'
        o_file = os.path.abspath(o_file)
        self._minicom_log = o_file
        cmd = 'screen -dmS at_minicom minicom -l -c on -C ' + o_file

        spf = os.environ.get('U_CUSTOM_MINICOM_SCRIPT', None)
        if spf and os.path.exists(spf):
            fn = '/tmp/minicom_script'
            os.system('cp -rf ' + spf + ' ' + fn)
            cmd += (' -S ' + fn)
            #self.lanpc_cmd_async(cmd)
        #self.start_async_subproc(cmd, self.m_caselogger)
        os.system(cmd)

        minicom_cap = o_file
        self.m_syslogger.info('---> minicom log file : ' + minicom_cap)

        return True

    def getMinicomDevName(self, cfg=None):
        """
        """
        fn = '/etc/minirc.dfl'
        if cfg: fn = cfg
        lines = []
        try:
            fd = open(fn, 'r')
            if fd:
                lines = fd.readlines()
                fd.close()
        except:
            return False

        devName = '/dev/ttyS0'
        m = '(/dev/\w*)'
        for line in lines:
            ss = line.strip()
            if not ss.startswith('#'):
                r = re.findall(m, ss)
                if len(r):
                    devName = r[0]
                    self._minicom_dev = devName
                    break

        return devName

    def log2minicom_new(self, log):
        """
        """
        if not self._minicom_log: return
        if not self._minicom_dev: return

        if not os.path.exists(self._minicom_log):
            os.system('touch ' + self._minicom_log)

        o_file = os.environ['G_CURRENTLOG'] + '/minicom.log'

        # 1. send msg to minicom Device
        tt = time.asctime()
        cmd = 'echo -e "' + ('\n\nAT_LANPC_LOG_[' + tt + ']: ' + log + '\n\n') + '"' + ' > ' + self._minicom_dev
        os.system(cmd)

        # 2. Get total lines
        tot_lines = 0
        cmd = 'time echo "TOTAL_LINES : `grep -c \"\" %s`" ' % (self._minicom_log)

        rc, res = self.lanpc_cmd(cmd)
        #print '>>>',rc
        #print '>>>',res
        if 0 == rc and len(res):
            m = r'TOTAL_LINES\s*:\s*(\d*)'
            rr = re.findall(m, res)
            #print 'rr:',rr
            if len(rr):
                tot_lines = int(rr[0])

        #
        if tot_lines > self._minicom_last_line_no:
            #
            cmd = 'time sed -n \'%d,$p\' %s >> %s' % (self._minicom_last_line_no + 1, self._minicom_log, o_file)
            self._minicom_last_line_no = tot_lines
            self.lanpc_cmd(cmd)
            # Check in CFE or not
            cmd = 'time sed -n \'$p\' %s ' % (self._minicom_log)
            last_line = os.popen(cmd).read()
            if last_line.find('CFE>') >= 0:
                self.m_syslogger.info('Find DUT stay in CFE> , try echo r to console')
                cmd = 'echo r > ' + self._minicom_dev
                os.system(cmd)
        else:
            # when line count is not changed ,means the minicom works incorrectly , need to restart it
            self.restart_minicom()


    def log2minicom(self, log):
        """
        append the log to minicom log file, help to debug error
        """
        # remove this function, due to the log file will be unstable
        #return
        os.system('sync')
        if not self._no_minicom and self._minicom_log:
            minicom_cap = self._minicom_log
            # cut logs from minicom log file
            lines = []

            if self._minicom_method == 1:
                fd = open(self._minicom_log, 'r')
                if fd:
                    lines = fd.readlines()
                    fd.close()
                txt = lines[self._minicom_last_line_no:]
                self._minicom_last_line_no = len(lines)

                # save to case log file
                o_file = os.environ['G_CURRENTLOG'] + '/minicom.log'
                fd = open(o_file, 'a')
                if fd:
                    tt = time.asctime()
                    fd.writelines(txt)
                    fd.write('\n\nAT_LOG_TO_MINICOM [' + tt + ']: ' + log + '\n\n')
                    fd.close()
            else:
                self.log2minicom_new(log)

        return

    def do_truncate_minicomlog(self, finished=False):
        """
        """

        is_minicom2file = os.getenv('IS_MINICOM2FILE', '1')

        if is_minicom2file == '1':

            #force_new_minicom = True
            force_new_minicom = False

            if force_new_minicom:
                if finished: return
                # start minicom capture
                o_file = os.environ['G_CURRENTLOG'] + '/minicom.log'
                #o_file = '/root/abcd'

                # try to kill existed
                #pid = os.popen('ps -C minicom -o pid=').read()
                pid = os.popen('pgrep minicom').read()
                if len(pid.strip()):
                    #print '===> To killall minicom'
                    os.system('killall -9 minicom ; sleep 5')
                    # go
                os.system('echo -e " =======> Start case at :`date` \n\n" > ' + o_file)

                cmd = 'minicom -o -C ' + o_file
                self._minicom_log = o_file
                spf = os.environ.get('U_CUSTOM_MINICOM_SCRIPT', None)
                if spf and os.path.exists(spf):
                    fn = '/tmp/minicom_script'
                    os.system('cp -rf ' + spf + ' ' + fn)
                    cmd += (' -S ' + fn)

                p = self.start_async_subproc(cmd, self.m_caselogger)
                self.m_subp_async.append(p)
            else:
                currlog = os.getenv('G_CURRENTLOG', None)
                if not currlog:
                    return
                    #
                minicom_cap = ''
                pid = ''

                if not finished:
                    cmd = 'ps -C "minicom -C" -o pid= -o cmd='
                    rr, res = self.lanpc_cmd(cmd)
                    z = res.split()
                    if len(z) >= 4:
                        pid = z[0].strip()
                        minicom_cap = z[-1].strip()
                    self.m_syslogger.info('---> res : ' + res)
                    self.m_syslogger.info(
                        '---> minicom log file : ' + minicom_cap + ' ,expected : ' + str(self._minicom_log))

                    # we need to start a new minicom
                    if (minicom_cap != self._minicom_log) or (0 == len(pid.strip())):
                        self.restart_minicom()
                    else:
                        pass

                        #self.m_syslogger.info('---> minicom log file : ' + minicom_cap)
                else:
                    # case done
                    if self._minicom_log:
                        minicom_cap = self._minicom_log
                        #self.lanpc_cmd('cp -rf ' + minicom_cap + ' ' + os.path.expandvars(currlog + '/minicom.log'))
                        #self.lanpc_cmd('echo `date` >' + minicom_cap)
                        if self._minicom_method == 1:
                            pass

                            #
        return True

    def start_before_case(self, case):
        """
        """
        if not self._no_lan_tshark:
            # start LAN PC tcpdump
            self.do_eth_tcpdump()

            # show LAN PC status
            cmd = "ifconfig | grep eth | cut -d' ' -f1 | xargs -i mii-tool {} ;ifconfig;ifconfig -a;route -n;netstat -lnptu;ps aux;df -h;free -m "
            show_cmd = os.environ.get('U_CUSTOM_TB_SHOW', cmd)
            resp = os.popen(show_cmd).read()
            o_file = os.environ['G_CURRENTLOG'] + '/lanpc_info'
            fd = open(o_file, 'w')
            if fd:
                fd.write(resp)
                fd.close()

            #
            o_file = os.environ['G_CURRENTLOG'] + '/lanpc_syslog'
            cmd = 'tail -f /var/log/messages  > %s' % o_file

            #p = self.lanpc_cmd_async(cmd)
            #self.m_subp_async.append(p)

        #
        if not self._no_minicom:
            # minicom
            self.do_truncate_minicomlog()

        if not self._no_wan_tshark:
            # start WAN PC tcpdump
            wan_eth = os.environ.get('G_HOST_IF1_2_0', None)
            ts = time.strftime('%Y_%m_%d_%H%M%S', time.localtime(time.time()))
            if wan_eth:
                self.last_wan_cap_file = 'wan_' + wan_eth + '_' + ts + '.cap'
                cap_file = os.environ['G_CURRENTLOG'] + '/wan_' + wan_eth + '_' + ts + '.cap'
                #cmd = 'nohup tshark -a duration:3600  -i ' + wan_eth + ' -s 0 -w ' + cap_file + ' >/dev/null 2>&1 &'
                #rc, output = self.wanpc_cmd(cmd)

                #cmd = 'tshark -B 10 -a duration:3600  -i ' + wan_eth + ' -s 0 -w ' + cap_file
                cmd = 'killall tshark;tshark -B 10 -i ' + wan_eth + ' -s 0 -w ' + cap_file + " > log4cap_wanpc 2>&1"
                p = self.wanpc_cmd_async(cmd)
                self.m_subp_async.append(p)

            # show WAN PC status
            o_file = os.environ['G_CURRENTLOG'] + '/wanpc_info'
            show_cmd = show_cmd.strip()
            #if len(show_cmd) and not show_cmd.endswith(';') :
            #    show_cmd += ';'

            #
            #p = self.wanpc_cmd_async(show_cmd, o_file)
            #self.m_subp_async.append(p)
            self.wanpc_cmd(show_cmd, o_file)

            #
            o_file = os.environ['G_CURRENTLOG'] + '/wanpc_syslog'
            cmd = 'tail -f /var/log/messages  > %s' % o_file
            p = self.wanpc_cmd_async(cmd, timeout=7200)
            self.m_subp_async.append(p)

            #
            cmd = 'killall ping;ping 192.168.55.253 -i 10'
            #o_file = os.environ['G_CURRENTLOG'] + '/wanpc_alive_ping'
            p = self.wanpc_cmd_async(cmd, timeout=7200)
            self.m_subp_async.append(p)

        # do custom commands
        d_file = os.path.join(os.getenv('G_LOG', '/root/automation/logs/current'), 'jobs_before_case')
        o_file = os.path.join(os.getenv('G_CURRENTLOG', '/root/automation/logs/current'), 'jobs_before_case.log')

        self.runCmdFromEnvFiles('U_CUSTOM_FILE_JOBS_PRE_EACH_CASE', defile=d_file, logfile=o_file)
        return True

    def end_after_case(self, case):
        """
        """

        if not self._no_lan_tshark:
            # stop LAN PC tcpdump
            #self.do_eth_tcpdump(do_stop=True)
            pass
            #
        if not self._no_minicom:
            self.do_truncate_minicomlog(finished=True)

        # stop WAN PC tcpdump
        #if self.last_wan_cap_file :
        #    #cmd = 'ps aux | grep %s | grep -v grep | xargs -n1 kill ' % (self.last_wan_cap_file)
        #    #self.wanpc_cmd(cmd)
        #    if self.m_pid_remote_tcpdump :
        #        rc = self.stop_async_subporc(self.m_pid_remote_tcpdump, self.m_caselogger)
        #        self.m_syslogger.info('exit remote tcpdump code : ' + str(rc))
        #        self.m_pid_remote_tcpdump = None

        # stop minicom capture
        #cmd = 'killall -9 minicom'
        #self.lanpc_cmd(cmd)
        #if self.m_pid_minicom :
        #    rc = self.stop_async_subporc(self.m_pid_minicom, self.m_caselogger)
        #    self.m_syslogger.info('exit minicom code : ' + str(rc))
        #    self.m_pid_minicom = None

        #stop all async process
        for p in self.m_subp_async:
            pid = p.pid
            rc = self.stop_async_subporc(p, self.m_caselogger)
            self.m_syslogger.info('exit pid ' + str(pid) + ' code : ' + str(rc))

        self.m_subp_async = []

        # do custom commands
        d_file = os.path.join(os.getenv('G_LOG', '/root/automation/logs/current'), 'jobs_after_case')
        o_file = os.path.join(os.getenv('G_CURRENTLOG', '/root/automation/logs/current'), 'jobs_after_case.log')
        self.runCmdFromEnvFiles('U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE', defile=d_file, logfile=o_file)

        return

    def lanpc_cmd(self, cmd):
        """
        """
        mycmd = cmd
        self.m_syslogger.debug('Command run in LAN PC : ' + mycmd)
        return self.subproc(mycmd)

    def lanpc_cmd_async(self, cmd, ofile=None):
        """
        """
        mycmd = cmd
        self.m_syslogger.debug('Command async run in LAN PC : ' + mycmd)
        return self.start_async_subproc(mycmd, self.m_caselogger)


    def wanpc_cmd(self, cmd, ofile=None):
        """
        """
        wan_ip = os.environ.get('G_HOST_IP1', None)
        wan_username = os.environ.get('G_HOST_USR1', None)
        wan_password = os.environ.get('G_HOST_PWD1', None)
        if not wan_ip or not wan_username or not wan_password:
            self.m_syslogger.warning('IP/username/password of WAN PC is(are) not correct! ssh_cmd is ignored!')
            return (False, 'WAN PC parameters error')
        mycmd = 'clicmd --mute -d %s -u %s -p %s -v \" %s \"' % (wan_ip, wan_username, wan_password, cmd)
        if ofile:
            mycmd += (' -o ' + ofile)

        self.m_syslogger.debug('Command async run in WAN PC : ' + mycmd)
        #os.system(mycmd)
        rc, output = self.subproc(mycmd)

        if not str(rc) == '0':
            self.m_syslogger.error('Failed --> ' + 'Command run in LAN PC : ' + mycmd)

        return (rc, output)

    def wanpc_cmd_async(self, cmd, ofile=None, timeout=None):
        """
        """
        wan_ip = os.environ.get('G_HOST_IP1', None)
        wan_username = os.environ.get('G_HOST_USR1', None)
        wan_password = os.environ.get('G_HOST_PWD1', None)
        if not wan_ip or not wan_username or not wan_password:
            self.m_syslogger.warning('IP/username/password of WAN PC is(are) not correct! ssh_cmd is ignored!')
            return (False, 'WAN PC parameters error')

        mycmd = 'clicmd --mute -d %s -u %s -p %s -v \" %s \"' % (wan_ip, wan_username, wan_password, cmd)
        if ofile:
            mycmd += (' -o ' + ofile)

        if timeout:
            mycmd += (' --timeout=' + str(timeout))

        self.m_syslogger.debug('Command run in WAN PC : ' + mycmd)
        #os.system(mycmd)
        return self.start_async_subproc(mycmd, self.m_caselogger)

    def launch_at_redmine(self):
        """
        """
        tbname = os.getenv('G_TBNAME')
        enable = os.getenv('U_CUSTOM_ENABLE_AT_REDMINE')

        if enable and not enable == '0' and tbname:
            fmt = 'killall at_redmine ; screen -dmS at_redmine at_redmine --tbname=%s  '
            cmd = fmt % (tbname)
            #self.m_syslogger.info('Launch at_redmine in WAN PC with command : ' + cmd )
            #self.wanpc_cmd(cmd)
            self.lanpc_cmd(cmd)

            time.sleep(2)
        else:
            self.lanpc_cmd('killall at_redmine')
            #self.wanpc_cmd('killall at_redmine')
            #self.m_syslogger.error('AT redmine not start due to some parameters is empty or not defined! 5 seconds show this message!')
            #
            time.sleep(2)
            return
        return

    def runCmdFromEnvFiles(self, env, defile=None, logfile=None):
        """
        """
        self.m_syslogger.info('runCmdFromEnvFile(%s,%s,%s)' % (str(env), str(defile), str(logfile)))
        try:
            v = os.getenv(env)
            flist = []
            #
            if not v:
                v = defile
                os.environ[env] = v
                pass
            else:
                self.m_syslogger.warning('Not found ENV(%s)' % (str(env)))
                #
            if v and os.path.exists(v):
                fd = open(v, 'r')
                self.m_syslogger.info('Load custom commands file from (%s)' % (str(v)))
                if fd:
                    flist = fd.readlines()
                    fd.close()
                os.system('rm %s' % v)
            else:
                self.m_syslogger.warning('==Not found file(%s)' % (str(v)))
                return True

            for fname in flist:
                lines = []
                resp = ''
                fname = fname.strip()
                if fname and os.path.exists(fname):
                    fd = open(fname, 'r')
                    self.m_syslogger.info('Load custom commands from file(%s)' % (str(fname)))
                    if fd:
                        lines = fd.readlines()
                        fd.close()
                else:
                    #self.m_syslogger.warning('Not found file(%s) defined by %s'%(str(fname),str(envName)) )
                    self.m_syslogger.warning('Not found file(%s)' % (str(fname)))
                    os.system('ls -lht %s' % os.path.dirname(fname))
                    pass

                #

                for cmd in lines:
                    self.m_syslogger.info('execute command : %s' % (str(cmd)))
                    rc, o = self.subproc(cmd, timeout=600)
                    resp += ('%s\n%s\n' % (cmd, o))
                    pass

                #
                if fname:
                    fd = open(fname, 'a')
                    if fd:
                        fd.write(resp)
                        fd.close()
        except Exception, e:
            pass
            #return False

        #exit(1)
        return True

    def isCaseToRun(self, job):
        """
        """
        fnz = job['filepath']
        #fnz.append(fn)
        if len(self._cases_whitelist):
            # required
            rex = '\.case'
            isInCaseFile = False
            for fn in fnz:
                res = re.findall(rex, fn, re.I)
                if len(res):
                    isInCaseFile = True
                    break

            if not isInCaseFile:
                print('-- is not in case file')
                return True
                #optional
            for m in self._cases_whitelist:

                for fn in fnz:
                    res = re.findall(m, fn, re.I)
                    if len(res):
                        print('-- Matched regular exp : %s' % (m))

                        self._casefile_whitelist.append(os.path.basename(fn))
                        return True
        else:
            print('-- no list defined')
            return True

        #
        return False

    def loadCaseToRunFromFile(self, fn):
        """
        """
        if not fn or os.path.exists(fn):
            return True
            #
        fd = open(fn, 'r')
        lines = []
        if fd:
            lines = fd.readlines()
            fd.close()

        for line in lines:
            s = line.strip()
            if s.startswith('#'):
                continue
            else:
                self.addCaseToRun(m)


    def addCaseToRun(self, m):
        """
        """
        if m not in self._cases_whitelist:
            self._cases_whitelist.append(m)
            pass
        return

    def isSame2LastPre(self, job):
        """
        """
        # get current job's pre
        fname = job['filepath'][-1]
        m = r'pre_\w*'
        res = re.findall(m, fname)
        pre_job = None
        if len(res):
            pre_job = res[0]
            #print('-- pre_job : %s' % pre_job)
            pass
        else:
            #print('-- Can not found pre_job : %s' % fname)
            return False

        sz = len(self.m_jobs)
        idx = sz

        last_pre = []
        while idx > 0:
            idx -= 1
            last_job = self.m_jobs[idx]
            fn = last_job['filepath'][-1]
            # Find last precondition
            res = re.findall(m, fn)

            if len(res):
                # precondition MUST in contains in case file(end with .case)
                if len(last_job['filepath']) > 1:
                    pfn = last_job['filepath'][-2]
                    if not pfn.endswith('.case'):
                        continue
                    else:
                        pass
                    pass
                else:
                    continue
                    #last_pre = res[0]
                last_pre.append(res[0])
                #print('append last pre : %s' % res[0])
                if res[0] in ['pre_tr']:
                    continue
                    #print('-- Last pre : %s' % (last_pre) )
                pass
            else:
                continue
                # diff the precondition
            #res = re.findall(pre_job,fn)
            #if len(res) :
            if pre_job in last_pre:
                #print('-- same precondition %s %s'%(pre_job,str(last_pre)))
                return True
            else:
                #print('-- different precondition %s %s'%(pre_job,str(last_pre)))
                return False
            pass

        return False

    def isDuplicateInCaseSinceLastPre(self, job):
        """
        """
        #
        fnp = job['filepath']
        if not len(fnp):
            return False
            #
        fname = fnp[-1]
        if not fname.endswith('.case'):
            return False

        #
        sz = len(self.m_jobs)
        idx = sz
        rc = False
        while idx > 0:
            idx -= 1
            last_job = self.m_jobs[idx]
            fn = last_job['filepath'][-1]


            # Find last precondition
            m = r'pre_\w*'
            res = re.findall(m, fn)
            last_pre = None
            if len(res):
                # reach the last precondition, stop
                last_pre = res[0]
                break
            else:
                if not fn.endswith('.case'):
                    continue
                elif fname == fname:
                    continue
                if job['line'] == last_job['line']:
                    rc = True
                    print('-------isDuplicateInCaseSinceLastPre : %s' % str(job) )
                    break

        return rc

    def importTestLinkOp(self):
        """
        """
        tl_opr = None
        err_msg = ''
        try:
            sys.path.append('/root/automation/tools/2.0/tl_operator')
            import tl_operator as tl_opr

            print(dir(tl_opr))
            #tl_opr = tl_operator
            pass
        except Exception, e:
            err_msg = str(e)
            print('Exception : %s ' % e)
            tl_opr = None
            pass
        return tl_opr, err_msg

    def load_testplan_from_testlink(self, testplan, testbuild):
        """
        """
        testplan = self.expandExpr(testplan)
        testbuild = self.expandExpr(testbuild)
        print('----> load_testplan_from_testlink : testplan(%s) testbuild(%s)' % (testplan, testbuild))
        rc = False
        err_msg = ''
        try:
            tl_opr, err_msg = self.importTestLinkOp()
            if not tl_opr:
                return False, err_msg
                #
            tester = os.environ.get('G_TESTER')
            ta = tl_opr.TL_OPRTOR(testplan, testbuild=testbuild, tester=tester)
            #print('ta = %s' % str(ta))
            self._testlink_agent = ta
            self.parse_testplan_from_testlink(ta)
            #tl_cases = ta.get_testcases()
            #pprint(tl_cases)
            rc = True
            pass
        except Exception, e:
            formatted_lines = traceback.format_exc().splitlines()
            print(formatted_lines)
            print('Exception : %s ' % e)
            err_msg = str(e)
            rc = False
            pass
        return rc, err_msg

    def parse_testplan_from_testlink(self, ta):
        """

         {'active': '1',
         'assigned_build_id': '',
         'assigner_id': '',
         'author_first_name': 'Leon',
         'author_id': '4',
         'author_last_name': 'Penn',
         'author_login': 'lpan',
         'creation_ts': '2012-12-06 13:45:38',
         'err': '',
         'exec_id': '',
         'exec_on_build': '',
         'exec_on_tplan': '',
         'exec_status': 'n',
         'executed': '',
         'execution_notes': '',
         'execution_order': '62360',
         'execution_run_type': '',
         'execution_ts': '',
         'execution_type': '2',
         'external_id': '11884',
         'feature_id': '78498',
         'id': '616635',
         'importance': '3',
         'is_open': '1',
         'layout': '1',
         'linked_by': '4',
         'linked_ts': '2012-12-26 20:21:14',
         'modification_ts': '0000-00-00 00:00:00',
         'name': '01901935_WPA2 + 802.1x with Both Encryption Type for Primary',
         'node_order': '6236',
         'platform_id': '0',
         'platform_name': '',
         'preconditions': '',
         'priority': '6',
         'result': '',
         'status': '1',
         'summary': '<p>WPA2 + 802.1x with Both Encryption Type</p>',
         'tc_external_id': '11884',
         'tc_id': '616634',
         'tcversion_id': '616635',
         'tcversion_number': '',
         'testcase_id': '616634',
         'tester_id': '',
         'testsuite_id': '616609',
         'tsuite_name': 'Various Security Type',
         'type': '',
         'updater_first_name': '',
         'updater_id': '',
         'updater_last_name': '',
         'updater_login': '',
         'urgency': '2',
         'user_id': '',
         'uuid': '01901935',
         'version': '1',
         'z': '6236'},
        """
        print('---> parse_testplan_from_testlink')
        list_cases = ta.get_testcases()
        tmp_tst_files = {}
        tst_list = []
        for case in list_cases:
            # 1. get case file by uuid
            uuid = case.get('uuid', None)
            case_file = ''
            if not uuid:
                rc = False
                err_msg = ''
                break
            m = r'%s*.case' % (str(uuid) )
            p = '/root/automation/testsuites/2.0/%s/tl_cases/%s' % (os.getenv('U_DUT_TYPE', 'CTLC2KA'), uuid[:3])
            res = list(search_file(m, p))
            if len(res):
                case_file = res[0]
                # 2. get case fullpath


            fullpath = case.get('fullpath', None)
            if not fullpath:
                fullpath = ['testlink']
                #
            sFullPath = '__'.join(fullpath)
            m = r'[^0-9a-zA-Z-_.]'
            sFullPath = re.sub(m, '_', sFullPath)
            sFullPath += '.tst'
            if sFullPath not in tmp_tst_files.keys():
                tmp_tst_files[sFullPath] = []
                tst_list.append(sFullPath)
            tmp_tst_files[sFullPath].append(case_file)

        # save tst
        for tst_name in tst_list:
            caselist = tmp_tst_files[tst_name]

            path = './tl_suites'
            if not os.path.exists(path):
                os.mkdir(path)
                #
            fn = os.path.join(path, tst_name)
            with open(fn, 'w') as fd:
                for case_file in caselist:
                    if len(case_file):
                        fd.write('-f %s \n' % case_file)
                fd.close()

            pass

        #exit(1)
        for tst_name in tst_list:
            caselist = tmp_tst_files[tst_name]

            path = './tl_suites'
            fn = os.path.join(path, tst_name)
            self.m_cfgfiles.append(fn)
            #self.load_file(fn,{})

        pass

    def resetRuntime(self):
        """
        """
        self.m_runtime = {
            'filepath': [],
            'linenum': [],
            'line': '',
            'param': '',
            'raw_param': '',
            'type': '', # PUTENV,INCLUDE,CASE,TAG
            'case': None,
            'status': 'checked',
        }

    def isDuplicatedNCase(self, job):
        """
        """
        rc = False
        ex = ["B-GEN-ENV.PRE-DUT.TELNET-002.xml", "B-GEN-ENV.PRE-WAN.SERVICE-001.xml"]
        fn = job['param']
        if fn.endswith('.xml'):
            fname = os.path.basename(fn)
            dname = job['filepath'][-1]
            # ncase SHOULD in file (*.case)
            if not dname.endswith('.case'): return rc
            # not in exception
            if fname in ex: return rc
            # not contains keyword
            keyword = 'PR'
            if fname.find(keyword) <= 0: return rc

            # find all ncase in case file since last precondition
            jl = len(self.m_jobs)
            for i in range(jl):
                last_job = self.m_jobs[-(i + 1)]
                if last_job.get('type') == 'NCASE':
                    fn2 = last_job['param']
                    fname2 = os.path.basename(fn2)
                    dname2 = last_job['filepath'][-1]
                    if dname2 != dname:
                        keyword = 'PRE-DUT.FACRESET'
                        if fname2.find(keyword) > 0:
                            return rc
                        elif fname2 == fname:
                            return True
                        pass
                    else:
                        pass
                else:
                    continue
            pass
        return rc

#------------------------------------------------------------------------------

def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += '\n\nNOTE :\n'
    usage += '1. all optons can be added in the config file specified with -f\n'
    usage += '2. -e,-p,-s,-x MUST before all cases\n'
    usage += '3. nested levels of files MUST less than 5\n'
    usage += ('\nGet more info with command : pydoc ' + os.path.abspath(__file__) + '\n')
    parser = OptionParser(usage=usage)

    #parser.description = desc
    #parser.add_option("-c", "--console", dest="console",action="store_true",
    #                       default = False,help="Not support now")
    parser.add_option("-d", "--debug", action="store_true", dest="debug",
                      default=False, help="run cases with debug mode, stop and waiting for input after each step")
    parser.add_option("-e", "--execute", action="store_true", dest="execute",
                      default=False, help="run cases after checking ")
    parser.add_option("-f", "--configfile", dest="cfgfile", action="append",
                      help="The environment config file to set")
    parser.add_option("-p", "--parseResult", dest="psfile",
                      help="print the parse result into file")
    parser.add_option("-m", "--map", dest="mappingfile",
                      help="print the mapping result into file")
    parser.add_option("-s", "--syslog", dest="syslog",
                      help="syslog file")
    parser.add_option("-t", "--test", dest="testcmd",
                      help="load variables only before run testcmd, ingore all cases")
    parser.add_option("-v", "--variableOption", dest="vos", action="append",
                      help="The environment to set, format is key=val")
    parser.add_option("-x", "--loglevel", type="int", dest="loglevel",
                      help="the log level, default is 30(WARNING)")
    parser.add_option("--mailto", dest="mailto", action="append",
                      help="send email after executing testsuites")
    parser.add_option("--mail", dest="mail", action="store_true",
                      help="send email after executing testsuites")
    #
    parser.add_option("--without-minicom", dest="no_minicom", action="store_true", default=False,
                      help="do not capture minicom log")
    parser.add_option("--without-lan-tshark", dest="no_lan_tshark", action="store_true", default=False,
                      help="do not start tshark in LAN PC to capture eth1 and eth2 ")
    parser.add_option("--without-wan-tshark", dest="no_wan_tshark", action="store_true", default=False,
                      help="do not start tshark in WAN PC to capture eth2")

    parser.add_option("--minicom-method", dest="minicom_method", type="int", default=1,
                      help="Setup the minicom capture method ,default is 1")

    parser.add_option("--tags", dest="tags", action="append",
                      help="tags for case and suite to test")
    #
    group = OptionGroup(parser, "Cases list to run", "Define the cases to run")
    parser.add_option_group(group)
    parser.add_option("-l", dest="tcases", action="append",
                      help="cases to run, join with ,")
    parser.add_option("--file_case2run", dest="fn_tcases", action="append",
                      help="The file contains cases to run ,one line one case")

    #
    #group = OptionGroup(parser,"Filters","Other useful filters for ATE load cases")
    #parser.add_option_group(group)
    #parser.add_option("--precondition_", dest="cases", action="append",
    #                  help="cases to run, join with ,")








    (options, args) = parser.parse_args()
    # check option
    if not options.cfgfile:
        print 'Error : ', 'No config file!'

        parser.print_help()
        exit(1)
    if options.testcmd:
        print "==", "MODE : TESTCMD "
        if options.execute:
            print "==", "conflict param -e and -t"
            exit(1)
    elif options.execute:
        print "==", "MODE : EXECUTE"
    else:
        print "==", "MODE : CHECK"
        # set log
    global logger
    global g_hdlr
    g_hdlr = None
    logger = logging.getLogger('ATE')
    #FORMAT = '[%(asctime)-15s %(module)8s:%(lineno)-4d %(levelname)-8s] %(message)s'
    FORMAT = '%(message)s'
    logging.basicConfig(format='%(levelname)-8s : %(message)s')
    # set syslog file
    if options.syslog:
        # sys
        g_hdlr = logging.FileHandler(options.syslog)
        g_hdlr.setFormatter(logging.Formatter(FORMAT))
        logger.addHandler(g_hdlr)
        # raw sys same as console
        #f,d = os.path.basename(options.syslog),os.path.dirname(options.syslog)
        #hdlr = logging.FileHandler(d + '/raw_' + f)
        #hdlr.setFormatter(logging.Formatter(FORMAT))
        #logger.addHandler(hdlr)
    #
    lvl = 30
    if options.loglevel:
        lvl = options.loglevel
    print "==", 'set loglevel :', lvl
    logger.setLevel(lvl)


    #logger.debug("log check")
    #logger.info("log check")
    #logger.warning("log check")
    #logger.error("log check")

    return options
    #------------------------------------------------------------------------------


def check_uniq():
    """
    """
    pid = os.getpid()
    os.environ['G_ATE_PID'] = str(pid)
    opid = 0
    # Get pid from pid file
    f_pid = '/var/run/ATE.pid'
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
            syslog.syslog(syslog.LOG_ERR, 'ATE is already in running! the pid is ' + str(opid))
            ATE_LOGGER.error('EXIT : ATE is already running!')
            exit(99)

    # Update the new pid
    print 'Update the ATE latest pid : ' + str(pid)
    os.system('echo ' + str(pid) + ' >' + f_pid)
    return True


def main():
    """
    main entry
    """
    import uuid

    tid = uuid.uuid1()
    os.environ['G_AT_UUID'] = str(tid)
    ATE_LOGGER.info('AT_UUID :  ' + str(tid))
    ATE_LOGGER.info('LAST_STATUS : parseCommandLine')
    opts = parseCommandLine()
    ATE_LOGGER.info('LAST_STATUS : parseCommandLine Done')

    ATE_LOGGER.info('LAST_STATUS : create new instance ATE')
    ate = ATE(debug=opts.debug)
    ATE_LOGGER.info('LAST_STATUS : create new instance ATE Done')
    syslog.openlog('ATE.py', syslog.LOG_PID | syslog.LOG_PERROR)
    ATE_LOGGER.info('LAST_STATUS : check ATE uniq')
    check_uniq()
    ATE_LOGGER.info('LAST_STATUS : check ATE uniq done')
    syslog.syslog('ATE instance created!')

    #
    sig_ids = [2, 4, 6, 8, 11, 15]
    #sig_ids = [n for n in range(20)]
    for sig in sig_ids:
        #print sig
        signal.signal(sig, ate.sighandle)

    ATE_LOGGER.info('LAST_STATUS : ATE parse options')
    ate.parseOpts(opts)
    ATE_LOGGER.info('LAST_STATUS : ATE parse options Done')
    try:
        ATE_LOGGER.info('LAST_STATUS : ATE run')
        rc = ate.run()
        if rc:
            syslog.syslog('ATE instance finished!')
            ATE_LOGGER.info('LAST_STATUS : ATE finished')
        else:
            syslog.syslog('ATE instance exit due to some error!')
            ATE_LOGGER.error('LAST_STATUS : ATE exit')

    except Exception, e:
        syslog.syslog(syslog.LOG_ERR, 'ATE has thrown exception : ' + str(e))
        formatted_lines = traceback.format_exc().splitlines()
        print ('Exception : ' + pformat(formatted_lines))

    #
    # killall minicom
    os.system('killall minicom')

    return 0


if __name__ == '__main__':
    """
    """
    INIT_ATE_LOG()
    #print ATE_LOGGER
    main()

    #try :
    #   main()
    #except KeyboardInterrupt :
    #   pass
    #except Exception,e :
    #   print '==Except',e

