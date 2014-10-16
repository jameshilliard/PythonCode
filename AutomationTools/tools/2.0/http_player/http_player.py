#!/usr/bin/python
#       http_player.py
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
"""
This tool is an HTTP request player using in Automation Test.It offer the following functions :
1. Parse record files with Firefox plugin "Live HTTP Headers" to python data structs. Wireshark support is in next plan.
2. Specify runner for websites those need login/logout,and runtime key in HTTP request headers,such as cached key.
3. Replace some values in HTTP headers with specified rules.
4. Create new files same as record files after do replacement.
5. Check request-body or/and query-body in record files.
6. Send HTTP reqeust after do replacement.
7. Send single URL and output response content

Usage :
1. check post files
    python http_player.py BHR2 recordfile -c
    ./http_player.py BHR2 "B-BHR2-WI.SEC-*" -c

2. pretend to play with replacement and save to other file ,diff two files to check replacement rule
    python http_player.py BHR2 recordfile -t -s newrecfile -v "U_WIRELESS_CUSTOM_WEP_KEY64bit1=test"

    you can using ATE -t to import ENV and test
    ATE -f cfg/env.cfg -f cfg/dut.cfg -f cfg/tst.cfg -f cfg/tb.cfg -t "python http_player.py BHR2 recordfile -t -s newrecfile"

3. play file
    python http_player.py BHR2 recordfile -l logpath

4. play single url and output response content (optional save content to a file with -s)
    python http_player.py BHR2 -g 'http://192.168.1.1'
    python http_player.py -g 'http://www.google.com' -s 'google_index.html'

NEW Feature :
2012/03/16
. append http request to log file (you can merge log file with minicom)
  python http_player.py BHR2 recordfile -l logpath -a append2log
"""
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2011, Rayofox"
__version__ = "1.0"
__history__ = """
Rev 1.0 : 2011/11/10
    Initial version
"""
#------------------------------------------------------------------------------
from types import *
import sys, time, os
import re
import socket
from optparse import OptionParser
from pprint import pprint
from pprint import pformat
import subprocess, signal, select
from copy import deepcopy
import traceback
import types
import urllib

from http_parser import Http_Parser
# import check_record_file
from http_request_sender import HttpRequestSender
from url_query_str import url_query_str
#------------------------------------------------------------------------------

def uniqAppend(arr, item):
    """
    append unique value into list
    """
    if item not in arr: arr.append(item)


