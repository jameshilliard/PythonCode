import os, time, sys
import re
import urllib
import _default_hdlr as def_hdlr

pages_handles = {
    "wireless_advanced.html": "wireless_advanced",
    "wireless_advanced_wep.html": "wireless_advanced",
    "wireless_advanced_wpa.html": "wireless_advanced",
    "wireless_advanced_wep.cgi": "wireless_advanced",
    "wireless_advanced_wpa.cgi": "wireless_advanced",
    "wireless_basic.html": "wireless_basic",
    "wireless_basic.cgi": "wireless_basic",
    "wireless_advanced_mac.cgi": "wireless_advanced_mac",
    "mynetwork_connections_br_settings.cgi": "mynetwork_connections_br_settings",
    "advanced_datetime.cgi": "advanced_datetime",
    "firewall_dmz_host.cgi": "firewall_dmz_host",
    "advanced_dhcp_connections.cgi": "advanced_dhcp_connections",
    "parental_rule.cgi": "parental_rule",
    "firewall_port_forwarding.cgi": "firewall_port_forwarding",
    "advanced_port_forwarding_edit.cgi": "advanced_port_forwarding_edit",
    "mynetwork_connections_ppp_settings.cgi": "mynetwork_connections_ppp_settings",
    "mynetwork_connections_eth_settings.cgi": "mynetwork_connections_eth_settings",

    # Sevice blocking
    "firewall_advanced_filtering.cgi": "firewall_advanced_filtering",
    "advanced_ipdistribution.cgi": "advanced_ipdistribution",
    "firewall_access_control.cgi": "firewall_access_control"
}


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
        self.info('PageHandler for FiberTech FTH-BHRK2-10-10-08E')
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
        path, query = urllib.splitquery(req['uri'])
        pn = os.path.basename(path)

        name = None
        if pages_handles.has_key(pn):
            name = pages_handles[pn]

        page_info['pagename'] = pn
        page_info['handler'] = None
        page_info['result'] = None
        page_info['message'] = "find page handler"

        if name:
            print "--" * 8
            print "pagename = ", pn
            cmd = 'import ' + name + ' as dut_page'
            print "==", "exec", cmd
            exec (cmd)
            #print "==done","exec",cmd
            _page = dut_page
            page_info['handler'] = _page
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
        
