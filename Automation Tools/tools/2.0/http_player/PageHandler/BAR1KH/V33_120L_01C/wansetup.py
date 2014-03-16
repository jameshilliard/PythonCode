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

body_fmts["enblDhcpClnt=1"] = 'serviceId=1&'
body_fmts["enblDhcpClnt=1"] += 'wanInf=ewan0.1&'
body_fmts["enblDhcpClnt=1"] += 'wanL2IfName=ewan0&'
body_fmts["enblDhcpClnt=1"] += 'udmtu=1500&'
body_fmts["enblDhcpClnt=1"] += 'enVlanMux=1&'
body_fmts["enblDhcpClnt=1"] += 'vlanMuxId=35&'
body_fmts["enblDhcpClnt=1"] += 'vlanMuxPr=0&'
body_fmts["enblDhcpClnt=1"] += 'enblDhcpClnt=1&'
body_fmts["enblDhcpClnt=1"] += 'enblDproxy=1&'
body_fmts["enblDhcpClnt=1"] += 'hostname=R1000H-Router&'
body_fmts["enblDhcpClnt=1"] += 'domainname=&'
body_fmts["enblDhcpClnt=1"] += 'enblEnetWan=0&'
body_fmts["enblDhcpClnt=1"] += 'enblNat=1&'
body_fmts["enblDhcpClnt=1"] += 'enblFirewall=1&'
body_fmts["enblDhcpClnt=1"] += 'enableAdvancedDmz=0&'
body_fmts["enblDhcpClnt=1"] += 'enblEnetWan=0&'
body_fmts["enblDhcpClnt=1"] += 'ntwkPrtcl=2&'
body_fmts["enblDhcpClnt=1"] += 'enblLan2=0&'
body_fmts["enblDhcpClnt=1"] += 'vipmode=0&'
body_fmts["enblDhcpClnt=1"] += 'enblIgmp=0&'
body_fmts["enblDhcpClnt=1"] += 'action=add&'
body_fmts["enblDhcpClnt=1"] += 'redirect=advancedsetup_wanipaddress.html&'
body_fmts["enblDhcpClnt=1"] += 'dnsIfc=&dnsPrimary=0.0.0.0&'
body_fmts["enblDhcpClnt=1"] += 'dnsSecondary=0.0.0.0'

body_fmts["pppUserName="] = 'serviceId=1&'
body_fmts["pppUserName="] += 'wanInf=ewan0.1&'
body_fmts["pppUserName="] += 'wanL2IfName=ewan0&'
body_fmts["pppUserName="] += 'udmtu=1500&'
body_fmts["pppUserName="] += 'enVlanMux=1&'
body_fmts["pppUserName="] += 'vlanMuxId=35&'
body_fmts["pppUserName="] += 'vlanMuxPr=0&'
body_fmts["pppUserName="] += 'pppUserName=autotest001&'
body_fmts["pppUserName="] += 'pppPassword=111111&'
body_fmts["pppUserName="] += 'pppIpExtension=0&'
body_fmts["pppUserName="] += 'enblFirewall=1&'
body_fmts["pppUserName="] += 'enblNat=1&'
body_fmts["pppUserName="] += 'useStaticIpAddress=0&'
body_fmts["pppUserName="] += 'pppLocalIpAddress=0.0.0.0&'
body_fmts["pppUserName="] += 'enblLan2=0&'
body_fmts["pppUserName="] += 'vipmode=0&'
body_fmts["pppUserName="] += 'PPPAutoConnect=1&'
body_fmts["pppUserName="] += 'enblOnDemand=1&'
body_fmts["pppUserName="] += 'pppToBridge=0&'
body_fmts["pppUserName="] += 'enblEnetWan=0&'
body_fmts["pppUserName="] += 'ntwkPrtcl=0&'
body_fmts["pppUserName="] += 'enblIgmp=0&'
body_fmts["pppUserName="] += 'action=add&'
body_fmts["pppUserName="] += 'redirect=advancedsetup_wanipaddress.html&'
body_fmts["pppUserName="] += 'dnsIfc=&'
body_fmts["pppUserName="] += 'dnsPrimary=0.0.0.0&'
body_fmts["pppUserName="] += 'dnsSecondary=0.0.0.0&'
body_fmts["pppUserName="] += 'needthankyou=advancedsetup_wanipaddress.html'