class Http_Player():
    """
    This class is the HTTP Player
    """
    # member variables
    # 0 : play
    # 1 : pretend play
    # 2 : check files
    m_mode = 0
    m_prod_id = None
    m_prod_ver = None
    m_sender = None
    m_runner = None
    m_parser = None
    m_pageHandler = None
    m_prod_id = None
    m_prod_ver = None
    m_recfile = None
    m_applogfile = None
    m_naExit = 0
    #
    m_check_results = {
        'changed': [],
        'nochange': [],
        'ignored': [],
        'nohandler': [],
        'changeInfo': {},
    }
    #
    # 3 : debug
    # 2 : info
    # 1 : warning
    # 0 : error
    m_msglvl = 2
    m_logpath = None
    m_reqs = []
    m_hashENV = {}

    #
    m_index = 0

    def loadEnv(self):
        """
        load env
        """
        for (k, v) in os.environ.items():
            if 0 == k.find('G_'):
                self.m_hashENV[k] = v
            elif 0 == k.find('U_'):
                self.m_hashENV[k] = v
            elif 0 == k.find('TMP_'):
                self.m_hashENV[k] = v

    def __init__(self, product_id, Product_Version=None, msglevel=2, mode=0, applogfile=None, naExit=0):
        """
        try to load all components :
        Sender
        Parser
        Runner
        PageHandler
        """
        #
        self.loadEnv()
        #
        # all input
        self.m_msglvl = msglevel
        self.m_prod_id = product_id
        self.m_mode = mode
        self.m_applogfile = applogfile
        self.m_naExit = naExit

        if not Product_Version:
            self.info('DUT Version is not specified ,using U_DUT_FW_VERSION defined')
            Product_Version = self.m_hashENV.get('U_DUT_FW_VERSION', None)
        self.m_prod_ver = Product_Version
        if not self.m_prod_ver:
            # self.error("DUT Version is not specified and U_DUT_FW_VERSION defined")
            # exit(2)
            pass
            # sender
        # if 0==self.m_mode :
        self.m_sender = HttpRequestSender()
        self.m_sender.setAppendLogFile(self.m_applogfile)
        # parser
        self.m_parser = Http_Parser(loglevel=self.m_msglvl)

        # runner
        if 0 == self.m_mode:
            if product_id:
                cmd = 'from Runner import ' + product_id + ' as RUNNER'
                exec (cmd)
                Runner = RUNNER.getRunner(Product_Version)
                self.m_runner = Runner(self, self.m_sender)
                if not self.m_runner:
                    self.error('Can not find Runner for ' + product_id + ' ' + Product_Version)
                    exit(1)
            else:
                print '==', 'Not specified DUT, Common Runner'
                from Runner import RunnerBase

                self.m_runner = RunnerBase.RunnerBase(self, '', self.m_sender)

        # page handler
        if product_id:
            cmd = 'from PageHandler import ' + product_id + ' as PGHDL'
            exec (cmd)
            self.m_pageHandler = PGHDL.getPageHandler(Product_Version, self)

    def debug(self, msg):
        """
        """
        if self.m_msglvl > 2:
            print("== Http_Player Debug : " + str(msg))
            # print(str(msg)  )
        return True

    def info(self, msg):
        """
        """
        if self.m_msglvl > 1:
            print '== Http_Player Info : ', str(msg)
        return True

    def warning(self, msg):
        """
        """
        if self.m_msglvl > 0:
            print '== Http_Player Warning : ', str(msg)
        return True

    def error(self, msg):
        """
        """
        print '== Http_Player AT_ERROR : ', str(msg)
        return True


    def check_server(self, address, port):
        s = socket.socket()
        print 'attempting to connect to %s on port %s' % (address, port)

        try:
            s.connect((address, port))
            print 'connected to %s on port %s' % (address, port)
            return True
        except socket.error, e:
            print 'connection to %s on port %s failed : %s' % (address, port, e)
            return False
        finally:
            print 'be a good citizen and close all your connections'
            s.close()

    def login(self):
        """
        """
        login_retry_count = 6
        if self.m_runner:

            for retry in range(login_retry_count):

                print '== | try login : ', str(retry + 1)
                self.info('try login : ' + str(retry + 1))

                print '== | try left : ', str(login_retry_count - retry - 1)
                self.info('try left : ' + str(login_retry_count - retry - 1))

                try:
                    login_rc = self.m_runner.login()

                    self.info('login result :' + str(login_rc))
                    # if login_rc:
                    return login_rc
                    # else:
                    #   self.info('sleep for 10s')
                    #  time.sleep(10)
                except Exception, e:
                    self.warning('Exception : ' + str(e))
                    self.info('sleep for 30s and try again')

                    if retry == login_retry_count - 1:
                        if self.m_naExit == 1:
                            self.error('AT_ERROR : error occur when trying to login , stop for debug !')
                            skip_rest_lbl = '$G_LOG/current/skip_all_rest.LABEL'
                            skip_rest_lbl = os.path.expandvars(skip_rest_lbl)
                            curr_log_dirr = os.path.expandvars('$G_LOG/current')

                            if not os.path.exists(curr_log_dirr):
                                self.error(skip_rest_lbl + ' not found')
                                self.info('using /tmp/skip_all_rest.LABEL.test instead')
                                skip_rest_lbl = '/tmp/skip_all_rest.LABEL.test'

                            output = open(skip_rest_lbl, 'a')

                            output.write('AT_ERROR : error occur when trying to login , stop for debug !')
                            output.write('\n')

                            output.close()
                        else:
                            self.error('AT_ERROR : error occur when trying to login')
                            return False

                    else:
                        time.sleep(30)
        else:
            self.error('No runner to run login')
            return False


    def logout(self):
        """
        """
        if self.m_runner:
            try:
                return self.m_runner.logout()
            except Exception, e:
                self.warning('Exception : ' + str(e))
                return True
        else:
            self.error('No runner to run logout')
            return False

    def upgradeFirmware(self, ufw, ver):
        """
        """
        if self.m_runner:
            try:
                return self.m_runner.upgradeFirmware(ufw, ver)
            except Exception, e:
                self.warning('Exception : ' + str(e))
                return True
        else:
            self.error('No runner to run updateFirmware')
            return False


    def beforeReqeust(self, Reqs, idx):
        """
        """
        #
        if self.m_runner:
            return self.m_runner.beforeReqeust(Reqs, idx)
        else:
            self.error('No runner to run beforeReqeust')
            return False


    def afterReqeust(self, Reqs, idx):
        """
        """
        if self.m_runner:
            return self.m_runner.afterReqeust(Reqs, idx)
        else:
            self.error('No runner to run afterReqeust')
            return False


    def replRequest(self, req):
        """
        """
        host = os.getenv('G_PROD_IP_BR0_0_0', None)
        if host:
            if req.has_key('host'):
                req['host'] = host
        if self.m_pageHandler:
            rc = self.m_pageHandler.replRequest(req)
            self.debug('replRequest Result : ')
            self.debug(rc)
            (nreq, changed) = rc
            if changed:
                self.info('Request Replaced : ' + nreq['request-line'])
        else:
            self.error('No PageHandler to run replRequest')
            return False
        return rc

    def checkRequest(self, req):
        """
        """
        if self.m_pageHandler:
            self.debug('\n\n' + '- ' * 32 + '\nTo check : ')
            self.debug(self.m_parser.dumpReq(req))
            rc = self.m_pageHandler.checkRequest(req)
            self.debug('checkRequest Result : ')
            self.debug(rc)

            self.debug('\n\n' + '- ' * 32 + '\n\n')
            # self.info(rc['message'])
            if not rc['result']:
                uniqAppend(self.m_check_results['nohandler'], rc['pagename'])
            elif rc['result'] == 'SAME':
                uniqAppend(self.m_check_results['nochange'], rc['pagename'])
            elif rc['result'] == 'IGNORE':
                uniqAppend(self.m_check_results['ignored'], rc['pagename'])
            elif rc['result'] == 'DIFF':
                uniqAppend(self.m_check_results['changed'], rc['pagename'])
                inf = self.m_check_results['changeInfo']
                name = rc['pagename']
                if not inf.has_key(name):
                    inf[name] = []
                uniqAppend(inf[name], rc['message'])
        else:
            self.error('No PageHandler to run checkRequest')
            return False
        return rc

    def check(self, recfiles):
        """
        """
        dut_type = self.m_prod_id
        if not recfiles:
            self.error('No recfile specified')
            return False

        # if not parser or not dut_type :
        #   self.error('No Parser or DUT specified')
        #   return False

        # list files
        cmd = 'ls ' + recfiles
        resp = os.popen(cmd).read()
        files = resp.split()
        # loop check
        for rec_file in files:
            parser = Http_Parser()  # (loglevel=self.m_msglvl)
            print "--" * 16
            print "==check file:", rec_file
            parser.parseRecordFile(rec_file)
            reqs = parser.getResult()
            print "==Total request:", str(len(reqs))
            for req in reqs:
                rc = self.checkRequest(req)
            parser = None
        print '==', 'Check Result : '

        #
        crc = self.m_check_results
        for (k, v) in crc.items():
            if type(v) == types.ListType:
                v.sort()
        pprint(self.m_check_results)
        return True

    def upgradeFW(self, ufw, ver=None):
        """
        """
        # login
        rc = self.login()
        if not rc: return rc

        # update firmware
        rc = self.upgradeFirmware(ufw, ver)
        if not rc: return rc

        # logout
        # self.info(' LOGOUT')
        # rc = self.logout()
        # if not rc : return rc

        return rc


    def playGet(self, url, save2):
        """
        """
        self.info('in function playGet()')
        self.info('to get connect of URL :' + url)

        m = r'(\w*)://([^/]*)/?(.*)'
        rc = re.findall(m, url)
        proto, host, uri = rc[0]

        m_port = r':(\d*)'

        rc_port = re.findall(m_port, host)

        if len(rc_port) > 0:
            port = rc_port[0]
            self.info('port : ' + port)

        self.info('proto : ' + proto + ' host : ' + host + ' uri : ' + uri)

        os.environ.update({'TMP_HTTP_PROTO': proto, 'TMP_HTTP_HOST': host})

        login_result = self.login()

        if not login_result:
            # print 'login to dut failed!!!'
            self.error('login to dut failed!!!')
            exit(1)
        else:
            # print 'login to dut passed!!!'
            self.info('login to dut passed!!!')

        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': None,
            # basic elements
            'host': '',
            'proto': '',
            'uri': str(uri),
            'method': 'GET',
        }

        resp, content = self.m_sender.sendRequest(req)
        self.logout()

        if save2:
            fd = file(save2, 'w')
            if fd:
                fd.write(content)
                fd.close()
            else:
                self.error('can not open file : ' + save2)
        else:
            print '==' * 32
            print '==', 'Response Headers :'
            print ''
            print resp
            print '==' * 32
            print '==', 'Page Content :'
            print ''
            print content
            pass
        return

    def play(self, pretended=False):
        """
        """
        # dut_address=os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1')

        # if not self.check_server( dut_address , 80 ):
        #    print 'the http server seems to be down ...'
        #    exit(1)
        #
        # if not self.check_server( dut_address , 443 ):
        #    print 'the https server seems to be down ...'
        #    exit(1)

        if 0 == len(self.m_reqs):
            self.warning('req is empty!')
            return True
            # login
        if not pretended:
            rc = self.login()
            if not rc: return rc

            self.logRecFile()
            # play record
        ncount = len(self.m_reqs)
        for index, req in enumerate(self.m_reqs):
            print '\n'
            print '------->> Current Step ', ncount, ':', index
            print '== Begin Time :', time.asctime()
            self.m_index = index

            #
            t1 = time.time()

            # take replacement
            rc = self.replRequest(req)
            # update req
            self.m_parser.updateReqByBodyAndQuery(req)
            self.m_parser.updateReq(req)
            # if not rc : break
            #
            if not pretended:
                try:
                    # bebore sending request
                    rc = self.beforeReqeust(self.m_reqs, index)
                    if not rc:
                        break
                    elif rc == 2:
                        self.info(req['request-line'])
                        self.info('Skip this request!')
                        continue

                    resp, content = self.m_sender.sendRequest(req)
                    req['resp_headers'] = resp
                    req['resp_content'] = content
                    # save
                    # if req['method']=='GET' :
                    path = req['uri']
                    self.saveRespContent(path, resp, content)
                    # after sending request
                    rc = self.afterReqeust(self.m_reqs, index)
                    if not rc: break
                except Exception, e:
                    self.warning('Exception : ' + str(e))
                    # traceback.print_exc()
                    formatted_lines = traceback.format_exc().splitlines()
                    pprint(formatted_lines)
                    self.info('Ignore exception')
                    time.sleep(3)
                    self.afterReqeust(self.m_reqs, index)
                # calc time span
            dt = time.time() - t1
            req['req-time'] = pformat('%.3f' % dt)
            print ''
            print('== Spend Time : %.3f' % dt)
            print '==' * 32
            print '\n'
        if not pretended:
            # logout
            self.info(' LOGOUT')
            rc = self.logout()
            if not rc: return rc
            # log post file
        self.logRecFile()
        return rc


    def load(self, recfile):
        """
        """
        if not recfile:
            self.error('No recfile specified')
            exit(1)
        self.m_recfile = recfile
        parser = self.m_parser
        parser.parseRecordFile(recfile)
        rc = parser.getResult()
        self.m_reqs = rc

        # save post file history
        fname = os.path.basename(self.m_recfile)
        hf = os.getenv('G_CUSTOM_POST_FILE_HISTORY', None)
        if hf:
            cmd = "echo '%s' >> '%s' " % (fname, hf)
            os.system(cmd)

            #
            cmd = "echo '%s' >> '%s' " % (self.m_recfile, hf + '_fullpath')
            os.system(cmd)
            pass

        return True

    def saveAsRecFile(self, fname):
        """
        """
        print '==saveAs:', fname
        if fname:
            return self.m_parser.saveAs(fname)

    def logRecFile(self):
        """
        """
        if not self.m_logpath:
            print '==', 'no log directory '
            return False
        fn = os.path.basename(self.m_recfile)
        fname = self.m_logpath + '/' + fn
        return self.m_parser.saveAs(fname)


    def saveRespContent(self, uri, resp, content):
        """
        save request response to logpath
        1. save response-content into file ,have rename rule when file existed
        2. save relation of response-content files and request-line in file menu
        """
        if not self.m_logpath:
            print '==', 'no log directory '
            return False
        if not content:
            print '==', 'content is None'
            return False
        if len(content) == 0:
            print '==', 'content is empty'
            return False
            #

        path, query = urllib.splitquery(uri)
        zpath = path.split('/')
        pn = zpath[-1]
        pndir = '/'.join(zpath[0:len(zpath) - 1])

        fn = self.m_logpath + pndir + '/' + pn

        d = os.path.dirname(fn)
        fname = os.path.basename(fn)
        if not os.path.exists(d):
            os.makedirs(d)

        if os.path.exists(fn):
            fn = fn + '_step_' + str(self.m_index)
        print '==', 'save response content file ', fn
        f = file(fn, 'w')
        f.write(content)
        f.close()
        # wirte detail
        fn2 = self.m_logpath + '/menu'
        txt = ('Step ' + str(self.m_index) + '\n')
        txt += ('URI  : ' + uri + '\n')
        txt += ('PAGE : ' + os.path.basename(fn) + '\n')
        txt += ('\n\n')
        f = file(fn2, 'a')
        f.write(txt)
        f.close()

        return True

    def newUrlQueryStr(self, s):
        """
        """
        return url_query_str(s)

