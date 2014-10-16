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
from pprint import pprint
from pprint import pformat


def diff_dict(hash1, hash2):
    """
    """
    rc = False
    if not len(hash1) == len(hash2):
        return True

    for k in hash1.keys():
        if not hash2.has_key(k):
            rc = True
            break
        if not str(hash1[k]).strip() == str(hash2[k]).strip():
            rc = True
            break
    return rc


class Runner(tcEngine):
    """
    """

    def __init__(self):
        """
        """
        tcEngine.__init__(self)
        print '==Based Runner for Version BHR2 (MI424WR-GEN2) '
        print '==Based Firmware Version : 20.16.0'
        print '==Need Login '
        #--------------------------------------------------------------------------

    def parseAuthKey(self):
        """
        """
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

    def makeMd5Pass(self, passwd, auth_key):
        """
        """
        md5_pass = ""
        m = hashlib.md5(passwd + auth_key)
        m.digest()
        md5_pass = m.hexdigest()
        return md5_pass

    #--------------------------------------------------------------------------

    def parseResponse(self):
        """
        """
        #print "Need Implement Yourself"
        location = ''
        if self.response.has_key('location'):
            location = self.response['location']
        #print 'location = ',location
        location = urllib.unquote(location)
        match = r'active_page=(\w*)'
        rr = re.findall(match, location)
        if len(rr) > 0:
            self.next_page['id'] = rr[0]
        match = r'active_page_str=(\w*)'
        rr = re.findall(match, location)
        if len(rr) > 0:
            self.next_page['title'] = rr[0]
        w = r'has_warnings=(\w*)'
        e = r'has_errors=(\w*)'
        #print s
        rr = re.findall(w, location)
        if len(rr) > 0:
            if int(rr[0]) > 0:
                self.next_page['type'] = 'warning'

        rr = re.findall(e, location)
        if len(rr) > 0:
            if int(rr[0]) > 0:
                self.next_page['type'] = 'error'

        #parse content
        match = r'Page\(\d+\)=\[Login\]'
        rr = re.findall(match, self.content)
        if len(rr) > 0:
            self.next_page['type'] = 'login'

        #
        page_id = self.next_page['id']
        if '9074' == page_id:
            self.next_page['type'] = 'login'
        elif '9131' == page_id:
            self.next_page['type'] = 'main'
        elif '9001' == page_id:
            self.next_page['type'] = 'warning'
        elif '6014' == page_id:
            self.next_page['type'] = 'waiting'

        ##
        if self.isDebug():
            self.p_hist('next_page', self.next_page)
        return True


    def handleTestCaseResponse(self):
        """
        """
        if not self.isNextPageSpecial():
            #print 'Next page is not a special page'
            pass
        else:
            if 'waiting' == self.next_page['type']:
                self.doWaitingPage()
                return True
            else:
                print 'Next page is  a special page :', self.next_page['type']
                self.setLastError('Response page is a ' + self.next_page['type'] + ' page')
            #return False
        return True

    def doWaitingPage(self):
        """
        """
        tw = 5
        print '==Waiting page ', str(tw), 'seconds'
        time.sleep(tw)

    #--------------------------------------------------------------------------

    def replBeforeRequest(self):
        """
        """
        from url_repl.BHR2_wi_repl import http_request_repl

        hrr = http_request_repl()
        #if self.cfg['method']=='POST' :
        print '==', 'cfg = ', pformat(self.cfg)
        cfg = hrr.do_repl(self.cfg)
        if diff_dict(cfg, self.cfg):
            self.cfg = cfg
            print '==', 'newcfg = ', pformat(self.cfg)
        return True


    #--------------------------------------------------------------------------

    def doLogin(self):
        """
        """
        print '==CONNECT HTTP SERVER'
        self.cfg = {
        'description': 'Login',
        'protocol': 'HTTP',
        'destination': '192.168.1.1',
        'method': '',
        'path': '',
        'body_len': 0,
        'query': '',
        'body': ''
        }
        self.doGet()
        self.parseResponse()
        if not self.isNextPageLogin():
            #self.p_hist('next_page',self.next_page)
            print '==Next page is not Login'
            self.setLastError('Can not get login page')
            return False
        #save cookie
        self.saveCookie()
        #do login

        print '==Login'
        username = "admin"#self.info['username']
        password = "admin1"#self.info['password']
        #parse AuthKey
        mask, auth_key = self.parseAuthKey()
        print "==|", mask, auth_key
        #makeMd5Pass
        md5_pass = self.makeMd5Pass(password, auth_key)
        body = {
        'active_page': 9074,
        'active_page_str': 'page_login',
        'page_title': 'Login',
        'mimic_button_field': 'submit_button_login_submit: ..',
        'button_value': '',
        'strip_page_top': 0,
        'user_name_defval': '',
        'user_name': username,
        mask: '',
        'passwd1': ' ' * 15,
        'md5_pass': md5_pass,
        'auth_key': auth_key

        }

        self.doPost('/index.cgi', body)
        self.parseResponse()
        if self.isNextPageLogin():
            print '==Error:login failed!'
            self.setLastError('Can not login')
            return False
        return True
        return True

    #--------------------------------------------------------------------------

    #--------------------------------------------------------------------------

    def doLogout(self):
        """
        """
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

    #--------------------------------------------------------------------------
    """parse test case file
    HOST = [192.168.1.254]
    USERNAME = []
    PASSWORD = []

    METHOD PATH DATA
    [GET] [\index.cgi] []
    [POST] [\index.cgi] [key=val&key2=val2]

    """

#--------------------------------------------------------------------------


def main():
    """
    """
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




