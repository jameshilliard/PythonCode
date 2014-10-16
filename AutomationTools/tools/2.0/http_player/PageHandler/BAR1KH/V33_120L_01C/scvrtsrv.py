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

"""
action  add
srvName aDv_PoRt_FoRwArDiNg
srvAddr 192.168.2.10
eStart  6000,
eEnd    6000,
proto   1,
iStart  6000,
iEnd    6000,
srvWanAddr  0.0.0.0
sessionKey  546822514


action  remove
rmLst   192.168.2.123|26000|26000|UDP|26000|26000,192.168.2.123|27500|27500|UDP|27500|27500,192.168.2.123|27910|27910|UDP|27910|27910,192.168.2.123|27960|27960|UDP|27960|27960,
sessionKey  1770319505
needthankyou    advancedsetup_applications.html
"""

# TODO : add POST body format string map to an unique string (when have multi format string ,the unique string id decided how to match)
body_fmts["sessionKey"] = ''
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
            new_iStart_add = os.getenv('U_CUSTOM_PFO_INTERNAL_START') and os.getenv(
                'U_CUSTOM_PFO_INTERNAL_START') or os.getenv('U_TR069_DEF_INTERNAL_PORT')
            new_iEnd_add = os.getenv('U_CUSTOM_PFO_INTERNAL_END') and os.getenv(
                'U_CUSTOM_PFO_INTERNAL_END') or os.getenv('U_TR069_DEF_INTERNAL_PORT_END_RANGE')

            new_eStart = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', 'NULL_NULL')
            new_eEnd = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', 'NULL_NULL')

            if new_eStart == 'NULL_NULL' and new_eEnd == 'NULL_NULL':
                print "external port same as internal port"
                new_eStart_add = new_iStart_add
                new_eEnd_add = new_iEnd_add

            else:
                print "external port differ from internal port"
                new_eStart_add = os.getenv('U_CUSTOM_PFO_EXTERNAL_START') and os.getenv(
                    'U_CUSTOM_PFO_EXTERNAL_START') or os.getenv('U_TR069_DEF_EXTERNAL_PORT')
                new_eEnd_add = os.getenv('U_CUSTOM_PFO_EXTERNAL_END') and os.getenv(
                    'U_CUSTOM_PFO_EXTERNAL_END') or os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE')

            # do replace
            if new_eStart_add:
                body.updateValueByIndex(eStart_add_idx, new_eStart_add + ',')
            if new_eEnd_add:
                body.updateValueByIndex(eEnd_add_idx, new_eEnd_add + ',')
            if new_iStart_add:
                body.updateValueByIndex(iStart_add_idx, new_iStart_add + ',')
            if new_iEnd_add:
                body.updateValueByIndex(iEnd_add_idx, new_iEnd_add + ',')

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
        fmt = body.fmt()

        if body.hasKey('sessionKey'):
            id_add = os.getenv('TMP_PFO_SESSION_ID_ADD', None)
            id_del = os.getenv('TMP_PFO_SESSION_ID_DEL', None)

            act = body.value('action', None)
            #print '---->',id_add,id_del,act,fmt
            if act == 'add':
                if id_add != None:
                    body.updateValue('sessionKey', id_add)
            elif act == 'remove':
                if id_del != None:
                    body.updateValue('sessionKey', id_del)
        else:
            #print fmt
            pass
            # DO NOT replace
        #return body

        all_port = 0
        eStart_add_idx = eEnd_add_idx = iStart_add_idx = iEnd_add_idx = None

        for index, k in enumerate(fmt['keys']):
            #   'srvAddr':'G_HOST_TIP0_1_0', proto=1, or 2, 1=tcp 2=udp when remove TCP/UPD
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
            #   srvName aDv_PoRt_FoRwArDiNg
            elif k == 'srvName':
                if body.value(k) != 'aDv_PoRt_FoRwArDiNg':
                    srvName = os.getenv('U_CUSTOM_APF_SERVICE_NAME')
                    if srvName:
                        body.updateValueByIndex(index, srvName)
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
                if v.endswith(','):
                    print '== to delete application port forwarding'

                    rmLst_ori = body.value('rmLst')
                    print 'original remove list : ', rmLst_ori
                    vals = rmLst_ori.split('|')
                    local_ip = vals[0]
                    #remote_ip = vals[6]
                    eStart = vals[1]
                    eEnd = vals[2]
                    iStart = vals[4]
                    iEnd = iStart + ','
                    protocal = vals[3] #    U_CUSTOM_PFO_PROTO
                else:
                    #if body.value('scvrtsrv.cmd?action') == 'remove_port_forwarding':
                    print '== to delete port forwarding rule'

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

                if v.endswith(','):
                    rmLst_new = new_local_ip + '|' + new_eStart + '|' + new_eEnd + '|' + protocal + '|' + new_iStart + '|' + new_iEnd + ','
                else:
                    #if body.value('scvrtsrv.cmd?action') == 'remove_port_forwarding':
                    rmLst_new = new_local_ip + '|' + new_eStart + '|' + new_eEnd + '|' + protocal + '|' + new_iStart + '|' + new_iEnd + '|' + new_remote_ip

                body.updateValueByIndex(index, rmLst_new)
                continue
            #,eStart_add_idx    ,eEnd_add_idx   ,iStart_add_idx ,iEnd_add_idx
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

