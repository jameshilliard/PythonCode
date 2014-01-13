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


class Runner_VCAC001_31_30L_00B(RunnerBase):
    """
    """

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, 'CAC001-31.30L.00B', Sender, loglevel)
        self.info('Runner for C2KA ' + self.m_prod_ver)

    def doWaitingPage(self, req):
        #
        resp = req['resp-headers']
        content = req['resp-content']
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
            'modemstatus_home.html',
            'utilities_timezone.cgi',
            'utilities_timezone.html',
            'wansetup.cmd',
            'dslatm.cmd',
            'dslptm.cmd',
            'ethwan.cmd',
        ]

        wp15 = ['natcfg.cmd']

        wp10 = ['advancedsetup_firewallsettings.html']
        wp80 = ['utilities_restoredefaultsettings.html',
                'rebootinfo.cgi',
                'rebootinfo.html',
                'restoreinfo.html',
                'advancedsetup_lanipaddress.cgi',
        ]

        #if self.cfg['method']!='POST' :
        #   print '==GET will not waiting Page(',redirect,')'
        #   return True
        timeout = 30
        if redirect:
            if redirect.find('wirelesssetup') >= 0:
                timeout = 65
            if redirect in wp35:
                timeout = 35
            elif redirect in wp10:
                timeout = 30
            elif redirect in wp15:
                timeout = 30
            elif redirect in wp80:
                timeout = 180
        print '==Waiting Page(', redirect, ') : ', timeout
        time.sleep(timeout)

    def parseNextPage(self, resp, content):
        """
         
        """
        idPage = ''
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

    def get_gpv_value(self, cmdlist=[], logFileName='cli_command.log', m1=r'.*\s*=\s*(.*)'):

        host = os.getenv('G_PROD_BR0_0_0', '192.168.0.1')
        port = os.getenv('U_DUT_TELNET_PORT', '23')
        username = os.getenv('U_DUT_TELNET_USER', 'admin')
        password = os.getenv('U_DUT_TELNET_PWD', '1')
        current_return_value = False

        logFilePath = os.path.expandvars('$G_CURRENTLOG')
        if not logFilePath.startswith('/'):
            logFilePath = '/tmp'
        logFile = os.path.join(logFilePath, logFileName)

        current_pvc_rc = self.cli_command(cmdlist, host, port, username, password, output=logFile)
        if current_pvc_rc:
            gpv_current_if_f = open(logFile, 'r')
            for line in gpv_current_if_f:
                rc = re.findall(m1, line.strip())
                if len(rc) > 0:
                    current_return_value = rc[0]
                    print 'Current return value is: <%s>' % current_return_value
                    return current_return_value
                    break
            gpv_current_if_f.close()

        print 'Current return value is <%s>' % current_return_value
        return current_return_value

    def updateRuntimeStatus(self):
        """
        """
        #        # get page connect_left_refresh.html
        #        # wanIfName=ppp0 (in broadband setting page)
        #        _ = re.compile('&#(x)?([0-9a-fA-F]+);')
        #        to_raw_str = lambda s, charset = 'utf-8':_.sub(lambda result:unichr(int(result.group(2), result.group(1) == 'x' and 16 or 10)).encode(charset) , s)
        #
        #        host = os.getenv('G_PROD_BR0_0_0', '192.168.0.1')
        #        uri = '/connect_left_refresh.html'
        #        method = 'GET'
        #
        #
        #        req = {
        #            # combined elements
        #            'URL' : 'http://' + host + uri,
        #            'request-line' : '',
        #            'request-body' : '',
        #            # basic elements
        #            'host' : host,
        #            'proto' : 'HTTP/1.1',
        #            'uri' : uri,
        #            'method' : method,
        #        }
        #
        #        resp, content = self.m_sender.sendRequest(req)
        #
        #        print '== content', content
        #
        #        contents = content.split('+')
        #
        #        print '== contents', contents
        #
        #        is_eth = contents[0]
        #
        #        print 'is_eth is :', is_eth
        #
        #        if is_eth == 'xDSL':
        #           # connect_retry=6
        #
        #            for conn in range(6):
        #                print 'try fetch connection info : ', conn
        #                connInfos = contents[3]
        #                if len(connInfos) == 0 :
        #                    print 'the connection info is not ready yet .'
        #
        #                    time.sleep(10)
        #                    resp, content = self.m_sender.sendRequest(req)
        #                    contents = content.split('+')
        #                else:
        #                    break
        #            if len(contents[3]) == 0:
        #                print 'AT_ERROR : connection info is not ready after all'
        #                exit(1)
        #            else:
        #                ifInfos = contents[3].split(':')
        #        #print len(atms[8].split('+')[2].split(':'))
        #                layer2ifc = to_raw_str(ifInfos[0])
        #                print  'layer2ifc : ', layer2ifc
        #                layer3ifc = to_raw_str(ifInfos[1])
        #                print  'layer3ifc : ', layer3ifc
        #            #print  'traffic type : ', to_raw_str(ifInfos[2])
        #        else:
        #            print 'current link is ETHERNET'
        #
        #            infos = to_raw_str(contents[6])
        #            print infos
        #            layer2ifc = 'ewan0'
        #            print  'layer2ifc : ewan0'
        #            layer3ifc = infos.split(':')[1]
        #            print 'layer3ifc : ', infos.split(':')[1]
        #        #time.sleep(10)
        #        #exit(1)
        #
        #        #TMP_CUSTOM_WANL2INFNAME     l2
        #        #TMP_CUSTOM_WANINF            l3
        #        os.environ['TMP_CUSTOM_WANL2INFNAME'] = layer2ifc
        #        os.environ['TMP_CUSTOM_WANINF'] = layer3ifc
        #
        #        if layer2ifc.find('atm') >= 0:
        #            editWanL2IfName = 'atm0'
        #            os.environ['TMP_CUSTOM_EDITWANL2INFNAME'] = editWanL2IfName
        #        elif layer2ifc.find('ptm') >= 0:
        #            editWanL2IfName = 'ptm0'
        #            os.environ['TMP_CUSTOM_EDITWANL2INFNAME'] = editWanL2IfName
        ##        elif layer2ifc.find('ewan') >= 0:
        ##            editWanL2IfName = 'ewan0'
        #        #if editWanL2IfName != None :
        #        #    os.environ['TMP_CUSTOM_EDITWANL2INFNAME'] = editWanL2IfName
        #        m_serv = r'\((.*)\)'
        #        rc_serv = re.findall(m_serv, layer2ifc)
        #        #print rc[0]
        #        if len(rc_serv) > 0:
        #            servName = rc_serv[0]
        #            os.environ['TMP_CUSTOM_SERVNAME'] = servName
        #        pass
        fp_cmd = []
        fullpath = 'InternetGatewayDevice.Layer3Forwarding.X_00247B_DefaultConnectionFullPath'
        fullpath_v = None
        current_if = None
        current_if_v = None
        fp_cmd.append('gpv %s' % fullpath)
        fullpath_v = self.get_gpv_value(fp_cmd)
        print '===><%s>' % fullpath_v

        if fullpath_v:
            lay3_cmd_list = []
            lay2_cmd_list = []
            current_lay3_point = 'gpv %s.X_BROADCOM_COM_IfName' % fullpath_v
            lay3_cmd_list.append(current_lay3_point)
            lay3logName = 'gpv_lay3_wif.log'
            print '====' * 32
            current_if_v = self.get_gpv_value(lay3_cmd_list, lay3logName)
            print '====' * 32

            m_eth = 'WANConnectionDevice\.\d+.WAN[I|P]P{1,2}Connection\.\d+'
            eth_rp_str = re.search(m_eth, fullpath_v)
            if eth_rp_str is not None:
                current_lay2_point_ETH = current_lay3_point.replace(eth_rp_str.group(), 'WANEthernetInterfaceConfig')
                lay2_cmd_list.append(current_lay2_point_ETH)

            m1 = 'WAN[I|P]P{1,2}Connection\.\d+'
            rp_str = re.search(m1, fullpath_v)

            if rp_str is not None:
                current_lay2_point_DSL = current_lay3_point.replace(rp_str.group(), 'WANDSLLinkConfig')
                current_lay2_point_PTM = current_lay3_point.replace(rp_str.group(), 'WANPTMLinkConfig')
                lay2_cmd_list.append(current_lay2_point_DSL)
                lay2_cmd_list.append(current_lay2_point_PTM)
                lay2logName = 'gpv_lay2_wif.log'
                current_lay2_if = self.get_gpv_value(lay2_cmd_list, lay2logName, m1=r'.*\s*=\s*(\w+\d+)')
                print 'Current lay2 interface is :<%s>' % current_lay2_if

                m_atm = 'atm\d+'
                m_ptm = 'ptm\d+'
                m_eth = 'ewan\d+'
                rc_atm = re.search(m_atm, current_lay2_if)
                rc_ptm = re.search(m_ptm, current_lay2_if)
                rc_eth = re.search(m_eth, current_lay2_if)
                if rc_atm is not None:

                    Get_Vci_Vpi_Cmd = []
                    c_lay2_DSL_PVC = current_lay2_point_DSL.replace('X_BROADCOM_COM_IfName', 'DestinationAddress')
                    Get_Vci_Vpi_Cmd.append(c_lay2_DSL_PVC)
                    pvclogName = 'gpv_atm_pvc.log'
                    current_pvc_v = self.get_gpv_value(Get_Vci_Vpi_Cmd, pvclogName)
                    pvc_list = re.findall('\d+', current_pvc_v)
                    if len(pvc_list) != 2:
                        print 'AT_ERROR : Get ATM PVC failed,it value is <%s>' % current_pvc_v
                        return False
                    else:
                        wan_l2_if = '%s/(0_%s_%s)' % (current_lay2_if, pvc_list[0], pvc_list[1])
                        os.environ.update({'TMP_CUSTOM_SERVNAME': '0_%s_%s' % (pvc_list[0], pvc_list[1])
                        })
                        print 'TMP_CUSTOM_SERVNAME :<%s>' % os.getenv('TMP_CUSTOM_SERVNAME')

                elif rc_ptm is not None:
                    wan_l2_if = '%s/(0_0_1)' % current_lay2_if
                    os.environ.update({'TMP_CUSTOM_SERVNAME': '0_0_1'})
                elif rc_eth is not None:
                    wan_l2_if = current_lay2_if
                    os.environ.update({'TMP_CUSTOM_SERVNAME': current_lay2_if})
                else:
                    wan_l2_if = ''
                os.environ.update({
                    'TMP_CUSTOM_WANINF': current_if_v,
                    'TMP_CUSTOM_WANL2INFNAME': wan_l2_if,

                })
            else:
                print "AT_ERROR : Failed to create current lay2 gpv point."
                return False
        pass

    def login(self):
        """
        """
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')
        #    adminUserName    CenturyL1nk
        #    adminPassword    Q1RMc3VwcG9ydDEyAA==
        #    sessionKey    111496590
        #    nothankyou    1
        #    POST /login_supportconsole.cgi HTTP/1.1
        #    pppPassword = base64.encodestring(os.getenv('U_DUT_CUSTOM_PPP_PWD', '111111') + '\0').strip()
        #    http://192.168.0.1/supportconsole

        if proto == 'https':
            username = os.getenv('U_DUT_HTTP_USER', 'admin')
            password = os.getenv('U_DUT_HTTP_PWD', '1')

            print '== login as ' + username + ' with password ' + password
            password = base64.encodestring(password + '\0').strip()

            host = os.environ.get('TMP_HTTP_HOST')
            if not host:
                host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1')
                print 'TMP_HTTP_HOST not defined ! using 192.168.0.1 instead'

            uri = '/'
            method = 'GET'

            url = proto + '://' + host + uri

            req = {
                # combined elements
                'URL': url,
                'request-line': '',
                'request-body': '',
                # basic elements
                'host': host,
                'proto': proto,
                'uri': uri,
                'method': method,
            }

            resp, content = self.m_sender.sendRequest(req)

            # var sessionKey = '497395279'
            loginSessionKey = ''
            match = r"var sessionKey = '(.*)'"
            rc = re.findall(match, content)
            if len(rc) > 0:
                loginSessionKey = rc[0]
                print 'loginSessionKey this time is : ', loginSessionKey

            method = 'POST'
            uri = '/login.cgi'
            url = proto + '://' + host + uri

            req = {
                # combined elements
                'URL': url,
                'request-line': '',
                'request-body': 'adminUserName=' + username + '&adminPassword=' + password + '&sessionKey=' + loginSessionKey + '&nothankyou=1',
                # basic elements
                'host': host,
                'proto': proto,
                'uri': uri,
                'method': method,
            }

            resp, content = self.m_sender.sendRequest(req)
            match_success = r'Modem Status'
            match_fail = r'password entered is not valid'

            if len(re.findall(match_success, content)) > 0:
                print 'login successful !'
                return True
            elif len(re.findall(match_fail, content)) > 0:
                print 'login fail !'
                return False
        elif proto == 'http':

        #    pppPassword = base64.encodestring(os.getenv('U_DUT_CUSTOM_PPP_PWD', '111111') + '\0').strip()
        #    http://192.168.0.1/supportconsole
            print 'Try login !'
            host = os.environ.get('TMP_HTTP_HOST')
            if not host:
                host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1')
                print 'TMP_HTTP_HOST not defined ! using 192.168.0.1 instead'

            loginMode = os.environ.get('TMP_HTTP_LOGIN_MODE', 'NULL_NULL')

            uri = '/'

            if not loginMode == 'NULL_NULL':
                if loginMode == 'supportconsole':
                    uri = '/supportconsole'

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

            pprint(resp)

            # var sessionKey = '497395279'
            loginSessionKey = ''
            match = r"var sessionKey = '(.*)'"
            rc = re.findall(match, content)
            if len(rc) > 0:
                loginSessionKey = rc[0]
                print 'loginSessionKey this time is : ', loginSessionKey
                os.environ['TMP_SESSION_KEY'] = loginSessionKey
            else:
                print 'session key not found'

            username = os.getenv('U_DUT_HTTP_USER', 'admin')
            password = os.getenv('U_DUT_HTTP_PWD', '1')
            password = base64.encodestring(password + '\0').strip()
            #host = os.environ.get('TMP_HTTP_HOST')

            method = 'POST'
            uri = '/login.cgi'

            if not loginMode == 'NULL_NULL':
                if loginMode == 'supportconsole':
                    uri = '/login_supportconsole.cgi'
                    username = 'CenturyL1nk'
                    password = 'CTLsupport12'

                    password = base64.encodestring(password + '\0').strip()

            req = {
                # combined elements
                'URL': 'http://' + host + uri,
                'request-line': '',
                'request-body': 'adminUserName=' + username + '&adminPassword=' + password + '&sessionKey=' + loginSessionKey + '&nothankyou=1',
                # basic elements
                'host': host,
                'proto': 'HTTP/1.1',
                'uri': uri,
                'method': method,
            }

            #    adminUserName    CenturyL1nk
            #    adminPassword    Q1RMc3VwcG9ydDEyAA==
            #    sessionKey    111496590
            #    nothankyou    1
            #    POST /login_supportconsole.cgi HTTP/1.1

            resp, content = self.m_sender.sendRequest(req)

            match_success = r'Modem Status'
            match_fail = r'password entered is not valid'

            if not loginMode == 'NULL_NULL':
                if loginMode == 'supportconsole':
                    match_fail = r'The user name and/or password entered is not valid. Please return to the login page'

                    if len(re.findall(match_fail, content)) > 0:
                        print 'login supportconsole fail !'
                        return False
                    else:
                        print 'login supportconsole successful !'
                        return True

            if len(re.findall(match_success, content)) > 0:
                print 'login successful !'
                return True
            elif len(re.findall(match_fail, content)) > 0:
                print 'login fail !'
                return False

    def logout(self):
        """
        """
        self.info('== To Logout')
        #print '==to Logout'
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.0.1 instead'

        url = proto + '://' + host + '/logout.cgi'
        method = 'POST'

        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': '',
            'proto': '',
            'uri': '',
            'method': method,
        }

        resp, content = self.m_sender.sendRequest(req)

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
            s = 'wansetup\.cmd'
            res = re.findall(s, uri)
            if len(res):
                print '==', 'Next page is wansetup.cmd, need to update RuntimeStatus'
                self.updateRuntimeStatus()
            else:
                s1 = 'dsl(\w)tm'
                res = re.findall(s1, uri)
                if len(res):
                    print '==', 'Next page is dslatm/dslptm setting page, need to update RuntimeStatus'
                    self.updateRuntimeStatus()
        return True


    def upgradeFirmware(self, filepath, ver=None):
        """
        """

        host = os.environ.get('TMP_HTTP_HOST')
        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.0.1 instead'

        #uri = '/upload.cgi'
        proto = 'http'
        uri = '/utilities_upgradefirmware.html'
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
        print '-->', 'Get upgrade firmware page Done!'

        uri = '/upload.cgi'
        key = 'filename'
        rc = self.m_sender.uploadFileNew(proto + '://' + host + uri, {key: open(filepath, 'rb')},
                                         {'Referer': 'http://192.168.0.1/utilities_upgradefirmware_real.html'})
        print '-->', 'upload File Done!'

        return rc


######################################################


hash_runners = {
    'CAC001-31.30L.00B': Runner_VCAC001_31_30L_00B,
}

def_runner = 'CAC001-31.30L.00B'


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
    
    
    

