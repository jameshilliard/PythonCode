#       wireless_setup_wpa.py
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
    "active_page_str=page_actiontec_wireless_setup_wpa2"] = 'active_page=6015&active_page_str=page_actiontec_wireless_setup_wpa2&page_title=WPA2&mimic_button_field=submit_button_wireless_apply%3A+..&button_value=9121&strip_page_top=0&wpa_sta_auth_type=1&wpa_sta_auth_type_defval=1&wpa_sta_auth_shared_key_defval=1234567890&wpa_sta_auth_shared_key=1234567890&psk_representation=1&psk_representation_defval=1&wpa_cipher=2&wpa_cipher_defval=2&is_grp_key_update_defval=3600&is_grp_key_update=1&8021x_rekeying_interval_defval=3600&8021x_rekeying_interval=3600'
body_fmts[
    "active_page_str=page_actiontec_wireless_setup_wpa&"] = 'active_page=6008&active_page_str=page_actiontec_wireless_setup_wpa&page_title=WPA&mimic_button_field=submit_button_wireless_apply%3A+..&button_value=9121&strip_page_top=0&wpa_sta_auth_type=1&wpa_sta_auth_type_defval=1&wpa_sta_auth_shared_key_defval=1234567890&wpa_sta_auth_shared_key=1234567890&psk_representation=1&psk_representation_defval=1&wpa_cipher=2&wpa_cipher_defval=2&is_grp_key_update_defval=3600&is_grp_key_update=1&8021x_rekeying_interval_defval=3600&8021x_rekeying_interval=3600'
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
        """

        if body.hasKey('wpa_sta_auth_shared_key'):
            psk = os.getenv('U_WIRELESS_CUSTOM_WPAPSK')
            if psk:
                body.updateValue('wpa_sta_auth_shared_key', psk)
        elif body.hasKey('wpa_sta_auth_shared_key_hex'):
            print "==", "Do not support WPA PSK HEX password"
            exit(1)

        wireless_radius_server = os.getenv('U_WIRELESS_RADIUS_SERVER', '192.168.53.254')
        ips = wireless_radius_server.split('.')

        for key in body.keys():
            m_radius_client_secret = r'radius_client_secret_\d*'
            rc_radius_client_secret = re.findall(m_radius_client_secret, key)

            if len(rc_radius_client_secret) > 0:
                #print len(rc_radius_client_secret)
                old_radius_client_secret = rc_radius_client_secret[0]
                new_radius_client_secret = os.getenv('TMP_SESSION_ID')
                if new_radius_client_secret:
                    new_radius_client_secret = 'radius_client_secret_' + new_radius_client_secret
                    body.updateKeyAndValue(old_radius_client_secret, new_radius_client_secret,
                                           os.getenv('U_WIRELESS_RADIUS_KEY', 'automation'))

        if body.hasKey('radius_client_server_ip0'):
            ip0 = str(ips[0])
            if ip0:
                body.updateValue('radius_client_server_ip0', ip0)
        if body.hasKey('radius_client_server_ip1'):
            ip1 = str(ips[1])
            if ip1:
                body.updateValue('radius_client_server_ip1', ip1)
        if body.hasKey('radius_client_server_ip2'):
            ip2 = str(ips[2])
            if ip2:
                body.updateValue('radius_client_server_ip2', ip2)
        if body.hasKey('radius_client_server_ip3'):
            ip3 = str(ips[3])
            if ip3:
                body.updateValue('radius_client_server_ip3', ip3)

        return body


	
	
	
	
