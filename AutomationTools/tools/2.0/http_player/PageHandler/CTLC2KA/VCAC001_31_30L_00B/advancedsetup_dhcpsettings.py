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
        #		'dhcpEthStart':'U_DUT_CUSTOM_LAN_MIN_ADDRESS',
        #		'dhcpEthEnd':'U_DUT_CUSTOM_LAN_MAX_ADDRESS',
        #		'dhcpSubnetMask':'U_DUT_CUSTOM_LAN_NETMASK',
        #		'dnsPrimary':'U_DUT_CUSTOM_LAN_DNS_1',
        #		'dnsSecondary':'U_DUT_CUSTOM_LAN_DNS_2',
        #		'dhcpLeasedTime':'TMP_CURR_LEASE_TIME',
        #		'ethIpAddress_tmp':'U_DUT_CUSTOM_LAN_IP',
        #		'dhcpEthStart_tmp':'U_DUT_CUSTOM_LAN_MIN_ADDRESS',
        #		'dhcpEthEnd_tmp':'U_DUT_CUSTOM_LAN_MAX_ADDRESS',
        #		'ethSubnetMask_tmp':'U_DUT_CUSTOM_LAN_NETMASK',

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'dnsPrimary':
                #	lanDnsType=custom
                is_dns_custom = body.value('lanDnsType')
                if is_dns_custom == 'custom':
                    ev = os.getenv('U_DUT_CUSTOM_LAN_DNS_1')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                elif is_dns_custom == 'default':
                    ev = os.getenv('TMP_DUT_WAN_DNS_1')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                continue
            elif k == 'dnsSecondary':
                #	lanDnsType=custom
                is_dns_custom = body.value('lanDnsType')
                if is_dns_custom == 'custom':
                    ev = os.getenv('U_DUT_CUSTOM_LAN_DNS_2')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                elif is_dns_custom == 'default':
                    ev = os.getenv('TMP_DUT_WAN_DNS_2')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                continue
            elif k == 'dhcpEthStart':
                ev = os.getenv('G_PROD_DHCPSTART_BR0_0_0')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'dhcpEthEnd':
                ev = os.getenv('G_PROD_DHCPEND_BR0_0_0')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'dhcpSubnetMask':
                ev = os.getenv('G_PROD_TMASK_BR0_0_0')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'dhcpLeasedTime':
                LeasedTime = os.getenv('G_PROD_LEASETIME_BR0_0_0')
                LeasedTime = int(LeasedTime) / 60
                ev = str(LeasedTime)
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'ethIpAddress_tmp':
                ev = os.getenv('U_DUT_CUSTOM_LAN_IP')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'dhcpEthStart_tmp':
                ev = os.getenv('G_PROD_DHCPSTART_BR0_0_0')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'dhcpEthEnd_tmp':
                ev = os.getenv('G_PROD_DHCPEND_BR0_0_0')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
            elif k == 'ethSubnetMask_tmp':
                ev = os.getenv('G_PROD_TMASK_BR0_0_0')
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                continue
        return body
