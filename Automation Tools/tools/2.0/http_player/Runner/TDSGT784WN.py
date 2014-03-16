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


class Runner_V1_1L_0A_GT784WN(RunnerBase):
    """
    """

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, '1.1L.0a-gt784wn', Sender, loglevel)
        self.info('Runner for TDSGT784 ' + self.m_prod_ver)

    def doWaitingPage(self, req):
        #
        resp = req['resp-headers']
        content = req['resp-content']
        if not 'POST' == req['method']:
            print '==', 'Not do waiting after GET'
            return

        # redirect
        redirect = None
        # thankyou.html
        match = r'var\s+redirect\w*\s*=\s*"(.+)"'
        res = re.findall(match, content)
        if len(res):
            redirect = res[0]
        else:
            print '==', 'No redirect in response-headers'
            redirect = os.path.basename(req['uri'])

        wp35 = [
            'advancedsetup_broadbandsettings.html',
            'advancedsetup_dslsettings.html',
            'advancedsetup_wanipaddress.html',
            'advancedsetup_ptmsettings.html',
            'quicksetup_home.html',
            'modemstatus_home.html'
        ]

        wp10 = ['advancedsetup_firewallsettings.html']
        wp80 = ['utilities_restoredefaultsettings.html',
                'wirelesssetup_basic.wl']

        #if self.cfg['method']!='POST' :
        #	print '==GET will not waiting Page(',redirect,')'
        #	return True
        timeout = 5
        if redirect:
            if redirect.find('wirelesssetup') >= 0:
                timeout = 65
            if redirect in wp35:
                timeout = 35
            elif redirect in wp10:
                timeout = 10
            elif redirect in wp80:
                timeout = 12
        print '==Waiting Page(', redirect, ') : ', timeout
        time.sleep(timeout)

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
        host = os.getenv('G_PROD_BR0_0_0', '192.168.0.1')
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

        print '== ', content
        _ = re.compile('&#(x)?([0-9a-fA-F]+);')
        to_str = lambda s, charset='utf-8': _.sub(
            lambda result: unichr(int(result.group(2), result.group(1) == 'x' and 16 or 10)).encode(charset), s)

        raw_content = to_str(content)
        print '== ', raw_content

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

        pass


    def login(self):
        """
        """
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')

        if proto == 'https':
            print 'this is a TODO feature , can copy it from Q2KH and modify ...'

            return True
        elif proto == 'http':
            print 'Try auto login !'
            # http://192.168.0.1/login.cgi?TDSAutoLogin=1&nothankyou=1
            # 192.168.0.1login.cgi
            uri = '/login.cgi?TDSAutoLogin=1&nothankyou=1'
            method = 'GET'
            proto = 'http'
            host = '192.168.0.1'
            req = {
            # combined elements
            'URL': proto + '://' + host + uri,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': host,
            'proto': 'HTTP/1.1',
            'uri': uri,
            'method': method,
            }

            resp, content = self.m_sender.sendRequest(req)

            #print '\n'*3
            #print resp
            #print '\n'*3
            return True
        #return True

    def logout(self):
        """
        """
        print '==No Logout'
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
            # check next page
            idPage = self.parseNextPage(resp, content)

            #print '\n'*3
            #print resp
            #print '\n'*3

            m = r'"globalSessionKey" value="(.*)"'
            find_session_key = False
            session_key_line = ''
            lines = content.splitlines()
            for line in lines:
                if line.find('globalSessionKey') >= 0:
                    #print "find global session key : ",line
                    find_session_key = True
                    session_key_line = line
                    break
            if find_session_key:
                rc = re.findall(m, session_key_line)
                if len(rc) > 0:
                    tmp_glb_session_key = rc[0]
                    if os.getenv('TMP_GLB_SESSION_KEY') != tmp_glb_session_key:
                        if not os.getenv('TMP_GLB_SESSION_KEY'):
                            print '\n' * 2
                            print 'Global session key found ,setting it to :', tmp_glb_session_key
                            print '\n' * 2
                        else:
                            print '\n' * 2
                            print 'Global session key changed ,changing it to :', tmp_glb_session_key
                            print '\n' * 2
                        os.environ.update({'TMP_GLB_SESSION_KEY': tmp_glb_session_key})
                    else:
                        print 'no need to change the Global session key '
                else:
                    print "regex match failed !"
            else:
                print "session key not found !"

            #print '\n'*3
            #print 'Global session key is : ',os.getenv('TMP_GLB_SESSION_KEY')
            #print '\n'*3
            self.doWaitingPage(req)


        # update Runtime status
        idx2 = idx + 1
        if idx2 < len(Reqs):
            req2 = Reqs[idx2]
            uri = req2['uri']
            s = 'advancedsetup_wanipaddress'
            res = re.findall(s, uri)
            if len(res):
                print '==', 'Next page is advancedsetup_wanipaddress, need to update RuntimeStatus'
                self.updateRuntimeStatus()
            else:
                pass
        return True


######################################################

# 1.1L.0a-gt784wn
hash_runners = {
    '1.1L.0a-gt784wn': Runner_V1_1L_0A_GT784WN,
}

def_runner = '1.1L.0a-gt784wn'


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
	
	
	



