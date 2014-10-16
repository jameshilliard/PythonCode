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


class Runner_V08D(RunnerBase):
    """
    """

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, 'FTH-BHRK2-10-10-08D', Sender, loglevel)
        self.info('Runner for FiberTech ' + self.m_prod_ver)

    def doWaitingPage(self, tw=5):
        """
        """
        print '==Waiting page ', str(tw), 'seconds'
        time.sleep(tw)

    def parseNextPage(self, resp, content):
        """
         
        """
        idPage = ''
        return idPage


    def login(self):
        """
        """
        return True

    def logout(self):
        """
        """
        return True


    def beforeReqeust(self, Reqs, idx):
        """
        """
        # 
        req = Reqs[idx]

        uri = req['uri']

        m = r'\.act$'
        res = re.findall(m, uri)
        if len(res):
        #time.sleep(2)
            #return 2
            pass

        return True

    def afterReqeust(self, Reqs, idx):
        """
        """
        req = Reqs[idx]

        uri = req['uri']
        pn = os.path.basename(uri)
        if pn == 'waiting_page.html':
            #self.doWaitingPage(5)
            pass

        if req.has_key('resp-headers') and req.has_key('resp-content'):
            print '==', req['resp_headers']
            m = r'\.act$'
            m_rbt = r'advanced_reboot_router.act$'
            res_rbt = re.findall(m_rbt, uri)
            res = re.findall(m, uri)
            if len(res):
                if len(res_rbt):
                    self.doWaitingPage(180)
                    pass
                    #print '==',req['resp_content']
                self.doWaitingPage(5)
                pass
            if req['method'] == 'POST':
                self.doWaitingPage(5)
        return True


######################################################

class Runner_V08G(Runner_V08D):
    """
    """

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, 'FTH-BHRK2-10-10-08G', Sender, loglevel)
        self.info('Runner for FiberTech ' + self.m_prod_ver)

    def login(self):
        """
        """
        self.info('== To Login')
        username = os.getenv('U_DUT_HTTP_USER', 'admin')
        password = os.getenv('U_DUT_HTTP_PWD', 'password')
        url = os.getenv('U_DUT_HTTP_HOME', 'http://192.168.1.1')
        m = r'https?://([^/]*)'
        res = re.findall(m, url)
        host = '192.168.1.1'
        if len(res): host = res[0]

        # local login
        # connect to DUT
        req = {
            # combined elements
            'URL': url,
            'request-line': 'GET / HTTP/1.1',
            'request-body': None,
            # basic elements
            'host': host,
            'proto': 'HTTP/1.1',
            'uri': '/',
            'method': 'GET',
        }

        Sender = self.m_sender
        #resp,content = Sender.sendRequest(req)
        #print(resp)
        #self.doWaitingPage(2)
        # check next page is main page
        #idPage = self.parseNextPage(resp,content)
        #if idPage != 'login' :  return False

        # do login
        req['URL'] += '/index.cgi'
        req['request-line'] = 'POST /index.cgi HTTP/1.1'
        req['method'] = 'POST'

        body = {
            'login_username': username,
            'login_password': password,
        }
        req['request-body'] = urllib.urlencode(body)
        # send login request
        resp, content = Sender.sendRequest(req)
        print(resp)

        # check next page is main page
        idPage = self.parseNextPage(resp, content)
        if idPage != 'main':
            self.error('Get main page after login failed')
            print(resp)
            #print(content)
            return False
        self.info('== Login Success')
        self.doWaitingPage(5)
        return True

    def logout(self):
        """
        """
        return True

    def parseNextPage(self, resp, content):
        """
         
        """
        typePage = ''
        location = ''
        next_page = self.m_next_page
        next_page['id'] = ''
        next_page['title'] = ''
        #
        if resp.has_key('location'):
            location = resp['location']
        print 'location = ', location
        if len(location) > 0:
            location = urllib.unquote(location)
            pg = os.path.basename(location)
            if pg == 'main.html':
                typePage = 'main'
            elif pg == 'waiting_page.html':
                typePage = 'waiting'
            elif pg == 'index.html':
                typePage = 'login'

        next_page['type'] = typePage
        print '==', 'next_page = ', pformat(next_page)
        return typePage


