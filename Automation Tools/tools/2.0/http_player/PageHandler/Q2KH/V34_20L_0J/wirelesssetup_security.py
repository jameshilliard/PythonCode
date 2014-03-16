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
    "wlDefaultKeyFlagWep64Bit"] = 'wlDefaultKeyFlagWep64Bit=1&wlDefaultKeyFlagWep128Bit=0&wlDefaultKeyWep64Bit=FFA8FFFFA9&wlDefaultKeyWep128Bit=ffc5aa8bff82dfc8ce7a667f7e&wlDefaultKeyWep128Bit=ffc5aa89ff82dfc7ce7a667f8c&wlDefaultKeyWep128Bit=ffc5aa87ff82dfc6ce7a657f82&wlDefaultKeyWep128Bit=ffc5aa85ff82dfc5ce7a657f84&wlKeyBit_wl0v0=1&wlKeyIndex_wl0v0=1&wlKeyIndex_wl0v0=1&wlKey1_64_wl0v0=1234567890&wlAuthMode_wl0v0=open&wlWep_wl0v0=enabled&wlDefaultKeyFlagPsk=15&wlDefaultKeyPsk0=87e14477bb00c0e415dbeb1cb2&wlDefaultKeyPsk1=87e14477bb00c0e415dbeb1cb2&wlDefaultKeyPsk2=87e14477bb00c0e415dbeb1cb2&wlDefaultKeyPsk3=87e14477bb00c0e415dbeb1cb2&needthankyou=1'
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
        # TODO : Implement your hash replacement
        # 1. get default wep and psk flag
        # 2. replace default wep 128 (duplicate key name)
        wep_flag = None
        wpa_flag = None
        idx_def_wep128 = 0
        i = 0
        fmt = body.fmt()

        #print '---fmt---'*12
        #pprint(fmt)
        #print '---fmt---'*12

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'wlDefaultKeyFlagWep128Bit':
                wep_flag = int(v)
                continue
            if k == 'wlDefaultKeyFlagPsk':
                wpa_flag = int(v)
                continue
            if k == 'wlDefaultKeyWep128Bit':
                idx_def_wep128 += 1
                ek = 'U_WIRELESS_WEPKEY' + str(idx_def_wep128)
                ev = os.getenv(ek)
                if ev:   v = ev
                body.updateValueByIndex(index, v)
                continue

        #print '-wep_flag:-'*12
        #print wep_flag

        #print '-wpa_flag:-'*12
        #print wpa_flag
        # 3. using default overwrite custom
        for index, k in enumerate(fmt['keys']):
            #print '-wep_flag:-'*6
            #print wep_flag

            #print '-wpa_flag:-'*6
            #print wpa_flag
            #print '-index : -'*6
            #print index
            #print '-k : -'*6
            #print k
            v = fmt['vals'][index]
            #print '-v : -'*6
            #print v
            if wep_flag:
                r = re.findall('wlKey(\d)_128_wl0v(\d)', k)
                #print '==>',k
                #print '==>',r
                if len(r) > 0:
                    (cus_idx, ssid_idx) = r[0]
                    if (wep_flag & (1 << int(ssid_idx) ) ):
                    # using default overwirte custom
                        ek = 'U_WIRELESS_WEPKEY' + str(int(ssid_idx) + 1)
                        ev = os.getenv(ek)
                        #print '==>',ek,ev
                        if ev: v = ev
                        body.updateValueByIndex(index, v)
                    #continue
            if wpa_flag:
                r = re.findall('wlWpaPsk_wl0v(\d)', k)
                #print '-r:-'*12
                #print r
                if len(r) > 0:
                    ssid_idx = r[0]
                    if (wpa_flag & (1 << int(ssid_idx)) ):
                        # using default overwirte custom
                        ek = 'U_WIRELESS_WPAPSK' + str(int(ssid_idx) + 1)
                        ev = os.getenv(ek)
                        if ev:  v = ev
                        body.updateValueByIndex(index, v)
                continue

        return body


	
	
	
	
