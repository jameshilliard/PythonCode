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
    "wep_active"] = 'apply_page=wireless_basic.html%3Fssid%3Dath3&waiting_page=waiting_page.html&waiting_page_leftmenu=2&waiting_page_topmenu=1&wep_active=1&wireless_vap_name=ath3&wireless_enable_type=1&wireless_ssid=SSID4&wireless_multiple_ssid=ath3&wireless_channel=0&wireless_keep_channel=1&wireless_wep_enable_type=0&wep_key_code=0987654321'
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
        # wireless SSIDx
        # match 'wireless_multiple_ssid=ath0'
        ssid_if = body.value('wireless_multiple_ssid')
        idx = int(ssid_if[-1])

        ssid = os.getenv('U_WIRELESS_SSID' + str(idx + 1))
        if ssid:
            body.updateValue('wireless_ssid', ssid)

        wep_active = body.value('wep_active', None)
        if wep_active:
            klen = body.value('wep_key_len', 0)
            if klen == '0':
                wepkey64 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY64bit' + wep_active)
                if wepkey64:
                    body.updateValue('wep_key_code', wepkey64)
            elif klen == '1':
                wepkey128 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY128bit' + wep_active)
                if wepkey128:
                    body.updateValue('wep_key_code', wepkey128)
        return body
