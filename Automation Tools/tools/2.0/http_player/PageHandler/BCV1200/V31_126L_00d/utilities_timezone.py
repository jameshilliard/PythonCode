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
        #	pacific                 mountain                central                 eastern                 eastern
        #	---------------------   --------------------    ---------------------   ---------------------   ---------------------
        #	timezoneindex	2       timezoneindex	3       timezoneindex	4       timezoneindex	5       timezoneindex	5
        #	use_dst	1               use_dst	1               use_dst	1               use_dst	1               use_dst	0
        #	time_zone	2           time_zone	3           time_zone	4           time_zone	5           time_zone	5
        #	---------------------   ---------------------   ---------------------   ---------------------   ---------------------


        fmt = body.fmt()

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'timezoneindex' or k == 'time_zone':
                ev = os.getenv('U_CUSTOM_TZONE_ENABLED')
                if ev:
                    v = ev
                    print '== change time zone to : ', v
                body.updateValueByIndex(index, v)
                continue
            elif k == 'use_dst':
                ev = os.getenv('U_CUSTOM_TZONE_DSLENABLED', os.getenv('U_DEF_TZONE_DSLENABLED'))
                if ev:
                    v = ev
                    print '== change daylight saving setting to : ', v
                body.updateValueByIndex(index, v)
                continue
        return body
