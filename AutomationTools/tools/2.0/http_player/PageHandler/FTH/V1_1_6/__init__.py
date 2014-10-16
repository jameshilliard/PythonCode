#       __init__.py
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
	The dispatcher for specified page
"""

#-----------------------------------------------------------------------
import os, time, sys
import re, urllib

import _default_hdlr as def_hdlr

#-----------------------------------------------------------------------
# TODO : add map keyword in url to page file name
# map key is value of active_page_str
pages_handles = {
    #'page_actiontec_wireless_status' : 'wireless_status',
    'page_actiontec_wireless_advanced_setup': 'wireless_advanced_setup',
    'page_actiontec_wireless_setup_wep': 'wireless_setup_wep',
    'page_actiontec_wireless_basic_setup': 'wireless_basic_setup',
    'page_actiontec_wireless_setup_wpa': 'wireless_setup_wpa',
    'page_actiontec_wireless_setup_wpa2': 'wireless_setup_wpa',
    'page_conn_settings_ppp0': 'conn_settings_ppp',
    'page_conn_settings_ppp1': 'conn_settings_ppp',
    'page_actiontec_wireless_setup_mac': 'wireless_setup_mac',
}

#-----------------------------------------------------------------------

class PageHandler():
    """
    """
    m_msglvl = 2
    m_hashENV = {}
    m_replPOST = True
    m_replGET = False
    m_player = None

    def __init__(self, player, loglevel=2):
        """
        """
        self.loadEnv()
        # TODO ,add your specified Version info
        self.info('PageHandler for BHR2 20.19.0')
        self.m_player = player

    def loadEnv(self):
        """
        """
        for (k, v) in os.environ.items():
            if 0 == k.find('G_'):
                self.m_hashENV[k] = v
            elif 0 == k.find('U_'):
                self.m_hashENV[k] = v
            elif 0 == k.find('TMP_'):
                self.m_hashENV[k] = v

    def debug(self, msg):
        """
        """
        if self.m_msglvl > 2:
            pprint('== ' + self.__class__.__name__ + ' Debug : ' + pformat(msg))
        return True

    def info(self, msg):
        """
        """
        if self.m_msglvl > 1:
            print '== ' + self.__class__.__name__ + ' Info : ', str(msg)
        return True

    def warning(self, msg):
        """
        """
        if self.m_msglvl > 0:
            print '== ' + self.__class__.__name__ + ' Warning : ', str(msg)
        return True

    def error(self, msg):
        """
        """
        print '== ' + self.__class__.__name__ + ' Error : ', str(msg)
        return True

    def find_page(self, req):
        """
        """
        _page = None
        page_info = {}
        #path = req['uri']
        #pn = os.path.basename(path)
        pn = ''
        m = r'active_page_str=([^&=]*)'
        q = None
        if self.m_replPOST:
            q = req['request-body']

        #if self.m_replGET :
        if not q:
            q = req['uri']
            q = urllib.unquote(q)

        if q:
            res = re.findall(m, q)
            if len(res) > 0:
                pn = res[0]

        name = None
        if pages_handles.has_key(pn):
            name = pages_handles[pn]

        page_info['pagename'] = (req['method'] + ' ' + pn)
        page_info['handler'] = None
        page_info['result'] = None
        page_info['message'] = "No page handler"

        if name:
            #print "--"*8
            print ''
            print '==', "pagename = ", pn
            print ''
            cmd = 'import ' + name + ' as dut_page'
            #print "==","exec",cmd
            exec (cmd)
            #print "==done","exec",cmd
            _page = dut_page
            page_info['handler'] = _page
        else:
            #print '++++++',pn
            pass
        return _page, page_info

    def checkRequest(self, req):
        """
        """
        #print "==HERE"
        (page, page_info) = self.find_page(req)
        if page:
            #page.check(req,page_info)
            pg = page.Page(self.m_player, self.m_msglvl)
            pg.check(req, page_info)

        return page_info

    def replRequest(self, req):
        """
        """
        (resp, changed) = (req, False)
        # do default repl first
        def_hdlr.replace(req)
        # do special repl next
        (page, page_info) = self.find_page(req)
        if page:
            #(resp,changed) = page.replace(req)
            pg = page.Page(self.m_player, self.m_msglvl)
            (resp, changed) = pg.replace(req)
        return (resp, changed)
		
