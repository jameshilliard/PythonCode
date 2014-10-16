#	   $FILENAME.py
#	   
#	   Copyright 2011 rayofox <lhu@actiontec.com>
#	   
#	   This program is free software; you can redistribute it and/or modify
#	   it under the terms of the GNU General Public License as published by
#	   the Free Software Foundation; either version 2 of the License, or
#	   (at your option) any later version.
#	   
#	   This program is distributed in the hope that it will be useful,
#	   but WITHOUT ANY WARRANTY; without even the implied warranty of
#	   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	   GNU General Public License for more details.
#	   
#	   You should have received a copy of the GNU General Public License
#	   along with this program; if not, write to the Free Software
#	   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#	   MA 02110-1301, USA.
#	   
#	   
"""
This is a template file to create page handle file
"""
#-----------------------------------------------------------------------
import os, sys
import httplib2, urllib
import re
import types
from pprint import pprint
from copy import deepcopy

from PageBase import PageBase

#-----------------------------------------------------------------------
body_fmts = {}

# TODO : add POST body format string map to an unique string (when have multi format string ,the unique string id decided how to match)
body_fmts[
    "frompage=advancedsetup_wanipaddress.html"] = 'page=confirm.html&DIP1=&DIP2=&ATM_PROTOCOL=pppoe&VID=&VPRIO=&wan_mode=ATM&vcSetting=8%2F35&CapMode=0&vlan_id=0&vcChannel=nas0&WT=3&WT1=1&UN=hyin&PW=111111&PWV=111111&MTU=1492&ACN=&wan_mode0=ATM%20%3A%20VC%20-%208%2F35%2C%20VLAN%20%3A%20None&wan_mode1=ATM%20%3A%20VC%20-%208%2F35%2C%20VLAN%20%3A%20None&operation=delete&WAN=0&def_gw=IP0&remove1=1&IDLE=0&submit_action=addVPIVCI&vpivci_status=0&vpivci_value=8%2F35&qs_status=1&QoSMode=0&peakCell=0&vmode=0&vip=0.0.0.0&vmask=0.0.0.0&pppstaticip=&linkType=1&wan_type=WANIP0&def_wan=1&ads_l3=0&PPPOA=0&vc_channel_name=vcc_channel_1&reconnect=&conn=pppoe&ppp_username=hyin&ppp_password=111111&cf_ppp_password=&pppautoconnect=1&nouser=0&host_name=&domain_name=&ipadd=&submask=&gateadd=&wanip=dynamicip&dnstyp=dyndns&frompage=advancedsetup_wanipaddress.html'
#body_fmts[""] = ''
#-----------------------------------------------------------------------
query_fmts = {}

# TODO : add query format string 
#query_fmts[''] = ''
#query_fmts[''] = ''


