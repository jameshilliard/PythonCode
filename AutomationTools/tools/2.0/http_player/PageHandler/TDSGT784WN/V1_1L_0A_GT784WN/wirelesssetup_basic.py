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
    "wlRadio"] = 'wlRadio=1&globalSessionKey=s%40zEo4NgNM%7C7t3c&wlSsid_wl0v0=TDSV1000W0008&wlHide_wl0v0=0&wlAuthMode_wl0v0=psk&wlWep_wl0v0=disabled&wlWpaPsk_wl0v0=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlWpa_wl0v0=aes&wlKeyBit_wl0v0=0&wlKeyIndex_wl0v0=1&wlKeyIndex_wl0v0=1&wlKey1_64_wl0v0=FFF7FFFFF7&wlKey1_128_wl0v0=ffa5f878ccea4ccc5464e4e997&wlKey2_64_wl0v0=FFF6FFFFF6&wlKey2_128_wl0v0=000000900FFF6FFFFF64967286&wlKey3_64_wl0v0=FFF5FFFFF5&wlKey3_128_wl0v0=000001000FFF5FFFFF54967285&wlKey4_64_wl0v0=FFF4FFFFF4&wlKey4_128_wl0v0=000001100FFF4FFFFF44967284&wlSsid_wl0v1=TDSV1000W0009&wlEnbl_wl0v1=0&wlHide_wl0v1=0&wlKeyBit_wl0v1=0&wlKeyIndex_wl0v1=1&wlKeyIndex_wl0v1=1&wlKey1_64_wl0v1=1234567890&wlKey1_128_wl0v1=12345678901234567890123456&wlKey2_64_wl0v1=1234567890&wlKey2_128_wl0v1=12345678901234567890123456&wlKey3_64_wl0v1=1234567890&wlKey3_128_wl0v1=12345678901234567890123456&wlKey4_64_wl0v1=1234567890&wlKey4_128_wl0v1=12345678901234567890123456&wlSsid_wl0v2=TDSV1000W000A&wlEnbl_wl0v2=0&wlHide_wl0v2=0&wlKeyBit_wl0v2=0&wlKeyIndex_wl0v2=1&wlKeyIndex_wl0v2=1&wlKey1_64_wl0v2=1234567890&wlKey1_228_wl0v2=&wlKey2_64_wl0v2=1234567890&wlKey2_228_wl0v2=&wlKey3_64_wl0v2=1234567890&wlKey3_228_wl0v2=&wlKey4_64_wl0v2=1234567890&wlKey4_228_wl0v2=&wlDefaultKeyFlagPsk=15&wlDefaultKeyPsk0=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyPsk1=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyPsk2=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyPsk3=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyFlagWep64Bit=1&wlDefaultKeyFlagWep128Bit=1&wlDefaultKeyWep64Bit=FFF7FFFFF7&wlDefaultKeyWep128Bit=ffa5f878ccea4ccc5464e4e997&wlDefaultKeyWep128Bit=ffa5f876ccea4cbf5464e3e999&wlDefaultKeyWep128Bit=ffa5f874ccea4cbe5464e3e99b&wlDefaultKeyWep128Bit=ffa5f872ccea4cbd5464e2e99d&needthankyou=1'
