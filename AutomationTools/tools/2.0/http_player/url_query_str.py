#!/usr/bin/python -u
#       url_str.py
#       
#       Copyright 2011 root <root@rayofox-test>
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





import os, sys, time, re
from copy import deepcopy
import urllib
from pprint import pprint
from pprint import pformat


def isListUniq(l):
    """
    """
    nl = []
    for i in l:
        if i not in nl: nl.append(i)
    return (nl == l)


def str2hash(s):
    """
    translate http query string or post string to hashmap
    """
    canHash = True
    seq = []
    hashmap = {}
    match = r'([^=&]*)=([^=&]*)'
    res = re.findall(match, s)
    for (k, v) in res:
        if k in seq:
            canHash = False
            hashmap = None
        seq.append(k)
        if canHash:
            hashmap[k] = v
    return (hashmap, seq)


def hash2str(h, seq=None):
    """
    """
    rc = ""
    if seq and len(seq) > 0:
        val = ''
        for key in seq:
            val += (key + '=' + h[key] + '&')
        rc = val[:-1]
    else:
        rc = urllib.urlencode(h)
    return rc


class url_query_str():
    """
    """
    m_fmt = {
    'keys': [],
    'vals': [],
    'hash': None,
    }
    m_changelog = []

    def __init__(self, s):
        """
        """
        self.m_changelog = []
        self.fmt(s)

    def addChangeLog(self, s):
        """
        """
        self.m_changelog.append(s)

    def getChangeLog(self):
        """
        """
        return self.m_changelog

    def __str2fmt(self, s):
        """
        """
        fmt = self.m_fmt
        fmt['hash'] = {}
        match = r'([^=&]*)=([^=&]*)'
        res = re.findall(match, s)
        for (k, v) in res:
            if k in fmt['keys']:
                #print '==',k + ' is already in ' + str(fmt['keys'])
                fmt['hash'] = None
            # unquote url string
            k = urllib.unquote_plus(k)
            v = urllib.unquote_plus(v)
            fmt['keys'].append(k)
            fmt['vals'].append(v)
            if not None == fmt['hash']:
                fmt['hash'][k] = v
        return fmt

    def __fmt2str(self, fmt):
        """
        """
        s = ''
        fmt = self.m_fmt
        for index, key in enumerate(fmt['keys']):
            if len(s) > 0: s += '&'
            # quote url string
            key = urllib.quote_plus(key)
            val = urllib.quote_plus(fmt['vals'][index])
            s += (key + '=' + val)
        return s

    def __resetFmt(self):
        """
        """
        self.m_fmt = {
        'keys': [],
        'vals': [],
        'hash': None,
        }

    def fmt(self, s=None):
        """
        """
        if s:
            self.__resetFmt()
            self.__str2fmt(s)
        return self.m_fmt

    def str(self):
        """
        """
        return self.__fmt2str(self.m_fmt)

    def keys(self):
        """
        """
        return self.m_fmt['keys']

    def hash(self):
        """
        """
        return self.m_fmt['hash']

    def dump(self):
        """
        """
        s = ''

        fmt = self.m_fmt
        for index, key in enumerate(fmt['keys']):
            s += ("'" + key + "' : '" + fmt['vals'][index] + "'\n")

        if fmt['hash']:
            s = ('{' + s + '}')
        else:
            s = ('[' + s + ']')

        return s


    def hasKey(self, key):
        """
        """
        return (self.indexKey(key) >= 0 )

    def indexKey(self, key):
        """
        """

        rc = -1
        if not key: return rc

        fmt = self.m_fmt
        if key in fmt['keys']:
            rc = fmt['keys'].index(key)

        return rc

    def value(self, key, defval=None):
        """
        """
        idx = self.indexKey(key)
        return self.valueByIndex(idx)

    def valueByIndex(self, index, defval=None):
        """
        """
        if self.isValidIndex(index):
            return self.m_fmt['vals'][index]
        return defval

    def updateValue(self, key, val):
        """
        """
        rc = -1
        if not key or not val: return rc

        rc = self.indexKey(key)
        if rc < 0: return rc

        return self.updateValueByIndex(rc, val)

    def deleteKey(self, key):
        """
        """

        rc = self.indexKey(key)
        if rc < 0: return rc

        return self.deleteKeyByIndex(rc)

    #

    def updateKey(self, key, newkey):
        """
        """

        rc = self.indexKey(key)
        if rc < 0: return rc

        return self.updateKeyByIndex(rc, newkey)

    def updateKeyAndValue(self, key, newkey, newval):
        """
        """
        rc = self.indexKey(key)
        if rc < 0: return rc

        return self.updateKeyAndValueByIndex(rc, newkey, newval)

    def isValidIndex(self, index):
        """
        """
        return ( index >= 0 and index < len(self.m_fmt['vals']) )

    def updateValueByIndex(self, index, val):
        """
        """
        if not val: return False
        fmt = self.m_fmt
        if self.isValidIndex(index):
            if not fmt['vals'][index] == val:
                self.addChangeLog('update value' + str(index) + ' : ' + fmt['keys'][index] + '=' + val)
            fmt['vals'][index] = val
            if fmt['hash']:
                fmt['hash'][fmt['keys'][index]] = val
        return True

    def deleteKeyByIndex(self, index):
        """
        """
        fmt = self.m_fmt

        if self.isValidIndex(index):
            self.addChangeLog('delete key' + str(index) + ' : ' + fmt['keys'][index])
            del fmt['keys'][index]
            del fmt['vals'][index]
            # reparse fmt
            s = self.str()
            self.fmt(s)

    def updateKeyByIndex(self, index, newkey):
        """
        """
        rc = -1
        if not newkey: return rc
        fmt = self.m_fmt
        if self.isValidIndex(index):

            rc = index
            key = fmt['keys'][index]
            val = fmt['vals'][index]

            if not key == newkey:
                self.addChangeLog('update key' + str(index) + ' : ' + fmt['keys'][index])
            fmt['keys'][index] = newkey

            if fmt['hash']:
                del fmt['hash'][key]
                fmt['hash'][newkey] = val
        return rc

    def updateKeyAndValueByIndex(self, index, newkey, newval):
        """
        """
        rc = -1
        if not newkey or not newval:
            return rc

        #
        rc = self.updateValueByIndex(index, newval)
        rc = self.updateKeyByIndex(index, newkey)
        return rc

    def addKeyAndValue(self, key, val):
        """
        """
        rc = -1
        if not key or not val: return rc
        #
        fmt = self.m_fmt

        #self.addChangeLog('add : ' + fmt['keys'][index] + '=' + val)
        # hash
        if fmt['hash']:
            if key in fmt['keys']:
                fmt['hash'] = None
            else:
                fmt['hash'][key] = val
        #
        fmt['keys'].append(key)
        fmt['vals'].append(val)


    def matchKeys(self, m):
        """
        """
        rc = []
        fmt = self.m_fmt
        for key in fmt['keys']:
            res = re.match(m, key)
            if res: rc.append(key)
        return rc

    def isChanged(self):
        """
        """
        return (len(self.m_changelog) > 0 )


