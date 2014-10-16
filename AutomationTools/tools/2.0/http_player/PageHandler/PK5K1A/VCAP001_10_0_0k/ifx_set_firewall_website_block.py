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
body_fmts["timezoneindex"] = 'timezoneindex=5&use_dst=0'
#body_fmts[""] = ''
#-----------------------------------------------------------------------
query_fmts = {}


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

        #    delflag=0&
        #    addF=1&
        #    delindex=&
        #    url=www.vosky.com&
        #    hostname=192.168.0.2&
        #    ip_addr=192.168.0.200

        #    delflag=1&
        #    addF=0&
        #    delindex=0&
        #    url=&
        #    hostname=&
        #    ip_addr=

        #    delflag=0&
        #    addF=1&
        #    delindex=&
        #    url=www.vosky.com&
        #    hostname=all&
        #    ip_addr=all

        fmt = body.fmt()

        is_add = body.value('addF')
        if is_add == '1':
            print '== to add a website blocking rule'
            #    hostname=192.168.0.2&
            #    ip_addr=192.168.0.200
            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'hostname' or k == 'ip_addr':
                    ev_ori = body.value(k)

                    if ev_ori != 'all':
                        ev = os.getenv('G_HOST_TIP0_1_0')
                        if ev:
                            v = ev
                            print '== change ' + k + ' to : ' + v
                        body.updateValueByIndex(index, v)
                        #continue
                        continue
        elif is_add == '0':

            print '== to delete a website blocking rule'

            fmt = body.fmt()

            for index, k in enumerate(fmt['keys']):
                v = fmt['vals'][index]
                if k == 'delindex':
                    delindexs = os.getenv('WBL_RULE_INDEX', 'NULL_NULL')
                    if delindexs != 'NULL_NULL':
                        delidxs = delindexs.split(',')
                        delindex = delidxs[0]
                        body.updateValueByIndex(index, delindex)
                    continue

        return body

