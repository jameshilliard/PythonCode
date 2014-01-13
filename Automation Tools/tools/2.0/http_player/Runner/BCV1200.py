#!/usr/bin/env python -u
"""
VAutomation Test Engine Class
"""

__author__ = "Rayofox"
__version__ = "$Revision: 0.1 $"
__date__ = "$Date: $"
__copyright__ = "Copyright (c) 2011 Rayofox"
__license__ = "Python"

import os, copy
import sys
import re
import hashlib
import time
import httplib2, urllib, urllib2
import imp
import types, base64
from pprint import pprint
from pprint import pformat
from RunnerBase import RunnerBase


class Runner_V31_126L_02f(RunnerBase):
    """
    #BCV1200-31.126L.02f
    """
    m_next_sleep_time = 0

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, 'V31.126L.02f', Sender, loglevel)
        self.info('Runner for BCV1200 ' + self.m_prod_ver)

    def doWaitingPage(self, req, resp, content):
        print '== uri is : ', req['uri']

        uri = req['uri']
        #setTimeout("do_reload()", 60*1000)
        #m_timeout = r'setTimeout\(\"do_re\w*\(\)\", (\d*)\);'
        m_timeout = r'setTimeout\(\"do_re[^,]*,\s*([^)]*)'

        #pprint(content)

        rc_timeout = re.findall(m_timeout, content)
        #rc_timeout2 = re.findall(m_timeout2, content)
        sleep_time = 0
        if len(rc_timeout) > 0:
            for index in range(len(rc_timeout)):
            #                print rc_timeout
            #                print 'current time out :', rc_timeout[index]
                #    retryTime
                if rc_timeout[index] == 'retryTime':
                    if len(rc_timeout) == 1:
                        rc_timeout[index] = '120*1000'
                    else:
                        rc_timeout[index] = '0'

                time2sleep = os.popen('echo ' + rc_timeout[index] + ' | bc').read()
                #                print 'time2sleep : ', time2sleep
                secs = None
                try:
                    secs = int(time2sleep)
                except:
                    print 'bad number : ', time2sleep

                tmp = secs
                if secs:
                    rc_timeout[index] = tmp
                else:
                    rc_timeout[index] = 0

            rc_timeout.sort(reverse=True)

            print rc_timeout
            #print rc_timeout
            #            time2sleep = os.popen('echo ' + rc_timeout[0] + ' | bc').read()
            #
            #
            #            print secs
            sleep_time = float(rc_timeout[0]) / 666

            print 'sleep_time : ', sleep_time

            if uri.find('.cgi') > -1 or uri.find('.cmd') > -1 or uri.find('.wl') > -1 or uri.find('.tod') > -1:
                print 'uri====>', uri.find('.cgi')
                if uri.find('natcfg.cmd') > -1:
                    sleep_time = 60
                elif uri.find('advancedsetup_lanipaddress_info.cgi') > -1:
                    sleep_time = 120
                if self.m_next_sleep_time > sleep_time:
                    sleep_time = self.m_next_sleep_time
                print '== | sleep ', sleep_time, 'sec according to setTimeout() function'
                time.sleep(sleep_time)
            else:
                if sleep_time > self.m_next_sleep_time:
                    print '== no need to sleep in current page , store it to next page'
                    self.m_next_sleep_time = sleep_time
        else:
            if uri.find('.cgi') > -1 or uri.find('.cmd') > -1 or uri.find('.wl') > -1 or uri.find('.tod') > -1:
                if self.m_next_sleep_time > 0:
                    sleep_time = self.m_next_sleep_time
                    if uri.find('natcfg.cmd') > -1:
                        if sleep_time < 60:
                            sleep_time = 60
                    elif uri.find('advancedsetup_lanipaddress_info.cgi') > -1:
                        sleep_time = 120
                    print '== | sleep ', sleep_time, 'sec according to previous setTimeout() function'
                    self.m_next_sleep_time = 0
                    time.sleep(sleep_time)

                else:
                    print '== no need to sleep'
            else:
                print '== no need to sleep'


    def parseNextPage(self, resp, content):
        """
         
        """
        idPage = ''
        self.m_next_page['type'] = 'normal'
        match = r'<h1 class="thankyou">Saving Settings </h1>'
        match2 = r'<title>Thank You!</title>'

        res = re.search(match, content)
        res2 = re.search(match2, content)
        if res or res2:
            self.m_next_page['type'] = 'waiting'

        return idPage


    def updateRuntimeStatus(self):
        """
        """
        # get page /modemstatus_home_refresh.html
        host = os.getenv('G_PROD_BR0_0_0', '192.168.0.1')
        uri = '/modemstatus_home_refresh.html'
        method = 'GET'

        req = {
            # combined elements
            'URL': 'http://' + host + uri,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': host,
            'proto': 'HTTP/1.1',
            'uri': uri,
            'method': method,
        }

        resp, content = self.m_sender.sendRequest(req)
        #print '== ', content
        #0++1++fe80::215:5ff:fefa:7af0+fd00::1/64+DHCP+++ewan0.1++ppp0.1++++Disconnected+Connecting+++0
        #1++0++fe80::215:5ff:fefa:7af0+fd00::1/64+DHCP+++ewan0.1++++++Connecting+Unconfigured+fe80::215:5ff:fefa:7af3++0
        #1++0++fe80::215:5ff:fefa:7af0+fd00::1/64+DHCP+++ewan0.1++ppp0.1++++Connecting+Disconnected+fe80::215:5ff:fefa:7af3++0
        _ = re.compile('&#(x)?([0-9a-fA-F]+);')
        to_str = lambda s, charset='utf-8': _.sub(
            lambda result: unichr(int(result.group(2), result.group(1) == 'x' and 16 or 10)).encode(charset), s)

        raw_content = to_str(content)
        print '== ', raw_content

        res = raw_content.split('+')
        print '== res', res

        if len(res) > 10:
            wanInf = res[9]
            if wanInf:
                os.environ['TMP_CUSTOM_WANINF'] = wanInf
            #        conn_info = None
            #        wan_info = None
            #        wanIntf = None
            #        wanL2IfName = None
            #
            #        if len(res) > 4 :
            #           conn_info = res[3]
            #           print '== conn_info', conn_info
            #        print '-' * 32
            #
            #        if conn_info :
            #            res = conn_info.split(';')
            #            wan_info = res[0]
            #            print '== wan_info', wan_info
            #
            #        if wan_info :
            #            res = wan_info.split(':')
            #            if len(res) > 2 :
            #                wanL2IfName = res[0]
            #                print '== wanL2IfName', wanL2IfName
            #                wanIntf = res[1]
            #                print '== wanIntf', wanIntf
            #        # set envrionment variable
            #        if wanIntf :
            #            os.environ['TMP_CUSTOM_WANINF'] = wanIntf
            #            print 'NOTICE : TMP_CUSTOM_WANINF set to :', wanIntf
            #        pass


    def login(self):
        """
        inputUserName    root
        inputPassword    Thr33scr33n!
        nothankyou    1 G_PROD_IP_BR0_0_0
        """

        print '== in function login()'
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')

        username = os.getenv('U_DUT_HTTP_USER', 'admin')
        password = os.getenv('U_DUT_HTTP_PWD', 'password')
        password = urllib.quote(password)
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.254 instead'

        uri = '/'
        url = proto + '://' + host + uri

        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': host,
            'proto': proto,
            'uri': uri,
            'method': 'GET',
        }

        resp, content = self.m_sender.sendRequest(req)

        #uri = '/login.cgi?inputUserName=' + username + '&inputPassword=' + password + '&nothankyou=1'
        url = proto + '://' + host + '/login.cgi?inputUserName=' + username + '&inputPassword=' + password + '&nothankyou=1'
        method = 'POST'

        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': 'inputUserName=' + username + '&inputPassword=' + password + '&nothankyou=1',
            # basic elements
            'host': host,
            'proto': proto,
            'uri': uri,
            'method': method,
        }

        resp, content = self.m_sender.sendRequest(req)

        match_err = r'msg=err'
        rc = re.findall(match_err, content)
        #pprint(rc)
        #print 'length of rc :',len(rc)
        if len(rc) > 0:
            print 'login to DUT failed ,please check the username and password !'
            return False
        else:
            print 'login successfully !'

            if resp.has_key('set-cookie'):
                curr_Cookie = resp['set-cookie']
                m_session_id = r'ACTSessionID=(\d*)'

                rc_sess_id = re.findall(m_session_id, curr_Cookie)

                if len(rc_sess_id) > 0:
                    curr_session_id = rc_sess_id[0]
                    print '==| change current session id to : ', curr_session_id
                    os.environ['TMP_SESSION_ID'] = curr_session_id

            return True

    def logout(self):
        """
        """
        print '==to Logout'
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.0.1 instead'

        url = proto + '://' + host + '/logout.cgi'
        method = 'POST'

        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': '',
            'proto': '',
            'uri': '',
            'method': method,
        }

        resp, content = self.m_sender.sendRequest(req)

        return True


    def beforeReqeust(self, Reqs, idx):
        """
        """
        # 
        return True

    def afterReqeust(self, Reqs, idx):
        """
        """
        req = Reqs[idx]
        #        print '+' * 30
        #        pprint(req)
        #        print '+' * 30

        if req.has_key('resp-headers') and req.has_key('resp-content') and req['resp-content'] != None:
            resp = req['resp-headers']
            content = req['resp-content']

            #            print '+' * 30
            #            pprint(content)
            #            print '+' * 30
            m = r'var globalSessionKey\s*=\s*\'(.*)\';'
            res = re.findall(m, content)
            if len(res):
                os.environ.update(
                    {
                        'TMP_SESSION_ID': res[0],
                    }
                )
                print '----- TMP_SESSION_ID :', os.getenv('TMP_SESSION_ID')
            #
            #            if resp.has_key('Cookie'):
            #                curr_Cookie = resp['Cookie']
            #                m_session_id = r'ACTSessionID=(\d*)'
            #
            #                rc_sess_id = re.findall(m_session_id, curr_Cookie)
            #
            #                if len(rc_sess_id) > 0:
            #                    curr_session_id = rc_sess_id[0]
            #
            #                    previous_session = os.getenv('TMP_SESSION_ID')
            #                    if  previous_session != None and  previous_session != curr_session_id :
            #                        print '==| change current session id to : ', curr_session_id
            #                        os.environ['TMP_SESSION_ID'] = curr_session_id

        if req.has_key('resp-headers') and req.has_key('resp-content') and req['resp-content'] != None and req[
            'resp-headers'] != None:
            self.doWaitingPage(req, resp, content)

        # update Runtime status
        idx2 = idx + 1
        if idx2 < len(Reqs):
            req2 = Reqs[idx2]
            uri = req2['uri']
            s = 'wansetup.cmd'
            res = re.findall(s, uri)
            if len(res):
                print '==', 'Next page is wansetup.cmd, need to update RuntimeStatus'
                self.updateRuntimeStatus()
            else:
                s1 = 'dsl(\w)tm'
                res = re.findall(s1, uri)
                if len(res):
                    print '==', 'Next page is dslatm/dslptm setting page, need to update RuntimeStatus'
                    self.updateRuntimeStatus()
        return True

    def upgradeFirmware(self, filepath, ver=None):
        """
        """

        host = os.environ.get('TMP_HTTP_HOST')
        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.0.1 instead'

        #uri = '/upload.cgi'
        proto = 'http'
        uri = '/utilities_upgradefirmware.html'
        url = proto + '://' + host + uri
        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': '',
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'GET',
        }
        self.m_timeout = 120
        resp, content = self.m_sender.sendRequest(req)

        uri = '/upload.cgi'
        key = 'filename'
        fname = os.path.basename(filepath)
        val = open(filepath, 'rb').read()
        files = [(key, fname, val)]

        rc = self.m_sender.uploadFileNew(proto + '://' + host + uri, {key: open(filepath, 'rb')})
        return rc


    ######################################################


hash_runners = {
    'BCV1200-31.126L.02f': Runner_V31_126L_02f,
}

def_runner = 'BCV1200-31.126L.02f'


def getRunner(prod_ver):
    """
    """
    runner = None
    for (k, v) in hash_runners.items():
        if k == prod_ver:
            runner = v
            print '==', 'Find specified Runner for Version ' + prod_ver
            break
    if not runner:
        print '==', 'Not find specified Runner for Version ' + str(prod_ver)
        print '==', 'Using the default Runner for Version ' + def_runner
        runner = hash_runners[def_runner]
        #return runner(prod_ver)
    return runner
    
    
    
