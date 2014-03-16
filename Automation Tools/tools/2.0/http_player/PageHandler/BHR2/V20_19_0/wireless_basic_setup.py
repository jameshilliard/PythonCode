#       template.py
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

# TODO : add your keyword-format into map
body_fmts[
    "wireless_wep_enable_type=1"] = 'active_page=9120&active_page_str=page_actiontec_wireless_basic_setup&page_title=Basic+Security+Settings&mimic_button_field=submit_button_submit%3A+..&button_value=9120&strip_page_top=0&tab4_selected=1&tab4_visited_1=1&wireless_enable_type=1&ssid=raywifi_bhr2_001&channel=-1&keep_channel_defval=0&wireless_wep_enable_type=1&pref_conn_set_8021x_key_len=104&pref_conn_set_8021x_key_mode=0&actiontec_default_wep_key=1234567890&actiontec_default_wep_key_128=12345678901234567890123456&actiontec_default_wep_key_ascii=&actiontec_default_wep_key_ascii_128=&wireless_conn_info_ssid=Enabled&wireless_conn_info_mac=Disabled&wireless_conn_info_mode=Compatibility+Mode%28802.11b%2Fg%2Fn%29&wireless_conn_info_packet_sent=99&wireless_conn_info_packet_rece=0'
body_fmts[
    "wireless_wep_enable_type=0"] = 'active_page=9120&active_page_str=page_actiontec_wireless_basic_setup&page_title=Basic+Security+Settings&mimic_button_field=submit_button_submit%3A+..&button_value=9120&strip_page_top=0&tab4_selected=1&tab4_visited_1=1&wireless_enable_type=1&ssid=raywifi_bhr2_001&channel=-1&keep_channel_defval=0&wireless_wep_enable_type=0&wireless_conn_info_ssid=Enabled&wireless_conn_info_mac=Disabled&wireless_conn_info_mode=Compatibility+Mode%28802.11b%2Fg%2Fn%29&wireless_conn_info_packet_sent=99&wireless_conn_info_packet_rece=0'
#-----------------------------------------------------------------------
query_fmts = {}
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

    #
    #self.m_isHash = True
    #self.m_replPOST = True
    #self.m_replGET = False


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
        """

        # wireless SSID1

        fixed_chan = os.getenv('U_WIRELESS_FIXED_CHANNEL')
        if fixed_chan:
            channel = body.value('channel')
            if '0' == channel or '-1' == channel:
                print '==	changed channel to ', fixed_chan
                body.updateValue('channel', str(fixed_chan))

        ssid = os.getenv('U_WIRELESS_SSID1')
        if ssid:
            body.updateValue('ssid', ssid)
        # WEP Key 64
        wepkey64 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY64bit1')
        if wepkey64:
            body.updateValue('actiontec_default_wep_key', wepkey64)
        # WEP Key 128
        wepkey128 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY128bit1')
        if wepkey128:
            body.updateValue('actiontec_default_wep_key_128', wepkey128)
        return body

