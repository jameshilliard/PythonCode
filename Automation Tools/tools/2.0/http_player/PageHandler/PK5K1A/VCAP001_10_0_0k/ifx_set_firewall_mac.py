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
from pprint import pprint
from copy import deepcopy

from PageBase import PageBase


#-----------------------------------------------------------------------
body_fmts = {}

# TODO : add POST body format string map to an unique string (when have multi format string ,the unique string id decided how to match)
body_fmts[
    "wireless_enable_type=1"] = 'apply_page=wireless_basic.html%3Fssid%3Dath0&waiting_page=waiting_page.html&waiting_page_leftmenu=2&waiting_page_topmenu=1&wep_active=1&wireless_vap_name=ath0&wireless_enable_type=1&wireless_ssid=549B3313&wireless_multiple_ssid=ath0&wireless_channel=3&wireless_keep_channel=0&wireless_wep_enable_type=1&wep_key_len=0&wep_key_mode=0&wep_key_code=0987654321'
body_fmts["wireless_enable_type=0"] = 'wireless_vap_name=ath0&wireless_enable_type=0&wireless_multiple_ssid=ath0'
#-----------------------------------------------------------------------
query_fmts = {}

# TODO : add query format string 
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

    ### Need To OverLoad ##########################

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
        replace body string
        """

        ################################################################
        fmt = body.fmt()

        is_add = body.value('addF')

        if is_add == '1':
            print '== to add access rule'

            #		delflag	0
            #		addF	1
            #		delindex
            #		check	2
            #		macfilterAction	2
            #		macfilterAdd0	54
            #		macfilterAdd1	e6
            #		macfilterAdd2	fc
            #		macfilterAdd3	6c
            #		macfilterAdd4	d4
            #		macfilterAdd5	c7
            #		Mon	1
            #		Tue	1
            #		Wed	1
            #		Thu	1
            #		Fri	1
            #		Sat	1
            #		Sun	1
            #		start_time	09:00
            #		end_time	09:15

            lan_mac = os.getenv('U_CUSTOM_ASC_MAC', os.getenv('G_HOST_MAC0_1_0'))
            if lan_mac:
                lan_mac = lan_mac.lower()
                lan_macs = lan_mac.split(':')
            days = os.getenv('U_CUSTOM_ASC_DAYS', '127')
            start_time = os.getenv('U_CUSTOM_ASC_START', '60')
            end_time = os.getenv('U_CUSTOM_ASC_END', '120')

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'macfilterAdd0':
                    v = lan_macs[0]
                    if v:
                        print '== change %s to %s' % (k, v)
                        body.updateValueByIndex(index, v)
                    continue
                elif k == 'macfilterAdd1':
                    v = lan_macs[1]
                    if v:
                        print '== change %s to %s' % (k, v)
                        body.updateValueByIndex(index, v)
                    continue
                elif k == 'macfilterAdd2':
                    v = lan_macs[2]
                    if v:
                        print '== change %s to %s' % (k, v)
                        body.updateValueByIndex(index, v)
                    continue
                elif k == 'macfilterAdd3':
                    v = lan_macs[3]
                    if v:
                        print '== change %s to %s' % (k, v)
                        body.updateValueByIndex(index, v)
                    continue
                elif k == 'macfilterAdd4':
                    v = lan_macs[4]
                    if v:
                        print '== change %s to %s' % (k, v)
                        body.updateValueByIndex(index, v)
                    continue
                elif k == 'macfilterAdd5':
                    v = lan_macs[5]
                    if v:
                        print '== change %s to %s' % (k, v)
                        body.updateValueByIndex(index, v)
                    continue

                elif k == 'start_time':
                    hrs = str(int(start_time) / 60)

                    if len(hrs) == 1:
                        hrs = '0' + hrs

                    mns = str(int(start_time) % 60)

                    if len(mns) == 1:
                        mns = '0' + mns

                    ev = hrs + ':' + mns

                    if ev:
                        v = ev
                        print '== change %s to %s ' % (k, v)
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'end_time':
                    hrs = str(int(end_time) / 60)

                    if len(hrs) == 1:
                        hrs = '0' + hrs

                    mns = str(int(end_time) % 60)

                    if len(mns) == 1:
                        mns = '0' + mns

                    ev = hrs + ':' + mns

                    if ev:
                        v = ev
                        print '== change %s to %s ' % (k, v)
                    body.updateValueByIndex(index, v)
                    continue
        elif is_add == '0':
            print '== to delete access rule'

            #		delflag	1
            #		addF	0
            #		delindex	0
            #		check	2
            #		macfilterAction	2
            #		macfilterAdd0
            #		macfilterAdd1
            #		macfilterAdd2
            #		macfilterAdd3
            #		macfilterAdd4
            #		macfilterAdd5
            #		Mon	0
            #		Tue	0
            #		Wed	0
            #		Thu	0
            #		Fri	0
            #		Sat	0
            #		Sun	0
            #		start_time
            #		end_time
            #		cpeId0	0
            #		addconnect0	2

            delindex = os.getenv('ASC_RULE_INDEX', '0')

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'delindex':
                    ev = delindex
                    if ev:
                        v = ev
                        print '== change %s to %s' % (k, v)
                    body.updateValueByIndex(index, v)
                    continue

        return body
