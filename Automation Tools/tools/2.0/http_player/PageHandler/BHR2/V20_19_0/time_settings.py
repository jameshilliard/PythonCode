#	   template.py
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
    "page_fw_port_forwarding"] = 'active_page=9012&active_page_str=page_fw_port_forwarding&page_title=Port+Forwarding&mimic_button_field=submit_button_add_portfw%3A+..&button_value=local_host_list&strip_page_top=0&tab4_selected=2&tab4_visited_2=1&local_host_list=specify&local_host_list_defval=specify&Specify_ip_defval=&Specify_ip=192.168.1.150&svc_service_combo=USER_DEFINED&svc_service_combo_defval=USER_DEFINED&svc_entry_protocol=6&svc_entry_protocol_defval=6&port_range_defval=65535&port_range=6666'
#body_fmts["wireless_wep_enable_type=0"] 	 = 'active_page=9120&active_page_str=page_actiontec_wireless_basic_setup&page_title=Basic+Security+Settings&mimic_button_field=submit_button_submit%3A+..&button_value=9120&strip_page_top=0&tab4_selected=1&tab4_visited_1=1&wireless_enable_type=1&ssid=raywifi_bhr2_001&channel=-1&keep_channel_defval=0&wireless_wep_enable_type=0&wireless_conn_info_ssid=Enabled&wireless_conn_info_mac=Disabled&wireless_conn_info_mode=Compatibility+Mode%28802.11b%2Fg%2Fn%29&wireless_conn_info_packet_sent=99&wireless_conn_info_packet_rece=0'
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
        fmt = body.fmt()

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'time_zone':
                ev = os.getenv('U_CUSTOM_TZONE_ENABLED')
                if ev:
                    v = ev
                    print '== change time zone to : ', v
                body.updateValueByIndex(index, v)
                continue
            #fff = {1:1}
            #if fff.has_key(k)

            if 'is_dl_sav' in fmt['keys']:
                ev = os.getenv('U_CUSTOM_TZONE_DSLENABLED', os.getenv('U_DEF_TZONE_DSLENABLED'))
                if ev == '0':
                    body.deleteKey('is_dl_sav')
            else:
                ev = os.getenv('U_CUSTOM_TZONE_DSLENABLED', os.getenv('U_DEF_TZONE_DSLENABLED'))
                if ev == '1':
                    body.addKeyAndValue('is_dl_sav', ev)

        return body
