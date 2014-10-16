#!/usr/bin/env python

import sys, os

# old style
install_root = os.environ.get('VW_INSTALL_ROOT')
if install_root == None:
    # a logical guess
    install_root = "%s/veriwave" % (os.environ.get('HOME'))

sys.path.insert(0, "%s/lib/python/vcl" % (install_root))

from vcl import *

argc = len(sys.argv)
if argc < 2:
    print "Usage: ", sys.argv[0], "<ip address>"
    sys.exit(1)
    
chassis.connect(sys.argv[1])
chassis.setUserId(0)
port.unbindAll()
chassis.disconnectAll()
