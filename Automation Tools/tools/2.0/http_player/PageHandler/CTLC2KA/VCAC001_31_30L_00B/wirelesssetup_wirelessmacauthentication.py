#       $FILENAME.py
#       
#       Copyright 2011 rayofox <lhu@actiontec.com>
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
    "wlWep_wl0v0=enabled"] = 'wlDefaultKeyFlagWep64Bit=1&wlDefaultKeyFlagWep128Bit=1&wlDefaultKeyWep64Bit=F5FEF3F5FF&wlDefaultKeyWep128Bit=fff4ea78fffaef79fd2efa2e7d&wlDefaultKeyWep128Bit=fff4ea76fffaef78fd2ef92e7f&wlDefaultKeyWep128Bit=fff4ea74fffaef77fd2ef92e8e&wlDefaultKeyWep128Bit=fff4ea72fffaef76fd2ef82e83&wlKeyBit_wl0v0=2&wlKeyIndex_wl0v0=1&wlKeyIndex_wl0v0=1&wlKey1_128_wl0v0=fff4ea78fffaef79fd2efa2e7d&wlAuthMode_wl0v0=open&wlWep_wl0v0=enabled&wlDefaultKeyFlagPsk=15&wlDefaultKeyPsk0=12345678&wlDefaultKeyPsk1=12345678&wlDefaultKeyPsk2=12345678&wlDefaultKeyPsk3=12345678&needthankyou=1'
body_fmts[
    "wlWep_wl0v0=disabled"] = 'wlDefaultKeyFlagWep64Bit=1&wlDefaultKeyFlagWep128Bit=1&wlDefaultKeyWep64Bit=F5FEF3F5FF&wlDefaultKeyWep128Bit=fff4ea78fffaef79fd2efa2e7d&wlDefaultKeyWep128Bit=fff4ea76fffaef78fd2ef92e7f&wlDefaultKeyWep128Bit=fff4ea74fffaef77fd2ef92e8e&wlDefaultKeyWep128Bit=fff4ea72fffaef76fd2ef82e83&wlKeyBit_wl0v0=0&wlAuthMode_wl0v0=psk+psk2&wlWep_wl0v0=disabled&wlWpaPsk_wl0v0=12345678&wlWpa_wl0v0=tkip%2Baes&wlDefaultKeyFlagPsk=15&wlDefaultKeyPsk0=12345678&wlDefaultKeyPsk1=12345678&wlDefaultKeyPsk2=12345678&wlDefaultKeyPsk3=12345678&needthankyou=1'
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
        # TODO : Implement your hash replacement
        # 1. get default wep and psk flag
        # 2. replace default wep 128 (duplicate key name)

        #		wlSsid_wl0v4	CenturyLink000A|CenturyLink000B|CenturyLink000C|CenturyLink000D
        #		wlFltMacMode_wl0v4	deny
        #		wlFltMacAddr_wl0v4	14:E6:E4:0D:AB:FF
        #		action	add
        #		wlSsidIdx	4
        #		needthankyou	1
        ssid1 = os.getenv('U_WIRELESS_SSID1')
        ssid2 = os.getenv('U_WIRELESS_SSID2')
        ssid3 = os.getenv('U_WIRELESS_SSID3')
        ssid4 = os.getenv('U_WIRELESS_SSID4')

        all_ssid = ssid1 + '|' + ssid2 + '|' + ssid3 + '|' + ssid4
        print 'all ssid : ', all_ssid
        fmt = body.fmt()

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'wlSsid_wl0v4':
                ev = all_ssid
                if ev:   v = ev
                body.updateValueByIndex(index, v)
                continue

        return body


	
	
	
	
