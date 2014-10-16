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


class Runner_V31_122L_01(RunnerBase):
    """
    #31.122L.01
    """
    m_next_sleep_time = 0

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, '31.122L.01', Sender, loglevel)
        self.info('Runner for TV2KH ' + self.m_prod_ver)

    def doWaitingPage(self, req, resp, content):
        print '== uri is : ', req['uri']

        uri = req['uri']
        #setTimeout("do_reload()", 60*1000)
        #m_timeout = r'setTimeout\(\"do_re\w*\(\)\", (\d*)\);'
        m_timeout = r'setTimeout\(\"do_re[^,]*,\s*([^)]*)'

        #pprint(content)

        rc_timeout = re.findall(m_timeout, content)
        #rc_timeout2 = re.findall(m_timeout2, content)
        sleep_time = 0
        if len(rc_timeout) > 0:
            for index in range(len(rc_timeout)):
            #                print rc_timeout
            #                print 'current time out :', rc_timeout[index]
                #    retryTime
                if rc_timeout[index] == 'retryTime':
                    if len(rc_timeout) == 1:
                        rc_timeout[index] = '120*1000'
                    else:
                        rc_timeout[index] = '0'

                time2sleep = os.popen('echo ' + rc_timeout[index] + ' | bc').read()
                #                print 'time2sleep : ', time2sleep
                secs = None
                try:
                    secs = int(time2sleep)
                except:
                    print 'bad number : ', time2sleep

                tmp = secs
                if secs:
                    rc_timeout[index] = tmp
                else:
                    rc_timeout[index] = 0

            rc_timeout.sort(reverse=True)

            print rc_timeout
            #print rc_timeout
            #            time2sleep = os.popen('echo ' + rc_timeout[0] + ' | bc').read()
            #
            #
            #            print secs
            sleep_time = float(rc_timeout[0]) / 666

            print 'sleep_time : ', sleep_time

            if uri.find('.cgi') > -1 or uri.find('.cmd') > -1 or uri.find('.wl') > -1 or uri.find('.tod') > -1:
                print 'uri====>', uri.find('.cgi')
                if uri.find('natcfg.cmd') > -1:
                    sleep_time = 60
                elif uri.find('advancedsetup_lanipaddress_info.cgi') > -1:
                    sleep_time = 120
                if self.m_next_sleep_time > sleep_time:
                    sleep_time = self.m_next_sleep_time
                print '== | sleep ', sleep_time, 'sec according to setTimeout() function'
                time.sleep(sleep_time)
            else:
                if sleep_time > self.m_next_sleep_time:
                    print '== no need to sleep in current page , store it to next page'
                    self.m_next_sleep_time = sleep_time
        else:
            if uri.find('.cgi') > -1 or uri.find('.cmd') > -1 or uri.find('.wl') > -1 or uri.find('.tod') > -1:
                if self.m_next_sleep_time > 0:
                    sleep_time = self.m_next_sleep_time
                    if uri.find('natcfg.cmd') > -1:
                        if sleep_time < 60:
                            sleep_time = 60
                    elif uri.find('advancedsetup_lanipaddress_info.cgi') > -1:
                        sleep_time = 120
                    print '== | sleep ', sleep_time, 'sec according to previous setTimeout() function'
                    self.m_next_sleep_time = 0
                    time.sleep(sleep_time)

                else:
                    print '== no need to sleep'
            else:
                print '== no need to sleep'

    def retryFun(self, fc='', fcPars=(), exp='ppp\d+.*|ewan\d+.*|[ap]tm\d+.*', rts=6, wt=15, debug=True):
        retryTimes = 0
        rvStr = 'self.%s%s' % (fc, fcPars)
        print '====>', rvStr
        while 1:
            try:
                rv = eval(rvStr)
            except AttributeError, e:
                print '====>', e
                rvStr = '%s%s' % (fc, fcPars)
                try:
                    rv = eval(rvStr)
                except Exception, e:
                    print '====>', e
                    rv = 'False'
            if rv:
                rc = re.search(exp, rv)
            else:
                rc = None
            retryTimes += 1
            if rc is not None:
                if debug:
                    print '<%s> returned expect value : <%s> !' % (fc, rc.group())
                return rc.group()
                break
            else:
                if debug:
                    print 'Not got <%s> expect return value at <%s> times,will have a retry after <%s> seconds!' % (
                    fc, retryTimes, wt)
                time.sleep(wt)
                if retryTimes == rts:
                    print 'Failed executed %s after retry %s times!' % (fc, rts)
                    return False
                    break


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

        return idPage

    def get_gpv_value(self, cmdlist=[], logFileName='cli_command.log', m1=r'.*\s*=\s*(\w+.*)'):

        host = os.getenv('G_PROD_BR0_0_0', '192.168.1.254')

        port = os.getenv('U_DUT_TELNET_PORT', '23')

        username = os.getenv('U_DUT_TELNET_USER', 'admin')

        password = os.getenv('U_DUT_TELNET_PWD', 'password')

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
        # get page /modemstatus_home_refresh.html
        #        host = os.getenv('G_PROD_BR0_0_0', '192.168.1.254')
        #        uri = '/modemstatus_home_refresh.html'
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
        #        #print '== ', content
        #        #0++1++fe80::215:5ff:fefa:7af0+fd00::1/64+DHCP+++ewan0.1++ppp0.1++++Disconnected+Connecting+++0
        #        #1++0++fe80::215:5ff:fefa:7af0+fd00::1/64+DHCP+++ewan0.1++++++Connecting+Unconfigured+fe80::215:5ff:fefa:7af3++0
        #        #1++0++fe80::215:5ff:fefa:7af0+fd00::1/64+DHCP+++ewan0.1++ppp0.1++++Connecting+Disconnected+fe80::215:5ff:fefa:7af3++0
        #        _ = re.compile('&#(x)?([0-9a-fA-F]+);')
        #        to_str = lambda s, charset = 'utf-8':_.sub(lambda result:unichr(int(result.group(2), result.group(1) == 'x' and 16 or 10)).encode(charset) , s)
        #
        #        raw_content = to_str(content)
        #        print '== ', raw_content
        #
        #        res = raw_content.split('+')
        #        print '== res', res
        #
        #        if len(res) > 10 :
        #            wanInf = res[9]
        #            if wanInf :
        #                os.environ['TMP_CUSTOM_WANINF'] = wanInf
        #
        #                if wanInf == 'atm0' :
        #                    os.environ['TMP_CUSTOM_WANL2INFNAME'] = 'atm0/(0_0_33)'
        #                elif wanInf == 'atm1' :
        #                    os.environ['TMP_CUSTOM_WANL2INFNAME'] = 'atm1/(0_8_35)'
        #                elif wanInf == 'ptm0' :
        #                    os.environ['TMP_CUSTOM_WANL2INFNAME'] = 'ptm0/(0_0_1)'
        #                else :
        #                    os.environ['TMP_CUSTOM_WANL2INFNAME'] = ''
        #
        #        output = os.path.expandvars('$G_CURRENTLOG/wan_link.log')
        #
        #
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
        #        conn_info = None
        #        wan_info = None
        #        wanIntf = None
        #        wanL2IfName = None
        #
        #        if len(res) > 4 :
        #           conn_info = res[3]
        #           print '== conn_info', conn_info
        #        print '-' * 32
        #
        #        if conn_info :
        #            res = conn_info.split(';')
        #            wan_info = res[0]
        #            print '== wan_info', wan_info
        #
        #        if wan_info :
        #            res = wan_info.split(':')
        #            if len(res) > 2 :
        #                wanL2IfName = res[0]
        #                print '== wanL2IfName', wanL2IfName
        #                wanIntf = res[1]
        #                print '== wanIntf', wanIntf
        #        # set envrionment variable
        #        if wanIntf :
        #            os.environ['TMP_CUSTOM_WANINF'] = wanIntf
        #            print 'NOTICE : TMP_CUSTOM_WANINF set to :', wanIntf
        #        pass
        #retryFun(self,fc,fcPars=(),exp='ppp\d+|ewan\d+|[ap]tm\d+',rts=6,wt=15)
        #get_gpv_value(self,cmdlist = [],logFileName='cli_command.log',m1 = r'.*\s*=\s*(.*)')
        fp_cmd = []
        fullpath = 'InternetGatewayDevice.Layer3Forwarding.X_ACTIONTEC_COM_DefaultConnectionFullPath'
        fullpath_v = None
        current_if = None
        current_if_v = None
        fp_cmd.append('gpv %s' % fullpath)
        #        fullpath_v = self.get_gpv_value(fp_cmd)
        Exp = '\w+\.+.*'
        fullpath_v = self.retryFun('get_gpv_value', fcPars=(fp_cmd,), exp=Exp)
        print '===><%s>' % fullpath_v

        if fullpath_v:
            lay3_cmd_list = []
            lay2_cmd_list = []
            current_lay3_point = 'gpv %s.X_BROADCOM_COM_IfName' % fullpath_v
            lay3_cmd_list.append(current_lay3_point)
            lay3logName = 'gpv_lay3_wif.log'
            print '====' * 32
            #            current_if_v = self.get_gpv_value(lay3_cmd_list,lay3logName)
            current_if_v = self.retryFun('get_gpv_value', fcPars=(lay3_cmd_list, lay3logName))
            print '====' * 32

            #            m_eth = 'WANConnectionDevice\.\d+.WAN[I|P]P{1,2}Connection\.\d+'
            #            eth_rp_str = re.search(m_eth,fullpath_v)
            #            if eth_rp_str is not None:
            #                current_lay2_point_ETH = current_lay3_point.replace(eth_rp_str.group(),'WANEthernetInterfaceConfig')
            #                lay2_cmd_list.append(current_lay2_point_ETH)

            m1 = 'WAN[I|P]P{1,2}Connection\.\d+'
            rp_str = re.search(m1, fullpath_v)

            if rp_str is not None:
                current_lay2_point_DSL = current_lay3_point.replace(rp_str.group(), 'WANDSLLinkConfig')
                current_lay2_point_PTM = current_lay3_point.replace(rp_str.group(), 'WANPTMLinkConfig')
                lay2_cmd_list.append(current_lay2_point_DSL)
                lay2_cmd_list.append(current_lay2_point_PTM)
                lay2logName = 'gpv_lay2_wif.log'
                #                current_lay2_if = self.get_gpv_value(lay2_cmd_list,lay2logName,m1 = r'.*\s*=\s*(\w+\d+)')
                current_lay2_if = self.retryFun('get_gpv_value', fcPars=(lay2_cmd_list, lay2logName))
                print 'Current lay2 interface is :<%s>' % current_lay2_if

                m_atm = 'atm\d+'
                m_ptm = 'ptm\d+'
                m_eth = 'ewan\d+'
                if current_lay2_if:

                    rc_atm = re.search(m_atm, current_lay2_if)
                    rc_ptm = re.search(m_ptm, current_lay2_if)
                    if rc_atm is not None:
                        Get_Vci_Vpi_Cmd = []
                        c_lay2_DSL_PVC = current_lay2_point_DSL.replace('X_BROADCOM_COM_IfName', 'DestinationAddress')
                        Get_Vci_Vpi_Cmd.append(c_lay2_DSL_PVC)
                        pvclogName = 'gpv_atm_pvc.log'
                        exp_pvc = 'PVC.*|pvc.*'
                        #                        current_pvc_v=self.get_gpv_value(Get_Vci_Vpi_Cmd,pvclogName)
                        current_pvc_v = self.retryFun('get_gpv_value', fcPars=(Get_Vci_Vpi_Cmd, pvclogName),
                                                      exp=exp_pvc)
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
                    else:
                        wan_l2_if = current_lay2_if
                        os.environ.update({'TMP_CUSTOM_SERVNAME': current_lay2_if})
                else:
                    wan_l2_if = 'ewan0'
                if not current_if_v:
                    print 'Current DUT lay3 interface is : <%s>' % current_if_v
                    current_if_v = ''
                os.environ.update({
                    'TMP_CUSTOM_WANINF': current_if_v,
                    'TMP_CUSTOM_WANL2INFNAME': wan_l2_if,

                })
            else:
                print "AT_ERROR : Failed to create current lay2 gpv point."
                return False
        print 'So update to env lay2 interface is : <%s>' % wan_l2_if
        pass


    def login(self):
        """
        inputUserName    root
        inputPassword    Thr33scr33n!
        nothankyou    1 G_PROD_IP_BR0_0_0
        """

        print '== in function login()'
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')

        username = os.getenv('U_DUT_HTTP_USER', 'root')
        password = os.getenv('U_DUT_HTTP_PWD', 'Thr33scr33n!')
        password = urllib.quote(password)
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.254')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.254 instead'

        uri = '/'
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
            'method': 'GET',
        }

        resp, content = self.m_sender.sendRequest(req)

        #uri = '/login.cgi?inputUserName=' + username + '&inputPassword=' + password + '&nothankyou=1'
        #url = proto + '://' + host + '/login.cgi?inputUserName=' + username + '&inputPassword=' + password + '&nothankyou=1'
        url = proto + '://' + host + '/login.cgi'
        method = 'POST'

        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': 'inputUserName=' + username + '&inputPassword=' + password + '&nothankyou=1',
            # basic elements
            'host': host,
            'proto': proto,
            'uri': uri,
            'method': method,
        }

        resp, content = self.m_sender.sendRequest(req)

        match_err = r'msg=err'
        rc = re.findall(match_err, content)
        #pprint(rc)
        #print 'length of rc :',len(rc)
        if len(rc) > 0:
            print 'login to DUT failed ,please check the username and password !'
            return False
        else:
            print 'login successfully !'

            if resp.has_key('set-cookie'):
                curr_Cookie = resp['set-cookie']
                m_session_id = r'ACTSessionID=(\d*)'

                rc_sess_id = re.findall(m_session_id, curr_Cookie)

                if len(rc_sess_id) > 0:
                    curr_session_id = rc_sess_id[0]
                    print '==| change current session id to : ', curr_session_id
                    os.environ['TMP_SESSION_ID'] = curr_session_id

            return True

    def logout(self):
        """
        """
        print '==to Logout'
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.254')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.254 instead'

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

            if resp.has_key('Cookie'):
                curr_Cookie = resp['Cookie']
                m_session_id = r'ACTSessionID=(\d*)'

                rc_sess_id = re.findall(m_session_id, curr_Cookie)

                if len(rc_sess_id) > 0:
                    curr_session_id = rc_sess_id[0]

                    previous_session = os.getenv('TMP_SESSION_ID')
                    if previous_session != None and previous_session != curr_session_id:
                        print '==| change current session id to : ', curr_session_id
                        os.environ['TMP_SESSION_ID'] = curr_session_id

            self.doWaitingPage(req, resp, content)

        # update Runtime status
        idx2 = idx + 1
        if idx2 < len(Reqs):
            req2 = Reqs[idx2]
            uri = req2['uri']
            s = 'wansetup.cmd'
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
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.254')
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.254 instead'

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

        uri = '/upload.cgi'
        key = 'filename'
        fname = os.path.basename(filepath)
        val = open(filepath, 'rb').read()
        files = [(key, fname, val)]

        rc = self.m_sender.uploadFileNew(proto + '://' + host + uri, {key: open(filepath, 'rb')})
        return rc


