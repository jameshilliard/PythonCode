#!/usr/bin/python
"""
Automation Test Engine Base Class

Automation Test General Flow:

                    LoadTestCase()
                        |
                        |
                        |
                    ?isNeedLogin() ------N-----------> jump to doTestCase()
                        |
                        |Y
                        |
                    doLogin()
                        |
                        |
                        |
                    ?isNextPageSpecial()------>jump to END
                        |
                        |N
                        |
                    doTestCase()
                        |
                        |
                        |
                    ?isNextPageSpecial() ---->  jump to handleTestCaseResponse()
                        |
                        |N
                        |
                    ?isNeedLogout()----> jump to END
                        |
                        |Y
                        |
                    doLogout()
                        |
                        |
                        |
                       END

"""

__author__ = "Rayofox"
__version__ = "Revision: 0.2 "
__date__ = "Date: 2011-08-11"
__copyright__ = "Copyright (c) 2011 Rayofox"
__license__ = "Python"

import os
import sys
import re
import hashlib
import time
import httplib2, urllib, urllib2, urlparse
import imp
import types
from pprint import pprint
from pprint import pformat
import traceback


class Filter(object):
    inc_rules = []
    exc_rules = []

    def __init__(self, includeOr=[], excludeAnd=[]):
        self.inc_rules.extend(includeOr)
        self.exc_rules.extend(excludeAnd)
        return

    def addIncludeOr(self, rex):
        self.inc_rules.append(rex)
        return

    def addExcludeAnd(self, rex):
        self.exc_rules.append(rex)
        return

    def filterIncludeOr(self, dest):
        #
        rc = True
        for rex in self.inc_rules:
            #print 'rex',rex
            #print 'dest',dest
            rc = False
            res = re.search(rex, dest)
            if res:
                rc = True
                break

        return rc

    def filterExcludeAnd(self, dest):
        #
        rc = True
        for rex in self.exc_rules:
            res = re.search(rex, dest)
            if res:
                rc = False
                break
        return rc

    def doFilter(self, dest):
        rc = False
        rc = self.filterIncludeOr(dest)
        if not rc:
            #print ''
            return rc
        rc = self.filterExcludeAnd(dest)
        if not rc:
            return rc
        return rc


