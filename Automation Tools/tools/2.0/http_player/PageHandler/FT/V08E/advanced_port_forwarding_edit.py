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
        #	POST /advanced_port_forwarding_edit.cgi HTTP/1.1
        #
        #	apply_page	advanced_port_forwarding.html
        #	waiting_page	waiting_page.html
        #	waiting_page_topmenu	5
        #	waiting_page_leftmenu	1
        #	adv_portforwarding_edit_otype	ADD
        #	adv_portforwarding_edit_ids	-1
        #	adv_portforwarding_edit_rules	-1,TCP,Any -&gt 1234,false,false,false,ADD
        #	adv_portforwarding_edit_servicename	alex
        #	adv_portforwarding_edit_servicedesc	alex_rule
        #
        #	submit_button_name	btn_delete
        #	apply_page	advanced_port_forwarding.html
        #	waiting_page	waiting_page.html
        #	waiting_page_topmenu	5
        #	waiting_page_leftmenu	1
        #	adv_portforwarding_ids	3
        ################################################################################################


        fmt = body.fmt()

        is_delete = False

        is_add = False

        if body.hasKey('submit_button_name'):
            if body.value('submit_button_name') == 'btn_delete':
                is_delete = True

        if body.hasKey('adv_portforwarding_edit_otype'):
            if body.value('adv_portforwarding_edit_otype') == 'ADD':
                is_add = True

        if is_delete:
            print '== to delete a port forwarding rule'
            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'adv_portforwarding_ids':
                    ev = os.getenv('APF_RULE_INDEX')
                    if ev:
                        v = ev
                        print '== change adv_portforwarding_ids to : ', v
                    body.updateValueByIndex(index, v)
                    continue

        if is_add:
        #	adv_portforwarding_edit_rules	-1,TCP,Any -&gt 1234,false,false,false,ADD
        #	adv_portforwarding_edit_servicename	alex
        #	adv_portforwarding_edit_servicedesc	alex_rule
        #	+','+
            print '== to add a port forwarding rule'
            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'adv_portforwarding_edit_rules':
                    v_elems = v.split(',')

                    new_eStart_add = os.getenv('U_CUSTOM_PFO_EXTERNAL_START',
                                               os.getenv('U_TR069_DEF_EXTERNAL_PORT', '5000'))
                    new_eEnd_add = os.getenv('U_CUSTOM_PFO_EXTERNAL_END',
                                             os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE', '5005'))
                    pfo_proto = os.getenv('U_CUSTOM_PFO_PROTO', 'TCP')

                    v = v_elems[0] + ',' + pfo_proto + ',' + 'Any -&gt ' + new_eStart_add + '-' + new_eEnd_add + ',' +
                        v_elems[3] + ',' + v_elems[4] + ',' + v_elems[5] + ',' + v_elems[6]
                    print '== new rule to add :', v
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'adv_portforwarding_edit_servicename' or k == 'adv_portforwarding_edit_servicedesc':
                    ev = os.getenv('U_CUSTOM_APF_SERVICE_NAME')
                    if ev:
                        v = ev
                        print '== change %s to %s ' % (k, v)
                    body.updateValueByIndex(index, v)
                    continue

        return body
