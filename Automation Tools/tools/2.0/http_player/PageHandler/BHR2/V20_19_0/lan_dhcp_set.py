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
#body_fmts[""] = ''
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
        dhcp_bro_ip = os.getenv('U_DUT_CUSTOM_LAN_IP', '192.168.1.1')
        dhcp_pool_start_ip = os.getenv('G_PROD_DHCPSTART_BR0_0_0', '192.168.1.2')
        dhcp_pool_end_ip = os.getenv('G_PROD_DHCPEND_BR0_0_0', '192.168.1.254')
        dhcp_netmask = os.getenv('U_DUT_CUSTOM_LAN_NETMASK', '255.255.255.0')
        dhcp_dns1 = os.getenv('U_DUT_CUSTOM_LAN_DNS_1', '"0.0.0.0')
        dhcp_dns2 = os.getenv('U_DUT_CUSTOM_LAN_DNS_2', '0.0.0.0')
        for index in range(0, 4):
            body.updateValue('static_ip' + str(int(index)), dhcp_bro_ip.split('.')[index])
            body.updateValue('static_netmask' + str(int(index)), dhcp_netmask.split('.')[index])
            body.updateValue('start_ip' + str(int(index)), dhcp_pool_start_ip.split('.')[index])
            body.updateValue('end_ip' + str(int(index)), dhcp_pool_end_ip.split('.')[index])
            body.updateValue('primary_dns' + str(int(index)), dhcp_dns1.split('.')[index])
            body.updateValue('secondary_dns' + str(int(index)), dhcp_dns2.split('.')[index])

        return body


    
    
    
    
