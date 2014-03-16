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
    "wireless_mac_filter_enable=1"] = 'apply_page=wireless_advanced_mac.html%3Fssid%3Dath1&waiting_page=waiting_page.html&waiting_page_leftmenu=3&waiting_page_topmenu=1&wireless_vap_name=ath1&wireless_mac_filter_enable=1&wireless_mac_filter_type=1&wireless_mac_all_address=00%3A20%3Ae0%3A00%3A41%3A00+'
body_fmts["wireless_mac_filter_enable=0"] = 'wireless_mac_filter_enable=0'
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
        if body:
            # replace wireless_mac_all_address value with U_WIRELESSCARD_MAC
            mac = os.getenv('U_WIRELESSCARD_MAC')
            if mac:
                wireless_mac_all_address = body.value('wireless_mac_all_address')
                wireless_mac_all_address = str(wireless_mac_all_address)

                #m_mac = r'\w*:\w*:\w*:\w*:\w*:\w*'
                m_mac = r'([^a-zA-Z0-9]*)\w*:\w*:\w*:\w*:\w*:\w*([^a-zA-Z0-9]*)'

                rc_mac = re.findall(m_mac, wireless_mac_all_address)

                if len(rc_mac) > 0:
                    start, end = rc_mac[0]

                    mac = start + mac + end
                    print '== | replace wireless_mac_all_address from  ', wireless_mac_all_address + ' to ' + mac
                    body.updateValue('wireless_mac_all_address', mac)

                    #body.updateValue('wireless_mac_all_address', mac)
        return body


    
    
    
    
