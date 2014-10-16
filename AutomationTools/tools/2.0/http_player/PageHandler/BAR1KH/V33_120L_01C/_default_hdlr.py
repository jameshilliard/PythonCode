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


    # port forward
    #'' : '',
    # action=add&
    #srvName=aDv_PoRt_FoRwArDiNg&
    'srvAddr': 'G_HOST_TIP0_1_0',
    #'eStart':'U_TR069_DEF_EXTERNAL_PORT',
    #'eEnd':'U_TR069_DEF_EXTERNAL_PORT_END_RANGE',
    #'proto':'1%2C&iStart=5006%2C',
    #'iStart':'U_TR069_DEF_INTERNAL_PORT',
    #'iEnd':'U_TR069_DEF_INTERNAL_PORT',
    #'srvWanAddr':'G_HOST_TIP1_2_0',
    # serCtlTelnet=0&remTelUser=admin&remTelTimeout=0&remTelPassChanged=1&nothankyou=0&remTelPass=QwestM0dem
    'remTelUser': 'U_DUT_TELNET_USER',
    'remTelPass': 'U_DUT_TELNET_PWD',

    #serCtlHttp=1&remoteGuiUserName=admin&remoteGuiPassword=password&remGuiTimeout=900&remGuiPort=443&nothankyou=0
    'remoteGuiUserName': 'U_CUSTOM_REMOTE_GUI_USERNAME',
    'remoteGuiPassword': 'U_CUSTOM_REMOTE_GUI_PASSWORD',
    'sptUserName': 'U_CUSTOM_REMOTE_GUI_USERNAME',
    'sptPassword': 'U_CUSTOM_REMOTE_GUI_PASSWORD',
    'remGuiPort': 'U_CUSTOM_REMOTE_GUI_PORT',
    # tr69 settings
    #
    #'tr69cAcsURL':'http%3A%2F%2Fxatechdmw.xdev.motive.com%2FcwmpWeb%2FCPEMgt&',
    'tr69cAcsUser': 'TMP_DUT_CWMP_CONN_ACS_USERNAME',
    #'tr69cAcsPwd':'&',
    #   tr69cInformEnable=1&
    #   tr69cInformInterval=60&
    #   tr69cPeriodicInformTime=1970-01-01T00%3A04%3A18%2B00%3A00&
    'tr69cConnReqURL': 'TMP_DUT_CWMP_CONN_REQ_URL',
    'tr69cConnReqUser': 'TMP_DUT_CWMP_CONN_REQ_USERNAME',
    #'tr69cConnReqPwd':'&',
    #   tr69cBackoffInterval=&
    #   tr69cDebugEnable=1&
    #   var%3Afrompage=tr69.html
    #MAC
    'wlFltMacAddr_wl0v0': 'U_WIRELESSCARD_MAC',
    'wlFltMacAddr_wl0v1': 'U_WIRELESSCARD_MAC',
    'wlFltMacAddr_wl0v2': 'U_WIRELESSCARD_MAC',
    'wlFltMacAddr_wl0v3': 'U_WIRELESSCARD_MAC',
    'wlFltMacAddr_wl0v4': 'U_WIRELESSCARD_MAC',
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
    print '----------------------------------------------'
    print req
    body = req['body-fmt']
    query = req['query-fmt']
    dut_fw = os.getenv('U_DUT_FW_VERSION')
    print 'DUT Firmware : ' + str(dut_fw)

    # do body repl only
    if body:
        print body.dump()
        print '==', 'common replace BEGIN'
        for (key, val) in common_repl.items():
            if body.hasKey(key):
                #
                val = os.getenv(val)
                if val:
                    print '==', 'update : ', key, '=', val
                    body.updateValue(key, val)
    elif query and dut_fw == '33.00L.28':
        print 'GA release version : 33.00L.28,advancedsetup_remotegui.cgi need replace!'
        print query.dump()
        for (key, val) in common_repl.items():
            if query.hasKey(key):
                #
                val = os.getenv(val)
                if val:
                    print '==', 'update : ', key, '=', val
                    query.updateValue(key, val)

    print '==', 'common replace END'
    return (req, changed)

