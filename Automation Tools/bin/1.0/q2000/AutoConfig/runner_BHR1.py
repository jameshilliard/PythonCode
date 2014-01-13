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

class Runner(tcEngine ):
    """
    """
    page_id2type = {
    '9001' : 'warning',
    '730' : 'warning',
    #'9138' : 'error',
    }
    def __init__(self):
        print '==Runner for BHR2 Rev.F '
        
#-------------------------------------------------------------------------------
    def parseAuthKey(self):
        content = self.content
        mask = ""
        match = r"name=\"passwordmask_(\d+)"
        r = re.search(match,content)
        #print r
        if r :
            gp = r.groups()
            mask=gp[0]
            #print 'passwordmask',mask
            
        auth_key = ""
        match = r"name=\"auth_key\" value=\"(\d+)\""
        r = re.search(match,content)
        #print r
        if r :
            gp = r.groups()
            auth_key=gp[0]
            #print 'auth_key',auth_key
        
        return mask,auth_key
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
    def makeMd5Pass(self,passwd,auth_key):
        md5_pass = ""
        m = hashlib.md5(passwd+auth_key)
        m.digest()
        md5_pass = m.hexdigest()
        return md5_pass
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
    def parseResponse(self):
        #print "Need Implement Yourself"
        location = ''
        if self.response.has_key('location') :
            location = self.response['location']
        #print 'location = ',location
        location = urllib.unquote(location)
        match = r'active_page=(\w*)'
        rr = re.findall(match,location)
        if len(rr) > 0:
            self.next_page['id'] = rr[0]
        match = r'active_page_str=(\w*)'
        rr = re.findall(match,location)
        if len(rr) > 0:
            self.next_page['title'] = rr[0]
        w = r'has_warnings=(\w*)'
        e = r'has_errors=(\w*)'
        #print s
        rr = re.findall(w,location)
        if len(rr) > 0:
            if int(rr[0]) > 0:
                self.next_page['type'] = 'warning'
            
        rr = re.findall(e,location)
        if len(rr) > 0:
            if int(rr[0]) > 0  :
                self.next_page['type'] = 'error'
        
        #parse content
        match = r'Page\(\d+\)=\[Login\]'
        rr = re.findall(match,self.content)
        if len(rr) > 0:
            self.next_page['type'] = 'login'
        
        #
        page_id = self.next_page['id']
        if '9067'==page_id:
            self.next_page['type'] = 'login'
        elif '9131'==page_id:
            self.next_page['type'] = 'main'
        elif '9001'==page_id :
            self.next_page['type'] = 'warning'
        
        ##
        if self.isDebug():
            self.p_hist('next_page',self.next_page)

        #return 0
    def handleTestCaseResponse(self):
        #print 'TODO:Handle Test Case Response here'
        #print '==Next page is :' ,self.next_page['type']
        
        if not self.isNextPageSpecial():
            #print 'Next page is not a special page'
            return True
        else:
            print 'Next page is  a special page :',self.next_page['type']
            self.setLastError('Response page is a ' + self.next_page['type']+' page')
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
        self.doGet()
        self.parseResponse()
        if not self.isNextPageLogin():
            #self.p_hist('next_page',self.next_page)
            print '==Next page is not Login'
            self.setLastError('Can not get login page')
            return False
        #save cookie
        self.saveCookie()
        # parse response content 
        self.handleTestCaseResponse()
        
        #do login
        
        print '==Login'
        username = self.info['username']
        password = self.info['password']
        #parse AuthKey
        mask,auth_key = self.parseAuthKey()
        #makeMd5Pass
        md5_pass = self.makeMd5Pass(password,auth_key)
        body = {
            'active_page':9067,
            'session_id' : mask,
            'nav_stack_0' : 9047,
            'page_title' : 'Login',
            'mimic_button_field' : 'submit_button_login_submit: ..',
            'button_value' : '',
            'transaction_id' : 3,
            'user_name' : username,
            'passwordmask_'+mask : password,
            'passwd1' : ' '*15,
            'md5_pass' : md5_pass,
            'auth_key' : auth_key
            
            }
        self.doPost('/cache/846886334/index.cgi',body)
        self.parseResponse()
        if self.isNextPageLogin():
            print '==Error:login failed!'
            self.setLastError('Can not login')
            return False
        return True
#-------------------------------------------------------------------------------
    
#-------------------------------------------------------------------------------    
    def doLogout(self):
        print '==LOGOUT'

        body = {
        'active_page':'9131',
        'active_page_str':'page_home_act_vz',
        'page_title':'Main',
        'mimic_button_field':'logout: ...',
        'button_value':'.',
        'strip_page_top':'0'

        }
        self.doPost('/index.cgi',body);
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
        print 'Usage : ',sys.argv[0],' test_case_file'
        return False
    
    ###
    tc_file = sys.argv[1]
    runner = Runner()
    runner.setDebug()
    # load case info
    rc = runner.loadTestCaseFile(tc_file)

    rc = runner.run();
    if not runner.isResultPass():
      print '\n-| FAIL: ',runner.getLastError()
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
                

        
                
