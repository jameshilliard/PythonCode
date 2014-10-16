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

#------------------------------------------------------------------------
body_fmts = {}

# TODO : add your keyword-format into map
body_fmts[
    "page_fw_dmz_host"] = 'active_page=9017&active_page_str=page_fw_dmz_host&page_title=DMZ+Host&mimic_button_field=submit_button_submit%3A+..&button_value=9017&strip_page_top=0&tab4_selected=3&tab4_visited_3=1&dmz_host_cb_defval=0&dmz_host_cb=1&dmz_host_ip0_defval=192&dmz_host_ip0=192&dmz_host_ip1_defval=168&dmz_host_ip1=168&dmz_host_ip2_defval=1&dmz_host_ip2=1&dmz_host_ip3_defval=0&dmz_host_ip3=10'

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
        print 'hello python '
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
        print 'hello replace'
        #        ip_addr = '192.168.1.150'
        ip_addr = os.getenv('U_CUSTOM_DMZ_HOST_IP', os.getenv('G_HOST_TIP0_1_0'))
        print 'DMZ LAN PC IP : ', ip_addr
        host_ips = ip_addr.split('.')
        print 'host ip : ', host_ips[0], host_ips[1], host_ips[2], host_ips[3],
        body.updateValue('dmz_host_ip0', host_ips[0])
        body.updateValue('dmz_host_ip1', host_ips[1])
        body.updateValue('dmz_host_ip2', host_ips[2])
        body.updateValue('dmz_host_ip3', host_ips[3])
        return body

