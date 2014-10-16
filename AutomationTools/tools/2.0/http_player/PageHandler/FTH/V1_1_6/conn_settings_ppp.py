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
    "service_name="] = 'active_page=9144&active_page_str=page_conn_settings_ppp0&page_title=Connection+Properties&mimic_button_field=submit_button_submit%3A+..&button_value=ppp0&strip_page_top=0&tab4_selected=0&tab4_visited_0=1&sym_show_detail_conf=1&network=1&network_defval=1&mtu_mode=1&mtu_mode_defval=1&depend_on_name=eth1&depend_on_name_defval=eth1&service_name_defval=&service_name=&on_demand_defval=0&reconnect_time_defval=30&reconnect_time=30&ppp_username_defval=verizonfios&ppp_username=rayofox001&ppp_password_337938148=111111&ppp_password_retype_337938148=111111&auth_pap_defval=1&auth_pap=1&auth_chap_defval=1&auth_chap=1&auth_mschapv1_defval=1&auth_mschapv1=1&auth_mschapv2_defval=1&auth_mschapv2=1&comp_bsd=1&comp_bsd_defval=1&comp_deflate=1&comp_deflate_defval=1&ip_settings=2&ip_settings_defval=2&override_subnet_mask_defval=0&static_netmask_override0_defval=0&static_netmask_override0=0&static_netmask_override1_defval=0&static_netmask_override1=0&static_netmask_override2_defval=0&static_netmask_override2=0&static_netmask_override3_defval=0&static_netmask_override3=0&dns_option=1&dns_option_defval=1&route_level=4&route_level_defval=4&route_metric_defval=1&route_metric=1&default_route_defval=1&default_route=1&is_trusted_defval=1&is_trusted=1'
body_fmts[
    "description_defval="] = 'active_page=9144&active_page_str=page_conn_settings_ppp0&page_title=Connection+Properties&mimic_button_field=submit_button_conn_enable%3A+..&button_value=ppp0&strip_page_top=0&tab4_selected=0&tab4_visited_0=1&sym_show_detail_conf=0&description_defval=WAN+PPPoE&description=WAN+PPPoE'

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

        # TODO : add your page name
        self.info('Page ' + os.path.basename(__file__))

        # add body format
        for (k, v) in body_fmts.items():
            self.addStrBodyFmt(k, v)
        # add query format
        for (k, v) in query_fmts.items():
            self.addStrQueryFmt(k, v)

        # TODO : setup replace mode
        #self.m_isHash = True
        #self.m_replPOST = True
        #self.m_replGET = False

    def checkDetail(self, fmt, page_info):
        """
        TODO : check detail difference
        """
        pass

    def replQuery(self, query):
        """
        """
        # TODO : Implement your replacement without hash

        pass


    def replBody(self, body):
        """
        {'active_page': '9144',
          'active_page_str': 'page_conn_settings_ppp0',
          'auth_chap': '1',
          'auth_chap_defval': '1',
          'auth_mschapv1': '1',
          'auth_mschapv1_defval': '1',
          'auth_mschapv2': '1',
          'auth_mschapv2_defval': '1',
          'auth_pap': '1',
          'auth_pap_defval': '1',
          'button_value': 'ppp0',
          'comp_bsd': '1',
          'comp_bsd_defval': '1',
          'comp_deflate': '1',
          'comp_deflate_defval': '1',
          'default_route': '1',
          'default_route_defval': '1',
          'depend_on_name': 'eth1',
          'depend_on_name_defval': 'eth1',
          'dns_option': '1',
          'dns_option_defval': '1',
          'ip_settings': '2',
          'ip_settings_defval': '2',
          'is_trusted': '1',
          'is_trusted_defval': '1',
          'mimic_button_field': 'submit_button_submit%3A+..',
          'mtu_mode': '1',
          'mtu_mode_defval': '1',
          'network': '1',
          'network_defval': '1',
          'on_demand_defval': '0',
          'override_subnet_mask_defval': '0',
          'page_title': 'Connection+Properties',
          'ppp_password_337938148': '111111',
          'ppp_password_retype_337938148': '111111',
          'ppp_username': 'rayofox001',
          'ppp_username_defval': 'verizonfios',
          'reconnect_time': '30',
          'reconnect_time_defval': '30',
          'route_level': '4',
          'route_level_defval': '4',
          'route_metric': '1',
          'route_metric_defval': '1',
          'service_name': '',
          'service_name_defval': '',
          'static_netmask_override0': '0',
          'static_netmask_override0_defval': '0',
          'static_netmask_override1': '0',
          'static_netmask_override1_defval': '0',
          'static_netmask_override2': '0',
          'static_netmask_override2_defval': '0',
          'static_netmask_override3': '0',
          'static_netmask_override3_defval': '0',
          'strip_page_top': '0',
          'sym_show_detail_conf': '1',
          'tab4_selected': '0',
          'tab4_visited_0': '1'},
        """
        #

        sess_id = ''
        cookie = self.m_player.m_sender.getCookie()
        if cookie and len(cookie):
            # match rg_cookie_session_id=1648344918
            z = cookie.split('=')
            if len(z) > 1:
                sess_id = z[1].split(';')[0]

        usr = os.environ.get('U_DUT_CUSTOM_PPP_USER', 'test')
        pwd = os.environ.get('U_DUT_CUSTOM_PPP_PWD', '111111')


        #body.updateValue('ppp_username',usr)
        #body.updateKeyAndValue('ppp_username','ppp_username' + str(sess_id),pwd)
        key = 'ppp_password_retype_' + str(sess_id)

        fmt = body.fmt()

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'ppp_username':
                ev = usr
                if ev:
                    print 'U_DUT_CUSTOM_PPP_USER is :', ev
                    v = ev
                else:
                    print 'U_DUT_CUSTOM_PPP_USER is not defined !'
                #print 'v=%s and ev=%s' % (v,ev)
                body.updateValueByIndex(index, v)
                continue

        #
        key2up = []
        m = r'ppp_password_.*'
        key2up = body.matchKeys(m)

        for key in key2up:
            if key.startswith('ppp_password_retype_'):
                body.updateKeyAndValue(key, 'ppp_password_retype_' + str(sess_id), pwd)
            elif key.startswith('ppp_password_'):
                body.updateKeyAndValue(key, 'ppp_password_' + str(sess_id), pwd)

        return body

	
	
	
	
