#!/usr/bin/env python
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
"""
#------------------------------------------------------------------------------
from types import *
import sys, time, os
import re
from optparse import OptionParser
import logging
from pprint import pprint
from pprint import pformat
import xml.etree.ElementTree as etree
#from lxml import etree
import subprocess, signal, select
from copy import deepcopy

#------------------------------------------------------------------------------
class ATE():
    """
    This class is the Automation Core Engine for running Automation test cases.
    """

    # The envrionment variables table
    m_hash_env = {}
    m_hash_env_bak = {}
    m_hash_export = []
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

    # check_only
    check_only = True

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
    m_check_have_case = False
    # VIP
    m_vip = ['G_CURRENTLOG', 'G_LOG']

    def __init__(self):
        """
        """
        pass

    def subproc(self, cmd, timeout=3600, plogger=None):
        """
        subprogress to run command
        """
        rc = None
        output = ''
        if not plogger: plogger = logging.getLogger()
        #
        plogger.info('subproc : ' + cmd)
        plogger.info('timout : ' + str(timeout))
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
        while True:
            while_begin = time.time()
            fs = select.select([p.stdout], [], [], timeout)
            #if p.poll() : break
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
            else:
                #print 'Timeout'
                plogger.error('Timeout')
                os.kill(p.pid, signal.SIGKILL)
                break
            timeout = timeout - (time.time() - while_begin)
        # return
        rc = p.poll()
        plogger.info('return value : ' + str(rc))
        return rc, output

    def parseKV(self, env):
        """
        parse equal expression : Key = Value
        """
        match = r'(\w*)\s*=\s*(.*)'
        kv = os.popen('echo ' + env).read().strip()
        #self.m_runtime['param'] = kv
        az = re.findall(match, kv)
        sz = len(az)
        if sz > 0:
            (key, val) = az[0]
            if key:
                if not val: val = ''
                return (key, val)
        return (None, None)

    def addJob(self, job):
        """
        add a job
        """
        self.m_jobs.append(job)
        logger.debug('add job : ' + pformat(job))

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
            msg += pformat(job)
            idx += 1
        #print '\n', str(idx),'\n'
        #pprint(job )
        #pprint(job)
        return msg

    def exportEnv(self):
        """
        No use
        """
        for expr in m_hash_export:
            self.addEnv(expr)

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
            # already exist
            if self.m_hash_env.has_key(key): msg = 'duplicate putenv'
            self.m_hash_env[key] = val
            oldval = os.environ.get(key, None)
            if oldval and not self.m_hash_env_bak.has_key(key):
                self.m_hash_env_bak[key] = oldval
            #os.putenv(key,val)
            os.environ[key] = val
            logger.debug('add env : %s = %s' % (key, val))
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
                rc += ('"' + key + '" : "' + val + '"\n')
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
        #
        if opts.execute:
            self.check_only = False
        # cfgfile
        if opts.cfgfile:
            for cfgs in opts.cfgfile:
                vcfg = cfgs.split(';')
                for cfg in vcfg:
                    if os.path.isfile(cfg):
                        self.addCfg(os.path.abspath(cfg))
                    else:
                        logger.error('Config file (%s) is not exist!' % cfg)
                        exit(1)
        else:
            logger.error('No config file!')
            exit(1)
        # variables tables
        if opts.vos:
            m_hash_export = opts.vos
            for kv in opts.vos:
                self.addEnv(kv)

        if opts.psfile:
            self.m_psfile = opts.psfile

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

        # append a file
        job['filepath'].append(fname)
        job['linenum'].append(0)
        fullpath = '-->'.join(job['filepath'])
        if len(job['filepath']) > 5:
            logger.error('File nesting greater than 5 : ' + '-->'.join(job['filepath']))
            exit(2)
        # openf file to parse
        fd = open(fname)
        if fd:
            lines = fd.readlines()
            # parse line by line
            for line in lines:
                job['linenum'][-1] += 1
                job['line'] = line
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
                # PUTENV
                elif k == '-v' or k == 'putenv':
                    #kv = os.popen('echo ' + v).read().strip()
                    kv = self.expandExpr(v).strip()
                    job['type'] = 'PUTENV'
                    job['param'] = kv
                    self.addJob(job)
                    job = deepcopy(job)
                    (rc, msg ) = self.addEnv(kv)
                    if rc:
                        if msg:
                            logger.warning(msg + ' ' + pformat(job))
                    else:
                        if msg:
                            logger.error(msg + ' ' + pformat(job))
                        #(key,val) = self.parseKV(kv)
                        #self.m_hash_env[key] = val
                        #os.putenv(key,val)
                        #self.addEnv(key,val)
                # INCLUDE
                elif k == '-f' or k == 'include':
                    #cmd = 'echo ' + v.split(';')[0]
                    #fn = os.popen(cmd).read().strip()
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
                    self.check_only = False
                elif k == '-p':
                    if self.m_check_have_case:
                        logger.error('set MUST before all cases : ' + pformat(job))
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
                        exit(1)
                elif k == '-x':
                    if self.m_check_have_case:
                        logger.error('set MUST before all cases : ' + pformat(job))
                        exit(1)
                    logger.info('set loglevel : ' + v)
                    job['type'] = 'SET_LOGLEVEL'
                    lvl = self.expandExpr(v)
                    job['param'] = lvl
                    self.addJob(job)
                    newjob = deepcopy(job)
                    try:
                        lvl = int(lvl)
                        logger.setLevel(lvl)
                    except Exception, e:
                        logger.error('bad loglevel : ' + v)
                        logger.error(e)
                        exit(1)
                elif k == '-nc':
                    self.m_check_have_case = True
                    plist = v.split(';')
                    #cmd = 'echo ' + v.split(';')[0]
                    #fn = os.popen(cmd).read().strip()
                    fn = plist[0]
                    job['raw_param'] = fn
                    fn = self.expandExpr(fn).strip()
                    job['type'] = 'NCASE'
                    fn = os.path.abspath(fn)
                    job['param'] = fn
                    if not os.path.isfile(fn):
                        logger.error('File not found : ' + pformat(job))
                        exit(1)
                    else:
                        # preload case
                        case = self.preload_case(job)
                        # add job
                        self.addJob(job)
                        job = deepcopy(job)
                        job.pop('case')
                elif k == '-tc':
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
                        exit(1)
                    else:
                        # preload case
                        case = self.preload_case(job)
                        # add job
                        self.addJob(job)
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
                else:
                    continue
                #jobs.append(job)
                #logger.error('job : ' + pformat(runtime) )
            #logger.error('jobs : ' + pformat(jobs) )
            fd.close()
        else:
            logger.error('File not found : ' + pformat(job))
            exit(1)
        logger.info('PASS : ' + fullpath)

    def load(self):
        """
        load all : config files,suite files
        """
        # load file
        for fname in self.m_cfgfiles:
            #self.resetRuntime()
            self.load_file(fname)
        # check environment
        self.check_vip()
        # save jobs into file
        if self.m_psfile:
            logger.info('Save all jobs into file : ' + self.m_psfile)
            fd = open(self.m_psfile, 'w')
            if fd:
                fd.write(self.dumpEnv())
                fd.write('##' * 16 + '\n')
                fd.write(self.dumpJobs())
                fd.close()
            else:
                pass

    def check_vip(self):
        """
        check Very Important Parameters ,such as G_LOG
        """
        #
        rc = False
        for vip in self.m_vip:
            if self.m_hash_env.has_key(vip) and self.m_hash_env[vip]:
                logger.info('VIP Check : ' + vip + ' = ' + self.m_hash_env[vip])
                rc = True
            else:
                logger.error('VIP Check : ' + vip + ' is not exist')
                exit(1)
        return rc

    def run(self):
        """
        main entry
        """
        self.m_times['starttime'] = time.asctime()
        self.m_times['start_check'] = time.time()
        # check
        logger.info("Preloading...")
        # load files
        self.load()

        # count check
        #self.m_times['endtime'] = time.asctime()
        self.m_times['end_check'] = time.time()
        duration = self.m_times['end_check'] - self.m_times['start_check']
        self.m_times['duration_check'] = duration
        logger.info('starttime : ' + self.m_times['starttime'])
        logger.info('duration : ' + str(duration))
        # run case
        if not self.check_only:
            logger.info('Execute Test')
            self.m_times['start_run'] = time.time()
            self.do_jobs()
            # save jobs into file
            if self.m_psfile:
                logger.info('Save all jobs done into file : ' + self.m_psfile)
                fd = open(self.m_psfile, 'w')
                if fd:
                    #fd.write(self.dumpEnv('doneJobs') )
                    fd.write('##' * 16 + '\n')
                    fd.write(self.dumpJobs('doneJobs'))
                    fd.close()
        else:
            logger.info('PASS : ' + 'Check Only')
            pass

    def make_logpath(self):
        """
        make all log path
        """
        logpath = self.m_hash_env['G_LOG']
        sln = self.m_hash_env['G_CURRENTLOG']
        ts = time.strftime('%Y-%m-%d_%H%M%S', time.localtime(time.time()))
        self.m_log_path = os.path.abspath(logpath + '/logs' + ts)
        os.makedirs(self.m_log_path)
        #
        cmd = 'rm -rf ' + sln + ';' + 'ln -s ' + self.m_log_path + ' ' + sln
        logger.info('Prepare log path : ' + cmd)
        os.system(cmd)

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

    def add_case_result(self, job):
        """
        add a case result
        """
        case = job['case']
        msg = ''
        msg += ('-' * 32 + '\n')
        msg += '\n[%03d] Testcase %s %s\n'
        msg += 'Description : %s\n'
        msg += 'Log Path : %s\n'
        msg += 'Testcase Path : %s\n'
        msg += 'Start time : %s\n'
        msg += 'Duration : %s\n'
        msg += "Last Error : %s\n"
        self.add_result(msg % (job['case_index'], job['status'], case['name'].strip(),
                               case['description'].strip(),
                               job['logpath'],
                               job['param'].strip(),
                               case['starttime'],
                               case['duration'],
                               case['last_error']))

    def do_jobs(self):
        """
        go to test
        """
        self.clearEnv()
        # prepare log path
        self.make_logpath()
        # prepare log file
        self.prepare_logs()
        #
        results = self.m_results
        lbl = None
        case_idx = 0
        failed_cases = []
        passed_cases = []
        skipped_cases = []
        ignored_cases = []
        for job in self.m_jobs:
            case = job.get('case', None)
            job['case_index'] = 0
            tp = job['type']
            job['param'] = self.expandExpr(job['raw_param'])
            # process label jump
            if lbl:
                if tp == 'LABEL' and lbl == job['param']:
                    self.m_syslogger.info('Reach label : ' + lbl)
                    lbl = None
                    continue
                else:
                    job['status'] = 'SKIPPED'
                    if tp == 'TCASE' or tp == 'NCASE':
                        self.m_syslogger.info('Skip for label : ' + lbl + ' : ' + job['param'])
                        skipped_cases.append(job['param'])
                    continue

            #
            if tp == 'PUTENV':
                #job['param'] = self.expandExpr(job['raw_param'])
                self.addEnv(job['param'])
                job['status'] = 'PASSED'
                pass
            elif tp == 'INCLUDE':
                job['status'] = 'PASSED'
                pass
            elif tp == 'TCASE':
                # process igonre cases
                ign = os.environ.get('U_CUSTOM_IGNORE_TCASES', None)
                if ign:
                    ign_cases = ign.split(';')
                    if job['param'] in jgn_cases:
                        ignored_cases.append(job['param'])
                        self.m_syslogger.info('ingored case : ' + job['param'])
                        continue
                #
                case_idx += 1
                job['case_index'] = case_idx
                results['G_CASE_INDEX'] = case_idx
                rc, err = self.do_case(job)
                if rc:
                    job['status'] = 'PASSED'
                    passed_cases.append(job['param'])
                    results['G_TCPASS'] += 1
                    goto = case.get('pass_goto', None)
                else:
                    job['status'] = 'FAILED'
                    failed_cases.append(job['param'])
                    results['G_TCFAIL'] += 1
                    goto = case.get('fail_goto', None)
                self.add_case_result(job)
                if goto: lbl = goto
                pass
            elif tp == 'NCASE':
                # process igonre cases
                ign = os.environ.get('U_CUSTOM_IGNORE_TCASES', None)
                if ign:
                    ign_cases = ign.split(';')
                    if job['param'] in jgn_cases:
                        ignored_cases.append(job['param'])
                        self.m_syslogger.info('ingored case : ' + job['param'])
                        continue
                #
                case_idx += 1
                job['case_index'] = case_idx
                results['G_CASE_INDEX'] = case_idx
                rc, err = self.do_case(job)
                if rc:
                    job['status'] = 'PASSED'
                    passed_cases.append(job['param'])
                    results['G_NCPASS'] += 1
                    goto = case.get('pass_goto', None)
                else:
                    job['status'] = 'FAILED'
                    failed_cases.append(job['param'])
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
        msg += ('\n'.join(self.m_include) )
        msg += ('\n' + '--' * 32 + '\nSkipped cases :\n')
        msg += ('\n'.join(skipped_cases) )
        msg += ('\n' + '--' * 32 + '\nIgnored cases :\n')
        msg += ('\n'.join(ignored_cases) )
        msg += ('\n' + '--' * 32 + '\nPassed cases :\n')
        msg += ('\n'.join(passed_cases) )
        msg += ('\n' + '--' * 32 + '\nFailed cases :\n')
        msg += ('\n'.join(failed_cases) )

        cnt_msg = (msg % (os.environ.get('G_HW_VERSION', 'None'),
                          os.environ.get('G_SW_VERSION', 'None'),
                          os.environ.get('U_DUT_SN', 'None'),
                          self.m_times['starttime'],
                          (self.m_times['duration']), (self.m_times['duration_check']), (self.m_times['duration_run']),
                          results['G_NCPASS'] + results['G_NCFAIL'], results['G_NCPASS'], results['G_NCFAIL'],
                          results['G_TCPASS'] + results['G_TCFAIL'], results['G_TCPASS'], results['G_TCFAIL'],
                          results['G_IGNUM'] ))
        self.add_result(cnt_msg)

    #self.m_syslogger.info(cnt_msg )


    def do_case(self, job):
        """
        run case
        """
        #
        rc = True
        last_error = ''
        case = job['case']
        case['last_error'] = last_error
        steps = case['stage']['step']
        job['status'] = 'RUNNING'
        # collect info
        job['param'] = os.path.abspath(job['param'])
        fname = os.path.basename(job['param'])
        results = self.m_results
        #results['G_CASE_INDEX'] += 1
        idx = results['G_CASE_INDEX']
        # create new path
        caselogpath = os.environ['G_CURRENTLOG'] + '/' + fname + '_' + str(idx)
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
        # add new case handler
        self.m_casehdlr = logging.FileHandler(caselogpath + '/case.log')
        caselogger.addHandler(self.m_casehdlr)
        steplogger.addHandler(self.m_casehdlr)
        # case result log
        hdlr = logging.FileHandler(caselogpath + '/result.txt')
        reslogger = logging.getLogger('ATE.CASE.RESULT.' + fname)
        reslogger.addHandler(hdlr)
        reslogger.addHandler(self.m_casehdlr)


        # print case info
        caselogger.info('--' * 16 + '\n' * 4)
        caselogger.info('Run case : ' + job['param'].strip())
        caselogger.info('Description : ' + case.get('description', 'None').strip())

        # run steps
        goto_label = None
        case['starttime'] = time.asctime()
        tbegin = time.time()

        for step in steps:
            # setup step logger
            begin = time.time()
            step['begintime'] = time.asctime()
            step['duration'] = '0'
            #
            if goto_label:
                idx = int(step['name'])
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
            #	steplogger.removeHandler(self.m_casehdlr)
            if self.m_stephdlr:
                steplogger.removeHandler(self.m_stephdlr)
            # add new hdlr
            step['logfile'] = job['logpath'] + '/step_' + step['name'] + '.txt'
            self.m_stephdlr = logging.FileHandler(step['logfile'])
            steplogger.addHandler(self.m_stephdlr)
            steplogger.addHandler(self.m_casehdlr)
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
                output.strip()
            elif step['type'] == 'sub':
                pass

            # parse results
            end = time.time()
            step['endtime'] = time.asctime()
            duration = end - begin
            step['duration'] = str(duration)
            steplogger.info('endtime : ' + time.asctime())
            steplogger.info('duration : ' + str(duration))

            if step_rc is not None and step_rc == 0:
                step['result'] = 'PASSED'
                goto_label = step['passed']
                if step['type'] == 'script':
                    pass
                elif step['type'] == 'getenv':
                    lines = output.splitlines()
                    line = ''
                    if len(lines):
                        line = lines[-1]
                    segs = line.split()
                    for seg in segs:
                        #print '=----=',seg
                        seg = self.expandExpr(seg)
                        steplogger.info('putenv : ' + seg)
                        self.addEnv(seg)
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
            msg = "Step %-2s:%-8s:%s"
            txt = (msg % (step['name'], step['result'], step['desc']) )
            reslogger.info(txt)
            # rename log path
            prefix = step['result'] + '_'
            fn, dn = os.path.basename(step['logfile']), os.path.dirname(step['logfile'])
            newfile = dn + '/' + prefix + fn
            os.renames(step['logfile'], newfile)
            step['logfile'] = newfile
            if not rc:
                last_error += (txt)
                last_error += '\n'
                case['last_error'] = last_error
        # case result
        tend = time.time()
        case['endtime'] = time.asctime()
        case['duration'] = str(tend - tbegin)

        if rc:
            case['result'] = 'PASSED'
        else:
            case['result'] = 'FAILED'
        job['status'] = case['result']
        # rename case log path
        postfix = '_' + case['result']
        newpath = job['logpath'] + postfix
        os.renames(job['logpath'], newpath)
        job['logpath'] = newpath
        # return parent path
        os.environ['G_CURRENTLOG'] = tlogpath
        return rc, last_error

    def preload_case(self, job):
        """
        parse xml format case file
        """
        rc = False
        case = {}
        fn = job['param']

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
            print '!!', e
            exit(1)
        root = tree.getroot()
        # add 1st-level node text
        nodes = list(root)
        for node in nodes:
            case[node.tag] = node.text
        # add step below stage
        #node_step = root.xpath('stage/step')
        node_stage = root.find('stage')
        if etree.iselement(node_stage):
            pass
        else:
            logger.error('/testcase/stage is not found :' + fn)
            exit(1)
        node_step = node_stage.findall('step')
        steps = len(node_step)
        #if steps > 0 :
        #	pass
        #else :
        #	logger.error('/testcase/stage/step is not found :' + fn)
        #	exit(1)


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
            'type': 'script',
            }
            for child in childs: case_step[child.tag] = child.text
            # check tags
            case_step['result'] = 'NA'
            if not case_step['desc']: case_step['desc'] = ''
            if not case_step.get('name', None):
                logger.error('/testcase/stage/step/name is not found :' + fn)
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
            else:
                case_step['type'] = 'script'
                case_step['command'] = ' '
                logger.warning(
                    'script ,getenv and sub below /testcase/stage/step/ is not found :' + fn + '\n' + pformat(case))
            # add step
            arr_steps.append(case_step)

        # sort case
        print '=='
        arr_steps.sort(lambda x, y: cmp(int(x['name']), int(y['name'])))
        logger.debug(pformat(arr_steps))
        logger.debug(pformat(case))
        # get steps
        #pprint(case)
        job['case'] = case
        return case

    #return arr_steps

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
    #						default = False,help="Not support now")
    parser.add_option("-e", "--execute", action="store_true", dest="execute",
                      default=False, help="run cases after checking ")
    parser.add_option("-f", "--configfile", dest="cfgfile", action="append",
                      help="The environment config file to set")
    parser.add_option("-p", "--parseResult", dest="psfile",
                      help="print the parse result into file")
    parser.add_option("-s", "--syslog", dest="syslog",
                      help="syslog file")
    parser.add_option("-v", "--variableOption", dest="vos", action="append",
                      help="The environment to set, format is key=val")
    parser.add_option("-x", "--loglevel", type="int", dest="loglevel", default=30,
                      help="the log level, default is 30(WARNING)")

    (options, args) = parser.parse_args()
    # check option
    if not options.cfgfile:
        print 'Error : ', 'No config file!'
        parser.print_help()
        exit(1)
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
    logger.setLevel(options.loglevel)

    #logger.debug("log check")
    #logger.info("log check")
    #logger.warning("log check")
    #logger.error("log check")

    return options
    #------------------------------------------------------------------------------


def main():
    """
    main entry
    """
    opts = parseCommandLine()
    ate = ATE()
    ate.parseOpts(opts)
    ate.run()
    return 0


if __name__ == '__main__':
    """
    """
    main()
#try :
#	main()
#except KeyboardInterrupt :
#	pass
#except Exception,e :
#	print '==Except',e

