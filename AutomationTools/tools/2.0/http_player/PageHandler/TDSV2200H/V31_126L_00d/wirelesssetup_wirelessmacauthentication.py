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
    "action"] = 'action=add&srvName=aDv_PoRt_FoRwArDiNg&srvAddr=192.168.0.200&eStart=5000%2C&eEnd=5005%2C&proto=1%2C&iStart=5006%2C&iEnd=5006%2C&srvWanAddr=192.168.55.254&needthankyou=advancedsetup_advancedportforwarding.html'
#body_fmts[""] = ''
#-----------------------------------------------------------------------
query_fmts = {}

# TODO : add query format string 
#query_fmts[''] = ''
#query_fmts[''] = ''

#ssid1=os.getenv('U_WIRELESS_SSID1')
#ssid2=os.getenv('U_WIRELESS_SSID2')
#ssid3=os.getenv('U_WIRELESS_SSID3')
#ssid4=os.getenv('U_WIRELESS_SSID4')

#all_ssid=ssid1+'|'ssid2+'|'ssid3+'|'+ssid4

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
        fmt = query.fmt()
        ssid1 = os.getenv('U_WIRELESS_SSID1')
        ssid2 = os.getenv('U_WIRELESS_SSID2')
        ssid3 = os.getenv('U_WIRELESS_SSID3')
        #ssid4=os.getenv('U_WIRELESS_SSID4')

        all_ssid = ssid1 + '|' + ssid2 + '|' + ssid3

        print 'all ssid : ', all_ssid
        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'wlSsid_wl0v3':
                ev = all_ssid
                if ev:
                    v = ev
                    #print 'v=%s and ev=%s' % (v,ev)
                query.updateValueByIndex(index, v)
                continue

        return query

        #pass

    def replBody(self, body):
        """
        replace body string
        """
        fmt = body.fmt()

        ssid1 = os.getenv('U_WIRELESS_SSID1')
        ssid2 = os.getenv('U_WIRELESS_SSID2')
        ssid3 = os.getenv('U_WIRELESS_SSID3')
        #ssid4=os.getenv('U_WIRELESS_SSID4')

        all_ssid = ssid1 + '|' + ssid2 + '|' + ssid3

        print 'all ssid : ', all_ssid
        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'wlSsid_wl0v3':
                ev = all_ssid
                if ev:
                    v = ev
                    #print 'v=%s and ev=%s' % (v,ev)
                body.updateValueByIndex(index, v)
                continue

        return body

