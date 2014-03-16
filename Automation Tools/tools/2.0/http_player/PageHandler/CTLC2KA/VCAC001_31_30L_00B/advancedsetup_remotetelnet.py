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
import httplib2, urllib, base64
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
        replace Body
        """
        fmt = body.fmt()

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'remTelUser':
                ev = os.getenv('U_DUT_TELNET_USER')
                if ev:
                    v = ev
                    print '== change adminUserName to : ', v
                body.updateValueByIndex(index, v)
                fname = os.getenv('U_CUSTOM_UPDATE_ENV_FILE', None)

                if fname:
                    fname = os.path.expandvars(fname)
                    file = open(fname, 'a')
                    file.write('-v U_DUT_TELNET_USER=' + v + '\n')
                    file.close()
                continue
            elif k == 'remTelPass':
                rgui_pwd = os.getenv('U_DUT_TELNET_PWD')
                #password = base64.encodestring(password + '\0').strip()
                #ev = rgui_pwd
                ev = base64.encodestring(rgui_pwd + '\0').strip()
                if ev:
                    v = ev
                body.updateValueByIndex(index, v)
                fname = os.getenv('U_CUSTOM_UPDATE_ENV_FILE', None)

                if fname:
                    fname = os.path.expandvars(fname)
                    file = open(fname, 'a')
                    file.write('-v U_DUT_TELNET_PWD=' + rgui_pwd + '\n')
                    file.close()
                continue
            elif k == 'remTelTimeout':
                ev = os.getenv('U_CUSTOM_REMOTE_GUI_TIMEOUT')
                if ev:
                    v = ev
                    print '== change remGuiTimeout to : ', v
                body.updateValueByIndex(index, v)
                continue
            elif k == 'remTelTimeout':
                ev = os.getenv('U_DUT_TELNET_PORT')
                if ev:
                    v = ev
                    print '== change remGuiPort to : ', v
                body.updateValueByIndex(index, v)
                continue
        return body

