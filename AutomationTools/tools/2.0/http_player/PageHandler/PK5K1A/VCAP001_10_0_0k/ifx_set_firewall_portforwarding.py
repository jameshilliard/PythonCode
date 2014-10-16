#	   $FILENAME.py
#	   
#	   Copyright 2011 rayofox <lhu@actiontec.com>
#	   
#	   This program is free software; you can redistribute it and/or modify
#	   it under the terms of the GNU General Public License as published by
#	   the Free Software Foundation; either version 2 of the License, or
#	   (at your option) any later version.
#	   
#	   This program is distributed in the hope that it will be useful,
#	   but WITHOUT ANY WARRANTY; without even the implied warranty of
#	   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	   GNU General Public License for more details.
#	   
#	   You should have received a copy of the GNU General Public License
#	   along with this program; if not, write to the Free Software
#	   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#	   MA 02110-1301, USA.
#	   
#	   
"""
This is a template file to create page handle file
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

# TODO : add POST body format string map to an unique string (when have multi format string ,the unique string id decided how to match)
body_fmts[
    "frompage=advancedsetup_advancedportforwarding"] = 'page=confirm.html&frompage=advancedsetup_advancedportforwarding.html&delflag=0&addF=1&delindex=&lan_ip=192.168.0.100&lan_start_port=1234&lan_end_port=2345&protocol=TCP&wan_ip=192.168.55.254&wan_start_port=3456&wan_end_port=4567'
#body_fmts[""] = ''
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


    def checkDetail(self, fmt, page_info):
        """
        check difference detail
        """
        # TODO : check detail difference
        pass

    def repl_port(self, body, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx):
        """
        """

        if all_port == 4:
            new_iStart_add = os.getenv('U_CUSTOM_PFO_INTERNAL_START', os.getenv('U_TR069_DEF_INTERNAL_PORT'))
            new_iEnd_add = os.getenv('U_CUSTOM_PFO_INTERNAL_END', os.getenv('U_TR069_DEF_INTERNAL_PORT_END_RANGE'))

            new_eStart = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', 'NULL_NULL')
            new_eEnd = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', 'NULL_NULL')

            if new_eStart == 'NULL_NULL' and new_eEnd == 'NULL_NULL':
                print "external port same as internal port"
                new_eStart_add = new_iStart_add
                new_eEnd_add = new_iEnd_add

            else:
                print "external port differ from internal port"
                new_eStart_add = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', os.getenv('U_TR069_DEF_EXTERNAL_PORT'))
                new_eEnd_add = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE'))

            body.updateValueByIndex(eStart_add_idx, new_eStart_add)
            body.updateValueByIndex(eEnd_add_idx, new_eEnd_add)
            body.updateValueByIndex(iStart_add_idx, new_iStart_add)
            body.updateValueByIndex(iEnd_add_idx, new_iEnd_add)

        return body

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
        #	PFO with no WAN IP , TCP        PFO with WAN IP , TCP        delete
        #
        #	delflag	0                       delflag	0                    delflag	1
        #	addF	1                       addF	1                    addF	0
        #	delindex	                    delindex	                 delindex	0
        #	lan_ip	192.168.0.100           lan_ip	192.168.0.100        lan_ip
        #	lan_start_port	1234            lan_start_port	1234         lan_start_port
        #	lan_end_port	2345            lan_end_port	2345         lan_end_port
        #	protocol	TCP                 protocol	TCP              protocol
        #	wan_ip	0.0.0.0                 wan_ip	192.168.55.254       wan_ip
        #	wan_start_port	1234            wan_start_port	3456         wan_start_port
        #	wan_end_port	2345            wan_end_port	4567         wan_end_port

        is_add = body.value('delflag')

        if is_add == '0':
            print '== to add a rule'

            fmt = body.fmt()
            all_port = 0
            eStart_add_idx = eEnd_add_idx = iStart_add_idx = iEnd_add_idx = None

            for index, k in enumerate(fmt['keys']):
                #	'srvAddr':'G_HOST_TIP0_1_0', proto=1, or 2, 1=tcp 2=udp when remove TCP/UPD
                v = fmt['vals'][index]
                if k == 'wan_ip':
                    srvWanAddr_ori = body.value('wan_ip')
                    #print 'srvWanAddr_ori :', srvWanAddr_ori
                    if srvWanAddr_ori != '0.0.0.0':
                        wan_ip = os.getenv('U_CUSTOM_PFO_SERVER_WANADDR', 'NULL_NULL')
                        if wan_ip == 'NULL_NULL':
                            wan_ip = os.getenv('TMP_DUT_DEF_GW', os.getenv('G_HOST_TIP1_2_0'))
                    else:
                        wan_ip = os.getenv('U_CUSTOM_PFO_SERVER_WANADDR', 'NULL_NULL')
                        if wan_ip == 'NULL_NULL':
                            wan_ip = '0.0.0.0'

                    body.updateValueByIndex(index, wan_ip)
                    continue

                elif k == 'protocol':
                    pfo_proto = os.getenv('U_CUSTOM_PFO_PROTO', 'NULL_NULL')

                    if pfo_proto == 'TCP':
                        body.updateValueByIndex(index, 'TCP')
                    elif pfo_proto == 'UDP':
                        body.updateValueByIndex(index, 'UDP')
                    continue

                elif k == 'lan_ip':
                    pfo_server = os.getenv('U_CUSTOM_PFO_SERVER', 'NULL_NULL')
                    if pfo_server == 'NULL_NULL':
                        pfo_server = os.getenv('G_HOST_TIP0_1_0')
                    body.updateValueByIndex(index, pfo_server)
                    continue

                #,eStart_add_idx	,eEnd_add_idx	,iStart_add_idx	,iEnd_add_idx
                elif k == 'wan_start_port':
                    eStart_add = body.value('wan_start_port')
                    eStart_add_idx = index
                    all_port += 1

                    body = self.repl_port(body, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                    continue

                elif k == 'wan_end_port':
                    eEnd_add = body.value('wan_end_port')
                    eEnd_add_idx = index
                    all_port += 1

                    body = self.repl_port(body, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                    continue

                elif k == 'lan_start_port':
                    iStart_add = body.value('lan_start_port')
                    iStart_add_idx = index
                    all_port += 1

                    body = self.repl_port(body, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                    continue

                elif k == 'lan_end_port':
                    iEnd_add = body.value('lan_end_port')
                    iEnd_add_idx = index
                    all_port += 1

                    body = self.repl_port(body, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                    continue
        elif is_add == '1':
            print '== to delete a rule'

            fmt = body.fmt()

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'delindex':
                    delindexs = os.getenv('PFO_RULE_INDEX', 'NULL_NULL')
                    if delindexs != 'NULL_NULL':
                        delidxs = delindexs.split(',')
                        delindex = delidxs[0]
                        body.updateValueByIndex(index, delindex)
                    continue

        return body