#------------------------------------------------------------------------------

def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [DUT] [RECORD_FILE] [options]\n"
    usage += ('\nGet detail introduction and sample usange with command : pydoc ' + os.path.abspath(__file__) + '\n\n')
    usage += "Arguments :\n"
    usage += "DUT              : The DUT id ,such as Q2KH, not required only when -g \n"
    usage += "RECORD_FILE      : The HTTP reqeust record file,not required only when -g\n"

    parser = OptionParser(usage=usage)
    # check post file
    parser.add_option("-a", "--appendlogfile", dest="applogfile",
                      default=False, help="append http request into file")
    parser.add_option("-c", "--check_only", action="store_true", dest="check_only",
                      default=False, help="Checking record file only")
    parser.add_option("-f", "--configfile", dest="cfgfile", action="append",
                      help="The environment config file to set")

    parser.add_option("-g", "--get", dest="get",
                      help="send http GET request,-g URL")
    parser.add_option("-l", "--logpath", dest="logpath",
                      help="Save logs to path")

    parser.add_option("-s", "--saveAs", dest="saveas",
                      help="This option is used with -t or -g , save result as")
    # pretend play to check replacement rule
    parser.add_option("-t", "--pretend", action="store_true", dest="pretend",
                      default=False, help="pretend to play with replacement rule,but not really sending request ")

    parser.add_option("-v", "--variableOption", dest="vos", action="append",
                      help="The environment to set, format is key=val")
    parser.add_option("-x", "-d", "--loglevel", type="int", dest="loglevel", default=2,
                      help="the log level, default is 2(INFO) 0 : error ;1 : warning;2 : infor;3 : debug")
    parser.add_option("-z", "--naExit", type="int", dest="naExit", default=0,
                      help="whether to cancel all followed testcase when DUT un-reachable")

    parser.add_option("--upgrade_firmware_file", dest="ufw",
                      help="This option is the firmware file to upgrade")

    parser.add_option("--upgrade_firmware_version", dest="ufv",
                      help="This option is the firmware version to upgrade")

    (options, args) = parser.parse_args()
    # output the options list
    print '==' * 32
    print 'Args :'
    print args
    print 'Options :'
    excludes = ['read_file', 'read_module', 'ensure_value']
    for k in dir(options):
        if k.startswith('_') or k in excludes:
            continue
            #
        v = getattr(options, k)
        print k, ':', v

    # check args
    # if len(args) == 1 :
    #   pass
    # elif len(args) == 2. :
    #   if options.get :
    #       parser.print_help()
    #       exit(1)
    # else :
    #   parser.print_help()
    #   exit(1)

    # parse option
    # if options.get :
    #
    if options.check_only:
        print '==', 'Check Mode'
        # check_post_files(args[0],args[1])
        # exit(0)
    elif options.pretend:
        print '==', 'Pretended Play Mode'
        if not options.saveas and not options.logpath:
            print '==', '-t MUST with -s saveas or -l logpath'
            exit(3)
    else:
        print '==', 'Play Mode'

    #
    if options.cfgfile:
        parseCfgFiles(options.cfgfile)

    if options.vos:
        for kv in options.vos:
            parseVerb(kv)

    return args, options
    #------------------------------------------------------------------------------


