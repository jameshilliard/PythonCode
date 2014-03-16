import sys, time, os
import re


hash_pageHdlrs = {
    'FTH-BHRK2-10-10-08D': 'V08D',
    'FTH-BHRK2-10-10-08E': 'V08E',
}

def_pageHdlr = 'FTH-BHRK2-10-10-08E'


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
	
