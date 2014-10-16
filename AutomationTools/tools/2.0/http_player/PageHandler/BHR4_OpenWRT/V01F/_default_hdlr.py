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

common_repl = {


    # wireless 802.1X
    # radius server for all SSID (the same value)
    'radius_server_ip': 'U_WIRELESS_RADIUS_SERVER',
    #'wlRadiusServerIP_wl0v1' : 'U_WIRELESS_RADIUS_SERVER',
    #'wlRadiusServerIP_wl0v2' : 'U_WIRELESS_RADIUS_SERVER',
    #'wlRadiusServerIP_wl0v3' : 'U_WIRELESS_RADIUS_SERVER',

    # radius server key
    'radius_shared_secret': 'U_WIRELESS_RADIUS_KEY',
    #'wlRadiusKey_wl0v1' : 'U_WIRELESS_RADIUS_KEY',
    #'wlRadiusKey_wl0v2' : 'U_WIRELESS_RADIUS_KEY',
    #'wlRadiusKey_wl0v3' : 'U_WIRELESS_RADIUS_KEY',

}


def check(req, page_info):
    """
    Not Support
    """
    return


def replace(req):
    """
    """
    changed = False
    # 
    body = req['body-fmt']
    query = req['query-fmt']
    # do body repl only
    if body:
        print '==', 'common replace BEGIN'
        for (key, val) in common_repl.items():
            if body.hasKey(key):
                #
                val = os.getenv(val)
                if val:
                    print '==', 'update : ', key, '=', val
                    body.updateValue(key, val)

    print '==', 'common replace END'
    return (req, changed)

