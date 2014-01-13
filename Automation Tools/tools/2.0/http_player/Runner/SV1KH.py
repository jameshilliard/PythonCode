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


class Runner_V30_20L_4(RunnerBase):
    """
    """
    m_next_sleep_time = 0

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, '30.20L.4', Sender, loglevel)
        self.info('Runner for SV1KH ' + self.m_prod_ver)

    def doWaitingPage(self, req, resp, content):
        print '== uri is : ', req['uri']

        uri = req['uri']

        m_timeout = r'setTimeout\(\"do_re\w*\(\)\", (\d*)\);'

        rc_timeout = re.findall(m_timeout, content)
        sleep_time = 0
        if len(rc_timeout) > 0:
            for index in range(len(rc_timeout)):
                tmp = int(rc_timeout[index])
                rc_timeout[index] = tmp

            rc_timeout.sort(reverse=True)
            sleep_time = float(rc_timeout[0]) / 76

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
        #print '-'*16
        #

        #

        return idPage


    def updateRuntimeStatus(self):
        """
        """
        # get page connect_left_refresh.html
        #		host = os.getenv('G_PROD_BR0_0_0', '192.168.1.254')
        #		uri = '/connect_left_refresh.html'
        #		method = 'GET'
        #
        #
        #		req = {
        #			# combined elements
        #			'URL' : 'http://' + host + uri,
        #			'request-line' : '',
        #			'request-body' : '',
        #			# basic elements
        #			'host' : host,
        #			'proto' : 'HTTP/1.1',
        #			'uri' : uri,
        #			'method' : method,
        #		}
        #
        #		resp, content = self.m_sender.sendRequest(req)
        #
        #		print '== ', content
        #		_ = re.compile('&#(x)?([0-9a-fA-F]+);')
        #		to_str = lambda s, charset = 'utf-8':_.sub(lambda result:unichr(int(result.group(2), result.group(1) == 'x' and 16 or 10)).encode(charset) , s)
        #
        #		raw_content = to_str(content)
        #		print '== ', raw_content
        #
        #		res = raw_content.split('+')
        #		conn_info = None
        #		wan_info = None
        #		wanIntf = None
        #		wanL2IfName = None
        #
        #		if len(res) > 4 : conn_info = res[3]
        #		print '-' * 32
        #
        #		if conn_info :
        #			res = conn_info.split(';')
        #			wan_info = res[0]
        #
        #		if wan_info :
        #			res = wan_info.split(':')
        #			if len(res) > 2 :
        #				wanL2IfName = res[0]
        #				wanIntf = res[1]
        #		# set envrionment variable
        #		if wanIntf :
        #			os.environ['TMP_CUSTOM_WANINF'] = wanIntf
        pass


    def login(self):
        """
        """

        proto = os.environ.get('TMP_HTTP_PROTO', 'http')


        #username = os.getenv('U_DUT_HTTP_USER', 'root')
        password = os.getenv('U_DUT_HTTP_PWD', 'gtwayt3ch215')
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = '172.16.1.254'
            print 'TMP_HTTP_HOST not defined ! using 172.16.1.254 instead'
        ######################################################################################

        uri = '/TECHLOGIN'

        method = 'GET'

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

        if not resp['status'] == '200':
            print '==', 'AT_ERROR : getting login page failed !'
            exit(1)
        ######################################################################################

        uri = '/login_tech.cgi'

        method = 'POST'

        req = {
        # combined elements
        'URL': proto + '://' + host + uri,
        'request-line': '',
        'request-body': 'admin_password=' + password + '&inputPassword_tech=' + password + '&nothankyou=1',
        # basic elements
        'host': host,
        'proto': 'HTTP/1.1',
        'uri': uri,
        'method': method,
        }

        resp, content = self.m_sender.sendRequest(req)

        #	'Cookie': 'ACTSessionID=174928185; Version=1'
        match_err = r'msg=err'
        rc = re.findall(match_err, content)
        #pprint(rc)
        #print 'length of rc :',len(rc)
        if len(rc) > 0:
            print 'login to DUT failed ,please check the username and password !'
            return False
        else:
            print 'login successfully !'

            m_session_key = r'ACTSessionID=(\d*); Version=1'
            #print self.m_sender.m_headers['Cookie']
            sessin_key_str = self.m_sender.m_headers['Cookie']

            if str(sessin_key_str) != '':
                rc_session_key = re.findall(m_session_key, sessin_key_str)

                if len(rc_session_key) > 0:
                    os.environ['TMP_SESSION_KEY'] = str(rc_session_key[0])
                    print '==|change TMP_SESSION_KEY to :', str(rc_session_key[0])
                    return True
                else:
                    return True
            else:
                return True
            return True


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
            # wirelesssetup_basic.wl

            #next_uri = req['uri']

            #		if os.path.basename(next_uri) == 'wirelesssetup_basic.wl':
            #			print '==', 'sleep 45'
            #			time.sleep(45)
            #		idPage = self.parseNextPage(resp, content)

            # do waiting page
            #if 'waiting' == idPage:
            self.doWaitingPage(req, resp, content)

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


hash_runners = {
    '30.20L.4': Runner_V30_20L_4,
}

def_runner = '30.20L.4'


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
	
	
	