class Runner_V31_60L_15A(RunnerBase):
    """
    """
    m_next_sleep_time = 0

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, '31.60L.15a', Sender, loglevel)
        self.info('Runner for TV2KH ' + self.m_prod_ver)

    def doWaitingPage(self, req, resp, content):
        print '== uri is : ', req['uri']

        uri = req['uri']

        m_timeout = r'setTimeout\(\"do_re\w*\(\)\", (\d*)\);'
        print '-->', content
        rc_timeout = re.findall(m_timeout, content)
        sleep_time = 0
        if len(rc_timeout) > 0:
            for index in range(len(rc_timeout)):
                tmp = int(rc_timeout[index])
                rc_timeout[index] = tmp

            rc_timeout.sort(reverse=True)
            #print rc_timeout
            sleep_time = float(rc_timeout[0]) / 500

            print 'sleep_time : ', sleep_time
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

        return idPage


    def updateRuntimeStatus(self):
        """
        """
        # get page connect_left_refresh.html
        host = os.getenv('G_PROD_BR0_0_0', '192.168.1.254')
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

        #print '== ',content
        _ = re.compile('&#(x)?([0-9a-fA-F]+);')
        to_str = lambda s, charset='utf-8': _.sub(
            lambda result: unichr(int(result.group(2), result.group(1) == 'x' and 16 or 10)).encode(charset), s)

        raw_content = to_str(content)
        #print '== ',raw_content

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
            # set envrionment variable
        if wanIntf:
            os.environ['TMP_CUSTOM_WANINF'] = wanIntf
            print 'NOTICE : TMP_CUSTOM_WANINF set to :', wanIntf
        pass


    def login(self):
        """
        """
        print '== in function login()'
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')

        username = os.getenv('U_DUT_HTTP_USER', 'root')
        password = os.getenv('U_DUT_HTTP_PWD', 'Thr33scr33n!')
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = '192.168.1.254'
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.254 instead'

        uri = '/'
        url = proto + '://' + host + uri

        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': host,
            'proto': 'HTTP/1.1',
            'uri': uri,
            'method': 'GET',
        }

        resp, content = self.m_sender.sendRequest(req)

        uri = '/login.cgi?inputUserName=' + username + '&inputPassword=' + password + '&nothankyou=1'
        url = proto + '://' + host + '/login.cgi?inputUserName=' + username + '&inputPassword=' + password + '&nothankyou=1'
        method = 'GET'

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

        match_err = r'msg=err'
        rc = re.findall(match_err, content)
        #pprint(rc)
        #print 'length of rc :',len(rc)
        if len(rc) > 0:
            print 'login to DUT failed ,please check the username and password !'
            return False
        else:
            print 'login successfully !'

            if resp.has_key('set-cookie'):
                curr_Cookie = resp['set-cookie']
                m_session_id = r'ACTSessionID=(\d*)'

                rc_sess_id = re.findall(m_session_id, curr_Cookie)

                if len(rc_sess_id) > 0:
                    curr_session_id = rc_sess_id[0]
                    print '==| change current session id to : ', curr_session_id
                    os.environ['TMP_SESSION_ID'] = curr_session_id

            return True

    def logout(self):
        """
        """
        print '==to Logout'
        proto = os.environ.get('TMP_HTTP_PROTO', 'http')
        host = os.environ.get('TMP_HTTP_HOST')

        if not host:
            host = '192.168.1.254'
            print 'TMP_HTTP_HOST not defined ! using 192.168.1.254 instead'

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
        resp = req['resp-headers']
        content = req['resp-content']

        if resp.has_key('set-cookie'):
            curr_Cookie = resp['set-cookie']
            m_session_id = r'ACTSessionID=(\d*)'

            rc_sess_id = re.findall(m_session_id, curr_Cookie)

            if len(rc_sess_id) > 0:
                curr_session_id = rc_sess_id[0]

                previous_session = os.getenv('TMP_SESSION_ID')
                if previous_session != None and previous_session != curr_session_id:
                    print '==| change current session id to : ', curr_session_id
                    os.environ['TMP_SESSION_ID'] = curr_session_id

        self.doWaitingPage(req, resp, content)

        return True

######################################################


hash_runners = {
    '31.60L.15a': Runner_V31_60L_15A,
    '31.122L.01': Runner_V31_122L_01,
}

def_runner = '31.122L.01'


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