body_fmts["enblDhcpClnt=0"] = 'serviceId=1&'
body_fmts["enblDhcpClnt=0"] += 'wanInf=ppp0.1&'
body_fmts["enblDhcpClnt=0"] += 'wanL2IfName=ewan0&'
body_fmts["enblDhcpClnt=0"] += 'udmtu=1500&'
body_fmts["enblDhcpClnt=0"] += 'enVlanMux=1&'
body_fmts["enblDhcpClnt=0"] += 'vlanMuxId=35&'
body_fmts["enblDhcpClnt=0"] += 'vlanMuxPr=0&'
body_fmts["enblDhcpClnt=0"] += 'enblDhcpClnt=0&'
body_fmts["enblDhcpClnt=0"] += 'wanIpAddress=172.17.35.127&'
body_fmts["enblDhcpClnt=0"] += 'wanSubnetMask=255.255.255.0&'
body_fmts["enblDhcpClnt=0"] += 'wanIntfGateway=172.17.35.254&'
body_fmts["enblDhcpClnt=0"] += 'enblEnetWan=0&'
body_fmts["enblDhcpClnt=0"] += 'enblNat=1&'
body_fmts["enblDhcpClnt=0"] += 'enblFirewall=1&'
body_fmts["enblDhcpClnt=0"] += 'enableAdvancedDmz=0&'
body_fmts["enblDhcpClnt=0"] += 'enblEnetWan=0&'
body_fmts["enblDhcpClnt=0"] += 'ntwkPrtcl=2&'
body_fmts["enblDhcpClnt=0"] += 'enblLan2=0&'
body_fmts["enblDhcpClnt=0"] += 'vipmode=0&'
body_fmts["enblDhcpClnt=0"] += 'enblIgmp=0&'
body_fmts["enblDhcpClnt=0"] += 'action=add&'
body_fmts["enblDhcpClnt=0"] += 'redirect=advancedsetup_wanipaddress.html&'
body_fmts["enblDhcpClnt=0"] += 'dnsPrimary=192.168.55.254&'
body_fmts["enblDhcpClnt=0"] += 'dnsSecondary=10.17.35.254&'
body_fmts["enblDhcpClnt=0"] += 'dnsIfc=&'
body_fmts["enblDhcpClnt=0"] += 'needthankyou=advancedsetup_wanipaddress.html'

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
        fmt = body.fmt()

        U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE = os.getenv('U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE', '1')

        if U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE == '0':
            print 'not do replacement , it is all manually set'

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]

                #				if k == 'sessionKey' :
                #					ev = os.getenv('TMP_CUSTOM_SESSIONKEY')
                #					if ev :
                #						print 'session key change to  :', ev
                #						v = ev
                #						#print 'v=%s and ev=%s' % (v,ev)
                #					body.updateValueByIndex(index, v)
                #					continue

                if k == 'vlanMuxId':
                #ori_vlanID=body.value('vlanMuxId')
                #					if not v == '-1':
                #						ev = os.getenv('TMP_CUSTOM_TAGGED_ID')
                #						if ev :
                    v = '35'
                    body.updateValueByIndex(index, v)
                    continue

                if k == 'wanIpAddress':
                    ev = os.getenv('TMP_DUT_WAN_IP')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
                if k == 'wanSubnetMask':
                    ev = os.getenv('TMP_DUT_WAN_MASK')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
                if k == 'wanIntfGateway':
                    ev = os.getenv('TMP_DUT_DEF_GW')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
                if k == 'dnsPrimary':
                    is_dhcp = body.value('enblDhcpClnt')
                    if is_dhcp == '0':
                        ev = os.getenv('TMP_DUT_WAN_DNS_1')
                        if ev:
                            v = ev
                        body.updateValueByIndex(index, v)
                    continue
                if k == 'dnsSecondary':
                    is_dhcp = body.value('enblDhcpClnt')
                    if is_dhcp == '0':
                        ev = os.getenv('TMP_DUT_WAN_DNS_2')
                        if ev:
                            v = ev
                        body.updateValueByIndex(index, v)
                    continue

        else:


        #pprint(fmt)

        #			if 'pppUserName' in fmt['keys']:
        #				serNamePre = 'pppoe_'
        #			elif 'wanIpAddress' in fmt['keys']:
        #				serNamePre = 'static_'
        #			else:
        #				serNamePre = 'dhcpc_'
        #
        #			serName = os.getenv('TMP_CUSTOM_SERVNAME')
        #
        #			if serName :
        #				serviceName = serNamePre + serName
        #			else:
        #				serviceName = serNamePre + os.getenv('TMP_CUSTOM_WANL2INFNAME')

            lay3inf = os.getenv('TMP_CUSTOM_WANINF')

            #			if lay3inf :
            #				if lay3inf.find('ppp') >= 0:
            #					print 'current link is pppoe'
            ##					if serNamePre.find('pppoe') >= 0:
            ##						print 'switch from pppoe to pppoe'
            #						#serviceName=''
            #				else:
            #					print 'current link is ipoe'
            ##					if serNamePre.find('dhcpc') >= 0:
            ##						print 'switch from ipoe to ipoe'
            #						#serviceName=''
            #			else:
            #				print 'AT_ERROR : could not get layer3interface info'
            #				exit(1)

            #print 'service name is : ', serviceName
            # wanInf=atm0&wanL2IfName=atm0%2F%280_0_35%29&
            # wanInf=ppp0&wanL2IfName=atm0%2F%280_0_35%29&
            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'wanInf':
                    ev = lay3inf
                    if ev:
                        print 'TMP_CUSTOM_WANINF is :', ev
                        v = ev
                    else:
                        print 'TMP_CUSTOM_WANINF is not defined !'
                    #print 'v=%s and ev=%s' % (v,ev)
                    body.updateValueByIndex(index, v)
                    continue
                if k == 'wanL2IfName':
                    ev = os.getenv('TMP_CUSTOM_WANL2INFNAME')
                    if ev:
                        print 'TMP_CUSTOM_WANL2INFNAME is :', ev
                        v = ev
                    #print 'v=%s and ev=%s' % (v,ev)
                    body.updateValueByIndex(index, v)
                    continue
                #				if k == 'serviceName' :
                #					ev = serviceName
                #					#if ev :
                #					print 'service name change to  :', ev
                #					v = ev
                #						#print 'v=%s and ev=%s' % (v,ev)
                #					body.updateValueByIndex(index, v)
                #					continue
                if k == 'sessionKey':
                    ev = os.getenv('TMP_CUSTOM_SESSIONKEY')
                    if ev:
                        print 'session key change to  :', ev
                        v = ev
                    #print 'v=%s and ev=%s' % (v,ev)
                    body.updateValueByIndex(index, v)
                    continue

                if k == 'wanIpAddress':
                    ev = os.getenv('TMP_DUT_WAN_IP')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
                if k == 'wanSubnetMask':
                    ev = os.getenv('TMP_DUT_WAN_MASK')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
                if k == 'wanIntfGateway':
                    ev = os.getenv('TMP_DUT_DEF_GW')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
                if k == 'dnsPrimary':
                    is_dhcp = body.value('enblDhcpClnt')
                    if is_dhcp == '0':
                        ev = os.getenv('TMP_DUT_WAN_DNS_1')
                        if ev:
                            v = ev
                        body.updateValueByIndex(index, v)
                    continue
                if k == 'dnsSecondary':
                    is_dhcp = body.value('enblDhcpClnt')
                    if is_dhcp == '0':
                        ev = os.getenv('TMP_DUT_WAN_DNS_2')
                        if ev:
                            v = ev
                        body.updateValueByIndex(index, v)
                    continue
        return body


	
	
	
	
