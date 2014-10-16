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


class Runner_V33_120L_01C(RunnerBase):
    """
    """
    m_next_sleep_time = 0

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, '33.120L.01c', Sender, loglevel)
        self.info('Runner for R1KH ' + self.m_prod_ver)

    def doWaitingPage(self, req, resp, content):
        print '== uri is : ', req['uri']

        uri = req['uri']

        m_timeout = r'setTimeout\(\"do_re\w*\(\)\", (\d*)\);'

        rc_timeout = re.findall(m_timeout, content)
        sleep_time = 0
        if len(rc_timeout) > 0:
            #print content
            for index in range(len(rc_timeout)):
                tmp = int(rc_timeout[index])
                rc_timeout[index] = tmp

            rc_timeout.sort(reverse=True)
            sleep_time = float(rc_timeout[0]) / 500

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

        if uri.find('advancedsetup_lanipaddress.cgi') >= 0:
            sleep_time = 20
            print '== waiting after advancedsetup_lanipaddress.cgi :', sleep_time

            time.sleep(sleep_time)

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
        #env_f=
        output = os.path.expandvars('$G_CURRENTLOG/wan_link.log')

        #env_file = open(os.path.expandvars('$U_CUSTOM_UPDATE_ENV_FILE'), 'r')

        #        if os.path.exists(output):
        #            print 'AT_INFO : to update runtime ENV from file : %s' % (output)
        #            update_env_f = open(output, 'r')
        #
        #            lines = update_env_f.readlines()
        #            update_env_f.close()
        #
        #            m_k_v = r'(.*)=(.*)'
        #            for line in lines:
        #                rc_kv = re.findall(m_k_v, line.strip())
        #                if len(rc_kv) > 0:
        #                    k, v = rc_kv[0]
        #                    print 'AT_INFO : updating env : %s = %s' % (k, v)
        #                    os.environ.update({
        #                                       k:v
        #                                       })

        #pass
        cmdlist = []
        host = os.getenv('G_PROD_BR0_0_0', '192.168.2.1')
        port = os.getenv('U_DUT_TELNET_PORT', '23')
        username = os.getenv('U_DUT_TELNET_USER', 'admin')
        password = os.getenv('U_DUT_TELNET_PWD', 'password')
        fullpath = 'InternetGatewayDevice.Layer3Forwarding.X_ACTIONTEC_COM_DefaultConnectionFullPath'
        fullpath_v = None
        current_if = None
        current_if_v = None

        cmdlist.append('gpv ' + fullpath)

        fullpath_rc = self.cli_command(cmdlist, host, port, username, password, cli_type='telnet')
        if not fullpath_rc:
            print 'operation gpv ' + fullpath + ' error'
            return False
        else:
            gpv_fullpath_f = open('/tmp/cli_command.log', 'r')
            for line in gpv_fullpath_f:
                if line.startswith(fullpath):
                    m_fullpath = r'.*\s*=\s*(.*)'
                    rc = re.findall(m_fullpath, line.strip())
                    if len(rc) > 0:
                        fullpath_v = rc[0]
                        print 'full path value : ', fullpath_v
                        break
            gpv_fullpath_f.close()

            if not fullpath_v:
                print 'AT_ERROR : can not get <' + fullpath + '>'
                return False
            else:
                cmdlist = []
                cmdlist.append('gpv ' + fullpath_v + '.X_BROADCOM_COM_IfName')

                current_if_rc = self.cli_command(cmdlist, host, port, username, password, cli_type='telnet')
                if not current_if_rc:
                    print 'operation gpv ' + fullpath_v + '.X_BROADCOM_COM_IfName error'
                    return False
                else:
                    gpv_current_if_f = open('/tmp/cli_command.log', 'r')
                    for line in gpv_current_if_f:
                        if line.startswith(fullpath_v + '.X_BROADCOM_COM_IfName'):
                            m_current_if = r'.*\s*=\s*(.*)'
                            rc = re.findall(m_current_if, line.strip())
                            if len(rc) > 0:
                                current_if_v = rc[0]
                                print 'current interface value : ', current_if_v
                                break
                    gpv_current_if_f.close()

                    if not current_if_v:
                        print 'AT_ERROR : can not get <' + fullpath_v + '.X_BROADCOM_COM_IfName>'
                        return False
                    else:
                        os.environ.update({
                            'TMP_CUSTOM_WANINF': current_if_v,
                        })


    def login(self):
        """
        """
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')

        #if proto == 'http':
        username = os.getenv('U_DUT_HTTP_USER', 'admin')
        password = os.getenv('U_DUT_HTTP_PWD', 'admin1')
        host = os.environ.get('TMP_HTTP_HOST')
        if not host:
            host = '192.168.2.1'
            print 'TMP_HTTP_HOST not defined ! using 192.168.2.1 instead'

        uri = '/'
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
        #            var ifLogin='1';
        #            var ifPassChanged='1';
        #            var userName = 'admin';
        #            var adminPassword = 'admin1';

        m_all = r'var ifLogin=\'(\d)\';\nvar ifPassChanged=\'(\d)\';'

        rc_all = re.findall(m_all, content)
        is_login, is_PassChanged = ('0', '1')

        if len(rc_all) > 0:
            print 'rc_all : ', rc_all[0]
            is_login, is_PassChanged = rc_all[0]
            #print 'is_login : ', is_login, type(is_login)
            #print 'is_PassChanged : ', is_PassChanged, type(is_PassChanged)

        if is_login == '0':
            print '== need to login first'
            if is_PassChanged == '1':
                print '== do login'
                #    inputUserName=admin&inputPassword=admin1&nothankyou=1
                uri = '/login.cgi'

            elif is_PassChanged == '0':
                print '== do login setup'

                #    http://192.168.2.1/login_set.cgi
                #    inputUserName=admin&inputPassword=admin1&nothankyou=1
                uri = '/login_set.cgi'

            method = 'POST'

            req = {
                # combined elements
                'URL': proto + '://' + host + uri,
                'request-line': '',
                'request-body': 'inputUserName=' + username + '&inputPassword=' + password + '&nothankyou=1',
                # basic elements
                'host': host,
                'proto': 'HTTP/1.1',
                'uri': uri,
                'method': method,
            }

            resp, content = self.m_sender.sendRequest(req)

            m_err = r'msg=err'

            rc_err = re.findall(m_err, content)

            if len(rc_err) > 0:
                print '== AT_ERROR : login failed !'
                return False
                #exit(1)
            else:
                print '== login passed !'
                return True

                #exit(1)
        else:
            print '== no need to login'
            return True
            #self.logout()

        return True
        #elif proto == 'https':
        #    print 'No login !'
        #    return True
        #return True

    def logout(self):
        """
        """
        print '== logout .'
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')

        host = os.environ.get('TMP_HTTP_HOST')
        if not host:
            host = '192.168.2.1'
            print 'TMP_HTTP_HOST not defined ! using 192.168.2.1 instead'

        uri = '/logout.cgi'
        method = 'POST'

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

        #        print '=-' * 16 + '   here comes the content of logout ' + '-=' * 16
        #        #print 'here comes the content'
        #        print content
        #        print '=-' * 16 + '   so much for the content of logout ' + '-=' * 16
        return True


    def beforeReqeust(self, Reqs, idx):
        """
        """
        # 
        return True

    def afterReqeust(self, Reqs, idx):
        """
        """
        content = ''
        resp = ''
        req = Reqs[idx]
        if req.has_key('resp-headers') and req.has_key('resp-content'):
            resp = req['resp-headers']
            content = req['resp-content']
            # check next page
            #idPage = self.parseNextPage(resp, content)

        # do waiting page
        # if 'waiting'==idPage:
        self.doWaitingPage(req, resp, content)

        # var sessionKey='1881248167';
        m = r'var sessionKey\s*=\s*\'(\d*)\';'
        res = re.findall(m, content)
        if len(res):
            os.environ['TMP_SESSION_ID'] = res[0]
            print '----- TMP_SESSION_ID :', res[0]

        #
        if req['uri'].find('advancedsetup_advancedportforwarding.html') >= 0:
            #print '----------!!!'
            m = r'sessionKey=(\d*)'
            res = re.findall(m, content)
            print '------>', res
            if len(res) == 2:
                id_add = res[0]
                id_del = res[1]
                os.environ['TMP_PFO_SESSION_ID_ADD'] = id_add
                os.environ['TMP_PFO_SESSION_ID_DEL'] = id_del
        elif req['uri'].find('wirelesssetup_wirelessmacauthentication.html') >= 0:
            #sss = '<input type="hidden" name="sessionKey" value="930684844" id="uiPostsessionKey">'
            m = r'name="sessionKey"\s*value="(\d*)"'
            res = re.findall(m, content)
            if len(res):
                os.environ['TMP_SESSION_ID'] = res[0]
                print '----- TMP_SESSION_ID :', res[0]


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

    def upgradeFirmware(self, filepath, ver=None):
        """
        """

        host = os.environ.get('TMP_HTTP_HOST')
        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.2.1')
            print 'TMP_HTTP_HOST not defined ! using ', host, ' instead'

        #uri = '/upload.cgi'
        proto = 'http'
        uri = '/1spfwupgr0de.html'
        url = proto + '://' + host + uri
        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': '',
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'GET',
        }
        self.m_timeout = 120
        resp, content = self.m_sender.sendRequest(req)

        uri = '/upload.cgi'
        key = 'filename'
        fname = os.path.basename(filepath)
        val = open(filepath, 'rb').read()
        files = [(key, fname, val)]

        rc = self.m_sender.uploadFileNew(proto + '://' + host + uri, {key: open(filepath, 'rb')})
        return rc


    ######################################################


