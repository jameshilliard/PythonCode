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
    "editWanL2IfName"] = 'action=edit&editWanL2IfName=atm0&portId=0&atmVpi=0&atmVci=32&connMode=0&modulationType=ADSL_Modulation_All&atmServiceCategory=UBR&atmPeakCellRate=0&atmSustainedCellRate=0&atmMaxBurstSize=0&atmencap=LLC&linktype=EoA&atmmtu=1492&enblQos=1&adsl_trspt_mode=auto&wanIfName=ppp0&autoselect=auto&manualselect=auto&redirect=advancedsetup_broadbandsettings.html&sessionKey=1720475378&needthankyou=advancedsetup_broadbandsettings.html'
#body_fmts["pppUserName"] = 'serviceWANType=0&serviceId=1&wanInf=ppp0&wanL2IfName=atm0%2F%280_0_35%29&pppUserName=hyin&pppPassword=111111&pppIpExtension=0&enblFirewall=1&enblNat=1&useStaticIpAddress=0&pppLocalIpAddress=0.0.0.0&enblLan2=0&vipmode=0&PPPAutoConnect=1&enblOnDemand=1&pppToBridge=0&enblEnetWan=0&ntwkPrtcl=0&enblIgmp=1&serviceName=&action=add&redirect=advancedsetup_wanipaddress.html&sessionKey=921262268&dnsIfc=&dnsPrimary=0.0.0.0&dnsSecondary=0.0.0.0&atmencaps=LLC&needthankyou=advancedsetup_wanipaddress.html&noneeddel=0'
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
        U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE = os.getenv('U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE', '1')
        if U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE == '0':
            print 'not do replacement , it is all manually set'
        else:
            fmt = body.fmt()

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'wanIfName':
                    ev = os.getenv('TMP_CUSTOM_WANINF')
                    if ev:
                        print 'TMP_CUSTOM_WANINF is :', ev
                        v = ev
                    else:
                        print 'TMP_CUSTOM_WANINF is not defined !'
                    #print 'v=%s and ev=%s' % (v,ev)
                    body.updateValueByIndex(index, v)
                    continue
                if k == 'editWanL2IfName':
                    ev = os.getenv('TMP_CUSTOM_EDITWANL2INFNAME')
                    if ev:
                        print 'TMP_CUSTOM_EDITWANL2INFNAME is :', ev
                        v = ev
                    #print 'v=%s and ev=%s' % (v,ev)
                    body.updateValueByIndex(index, v)
                    continue
        return body


	
	
	
	