class Runner_V08H(Runner_V08D):
    """
    """

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, 'FTH-BHRK2-10-10-08H', Sender, loglevel)
        self.info('Runner for FiberTech ' + self.m_prod_ver)

    def login(self):
        """
        """
        self.info('== To Login')

        proto = os.environ.get('TMP_HTTP_PROTO', 'http')
        username = os.getenv('U_DUT_HTTP_USER', 'admin')
        password = os.getenv('U_DUT_HTTP_PWD', 'password')

        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.254 instead'

        uri = '/'
        url = proto + '://' + host + uri

        req = {
            # combined elements
            'URL': url,
            'request-line': 'GET / HTTP/1.1',
            'request-body': None,
            # basic elements
            'host': host,
            'proto': 'HTTP/1.1',
            'uri': '/',
            'method': 'GET',
        }

        Sender = self.m_sender
        #resp,content = Sender.sendRequest(req)
        #print(resp)
        #self.doWaitingPage(2)
        # check next page is main page
        #idPage = self.parseNextPage(resp,content)
        #if idPage != 'login' :  return False

        # do login
        req['URL'] += '/index.cgi'
        req['request-line'] = 'POST /index.cgi HTTP/1.1'
        req['method'] = 'POST'

        body = {
            'login_username': username,
            'login_password': password,
        }
        req['request-body'] = urllib.urlencode(body)
        #print('login req : '+req['URL'])
        # send login request
        resp, content = Sender.sendRequest(req)
        print(resp)

        # check next page is main page
        idPage = self.parseNextPage(resp, content)
        if idPage != 'main':
            self.error('Get main page after login failed')
            print(resp)
            #print(content)
            return False
        self.info('== Login Success')
        self.doWaitingPage(5)
        return True

    def logout(self):
        """
        """
        self.info('== To Logout')

        proto = os.environ.get('TMP_HTTP_PROTO', 'http')

        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.254 instead'

        uri = '/logout.cgi'
        url = proto + '://' + host + uri

        # local logout
        # logout DUT
        req = {
            # combined elements
            'URL': url,
            'request-line': 'GET / HTTP/1.1',
            'request-body': None,
            # basic elements
            'host': host,
            'proto': 'HTTP/1.1',
            'uri': uri,
            'method': 'GET',
        }

        try:
            Sender = self.m_sender
            Sender.sendRequest(req)
        except Exception, e:
            self.warning('Exception : ' + str(e))
            return True
        return True

    def parseNextPage(self, resp, content):
        """
         
        """
        typePage = ''
        location = ''
        next_page = self.m_next_page
        next_page['id'] = ''
        next_page['title'] = ''
        #
        if resp.has_key('location'):
            location = resp['location']
        print 'location = ', location
        if len(location) > 0:
            location = urllib.unquote(location)
            pg = os.path.basename(location)
            if pg == 'main.html':
                typePage = 'main'
            elif pg == 'waiting_page.html':
                typePage = 'waiting'
            elif pg == 'index.html':
                typePage = 'login'

        next_page['type'] = typePage
        print '==', 'next_page = ', pformat(next_page)
        return typePage

    def upgradeFirmware(self, filepath, ver=None):
        """
        """

        print '---' * 32
        host = os.environ.get('TMP_HTTP_HOST')
        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.1 instead'

        #uri = '/upload.cgi'
        proto = 'http'
        uri = '/advanced_firmware_upgrade_local.html'
        url = proto + '://' + host + uri
        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'GET',
        }
        resp, content = self.m_sender.sendRequest(req)

        print '-->', 'Get upgrade firmware page Done!'
        uri = '/advanced_firmware_upgrade_local.cgi'
        fields = {
            'apply_page': 'advanced_firmware_upgrade_confirm.html',
            'waiting_page_topmenu': '5',
            'waiting_page_leftmenu': '1',
            'adv_upgradeimage_file': open(filepath, 'rb'),
        }
        rc = self.m_sender.uploadFileNew(proto + '://' + host + uri, fields=fields)
        print '-->', 'upload File Done!'

        proto = 'http'
        uri = '/advanced_firmware_upgrade_confirm.cgi'
        url = proto + '://' + host + uri
        req_1 = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': 'apply_page=index.html&waiting_page=waiting_reboot.html&waiting_page_topmenu=5&waiting_page_leftmenu=1',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_1)
        print '-->', 'upload File Done!'

        proto = 'http'
        uri = '/advanced_firmware_upgrade_confirm.act'
        url = proto + '://' + host + uri
        req_2 = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_2)
        return rc

######################################################

hash_runners = {
    'FTH-BHRK2-10-10-08D': Runner_V08D,
    'FTH-BHRK2-10-10-08E': Runner_V08D,
    'FTH-BHRK2-10-10-08G': Runner_V08D,
    'FTH-BHRK2-10-10-08H': Runner_V08H,
    'FTH-BHRK2-10-10-08I': Runner_V08H,
}

def_runner = 'FTH-BHRK2-10-10-08H'


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
    
    
    



