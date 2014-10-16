#       wireless_basic.py
#       
#       Copyright 2011 rayofox <rayofox@rayofox-test>
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
    "wireless_enable_type=1"] = 'apply_page=wireless_basic.html%3Fssid%3Dath0&waiting_page=waiting_page.html&waiting_page_leftmenu=2&waiting_page_topmenu=1&wep_active=1&wireless_vap_name=ath0&wireless_enable_type=1&wireless_ssid=549B3313&wireless_multiple_ssid=ath0&wireless_channel=3&wireless_keep_channel=0&wireless_wep_enable_type=1&wep_key_len=0&wep_key_mode=0&wep_key_code=0987654321'
body_fmts["wireless_enable_type=0"] = 'wireless_vap_name=ath0&wireless_enable_type=0&wireless_multiple_ssid=ath0'
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
        #	create rule
        #	POST /scpmapp.cmd HTTP/1.1
        #
        #	action	add                                         action	del
        #	pmAppName	some_rule                               app_id	0
        #	protocol1	TCP                                     rule_id	0
        #	eStart1	7777                                        needthankyou	advancedsetup_applications.html
        #	eEnd1	8888
        #	iStart1	4444
        #	iEnd1	4444
        #	needthankyou	advancedsetup_applications.html



        fmt = body.fmt()

        is_add = body.value('action')

        if is_add == 'add':
            print '== to create application rule'

            new_iStart = os.getenv('U_CUSTOM_PFO_INTERNAL_START', os.getenv('U_TR069_DEF_INTERNAL_PORT'))
            new_iEnd = os.getenv('U_CUSTOM_PFO_INTERNAL_END', os.getenv('U_TR069_DEF_INTERNAL_PORT_END_RANGE'))
            new_eStart = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', os.getenv('U_TR069_DEF_EXTERNAL_PORT'))
            new_eEnd = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE'))

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'pmAppName':
                    srvName = os.getenv('U_CUSTOM_APF_SERVICE_NAME')
                    if srvName:
                        body.updateValueByIndex(index, srvName)
                    continue
                elif k == 'eStart1':
                    ev = new_eStart
                    if ev:
                        v = ev
                        print '== change eStart1 to : ', v
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'eEnd1':
                    ev = new_eEnd
                    if ev:
                        v = ev
                        print '== change eEnd1 to : ', v
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'iStart1' or k == 'iEnd1':
                    ev = new_eStart
                    if ev:
                        v = ev
                        print '== change %s to %s ' % (k, v)
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'protocol1':
                    pfo_proto = os.getenv('U_CUSTOM_PFO_PROTO', 'NULL_NULL')

                    if pfo_proto == 'TCP':
                        body.updateValueByIndex(index, pfo_proto)
                    elif pfo_proto == 'UDP':
                        body.updateValueByIndex(index, pfo_proto)
                    continue
        elif is_add == 'del':
            print '== to delete application rule'

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'app_id':
                    ev = os.getenv('APF_RULE_INDEX')
                    if ev:
                        v = ev
                        print '== change app_id to : ', v
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'rule_id':
                    ev = os.getenv('APF_RULE_INDEX')
                    if ev:
                        v = ev
                        print '== change rule_id to : ', v
                    body.updateValueByIndex(index, v)
                    continue

        return body
