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


class Runner_VCAP001_10_0_0k(RunnerBase):
    """
    """

    def __init__(self, player, Sender, loglevel=2):
        """
        """
        RunnerBase.__init__(self, player, 'CAP001-10.0.0k', Sender, loglevel)
        self.info('Runner for PK5001A ' + self.m_prod_ver)

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
            'Act_Wlan_SetSecuritySettings',
            'advancedsetup_broadbandsettings.html',
            'advancedsetup_dslsettings.html',
            'advancedsetup_wanipaddress.html',
            'advancedsetup_ptmsettings.html',
            'quicksetup_home.html',
            'modemstatus_home.html',
            #'act_set_lan_dhcps'
            'act_set_telnet_setting',
            'ifx_set_firewall_website_block',
            'ifx_set_firewall_mac',
        ]

        wp10 = ['advancedsetup_firewallsettings.html',
                'ifx_set_nat_main_act']
        wp60 = [
            'Act_Wlan_multiplessidConfig',
            'ifx_set_act_application_applied',
        ]
        wp80 = ['act_set_system_reset', 'act_set_system_reboot', 'act_ifx_cgi_adsl_wan_config']

        #if self.cfg['method']!='POST' :
        #    print '==GET will not waiting Page(',redirect,')'
        #    return True
        timeout = 30
        if redirect:
            if redirect.find('wirelesssetup') >= 0:
                timeout = 65
            if redirect in wp35:
                timeout = 35
            elif redirect in wp10:
                timeout = 30
            elif redirect in wp60:
                timeout = 60
            elif redirect in wp80:
                timeout = 150
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


    def updateRuntimeStatus(self):
        """
        """
        #    advancedsetup_wanipaddress_real.html
        #var atm_info = '1|adsl_vcchannel|8/35,LLC/SNAP|nas0|0';     var atm_info = '1|adsl_vcchannel|8/35,LLC/SNAP|nas0|0';
        #var num_atm = 0;                                            var num_atm = 0;
        #var max_vcc = 20;                                           var max_vcc = 20;
        #var WAN_VCCs = new Array(20);                               var WAN_VCCs = new Array(20);
        #var WAN_COUNT = 20;                                         var WAN_COUNT = 20;

        #var DEF_GW= "WANIP0";                                       var DEF_GW= "WANPPP1";
        #var G_WAN_MODE="0";                                         var G_WAN_MODE="0";
        #var cur_def_gw="WANIP0";                                    var cur_def_gw="WANPPP1";
        #var mode_wan="IP";                                          var mode_wan="PPP";
        #var wan_type = "";                                          var wan_type = "";
        #var cpeId = "1";                                            var cpeId = "1";

        #var gw_ip = "192.168.55.254";                               var gw_ip = "10.100.100.1";
        #var def_wan_ip = "192.168.55.188";                          var def_wan_ip = "10.100.100.10";
        #var def_wan_netmask = "255.255.255.0";                      var def_wan_netmask = "255.255.255.255";
        #var ads_l3 = "0";                                           var ads_l3 = "0";
        #var autowan_status = 2;                                     var autowan_status = 2;
        #var gw1="192";                                              var gw1="10";
        #var gw2="168";                                              var gw2="100";
        #var gw3="55";                                               var gw3="100";
        #var gw4="254";                                              var gw4="1";
        #var reconnect = "";                                         var reconnect = "";
        #var authmode=  "";                                          var authmode=  "0";
        #var autoconnect;                                            var autoconnect;
        #var ipmode = "";                                            var ipmode = "";
        #var ppp_static_ipadd = "";;                                 var ppp_static_ipadd = "";;
        #var ppp_static_gateadd = "0.0.0.0";                         var ppp_static_gateadd = "0.0.0.0";
        #var ppp_static_netmask = "0.0.0.0";                         var ppp_static_netmask = "0.0.0.0";

        #print 'len content : ', len(content)
        #        print '###########################################################################'
        #        pprint(content)
        #        print '###########################################################################'
        #        print

        for wan_info_index in range(5):
            print '== try getting wan connection info : ', wan_info_index
            uri = '/advancedsetup_wanipaddress.html'
            method = 'GET'
            req = {
                # combined elements
                'URL': 'http' + '://' + '192.168.0.1' + uri,
                'request-line': '',
                'request-body': '',
                # basic elements
                'host': '192.168.0.1',
                'proto': 'HTTP/1.1',
                'uri': uri,
                'method': method,
            }

            resp, content = self.m_sender.sendRequest(req)

            time.sleep(3)

            uri = '/advancedsetup_wanipaddress_real.html'
            method = 'GET'
            req = {
                # combined elements
                'URL': 'http' + '://' + '192.168.0.1' + uri,
                'request-line': '',
                'request-body': '',
                # basic elements
                'host': '192.168.0.1',
                'proto': 'HTTP/1.1',
                'uri': uri,
                'method': method,
            }

            resp, content = self.m_sender.sendRequest(req)

            time.sleep(3)

            DEF_GW = mode_wan = VPIVCI = ''

            m_DEF_GW = r'var *DEF_GW *= *"(.*)";'
            rc = re.findall(m_DEF_GW, content)
            if len(rc) > 0:
                DEF_GW = rc[0]
                print '== DEF_GW : ', DEF_GW
                os.environ.update({'TMP_WAN_SETTING_DEF_GW': DEF_GW})

            m_mode_wan = r'var *mode_wan *= *"(.*)";'
            rc = re.findall(m_mode_wan, content)
            if len(rc) > 0:
                mode_wan = rc[0]
                print '== mode_wan : ', mode_wan
                os.environ.update({'TMP_WAN_SETTING_MODE_WAN': mode_wan})

            m_VPIVCI = r'var atm_info = \'.*\|.*\|(.*),.*\|.*\|.*\';'
            rc = re.findall(m_VPIVCI, content)
            if len(rc) > 0:
                VPIVCI = rc[0]
                print '== vpi vci : ', VPIVCI
                os.environ.update({'TMP_WAN_SETTING_VPIVCI': VPIVCI})

            if DEF_GW == '' and mode_wan == '' and VPIVCI == '':
                print '== try getting wan connection info again !'
            else:
                break

        output = os.path.expandvars('$G_CURRENTLOG/wan_link.log')

        #env_file = open(os.path.expandvars('$U_CUSTOM_UPDATE_ENV_FILE'), 'r')

        if os.path.exists(output):
            print 'AT_INFO : to update runtime ENV from file : %s' % (output)
            update_env_f = open(output, 'r')

            lines = update_env_f.readlines()
            update_env_f.close()

            m_k_v = r'(.*)=(.*)'
            for line in lines:
                rc_kv = re.findall(m_k_v, line.strip())
                if len(rc_kv) > 0:
                    k, v = rc_kv[0]
                    print 'AT_INFO : updating env : %s = %s' % (k, v)
                    os.environ.update({
                        k: v
                    })

        pass

    def updateOldUsername(self):
        """
        """
        print '== try getting old user name info'
        uri = '/advancedsetup_remotetelnet.html'
        method = 'GET'
        req = {
            # combined elements
            'URL': 'http' + '://' + '192.168.0.1' + uri,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': '192.168.0.1',
            'proto': 'HTTP/1.1',
            'uri': uri,
            'method': method,
        }

        resp, content = self.m_sender.sendRequest(req)

        #<input type="hidden" name="userOldname" value="root">

        userOldname = r'<input type=\"hidden\" name=\"userOldname\" value=\"(.*)\">'
        rc = re.findall(userOldname, content)
        if len(rc) > 0:
            oldname = rc[0]
            print '== userOldname : ', oldname
            os.environ.update({'TMP_TELNET_OLD_USERNAME': oldname})

    def login(self):
        """
        """
        print 'in PK5K1A runner Login routine'

        proto = os.environ.get('TMP_HTTP_PROTO', 'http')
        username = os.getenv('U_DUT_HTTP_USER', 'admin')
        password = os.getenv('U_DUT_HTTP_PWD', 'Centurylink')
        host = os.environ.get('TMP_HTTP_HOST', '192.168.0.1')

        uri = '/'
        url = proto + '://' + host + uri
        method = 'GET'
        print 'host :', host
        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': host,
            'proto': 'HTTP/1.1',
            'uri': uri,
            'method': method,
        }

        resp, content = self.m_sender.sendRequest(req)

        # 'content-location': 'http://192.168.0.1/login.html' (fail) 
        # http://192.168.0.1/ (pass)
        #print 'content-location is :', resp['content-location'], resp

        match = r'login.html'

        #rc = re.findall(match, resp['content-location'])
        #if len(rc) > -1 :
        print 'need to do Login !'

        uri = '/login.html'
        url = proto + '://' + host + uri
        method = 'GET'
        print 'host :', host
        req = {
            # combined elements
            'URL': url,
            'request-line': '',
            'request-body': '',
            # basic elements
            'host': host,
            'proto': 'HTTP/1.1',
            'uri': uri,
            'method': method,
        }

        resp, content = self.m_sender.sendRequest(req)

        #print resp
        #print content

        uri = '/goform/act_set_web_login'
        url = proto + '://' + host + uri
        method = 'POST'
        req = {
            # combined elements urllib.quote_plus(password)
            'URL': url,
            'request-line': '',
            'request-body': 'page=index.html&admin_user_name=' + username + '&admin_password=' + urllib.quote_plus(
                password) + '&admin_password2=&show_password=on',
            # basic elements
            'host': host,
            'proto': 'HTTP/1.1',
            'uri': uri,
            'method': method,
        }

        resp, content = self.m_sender.sendRequest(req)

        match = r'location.href="/index.html"'

        rc = re.findall(match, content)
        if len(rc) > 0:
            print 'Login successful !'
            return True
        else:
            match = r'location.href="/loginfailed.html"'
            rc = re.findall(match, content)
            if len(rc) > 0:
                print 'Login Failed !'
                return False
        return True


    def logout(self):
        """
        """
        print '==no Logout'

        return True


    def beforeReqeust(self, Reqs, idx):
        """
        """

        #    'POST /goform/act_ifx_cgi_adsl_wan_config HTTP/1.1'
        #        req1 = Reqs[idx]
        #        request_line = req1['request-line']
        #        if request_line == 'POST /goform/act_ifx_cgi_adsl_wan_config HTTP/1.1':
        #            print '==', 'before request : Next page is advancedsetup_wanipaddress, need to update RuntimeStatus'
        #            self.updateRuntimeStatus()

        idx2 = idx + 1
        if idx2 < len(Reqs):
            req2 = Reqs[idx2]
            request_line = req2['request-line']
            if request_line == 'POST /connect_status.html HTTP/1.1':
                Reqs[idx2]['body-fmt'] = None
                Reqs[idx2]['method'] = 'GET'
                Reqs[idx2]['request-line'] = ''
                Reqs[idx2]['uri'] = '/'

        return True

    def afterReqeust(self, Reqs, idx):
        """
        """
        req = Reqs[idx]
        if req.has_key('resp-headers') and req.has_key('resp-content'):
            resp = req['resp-headers']
            content = req['resp-content']
            idPage = self.parseNextPage(resp, content)

            self.doWaitingPage(req)

        # update Runtime status    http://192.168.0.1/goform/act_ifx_cgi_adsl_wan_config
        idx2 = idx + 1
        if idx2 < len(Reqs):
            req2 = Reqs[idx2]
            uri = req2['uri']
            s = 'act_ifx_cgi_adsl_wan_config'
            res = re.findall(s, uri)
            if len(res):
                print '==', 'after request : Next page is advancedsetup_wanipaddress, need to update RuntimeStatus'
                self.updateRuntimeStatus()
            else:
                s = 'act_set_telnet_setting'
                res = re.findall(s, uri)
                if len(res):
                    print '==', 'after request : Next page is act_set_telnet_setting, need to update OldUsername'
                    self.updateOldUsername()
                else:
                    pass
        return True

    def upgradeFirmware(self, filepath, ver=None):
        """
        """

        print '---' * 32
        host = os.environ.get('TMP_HTTP_HOST')
        if not host:
            host = os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1')
            print 'TMP_HTTP_HOST not defined ! using 192.168.0.1 instead'
        proto = 'http'
        uri = '/utilities_upgradefirmware.html'
        url = proto + '://' + host + uri
        req = {
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
        resp, content = self.m_sender.sendRequest(req)
        print '-->', 'Get upgrade firmware page Done!'

        uri = '/goform/act_check_upgrade'
        fields = {
            'page': 'upgrade_firm_return.htm',
            'filename': open(filepath, 'rb'),
        }
        rc = self.m_sender.uploadFileNew(proto + '://' + host + uri, fields=fields)

        print '-->', 'Check Upgrade File Done!'

        uri = '/goform/act_upgrade'
        fields = {
            'page': 'upgrade_firm_return.htm',
            'filename': open(filepath, 'rb'),
        }
        rc = self.m_sender.uploadFileNew(proto + '://' + host + uri, fields=fields)

        print '-->', 'upload File Done!'

        return rc

    ######################################################


hash_runners = {
    'CAP001-10.0.0k': Runner_VCAP001_10_0_0k,
}

def_runner = 'CAP001-10.0.0k'


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
    
    
    


