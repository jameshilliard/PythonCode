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

import _utils as utils

# form information
form_type = "POST"
form_fmt_unique = True
form_has_order = False

form_fmt = {}

# form wep setting
form_fmt["wep"] = {}
form_fmt["wep"][
    'str'] = "apply_page=wireless_advanced_wep.html%3Fssid%3Dath0&waiting_page=waiting_page.html&waiting_page_leftmenu=3&waiting_page_topmenu=1&wireless_vap_name=ath0&wep_mode=0&radius_server_ip=0.0.0.0&radius_server_port=1812&radius_shared_secret=&wep_auth=0&wep_active=1&wep_key_0_code=0987654321&wep_key_0_mode=0&wep_key_0_len=0&wep_key_1_code=&wep_key_1_mode=0&wep_key_1_len=0&wep_key_2_code=&wep_key_2_mode=0&wep_key_2_len=0&wep_key_3_code=&wep_key_3_mode=0&wep_key_3_len=0"
form_fmt["wep"]['hash'] = {
"apply_page": "wireless_advanced_wep.html?ssid=ath0",
"waiting_page": "waiting_page.html",
"waiting_page_leftmenu": "3",
"waiting_page_topmenu": "1",
"wireless_vap_name": "ath0",
"wep_mode": "0",
"radius_server_ip": "0.0.0.0",
"radius_server_port": "1812",
"radius_shared_secret": "",
"wep_auth": "0",
"wep_active": "1",
"wep_key_0_code": "0987654321",
"wep_key_0_mode": "0",
"wep_key_0_len": "0",
"wep_key_1_code": "",
"wep_key_1_mode": "0",
"wep_key_1_len": "0",
"wep_key_2_code": "",
"wep_key_2_mode": "0",
"wep_key_2_len": "0",
"wep_key_3_code": "",
"wep_key_3_mode": "0",
"wep_key_3_len": "0",
}

# form wpa/wpa2 setting
form_fmt["wpa"] = {}
form_fmt["wpa"][
    'str'] = "apply_page=wireless_advanced_wpa.html%3Fssid%3Dath0&waiting_page=waiting_page.html&waiting_page_leftmenu=3&waiting_page_topmenu=1&wireless_security_enabled=WPA2&wireless_vap_name=ath0&wpa_sta_auth_type=0&wpa_pre_authentication=1&wpa_sta_auth_shared_key=1234567890&wpa_psk_representation=0&wpa_cipher=0&wpa_is_grp_key_update=0&wpa_grp_key_update_interval=800&radius_server_ip=0.0.0.0&radius_server_port=1812&radius_shared_secret="
form_fmt["wpa"]['hash'] = {
"apply_page": "wireless_advanced_wpa.html?ssid=ath0",
"waiting_page": "waiting_page.html",
"waiting_page_leftmenu": "3",
"waiting_page_topmenu": "1",
"wireless_security_enabled": "WPA2",
"wireless_vap_name": "ath0",
"wpa_sta_auth_type": "0",
"wpa_pre_authentication": "1",
"wpa_sta_auth_shared_key": "1234567890",
"wpa_psk_representation": "0",
"wpa_cipher": "0",
"wpa_is_grp_key_update": "0",
"wpa_grp_key_update_interval": "800",
"radius_server_ip": "0.0.0.0",
"radius_server_port": "1812",
"radius_shared_secret": "",

}


def check(req, page_info):
    """
    1. the unique format
    2. hashmap without index(no order,keyword unique)

    page_info['pagename'] = ""
    page_info['handler'] = None
    page_info['result'] = None
    page_info['message'] = "checking"

    """
    # check POST data
    q = req['body']
    if q and len(q):
        seq, h = utils.str2hash(q)
        #
        form_hashmap = None
        if "wireless_advanced_wep.cgi" == page_info['pagename']:
            form_hashmap = form_fmt['wep']['hash']
        elif "wireless_advanced_wpa.cgi" == page_info['pagename']:
            form_hashmap = form_fmt['wpa']['hash']
        (rc, kall, ko1, ko2) = utils.diff_form_hashmap_keys(form_hashmap, h)
        #print "==",form_hashmap
        #print "==",h
        page_info['message'] = ""
        if not rc:
            page_info['result'] = "SAME"
            page_info['message'] = ""
        else:
            page_info['result'] = "DIFF"
            page_info['message'] += (page_info['pagename'] + ":\n")
            if len(ko1):
                page_info['message'] += ("Lost Keys : " + str(ko1) + "\n" )
            if len(ko2):
                page_info['message'] += ("New  Keys : " + str(ko2) + "\n" )
    return


def form_repl(form):
    """
    """
    # WEP
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
    # WPA
    if form.has_key('wireless_security_enabled') and form['wireless_security_enabled'] == 'WPA':
        psk = os.getenv('U_WIRELESS_CUSTOM_WPAPSK')
        if psk: form['wpa_sta_auth_shared_key'] = urllib.quote(psk)
        return form
    # WPA2
    if form.has_key('wireless_security_enabled') and form['wireless_security_enabled'] == 'WPA2':
        #logger.debug('here')
        psk = os.getenv('U_WIRELESS_CUSTOM_WPAPSK')
        if psk: form['wpa_sta_auth_shared_key'] = urllib.quote(psk)
        return form
    #pass
    return form


def replace(req):
    """
    """
    changed = True
    q = req['body']
    if q and len(q):
        seq, h = utils.str2hash(q)
        new_h = form_repl(h)
        if new_h == h:
            changed = False
        else:
            q = utils.hash2str(new_h, seq)
            req['body'] = q
    else:
        changed = False
    return (req, changed)

