#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#       BHR2_wi_repl.py
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
This replacement for pages :
wireless_basic.html
wireless_advanced.html
"""
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2011, Rayofox"
__version__ = "0.1"
__license__ = "MIT"
__history__ = """
Rev 0.1 : 2011/09/28
	Initial version, based on version :20.16.0
"""
#------------------------------------------------------------------------------

import os, sys
import httplib2, urllib
import re
import types
from pprint import pprint
from pprint import pformat
import logging
#------------------------------------------------------------------------------

class http_request_repl():
    """
    """
    cfg = {
    'description': 'no description',
    'protocol': 'HTTP',
    'destination': '',
    'method': '',
    'path': '',
    'body_len': 0,
    'query': '',
    'body': ''
    }
    # the repl handlers with page name
    hdlrs = {}

    def __init__(self):
        """
        """

        # A little magic - Everything called cmdXXX is a command
        for k in dir(self):
            if k[:5] == 'hdlr_':
                name = k[5:]
                method = getattr(self, k)
                self.hdlrs[name] = method
        pass

    def hdlr_page_actiontec_wireless_basic_setup(self, form):
        """
        """
        sample = """
		active_page	9120
		active_page_str	page_actiontec_wireless_basic_setup
		page_title	Basic Security Settings
		mimic_button_field	submit_button_submit: ..
		button_value	9120
		strip_page_top	0
		tab4_selected	1
		tab4_visited_1	1
		wireless_enable_type	1
		ssid	raytest009
		channel	-1
		keep_channel_defval	0
		wireless_wep_enable_type	1
		pref_conn_set_8021x_key_len	40
		pref_conn_set_8021x_key_mode	0
		actiontec_default_wep_key	8597DBC4B5
		actiontec_default_wep_key_128	8597DBC4B5
		actiontec_default_wep_key_ascii
		actiontec_default_wep_key_ascii_128
		wireless_conn_info_ssid	Disabled
		wireless_conn_info_mac	Disabled
		wireless_conn_info_mode	Mixed accepts 802.11b and 802.11g connections
		wireless_conn_info_packet_sent	74
		wireless_conn_info_packet_rece	0
		"""
        # wireless SSID1
        ssid = os.getenv('U_WIRELESS_SSID1')
        if ssid: form['ssid'] = ssid
        # WEP Key 64
        wepkey64 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY64bit1')
        if wepkey64: form['actiontec_default_wep_key'] = urllib.quote(wepkey64)
        # WEP Key 128
        wepkey128 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY128bit1')
        if wepkey128: form['actiontec_default_wep_key_128'] = urllib.quote(wepkey128)
        return form

    def hdlr_page_actiontec_wireless_setup_wep(self, form):
        """
        """
        sample = """
		active_page	6006
		active_page_str	page_actiontec_wireless_setup_wep
		page_title	WEP Key
		mimic_button_field	submit_button_wireless_apply: ..
		button_value	.
		strip_page_top	0
		wep_mode	0
		wep_mode_defval	0
		wl_auth	2
		wl_auth_defval	2
		wep_active_defval	0
		wep_active	0
		0_8021x_key_hex_0	12345678900000000000000000
		0_8021x_mode_0	0
		0_8021x_key_len_0	104
		0_8021x_key_hex_1	0123456789
		0_8021x_mode_1	0
		0_8021x_key_len_1	40
		0_8021x_key_hex_2
		0_8021x_mode_2	0
		0_8021x_key_len_2	40
		0_8021x_key_hex_3
		0_8021x_mode_3	0
		0_8021x_key_len_3	40
		"""
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
                    if wepkey64: form[kcode] = urllib.quote(wepkey64)
                elif vlen == '104': # wep128
                    wepkey128 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY128bit' + str(idx + 1))
                    if wepkey128: form[kcode] = urllib.quote(wepkey128)

        return form

        def hdlr_page_actiontec_wireless_setup_wpa(self, form):
            """
            """
            sample = """
			active_page	6008
			active_page_str	page_actiontec_wireless_setup_wpa
			page_title	WPA
			mimic_button_field	onchange: psk_representation..
			button_value	9121
			strip_page_top	0
			wpa_sta_auth_type	1
			wpa_sta_auth_type_defval	1
			wpa_sta_auth_shared_key_defval	1234567890
			wpa_sta_auth_shared_key	1234567890
			psk_representation	0
			psk_representation_defval	1
			wpa_cipher	3
			wpa_cipher_defval	3
			is_grp_key_update_defval	3600
			is_grp_key_update	1
			8021x_rekeying_interval_defval	3600
			8021x_rekeying_interval	3600
			"""
            if form.has_key('wpa_sta_auth_shared_key'):
                psk = os.getenv('U_WIRELESS_CUSTOM_WPAPSK')
                if psk: form['wpa_sta_auth_shared_key'] = urllib.quote(psk)
            elif form.has_key('wpa_sta_auth_shared_key_hex'):
                print "==", "Do not support WPA PSK HEX password"
                exit(1)
            #psk = os.getenv('U_WIRELESS_CUSTOM_WPAPSK')
            #if psk : form['wpa_sta_auth_shared_key_hex'] = urllib.quote(psk)
            return form

        def hdlr_page_actiontec_wireless_setup_wpa2(self, form):
            """
            """
            sample = """
			active_page	6015
			active_page_str	page_actiontec_wireless_setup_wpa2
			page_title	WPA2
			mimic_button_field	submit_button_wireless_apply: ..
			button_value	psk_representation
			strip_page_top	0
			wpa_sta_auth_type	1
			wpa_sta_auth_type_defval	1
			wpa_sta_auth_shared_key_defval
			wpa_sta_auth_shared_key	1233211234567
			psk_representation	1
			psk_representation_defval	0
			wpa_cipher	3
			wpa_cipher_defval	3
			is_grp_key_update_defval	3600
			is_grp_key_update	1
			8021x_rekeying_interval_defval	3600
			8021x_rekeying_interval	3600
			"""
            # The same as wpa
            return self.hdlr_page_actiontec_wireless_setup_wpa(form)

        #return form

    def hdlr_wireless_basic(self, form):
        """
        """
        sample = """
		wep_active	4
		wireless_vap_name	ath0
		wireless_enable_type	1
		wireless_ssid	bensonfiber
		wireless_channel	0
		wireless_keep_channel	1
		wireless_wep_enable_type	1
		wep_key_len	0
		wep_key_mode	0
		wep_key_code	1A2B3C4D5E
		"""
        # wireless SSID1
        ssid = os.getenv('U_WIRELESS_SSID1')
        if ssid: form['wireless_ssid'] = ssid

        wep_active = form.get('wep_active', None)
        if wep_active:
            klen = form.get('wep_key_len', 0)
            if klen == '0':
                wepkey64 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY64bit' + wep_active)
                if wepkey64: form['wep_key_code'] = urllib.quote(wepkey64)
            elif klen == '1':
                wepkey128 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY128bit' + wep_active)
                if wepkey128: form['wep_key_code'] = urllib.quote(wepkey128)

        return form

    def hdlr_wireless_advanced(self, form):
        """
        """
        #logger.debug('here')
        # WEP
        sample = """
			wep_mode	0
			radius_server_ip	0.0.0.0
			radius_server_port	1812
			radius_shared_secret
			wep_auth	0
			wep_key_0_code	1A2B3C4D5E
			wep_key_0_mode	0
			wep_key_0_len	0
			wep_key_1_code	1A2B3C4D5E0000000000000000
			wep_key_1_mode	0
			wep_key_1_len	1
			wep_active	3
			wep_key_2_code	3333333333
			wep_key_2_mode	0
			wep_key_2_len	0
			wep_key_3_code	4444444444
			wep_key_3_mode	0
			wep_key_3_len	0
		"""
        if form.has_key('wep_mode'):
            wep_active = form.get('wep_active', None)
            if wep_active: # get the active key
                idx = int(wep_active) - 1
                kcode = 'wep_key_' + str(idx) + '_code'
                kmode = 'wep_key_' + str(idx) + '_mode'
                klen = 'wep_key_' + str(idx) + '_len'
                vlen = form.get(klen, None)
                vcode = form.get(kcode, None)
                if vlen and vcode:
                    if vlen == '0': # wep64
                        wepkey64 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY64bit' + wep_active)
                        if wepkey64: form[kcode] = urllib.quote(wepkey64)
                    elif vlen == '1': # wep128
                        wepkey128 = os.getenv('U_WIRELESS_CUSTOM_WEP_KEY128bit' + wep_active)
                        if wepkey128: form[kcode] = urllib.quote(wepkey128)
            return form
        #pass

        # WPA
        sample = """
			wireless_security_enabled	WPA
			wpa_sta_auth_type	0
			wpa_pre_authentication	0
			wpa_sta_auth_shared_key	1233211234567
			wpa_psk_representation	0
			wpa_cipher	0
			wpa_is_grp_key_update	0
			wpa_grp_key_update_interval	0
			radius_server_ip	0.0.0.0
			radius_server_port	1812
			radius_shared_secret
		"""
        if form.has_key('wireless_security_enabled') and form['wireless_security_enabled'] == 'WPA':
            psk = os.getenv('U_WIRELESS_CUSTOM_WPAPSK')
            if psk: form['wpa_sta_auth_shared_key'] = urllib.quote(psk)
            return form
        #pass

        # WPA2
        sample = """
			wireless_security_enabled	WPA2
			wpa_sta_auth_type	0
			wpa_pre_authentication	1
			wpa_sta_auth_shared_key	1233211234567
			wpa_psk_representation	0
			wpa_cipher	2
			wpa_is_grp_key_update	0
			wpa_grp_key_update_interval	0
			radius_server_ip	0.0.0.0
			radius_server_port	1812
			radius_shared_secret
		"""

        if form.has_key('wireless_security_enabled') and form['wireless_security_enabled'] == 'WPA2':
            #logger.debug('here')
            psk = os.getenv('U_WIRELESS_CUSTOM_WPAPSK')
            if psk: form['wpa_sta_auth_shared_key'] = urllib.quote(psk)
            return form
        #pass
        return form

    def do_repl(self, _cfg):
        """
        """
        # input cfg MUST be a dict
        t = type(_cfg)
        if t is not types.DictionaryType:
            print 'Type error'
            return _cfg

        #
        cfg = self.cfg
        cfg.update(_cfg)

        # do all cases repl
        self.do_repl_dest(cfg)
        self.do_repl_path(cfg)
        # POST only for query/setup
        if not cfg['method'] == 'POST':
            return _cfg
        self.do_repl_query(cfg)
        self.do_repl_body(cfg)
        return cfg

    def do_repl_dest(self, cfg):
        """
        """
        return cfg

    def do_repl_path(self, cfg):
        """
        """
        return cfg

    def do_repl_form(self, cfg, keyname):
        """
        """
        # make query to hashmap
        query = cfg[keyname]
        if len(query) == 0: return cfg
        t = type(query)
        mapQ = {}
        seq = []
        if t is types.DictionaryType:
            mapQ = query
            pass
        elif t is types.StringType:
            match = r'([^=&]*)=([^=&]*)'
            res = re.findall(match, query)
            #print res
            for (k, v) in res:
                #print '--',k,str(v)
                seq.append(k)
                mapQ[k] = v
            pass
        # invoke callback function
        if not mapQ.has_key('active_page_str'):
            print "==", 'have no key active_page_str in query'
            return cfg
        fn = mapQ['active_page_str']
        #fn = os.path.basename(path)
        found = False
        for (name, method) in self.hdlrs.items():
            #if fn.find(name) >= 0 :
            if fn == name:
                found = True
                print '==', 'repl callback function:', name
                method(mapQ)
                break
        if not found:
            print '==', 'no repl callback function for page:', fn
        # make result
        if len(seq) > 0:
            #pprint(seq)
            #cfg[keyname] = urllib.urlencode(mapQ)
            val = ''
            for key in seq:
                val += (key + '=' + mapQ[key] + '&')
            cfg[keyname] = val[:-1]
        else:
            cfg[keyname] = mapQ
        return cfg

    def do_repl_query(self, cfg):
        """
        """
        return self.do_repl_form(cfg, 'query')

    def do_repl_body(self, cfg):
        """
        """
        return self.do_repl_form(cfg, 'body')


def mySetEnv(k, v):
    """
    """
    os.environ[k] = v


def main():
    """
    """
    return 0


if __name__ == '__main__':
    main()

