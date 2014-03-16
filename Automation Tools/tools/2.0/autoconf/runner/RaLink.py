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
import httplib2, urllib, urllib2
import imp
import types, base64


class Runner(tcEngine):
    """
    """

    def __init__(self):
        tcEngine.__init__(self)
        print '==Runner for RaLink '

    #-------------------------------------------------------------------------------
    def parseAuthKey(self):
        content = self.content
        mask = ""
        match = r"name=\"(passwordmask_\d+)"
        r = re.search(match, content)
        #print r
        if r:
            gp = r.groups()
            mask = gp[0]
            #print 'passwordmask',mask

        auth_key = ""
        match = r"name=\"auth_key\" value=\"(\d+)\""
        r = re.search(match, content)
        #print r
        if r:
            gp = r.groups()
            auth_key = gp[0]
            #print 'auth_key',auth_key

        return mask, auth_key

    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    def makeMd5Pass(self, passwd, auth_key):
        md5_pass = ""
        m = hashlib.md5(passwd + auth_key)
        m.digest()
        md5_pass = m.hexdigest()
        return md5_pass

    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    def parseResponse(self):
        status = self.response['status']
        if '401' == status:
            self.next_page['type'] = '401 Unauthorized'

    def handleTestCaseResponse(self):
        #print 'TODO:Handle Test Case Response here'
        #print '==Next page is :' ,self.next_page['type']

        if not self.isNextPageSpecial():
            #print 'Next page is not a special page'
            return True
        else:
            print 'Next page is  a special page :', self.next_page['type']
            self.setLastError('Response page is a ' + self.next_page['type'] + ' page')
            return False
            #if self.isNextPageWarning():
        #    print 'Next page is  a special page'
        #    return False


        return True

    #-------------------------------------------------------------------------------

    """
    Login
    """

    def doLogin(self):
        #connect and get login page
        print '==CONNECT HTTP SERVER'
        username = self.info['username']
        password = self.info['password']
        self.http.add_credentials(username, password)
        self.doGet()
        self.parseResponse()

        #save cookie
        self.saveCookie()
        #do login

        print '==Login'
        #self.doGet()
        #self.parseResponse()


        return True

    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    def doLogout(self):
        print '==LOGOUT'

        body = {
            'active_page': '9131',
            'active_page_str': 'page_home_act_vz',
            'page_title': 'Main',
            'mimic_button_field': 'logout: ...',
            'button_value': '.',
            'strip_page_top': '0'

        }
        self.doPost('/index.cgi', body);
        self.parseResponse();
        if self.isNextPageLogin():
            print '==Logout Success'
        else:
            print "==Logout Error"
            return False
        return True

#-------------------------------------------------------------------------------
"""parse test case file        
    HOST = [192.168.1.1]
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
                

        
                
