import sys, time, os
import re


hash_pageHdlrs = {
    'CORTINA-BHR4-0-0-01F': 'V01F',
}

def_pageHdlr = 'CORTINA-BHR4-0-0-01F'


def getPageHandler(prod_ver, player):
    """
    Dispatcher for Version
    """
    pageHdlr = None
    for (k, v) in hash_pageHdlrs.items():
        if k == prod_ver:
            pageHdlr = v
            print '==', 'Find specified PageHandler for Version ' + prod_ver
            break
    if not pageHdlr:
        print '==', 'Not find specified PageHandler for Version ' + str(prod_ver)
        print '==', 'Using the default PageHandler for Version ' + def_pageHdlr
        pageHdlr = hash_pageHdlrs[def_pageHdlr]
    cmd = 'from ' + pageHdlr + ' import PageHandler'
    exec (cmd)
    hdlr = PageHandler(player)
    return hdlr
	
