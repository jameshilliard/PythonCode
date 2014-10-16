import sys, time, os
import re
from pages import _default_hdlr as def_hdlr

pages_handles = {
    "wireless_advanced_wep.html": "wireless_advanced",
    "wireless_advanced_wep.cgi": "wireless_advanced",
    "wireless_basic.html": "wireless_basic",
}


def find_page(req):
    """
    """
    _page = None
    page_info = {}
    path = req['path']
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
        cmd = 'from pages import ' + name + ' as dut_page'
        #print "==","exec",cmd
        exec (cmd)
        #print "==done","exec",cmd
        _page = dut_page
        page_info['handler'] = _page
    return _page, page_info


def hdlr_check_request(req):
    """
    """
    (page, page_info) = find_page(req)
    if page:
        page.check(req, page_info)

    return page_info


def hdlr_repl_request(req):
    """
    """
    # do default repl first
    def_hdlr.replace(req)
    # do special repl next
    (page, page_info) = find_page(req)
    if page:
        page.replace(req)
    return req
