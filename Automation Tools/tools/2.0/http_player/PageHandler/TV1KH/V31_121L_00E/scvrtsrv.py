#       $FILENAME.py
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
    "action"] = 'action=add&srvName=aDv_PoRt_FoRwArDiNg&srvAddr=192.168.0.200&eStart=5000%2C&eEnd=5005%2C&proto=1%2C&iStart=5006%2C&iEnd=5006%2C&srvWanAddr=192.168.55.254&needthankyou=advancedsetup_advancedportforwarding.html'
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

    def repl_port(self, body, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx):
        """
        """

        if all_port == 4:
            new_iStart_add = os.getenv('U_CUSTOM_PFO_INTERNAL_START', os.getenv('U_TR069_DEF_INTERNAL_PORT')) + ','
            new_iEnd_add = os.getenv('U_CUSTOM_PFO_INTERNAL_END',
                                     os.getenv('U_TR069_DEF_INTERNAL_PORT_END_RANGE')) + ','

            new_eStart = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', 'NULL_NULL')
            new_eEnd = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', 'NULL_NULL')

            if new_eStart == 'NULL_NULL' and new_eEnd == 'NULL_NULL':
                print "external port same as internal port"
                new_eStart_add = new_iStart_add
                new_eEnd_add = new_iEnd_add

            else:
                print "external port differ from internal port"
                new_eStart_add = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', os.getenv('U_TR069_DEF_EXTERNAL_PORT')) + ','
                new_eEnd_add = os.getenv('U_CUSTOM_PFO_EXTERNAL_END',
                                         os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE')) + ','

            body.updateValueByIndex(eStart_add_idx, new_eStart_add)
            body.updateValueByIndex(eEnd_add_idx, new_eEnd_add)
            body.updateValueByIndex(iStart_add_idx, new_iStart_add)
            body.updateValueByIndex(iEnd_add_idx, new_iEnd_add)

        return body

    def replQuery(self, query):

        """
        replace query string
        """
        #body=''
        # TODO : Implement your replacement without hash
        fmt = query.fmt()

        #fmt = body.fmt()
        all_port = 0
        eStart_add_idx = eEnd_add_idx = iStart_add_idx = iEnd_add_idx = None

        for index, k in enumerate(fmt['keys']):
            #    'srvAddr':'G_HOST_TIP0_1_0', proto=1, or 2, 1=tcp 2=udp when remove TCP/UPD
            v = fmt['vals'][index]
            if k == 'srvWanAddr':
                srvWanAddr_ori = query.value('srvWanAddr')
                #print 'srvWanAddr_ori :', srvWanAddr_ori
                if srvWanAddr_ori != '0.0.0.0':
                    srvWanAddr = os.getenv('U_CUSTOM_PFO_SERVER_WANADDR', 'NULL_NULL')
                    if srvWanAddr == 'NULL_NULL':
                        srvWanAddr = os.getenv('TMP_DUT_DEF_GW', os.getenv('G_HOST_TIP1_2_0'))
                else:
                    srvWanAddr = os.getenv('U_CUSTOM_PFO_SERVER_WANADDR', 'NULL_NULL')
                    if srvWanAddr == 'NULL_NULL':
                        srvWanAddr = '0.0.0.0'

                query.updateValueByIndex(index, srvWanAddr)
                continue

            elif k == 'proto':
                pfo_proto = os.getenv('U_CUSTOM_PFO_PROTO', 'NULL_NULL')

                if pfo_proto == 'TCP':
                    query.updateValueByIndex(index, '1,')
                elif pfo_proto == 'UDP':
                    query.updateValueByIndex(index, '2,')
                continue

            elif k == 'srvAddr':
                pfo_server = os.getenv('U_CUSTOM_PFO_SERVER', 'NULL_NULL')
                if pfo_server == 'NULL_NULL':
                    pfo_server = os.getenv('G_HOST_TIP0_1_0')
                query.updateValueByIndex(index, pfo_server)
                continue

            elif k == 'rmLst':
                rmLst_ori = query.value('rmLst')
                print 'original remove list : ', rmLst_ori
                vals = rmLst_ori.split('|')
                local_ip = vals[0]
                remote_ip = vals[6]
                eStart = vals[1]
                eEnd = vals[2]
                iStart = vals[4]
                iEnd = vals[5]
                protocal = vals[3] #    U_CUSTOM_PFO_PROTO

                new_protocal = os.getenv('U_CUSTOM_PFO_PROTO', 'NULL_NULL')

                if new_protocal != 'NULL_NULL':
                    protocal = new_protocal

                new_iStart = os.getenv('U_CUSTOM_PFO_INTERNAL_START', os.getenv('U_TR069_DEF_INTERNAL_PORT'))
                new_iEnd = os.getenv('U_CUSTOM_PFO_INTERNAL_END', os.getenv('U_TR069_DEF_INTERNAL_PORT_END_RANGE'))
                new_eStart = os.getenv('U_CUSTOM_PFO_EXTERNAL_START',
                                       'NULL_NULL')#, os.getenv('U_TR069_DEF_EXTERNAL_PORT'))
                new_eEnd = os.getenv('U_CUSTOM_PFO_EXTERNAL_END',
                                     'NULL_NULL')#, os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE'))

                if new_eStart == 'NULL_NULL' and new_eEnd == 'NULL_NULL':
                    new_eStart = new_iStart
                    new_eEnd = new_iEnd
                else:
                    new_eStart = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', os.getenv('U_TR069_DEF_EXTERNAL_PORT'))
                    new_eEnd = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE'))

                new_local_ip = os.getenv('U_CUSTOM_PFO_SERVER', 'NULL_NULL')
                if new_local_ip == 'NULL_NULL':
                    new_local_ip = os.getenv('G_HOST_TIP0_1_0')

                #print 'remote ip : ', remote_ip

                U_CUSTOM_PFO_SERVER_WANADDR = os.getenv('U_CUSTOM_PFO_SERVER_WANADDR', 'NULL_NULL')

                if U_CUSTOM_PFO_SERVER_WANADDR != 'NULL_NULL':
                    new_remote_ip = U_CUSTOM_PFO_SERVER_WANADDR
                else:
                    if remote_ip != '0.0.0.0':
                        new_remote_ip = os.getenv('TMP_DUT_DEF_GW', remote_ip)
                    else:
                        new_remote_ip = remote_ip

                rmLst_new = new_local_ip + '|' + new_eStart + '|' + new_eEnd + '|' + protocal + '|' + new_iStart + '|' + new_iEnd + '|' + new_remote_ip

                query.updateValueByIndex(index, rmLst_new)
                continue
            #,eStart_add_idx    ,eEnd_add_idx    ,iStart_add_idx    ,iEnd_add_idx
            elif k == 'eStart':
                eStart_add = query.value('eStart')
                eStart_add_idx = index
                all_port += 1

                query = self.repl_port(query, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                continue

            elif k == 'eEnd':
                eEnd_add = query.value('eEnd')
                eEnd_add_idx = index
                all_port += 1

                query = self.repl_port(query, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                continue

            elif k == 'iStart':
                iStart_add = query.value('iStart')
                iStart_add_idx = index
                all_port += 1

                query = self.repl_port(query, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                continue

            elif k == 'iEnd':
                iEnd_add = query.value('iEnd')
                iEnd_add_idx = index
                all_port += 1

                query = self.repl_port(query, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                continue
        return query

    def replBody(self, body):
        """
        replace body string
        """
        fmt = body.fmt()
        all_port = 0
        eStart_add_idx = eEnd_add_idx = iStart_add_idx = iEnd_add_idx = None

        for index, k in enumerate(fmt['keys']):
            #    'srvAddr':'G_HOST_TIP0_1_0', proto=1, or 2, 1=tcp 2=udp when remove TCP/UPD
            v = fmt['vals'][index]
            if k == 'srvWanAddr':
                srvWanAddr_ori = body.value('srvWanAddr')
                #print 'srvWanAddr_ori :', srvWanAddr_ori
                if srvWanAddr_ori != '0.0.0.0':
                    srvWanAddr = os.getenv('U_CUSTOM_PFO_SERVER_WANADDR', 'NULL_NULL')
                    if srvWanAddr == 'NULL_NULL':
                        srvWanAddr = os.getenv('TMP_DUT_DEF_GW', os.getenv('G_HOST_TIP1_2_0'))
                else:
                    srvWanAddr = os.getenv('U_CUSTOM_PFO_SERVER_WANADDR', 'NULL_NULL')
                    if srvWanAddr == 'NULL_NULL':
                        srvWanAddr = '0.0.0.0'

                body.updateValueByIndex(index, srvWanAddr)
                continue

            elif k == 'proto':
                pfo_proto = os.getenv('U_CUSTOM_PFO_PROTO', 'NULL_NULL')

                if pfo_proto == 'TCP':
                    body.updateValueByIndex(index, '1,')
                elif pfo_proto == 'UDP':
                    body.updateValueByIndex(index, '2,')
                continue

            elif k == 'srvAddr':
                pfo_server = os.getenv('U_CUSTOM_PFO_SERVER', 'NULL_NULL')
                if pfo_server == 'NULL_NULL':
                    pfo_server = os.getenv('G_HOST_TIP0_1_0')
                body.updateValueByIndex(index, pfo_server)
                continue

            elif k == 'rmLst':
                rmLst_ori = body.value('rmLst')
                print 'original remove list : ', rmLst_ori
                vals = rmLst_ori.split('|')
                local_ip = vals[0]
                remote_ip = vals[6]
                eStart = vals[1]
                eEnd = vals[2]
                iStart = vals[4]
                iEnd = vals[5]
                protocal = vals[3] #    U_CUSTOM_PFO_PROTO

                new_protocal = os.getenv('U_CUSTOM_PFO_PROTO', 'NULL_NULL')

                if new_protocal != 'NULL_NULL':
                    protocal = new_protocal

                new_iStart = os.getenv('U_CUSTOM_PFO_INTERNAL_START', os.getenv('U_TR069_DEF_INTERNAL_PORT'))
                new_iEnd = os.getenv('U_CUSTOM_PFO_INTERNAL_END', os.getenv('U_TR069_DEF_INTERNAL_PORT_END_RANGE'))
                new_eStart = os.getenv('U_CUSTOM_PFO_EXTERNAL_START',
                                       'NULL_NULL')#, os.getenv('U_TR069_DEF_EXTERNAL_PORT'))
                new_eEnd = os.getenv('U_CUSTOM_PFO_EXTERNAL_END',
                                     'NULL_NULL')#, os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE'))

                if new_eStart == 'NULL_NULL' and new_eEnd == 'NULL_NULL':
                    new_eStart = new_iStart
                    new_eEnd = new_iEnd
                else:
                    new_eStart = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', os.getenv('U_TR069_DEF_EXTERNAL_PORT'))
                    new_eEnd = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE'))

                new_local_ip = os.getenv('U_CUSTOM_PFO_SERVER', 'NULL_NULL')
                if new_local_ip == 'NULL_NULL':
                    new_local_ip = os.getenv('G_HOST_TIP0_1_0')

                #print 'remote ip : ', remote_ip

                U_CUSTOM_PFO_SERVER_WANADDR = os.getenv('U_CUSTOM_PFO_SERVER_WANADDR', 'NULL_NULL')

                if U_CUSTOM_PFO_SERVER_WANADDR != 'NULL_NULL':
                    new_remote_ip = U_CUSTOM_PFO_SERVER_WANADDR
                else:
                    if remote_ip != '0.0.0.0':
                        new_remote_ip = os.getenv('TMP_DUT_DEF_GW', remote_ip)
                    else:
                        new_remote_ip = remote_ip

                rmLst_new = new_local_ip + '|' + new_eStart + '|' + new_eEnd + '|' + protocal + '|' + new_iStart + '|' + new_iEnd + '|' + new_remote_ip

                body.updateValueByIndex(index, rmLst_new)
                continue
            #,eStart_add_idx    ,eEnd_add_idx    ,iStart_add_idx    ,iEnd_add_idx
            elif k == 'eStart':
                eStart_add = body.value('eStart')
                eStart_add_idx = index
                all_port += 1

                body = self.repl_port(body, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                continue

            elif k == 'eEnd':
                eEnd_add = body.value('eEnd')
                eEnd_add_idx = index
                all_port += 1

                body = self.repl_port(body, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                continue

            elif k == 'iStart':
                iStart_add = body.value('iStart')
                iStart_add_idx = index
                all_port += 1

                body = self.repl_port(body, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                continue

            elif k == 'iEnd':
                iEnd_add = body.value('iEnd')
                iEnd_add_idx = index
                all_port += 1

                body = self.repl_port(body, all_port, eStart_add_idx, eEnd_add_idx, iStart_add_idx, iEnd_add_idx)
                continue

        return body
