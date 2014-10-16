#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#       AFT_wi_repl.py
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
Rev 0.1 : 2011/09/09
	Initial version, based on version :4.0.16.1.56.100.10.12.104
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
        path = cfg['path']
        fn = os.path.basename(path)
        for (name, method) in self.hdlrs.items():
            if fn.find(name) >= 0:
                method(mapQ)
                break
        #
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
    global logger
    logger = logging.getLogger()
    FORMAT = '%(message)s'
    logging.basicConfig(format='[%(filename)s:%(lineno)s %(levelname)-8s] %(message)s')
    logger.setLevel(logging.NOTSET)
    q = {
    'wireless_security_enabled': 'WPA2',
    'wpa_sta_auth_type': 0,
    'wpa_pre_authentication': 1,
    'wpa_sta_auth_shared_key': '1233211234567',
    'wpa_psk_representation': 0,
    'wpa_cipher': 2,
    'wpa_is_grp_key_update': 0,
    'wpa_grp_key_update_interval': 0,
    'radius_server_ip': '0.0.0.0',
    'radius_server_port': 1812,
    'radius_shared_secret': '',
    }
    qq = """wep_active=&wireless_vap_name=ath0&wireless_enable_type=1&wireless_ssid=bensonfiber&wireless_channel=0&wireless_keep_channel=1&wireless_wep_enable_type=1&wep_key_len=0&wep_key_mode=0&wep_key_code=1A2B3C4D5E"""

    cfg = {
    'description': 'no description',
    'protocol': 'HTTP',
    'destination': '192.168.1.1',
    'method': 'GET',
    'path': '/wireless_advanced.html',
    'body_len': 0,
    'query': qq,
    'body': q,
    }
    # export env
    # import ENV value
    mySetEnv('U_WIRELESS_SSID1', 'ssid_test001')
    mySetEnv('U_WIRELESS_SSID2', 'ssid_test002')
    mySetEnv('U_WIRELESS_SSID3', 'ssid_test003')
    mySetEnv('U_WIRELESS_SSID4', 'ssid_test004')

    mySetEnv('U_WIRELESS_WEPKEY_DEF_64', '123456789A')

    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY64bit1', '123456789A')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY64bit2', '123456789B')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY64bit3', '123456789C')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY64bit4', '123456789D')

    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY128bit1', 'abcdef0123456789wepkey128A')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY128bit2', 'abcdef0123456789wepkey128B')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY128bit3', 'abcdef0123456789wepkey128C')
    mySetEnv('U_WIRELESS_CUSTOM_WEP_KEY128bit4', 'abcdef0123456789wepkey128D')

    mySetEnv('U_WIRELESS_WEPKEY1', 'mytest')
    mySetEnv('U_WIRELESS_WEPKEY2', 'mytest2')
    mySetEnv('U_WIRELESS_WEPKEY3', 'mytest3')
    mySetEnv('U_WIRELESS_WEPKEY4', 'mytest4')

    mySetEnv('U_WIRELESS_WPAPSK1', 'WPAPSK1')
    mySetEnv('U_WIRELESS_WPAPSK2', 'WPAPSK2')
    mySetEnv('U_WIRELESS_WPAPSK3', 'WPAPSK3')
    mySetEnv('U_WIRELESS_WPAPSK4', 'WPAPSK4')

    mySetEnv('U_WIRELESS_CUSTOM_WPAPSK', 'cuswpapsk1')

    #
    hrr = http_request_repl()
    newcfg = hrr.do_repl(cfg)
    logger.debug('cfg = ' + pformat(cfg))
    #print '--------------'*4
    logger.debug('--' * 32)
    logger.debug('newcfg = ' + pformat(newcfg))
    return 0


if __name__ == '__main__':
    main()

