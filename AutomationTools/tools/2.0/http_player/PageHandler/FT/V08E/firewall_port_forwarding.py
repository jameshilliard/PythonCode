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
        #	----------------------------------------------------------------------------------------------------------
        #	list                                                    specify
        #
        #	firewall_forward_action	add                             firewall_forward_action	add
        #	firewall_forward_basic_advanced	1                       firewall_forward_basic_advanced	1
        #	firewall_forward_servicename	                        firewall_forward_servicename
        #	waiting_page	waiting_page.html                       waiting_page	waiting_page.html
        #	waiting_page_topmenu	3                               waiting_page_topmenu	3
        #	waiting_page_leftmenu	3                               waiting_page_leftmenu	3
        #	apply_page	firewall_port_forwarding.html               apply_page	firewall_port_forwarding.html
        #	firewall_forward_localhost_list	192.168.1.100           firewall_forward_localhost_list	-1
        #	firewall_forward_localhost	                            firewall_forward_localhost	192.168.1.100
        #	firewall_forward_protocol	-2                          firewall_forward_protocol	-2
        #	firewall_forward_protocol_custom	TCP                 firewall_forward_protocol_custom	TCP
        #	firewall_forward_protocol_ports_custom	4488            firewall_forward_protocol_ports_custom
        #	firewall_forward_protocol_advanced	TCP                 firewall_forward_protocol_advanced	UDP
        #	firewall_forward_sourceports_advanced_list	0           firewall_forward_sourceports_advanced_list	0
        #	firewall_forward_sourceports_advanced	                firewall_forward_sourceports_advanced
        #	firewall_forward_destports_advanced_list	-1          firewall_forward_destports_advanced_list	-1
        #	firewall_forward_destports_advanced	5555-6666           firewall_forward_destports_advanced	5555-6666
        #	firewall_forward_wanconnection_list	wildcast            firewall_forward_wanconnection_list	wildcast
        #	firewall_forward_fwports_advanced_list	-1              firewall_forward_fwports_advanced_list	-1
        #	firewall_forward_fwports_advanced	7777-8888           firewall_forward_fwports_advanced	6666-7777
        #	firewall_forward_remote_ipaddress	192.168.55.254      firewall_forward_remote_ipaddress	192.168.55.254
        #	firewall_forward_schedule_advanced	                    firewall_forward_schedule_advanced
        #	----------------------------------------------------------------------------------------------------------

        fmt = body.fmt()

        action = body.value('firewall_forward_action')

        if action == 'add':
            print '== to add a rule'

            is_apf = body.value('firewall_forward_servicename')

            if str(is_apf) == '':
                print '== replacement of port-forwarding !'

                new_iStart_add = os.getenv('U_CUSTOM_PFO_INTERNAL_START', os.getenv('U_TR069_DEF_INTERNAL_PORT'))
                new_iEnd_add = os.getenv('U_CUSTOM_PFO_INTERNAL_END', os.getenv('U_TR069_DEF_INTERNAL_PORT_END_RANGE'))
                new_eStart_add = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', os.getenv('U_TR069_DEF_EXTERNAL_PORT'))
                new_eEnd_add = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE'))

                for index, k in enumerate(fmt['keys']):
                    v = fmt['vals'][index]
                    if k == 'firewall_forward_localhost_list':
                        pfo_server = os.getenv('U_CUSTOM_PFO_SERVER', 'NULL_NULL')
                        if pfo_server == 'NULL_NULL':
                            pfo_server = os.getenv('G_HOST_TIP0_1_0')

                        if v != '-1':
                            body.updateValueByIndex(index, pfo_server)
                        else:
                            body.updateValue('firewall_forward_localhost', pfo_server)
                        continue
                    elif k == 'firewall_forward_protocol_advanced':
                        pfo_proto = os.getenv('U_CUSTOM_PFO_PROTO', 'NULL_NULL')

                        if pfo_proto == 'TCP':
                            body.updateValueByIndex(index, 'TCP')
                        elif pfo_proto == 'UDP':
                            body.updateValueByIndex(index, 'UDP')
                        continue
                    elif k == 'firewall_forward_destports_advanced':
                        ev = new_eStart_add + '-' + new_eEnd_add
                        if ev:
                            v = ev
                            print '== change firewall_forward_destports_advanced to : ', v
                        body.updateValueByIndex(index, v)
                        continue
                    elif k == 'firewall_forward_fwports_advanced':
                        is_internal_specified = body.value('firewall_forward_fwports_advanced')

                        if is_internal_specified != '0':
                            ev = new_iStart_add + '-' + new_iEnd_add
                            if ev:
                                v = ev
                                print '== change firewall_forward_fwports_advanced to : ', v
                            body.updateValueByIndex(index, v)
                        continue
                    elif k == 'firewall_forward_remote_ipaddress':
                        wan_ip = os.getenv('U_CUSTOM_PFO_SERVER_WANADDR', 'NULL_NULL')
                        if wan_ip == 'NULL_NULL':
                            wan_ip = os.getenv('TMP_DUT_DEF_GW', os.getenv('G_HOST_TIP1_2_0'))

                        ev = wan_ip
                        if ev:
                            v = ev
                            print '== change firewall_forward_remote_ipaddress to : ', v
                        body.updateValueByIndex(index, v)
                        continue
            else:
                print '== replacement for application forwarding'

                new_iStart_add = os.getenv('U_CUSTOM_PFO_INTERNAL_START', os.getenv('U_TR069_DEF_INTERNAL_PORT'))
                new_iEnd_add = os.getenv('U_CUSTOM_PFO_INTERNAL_END', os.getenv('U_TR069_DEF_INTERNAL_PORT_END_RANGE'))

                for index, k in enumerate(fmt['keys']):
                    v = fmt['vals'][index]
                    if k == 'firewall_forward_localhost_list':
                        pfo_server = os.getenv('U_CUSTOM_PFO_SERVER', 'NULL_NULL')
                        if pfo_server == 'NULL_NULL':
                            pfo_server = os.getenv('G_HOST_TIP0_1_0')

                        if v != '-1':
                            body.updateValueByIndex(index, pfo_server)
                        else:
                            body.updateValue('firewall_forward_localhost', pfo_server)
                        continue
                    elif k == 'firewall_forward_fwports_advanced':
                        is_internal_specified = body.value('firewall_forward_fwports_advanced_list')

                        if is_internal_specified != '0':
                            ev = new_iStart_add + '-' + new_iEnd_add
                            if ev:
                                v = ev
                                print '== change firewall_forward_fwports_advanced to : ', v
                            body.updateValueByIndex(index, v)
                        continue
                    elif k == 'firewall_forward_remote_ipaddress':
                        wan_ip = os.getenv('U_CUSTOM_PFO_SERVER_WANADDR', 'NULL_NULL')
                        if wan_ip == 'NULL_NULL':
                            wan_ip = os.getenv('TMP_DUT_DEF_GW', os.getenv('G_HOST_TIP1_2_0'))

                        ev = wan_ip
                        if ev:
                            v = ev
                            print '== change firewall_forward_remote_ipaddress to : ', v
                        body.updateValueByIndex(index, v)
                        continue
                    elif k == 'firewall_forward_servicename':
                        servName = os.getenv('APF_SERVICE_NAME')
                        if servName:
                            v = servName
                            print '== change firewall_forward_servicename to ', v
                            body.updateValueByIndex(index, v)
                        continue

        elif action == 'delete':
            print '== to delete a rule'

            #	firewall_forward_action	delete
            #	firewall_forward_indexes_delete	.11_wildcast.
            #	waiting_page	waiting_page.html
            #	waiting_page_topmenu	3
            #	waiting_page_leftmenu	3
            #	apply_page	firewall_port_forwarding.html
            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'firewall_forward_indexes_delete':
                    delindex = os.getenv('PFO_RULE_INDEX')
                    if delindex:
                        v = '.' + delindex + '_wildcast.'
                        print '== change firewall_forward_indexes_delete to ', v
                        body.updateValueByIndex(index, v)
                    else:
                        delindex = os.getenv('APF_RULE_INDEX')
                        if delindex:
                            v = '.' + delindex + '_wildcast.'
                            print '== change firewall_forward_indexes_delete to ', v
                            body.updateValueByIndex(index, v)
                    continue

        return body
