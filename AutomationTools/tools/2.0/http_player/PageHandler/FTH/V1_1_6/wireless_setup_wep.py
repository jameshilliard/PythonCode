#       wireless_setup_wep.py
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
    "wep_mode="] = 'active_page=6006&active_page_str=page_actiontec_wireless_setup_wep&page_title=WEP+Key&mimic_button_field=submit_button_wireless_apply%3A+..&button_value=9121&strip_page_top=0&wep_mode=0&wep_mode_defval=0&wl_auth=0&wl_auth_defval=0&wep_active=0&0_8021x_key_hex_0=12345678901234567890123456&0_8021x_mode_0=0&0_8021x_key_len_0=104&0_8021x_key_hex_1=12345678901234567890123456&0_8021x_mode_1=0&0_8021x_key_len_1=104&0_8021x_key_hex_2=12345678901234567890123456&0_8021x_mode_2=0&0_8021x_key_len_2=104&wep_active_defval=3&0_8021x_key_hex_3=468766400E24F1FE67F0284000&0_8021x_mode_3=0&0_8021x_key_len_3=104'
#form_fmt["wpa"] = ''
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
        form = body.hash()
        if form:
        #
            wep_active = form.get('wep_active', None)
            if wep_active: # get the active key
                idx = int(wep_active)
                kcode = '0_8021x_key_hex_' + str(idx)
                kmode = '0_8021x_mode_' + str(idx)
                klen = '0_8021x_key_len_' + str(idx)
                vlen = form.get(klen, None)
                vcode = form.get(kcode, None)
                if vlen and vcode:
                    if vlen == '40': # wep64
                        wepkey64 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY64bit' + str(idx + 1))
                        if wepkey64:
                            body.updateValue(kcode, wepkey64)
                    elif vlen == '104': # wep128
                        wepkey128 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY128bit' + str(idx + 1))
                        if wepkey128:
                            body.updateValue(kcode, wepkey128)

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

	
	
	
	
