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
body_fmts[
    "tr69cAcsURL"] = 'tr69cAcsURL=http%3A%2F%2Fxatechdmw.xdev.motive.com%2FcwmpWeb%2FCPEMgt&tr69cAcsUser=qwest&tr69cAcsPwd=&tr69cInformEnable=1&tr69cInformInterval=60&tr69cPeriodicInformTime=2012-02-21T02%3A43%3A58%2B00%3A00&tr69cConnReqURL=http%3A%2F%2F192.168.55.147%3A4567%2F&tr69cConnReqUser=00247B-V2000H-CVJA1141900040&tr69cConnReqPwd=&tr69cBackoffInterval=&tr69cDebugEnable=1&var%3Afrompage=tr69.html'
#body_fmts[""] = ''
#-----------------------------------------------------------------------
query_fmts = {}


class Page(PageBase):
    """
    """

    def __init__(self, player, msglvl=2):
        """
        """
        PageBase.__init__(self, player, msglvl)
        self.info('Page ' + os.path.basename(__file__))
        self.addStrFmts(body_fmts, query_fmts)

    #		tr69cAcsURL	http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt
    #		tr69cAcsUser	qwest
    #		tr69cAcsPwd
    #		tr69cInformEnable	1
    #		tr69cInformInterval	60
    #		tr69cPeriodicInformTime	2012-02-21T02:43:58+00:00
    #		tr69cConnReqURL	http://192.168.55.147:4567/
    #		tr69cConnReqUser	00247B-V2000H-CVJA1141900040
    #		tr69cConnReqPwd
    #		tr69cBackoffInterval
    #		tr69cDebugEnable	1
    #		var:frompage	tr69.html

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
        fmt = body.fmt()
        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'dhcpEthStart':
                ev = os.getenv('U_DUT_CUSTOM_LAN_MIN_ADDRESS')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'dhcpEthEnd':
                ev = os.getenv('U_DUT_CUSTOM_LAN_MAX_ADDRESS')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'ethSubnetMask':
                ev = os.getenv('U_DUT_CUSTOM_LAN_NETMASK')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'ethIpAddress':
                ev = os.getenv('U_DUT_CUSTOM_LAN_IP')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
        return body
