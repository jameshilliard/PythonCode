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
body_fmts[
    "AdMiNpAsSwOrD1"] = 'etpage=confirm.html&username=root&userNewPswd=Thr33scr33n%21&security%3Asettings%2Fpassword_confirm=Thr33scr33n%21+&connection0%3Afwan%3Asettings%2Fprivate%2Fremote_web%2Fstate=0&security%3Asettings%2Fhold=%3C%3F+query+security%3Astatus%2Fhold+%3F%3E&connection0%3Afwan%3Asettings%2Fprivate%2Fremote_web%2FRedirectPort=9000&OldPasswd=0&connection0%3Afwan%3Asettings%2Fprivate%2Fremote_web%2Fweb_timeout=15&var%3Afrompage=..%2Fhtml%2Fadvancedsetup_remotegui.html&page=confirm.html&frompage=advancedsetup_remotegui.html&remote_management_timeout=15&AdMiNuSeRnAmE=root&AdMiNpAsSwOrD=Thr33scr33n%21&AdMiNpAsSwOrD1=Thr33scr33n%21+&RemotePort=9000'
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
#    username=root
#    userNewPswd=Thr33scr33n%21
#    security%3Asettings%2Fpassword_confirm=Thr33scr33n%21+
#    connection0%3Afwan%3Asettings%2Fprivate%2Fremote_web%2FRedirectPort=9000
#    connection0%3Afwan%3Asettings%2Fprivate%2Fremote_web%2Fweb_timeout=15
#    remote_management_timeout=15
#    AdMiNuSeRnAmE=root
#    AdMiNpAsSwOrD=Thr33scr33n%21
#    AdMiNpAsSwOrD1=Thr33scr33n%21+
#    RemotePort=9000
        """
        fmt = body.fmt()

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'username' or k == 'AdMiNuSeRnAmE':
                ev = os.getenv('U_CUSTOM_REMOTE_GUI_USERNAME')
                if ev:
                    v = ev
                    print '== change %s to %s ' % (k, v)
                body.updateValueByIndex(index, v)
                fname = os.getenv('U_CUSTOM_UPDATE_ENV_FILE', None)

                if fname:
                    fname = os.path.expandvars(fname)
                    file = open(fname, 'a')
                    file.write('-v U_DUT_HTTP_USER=' + v + '\n')
                    file.close()
                continue
            elif k == 'userNewPswd' or k == 'AdMiNpAsSwOrD':
                rgui_pwd = os.getenv('U_CUSTOM_REMOTE_GUI_PASSWORD')
                ev = rgui_pwd
                if ev:
                    v = ev
                    print '== change %s to %s ' % (k, v)
                body.updateValueByIndex(index, v)
                fname = os.getenv('U_CUSTOM_UPDATE_ENV_FILE', None)

                if fname:
                    fname = os.path.expandvars(fname)
                    file = open(fname, 'a')
                    file.write('-v U_DUT_HTTP_PWD=' + rgui_pwd + '\n')
                    file.close()
                continue
            elif k == 'security:settings/password_confirm' or k == 'AdMiNpAsSwOrD1':
                rgui_pwd = os.getenv('U_CUSTOM_REMOTE_GUI_PASSWORD')
                ev = rgui_pwd + ' '
                if ev:
                    v = ev
                    print '== change %s to %s ' % (k, v)
                body.updateValueByIndex(index, v)
                continue
            elif k == 'remote_management_timeout' or k == 'connection0:fwan:settings/private/remote_web/web_timeout':
                ev = os.getenv('U_CUSTOM_REMOTE_GUI_TIMEOUT')

                if ev:
                    ev = str(int(ev) / 60)
                    v = ev
                    print '== change %s to %s ' % (k, v)
                body.updateValueByIndex(index, v)
                continue
            elif k == 'connection0:fwan:settings/private/remote_web/RedirectPort' or k == 'RemotePort':
                ev = os.getenv('U_CUSTOM_REMOTE_GUI_PORT')
                if ev:
                    v = ev
                    print '== change %s to %s ' % (k, v)
                body.updateValueByIndex(index, v)
                continue
            #
        return body

