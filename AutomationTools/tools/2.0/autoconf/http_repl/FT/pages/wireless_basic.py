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
#form_hashmap=True
form_has_order = False

form_fmt = {}
form_fmt["wep_active"] = {}
form_fmt["wep_active"][
    'str'] = "apply_page=wireless_basic.html%3Fssid%3Dath0&waiting_page=waiting_page.html&waiting_page_leftmenu=2&waiting_page_topmenu=1&wep_active=1&wireless_vap_name=ath0&wireless_enable_type=1&wireless_ssid=70069172&wireless_multiple_ssid=ath0&wireless_channel=0&wireless_keep_channel=1&wireless_wep_enable_type=1&wep_key_len=0&wep_key_mode=0&wep_key_code=0987654321"
form_fmt["wep_active"]['hash'] = {
"apply_page": "wireless_basic.html?ssid=ath0",
"waiting_page": "waiting_page.html",
"waiting_page_leftmenu": "2",
"waiting_page_topmenu": "1",
"wep_active": "1",
"wireless_vap_name": "ath0",
"wireless_enable_type": "1",
"wireless_ssid": "70069172",
"wireless_multiple_ssid": "ath0",
"wireless_channel": "0",
"wireless_keep_channel": "1",
"wireless_wep_enable_type": "1",
"wep_key_len": "0",
"wep_key_mode": "0",
"wep_key_code": "0987654321",
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
        form_hashmap = form_fmt["wep_active"]["hash"]
        (rc, kall, ko1, ko2) = utils.diff_form_hashmap_keys(form_hashmap, h)
        page_info['message'] = ""
        if not rc:
            page_info['result'] = "SAME"
            page_info['message'] = ""
        else:
            page_info['result'] = "DIFF"
            page_info['message'] += (page_info['pagename'] + ":\n")
            page_info['message'] += ("Lost Keys : " + str(ko1) + "\n" )
            page_info['message'] += ("New  Keys : " + str(ko2) + "\n" )
    return


def form_repl(form):
    """
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

