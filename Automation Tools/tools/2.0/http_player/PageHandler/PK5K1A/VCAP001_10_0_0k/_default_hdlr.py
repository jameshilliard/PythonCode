#       wireless_basic.py
#       
#       Copyright 2011 rayofox <rayofox@rayofox-test>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#       
#       

import os, sys
import httplib2, urllib
import re
import types


"""

"""

common_repl = {

    # wireless SSID
    'wlSsid_wl0v0': 'U_WIRELESS_SSID1',
    'wlSsid_wl0v1': 'U_WIRELESS_SSID2',
    'wlSsid_wl0v2': 'U_WIRELESS_SSID3',
    'wlSsid_wl0v3': 'U_WIRELESS_SSID4',

    #########################################################
    # default WEP KEY 64 bit
    'wlDefaultKeyWep64Bit': 'U_WIRELESS_WEPKEY_DEF_64',

    #########################################################
    # default WEP KEY 128 bit
    # special replace rule

    #########################################################
    # custom WEP KEY 64 bit
    # 1st for all SSID (the same value)
    'wlKey1_64_wl0v0': 'U_WIRELESS_CUSTOM_WEP_KEY64bit1',
    'wlKey1_64_wl0v1': 'U_WIRELESS_CUSTOM_WEP_KEY64bit1',
    'wlKey1_64_wl0v2': 'U_WIRELESS_CUSTOM_WEP_KEY64bit1',
    'wlKey1_64_wl0v3': 'U_WIRELESS_CUSTOM_WEP_KEY64bit1',

    # 2nd for all SSID (the same value)
    'wlKey2_64_wl0v0': 'U_WIRELESS_CUSTOM_WEP_KEY64bit2',
    'wlKey2_64_wl0v1': 'U_WIRELESS_CUSTOM_WEP_KEY64bit2',
    'wlKey2_64_wl0v2': 'U_WIRELESS_CUSTOM_WEP_KEY64bit2',
    'wlKey2_64_wl0v3': 'U_WIRELESS_CUSTOM_WEP_KEY64bit2',

    # 3rd for all SSID (the same value)
    'wlKey3_64_wl0v0': 'U_WIRELESS_CUSTOM_WEP_KEY64bit3',
    'wlKey3_64_wl0v1': 'U_WIRELESS_CUSTOM_WEP_KEY64bit3',
    'wlKey3_64_wl0v2': 'U_WIRELESS_CUSTOM_WEP_KEY64bit3',
    'wlKey3_64_wl0v3': 'U_WIRELESS_CUSTOM_WEP_KEY64bit3',

    # 4th for all SSID (the same value)
    'wlKey4_64_wl0v0': 'U_WIRELESS_CUSTOM_WEP_KEY64bit4',
    'wlKey4_64_wl0v1': 'U_WIRELESS_CUSTOM_WEP_KEY64bit4',
    'wlKey4_64_wl0v2': 'U_WIRELESS_CUSTOM_WEP_KEY64bit4',
    'wlKey4_64_wl0v3': 'U_WIRELESS_CUSTOM_WEP_KEY64bit4',

    #########################################################
    # custom WEP KEY 128 bit
    # 1st for all SSID (the same value)
    'wlKey1_128_wl0v0': 'U_WIRELESS_CUSTOM_WEP_KEY128bit1',
    'wlKey1_128_wl0v1': 'U_WIRELESS_CUSTOM_WEP_KEY128bit1',
    'wlKey1_128_wl0v2': 'U_WIRELESS_CUSTOM_WEP_KEY128bit1',
    'wlKey1_128_wl0v3': 'U_WIRELESS_CUSTOM_WEP_KEY128bit1',

    # 2nd for all SSID (the same value)
    'wlKey2_128_wl0v0': 'U_WIRELESS_CUSTOM_WEP_KEY128bit2',
    'wlKey2_128_wl0v1': 'U_WIRELESS_CUSTOM_WEP_KEY128bit2',
    'wlKey2_128_wl0v2': 'U_WIRELESS_CUSTOM_WEP_KEY128bit2',
    'wlKey2_128_wl0v3': 'U_WIRELESS_CUSTOM_WEP_KEY128bit2',

    # 3rd for all SSID (the same value)
    'wlKey3_128_wl0v0': 'U_WIRELESS_CUSTOM_WEP_KEY128bit3',
    'wlKey3_128_wl0v1': 'U_WIRELESS_CUSTOM_WEP_KEY128bit3',
    'wlKey3_128_wl0v2': 'U_WIRELESS_CUSTOM_WEP_KEY128bit3',
    'wlKey3_128_wl0v3': 'U_WIRELESS_CUSTOM_WEP_KEY128bit3',

    # 4th for all SSID (the same value)
    'wlKey4_128_wl0v0': 'U_WIRELESS_CUSTOM_WEP_KEY128bit4',
    'wlKey4_128_wl0v1': 'U_WIRELESS_CUSTOM_WEP_KEY128bit4',
    'wlKey4_128_wl0v2': 'U_WIRELESS_CUSTOM_WEP_KEY128bit4',
    'wlKey4_128_wl0v3': 'U_WIRELESS_CUSTOM_WEP_KEY128bit4',


    #########################################################
    # default WPA PSK
    'wlDefaultKeyPsk0': 'U_WIRELESS_WPAPSK1',
    'wlDefaultKeyPsk1': 'U_WIRELESS_WPAPSK2',
    'wlDefaultKeyPsk2': 'U_WIRELESS_WPAPSK3',
    'wlDefaultKeyPsk3': 'U_WIRELESS_WPAPSK4',

    #########################################################
    # custom WPA PSK
    # using the same value
    'wlWpaPsk_wl0v0': 'U_WIRELESS_CUSTOM_WPAPSK',
    'wlWpaPsk_wl0v1': 'U_WIRELESS_CUSTOM_WPAPSK',
    'wlWpaPsk_wl0v2': 'U_WIRELESS_CUSTOM_WPAPSK',
    'wlWpaPsk_wl0v3': 'U_WIRELESS_CUSTOM_WPAPSK',
    #########################################################
    # wireless 802.1X
    # radius server for all SSID (the same value)
    'wlRadiusServerIP_wl0v0': 'U_WIRELESS_RADIUS_SERVER',
    'wlRadiusServerIP_wl0v1': 'U_WIRELESS_RADIUS_SERVER',
    'wlRadiusServerIP_wl0v2': 'U_WIRELESS_RADIUS_SERVER',
    'wlRadiusServerIP_wl0v3': 'U_WIRELESS_RADIUS_SERVER',

    # radius server key
    'wlRadiusKey_wl0v0': 'U_WIRELESS_RADIUS_KEY',
    'wlRadiusKey_wl0v1': 'U_WIRELESS_RADIUS_KEY',
    'wlRadiusKey_wl0v2': 'U_WIRELESS_RADIUS_KEY',
    'wlRadiusKey_wl0v3': 'U_WIRELESS_RADIUS_KEY',

    # ppp
    'pppUserName': 'U_DUT_CUSTOM_PPP_USER',
    'pppPassword': 'U_DUT_CUSTOM_PPP_PWD',

    # vci/vpi for ADSL
    'atmVpi': 'U_DUT_CUSTOM_VPI',
    'atmVci': 'U_DUT_CUSTOM_VCI',

    # runtime wan interface
    'wanInf': 'TMP_CUSTOM_WANINF',
    'wanIfName': 'TMP_CUSTOM_WANINF',
    # DHCP setting
    #'SysIP' : 'U_DUT_CUSTOM_LAN_IP',
    #'DhcpsStartIP' : 'U_DUT_CUSTOM_LAN_MIN_ADDRESS',
    #'DhcpsEndIP' : 'U_DUT_CUSTOM_LAN_MAX_ADDRESS',
    #'SysMASK' : 'U_DUT_CUSTOM_LAN_NETMASK',
    #'DnsPrimary' : 'U_DUT_CUSTOM_LAN_DNS_1',
    #'DnsSecondary' : 'U_DUT_CUSTOM_LAN_DNS_2',
    #'LeaseTime' : 'TMP_CURR_LEASE_TIME',
    #DHCP Reservation
    'mac': 'G_HOST_MAC0_1_0',
    'static_ip': 'U_CUSTOM_LAN_DHCP_RESERVED_IP',
    'mac_address_manual': 'G_HOST_MAC0_1_0',
    'ip': 'U_CUSTOM_LAN_DHCP_RESERVED_IP',

    ##	MAC authentication
    #'wlFltMacAddr_wl0v0':'U_WIRELESSCARD_MAC',
    #'wlFltMacAddr_wl0v1':'U_WIRELESSCARD_MAC',
    #'wlFltMacAddr_wl0v2':'U_WIRELESSCARD_MAC',
    #'wlFltMacAddr_wl0v3':'U_WIRELESSCARD_MAC',

    #telnet
    #page	confirm.html
    #frompage	advancedsetup_remotetelnet.html
    #TELNET_WAN_ENABLE	1


    #userOldname	admin
    #telTimeout	-1

    # port forward
    #'' : '',
    #	tr69
    #'ACS_UserName':'TMP_DUT_CWMP_CONN_ACS_USERNAME',
    #'tr69cConnReqURL':'TMP_DUT_CWMP_CONN_REQ_URL',
    #'tr69cConnReqUser':'TMP_DUT_CWMP_CONN_REQ_USERNAME',
}


def check(req, page_info):
    """
    Not Support
    """
    return


def replace(req):
    """
    """
    changed = False
    #
    body = req['body-fmt']
    query = req['query-fmt']
    # do body repl only
    if body:
        print '==', 'common replace BEGIN'
        for (key, val) in common_repl.items():
            if body.hasKey(key):
                #
                val = os.getenv(val)
                if val:
                    print '==', 'update : ', key, '=', val
                    body.updateValue(key, val)

    print '==', 'common replace END'
    return (req, changed)