body_fmts[
    "wlRadiusServerIP"] = 'wlRadio=1&globalSessionKey=s%40zEo4NgNM%7C7t3c&wlSsid_wl0v0=TDSV1000W0008&wlHide_wl0v0=0&wlAuthMode_wl0v0=psk&wlWep_wl0v0=disabled&wlWpaPsk_wl0v0=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlWpa_wl0v0=aes&wlKeyBit_wl0v0=0&wlKeyIndex_wl0v0=1&wlKeyIndex_wl0v0=1&wlKey1_64_wl0v0=FFF7FFFFF7&wlKey1_128_wl0v0=ffa5f878ccea4ccc5464e4e997&wlKey2_64_wl0v0=FFF6FFFFF6&wlKey2_128_wl0v0=000000900FFF6FFFFF64967286&wlKey3_64_wl0v0=FFF5FFFFF5&wlKey3_128_wl0v0=000001000FFF5FFFFF54967285&wlKey4_64_wl0v0=FFF4FFFFF4&wlKey4_128_wl0v0=000001100FFF4FFFFF44967284&wlSsid_wl0v1=TDSV1000W0009&wlEnbl_wl0v1=0&wlHide_wl0v1=0&wlKeyBit_wl0v1=0&wlKeyIndex_wl0v1=1&wlKeyIndex_wl0v1=1&wlKey1_64_wl0v1=1234567890&wlKey1_128_wl0v1=12345678901234567890123456&wlKey2_64_wl0v1=1234567890&wlKey2_128_wl0v1=12345678901234567890123456&wlKey3_64_wl0v1=1234567890&wlKey3_128_wl0v1=12345678901234567890123456&wlKey4_64_wl0v1=1234567890&wlKey4_128_wl0v1=12345678901234567890123456&wlSsid_wl0v2=TDSV1000W000A&wlEnbl_wl0v2=0&wlHide_wl0v2=0&wlKeyBit_wl0v2=0&wlKeyIndex_wl0v2=1&wlKeyIndex_wl0v2=1&wlKey1_64_wl0v2=1234567890&wlKey1_228_wl0v2=&wlKey2_64_wl0v2=1234567890&wlKey2_228_wl0v2=&wlKey3_64_wl0v2=1234567890&wlKey3_228_wl0v2=&wlKey4_64_wl0v2=1234567890&wlKey4_228_wl0v2=&wlDefaultKeyFlagPsk=15&wlDefaultKeyPsk0=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyPsk1=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyPsk2=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyPsk3=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyFlagWep64Bit=1&wlDefaultKeyFlagWep128Bit=1&wlDefaultKeyWep64Bit=FFF7FFFFF7&wlDefaultKeyWep128Bit=ffa5f878ccea4ccc5464e4e997&wlDefaultKeyWep128Bit=ffa5f876ccea4cbf5464e3e999&wlDefaultKeyWep128Bit=ffa5f874ccea4cbe5464e3e99b&wlDefaultKeyWep128Bit=ffa5f872ccea4cbd5464e2e99d&needthankyou=1'
#body_fmts[""] = ''
#-----------------------------------------------------------------------
query_fmts = {}