def main():
    """
    """
    #s = 'active_page=9144&active_page_str=page_conn_settings_ppp0&page_title=Connection+Properties&mimic_button_field=submit_button_submit%3A+..&button_value=ppp0&strip_page_top=0&tab4_selected=0&tab4_visited_0=1&sym_show_detail_conf=1&network=1&network_defval=1&mtu_mode=1&mtu_mode_defval=1&depend_on_name=eth1&depend_on_name_defval=eth1&service_name_defval=&service_name=&on_demand_defval=0&reconnect_time_defval=30&reconnect_time=30&ppp_username_defval=verizonfios&ppp_username=rayofox001&ppp_password_337938148=111111&ppp_password_retype_337938148=111111&auth_pap_defval=1&auth_pap=1&auth_chap_defval=1&auth_chap=1&auth_mschapv1_defval=1&auth_mschapv1=1&auth_mschapv2_defval=1&auth_mschapv2=1&comp_bsd=1&comp_bsd_defval=1&comp_deflate=1&comp_deflate_defval=1&ip_settings=2&ip_settings_defval=2&override_subnet_mask_defval=0&static_netmask_override0_defval=0&static_netmask_override0=0&static_netmask_override1_defval=0&static_netmask_override1=0&static_netmask_override2_defval=0&static_netmask_override2=0&static_netmask_override3_defval=0&static_netmask_override3=0&dns_option=1&dns_option_defval=1&route_level=4&route_level_defval=4&route_metric_defval=1&route_metric=1&default_route_defval=1&default_route=1&is_trusted_defval=1&is_trusted=1'
    s = 'active%5fpage=9121&active%5fpage%5fstr=page%5factiontec%5fwireless%5fadvanced%5fsetup&req%5fmode=1&mimic%5fbutton%5ffield=submit%5fbutton%5fsubmit&strip%5fpage%5ftop=0&button%5fvalue=9121'
    uqs = url_query_str(s)
    print 'fmt = '
    pprint(uqs.fmt())
    #
    print '==' * 32
    uqs.updateKey('ppp_password_337938148', 'ppp_password_90')
    uqs.updateValue('ppp_password_90', 'a:bz&')
    print 'newfmt = '
    pprint(uqs.fmt())
    print uqs.str()
    print '==' * 32
    m = r'ppp_pass.*'
    print uqs.matchKeys(m)
    print '==' * 32
    print 'Changelog :'
    clog = uqs.getChangeLog()
    for log in clog:
        print log


if __name__ == '__main__':
    """
    """
    main()