class Page(PageBase):
    """
    """

    def __init__(self, player, msglvl=2):
        """
        """
        PageBase.__init__(self, player, msglvl)
        self.info('Page ' + os.path.basename(__file__))
        self.addStrFmts(body_fmts, query_fmts)

    ### Need To OverLoad ##########################

    def checkDetail(self, fmt, page_info):
        """
        check difference detail
        """
        # TODO : check detail difference
        pass

    def replQuery(self, query):
        """
        replace query string
        """
        # TODO : Implement your replacement without hash

        pass

    def replBody(self, body):
        """
        replace body string
        """

        TMP_WAN_SETTING_DEF_GW = os.getenv('TMP_WAN_SETTING_DEF_GW', 'NULL_NULL')
        TMP_WAN_SETTING_MODE_WAN = os.getenv('TMP_WAN_SETTING_MODE_WAN', 'NULL_NULL')
        TMP_WAN_SETTING_VPIVCI = os.getenv('TMP_WAN_SETTING_VPIVCI', 'NULL_NULL')

        print ' TMP_WAN_SETTING_DEF_GW -> %s \n TMP_WAN_SETTING_MODE_WAN -> %s \n TMP_WAN_SETTING_VPIVCI -> %s \n' % (
        TMP_WAN_SETTING_DEF_GW, TMP_WAN_SETTING_MODE_WAN, TMP_WAN_SETTING_VPIVCI)

        #print body.fmt()
        if body.value('ATM_PROTOCOL') == 'rfc2684_eoa':
            print '== set WAN connection type to rfc2684_eoa'
            dst_conn_type = 'rfc2684_eoa'
        elif body.value('ATM_PROTOCOL') == 'pppoe':
            print '== set WAN connection type to pppoe'
            dst_conn_type = 'pppoe'

        fmt = body.fmt()

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'vcSetting':
                vcSetting_ori = body.value('vcSetting')

                vcSetting = os.getenv('TMP_WAN_SETTING_VPIVCI', 'NULL_NULL')
                if not vcSetting == 'NULL_NULL':
                    print '== change vcSetting from %s to %s' % (vcSetting_ori, vcSetting)
                    body.updateValueByIndex(index, vcSetting)
                continue

            elif k == 'WT1':
                WT1_ori = body.value('WT1')

                if TMP_WAN_SETTING_MODE_WAN == 'PPP':
                    print '== WAN setting before : ', TMP_WAN_SETTING_MODE_WAN
                    print '== change WT1 from %s to %s' % (WT1_ori, '3')
                    body.updateValueByIndex(index, '3')
                elif TMP_WAN_SETTING_MODE_WAN == 'IP':
                    print '== WAN setting before : ', TMP_WAN_SETTING_MODE_WAN
                    print '== change WT1 from %s to %s' % (WT1_ori, '1')
                    body.updateValueByIndex(index, '1')
                continue

            elif k == 'UN':
                UN_ori = body.value('UN')

                if dst_conn_type == 'pppoe':
                    UN = os.getenv('U_DUT_CUSTOM_PPP_USER', 'aliu')
                    print '== change UN from %s to %s' % (UN_ori, UN)
                    body.updateValueByIndex(index, UN)
                continue

            elif k == 'PW':
                PW_ori = body.value('PW')

                if dst_conn_type == 'pppoe':
                    PW = os.getenv('U_DUT_CUSTOM_PPP_PWD', '111111')
                    print '== change PW from %s to %s' % (PW_ori, PW)
                    body.updateValueByIndex(index, PW)
                continue

            elif k == 'PWV':
                PWV_ori = body.value('PWV')

                if dst_conn_type == 'pppoe':
                    PWV = os.getenv('U_DUT_CUSTOM_PPP_PWD', '111111')
                    print '== change PWV from %s to %s' % (PWV_ori, PWV)
                    body.updateValueByIndex(index, PWV)
                continue

            elif k == 'wan_mode0':
                wan_mode0_ori = body.value('wan_mode0')

                wan_mode0s = wan_mode0_ori.split(':')
                wan_mode0 = wan_mode0s[0] + ':' + ' VC - ' + vcSetting + ', VLAN ' + ':' + wan_mode0s[2]

                print '== change wan_mode0 from %s to %s' % (wan_mode0_ori, wan_mode0)
                body.updateValueByIndex(index, wan_mode0)

                continue

            elif k == 'wan_mode1':
                wan_mode1_ori = body.value('wan_mode1')

                wan_mode1s = wan_mode1_ori.split(':')
                wan_mode1 = wan_mode1s[0] + ':' + ' VC - ' + vcSetting + ', VLAN ' + ':' + wan_mode1s[2]

                print '== change wan_mode1 from %s to %s' % (wan_mode1_ori, wan_mode1)
                body.updateValueByIndex(index, wan_mode1)

                continue

            elif k == 'WAN':
                WAN_ori = body.value('WAN')

                if TMP_WAN_SETTING_MODE_WAN == 'PPP':
                    WAN = '1'
                elif TMP_WAN_SETTING_MODE_WAN == 'IP' or TMP_WAN_SETTING_MODE_WAN == 'WANIP0':
                    WAN = '0'
                print '== change WAN from %s to %s' % (WAN_ori, WAN)

                body.updateValueByIndex(index, WAN)
                continue

            elif k == 'def_gw':
                def_gw_ori = body.value('def_gw')

                if TMP_WAN_SETTING_MODE_WAN == 'PPP':
                    def_gw = 'PPP1'
                elif TMP_WAN_SETTING_MODE_WAN == 'IP' or TMP_WAN_SETTING_MODE_WAN == 'WANIP0':
                    def_gw = 'IP0'
                print '== change def_gw from %s to %s' % (def_gw_ori, def_gw)

                body.updateValueByIndex(index, def_gw)
                continue

            elif k == 'vpivci_value':
                vpivci_value_ori = body.value('vpivci_value')

                vpivci_value = os.getenv('TMP_WAN_SETTING_VPIVCI', 'NULL_NULL')
                if not vpivci_value == 'NULL_NULL':
                    print '== change vpivci_value from %s to %s' % (vpivci_value_ori, vpivci_value)
                    body.updateValueByIndex(index, vpivci_value)
                continue

            elif k == 'wan_type':
                wan_type_ori = body.value('wan_type')

                if TMP_WAN_SETTING_MODE_WAN == 'PPP':
                    wan_type = 'WANPPP1'
                elif TMP_WAN_SETTING_MODE_WAN == 'IP' or TMP_WAN_SETTING_MODE_WAN == 'WANIP0':
                    wan_type = 'WANIP0'
                print '== change wan_type from %s to %s' % (wan_type_ori, wan_type)

                body.updateValueByIndex(index, wan_type)
                continue

            #			elif k == 'conn' :
            #				conn_ori = body.value('conn')
            #
            #				if dst_conn_type == 'pppoe':
            #					conn = 'pppoe'
            #				elif dst_conn_type == 'rfc2684_eoa':
            #					conn = 'dhcpc'
            #
            #				print '== change conn from %s to %s' % (conn_ori, conn)
            #				body.updateValueByIndex(index, conn)
            #				continue

            elif k == 'ppp_username':
                ppp_username_ori = body.value('ppp_username')

                if dst_conn_type == 'pppoe':
                    ppp_username = os.getenv('U_DUT_CUSTOM_PPP_USER', 'aliu')

                    print '== change ppp_username from %s to %s' % (ppp_username_ori, ppp_username)
                    body.updateValueByIndex(index, ppp_username)
                continue

            elif k == 'ppp_password':
                ppp_password_ori = body.value('ppp_password')

                if dst_conn_type == 'pppoe':
                    ppp_password = os.getenv('U_DUT_CUSTOM_PPP_PWD', '111111')

                    print '== change ppp_password from %s to %s' % (ppp_password_ori, ppp_password)
                    body.updateValueByIndex(index, ppp_password)
                continue

            elif k == 'show_password':
                show_password_ori = body.value('show_password')

                if dst_conn_type == 'pppoe':
                    print '== change from  %s : %s to %s : %s' % (k, show_password_ori, 'pppautoconnect', '1')
                    body.updateKeyAndValue(k, 'pppautoconnect', '1')
                continue

            elif k == 'pppautoconnect':
                pppautoconnect_ori = body.value('pppautoconnect')

                if dst_conn_type == 'rfc2684_eoa':
                    print '== change from  %s : %s to %s : %s' % (k, pppautoconnect_ori, 'show_password', 'on')
                    body.updateKeyAndValue(k, 'show_password', 'on')
                continue

            elif k == 'IP' or k == 'ipadd':
                ev = os.getenv('TMP_DUT_WAN_IP')
                print 'INFO : TMP_DUT_WAN_IP ', ev
                if ev:
                    if str(v) != '':
                        v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'NM' or k == 'submask':
                ev = os.getenv('TMP_DUT_WAN_MASK')
                if ev:
                    if str(v) != '':
                        v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'GIP' or k == 'gateadd':
                ev = os.getenv('TMP_DUT_DEF_GW')
                if ev:
                    if str(v) != '':
                        v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'DIP1' or k == 'primarydns':
            #				is_dhcp = body.value('enblDhcpClnt')
            #				if is_dhcp == '0' :
                ev = os.getenv('TMP_DUT_WAN_DNS_1')
                if ev:
                    if str(v) != '':
                        v = ev
                body.updateValueByIndex(index, v)

                continue
            elif k == 'DIP2' or k == 'secdns':
                #is_dhcp = body.value('enblDhcpClnt')
                #if is_dhcp == '0' :
                ev = os.getenv('TMP_DUT_WAN_DNS_2')
                if ev:
                    if str(v) != '':
                        v = ev
                body.updateValueByIndex(index, v)

                continue

            TMP_DUT_WAN_IP = os.getenv('TMP_DUT_WAN_IP')
            if TMP_DUT_WAN_IP:
                IP1 = TMP_DUT_WAN_IP.split('.')[0]
                IP2 = TMP_DUT_WAN_IP.split('.')[1]
                IP3 = TMP_DUT_WAN_IP.split('.')[2]
                IP4 = TMP_DUT_WAN_IP.split('.')[3]

                #print '%s %s %s %s ' % (IP1, IP2, IP3, IP4)

                if k == 'IP1':
                    v = IP1
                    body.updateValueByIndex(index, v)
                    #print 'updating IP1'
                    continue

                if k == 'IP2':
                    v = IP2
                    body.updateValueByIndex(index, v)
                    #print 'updating IP2'
                    continue

                if k == 'IP3':
                    v = IP3
                    body.updateValueByIndex(index, v)
                    #print 'updating IP3'
                    continue

                if k == 'IP4':
                    v = IP4
                    body.updateValueByIndex(index, v)
                    #print 'updating IP4'
                    continue

            TMP_DUT_DEF_GW = os.getenv('TMP_DUT_DEF_GW')
            if TMP_DUT_DEF_GW:
                GIP1 = TMP_DUT_DEF_GW.split('.')[0]
                GIP2 = TMP_DUT_DEF_GW.split('.')[1]
                GIP3 = TMP_DUT_DEF_GW.split('.')[2]
                GIP4 = TMP_DUT_DEF_GW.split('.')[3]

                if k == 'GIP1':
                    v = GIP1
                    body.updateValueByIndex(index, v)
                    continue

                if k == 'GIP2':
                    v = GIP2
                    body.updateValueByIndex(index, v)
                    continue

                if k == 'GIP3':
                    v = GIP3
                    body.updateValueByIndex(index, v)
                    continue

                if k == 'GIP4':
                    v = GIP4
                    body.updateValueByIndex(index, v)
                    continue

            TMP_DUT_WAN_MASK = os.getenv('TMP_DUT_WAN_MASK')
            if TMP_DUT_WAN_MASK:
                NM1 = TMP_DUT_WAN_MASK.split('.')[0]
                NM2 = TMP_DUT_WAN_MASK.split('.')[1]
                NM3 = TMP_DUT_WAN_MASK.split('.')[2]
                NM4 = TMP_DUT_WAN_MASK.split('.')[3]

                if k == 'NM1':
                    v = NM1
                    body.updateValueByIndex(index, v)
                    continue

                if k == 'NM2':
                    v = NM2
                    body.updateValueByIndex(index, v)
                    continue

                if k == 'NM3':
                    v = NM3
                    body.updateValueByIndex(index, v)
                    continue

                if k == 'NM4':
                    v = NM4
                    body.updateValueByIndex(index, v)
                    continue


                #IP=172.19.106.127      | DIP1=168.95.1.1       |  IP1=172  |   NM1=255 |    GIP1=172
                #NM=255.255.255.0       | DIP2=10.20.10.10      |  IP2=19   |   NM2=255 |    GIP2=19
                #GIP=172.19.106.254     | primarydns=168.95.1.1 |  IP3=106  |   NM3=255 |    GIP3=106
                #ipadd=172.19.106.127   | secdns=10.20.10.10    |  IP4=127  |   NM4=0   |    GIP4=254
                #submask=255.255.255.0  |                       |           |           |
                #gateadd=172.19.106.254
                #######################|#######################|###########|###########|############

        #exit(0)

        return body


	
	
	
	
