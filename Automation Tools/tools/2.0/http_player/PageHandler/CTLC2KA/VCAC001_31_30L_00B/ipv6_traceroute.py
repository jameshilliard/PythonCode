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
        self.m_replPOST = True
        self.m_replGET = True

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
        #    POST /ipv6_traceroute.cgi?
        #            ipv6_hostName=192.168.55.254&
        #            ipv6_tracerouteSign=1&
        #            nothankyou=1&
        #            ipv6_ping_type=ipv4&
        #            page=ipv6_traceroute.html

        fmt = query.fmt()

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'ipv6_hostName' and v != '':
                v = os.getenv('U_CUSTOM_TRCRT_HOST')
                #print 'DMZ LAN PC IP : ', ip_addr
                if v:
                    query.updateValueByIndex(index, v)
                continue

        return query

    def replBody(self, body):
        """
        replace body string
        """
        print '==== replBody'
        # TODO : Implement your hash replacement
        return body


    
    
    
    
