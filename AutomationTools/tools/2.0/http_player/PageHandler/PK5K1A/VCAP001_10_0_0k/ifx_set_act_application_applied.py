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
#body_fmts[""] = ''
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
        # TODO : Implement your hash replacement
        fmt = body.fmt()

        is_add = body.value('addF')
        is_del = body.value('delflag')

        if is_add == '2':
            print '== to create application rule detial 2'

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'name':
                    ev = os.getenv('U_CUSTOM_APF_SERVICE_NAME')
                    if ev:
                        v = urllib.unquote_plus(ev.strip())
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'start':
                    ev = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', os.getenv('U_TR069_DEF_EXTERNAL_PORT'))
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'end':
                    ev = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE'))
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'protocol':
                    pfo_proto = os.getenv('U_CUSTOM_PFO_PROTO', 'NULL_NULL').upper()

                    if pfo_proto == 'TCP':
                        body.updateValueByIndex(index, pfo_proto)
                    elif pfo_proto == 'UDP':
                        body.updateValueByIndex(index, pfo_proto)
                    continue
        elif is_del == '2':
            print '== to delete application rule detail 2'

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'name':
                    ev = os.getenv('U_CUSTOM_APF_SERVICE_NAME')
                    if ev:
                        v = urllib.unquote_plus(ev.strip())
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'start':
                    ev = os.getenv('U_CUSTOM_PFO_EXTERNAL_START', os.getenv('U_TR069_DEF_EXTERNAL_PORT'))
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'end':
                    ev = os.getenv('U_CUSTOM_PFO_EXTERNAL_END', os.getenv('U_TR069_DEF_EXTERNAL_PORT_END_RANGE'))
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'protocol':
                    pfo_proto = os.getenv('U_CUSTOM_PFO_PROTO', 'NULL_NULL').upper()

                    if pfo_proto == 'TCP':
                        body.updateValueByIndex(index, pfo_proto)
                    elif pfo_proto == 'UDP':
                        body.updateValueByIndex(index, pfo_proto)
                    continue
        elif is_add == '1':
            print '== to create application rule detial 1'
            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'name':
                    ev = os.getenv('U_CUSTOM_APF_SERVICE_NAME')
                    if ev:
                        v = urllib.unquote_plus(ev.strip())
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'ipaddr':
                    ev = os.getenv('G_HOST_TIP0_1_0')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
        elif is_del == '1':
            print '== to create application rule detial 1'
            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'name':
                    ev = os.getenv('U_CUSTOM_APF_SERVICE_NAME')
                    if ev:
                        v = urllib.unquote_plus(ev.strip())
                    body.updateValueByIndex(index, v)
                    continue
                elif k == 'ipaddr':
                    ev = os.getenv('G_HOST_TIP0_1_0')
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                    continue
        return body


	
	
	
	