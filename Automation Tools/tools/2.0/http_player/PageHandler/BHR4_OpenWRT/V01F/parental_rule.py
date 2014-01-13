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
# query_fmts[''] = ''
# query_fmts[''] = ''



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
        # self.m_isHash = True
        # self.m_replPOST = True
        # self.m_replGET = False

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
        #    parental_devicelist_dest    192.168.1.2;                parental_index    1
        #    parental_limitaccess_dest    Website:www.vosky.com;      sumbit_button_name    delete
        #    parental_index    -1                                      waiting_page    waiting_page.html
        #    sumbit_button_name    add_edit                            waiting_page_topmenu    4
        #    parental_weekdays    Mon,Tue,Wed,Thu,Fri,Sat,Sun         waiting_page_leftmenu    2
        #    parental_timestart    00:00                               apply_page    parental_rule.html
        #    parental_timeend    23:59
        #    waiting_page    waiting_page.html                       --------------------------------------------------====
        #    waiting_page_topmenu    4
        #    waiting_page_leftmenu    1
        #    apply_page    parental_rule.html
        #    parental_limit_access    Exclude
        #    parental_start_ispm    a.m.
        #    parental_end_ispm    p.m.
        #    parental_rule_name    test_rule_name
        #    parental_rule_description    test_description
        #    --------------------------------------------------====
        #    parental_devicelist_dest    192.168.1.2;192.168.1.100;     parental_index    2
        #    parental_limitaccess_dest    Website:www.example.com ;      sumbit_button_name    delete
        #    parental_index    -1                                        waiting_page    waiting_page.html
        #    sumbit_button_name    add_edit                            waiting_page_topmenu    4
        #    parental_weekdays    Mon,Tue,Wed,Thu,Fri,Sat,Sun            waiting_page_leftmenu    2
        #    parental_timestart    00:00                                apply_page    parental_rule.html
        #    parental_timeend    23:59
        #    waiting_page    waiting_page.html
        #    waiting_page_topmenu    4
        #    waiting_page_leftmenu    1
        #    apply_page    parental_rule.html
        #    parental_limit_access    Exclude
        #    parental_start_ispm    a.m.
        #    parental_end_ispm    p.m.
        #    parental_rule_name    aaaaa
        #    parental_rule_description    ccccc
        #
        #    ----------------------------------------------------------------------------------------------------------------


        fmt = body.fmt()

        is_add = body.value('sumbit_button_name')

        if is_add == 'add_edit':
            print '== to add a rule'

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'parental_devicelist_dest':
                    hosts = body.value('parental_devicelist_dest')

                    m = r'.*;.*;'

                    rc = re.findall(m, hosts)

                    if len(rc) > 0:
                        print '== to block for all LAN PC'

                        #                        -v G_HOST_IF0_1_0           = eth1
                        #                        -v G_HOST_TIP0_1_0          = 192.168.0.100
                        #                        # eth2
                        #                        -v G_HOST_IF0_2_0           = eth2
                        #                        -v G_HOST_TIP0_2_0          = 192.168.0.200
                        eth1 = os.getenv('G_HOST_TIP0_1_0', '192.168.1.100')
                        eth2 = os.getenv('G_HOST_TIP0_2_0', '192.168.1.200')

                        hosts = eth1 + ';' + eth2 + ';'

                        ev = hosts
                        if ev:
                            v = ev
                            print '== change hosts to : ', v
                        body.updateValueByIndex(index, v)
                        continue
                    else:
                        print '== to block one LAN PC'

                        eth1 = os.getenv('G_HOST_TIP0_1_0', '192.168.1.100')

                        hosts = eth1 + ';'
                        ev = hosts
                        if ev:
                            v = ev
                            print '== change hosts : ', v
                        body.updateValueByIndex(index, v)
                        continue

                elif k == 'parental_limitaccess_dest':
                    #    Website:www.example.com ;
                    #    U_CUSTOM_HTTP_HOST
                    site = os.getenv('U_CUSTOM_HTTP_HOST', 'www.vosky.com')
                    ev = 'Website:' + site + ' ;'
                    if ev:
                        v = ev
                        print '== change Website to : ', v
                    body.updateValueByIndex(index, v)
                    continue

                elif k == 'parental_maclist_dest':
                    #    Website:www.example.com ;
                    #    U_CUSTOM_HTTP_HOST
                    site = os.getenv('G_HOST_MAC0_1_0', 'aa:bb:cc:dd:ee:ff')
                    ev = site + ';'
                    if ev:
                        v = ev
                        print '== change parental_maclist_dest to : ', v
                    body.updateValueByIndex(index, v)
                    continue

        elif is_add == 'delete':
            print '== to delete a rule'
            delindex = os.getenv('WBL_RULE_INDEX')

            fmt = body.fmt()

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'parental_index':
                    delindexs = os.getenv('WBL_RULE_INDEX', 'NULL_NULL')
                    if delindexs != 'NULL_NULL':
                        delidxs = delindexs.split(',')
                        delindex = delidxs[0]
                        body.updateValueByIndex(index, delindex)
                    continue

        return body
