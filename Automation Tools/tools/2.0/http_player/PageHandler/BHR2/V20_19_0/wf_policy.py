#	   template.py
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

# TODO : add your keyword-format into map
body_fmts[
    "page_fw_port_forwarding"] = 'active_page=9012&active_page_str=page_fw_port_forwarding&page_title=Port+Forwarding&mimic_button_field=submit_button_add_portfw%3A+..&button_value=local_host_list&strip_page_top=0&tab4_selected=2&tab4_visited_2=1&local_host_list=specify&local_host_list_defval=specify&Specify_ip_defval=&Specify_ip=192.168.1.150&svc_service_combo=USER_DEFINED&svc_service_combo_defval=USER_DEFINED&svc_entry_protocol=6&svc_entry_protocol_defval=6&port_range_defval=65535&port_range=6666'
#body_fmts["wireless_wep_enable_type=0"] 	 = 'active_page=9120&active_page_str=page_actiontec_wireless_basic_setup&page_title=Basic+Security+Settings&mimic_button_field=submit_button_submit%3A+..&button_value=9120&strip_page_top=0&tab4_selected=1&tab4_visited_1=1&wireless_enable_type=1&ssid=raywifi_bhr2_001&channel=-1&keep_channel_defval=0&wireless_wep_enable_type=0&wireless_conn_info_ssid=Enabled&wireless_conn_info_mac=Disabled&wireless_conn_info_mode=Compatibility+Mode%28802.11b%2Fg%2Fn%29&wireless_conn_info_packet_sent=99&wireless_conn_info_packet_rece=0'
#-----------------------------------------------------------------------
query_fmts = {}
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
        """
        fmt = body.fmt()
        #	wf_lan_comp_allbox=abcd+
        #	wf_lan_comp_sel=abcd+
        #		wf_lan_comp_allbox	192.168.1.200
        #		wf_lan_comp_sel	192.168.1.100 192.168.1.200

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'wf_lan_comp_sel':
                #v_ori = body.value(k)
                if v != '':
                    print '== the original wf_lan_comp_sel is >%s<' % (v)

                    m_all_lan = r'.* .* '
                    rc_all_lan = re.findall(m_all_lan, v)
                    if len(rc_all_lan) > 0:
                        print '== to block website for all LAN PC'
                        eth1 = os.getenv('G_HOST_TIP0_1_0', '192.168.1.100')
                        eth2 = os.getenv('G_HOST_TIP0_2_0', '192.168.1.200')
                        v_new = eth1 + ' ' + eth2 + ' '
                        print '== change LAN PC list from %s to %s' % (v, v_new)
                        v = v_new
                    else:
                        print '== to block website for one LAN PC'
                        eth1 = os.getenv('G_HOST_TIP0_1_0', '192.168.1.100')
                        v_new = eth1 + ' '
                        print '== change LAN PC list from %s to %s' % (v, v_new)
                        v = v_new
                    body.updateValueByIndex(index, v)

                continue
            elif k == 'mimic_button_field':
            #v_ori = body.value(k)
            #	active_page	6023                                active_page	6023                            active_page	6023
            #	page_title	Rule Summary                        page_title	Rule Summary                    page_title	Rule Summary
            #	mimic_button_field	wf_policy_remove: 0..       mimic_button_field	wf_policy_remove: 1..   mimic_button_field	wf_policy_remove: 0..
            #	button_value	                                button_value	1391                        button_value	1
            #	strip_page_top	0                               strip_page_top	0                           strip_page_top	0
            #	tab4_selected	1                               tab4_selected	1                           tab4_selected	1
            #	tab4_visited_1	1                               tab4_visited_1	1                           tab4_visited_1	1
            #	(null)	192.168.1.100                           (null)	192.168.1.100                       (null)	192.168.1.100
            #	--------------------------------------------    (null)	192.168.1.200                    -  ------------------------------------------
                #print '===========      here     ============'
                is_del = v
                m_del = r'wf_policy_remove'
                rc_del = re.findall(m_del, is_del)
                if len(rc_del) > 0:
                    #print is_del
                    delindex = os.getenv('WBL_RULE_INDEX', '0')
                    v_new = 'wf_policy_remove: ' + delindex + '..'
                    v = v_new
                    print '== to delete a rule with rule index :', delindex
                    body.updateValueByIndex(index, v)
                continue

        return body
