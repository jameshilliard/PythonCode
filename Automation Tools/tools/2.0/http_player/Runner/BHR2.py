#!/usr/bin/env python -u
"""
VAutomation Test Engine Class
"""

__author__ = "Rayofox"
__version__ = "$Revision: 0.1 $"
__date__ = "$Date: $"
__copyright__ = "Copyright (c) 2011 Rayofox"
__license__ = "Python"

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
from RunnerBase import RunnerBase


class Runner_v20_19_0(RunnerBase):
    """
    """

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, '20.19.0', Sender, loglevel)
        self.info('Runner for BHR2 ' + self.m_prod_ver)


    def parseNextPage(self, resp, content):
        """
         Page(9074)=[Login]
        """
        typePage = ''
        location = ''
        next_page = self.m_next_page
        next_page['id'] = ''
        next_page['title'] = ''
        #
        if resp.has_key('location'):
            location = resp['location']
            #print 'location = ',location
        location = urllib.unquote(location)
        match = r'active_page=(\w*)'
        match1 = r'Page\(9099\)'
        match2 = r'Page\(9100\)'
        rr = re.findall(match, location)
        if len(rr) > 0:
            next_page['id'] = rr[0]
        else:
            rr1 = re.findall(match1, content)
            if len(rr1) > 0:
                next_page['id'] = '9099'

            rr2 = re.findall(match2, content)
            if len(rr2) > 0:
                next_page['id'] = '9100'

        match = r'active_page_str=(\w*)'
        rr = re.findall(match, location)
        if len(rr) > 0:
            next_page['title'] = rr[0]
        w = r'has_warnings=(\w*)'
        e = r'has_errors=(\w*)'

        rr = re.findall(w, location)
        if len(rr) > 0:
            if int(rr[0]) > 0:
                typePage = 'warning'
        rr = re.findall(e, location)
        if len(rr) > 0:
            if int(rr[0]) > 0:
                typePage = 'error'
            #parse content
        match = r'Page\(\d+\)=\[Login\]'
        rr = re.findall(match, content)
        if len(rr) > 0:
            typePage = 'login'
            #
        page_id = next_page['id']
        if '9074' == page_id:
            typePage = 'login'
        elif '9130' == page_id:
            typePage = 'main'
        elif '9131' == page_id:
            typePage = 'main'
        elif '9132' == page_id:
            typePage = 'main'
        elif '9099' == page_id:
            typePage = 'loginSetup'
        elif '9100' == page_id:
            typePage = 'login_Setup'
        elif '9001' == page_id:
            typePage = 'warning'
        elif '6014' == page_id:
            typePage = 'waiting'

        #
        # 'id': '9144', 'title': 'page_conn_settings_ppp0'

        next_page['type'] = typePage
        print '==', 'next_page = ', pformat(next_page)
        return typePage


    def pageToSleep(self):
        """
        """
        page_to_sleep = {
            '9144': 0,
            '9001': 0,
            '6014': 0,
            '9122': 0,
        }

        pgid = self.m_next_page['id']

        tw = 0
        if page_to_sleep.has_key(pgid):
            tw = page_to_sleep[pgid]

        self.doWaitingPage(tw)


    def login(self):
        """
        """
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.1 instead'

        uri = '/'
        url = proto + '://' + host + uri

        self.info('==CONNECT HTTP SERVER')
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

        username = self.m_hashENV.get('U_DUT_HTTP_USER', 'admin')
        password = self.m_hashENV.get('U_DUT_HTTP_PWD', 'admin1')

        Sender = self.m_sender
        resp, content = Sender.sendRequest(req)

        m_rg_cookie_session_id = r'rg_cookie_session_id=(\d*)'

        rc_rg_cookie_session_id = re.findall(m_rg_cookie_session_id, resp['set-cookie'])
        #print resp['set-cookie']

        if len(rc_rg_cookie_session_id) > 0:
            tmp_session_id = rc_rg_cookie_session_id[0]
            print '== change session id to : ', tmp_session_id
            os.environ['TMP_SESSION_ID'] = tmp_session_id

        # check next page is login page
        idPage = self.parseNextPage(resp, content)

        print 'next page is :', idPage

        if idPage != 'login' and idPage != 'loginSetup' and idPage != 'login_Setup':
            self.error('Get login page failed')
            return False

        if idPage == 'login':
            #do login
            self.info('Login')

            #parse AuthKey
            mask, auth_key = self.parseAuthKey(content)
            #print "==|",mask,auth_key

            #makeMd5Pass
            md5_pass = self.makeMd5Pass(password, auth_key)

            print '\n' * 3
            print '==mask :', mask
            #mask : passwordmask_1558103393
            print '==md5_pass :', md5_pass
            print '==auth_key :', auth_key

            print '\n' * 3
            # combine post body
            body = {
                'active_page': 9075,
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
            req_body = urllib.urlencode(body)

            uri = '/index.cgi'
            url = proto + '://' + host + uri

            req = {
                # combined elements
                'URL': url,
                'request-line': 'POST /index.cgi HTTP/1.1',
                'request-body': req_body,
                # basic elements
                'host': host,
                'proto': 'HTTP/1.1',
                'uri': uri,
                'method': 'POST',
            }
            # login with username and password
            resp, content = Sender.sendRequest(req)

            # check next page is main page
            idPage = self.parseNextPage(resp, content)

            print 'next page is :', idPage
            if idPage != 'main':
                print '== Get main page after login failed'
                print(resp)
                #           #print(content)
                return False
            elif idPage == 'main':
                print '== Get main page after login passed'
                print(resp)

                return True
                #
                #return True
        elif idPage == 'loginSetup':
            print 'loginSetup page after restore default'
            #username = self.m_hashENV.get('U_DUT_HTTP_USER', 'admin')
            #password = self.m_hashENV.get('U_DUT_HTTP_PWD', 'admin1')

            mask = ""
            match = r"name=\"(password_\d+)"
            r = re.search(match, content)
            #print r
            if r:
                gp = r.groups()
                mask = gp[0]
            print 'mask is :', mask

            post_body = "active_page=9099&active_page_str=page_login_setup&page_title=Login+Setup&"
            post_body += "mimic_button_field=submit_button_login_submit%3A+..&button_value=&strip_page_top=0&"
            post_body += "username_defval=" + username + "&username=" + username + "&"
            post_body += (mask + "=" + password + "&rt_" + mask + "=" + password + "&")
            post_body += "time_zone=Eastern_Time&time_zone_defval=Eastern_Time"

            #req_body = urllib.urlencode(body)
            req_body = post_body
            req = {
                # combined elements
                'URL': 'http://' + host + '/index.cgi',
                'request-line': 'POST /index.cgi HTTP/1.1',
                'request-body': req_body,
                # basic elements
                'host': host,
                'proto': 'HTTP/1.1',
                'uri': '/index.cgi',
                'method': 'POST',
            }

            pprint(req)
            # login with username and password
            resp, content = Sender.sendRequest(req)
            return True

        elif idPage == 'login_Setup':
            print 'login_Setup page after restore default'
            #username = self.m_hashENV.get('U_DUT_HTTP_USER', 'admin')
            #password = self.m_hashENV.get('U_DUT_HTTP_PWD', 'admin1')

            mask = ""
            match = r"name=\"(password_\d+)"
            r = re.search(match, content)
            #print r
            if r:
                gp = r.groups()
                mask = gp[0]
            print 'mask is :', mask

            # active_page=9100&active_page_str=page_login_setup&page_title=Login+Setup&
            # mimic_button_field=submit_button_login_submit%3A+..&button_value=6027&strip_page_top=0&
            # username_defval=admin&username=admin&
            # password_228395487=admin1&rt_password_228395487=admin1&
            # time_zone=Eastern_Time&time_zone_defval=Eastern_Time

            post_body = "active_page=9100&active_page_str=page_login_setup&page_title=Login+Setup&"
            post_body += "mimic_button_field=submit_button_login_submit%3A+..&button_value=6027&strip_page_top=0&"
            post_body += "username_defval=" + username + "&username=" + username + "&"
            post_body += (mask + "=" + password + "&rt_" + mask + "=" + password + "&")
            post_body += "time_zone=Eastern_Time&time_zone_defval=Eastern_Time"

            #req_body = urllib.urlencode(body)
            req_body = post_body
            req = {
                # combined elements
                'URL': 'http://' + host + '/index.cgi',
                'request-line': 'POST /index.cgi HTTP/1.1',
                'request-body': req_body,
                # basic elements
                'host': host,
                'proto': 'HTTP/1.1',
                'uri': '/index.cgi',
                'method': 'POST',
            }

            pprint(req)
            # login with username and password
            resp, content = Sender.sendRequest(req)

            idPage = self.parseNextPage(resp, content)

            print 'next page is :', idPage
            if idPage != 'main':
                print '== Get main page after login_Setup failed'
                print(resp)
                #           #print(content)
                return False
            elif idPage == 'main':
                print '== Get main page after login_Setup passed'
                print(resp)

                return True
                #exit(1)

    def logout(self):
        """
        """
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.1 instead'

        uri = '/index.cgi'
        url = proto + '://' + host + uri
        body = {
            'active_page': '9131',
            'active_page_str': 'page_home_act_vz',
            'page_title': 'Main',
            'mimic_button_field': 'logout: ...',
            'button_value': '.',
            'strip_page_top': '0'

        }
        req_body = urllib.urlencode(body)
        req = {
            # combined elements
            'URL': url,
            'request-line': 'POST / HTTP/1.1',
            'request-body': req_body,
            # basic elements
            'host': host,
            'proto': 'HTTP/1.1',
            'uri': uri,
            'method': 'POST',
        }
        Sender = self.m_sender
        # login with username and password
        #resp, content = Sender.sendRequest(req)

        try:
            #Sender = self.m_sender
            Sender.sendRequest(req)
        except Exception, e:
            self.warning('Exception : ' + str(e))
            return True

        return True


    def beforeReqeust(self, Reqs, idx):
        """
        """
        # in HTTP/0.9 URL '_' must be replaced with '%5f'
        # replace _ with %5f 
        req = Reqs[idx]
        URL = req['URL']

        m = r'_'
        req['URL'] = re.sub(m, '%5f', URL)

        return True

    def afterReqeust(self, Reqs, idx):
        """
        """
        #print '== | in function afterReqeust : ',idx
        req = Reqs[idx]
        if req.has_key('resp-headers') and req.has_key('resp-content'):

            resp = req['resp-headers']
            content = req['resp-content']

            #        print '================================='
            #        print '\n'
            #        pprint(resp)
            #        print '\n'
            #        print '================================='

            #resp={}

            if resp.has_key('location'):
                loc = resp['location']

                print 'location :', loc
                #'location': '/index.cgi?active%5fpage=1220&active%5fpage%5fstr=page%5fdiagnostics&req%5fmode=1&mimic%5fbutton%5ffield=submit%5fbutton%5fping%5ftest%5fgo%3a+%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=1220'
                m_ping_sleep = r'submit\%5fbutton\%5fping\%5ftest\%5fgo'

                rc_ping = re.findall(m_ping_sleep, loc)

                if len(rc_ping) > 0:
                    print '== sleep 10 secs for ping test'
                    time.sleep(10)

            m_waiting = r'PutEvent\((\d*)\);'
            rc = re.findall(m_waiting, content)
            #rrcc=['11','321','1']
            if len(rc) > 0:
                for index in range(len(rc)):
                    tmp = int(rc[index])
                    rc[index] = tmp

                rc.sort(reverse=True)
                sleep_time = float(rc[0]) / 1000
                print '== | sleep ', sleep_time, 'sec according to PutEvent() function'
                time.sleep(sleep_time)

            idPage = self.parseNextPage(resp, content)
            self.pageToSleep()
        return True

    def doWaitingPage(self, tw):
        """
        """
        print '==Waiting page ', str(tw), 'seconds'
        time.sleep(tw)

    ######################################################
    def parseAuthKey(self, content):
        """
        """
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

    #-----------------------------------------------------------------------
    def upgradeFirmware(self, filepath, ver=None):
        """
        """
        print '+++' * 32
        host = os.environ.get('TMP_HTTP_HOST')
        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.0.1 instead'
        proto = 'http'
        uri = '/index.cgi'
        url = proto + '://' + host + uri

        req_1 = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': 'active_page=9132&active_page_str=page_home_act_vz&page_title=Main&mimic_button_field=sidebar%3A+actiontec_topbar_adv_setup..&button_value=.&strip_page_top=0',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_1)
        proto = 'http'
        uri = '/index.cgi'
        url = proto + '://' + host + uri
        req_2 = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': 'active_page=730&active_page_str=page_advanced&page_title=Advanced&mimic_button_field=submit_button_yes%3A+..&button_value=actiontec_topbar_adv_setup&strip_page_top=0',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_2)
        proto = 'http'
        uri = '/index.cgi'
        url = proto + '://' + host + uri
        req_3 = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': 'active_page=730&active_page_str=page_advanced&page_title=Advanced&mimic_button_field=goto%3A+741..&button_value=actiontec_topbar_adv_setup&strip_page_top=0',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_3)
        proto = 'http'
        uri = '/index.cgi'
        url = proto + '://' + host + uri
        req_4 = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': 'active_page=741&active_page_str=page_wan_upgrade&page_title=+Firmware+Upgrade&mimic_button_field=submit_button_man_upgrade%3A+..&button_value=741&strip_page_top=0&wan_upgrade_type=3&wan_upgrade_type_defval=3&check_url_defval=https%3A%2F%2Fupgrade.actiontec.com%2FMI424WR2%2FMI424WR_EF.rmt&check_url=https%3A%2F%2Fupgrade.actiontec.com%2FMI424WR2%2FMI424WR_EF.rmt',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_4)

        uri = '/upgrade.cgi'
        fields = {
            'active_page': '747',
            'page_title': 'Upgrade From a Computer in the Network',
            'mimic_button_field': 'submit_button_upgrade_now: ..',
            'button_value': '741',
            'strip_page_top': '0',
            'image': open(filepath, 'rb'),
        }
        rc = self.m_sender.uploadFileNew(proto + '://' + host + uri, fields=fields)
        print '-->', 'upload File Done!'

        proto = 'http'
        uri = '/index.cgi?active%5fpage=743&req%5fmode=0&mimic%5fbutton%5ffield=submit%5fbutton%5fupgrade%5fnow%3a+%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=741'
        url = proto + '://' + host + uri
        req_1 = {
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
        resp, content = self.m_sender.sendRequest(req_1)

        proto = 'http'
        uri = '/index.cgi'
        url = proto + '://' + host + uri
        req_1 = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': 'active_page=743&page_title=+Firmware+Upgrade&mimic_button_field=submit_button_submit%3A+..&button_value=741&strip_page_top=0',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_1)
        return rc


################################################################################################################################

class Runner_v20_9_0(Runner_v20_19_0):
    """
    9097 loginSetup
    9128 main
    9072 login
    730 logout
    """

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, '20.9.0', Sender, loglevel)
        self.info('Runner for BHR2 ' + self.m_prod_ver)


    def parseNextPage(self, resp, content):
        """
         Page(9072)=[Login]
         Page(9128)=[main]
         Page(9097)=[loginSetup]
         Page(730)=[logout]
        """
        typePage = ''
        location = ''
        next_page = self.m_next_page
        next_page['id'] = ''
        next_page['title'] = ''
        #
        if resp.has_key('location'):
            location = resp['location']
            #print 'location = ',location
        location = urllib.unquote(location)
        match = r'active_page=(\w*)'
        match1 = r'Page\(9097\)'
        match2 = r'Page\(9100\)'
        rr = re.findall(match, location)
        if len(rr) > 0:
            next_page['id'] = rr[0]
        else:
            rr1 = re.findall(match1, content)
            if len(rr1) > 0:
                next_page['id'] = '9097'

            rr2 = re.findall(match2, content)
            if len(rr2) > 0:
                next_page['id'] = '9100'

        match = r'active_page_str=(\w*)'
        rr = re.findall(match, location)
        if len(rr) > 0:
            next_page['title'] = rr[0]
        w = r'has_warnings=(\w*)'
        e = r'has_errors=(\w*)'

        rr = re.findall(w, location)
        if len(rr) > 0:
            if int(rr[0]) > 0:
                typePage = 'warning'
        rr = re.findall(e, location)
        if len(rr) > 0:
            if int(rr[0]) > 0:
                typePage = 'error'
            #parse content
        match = r'Page\(\d+\)=\[Login\]'
        rr = re.findall(match, content)
        if len(rr) > 0:
            typePage = 'login'
            #
        page_id = next_page['id']
        if '9072' == page_id:
            typePage = 'login'
        elif '9128' == page_id:
            typePage = 'main'
        elif '9097' == page_id:
            typePage = 'loginSetup'
        elif '9001' == page_id:
            typePage = 'warning'
        elif '6014' == page_id:
            typePage = 'waiting'

        #
        # 'id': '9144', 'title': 'page_conn_settings_ppp0'

        next_page['type'] = typePage
        print '==', 'next_page = ', pformat(next_page)
        return typePage

    def login(self):
        """
        """
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.1 instead'

        uri = '/'
        url = proto + '://' + host + uri

        self.info('==CONNECT HTTP SERVER')
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

        username = self.m_hashENV.get('U_DUT_HTTP_USER', 'admin')
        password = self.m_hashENV.get('U_DUT_HTTP_PWD', 'admin1')

        Sender = self.m_sender
        resp, content = Sender.sendRequest(req)
        print resp
        print content
        m_rg_cookie_session_id = r'rg_cookie_session_id=(\d*)'

        rc_rg_cookie_session_id = re.findall(m_rg_cookie_session_id, resp['set-cookie'])
        #print resp['set-cookie']

        if len(rc_rg_cookie_session_id) > 0:
            tmp_session_id = rc_rg_cookie_session_id[0]
            print '== change session id to : ', tmp_session_id
            os.environ['TMP_SESSION_ID'] = tmp_session_id

        # check next page is login page
        idPage = self.parseNextPage(resp, content)

        print 'next page is :', idPage

        if idPage != 'login' and idPage != 'loginSetup':
            self.error('Get login page failed')
            return False

        if idPage == 'login':
            #do login
            self.info('Login')

            #parse AuthKey
            mask, auth_key = self.parseAuthKey(content)
            #print "==|",mask,auth_key

            #makeMd5Pass
            md5_pass = self.makeMd5Pass(password, auth_key)

            print '\n' * 3
            print '==mask :', mask
            #mask : passwordmask_1558103393
            print '==md5_pass :', md5_pass
            print '==auth_key :', auth_key

            print '\n' * 3
            # combine post body
            body = {
                'active_page': 9072,
                'active_page_str': 'page_login',
                'page_title': 'Login',
                'mimic_button_field': 'submit_button_login_submit: ..',
                'button_value': '.',
                'strip_page_top': 0,
                'user_name_defval': '',
                'user_name': username,
                mask: '',
                'passwd1': ' ' * 9,
                'md5_pass': md5_pass,
                'auth_key': auth_key

            }
            req_body = urllib.urlencode(body)
            print req_body
            uri = '/index.cgi'
            url = proto + '://' + host + uri

            req = {
                # combined elements
                'URL': url,
                'request-line': 'POST /index.cgi HTTP/1.1',
                'request-body': req_body,
                # basic elements
                'host': host,
                'proto': 'HTTP/1.1',
                'uri': uri,
                'method': 'POST',
            }
            # login with username and password
            resp, content = Sender.sendRequest(req)
            print resp
            # check next page is main page
            idPage = self.parseNextPage(resp, content)

            print 'next page is :', idPage
            if idPage != 'main':
                print '\n##################Get main page after login FAILED\n'
                return False
            elif idPage == 'main':
                print '\n################## Get main page after login PASSED\n'
                return True
        elif idPage == 'loginSetup':
            print '##################loginSetup page after restore default'
            #username = self.m_hashENV.get('U_DUT_HTTP_USER', 'admin')
            #password = self.m_hashENV.get('U_DUT_HTTP_PWD', 'admin1')

            mask = ""
            match = r"name=\"(password_\d+)"
            r = re.search(match, content)
            #print r
            if r:
                gp = r.groups()
                mask = gp[0]
            print 'mask is :', mask

            post_body = "active_page=9097&active_page_str=page_login_setup&page_title=Login+Setup&"

            post_body += "mimic_button_field=submit_button_login_submit%3A+..&button_value=6027&strip_page_top=0&"
            post_body += "username_defval=" + username + "&username=" + username + "&"
            post_body += (mask + "=" + password + "&rt_" + mask + "=" + password + "&")
            post_body += "time_zone=Eastern_Time&time_zone_defval=Eastern_Time"

            #req_body = urllib.urlencode(body)
            req_body = post_body
            req = {
                # combined elements
                'URL': 'http://' + host + '/index.cgi',
                'request-line': 'POST /index.cgi HTTP/1.1',
                'request-body': req_body,
                # basic elements
                'host': host,
                'proto': 'HTTP/1.1',
                'uri': '/index.cgi',
                'method': 'POST',
            }

            pprint(req)
            # login with username and password
            resp, content = Sender.sendRequest(req)
            idPage = self.parseNextPage(resp, content)
            print resp
            print 'next page is :', idPage
            if idPage != 'main':
                print '\n################## Get main page FAILED after login Setup\n'
                return False
            elif idPage == 'main':
                print '\n##################Get main page PASSED after login Setup\n'
                return True

    def logout(self):
        """
        """
        print '##################logout page'
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.1 instead'

        uri = '/index.cgi'
        url = proto + '://' + host + uri
        #active_page=9128&active_page_str=page_home_act_vz&page_title=Main&mimic_button_field=logout%3A+...&button_value=&strip_page_top=0
        """
        active_page    9128
        active_page_str    page_home_act_vz
        page_title    Main
        mimic_button_field    logout: ...
        button_value
        strip_page_top    0
        """
        body = {
            'active_page': '9128',
            'active_page_str': 'page_home_act_vz',
            'page_title': 'Main',
            'mimic_button_field': 'logout: ...',
            'button_value': '',
            'strip_page_top': '0'

        }
        #active_page=730&active_page_str=page_advanced&page_title=Advanced&mimic_button_field=logout%3A+...&button_value=actiontec_topbar_adv_setup&strip_page_top=0
        req_body = urllib.urlencode(body)
        print req_body
        req = {
            # combined elements
            'URL': url,
            'request-line': 'POST / HTTP/1.1',
            'request-body': req_body,
            # basic elements
            'host': host,
            'proto': 'HTTP/1.1',
            'uri': uri,
            'method': 'POST',
        }
        Sender = self.m_sender
        # login with username and password
        #resp, content = Sender.sendRequest(req)

        try:
            #Sender = self.m_sender
            resp, content = Sender.sendRequest(req)
        except Exception, e:
            self.warning('Exception : ' + str(e))
            return True
        idPage = self.parseNextPage(resp, content)
        if idPage != 'login' and idPage != 'loginSetup':
            print 'AT_WARNING : logout FAILED!'
            self.error('AT_WARNING : logout FAILED!')
            #return False
        else:
            print 'AT_INFO : logout PASSED!'
        return True

    def upgradeFirmware(self, filepath, ver=None):
        """
        """
        print '+++' * 32
        host = os.environ.get('TMP_HTTP_HOST')
        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.1 instead'
        proto = 'http'
        uri = '/index.cgi'
        url = proto + '://' + host + uri

        req_1 = {
            # combined elements
            'URL': url,
            'request-line': '',
            #active_page=9131&active_page_str=page_home_act_vz&page_title=Main&mimic_button_field=sidebar%3A+actiontec_topbar_adv_setup..&button_value=741&strip_page_top=0
            'request-body': 'active_page=9131&active_page_str=page_home_act_vz&page_title=Main&mimic_button_field=sidebar%3A+actiontec_topbar_adv_setup..&button_value=741&strip_page_top=0',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_1)
        print '-----------------------------------------------------------------------------------------------------------'
        proto = 'http'
        uri = '/index.cgi'
        url = proto + '://' + host + uri
        req_2 = {
            # combined elements
            'URL': url,
            'request-line': '',
            #active_page=730&active_page_str=page_advanced&page_title=Advanced&mimic_button_field=submit_button_yes%3A+..&button_value=actiontec_topbar_adv_setup&strip_page_top=0
            'request-body': 'active_page=730&active_page_str=page_advanced&page_title=Advanced&mimic_button_field=submit_button_yes%3A+..&button_value=actiontec_topbar_adv_setup&strip_page_top=0',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_2)
        print '-------------------------------------------------------------------------------------------------------------'
        proto = 'http'
        uri = '/index.cgi'
        url = proto + '://' + host + uri
        req_3 = {
            # combined elements
            'URL': url,
            'request-line': '',
            #active_page=730&active_page_str=page_advanced&page_title=Advanced&mimic_button_field=goto%3A+741..&button_value=actiontec_topbar_adv_setup&strip_page_top=0
            'request-body': 'active_page=730&active_page_str=page_advanced&page_title=Advanced&mimic_button_field=goto%3A+741..&button_value=actiontec_topbar_adv_setup&strip_page_top=0',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_3)
        print '-------------------------------------------------------------------------------------------------------------'
        proto = 'http'
        uri = '/index.cgi'
        url = proto + '://' + host + uri
        req_4 = {
            # combined elements
            'URL': url,
            'request-line': '',
            #active_page=741&active_page_str=page_wan_upgrade&page_title=+Firmware+Upgrade&mimic_button_field=submit_button_man_upgrade%3A+..&button_value=741&strip_page_top=0&wan_upgrade_type=3&wan_upgrade_type_defval=3&check_url_defval=https%3A%2F%2Fupgrade.actiontec.com%2FMI424WR2%2FMI424WR2.rmt&check_url=https%3A%2F%2Fupgrade.actiontec.com%2FMI424WR2%2FMI424WR2.rmt
            'request-body': 'active_page=741&active_page_str=page_wan_upgrade&page_title=+Firmware+Upgrade&mimic_button_field=submit_button_man_upgrade%3A+..&button_value=741&strip_page_top=0&wan_upgrade_type=3&wan_upgrade_type_defval=3&check_url_defval=https%3A%2F%2Fupgrade.actiontec.com%2FMI424WR2%2FMI424WR2.rmt&check_url=https%3A%2F%2Fupgrade.actiontec.com%2FMI424WR2%2FMI424WR2.rmt',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_4)
        print '----------------------------------------------------------------------------------------------------------'
        uri = '/upgrade.cgi'
        fields = {
            'active_page': '747',
            #'page_title':'Upgrade From a Computer in the Network',
            'mimic_button_field': 'submit_button_upgrade_now: ..',
            'button_value': '741',
            'strip_page_top': '0',
            'image': open(filepath, 'rb'),
        }
        rc = self.m_sender.uploadFileNew(proto + '://' + host + uri, fields=fields)
        print '-->', 'upload File Done!'
        print '-----------------------------------------------------------------------------------------------------------'
        proto = 'http'
        #http:/ index.cgi?active%5fpage=743&req%5fmode=0&mimic%5fbutton%5ffield=submit%5fbutton%5fupgrade%5fnow%3a+%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=741
        uri = '/index.cgi?active%5fpage=743&req%5fmode=0&mimic%5fbutton%5ffield=submit%5fbutton%5fupgrade%5fnow%3a+%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=741'
        url = proto + '://' + host + uri
        req_1 = {
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
        #resp, content = self.m_sender.sendRequest(req_1) 
        print '------------------------------------------------------------------------------------------------------'
        proto = 'http'
        uri = '/index.cgi'
        url = proto + '://' + host + uri
        req_1 = {
            # combined elements
            'URL': url,
            'request-line': '',
            #                 active_page=743&page_title=+Firmware+Upgrade&mimic_button_field=submit_button_submit%3A+..&button_value=741&strip_page_top=0
            'request-body': 'active_page=743&page_title=+Firmware+Upgrade&mimic_button_field=submit_button_submit%3A+..&button_value=741&strip_page_top=0',
            # basic elements
            'host': host,
            'proto': 'HTTP',
            'uri': str(uri),
            'method': 'POST',
        }
        resp, content = self.m_sender.sendRequest(req_1)
        return rc


hash_runners = {
    '20.19.0': Runner_v20_19_0,
    '20.9.0': Runner_v20_9_0,
}

def_runner = '20.19.0'


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