# TODO : add query format string 
query_fmts[
    'wlRadio'] = 'wlRadio=1&globalSessionKey=s-RxP%3C1Io9q1z9Y&wlSsid_wl0v0=TDSV1000W0008&wlHide_wl0v0=0&wlAuthMode_wl0v0=open&wlWep_wl0v0=enabled&wlWpaGtkRekey_wl0v0=3600&wlWpaPsk_wl0v0=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlWpa_wl0v0=aes&wlKeyBit_wl0v0=2&wlKeyIndex_wl0v0=1&wlKeyIndex_wl0v0=1&wlKey1_128_wl0v0=ffa5f878ccea4ccc5464e4e997&wlKey2_128_wl0v0=000000900FFF6FFFFF64967286&wlKey3_128_wl0v0=000001000FFF5FFFFF54967285&wlKey4_128_wl0v0=000001100FFF4FFFFF44967284&wlRadiusServerIP_wl0v0=0.0.0.0&wlRadiusPort_wl0v0=1812&wlRadiusKey_wl0v0=&wlSsid_wl0v1=TDSV1000W0009&wlEnbl_wl0v1=0&wlHide_wl0v1=0&wlAuthMode_wl0v1=psk+psk2&wlWep_wl0v1=disabled&wlWpaGtkRekey_wl0v1=3600&wlWpaPsk_wl0v1=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlWpa_wl0v1=tkip%2Baes&wlKeyBit_wl0v1=0&wlKeyIndex_wl0v1=1&wlKeyIndex_wl0v1=1&wlKey1_64_wl0v1=1234567890&wlKey1_128_wl0v1=12345678901234567890123456&wlKey2_64_wl0v1=1234567890&wlKey2_128_wl0v1=12345678901234567890123456&wlKey3_64_wl0v1=1234567890&wlKey3_128_wl0v1=12345678901234567890123456&wlKey4_64_wl0v1=1234567890&wlKey4_128_wl0v1=12345678901234567890123456&wlRadiusServerIP_wl0v1=0.0.0.0&wlRadiusPort_wl0v1=1812&wlRadiusKey_wl0v1=&wlSsid_wl0v2=TDSV1000W000A&wlEnbl_wl0v2=0&wlHide_wl0v2=0&wlAuthMode_wl0v2=psk+psk2&wlWep_wl0v2=disabled&wlWpaGtkRekey_wl0v2=3600&wlWpaPsk_wl0v2=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlWpa_wl0v2=tkip%2Baes&wlKeyBit_wl0v2=0&wlKeyIndex_wl0v2=1&wlKeyIndex_wl0v2=1&wlKey1_64_wl0v2=1234567890&wlKey1_228_wl0v2=&wlKey2_64_wl0v2=1234567890&wlKey2_228_wl0v2=&wlKey3_64_wl0v2=1234567890&wlKey3_228_wl0v2=&wlKey4_64_wl0v2=1234567890&wlKey4_228_wl0v2=&wlRadiusServerIP_wl0v2=0.0.0.0&wlRadiusPort_wl0v2=1812&wlRadiusKey_wl0v2=&wlDefaultKeyFlagPsk=15&wlDefaultKeyPsk0=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyPsk1=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyPsk2=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyPsk3=%FF%FF%FF%FF%FF%FF23S5W24GD3T67GKM&wlDefaultKeyFlagWep64Bit=1&wlDefaultKeyFlagWep128Bit=1&wlDefaultKeyWep64Bit=FFF7FFFFF7&wlDefaultKeyWep128Bit=ffa5f878ccea4ccc5464e4e997&wlDefaultKeyWep128Bit=ffa5f876ccea4cbf5464e3e999&wlDefaultKeyWep128Bit=ffa5f874ccea4cbe5464e3e99b&wlDefaultKeyWep128Bit=ffa5f872ccea4cbd5464e2e99d'
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
        print 'in method replQuery .....'
        wep_flag = None
        wpa_flag = None
        idx_def_wep128 = 0
        i = 0
        fmt = query.fmt()

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

                print 'replacing %s to %s ...' % (ek, ev)
                query.updateValueByIndex(index, v)
                continue


        # 3. using default overwrite custom
        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]

            if wep_flag:
                r = re.findall('wlKey(\d)_128_wl0v(\d)', k)
                if len(r) > 0:
                    (cus_idx, ssid_idx) = r[0]
                    if (wep_flag & (1 << int(ssid_idx) ) ):
                        if int(cus_idx) == 1:
                        # using default overwirte custom
                            ek = 'U_WIRELESS_WEPKEY' + str(int(ssid_idx) + 1)
                            ev = os.getenv(ek)
                            #print '==>',ek,ev
                            if ev: v = ev
                            query.updateValueByIndex(index, v)
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
                        query.updateValueByIndex(index, v)
                continue

        return query

    def replBody(self, body):
        """
        replace body string
        """
        print 'in function replBody .....'
        # TODO : Implement your hash replacement
        # 1. get default wep and psk flag
        # 2. replace default wep 128 (duplicate key name)

        wep_flag = None
        wpa_flag = None
        idx_def_wep128 = 0
        i = 0
        fmt = body.fmt()

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

        # 3. using default overwrite custom
        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if wep_flag:
                r = re.findall('wlKey(\d)_128_wl0v(\d)', k)
                if len(r) > 0:
                    (cus_idx, ssid_idx) = r[0]
                    if (wep_flag & (1 << int(ssid_idx) ) ):
                        if int(cus_idx) == 1:
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


	
	
	
	
