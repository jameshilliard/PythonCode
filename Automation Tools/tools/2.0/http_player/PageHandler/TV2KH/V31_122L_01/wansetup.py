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
    "enblDhcpClnt"] = 'serviceWANType=0&serviceId=1&wanInf=atm0&wanL2IfName=atm0%2F%280_0_35%29&enblDhcpClnt=1&enblDproxy=1&hostname=&domainname=&enblEnetWan=0&enblNat=1&enblFirewall=1&enableAdvancedDmz=0&enblEnetWan=0&ntwkPrtcl=2&enblLan2=0&vipmode=0&enblIgmp=1&serviceName=&action=add&redirect=advancedsetup_wanipaddress.html&sessionKey=649829393&dnsIfc=&dnsPrimary=0.0.0.0&dnsSecondary=0.0.0.0&atmencaps=LLC&noneeddel=0'
body_fmts[
    "pppUserName"] = 'serviceWANType=0&serviceId=1&wanInf=ppp0&wanL2IfName=atm0%2F%280_0_35%29&pppUserName=hyin&pppPassword=111111&pppIpExtension=0&enblFirewall=1&enblNat=1&useStaticIpAddress=0&pppLocalIpAddress=0.0.0.0&enblLan2=0&vipmode=0&PPPAutoConnect=1&enblOnDemand=1&pppToBridge=0&enblEnetWan=0&ntwkPrtcl=0&enblIgmp=1&serviceName=&action=add&redirect=advancedsetup_wanipaddress.html&sessionKey=921262268&dnsIfc=&dnsPrimary=0.0.0.0&dnsSecondary=0.0.0.0&atmencaps=LLC&needthankyou=advancedsetup_wanipaddress.html&noneeddel=0'
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
        #	serviceId	1                                   serviceId	1
        #	wanInf	ewan0.1                                 wanInf	ewan0.1
        #	wanL2IfName	ewan0                               wanL2IfName	ewan0
        #	enVlanMux	1                                   enVlanMux	1
        #	vlanMuxId	-1                                  vlanMuxId	-1
        #	vlanMuxPr	-1                                  vlanMuxPr	-1
        #	pppUserName	hyin                                enblDhcpClnt	1
        #	pppPassword	111111                              enblDproxy	1
        #	pppIpExtension	0                               hostname	home
        #	enblFirewall	1                               domainname	telus
        #	enblNat	1                                       enblEnetWan	0
        #	useStaticIpAddress	0                           enblNat	1
        #	pppLocalIpAddress	0.0.0.0                     enblFirewall	1
        #	enblLan2	0                                   enableAdvancedDmz	0
        #	vipmode	0                                       enblEnetWan	0
        #	PPPAutoConnect	1                               ntwkPrtcl	2
        #	enblOnDemand	1                               enblLan2	0
        #	pppToBridge	0                                   vipmode	0
        #	enblEnetWan	0                                   enblIgmp	1
        #	ntwkPrtcl	0                                   action	add
        #	enblIgmp	1                                   redirect	advancedsetup_wanipaddress.html
        #	action	add                                     dnsIfc
        #	redirect	advancedsetup_wanipaddress.html     dnsPrimary	0.0.0.0
        #	dnsIfc	                                        dnsSecondary	0.0.0.0
        #	dnsPrimary	0.0.0.0                             --------------------------------------------
        #	dnsSecondary	0.0.0.0
        #	--------------------------------------------------------------------------------------------


        #		fmt = body.fmt()
        #
        #		lay3inf = os.getenv('TMP_CUSTOM_WANINF', 'ewan0.1')
        #
        #		if lay3inf :
        #			if lay3inf.find('ppp') >= 0:
        #				print 'current link is pppoe'
        #			else:
        #				print 'current link is ipoe'
        ##		else:
        ##			print 'AT_ERROR : could not get layer3interface info'
        ##			exit(1)
        #
        #		for index, k in enumerate(fmt['keys']) :
        #			v = fmt['vals'][index]
        #			if k == 'wanInf' :
        #				ev = lay3inf
        #				if ev :
        #					print 'TMP_CUSTOM_WANINF is :', ev
        #					v = ev
        #				else:
        #					print 'TMP_CUSTOM_WANINF is not defined !'
        #				body.updateValueByIndex(index, v)
        #				continue
        #			elif k == 'wanL2IfName' :
        #				ev = os.getenv('TMP_CUSTOM_WANL2INFNAME', 'ewan0')
        #				if ev :
        #					print 'TMP_CUSTOM_WANL2INFNAME is :', ev
        #					v = ev
        #				body.updateValueByIndex(index, v)
        #				continue

        fmt = body.fmt()

        #pprint(fmt)

        #		if 'pppUserName' in fmt['keys']:
        #			serNamePre = 'pppoe_'
        #		elif 'wanIpAddress' in fmt['keys']:
        #			serNamePre = 'static_'
        #		else:
        #			serNamePre = 'dhcpc_'
        #
        #		serName = os.getenv('TMP_CUSTOM_SERVNAME')
        #
        #		if serName :
        #			serviceName = serNamePre + serName
        #		else:
        #			serviceName = serNamePre + os.getenv('TMP_CUSTOM_WANL2INFNAME')
        #
        #		lay3inf = os.getenv('TMP_CUSTOM_WANINF')

        #		if lay3inf :
        #			if lay3inf.find('ppp') >= 0:
        #				print 'current link is pppoe'
        #				if serNamePre.find('pppoe') >= 0:
        #					print 'switch from pppoe to pppoe'
        #					#serviceName=''
        #			else:
        #				print 'current link is ipoe'
        #				if serNamePre.find('dhcpc') >= 0:
        #					print 'switch from ipoe to ipoe'
        #					#serviceName=''
        #		else:
        #			print 'AT_ERROR : could not get layer3interface info'
        #			exit(1)

        #print 'service name is : ', serviceName
        # wanInf=atm0&wanL2IfName=atm0%2F%280_0_35%29&
        # wanInf=ppp0&wanL2IfName=atm0%2F%280_0_35%29&
        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'wanInf':
                ev = os.getenv('TMP_CUSTOM_WANINF')
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
            #			if k == 'serviceName' :
            #				ev = serviceName
            #				#if ev :
            #				print 'service name change to  :', ev
            #				v = ev
            #					#print 'v=%s and ev=%s' % (v,ev)
            #				body.updateValueByIndex(index, v)
            #				continue
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
            if k == 'pppUserName':
                is_dhcp = body.value('enblDhcpClnt')
                if is_dhcp == '0':
                    ev = os.getenv('U_DUT_CUSTOM_PPP_USER')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
            if k == 'pppPassword':
                is_dhcp = body.value('enblDhcpClnt')
                if is_dhcp == '0':
                    ev = os.getenv('U_DUT_CUSTOM_PPP_PWD')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
        return body

		
		
		