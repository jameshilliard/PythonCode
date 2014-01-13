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
from pprint import pprint
from copy import deepcopy

from PageBase import PageBase


#-----------------------------------------------------------------------
body_fmts = {}

# TODO : add POST body format string map to an unique string (when have multi format string ,the unique string id decided how to match)
body_fmts[
    "wep_mode"] = 'apply_page=wireless_advanced_wep.html%3Fssid%3Dath0&waiting_page=waiting_page.html&waiting_page_leftmenu=3&waiting_page_topmenu=1&wireless_vap_name=ath0&wep_mode=0&radius_server_ip=0.0.0.0&radius_server_port=1812&radius_shared_secret=&wep_auth=0&wep_active=1&wep_key_0_code=0987654321&wep_key_0_mode=0&wep_key_0_len=0&wep_key_1_code=&wep_key_1_mode=0&wep_key_1_len=0&wep_key_2_code=&wep_key_2_mode=0&wep_key_2_len=0&wep_key_3_code=&wep_key_3_mode=0&wep_key_3_len=0'
body_fmts[
    "wireless_security_enabled"] = 'apply_page=wireless_advanced_wpa.html%3Fssid%3Dath0&waiting_page=waiting_page.html&waiting_page_leftmenu=3&waiting_page_topmenu=1&wireless_security_enabled=WPA2&wireless_vap_name=ath0&wpa_sta_auth_type=0&wpa_pre_authentication=1&wpa_sta_auth_shared_key=1234567890&wpa_psk_representation=0&wpa_cipher=0&wpa_is_grp_key_update=0&wpa_grp_key_update_interval=800&radius_server_ip=0.0.0.0&radius_server_port=1812&radius_shared_secret='
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

    # TODO : setup replace mode
    #self.m_isHash = True
    #self.m_replPOST = True
    #self.m_replGET = False

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
        if body.hasKey('wep_mode'):
            wep_active = body.value('wep_active', None)
            if wep_active: # get the active key
                idx = int(wep_active) - 1
                kcode = 'wep_key_' + str(idx) + '_code'
                kmode = 'wep_key_' + str(idx) + '_mode'
                klen = 'wep_key_' + str(idx) + '_len'
                vlen = body.value(klen, None)
                vcode = body.value(kcode, None)
                if vlen and vcode:
                    if vlen == '0': # wep64
                        wepkey64 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY64bit' + wep_active)
                        if wepkey64:
                            body.updateValue(kcode, wepkey64)
                    elif vlen == '1': # wep128
                        wepkey128 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY128bit' + wep_active)
                        if wepkey128:
                            body.updateValue(kcode, wepkey128)
        # WPA
        if body.value('wireless_security_enabled') and body.value('wireless_security_enabled') == 'WPA':
            psk = os.getenv('U_WIRELESS_CUSTOM_WPAPSK')
            if psk:
                body.updateValue('wpa_sta_auth_shared_key', psk)
        # WPA2
        if body.value('wireless_security_enabled') and body.value('wireless_security_enabled') == 'WPA2':
            #logger.debug('here')
            psk = os.getenv('U_WIRELESS_CUSTOM_WPAPSK')
            if psk:
                body.updateValue('wpa_sta_auth_shared_key', psk)
            #pass
        return body

