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
    "wireless_enable_type=1"] = 'apply_page=wireless_basic.html%3Fssid%3Dath0&waiting_page=waiting_page.html&waiting_page_leftmenu=2&waiting_page_topmenu=1&wep_active=1&wireless_vap_name=ath0&wireless_enable_type=1&wireless_ssid=549B3313&wireless_multiple_ssid=ath0&wireless_channel=3&wireless_keep_channel=0&wireless_wep_enable_type=1&wep_key_len=0&wep_key_mode=0&wep_key_code=0987654321'
body_fmts["wireless_enable_type=0"] = 'wireless_vap_name=ath0&wireless_enable_type=0&wireless_multiple_ssid=ath0'
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
        #   sumbit_button_name	edit_datetime               sumbit_button_name	edit_datetime
        #   advanced_datetime_starttime	3-11 00:00          advanced_datetime_starttime	3-11 00:00
        #   advanced_datetime_endtime	11-11 02:00         advanced_datetime_endtime	11-11 02:00
        #   waiting_page	waiting_page.html               waiting_page	waiting_page.html
        #   waiting_page_topmenu	5                       waiting_page_topmenu	5
        #   waiting_page_leftmenu	1                       waiting_page_leftmenu	1
        #   apply_page	advanced_datetime.html              apply_page	advanced_datetime.html
        #   	advanced_datetime_timezone	(GMT-9:00) Alaska   advanced_datetime_timezone	(GMT-6:00) Central
        #   	advanced_datetime_daylight	false               advanced_datetime_daylight	true
        #   advanced_datetime_offset	60                  advanced_datetime_offset	60
        #   advanced_datetime_automatic	true                advanced_datetime_automatic	true
        #   advanced_datetime_protocol	1                   advanced_datetime_protocol	1
        #   advanced_datetime_updateperiod	600             advanced_datetime_updateperiod	600
        ################################################################################################


        fmt = body.fmt()

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'advanced_dhcp_start_ipaddress':
                ev = os.getenv('G_PROD_DHCPSTART_BR0_0_0')
                if ev:
                    v = ev
                    print '== change advanced_dhcp_start_ipaddress to : ', v
                body.updateValueByIndex(index, v)
                continue
            elif k == 'advanced_dhcp_end_ipaddress':
                ev = os.getenv('G_PROD_DHCPEND_BR0_0_0', os.getenv('G_PROD_DHCPEND_BR0_0_0'))
                if ev:
                    v = ev
                    print '== change advanced_dhcp_end_ipaddress to : ', v
                body.updateValueByIndex(index, v)
                continue
        return body
