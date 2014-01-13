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
#	active_page=6010&active_page_str=page_actiontec_wireless_setup_mac&page_title=Wireless+MAC+Authentication&mimic_button_field=submit_button_wireless_apply%3A+..&button_value=.&strip_page_top=0&wireless_mac_filter_enable_defval=1&wireless_mac_filter_enable=1&wireless_mac_filter_type=0&wireless_mac_address=0&wireless_mac_address=1	&wireless_mac_all_address=
#	active_page=6010&active_page_str=page_actiontec_wireless_setup_mac&page_title=Wireless+MAC+Authentication&mimic_button_field=submit_button_wireless_apply%3A+..&button_value=.&strip_page_top=0&wireless_mac_filter_enable_defval=0&wireless_mac_filter_enable=1&wireless_mac_filter_type=0&wireless_mac_address=0						 	&wireless_mac_all_address=00%3A20%3Ae0%3A00%3A41%3A00%23
#	active_page=6010&active_page_str=page_actiontec_wireless_setup_mac&page_title=Wireless+MAC+Authentication&mimic_button_field=submit_button_wireless_apply%3A+..&button_value=.&strip_page_top=0&wireless_mac_filter_enable_defval=1&wireless_mac_address=0&wireless_mac_all_address=
#	
body_fmts[
    "wireless_mac_filter_enable_defval=1"] = 'active_page=6010&active_page_str=page_actiontec_wireless_setup_mac&page_title=Wireless+MAC+Authentication&mimic_button_field=submit_button_wireless_apply%3A+..&button_value=.&strip_page_top=0&wireless_mac_filter_enable_defval=1&wireless_mac_filter_enable=1&wireless_mac_filter_type=0&wireless_mac_address=0&wireless_mac_address=1&wireless_mac_all_address='
body_fmts[
    "wireless_mac_filter_enable_defval=0"] = 'active_page=6010&active_page_str=page_actiontec_wireless_setup_mac&page_title=Wireless+MAC+Authentication&mimic_button_field=submit_button_wireless_apply%3A+..&button_value=.&strip_page_top=0&wireless_mac_filter_enable_defval=0&wireless_mac_filter_enable=1&wireless_mac_filter_type=0&wireless_mac_address=0&wireless_mac_all_address=00%3A20%3Ae0%3A00%3A41%3A00%23'
#body_fmts[""] 	 = 'active_page=6010&active_page_str=page_actiontec_wireless_setup_mac&page_title=Wireless+MAC+Authentication&mimic_button_field=submit_button_wireless_apply%3A+..&button_value=.&strip_page_top=0&wireless_mac_filter_enable_defval=1&wireless_mac_address=0&wireless_mac_all_address='

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
        #	U_WIRELESSCARD_MAC

        #############################################################

        #		wireless_mac_filter_enable_defval	0
        #		wireless_mac_filter_enable	1
        #		wireless_mac_filter_type	0
        #		wireless_mac_address	0
        #		wireless_mac_all_address	00:20:e0:00:41:00#

        #############################################################

        #		wireless_mac_filter_enable_defval	1
        #		wireless_mac_filter_enable	1
        #		wireless_mac_filter_type	0
        #		wireless_mac_address	00:20:e0:00:41:00
        #		wireless_mac_address	1
        #		wireless_mac_all_address

        #############################################################

        #		wireless_mac_filter_enable_defval	1
        #		wireless_mac_address	0
        #		wireless_mac_all_address

        #############################################################



        mac_addr = os.getenv('U_WIRELESSCARD_MAC')
        mac_addr = mac_addr.lower()
        mac_addr_all = mac_addr + '#'

        if mac_addr:
            mac = body.value('wireless_mac_address')
            mac = str(mac)
            mac_all = body.value('wireless_mac_all_address')
            mac_all = str(mac_all)

            #				body.updateValue('channel', str(fixed_chan))

            m_mac = r'\w*:\w*:\w*:\w*:\w*:\w*'

            rc_mac = re.findall(m_mac, mac)
            rc_mac_all = re.findall(m_mac, mac_all)

            if len(rc_mac) > 0:
                print '== | replace wireless_mac_address with : ', mac_addr
                body.updateValue('wireless_mac_address', mac_addr)

            if len(rc_mac_all) > 0:
                print '== | replace wireless_mac_all_address with : ', mac_addr_all
                body.updateValue('wireless_mac_all_address', mac_addr_all)

        return body