def parseVerb(kv):
    """
    """
    match = r'(\w*)=(.*)'
    # print '==',kv
    res = re.findall(match, kv)
    for (k, v) in res:
        (k, v) = res[0]
        print '==', 'import env :', k, ' = ', v
        os.environ[k] = v
        # print


def parseCfgFiles(files):
    """
    """
    for fn in files:
        fd = file(fn, 'r')
        if fd:
            lines = fd.readlines()
            fd.close()
            for line in lines:
                line = line.strip()
                if line.startswith('#'):
                    pass
                else:
                    if line.startswith('-v'):
                        m = r'-v\s*(.*)'
                        res = re.findall(m, line)
                        if len(res):
                            kv = res[0]
                            parseVerb(kv)
        else:
            print '==', 'AT_ERROR :', 'Can not open file : ', fn


def exportCurrentPath():
    """
    """
    import os, sys

    path = sys.path[0]
    if os.path.isdir(path):
        # return path
        pass
    elif os.path.isfile(path):
        path = os.path.dirname(path)

    print '==add path :', path
    sys.path.append(path)


def main():
    """
    main entry
    """

    timeout = 20
    socket.setdefaulttimeout(timeout)

    t0 = time.time()
    # HPlayer = Http_Player('BHR2','20.19.0')
    args, opts = parseCommandLine()
    # check args

    #
    exportCurrentPath()

    # mode = 0
    if opts.get:
        # single play mode
        mode = 3
    elif opts.check_only:
        mode = 2
    elif opts.pretend:
        mode = 1
    elif opts.ufw:
        mode = 4
    else:
        mode = 0
        #
    dut = None
    recfile = None
    if len(args) > 0: dut = args[0]
    if len(args) > 1:  recfile = args[1]

    if recfile and not opts.get and not opts.check_only and not os.path.exists(recfile):
        print '==', 'AT_ERROR :', 'File is not exist :', recfile
        exit(1)
        # create player
    HPlayer = Http_Player(dut, msglevel=opts.loglevel, applogfile=opts.applogfile, naExit=opts.naExit)


    #
    if opts.logpath:
        HPlayer.m_logpath = opts.logpath
        d = opts.logpath
        if not os.path.exists(d):
            os.makedirs(d)
        #
    if opts.get:
        rc = HPlayer.playGet(opts.get, opts.saveas)
        exit(rc)
    elif opts.check_only:
        rc = HPlayer.check(recfile)
    elif opts.pretend:
        rc = HPlayer.load(recfile)
        rc = HPlayer.check(recfile)
        rc = HPlayer.play(True)
        if opts.saveas:
            HPlayer.saveAsRecFile(opts.saveas)
    elif opts.ufw:
        rc = HPlayer.upgradeFW(opts.ufw, opts.ufv)
    else:
        rc = HPlayer.load(recfile)
        print '==' * 32
        print '==', 'To Check...\n'
        rc = HPlayer.check(recfile)
        print '==' * 32
        print '==', 'To Play...\n'
        rc = HPlayer.play()

    dt = time.time() - t0
    print '==' * 32
    print '\n'
    print('== Spend Time : %.3f seconds' % dt)

    if not rc: exit(1)
    exit(0)


if __name__ == '__main__':
    """
    """
    main()


