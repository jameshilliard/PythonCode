#!/usr/bin/env python -u
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
import httplib2, urllib, urllib2
import imp
import types, base64


class Runner(tcEngine):
    """
    """

    def __init__(self):
        tcEngine.__init__(self)
        print '==Based Runner for Telus V2000H '
        print '==Based Firmware Version : 31.60L.14'
        print '==need Login'

    #-------------------------------------------------------------------------------
    def parseResponse(self):
        match = r'<h1 class="thankyou">Saving Settings </h1>'
        match2 = r'<title>Thank You!</title>'

        if not self.content: self.content = ''
        res = re.search(match, self.content)
        res2 = re.search(match2, self.content)
        if res or res2:
            self.next_page['type'] = 'waiting'


    def handleTestCaseResponse(self):
        #print 'TODO:Handle Test Case Response here'
        #print '==Next page is :' ,self.next_page['type']
        if self.cfg['method'] == 'GET':
            q = self.cfg['query']
            #print q
            if len(q) == 0:
                return True
            path = self.cfg['path']
            # restoreinfo.cgi?noThankyou=1
            #match = r'([^/]*)' 
            #res = re.findall(match,self.cfg['path'],re.I)
            res = path.split('/')
            print res
            wp90 = ['restoreinfo.cgi', 'rebootinfo.cgi']
            # default waiting seconds
            timeout = 15
            redirect = 'None'
            l = len(res)
            # redirect parse
            if l > 0:
                redirect = res[l - 1]
                if redirect in wp90:
                    timeout = 90
                # sleep a while
            print '==Query Waiting Page(', redirect, ') : ', timeout
            time.sleep(timeout)
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
        match = r'var redirect = "(.+)";'
        resp = re.findall(match, self.content)
        if len(resp):
            redirect = resp[0]
        wp15 = [
            'advancedsetup_broadbandsettings.html',
            'advancedsetup_dslsettings.html',
            'advancedsetup_wanipaddress.html',
            'advancedsetup_ptmsettings.html',
            'quicksetup_home.html',
            'modemstatus_home.html'
        ]

        wp10 = ['advancedsetup_firewallsettings.html']
        timeout = 5
        if redirect:
            if redirect in wp15:
                timeout = 15
            elif redirect in wp10:
                timeout = 10
        print '==Waiting Page : ', timeout
        time.sleep(timeout)

    #-------------------------------------------------------------------------------


    #-------------------------------------------------------------------------------

    """
    Login 
    """

    def doLogin(self):
        # connect and get login page
        print '==CONNECT HTTP SERVER'

        username = self.AEV.get('U_DUT_HTTP_USER', 'root') #"root"   #self.info['username']
        password = self.AEV.get('U_DUT_HTTP_PWD', 'Thr33scr33n!') #"Thr33scr33n!"   #self.info['password']
        #self.http.add_credentials(username, password)

        rc = self.doGet()
        print 'resp = ', self.response
        self.parseResponse()

        #save cookie
        self.saveCookie()
        #do login

        print '==Login'

        query_data = 'inputUserName=' + urllib.quote(username) + '&inputPassword=' + urllib.quote(
            password) + '&nothankyou=1'
        rc = self.doGet('/login.cgi', query=query_data)
        if not rc:
            print '==Login Failed'
            return False
        rc = self.parseResponse()

        # the login error response content
        err = """
        <html>
        <head>
        <script language="Javascript">
        function do_load(){
            window.top.location.href="index.html?msg=err";
        }
 
        </script>
        </head>

        <body onload="do_load()">

        </body>
        </html>
        """
        match = r'msg=err'
        res = re.findall(match, self.content)
        if len(res) > 0:
            print '==', 'login failed'
            rc = False
        else:
            rc = True

        return rc

    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    def doLogout(self):
        print '==LOGOUT'
        rc = True
        #rc = self.doGet('/logout.cgi');
        #if not rc : return False
        #self.parseResponse();
        """
        if self.isNextPageLogin():
            print '==Logout Success'
        else:
            print "==Logout Error"
            return False
        """
        return rc

#-------------------------------------------------------------------------------
"""parse test case file        
    HOST = [192.168.1.254]
    USERNAME = [] 
    PASSWORD = [] 
    
    METHOD PATH DATA
    [GET] [\index.cgi] []
    [POST] [\index.cgi] [key=val&key2=val2]
    
"""

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
                

        
                
