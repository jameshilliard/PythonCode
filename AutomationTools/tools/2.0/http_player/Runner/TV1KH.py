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


class Runner_V31_121L_00E(RunnerBase):
    """
    """
    m_next_sleep_time = 0

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, '31.121L.00e', Sender, loglevel)
        self.info('Runner for TV1KH ' + self.m_prod_ver)

    def doWaitingPage(self, req, resp, content):
        print '== uri is : ', req['uri']

        uri = req['uri']

        #       if uri.find('advancedsetup_remotetelnet.cgi') > -1:
        #           print 'resp of remote telnet :'
        #           print '\n'
        #           print resp
        #           print 'cont of remote telnet :'
        #           print '\n'
        #           print content
        #           print '\n' * 2

        #exit(0)

        m_timeout = r'setTimeout\(\"do_re\w*\(\)\", (\d*)\);'

        rc_timeout = re.findall(m_timeout, content)
        sleep_time = 0
        if len(rc_timeout) > 0:
            for index in range(len(rc_timeout)):
                tmp = int(rc_timeout[index])
                rc_timeout[index] = tmp

            rc_timeout.sort(reverse=True)
            #print rc_timeout
            sleep_time = float(rc_timeout[0]) / 500

            print 'sleep_time : ', sleep_time
            if uri.find('.cgi') > -1 or uri.find('.cmd') > -1 or uri.find('.wl') > -1:
                if self.m_next_sleep_time > sleep_time:
                    sleep_time = self.m_next_sleep_time
                print '== | sleep ', sleep_time, 'sec according to setTimeout() function'
                time.sleep(sleep_time)
            else:
                print '== no need to sleep in current page , store it to next page'
                self.m_next_sleep_time = sleep_time
        else:
            if uri.find('.cgi') > -1 or uri.find('.cmd') > -1:
                if self.m_next_sleep_time > 0:
                    sleep_time = self.m_next_sleep_time
                    print '== | sleep ', sleep_time, 'sec according to previous setTimeout() function'
                    self.m_next_sleep_time = 0
                    time.sleep(sleep_time)

                else:
                    #print '== no need to sleep'
                    #print 'resp content : '
                    #print content

                    bn = os.path.basename(uri)
                    print '== Page name is :', bn
                    wp = {
                        'advancedsetup_remotetelnet.cgi': 10,
                    }
                    if bn in wp:
                        print '== | sleep ', str(wp[bn]), 'seconds according to empirical value'
                        time.sleep(wp[bn])

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
            #print '-'*16
        # 

        # 

        return idPage


    def updateRuntimeStatus(self):
        """
        """
        # get page connect_left_refresh.html
        host = os.getenv('G_PROD_BR0_0_0', '192.168.1.254')
        uri = '/connect_left_refresh.html'
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

        #print '== ',content
        _ = re.compile('&#(x)?([0-9a-fA-F]+);')
        to_str = lambda s, charset='utf-8': _.sub(
            lambda result: unichr(int(result.group(2), result.group(1) == 'x' and 16 or 10)).encode(charset), s)

        raw_content = to_str(content)
        #print '== ',raw_content

        res = raw_content.split('+')
        conn_info = None
        wan_info = None
        wanIntf = None
        wanL2IfName = None

        if len(res) > 4: conn_info = res[3]
        print '-' * 32

        if conn_info:
            res = conn_info.split(';')
            wan_info = res[0]

        if wan_info:
            res = wan_info.split(':')
            if len(res) > 2:
                wanL2IfName = res[0]
                wanIntf = res[1]
            # set envrionment variable
        if wanIntf:
            os.environ['TMP_CUSTOM_WANINF'] = wanIntf
            print 'NOTICE : TMP_CUSTOM_WANINF set to :', wanIntf
        pass


    def login(self):
        """
        """
        print '== in function login()'
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')

        username = os.getenv('U_DUT_HTTP_USER', 'root')
        password = os.getenv('U_DUT_HTTP_PWD', 'Thr33scr33n!')
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = '192.168.1.254'
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
            'proto': 'HTTP/1.1',
            'uri': uri,
            'method': 'GET',
        }

        resp, content = self.m_sender.sendRequest(req)

        uri = '/login.cgi'
        bd = 'inputUserName=' + username + '&inputPassword=' + password + '&nothankyou=1'
        url = proto + '://' + host + uri
        method = 'POST'

        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': bd,
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
            host = '192.168.1.254'
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.254 instead'
        uri = '/logout.cgi'
        url = proto + '://' + host + uri
        method = 'POST'

        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': host,
            'proto': proto,
            'uri': uri,
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
        if req.has_key('resp-headers') and req.has_key('resp-content'):
            resp = req['resp-headers']
            content = req['resp-content']

            if resp.has_key('set-cookie'):
                curr_Cookie = resp['set-cookie']
                m_session_id = r'ACTSessionID=(\d*)'

                rc_sess_id = re.findall(m_session_id, curr_Cookie)

                if len(rc_sess_id) > 0:
                    curr_session_id = rc_sess_id[0]

                    previous_session = os.getenv('TMP_SESSION_ID')
                    if previous_session != None and previous_session != curr_session_id:
                        print '==| change current session id to : ', curr_session_id
                        os.environ['TMP_SESSION_ID'] = curr_session_id

            # check next page
            #idPage = self.parseNextPage(resp, content)

            # do waiting page
            #if 'waiting' == idPage:
            self.doWaitingPage(req, resp, content)

            # update Runtime status
        #       idx2 = idx + 1
        #       if idx2 < len(Reqs) :
        #           req2 = Reqs[idx2]
        #           uri = req2['uri']
        #           s = 'advancedsetup_wanipaddress'
        #           res = re.findall(s, uri)
        #           if len(res) :
        #               print '==', 'Next page is advancedsetup_wanipaddress, need to update RuntimeStatus'
        #               self.updateRuntimeStatus()
        #           else :
        #               pass
        return True

    def upgradeFirmware(self, filepath, ver=None):
        """
        """

        host = os.environ.get('TMP_HTTP_HOST')
        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.254')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.254 instead'

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
    '31.121L.00e': Runner_V31_121L_00E,
}

def_runner = '31.121L.00e'


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
    
    
    



