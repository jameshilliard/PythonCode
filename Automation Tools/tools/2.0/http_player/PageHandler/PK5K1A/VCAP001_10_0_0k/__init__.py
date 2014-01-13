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
    'wirelesssetup_security.wl': 'wirelesssetup_security',
    'Act_Wlan_SetSecuritySettings': 'Act_Wlan_SetSecuritySettings',
    'k2': 'hdlr2',
    'k3': 'hdlr3',
    'act_ifx_cgi_adsl_wan_config': 'act_ifx_cgi_adsl_wan_config',
    'ifx_set_firewall_portforwarding': 'ifx_set_firewall_portforwarding',
    'act_set_lan_dhcps': 'act_set_lan_dhcps',
    'act_set_lan_dhcp_static_lease': 'act_set_lan_dhcp_static_lease',
    'act_set_wizard_tz': 'act_set_wizard_tz',
    'ifx_set_firewall_website_block': 'ifx_set_firewall_website_block',
    #'ifx_set_firewall_service_block' : 'ifx_set_firewall_service_block',
    'ifx_set_firewall_mac': 'ifx_set_firewall_mac',
    'ifx_set_act_application_applied': 'ifx_set_act_application_applied',
    'ifx_set_firewall_dmz_act': 'ifx_set_firewall_dmz_act',
    'act_set_telnet_setting': 'act_set_telnet_setting',
    'ipv6_traceroute': 'ipv6_traceroute',
    'act_set_web_wan': 'act_set_web_wan',
    'Act_Wlan_AddMacFilterConfiguration': 'Act_Wlan_AddMacFilterConfiguration',
    'act_set_support_tr69': 'act_set_support_tr69',
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
        self.info('PageHandler for PK5001A CAP001-10.0.0k')
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
        # TODO : find page handler
        path, query = urllib.splitquery(req['uri'])
        pn = os.path.basename(path)

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
		
