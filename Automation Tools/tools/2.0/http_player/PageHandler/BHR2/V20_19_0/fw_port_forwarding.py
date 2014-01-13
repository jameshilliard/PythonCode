#       template.py
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

    #
    #self.m_isHash = True
    #self.m_replPOST = True
    #self.m_replGET = False


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
        #arr = {}
        #arr.has_key('')
        #	port_range	6666 External and Internal
        #	Specify_ip	192.168.1.150 --> LAN IP
        #	edit_dst_ports	5555 -->External
        #	fwd_port	6666 -->Internal
        #	&enabled_1_defval=1&enabled_1=1&1_defval=0&1=1&enabled_2_defval=1&enabled_2=1&2_defval=0&2=1
        #	mimic_button_field	submit_button_add_portfw: ..

        is_del = body.value('mimic_button_field')
        if is_del == 'submit_button_add_portfw: ..':
            print '== to add a rule'

            fmt = body.fmt()
            #all_port = 0
            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]

                if k == 'port_range':
                    # both lan port and dut port
                    port_range_ori = body.value('port_range')

                    iStart = os.getenv('U_CUSTOM_PFO_INTERNAL_START', os.getenv('U_TR069_DEF_INTERNAL_PORT'))
                    iEnd = os.getenv('U_CUSTOM_PFO_INTERNAL_END', os.getenv('U_TR069_DEF_INTERNAL_PORT_END_RANGE'))
                    #eStart = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', os.getenv('U_TR069_DEF_EXTERNAL_PORT'))
                    #eEnd = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE'))

                    m_range = r'-'
                    if len(re.findall(m_range, port_range_ori)) > 0:
                        port_range = iStart + '-' + iEnd
                    else:
                        port_range = iStart
                    body.updateValueByIndex(index, port_range)
                    continue
                elif k == 'local_host_list':
                    #	local_host_list	192.168.1.100
                    Specify_ip = os.getenv('U_CUSTOM_PFO_SERVER', 'NULL_NULL')
                    if Specify_ip == 'NULL_NULL':
                        Specify_ip = os.getenv('G_HOST_TIP0_1_0')

                    if body.value('local_host_list') == 'specify':
                        #	Specify_ip	192.168.1.100
                        body.updateValue('Specify_ip', Specify_ip)
                    else:
                        body.updateValue('local_host_list', Specify_ip)
                    continue
                elif k == 'Specify_ip':
                    #	lan PC
                    #Specify_ip = os.getenv('G_HOST_TIP0_1_0')
                    Specify_ip = os.getenv('U_CUSTOM_PFO_SERVER', 'NULL_NULL')
                    if Specify_ip == 'NULL_NULL':
                        Specify_ip = os.getenv('G_HOST_TIP0_1_0')

                    body.updateValueByIndex(index, Specify_ip)
                    continue
                elif k == 'edit_dst_ports':
                    #	external ports can be a range
                    edit_dst_ports_ori = body.value('edit_dst_ports')

                    eStart = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', 'NULL_NULL')
                    eEnd = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', 'NULL_NULL')

                    if eStart == 'NULL_NULL' and eEnd == 'NULL_NULL':
                        iStart = os.getenv('U_CUSTOM_PFO_INTERNAL_START', os.getenv('U_TR069_DEF_INTERNAL_PORT'))
                        iEnd = os.getenv('U_CUSTOM_PFO_INTERNAL_END', os.getenv('U_TR069_DEF_INTERNAL_PORT_END_RANGE'))

                        m_range = r'-'
                        if len(re.findall(m_range, edit_dst_ports_ori)) > 0:
                            edit_dst_ports = iStart + '-' + iEnd
                        else:
                            edit_dst_ports = iStart
                    else:

                        #eStart = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', os.getenv('U_TR069_DEF_EXTERNAL_PORT'))
                        #eEnd = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE'))

                        m_range = r'-'
                        if len(re.findall(m_range, edit_dst_ports_ori)) > 0:
                            edit_dst_ports = eStart + '-' + eEnd
                        else:
                            edit_dst_ports = eStart


                    #edit_dst_ports = os.getenv('U_TR069_DEF_EXTERNAL_PORT')
                    body.updateValueByIndex(index, edit_dst_ports)
                    continue
                elif k == 'fwd_port':
                    #	internal port , cannot be a range
                    fwd_port = os.getenv('U_CUSTOM_PFO_INTERNAL_START', os.getenv('U_TR069_DEF_INTERNAL_PORT'))
                    body.updateValueByIndex(index, fwd_port)
                    continue
        elif is_del == 'submit_button_delete: ..':
            print '== to delete a rule'
            #	&enabled_1_defval=1&enabled_1=1&1_defval=0&1=1&enabled_2_defval=1&enabled_2=1&2_defval=0&2=1
            #	enabled_0_defval=1	&enabled_0=1	&0_defval=0&0=1
            #	def addKeyAndValue(self,key,val)
            #	def updateKeyAndValueByIndex(self,index,newkey,newval) :
            #	def deleteKey(self,key)

            delindexs = os.getenv('PFO_RULE_INDEX', 'NULL_NULL')
            if delindexs != 'NULL_NULL':
                delidxs = delindexs.split(',')

                if '0' not in delidxs:
                    body.deleteKey('enabled_0_defval')
                    body.deleteKey('enabled_0')
                    body.deleteKey('0_defval')
                    body.deleteKey('0')
                for delindex in delidxs:
                    body.addKeyAndValue('enabled_' + delindex + '_defval', '1')
                    body.addKeyAndValue('enabled_' + delindex, '1')
                    body.addKeyAndValue(delindex + '_defval', '0')
                    body.addKeyAndValue(delindex, '1')

        return body

