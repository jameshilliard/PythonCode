#	   $FILENAME.py
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
#body_fmts[''] = ''
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
        fmt = body.fmt()
        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'LeaseTime':
                ev = os.getenv('G_PROD_LEASETIME_BR0_0_0', '86400')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'DhcpsStartIP':
                ev = os.getenv('G_PROD_DHCPSTART_BR0_0_0')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'DhcpsEndIP':
                ev = os.getenv('G_PROD_DHCPEND_BR0_0_0')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'SysMASK':
                ev = os.getenv('G_PROD_TMASK_BR0_0_0')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'SysIP':
                ev = os.getenv('U_DUT_CUSTOM_LAN_IP')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'DnsPrimary':
                #	lanDnsType=custom
                is_dns_custom = body.value('dnstype')
                if is_dns_custom == 'custom':
                    ev = os.getenv('U_DUT_CUSTOM_LAN_DNS_1')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                continue
            elif k == 'DnsSecondary':
                #	lanDnsType=custom
                is_dns_custom = body.value('dnstype')
                if is_dns_custom == 'custom':
                    ev = os.getenv('U_DUT_CUSTOM_LAN_DNS_2')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                continue
        return body