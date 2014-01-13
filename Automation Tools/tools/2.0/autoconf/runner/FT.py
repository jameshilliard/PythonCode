#!/usr/bin/env python -u
"""
VAutomation Test Engine Class
"""

__author__ = "Rayofox"
__version__ = "$Revision: 0.1 $"
__date__ = "$Date: $"
__copyright__ = "Copyright (c) 2011 Rayofox"
__license__ = "Python"

from tcEngine import tcEngine

import os, copy
import sys
import re
import hashlib
import time
import httplib2, urllib, urllib2
import imp
import types, base64
from pprint import pprint
from pprint import pformat


class Runner(tcEngine):
    """
    """

    def __init__(self):
        """
        """
        tcEngine.__init__(self)
        print '==Based Runner for Actiontec FiberTech '
        print '==Based Firmware Version : 4.0.16.1.56.100.10.12.104'
        print '==no need Login'

    #-------------------------------------------------------------------------------
    def parseResponse(self):
        return True


    def handleTestCaseResponse(self):
        return True

    #-------------------------------------------------------------------------------

    def replBeforeRequest(self):

        """
        """
        from url_repl.AFT_wi_repl import http_request_repl

        hrr = http_request_repl()
        cfg = copy.deepcopy(self.cfg)
        #print '==','cfg = ',pformat(self.cfg)
        cfg = hrr.do_repl(cfg)
        #print '==','newcfg = ',pformat(self.cfg)
        if cfg == self.cfg:
            print "==", "No replacement"
        else:
            print '==', 'cfg    = ', pformat(self.cfg)
            print '==', 'newcfg = ', pformat(cfg)
            self.cfg = cfg
        return True


    #-------------------------------------------------------------------------------

    def doLogin(self):
        """
        """
        return True

    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------

    def doLogout(self):
        """
        """
        return True

    #-------------------------------------------------------------------------------
    """parse test case file
    HOST = [192.168.1.254]
    USERNAME = []
    PASSWORD = []

    METHOD PATH DATA
    [GET] [\index.cgi] []
    [POST] [\index.cgi] [key=val&key2=val2]

    """

#-------------------------------------------------------------------------------


def main():
    """
    """
    argc = len(sys.argv)
    if argc < 2:
        print 'Usage : ', sys.argv[0], ' test_case_file'
        return False

    ###
    tc_file = sys.argv[1]
    runner = Runner()
    runner.setDebug()
    # load case info
    rc = runner.loadTestCaseFile(tc_file)

    rc = runner.run();
    if not runner.isResultPass():
        print '\n-| FAIL: ', runner.getLastError()
    else:
        print '\n-| PASS '

    return True


if __name__ == "__main__":
    main()
    """
    try:
        main()
    except Exception,e :
        print '\n-| FAIL: ',e
    """




