#! /usr/bin/env python
"""
The wi_sec_repl support the replacement rule for broadcom wireless security page
"""

import re, os, sys
import urllib2

wi_sec_match = 'wlDefaultKeyFlagWep64Bit=.+'


def wi_sec_cbReplace(m):
    res = m.group(0)
    match = '([^&=]*)=([^&=]*)'
    rr = re.findall(match, res)

    # 1. get default wep and psk flag
    # 2. replace default wep 128 (duplicate key name)
    wep_flag = None
    wpa_flag = None
    idx_def_wep128 = 0
    i = 0
    for i in range(0, len(rr)):
        (k, v) = rr[i]
        #print "=======",k,v
        if k == 'wlDefaultKeyFlagWep128Bit':
            wep_flag = int(v)
            continue
        if k == 'wlDefaultKeyFlagPsk':
            wpa_flag = int(v)
            continue
        if k == 'wlDefaultKeyWep128Bit':
            idx_def_wep128 += 1
            ek = 'U_WIRELESS_WEPKEY' + str(idx_def_wep128)
            ev = os.getenv(ek)
            if ev:   v = ev
            rr[i] = (k, v)
            continue
        # 3. using default overwrite custom
    for i in range(0, len(rr)):
        (k, v) = rr[i]
        if wep_flag:
            r = re.findall('wlKey(\d)_128_wl0v(\d)', k)
            #print '==>',k
            #print '==>',r
            if len(r) > 0:
                (cus_idx, ssid_idx) = r[0]
                if (wep_flag & (1 << int(ssid_idx) ) ):
                # using default overwirte custom
                    ek = 'U_WIRELESS_WEPKEY' + str(int(ssid_idx) + 1)
                    ev = os.getenv(ek)
                    #print '==>',ek,ev
                    if ev: v = ev
                    rr[i] = (k, v)
            continue
        if wpa_flag:
            r = re.findall('wlWpaPsk_wl0v(\d)', k)
            if len(r) > 0:
                ssid_idx = r[0]
                if (wpa_flag & (1 << int(ssid_idx)) ):
                    # using default overwirte custom
                    ek = 'U_WIRELESS_WPAPSK' + str(int(ssid_idx) + 1)
                    ev = os.getenv(ek)
                    if ev:  v = ev
                    rr[i] = (k, v)
            continue
        # join the query/post data
    dlist = []
    for (k, v) in rr:
        item = (k + '=' + v)
        dlist.append(item)
    res = '&'.join(dlist)
    return res.strip()

