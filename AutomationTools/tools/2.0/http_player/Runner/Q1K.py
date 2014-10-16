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


class Runner_V34_20L_0J(RunnerBase):
    """
    """

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, '34.20L.0j', Sender, loglevel)
        self.info('Runner for Q2KH ' + self.m_prod_ver)

    def doWaitingPage(self, req):
        #
        resp = req['resp-headers']
        content = req['resp-content']

        if not resp or not content:
            print '==', 'Bad request,do not waiting'
            return
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
            'modemstatus_home.html', 'restoreinfo.cgi', 'natcfg.cmd',
        ]

        wp120 = ['rebootinfo.cgi', ]

        wp10 = ['advancedsetup_firewallsettings.html']
        wp80 = ['utilities_restoredefaultsettings.html']

        #if self.cfg['method']!='POST' :
        #   print '==GET will not waiting Page(',redirect,')'
        #   return True
        timeout = 5
        if redirect:
            if redirect.find('wirelesssetup') >= 0:
                timeout = 65
            if redirect in wp35:
                timeout = 35
            elif redirect in wp10:
                timeout = 10
            elif redirect in wp80:
                timeout = 180
            elif redirect in wp120:
                timeout = 120
        print '==Waiting Page(', redirect, ') : ', timeout
        time.sleep(timeout)

    def parseNextPage(self, resp, content):
        """
         
        """

        idPage = ''
        if not resp or not content:
            return idPage

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
        # wanIfName=ppp0 (in broadband setting page)
        _ = re.compile('&#(x)?([0-9a-fA-F]+);')
        to_raw_str = lambda s, charset='utf-8': _.sub(
            lambda result: unichr(int(result.group(2), result.group(1) == 'x' and 16 or 10)).encode(charset), s)

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

        contents = content.split('+')

        is_eth = contents[0]

        print 'is_eth is :', is_eth
        if is_eth == 'xDSL':
        # connect_retry=6

            for conn in range(6):
                print 'try fetch connection info : ', conn
                connInfos = contents[3]
                if len(connInfos) == 0:
                    print 'the connection info is not ready yet .'

                    time.sleep(10)
                    resp, content = self.m_sender.sendRequest(req)
                    contents = content.split('+')
                else:
                    break
            if len(contents[3]) == 0:
                print 'AT_ERROR : connection info is not ready after all'
                exit(1)
            else:
                ifInfos = contents[3].split(':')
                #print len(atms[8].split('+')[2].split(':'))
                layer2ifc = to_raw_str(ifInfos[0])
                print  'layer2ifc : ', to_raw_str(ifInfos[0])
                layer3ifc = to_raw_str(ifInfos[1])
                print  'layer3ifc : ', to_raw_str(ifInfos[1])
                #print  'traffic type : ', to_raw_str(ifInfos[2])
        else:
            print 'current link is ETHERNET'

            infos = to_raw_str(contents[6])
            print infos
            layer2ifc = 'ewan0'
            print  'layer2ifc : ewan0'
            layer3ifc = infos.split(':')[1]
            print 'layer3ifc : ', infos.split(':')[1]
            #time.sleep(10)
        #exit(1)

        #TMP_CUSTOM_WANL2INFNAME     l2
        #TMP_CUSTOM_WANINF            l3
        os.environ['TMP_CUSTOM_WANL2INFNAME'] = layer2ifc
        os.environ['TMP_CUSTOM_WANINF'] = layer3ifc

        if layer2ifc.find('atm') >= 0:
            editWanL2IfName = 'atm0'
            os.environ['TMP_CUSTOM_EDITWANL2INFNAME'] = editWanL2IfName
        elif layer2ifc.find('ptm') >= 0:
            editWanL2IfName = 'ptm0'
            os.environ['TMP_CUSTOM_EDITWANL2INFNAME'] = editWanL2IfName
        #        elif layer2ifc.find('ewan') >= 0:
        #            editWanL2IfName = 'ewan0'
        #if editWanL2IfName != None :
        #    os.environ['TMP_CUSTOM_EDITWANL2INFNAME'] = editWanL2IfName
        m_serv = r'\((.*)\)'
        rc_serv = re.findall(m_serv, layer2ifc)
        #print rc[0]
        if len(rc_serv) > 0:
            servName = rc_serv[0]
            os.environ['TMP_CUSTOM_SERVNAME'] = servName
        pass


    def login(self):
        """
        """
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')

        if proto == 'https':
            username = os.getenv('U_DUT_HTTP_USER', 'admin')
            password = os.getenv('U_DUT_HTTP_PWD', 'QwestM0dem')
            host = os.environ.get('TMP_HTTP_HOST')
            if not host:
                host = '192.168.0.1'
                print 'TMP_HTTP_HOST not defined ! using 192.168.0.1 instead'

            uri = '/login.cgi'
            method = 'POST'

            req = {
                # combined elements
                'URL': proto + '://' + host + uri,
                'request-line': '',
                'request-body': 'adminUserName=' + username + '&adminPassword=' + password + '&sessionKey=646705949&nothankyou=1',
                # basic elements
                'host': host,
                'proto': 'HTTP/1.1',
                'uri': uri,
                'method': method,
            }

            resp, content = self.m_sender.sendRequest(req)

            print '=-' * 16 + '   here comes the content  ' + '-=' * 16
            #print 'here comes the content'
            print content
            print '=-' * 16 + '   so much for the content ' + '-=' * 16

            match = r'Login Failed'
            rc = re.findall(match, content)
            if len(rc) > 0:
                print 'Login failed !'
                return False
            elif len(rc) == 0:
                print 'Login passed !'
                return True
        elif proto == 'http':
            print 'No login !'
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

            # do waiting page
            # if 'waiting'==idPage:
            self.doWaitingPage(req)


        # update Runtime status
        idx2 = idx + 1
        if idx2 < len(Reqs):
            req2 = Reqs[idx2]
            uri = req2['uri']
            s = 'wansetup'
            res = re.findall(s, uri)
            if len(res):
                print '==', 'Next page is wan setup page, need to update RuntimeStatus'
                self.updateRuntimeStatus()
                #self.getIfnames()
            else:
                s1 = 'dsl(\w)tm'
                res = re.findall(s1, uri)
                if len(res):
                    print '==', 'Next page is dslatm/dslptm setting page, need to update RuntimeStatus'
                    self.updateRuntimeStatus()
                    #pass
        return True


######################################################


hash_runners = {
    '34.20L.0j': Runner_V34_20L_0J,
}

def_runner = '34.20L.0j'


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
    
    
    



