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
        # TODO : Implement your hash replacement
        if body.value('ip_settings') == '1':
            static_ip = os.getenv('TMP_DUT_WAN_IP')
            print 'static_ip', static_ip
            for k in range(0, 4):
                body.updateValue('static_ip' + str(int(k)), static_ip.split('.')[k])

            static_netmask = os.getenv('TMP_DUT_WAN_MASK')
            print 'static_netmask', static_netmask
            for k in range(0, 4):
                body.updateValue('static_netmask' + str(int(k)), static_netmask.split('.')[k])

            static_gateway = os.getenv('TMP_DUT_DEF_GW')
            print 'static_gateway', static_gateway
            for k in range(0, 4):
                body.updateValue('static_gateway' + str(int(k)), static_gateway.split('.')[k])

        if body.value('dns_option') == '0':
            primary_dns = os.getenv('TMP_DUT_WAN_DNS_1')
            print 'primary_dns', primary_dns
            for k in range(0, 4):
                body.updateValue('primary_dns' + str(int(k)), primary_dns.split('.')[k])

            secondary_dns = os.getenv('TMP_DUT_WAN_DNS_2')
            print 'secondary_dns', secondary_dns
            for k in range(0, 4):
                body.updateValue('secondary_dns' + str(int(k)), secondary_dns.split('.')[k])
        return body


	
	
	
	
