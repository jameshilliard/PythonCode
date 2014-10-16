#!/usr/bin/python
"""
VAutomation Test Engine Class
"""

__author__ = "Rayofox"
__version__ = "$Revision: 0.1 $"
__date__ = "$Date: $"
__copyright__ = "Copyright (c) 2011 Rayofox"
__license__ = "Python"

from tcEngine import tcEngine

import os
import sys
import re
import hashlib
import time
import httplib2, urllib
import imp
import types


class Runner(tcEngine):
    """
    """

    #special_type = ['login','warning','notice','error','waiting','thank_you']
    #-------------------------------------------------------------------------------
    def __init__(self):
        tcEngine.__init__(self)
        print '==Based Runner for V1000H SaskTel '
        print '==Based Firmware Version : 30.20L.0d'
        print '==need Login'

    #-------------------------------------------------------------------------------
    replacer = {}

    def parseReplacerFromBuf(self, str):
        m = r'([^=\s]+)\s*=\s*([^\s]*)'
        res = re.findall(m, str)
        for i in range(len(res)):
            k, v = res[i]
            k = urllib.quote(k)
            v = urllib.quote(v)
            self.replacer[k] = v
        return True

    def parseReplacerFromResponse(self):
        content = self.content
        m = r'var\s*sessionKey\s*=\s*\'(\d*)\''
        res = re.findall(m, content)
        if (len(res) > 0):
            print '== sessionkey = ', res
            self.replacer['sessionKey'] = res[0]
            if self.URL_REPL:
                self.URL_REPL.addKV('sessionKey', res[0])
            return True
        return True

    def doReplace(self):
        # get next cfg
        nd = self.current_step
        if len(self.cfgs) <= nd:
            if self.isDebug(): print 'the last of request'
            return True
        cfg = self.cfgs[nd]
        if self.isDebug(): print '++', cfg
        if cfg['method'] != 'POST':
            if self.isDebug(): print '++ method is not POST'
            return True
        for k, v in self.replacer.items():
            #if self.isDebug() : 
            print '++replacer : ', k, v
            m = k + '=([^&]*)'
            cfg['body'] = re.sub(m, k + '=' + v, cfg['body'])
        if self.isDebug(): print '++ new body : ', cfg['body']
        return True

    def handleDynamicReplace(self):
        rc = self.parseReplacerFromResponse()
        if not self.URL_REPL:
            rc = self.doReplace()
        return rc


    def prehandleWanSetting(self):
        # get next cfg
        nd = self.current_step
        if len(self.cfgs) <= nd:
            if self.isDebug(): print 'the last of request'
            return True
        cfg = self.cfgs[nd]
        if self.isDebug(): print '++', cfg
        if cfg['method'] != 'POST':
            #if self.isDebug() : print '++ method is not POST'
            return True
            # get page connect_left_refresh.html
        url = "http://192.168.0.1/connect_left_refresh.html"
        resp, content = self.http.request(url, 'GET', headers=self.headers)
        # parse page such as :
        # xDSL+Disabled||||||0|0|+Disabled+atm0/&#40;0_0_33&#41;:atm0:ATM:IPoE:0&#59;192.168.10.72&#59;255.255.255.0&#59;192.168.10.254&#59;0&#59;1&#59;1&#59;Connected&#59;02-10-18-aa-bb-cd&#59;LLC&#59;10.20.10.10,168.95.1.1&#59;1&#59;1&#59;EoA:1:1492|+Disabled|0|0+Up|508|9085+
        #
        #

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

        #print 'wanIntf = ',wanIntf
        #if wanL2IfName : self.replacer['wanL2IfName'] = wanL2IfName
        if wanIntf:
            self.replacer['wanInf'] = wanIntf
            self.replacer['wanIfName'] = wanIntf
            if self.URL_REPL:
                self.URL_REPL.addKV('wanInf', wanIntf)
                self.URL_REPL.addKV('wanIfName', wanIntf)

        return True

    #-------------------------------------------------------------------------------
    def parseResponse(self):
        self.next_page['type'] = 'normal'
        match = r'<h1 class="thankyou">Saving Settings </h1>'
        match2 = r'<title>Thank you!</title>'
        res = re.search(match, self.content)
        res2 = re.search(match2, self.content)
        #print '==',res,res2
        if res or res2:
            self.next_page['type'] = 'waiting'
            print '==', 'next page is waiting/thankyou page'
        print '-' * 16
        # 
        #self.prehandleWanSetting()
        # 
        #self.handleDynamicReplace()
        return True


    def handleTestCaseResponse(self):
        #print 'TODO:Handle Test Case Response here'
        #print '==Next page is :' ,self.next_page['type']

        if not self.isNextPageSpecial():
            #print 'Next page is not a special page'
            return True
        else:
            # do sleep
            if 'waiting' == self.next_page['type']:
                self.doWaitingPage()
                return True
            print 'Next page is  a special page :', self.next_page['type']
            self.setLastError('Response page is a ' + self.next_page['type'] + ' page')
            return False
            #if self.isNextPageWarning():
        #    print 'Next page is  a special page'
        #    return False

        self.content = ""
        return True

    def doWaitingPage(self):
        key = 'do_waiting_page'
        if self.info.has_key(key):
            if not self.info[key]:
                print '==Ignore Waiting page'
                return
        else:
            print '==Ignore Waiting page'
            return

        # redirect
        redirect = None
        # thankyou.html
        match = r'var\s+redirect\w*\s*=\s*"(.+)"'
        resp = re.findall(match, self.content)
        if len(resp):
            redirect = resp[0]
        wp35 = [
            'advancedsetup_broadbandsettings.html',
            'advancedsetup_dslsettings.html',
            'advancedsetup_wanipaddress.html',
            'advancedsetup_ptmsettings.html',
            'quicksetup_home.html',
            'modemstatus_home.html'
        ]

        wp10 = ['advancedsetup_firewallsettings.html']
        wp80 = ['utilities_restoredefaultsettings.html']

        timeout = 5
        if redirect:
            if redirect.find('wirelesssetup') >= 0:
                timeout = 25
            if redirect in wp35:
                timeout = 35
            elif redirect in wp10:
                timeout = 10
            elif redirect in wp80:
                timeout = 80
        print '==Waiting Page(', redirect, ') : ', timeout
        time.sleep(timeout)
        return True

    #-------------------------------------------------------------------------------

    """
    Login
    """

    def doLogin(self):
        # connect and get login page
        print '==CONNECT HTTP SERVER'
        # get username and password
        username = self.AEV.get('U_DUT_HTTP_USER', 'root')
        password = self.AEV.get('U_DUT_HTTP_PWD', 'gtwayt3ch215')
        #self.http.add_credentials(username, password)

        rc = self.doGet('/TECHLOGIN', dest='172.16.1.254')
        print 'resp = ', self.response
        self.parseResponse()

        # save cookie
        self.saveCookie()
        # do login
        print '==Login'
        #post_data = 'admin_password=gtwayt3ch215&inputPassword_tech=gtwayt3ch215&nothankyou=1'
        post_data = 'admin_password=' + password + '&inputPassword_tech=' + password + '&nothankyou=1'
        rc = self.doPost('/login_tech.cgi', post_data, dest='172.16.1.254')
        if not rc: return False
        rc = self.parseResponse()

        match = r'<title>Login</title>'
        res = re.findall(match, self.content)
        if len(res) > 0:
            print '==', 'login failed'
            rc = False

        return rc

    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    def doLogout(self):
        rc = self.doGet('/logout.cgi', dest='172.16.1.254')
        if not rc: return False
        rc = self.parseResponse()
        return rc

#-------------------------------------------------------------------------------


def main():
    argc = len(sys.argv)
    if argc < 2:
        print 'Usage : ', sys.argv[0], ' test_case_file'
        return False

    ###
    tc_file = sys.argv[1]
    runner = Runner()
    runner.setDebug()
    # load case info
    rc = runner.loadTestCaseFile(tc_file)

    rc = runner.run();
    if not runner.isResultPass():
        print '\n-| FAIL: ', runner.getLastError()
    else:
        print '\n-| PASS '

    return True


if __name__ == "__main__":
    main()
    """
    try:
        main()
    except Exception,e :
        print '\n-| FAIL: ',e
    """
                

        
                
