#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#       analyzeTRL.py
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
    Tool for analyze Automation test result file result.log ,and count and classify
    error with the keyword.
"""

import os, sys, re
from pprint import pprint
from pprint import pformat
from copy import deepcopy
from optparse import OptionParser
import logging


def pp_duration(dur):
    """
    """
    nDur = int(float(dur))
    nHour = int(nDur) / 3600
    nMin = (int(nDur) - nHour * 3600) / 60
    nSec = int(nDur) % 60
    nMilSec = (int)((float(dur) - nDur) * 1000)
    #print '==nMilSec',nMilSec
    return (nHour, nMin, nSec, nMilSec)

# Analyzer for Automation Test Result
class A4ATR():
    """
    """
    #
    m_logger = None
    m_keywords = []
    m_rc = {
        'frame_lines': [],
        'index': '',
        'result': '',
        'casename': '',

        'error_details': '',
        'match_keywords': [],
    }
    m_rcs = []
    m_tot = {
        'TOTAL': 0,
        'PASSED': 0,
        'FAILED': 0,
        'SKIPPED': 0,
        'IGNORED': 0,
        'STARTTIME': '',
        'DURATION': 0,
    }
    m_verbose = 0
    m_all = False

    def __init__(self, logger, verbose=0, analyze_all=False):
        """
        """
        self.m_logger = logger
        self.m_verbose = verbose
        self.m_all = analyze_all
        pass

    def LOG(self):
        """
        """
        return self.m_logger

    def addKeywords(self, arrKeyword):
        """
        add keywords to classify failed cases
        """
        if arrKeyword:
            self.m_keywords += arrKeyword
        return True

    def loadFile(self, fn):
        """
        load test result file
        """
        # clear rcs
        self.m_rcs = []

        fd = open(fn, 'r')
        lines = []
        # read file
        if fd:
            lines = fd.readlines()
            fd.close()

        return self.splitFrames(lines)
        # parse lines
        #return self.parseLines(lines)

    def splitFrames(self, lines):
        """
        """
        # frame start and end
        mb = r'\[(\d*)\]\s*(\wCASE)\s*(.*ED)\s*(.*)'
        me = r'^\-\-\-\-\-\-\-\-'
        # test case result end
        mt = r'^################################################'

        inFrame = False

        rcs = []
        trc = None
        step = 0
        for line in lines:
            self.LOG().debug("line : " + line)
            if inFrame:
                s = line.strip()
                r1 = re.findall(me, s)
                r2 = re.findall(mt, s)
                if r2 and len(r2):
                    trc['frame_lines'].append(line)
                    self.LOG().info("matched test case results end line,exit splitFrames")
                    inFrame = False
                    break
                elif r1 and len(r1):
                    self.LOG().debug("matched test case result end line")
                    rcs.append(trc)
                    trc = None
                    step = 0
                    inFrame = False
                    continue
                else:
                    trc['frame_lines'].append(line)

                #


                #
                if 1 == step:
                    m = r'([^:]*)\s*:\s*(.*)'
                    rr = re.findall(m, line)
                    k = None
                    v = None
                    if rr and len(rr):
                        k, v = rr[0]
                        k = k.strip()
                        v = v.strip()
                        trc[k] = v
                    if s.startswith("Last Error"):
                        step = 2
                    elif s.startswith("Testcase Path"):
                        casename = os.path.basename(v)
                        trc['casename'] = casename
                elif 2 == step:
                    trc['Last Error'] = line
                    step = 3
                elif 3 == step:
                    if s.startswith('error message details'):
                        trc['Error Details'] = ''
                        step = 4
                elif 4 == step:
                    trc['Error Details'] += line

            else:
                s = line.strip()
                r1 = re.findall(mb, s)
                r2 = re.findall(mt, s)
                if r2 and len(r2):
                    if trc:
                        trc['frame_lines'].append(line)
                    self.LOG().info("matched test case results end line,exit splitFrames")
                    break
                elif r1 and len(r1):
                    self.LOG().debug("matched test case result start line")
                    trc = deepcopy(self.m_rc)
                    trc['frame_lines'].append(line)
                    (trc['index'], trc['type'], trc['result'], trc['casename']) = r1[0]
                    step = 1
                    inFrame = True
                else:
                    pass
        if trc: rcs.append(trc)
        self.m_rcs = rcs
        return True

    def parseFrames(self):
        """
        parse result file, file format :
        --------------------------------
        
        [001] Testcase PASSED B-GEN-TR98-PR.TR-001.xml
        Description : Test suite preparation for tr98.
        Log Path : /root/automation/logs/current/B-GEN-TR98-PR.TR-001.xml_1_PASSED
        Testcase Path : /root/automation/platform/2.0/FT/tcases/TR069/common/B-GEN-TR98-PR.TR-001.xml
        Start time : Tue Jan 10 19:39:53 2012
        Duration : 14.502933979
        
        --------------------------------
        
        [111] Testcase FAILED B-GEN-TR98-WI.SEC-089.xml
        Description : Wireless security switching from WPA,TKIP to WPA2 AES
        Log Path : /root/automation/logs/current/B-GEN-TR98-WI.SEC-289.xml_111_FAILED
        Testcase Path : /root/automation/platform/2.0/FT/tcases/TR069/wireless/SEC/SSID3/B-GEN-TR98-WI.SEC-289.xml
        Start time : Wed Jan 11 06:42:55 2012
        Duration : 387.999325991
        Last Error : 
                Step 13:FAILED  :Action : Connect a wireless Client to "$U_WIRELESS_CUSTOM_SSID_SEL" and fetch IP.
        error message details :
        [13][Action : Connect a wireless Client to "$U_WIRELESS_CUSTOM_SSID_SEL" and fetch IP.][bash /root/automation/bin/2.0/FT/wifi_connect_DUT.sh -f /root/automation/logs/current/B-GEN-TR98-WI.SEC-289.xml_111/wirelesssec_1.conf -i wlan4 -t 10] : connection timeout ! last status is (wpa_state=SCANNING), expected COMPLETED!
        --------------------------------
        """
        rcs = self.m_rcs
        #print '--'*16
        self.LOG().debug('--' * 16)
        self.LOG().debug(pformat(rcs))
        nPass = 0
        nFail = 0
        nDur = 0.0
        #
        # tsuites 
        #           
        #
        #
        self.m_tot['tsuites'] = []
        self.m_tot['cases_passed'] = []
        self.m_tot['cases_failed'] = []
        self.m_tot['cases_ignored'] = []
        self.m_tot['cases_skipped'] = []
        self.m_tot['nc_passed'] = []
        self.m_tot['nc_failed'] = []
        self.m_tot['cases_failed_uncategorized'] = []
        self.m_tot['cases_failed_no_message'] = []
        self.m_tot['cases_failed_duplicated_in_category'] = []
        self.m_tot['cases_failed_category'] = {}

        for keyword in self.m_keywords:
            self.m_tot['cases_failed_category'][keyword] = []

        for trc in rcs:
            casename = trc['casename']
            index = trc['index']

            # add test suite
            cur_tsuite = None
            if trc.has_key('In Testsuite'):
                tsname = trc['In Testsuite']

                found = False

                for ts in self.m_tot['tsuites']:
                    if ts['name'] == tsname:
                        found = True
                        cur_tsuite = ts
                if not found:
                    cur_tsuite = {
                        'name': tsname,
                        'PASSED': [],
                        'FAILED': [],
                        'IGNORED': [],
                        'SKIPPED': [],
                        'DURATION': 0.0,
                        'STARTTIME': '',
                    }
                    self.m_tot['tsuites'].append(cur_tsuite)

            #
            if 0 == len(cur_tsuite['STARTTIME']):
                cur_tsuite['STARTTIME'] = trc['Start time']
            case_rc = trc.get('result', '')
            if not self.m_all and 'NCASE' == trc['type']:
                # Now do not calc ncase
                if 'PASSED' == case_rc:
                    pass
                elif 'FAILED' == case_rc:
                    pass
                elif 'IGNORED' == case_rc:
                    pass
                elif 'SKIPPED' == case_rc:
                    pass

                continue

            if 'PASSED' == case_rc:
                nPass += 1
                dur = trc.get('Duration', 0)
                nDur += float(dur)
                pretty_dur = ('%02dH:%02dM:%02d.%03dS' % pp_duration(dur) )
                self.m_tot['cases_passed'].append("%04d [Duration:%s][Starttime:%s] %s" % (
                int(index), pretty_dur, trc.get('Start time', ''), casename))
                if cur_tsuite:
                    #cur_tsuite['PASSED'] += 1
                    cur_tsuite['PASSED'].append("%04d %s" % (int(index), casename))
                    cur_tsuite['DURATION'] += float(dur)

            elif 'FAILED' == case_rc:
                d_err = trc['Error Details']
                if len(d_err.strip()) == 0: d_err = trc['Last Error']
                nFail += 1
                dur = trc.get('Duration', 0)
                nDur += float(dur)
                pretty_dur = ('%02dH:%02dM:%02d.%03dS' % pp_duration(dur) )
                self.m_tot['cases_failed'].append("%04d [Duration:%s][Starttime:%s] %s" % (
                int(index), pretty_dur, trc.get('Start time', ''), casename))
                #self.m_tot['cases_failed'].append("%04d [Duration:%s] %s" %(int(index),pretty_dur,casename) )
                if cur_tsuite:
                    #cur_tsuite['FAILED'] += 1
                    cur_tsuite['FAILED'].append("%04d %s" % (int(index), casename))
                    cur_tsuite['DURATION'] += float(dur)

                for keyword in self.m_keywords:
                    rr = re.findall(keyword, trc['Error Details'], re.I)
                    if rr and len(rr):
                        trc['match_keywords'].append(keyword)
                        if self.m_verbose > 1:
                            self.m_tot['cases_failed_category'][keyword].append(
                                "%04d %s %s" % (int(index), casename, d_err))
                        else:
                            self.m_tot['cases_failed_category'][keyword].append("%04d %s" % (int(index), casename))

                nc = len(trc['match_keywords'])
                if 0 == nc:
                    msg = d_err.strip()
                    if 0 == len(msg):
                        self.m_tot['cases_failed_no_message'].append(
                            "%04d %s %s" % (int(index), casename, trc['Last Error']))
                    else:
                        if self.m_verbose < 1:
                            self.m_tot['cases_failed_uncategorized'].append("%04d %s" % (int(index), casename))
                        else:
                            self.m_tot['cases_failed_uncategorized'].append(
                                "%04d %s %s" % (int(index), casename, d_err))
                elif nc > 1:
                    self.m_tot['cases_failed_duplicated_in_category'].append("%04d %s" % (int(index), casename))
            elif 'IGNORED' == case_rc:
                self.m_tot['cases_ignored'].append("%04d %s" % (int(index), casename))
                if cur_tsuite:
                    #cur_tsuite['IGNORED'] += 1
                    cur_tsuite['IGNORED'].append(casename)
            elif 'SKIPPED' == case_rc:
                self.m_tot['cases_skipped'].append("%04d %s" % (int(index), casename))
                if cur_tsuite:
                    #cur_tsuite['SKIPPED'] += 1
                    cur_tsuite['SKIPPED'].append(casename)

        # calc duration
        nHour = int(nDur) / 3600
        nMin = (int(nDur) - nHour * 3600) / 60
        nSec = int(nDur) % 60
        #print "====|",nDur,nHour,nMin,nSec
        self.m_tot['DURATION'] = ('%02dH:%02dM:%02dS' % (nHour, nMin, nSec))

        if nFail + nPass > 0:
            nDur = nDur / (nFail + nPass)
        else:
            nDur = 0
        nHour = int(nDur) / 3600
        nMin = (int(nDur) - nHour * 3600) / 60
        nSec = int(nDur) % 60
        self.m_tot['DURATION_AVG'] = ('%02dH:%02dM:%02dS' % (nHour, nMin, nSec))
        self.m_tot['PASSED'] = len(self.m_tot['cases_passed'])
        self.m_tot['FAILED'] = len(self.m_tot['cases_failed'])
        self.m_tot['SKIPPED'] = len(self.m_tot['cases_skipped'])
        self.m_tot['IGNORED'] = len(self.m_tot['cases_ignored'])
        self.m_tot['TOTAL'] = (
        self.m_tot['PASSED'] + self.m_tot['FAILED'] + self.m_tot['SKIPPED'] + self.m_tot['IGNORED'] )

        if len(rcs):
            trc1 = rcs[0]
            trc2 = rcs[-1]
            self.m_tot['STARTTIME'] = trc1.get('Start time', '')

        return True


    def analyze(self):
        """
        """
        self.parseFrames()
        self.LOG().debug('=====>TOT:')
        self.LOG().debug(pformat(self.m_tot))
        #print "==>TOT"
        #pprint(self.m_tot)
        return True

    def saveasResult(self, saveto):
        """
        """
        rcstr = self.getResultStr()
        fd = open(saveto, 'w')
        if fd:
            fd.write(rcstr)
            fd.close()
        else:
            self.LOG().error('create file failed : ' + str(saveto))
            exit(1)

        return True

    def dumpResult(self):
        """
        """
        print '--' * 16
        rcstr = self.getResultStr()
        print rcstr
        return True

    def getResultStr(self):
        """
        """

        rcs = self.m_rcs
        #
        rcstr = ''



        #
        sep_str = ('--' * 16 + '\n')

        if self.m_verbose > 0:
            rcstr += sep_str
            rcstr += ('cases PASSED(%d) \n\n' % len(self.m_tot['cases_passed']))
            for casename in self.m_tot['cases_passed']:
                rcstr += (casename + '\n')

            #
            rcstr += sep_str
            rcstr += ('cases SKIPPED(%d) \n\n' % len(self.m_tot['cases_skipped']))
            for casename in self.m_tot['cases_skipped']:
                rcstr += (casename + '\n')

            # Ignored case
            if self.m_tot['IGNORED'] > 0:
                rcstr += sep_str
                rcstr += ('cases IGNORED(%d) \n\n' % len(self.m_tot['cases_ignored']))
                for casename in self.m_tot['cases_ignored']:
                    rcstr += (casename + '\n')
                    #
            rcstr += sep_str
            rcstr += ('cases FAILED(%d) \n\n' % len(self.m_tot['cases_failed']))
            for casename in self.m_tot['cases_failed']:
                rcstr += (casename + '\n')

            #
            rcstr += sep_str
            rcstr += ('cases FAILED without any error detail(%d) \n\n' % len(self.m_tot['cases_failed_no_message']))
            for casename in self.m_tot['cases_failed_no_message']:
                rcstr += (casename + '\n')

            #
            rcstr += sep_str
            rcstr += ('cases FAILED without category(%d) \n\n' % len(self.m_tot['cases_failed_uncategorized']))
            for casename in self.m_tot['cases_failed_uncategorized']:
                rcstr += (casename + '\n')

            #
            rcstr += sep_str
            rcstr += ('cases FAILED with category\n\n')
            for key, cases in self.m_tot['cases_failed_category'].items():
                if len(cases):
                    rcstr += ('\n\n======> (%d)keyword : %s\n\n' % (len(cases), key))
                    for casename in cases:
                        rcstr += (casename + '\n')

            nDuplicated = len(self.m_tot['cases_failed_duplicated_in_category'])
            if nDuplicated:
                rcstr += ('\n\nWARNING : (%d) cases duplicated in category\n\n' % (nDuplicated) )
                for casename in self.m_tot['cases_failed_duplicated_in_category']:
                    rcstr += (casename + '\n')
                # test suites count
            rcstr += sep_str
            rcstr += ('test suites info\n\n')



        #rcstr += ('%-32s : [Case:%3s/%3s/%3s] [Duration:%s/%s]\n'
        #    %('Testsuites','TOTAL','PASSED','FAILED','SUM','AVG' 
        #    ))
        for tst in self.m_tot['tsuites']:

            dur_sum = tst['DURATION']
            dur_avg = 0
            cases_executed = len(tst['PASSED']) + len(tst['FAILED'])
            cases_total = len(tst['PASSED']) + len(tst['FAILED']) + len(tst['SKIPPED']) + len(tst['IGNORED'])
            if (cases_executed) > 0:
                dur_avg = tst['DURATION'] / cases_executed

            if not self.m_all and 0 == cases_total:
                continue

            pretty_sum = ('%02dH:%02dM:%02d.%03dS' % pp_duration(dur_sum) )
            pretty_avg = ('%02dH:%02dM:%02d.%03dS' % pp_duration(dur_avg) )

            #rcstr += ('[D%-10s] [P%03d] [F%03d] : %s \n'%(str(tst['DURATION']),tst['PASSED'],tst['FAILED'],tst['name']))
            tstfile = os.path.basename(tst['name'])
            #rcstr += ('%-32s : [Total:%03d] [Pass:%03d] [Fail:%03d] [Duration_Sum:%10s] [Duration_Avg:%10s]\n'
            #if len(tst['FAILED']) :

            rcstr += ('%s(%d) : \n' % (tstfile, cases_total))
            if cases_executed > 0:
                rcstr += ('[Case Executed:%03d=%03d+%03d]\n[Duration:%10s=%03d*%10s]\n[StartTime:%s]\n'
                          % (cases_executed, len(tst['PASSED']), len(tst['FAILED']),
                             pretty_sum, cases_executed, pretty_avg, tst['STARTTIME']
                ))
                # 
                for it in tst['FAILED']:
                    rcstr += (it + '\n')

            if len(tst['SKIPPED']):
                rcstr += ('[Case Skipped:%03d]\n' % (len(tst['SKIPPED'])))
                # 
                if len(tst['SKIPPED']) == cases_total:
                    rcstr += ('ALL CASES SKIPPED\n')
                else:
                    for it in tst['SKIPPED']:
                        rcstr += (it + '\n')

            if len(tst['IGNORED']):
                rcstr += ('[Case Skipped:%03d]\n' % (len(tst['IGNORED'])))
                # 
                if len(tst['IGNORED']) == cases_total:
                    rcstr += ('ALL CASES INGORED\n')
                else:
                    for it in tst['IGNORED']:
                        rcstr += (it + '\n')
            rcstr += '\n'

        # tot
        rcstr += sep_str
        rcstr += ('Statistics  \n\n')
        rcstr += ('TOTAL        : ' + str(self.m_tot['TOTAL']) + '\n')
        rcstr += ('PASSED       : ' + str(self.m_tot['PASSED']) + '\n')
        rcstr += ('FAILED       : ' + str(self.m_tot['FAILED']) + '\n')
        rcstr += ('SKIPEED      : ' + str(self.m_tot['SKIPPED']) + '\n')
        if self.m_tot['IGNORED'] > 0:
            rcstr += ('IGNORED      : ' + str(self.m_tot['IGNORED']) + '\n')
        rcstr += ('STARTTIME    : ' + str(self.m_tot['STARTTIME']) + '\n')
        rcstr += ('DURATION     : ' + str(self.m_tot['DURATION']) + '\n')
        rcstr += ('DURATION_AVG : ' + str(self.m_tot['DURATION_AVG']) + '\n')

        return rcstr

#------------------------------------------------------------------------------

def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ('\nGet more info with command : pydoc ' + os.path.abspath(__file__) + '\n')
    parser = OptionParser(usage=usage)

    parser.add_option("-a", "--all", dest="analyze_all", action="store_true", default=False,
                      help="analyze all cases include ncases")
    parser.add_option("-d", "--destination", dest="dest",
                      help="destination file to analyze")
    parser.add_option("-k", "--keyword", dest="keywords", action="append",
                      help="keyword(s) to classify error cases in error message")
    parser.add_option("-r", "--keyword_rules_file", dest="rules_file", #action="append",
                      help="rule file contains keyword(s) to classify error cases in error message")
    parser.add_option("-s", "--saveto", dest="saveto",
                      help="Save result to file")
    parser.add_option("-v", "--verbose", type="int", dest="verbose", default=1,
                      help="verbose level to output , default is 1 . \n0 : Summary information only.\n1 : Error details for cases without category only.\n2 : Error details for all")
    parser.add_option("-x", "--loglevel", type="int", dest="loglevel", default=30,
                      help="the log level, default is 30(WARNING)")

    (options, args) = parser.parse_args()
    if not options.dest or not os.path.exists(options.dest):
        print '==', 'destnation log file is not specified or not exist!'
        parser.print_help()
        exit(1)

    return options
    #------------------------------------------------------------------------------


def importRulesFromFile(fname):
    """
    """
    rules = []
    lines = []
    if os.path.exists(fname):
        fd = open(fname)
        if fd:
            lines = fd.readlines()
            fd.close()

    # 
    for line in lines:
        # trip the front and behind white space 
        ss = line.strip()
        # ignore comment line begin with #
        if not ss.startswith('#') and len(ss):
            rules.append(ss)
        #print "-->",rules
    return rules


def main():
    """
    main entry
    """
    opts = parseCommandLine()
    # initial logger
    logger = logging.getLogger('A4ATR')
    #FORMAT = '[%(asctime)-15s %(module)8s:%(lineno)-4d %(levelname)-8s] %(message)s'
    FORMAT = '%(message)s'
    logging.basicConfig(format='%(levelname)-8s : %(message)s')
    # set syslog file
    #if opts.syslog :
    #    # sys
    #    g_hdlr = logging.FileHandler(opts.syslog)
    #    g_hdlr.setFormatter(logging.Formatter(FORMAT))
    #    logger.addHandler(g_hdlr)
    #    # raw sys same as console
    #    #f,d = os.path.basename(options.syslog),os.path.dirname(options.syslog)
    #    #hdlr = logging.FileHandler(d + '/raw_' + f)
    #    #hdlr.setFormatter(logging.Formatter(FORMAT))
    #    #logger.addHandler(hdlr)
    # 
    print "==", 'set loglevel :', opts.loglevel
    logger.setLevel(opts.loglevel)

    #
    srcFile = opts.dest
    save2File = opts.saveto
    keywords = opts.keywords
    # 
    analyzer = A4ATR(logger, verbose=opts.verbose, analyze_all=opts.analyze_all)
    rc = analyzer.loadFile(srcFile)
    if not rc:
        print "==", "loadFile error"
        exit(1)
        # Import Rules from file
    rules = []
    if opts.rules_file:
        rules = importRulesFromFile(opts.rules_file)
    if keywords:
        for keyword in keywords:
            ss = keyword.strip()
            if not ss in rules:
                rules.append(ss)
    rc = analyzer.addKeywords(rules)
    #
    rc = analyzer.analyze()
    if save2File:
        analyzer.saveasResult(save2File)
    else:
        print '==', 'No output file specified, dump in stdout:'
        analyzer.dumpResult()

    exit(0)


if __name__ == '__main__':
    """
    """
    main()