class tcEngine(object):
    """
    Engine for run testcase in different DUT
    """
    resultPass = False
    last_error = ''
    #test case file
    tc_file = ''
    tc = None
    total_step = 1
    current_step = 0
    #http
    http = ''
    headers = {'Content-type': 'application/x-www-form-urlencoded'}
    response = ''
    content = ''
    #next page info
    next_page = {
        'type': 'unknown', #login,warining,notice,error,wating,others
        'id': 0,
        'title': ''
    }
    #runner info
    info = {
        'login': True,
        'logout': True,
        'name': 'Noname',
        'host': '192.168.1.1',
        'username': 'admin',
        'password': 'admin1',
        'debug': False,
        'no_exception': True,
        'logdir': None,
    }

    #test case config data
    cfg = {
        'description': 'no description',
        'protocol': 'HTTP',
        'destination': '',
        'method': '',
        'path': '',
        'body_len': 0,
        'query': '',
        'body': ''
    }
    cfgs = []
    special_type = ['login', 'warning', 'notice', 'error', 'waiting']

    # Filter
    filters = {
        'method': None,
        'url': None,
        'body': None
    }
    #
    result = {
        'totoal_req': 0,
        'succ_req': 0,
        'filter_req': 0
    }
    # Application Environment Variables
    AEV = {}
    # replacement
    URL_REPL = None

    def __init__(self, debug=False):
        print '==tcEngine '
        self.info['debug'] = debug
        self.filters['method'] = Filter()
        self.filters['url'] = Filter()
        # load application envrioment variables
        self.loadAEV()
        print '==Current Product Type: ', self.AEV.get('U_DUT_TYPE', 'None')
        print '==Current Firmware Version: ', self.AEV.get('U_DUT_FW_VERSION', 'None')

        self.loadRepl()
        return

    def setDebug(self, debug=True):
        self.info['debug'] = debug

    #-------------------------------------------------------------------------------
    def loadRepl(self):
        from url_repl.url_replace import UrlReplacer
        from url_repl.wi_sec_repl import wi_sec_match
        from url_repl.wi_sec_repl import wi_sec_cbReplace
        #
        UR = UrlReplacer()
        # add special replace rule
        UR.addRule(wi_sec_match, wi_sec_cbReplace)
        # load common replacement
        ek = 'U_PATH_COMMON_URL_REPL'
        ev = os.getenv(ek)
        if ev:
            cfgfiles = ev.split(';')
            for cfgfile in cfgfiles:
                if os.path.exists(cfgfile) and os.path.isfile(cfgfile):
                    print '==', 'import common replace data from file :', cfgfile
                    UR.importKV(cfgfile)
                    self.URL_REPL = UR
                else:
                    print '==', 'can not found file :', cfgfile
        if not self.URL_REPL:
            print '==', 'url replacer is not ready'
        else:
            print '==', 'url replacer ready'
        return True

    def loadAEV(self):

        for (k, v) in os.environ.items():
            if not k.find('G_'):
                self.AEV[k] = v
            if not k.find('U_'):
                self.AEV[k] = v

        #-------------------------------------------------------------------------------
    def addFilter(self, name, filter):
        if name and filter:
            self.filters[name] = filter
        return

    def includeMethod(self, method):
        filter = self.filters['method']
        if not filter:
            filter = Filter()
            self.filters['method'] = filter
        filter.addIncludeOr(method)
        return

    def excludeMethod(self, method):
        filter = self.filters['method']
        if not filter:
            filter = Filter()
            self.filters['method'] = filter
        filter.addExcludeAnd(method)
        return

    def includePostContent(self, rule):
        filter = self.filters['body']
        if not filter:
            filter = Filter()
            self.filters['body'] = filter
        filter.addIncludeAnd(rule)
        return

    def excludePostContent(self, rule):
        filter = self.filters['body']
        if not filter:
            filter = Filter()
            self.filters['body'] = filter
        filter.addExcludeAnd(rule)
        return

    def includeURL(self, rule):
        filter = self.filters['url']
        if not filter:
            filter = Filter()
            self.filters['url'] = filter
        filter.addIncludeAnd(rule)
        return

    def excludeURL(self, rule):
        filter = self.filters['url']
        if not filter:
            filter = Filter()
            self.filters['url'] = filter
        filter.addExcludeAnd(rule)
        return

        #-------------------------------------------------------------------------------
    def p_hist(self, name, h):
        print name + ' = {'
        for key in sorted(h.keys()):
            print '\'%s\' : \'%s\',' % (key, h[key])
        print '}'

    def debugResponse(self):
        print 'resp', self.response
        #print 'content',self.content[0:300]
        print 'content', self.content

    def saveRespContent(self, path):
        if not self.info['logdir']:
            print '==', 'no log directory '
            return False
        if not self.content:
            print '==', 'content is None'
            return False
        if len(self.content) == 0:
            print '==', 'content is empty'
            return False

        # parse the content save file name
        fn = self.info['logdir'] + path

        d = os.path.dirname(fn)
        fname = os.path.basename(fn)
        if not os.path.exists(d):
            os.makedirs(d)

        if os.path.exists(fn):
            fn = fn + '_step_' + str(self.current_step)
        print '==', 'save response content file ', fn
        f = file(fn, 'w')
        f.write(self.content)
        f.close()
        return True
        #print 'content',self.content[0:300]
        #print 'content',self.content

    #-------------------------------------------------------------------------------

    """
    val = 0, '' ,None,False are all mean Nil
    """

    def isNil(self, val):
        t = type(val)
        if t is types.StringType:
            return 0 == len(val)
        elif t is types.BooleanType:
            return False == val
        elif t is types.IntType:
            return 0 == val
        elif t is types.NoneType:
            return True
        else:
            return False

    def isDebug(self):
        return not self.isNil(self.info['debug'])

    def setLastError(self, err):
        self.last_error = 'Step ' + str(self.current_step) + ' : '
        self.last_error += str(err)

        #-------------------------------------------------------------------------------
    def saveCookie(self):
        #save Cookie
        if self.response.has_key('set-cookie'):
            self.headers['Cookie'] = self.response['set-cookie']

    def doGet(self, path='/', query=None, dest=None, proto='HTTP'):
        try:
            if self.cfg['protocol']: proto = self.cfg['protocol']
            t = type(query)
            if t is types.DictionaryType:
                query = urllib.urlencode(query)
                #url = self.info['host'] + path
            #url = self.cfg['destination'] + path
            url = ''
            if not dest: dest = self.cfg['destination']
            if dest:
                url = proto + '://' + dest + path
            if not self.isNil(query):
                url += ('?' + query)
            if self.isDebug():
                print 'url = ', url

            self.response, self.content = self.http.request(url, 'GET', headers=self.headers)
            self.saveRespContent(path);
            if self.isDebug():
                self.debugResponse()

            return True
        except Exception, e:
            print '==!!Exception:', e
            #print '\n-| FAIL: ',e
            traceback.print_exc()
            if self.info.has_key('no_exception'):
                if self.info['no_exception']:
                    print '==Ignore exception'
                    return True
                else:
                    print '==Handle exception'
                    return False
            return False

    def doPost(self, path, body, dest=None, proto='HTTP'):
        if self.cfg['protocol']: proto = self.cfg['protocol']
        try:
            t = type(body)
            if t is types.DictionaryType:
                body = urllib.urlencode(body)
                #url = self.info['host'] + path
            #url = self.cfg['destination'] + path
            url = ''
            if not dest: dest = self.cfg['destination']
            if dest:
                url = proto + '://' + dest + path
            if self.isDebug():
                print 'url = ', url
                print 'body = ', body

            self.response, self.content = self.http.request(url, 'POST', headers=self.headers, body=body)
            if self.isDebug():
                self.debugResponse()

            return True
        except Exception, e:
            print '==!Exception:', e
            #print '\n-| FAIL: ',e
            traceback.print_exc()
            if self.info.has_key('no_exception'):
                if self.info['no_exception']:
                    print '==Ignore exception'
                    return True
                else:
                    print '==Handle exception'
                    return False
            return False


    def isNextPageLogin(self):
        return 'login' == self.next_page['type']

    def isNextPageWarning(self):
        return 'warning' == self.next_page['type']

    def isNextPageNotice(self):
        return 'notice' == self.next_page['type']

    def isNextPageError(self):
        return 'error' == self.next_page['type']

    def isNextPageWaiting(self):
        return 'waiting' == self.next_page['type']

    def isNextPageSpecial(self):
        type = self.next_page['type']
        if type in self.special_type:
            return True
        else:
            return False

    def isResultPass(self):
        return self.resultPass

        #-------------------------------------------------------------------------------
    """
        do replacement before send request
    """

    def replBeforeRequest(self):
        urepl = self.URL_REPL
        if not urepl: return False
        #
        method = self.cfg['method']
        key = None
        if 'POST' == method:
            key = 'body'
        elif 'GET' == method:
            key = 'query'
            #
        if key:
            raw = self.cfg[key]
            res = urepl.replace(raw)
            if res != raw:
                self.cfg[key] = res
                print '== raw :\n', '\n'.join(raw.split('&'))
                print '== res :\n', '\n'.join(res.split('&'))
                return True
        return False

        #-------------------------------------------------------------------------------
    """
    Function MUST to implement Yourself
    """

    def parseResponse(self):
        print "TODO:Need Implement Yourself"
        status = self.response['status']
        if '401' == status:
            print '==Unauthorized'
        return False

    """
    Login
    """

    def doLogin(self):
        #connect and get login page
        print 'TODO:LOGIN'
        #self.doGet()
        #self.parseResponse()
        #if not self.isNextPageLogin():
        #    print '==Next page is not Login'
        #    return False
        #do login
        #print 'do login '
        self.setLastError('Not implement doLogin')
        return False

    def doLogout(self):
        print 'TODO:LOGOUT'
        return False

        #-------------------------------------------------------------------------------
    """
    Implement Your own response handle
    """

    def handleTestCaseResponse(self):
        print 'TODO:Handle Test Case Response here'
        #print '==Next page is :' ,self.next_page['type']
        if not self.isNextPageSpecial():
            #print 'Next page is not a special page'
            self.wait4cfg(1)
            return True
        else:
            print 'Next page is  a special page'
            return False
            #if self.isNextPageWarning():
        #    print 'Next page is  a special page'
        #    return False


        return True

        #-------------------------------------------------------------------------------
    def getLastError(self):
        return self.last_error

    def wait4cfg(self, sec_):
        #need wait for a while
        #print 'waiting 5 sec for setting...'
        time.sleep(sec_)

    def isNeedLogin(self):
        if not self.isNil(self.info['login']): return True
        return False

    def isNeedLogout(self):
        if not self.isNil(self.info['logout']): return True
        return False

    def loadTestCaseFile(self, tc_file):
        self.tc_file = tc_file
        #tc_file = self.tc_file
        self.tc = self.impTestCase(tc_file)
        self.current_step = 0
        #print 'tc_cfgs = ',self.tc.cfgs
        self.loadTestCaseInfo(info=self.tc.info, cfgs=self.tc.cfgs)

    def loadTestCaseInfo(self, info={}, cfgs=[]):
        self.info.update(info)
        self.cfgs = cfgs
        self.result['total_req'] = len(cfgs)
        if self.isDebug():
            self.p_hist('tc_info', self.info)
            print 'tc_cfgs = %s' % pformat(self.cfgs)
        return True

    def loadTestCase(self):
        if self.current_step < len(self.cfgs):
            self.cfg = self.cfgs[self.current_step]
            self.current_step += 1
            if self.isDebug(): self.p_hist('cfg', self.cfg)
            return True
        else:
            #print ':'
            return False

    #-------------------------------------------------------------------------------
    def impTestCase(self, fn_):
        tc = imp.load_source("test_case", fn_)
        return tc

    def doTestCase(self):
        print '==Do Test case :', self.info['name']
        #
        while self.loadTestCase():
            print '\n==Current Step : ', self.current_step
            print '==Begin Time :', time.asctime()
            t = time.time()
            if self.cfg.has_key('description'):
                print '==', self.cfg['description']
                # Method
            method = self.cfg['method']
            filter = self.filters['method']
            if filter:
                rc = filter.doFilter(method)
                if not rc:
                    print '==Filtered with method'
                    self.result['filter_req'] += 1
                    continue
                #Url
            url = self.info['host'] + self.cfg['path']
            if self.cfg.has_key('destination') and self.cfg.has_key('protocol'):
                #print '@@@'
                url = self.cfg['protocol'] + '://' + self.cfg['destination']
                #print '###'
            if 'GET' == method:
                url += '?'
                url += self.cfg['query']
            filter = self.filters['url']
            if filter:
                rc = filter.doFilter(url)
                if not rc:
                    print '==Filtered with url'
                    self.result['filter_req'] += 1
                    continue
                #POST Content
            filter = self.filters['body']
            if filter and ('POST' == method):
                body = self.cfg['body']
                rc = filter.doFilter(body)
                if not rc:
                    print '==Filtered with POST content'
                    self.result['filter_req'] += 1
                    continue
            dest = None
            if self.cfg.has_key('destination'):
                dest = self.cfg['destination']

            self.replBeforeRequest()
            if 'POST' == method:
                print '==', self.cfg['body']
                rc = self.doPost(self.cfg['path'], self.cfg['body'], dest=dest)
            elif 'GET' == method:
                rc = self.doGet(self.cfg['path'], self.cfg['query'], dest=dest)
            else:
                print '==Error: Unknown method'
                return False
            if rc:
                #check the next page
                rc = self.parseResponse()
                rc = self.handleTestCaseResponse()
                self.content = None
            print '==End Time :', time.asctime()
            print '==Span Time :', time.time() - t
            if not rc:
                print "==Error: Step ", self.current_step
                return False
            self.result['succ_req'] += 1
        print '==All Pass'
        return True

    #-------------------------------------------------------------------------------
    def run(self):
        #prepare http
        rc = False
        self.http = httplib2.Http(timeout=120)#(timeout=15)
        #run cases
        while 1:
            # do login
            if self.isNeedLogin():
                rc = self.doLogin()
                if not rc:
                    print '==Login failed ,exit '
                    break
            else:
                print '==Login Ignore'
                #do case
            rc = self.doTestCase();
            if not rc:
                #if self.isDebug():
                #self.debugResponse()
                break
                #do logout
            if self.isNeedLogout():
                rc &= self.doLogout()
                #if not rc : break
            else:
                print '==Logout Ignore'

            #done
            break
            #
        #print '==Result : ',rc
        if rc: self.resultPass = True
        #else : self.result = ''
        print '\n' * 2
        print '==Total Request   : ', self.result['total_req']
        print '==Filter Request  : ', self.result['filter_req']
        print '==Success Request : ', self.result['succ_req']
        print '\n' * 2
        return rc
        #-------------------------------------------------------------------------------


def main():
    argc = len(sys.argv)
    if argc < 2:
        print 'Usage : ', sys.argv[0], ' test_case_file'
        return False

    ###
    tc_file = sys.argv[1]
    runner = tcEngine(debug=True)
    # load case info
    rc = runner.loadTestCaseFile(tc_file)

    rc = runner.run();
    if not runner.isResultPass():
        print '\n-| FAIL: ', runner.getLastError()
    else:
        print '\n-| PASS '

    return True


def testFilter():
    filter = Filter(includeOr=['POST'])
    rc = filter.doFilter('POST index.cgi?a=b&c=1 HTTP/1.1')
    print 'rc', rc


if __name__ == "__main__":
    #main()
    testFilter()
    """
    try:
        main()
    except Exception,e :
        print '\n-| FAIL: ',e
    """