class Runner_V33_00L_28(Runner_V33_120L_01C):
    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, '33.00L.28', Sender, loglevel)
        self.info('Runner for R1KH ' + self.m_prod_ver)

    def doWaitingPage(self, req, resp, content):
        print '== uri is : ', req['uri']

        uri = req['uri']

        m_timeout = r'setTimeout\(\"do_re\w*\(\)\", (\d*)\);'

        rc_timeout = re.findall(m_timeout, content)
        sleep_time = 0
        if len(rc_timeout) > 0:
            #print content
            for index in range(len(rc_timeout)):
                tmp = int(rc_timeout[index])
                rc_timeout[index] = tmp

            rc_timeout.sort(reverse=True)
            sleep_time = float(rc_timeout[0]) / 500
            if uri.find('wirelesssetup') > -1:
                print 'sleep 15'
                time.sleep(15)
            elif uri.find('.cgi') > -1 or uri.find('.cmd') > -1 or uri.find('.wl') > -1:
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

        if uri.find('advancedsetup_lanipaddress.cgi') >= 0:
            sleep_time = 20
            print '== waiting after advancedsetup_lanipaddress.cgi :', sleep_time

            time.sleep(sleep_time)

    def login(self):
        """
        """
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')

        username = os.getenv('U_DUT_HTTP_USER', 'admin')
        password = os.getenv('U_DUT_HTTP_PWD', 'admin1')
        host = os.environ.get('TMP_HTTP_HOST')
        if not host:
            host = '192.168.2.1'
            print 'TMP_HTTP_HOST not defined ! using 192.168.2.1 instead'

        uri = '/'
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
        print '====================================='
        print resp
        print '====================================='
        print content
        print '====================================='

        m_index = r'window.top.location.href=\'index_real.html\''
        m_login = r'id=\"admin_password\"'
        m_loginSetup = r'id=\"admin_password2\"'

        rc1 = re.findall(m_login, content)
        rc2 = re.findall(m_loginSetup, content)
        rc3 = re.findall(m_index, content)

        if len(rc1) == 0 and len(rc2) == 0 and len(rc3) > 0:
            print '########### no need login'
            return True

        elif len(rc1) > 0 and len(rc2) == 0:

            print '########### do login'
            #inputUserName=admin&inputPassword=admin1&nothankyou=1
            uri = '/login.cgi'
            method = 'POST'
            req = {
                # combined elements
                'URL': proto + '://' + host + uri,
                'request-line': '',
                'request-body': 'inputUserName=' + username + '&inputPassword=' + password + '&nothankyou=1',
                # basic elements
                'host': host,
                'proto': 'HTTP/1.1',
                'uri': uri,
                'method': method,
            }
            resp, content = self.m_sender.sendRequest(req)

            m_err = r'msg=err'
            print '----------------------------------------------------'
            print resp
            print content
            print '----------------------------------------------------'
            rc_err = re.findall(m_err, content)

            if len(rc_err) > 0:
                print '== AT_ERROR : login FAILED !'
                return False
            else:
                print '== AT_INFO : login PASSED !'
                return True

        elif len(rc1) > 0 and len(rc2) > 0:

            print '########### do login Setup'
            uri = '/login_set.cgi'
            method = 'POST'
            req = {
                # combined elements
                'URL': proto + '://' + host + uri,
                'request-line': '',
                'request-body': 'adminUserName=' + username + '&adminPassword=' + password + '&admin_password2=' + password + '&nothankyou=1',
                # basic elements
                'host': host,
                'proto': 'HTTP/1.1',
                'uri': uri,
                'method': method,
            }

            resp, content = self.m_sender.sendRequest(req)

            m_err = r'msg=err'

            rc_err = re.findall(m_err, content)

            if len(rc_err) > 0:
                print '== AT_ERROR : login FAILED !'
                return False
            else:
                print '== AT_INFO : login PASSED !'
                return True
        else:
            print '########## AT_ERROR : Get ' + host + ' FAILED !'
            return False


hash_runners = {
    '33.120L.01c': Runner_V33_120L_01C,
    '33.00L.28': Runner_V33_00L_28,
}

def_runner = '33.120L.01c'


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
    
    
    



