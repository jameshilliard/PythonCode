#!/usr/bin/env python

#
# $Id: vwConfig.py,v 1.88.2.4.2.9 2008/02/08 15:55:51 manderson Exp $
#

#
# Version information
#
release_version = "4.0.3-WT-3.4"
waveauto_banner = "WaveAutomation version %s" % release_version
vwconfig_version = "$RCSfile: vwConfig.py,v $ $Revision: 1.88.2.4.2.9 $ $Date: 2008/02/08 15:55:51 $"

import sys, string, os, imp
import time, threading, datetime
from optparse import OptionParser, OptionGroup

# we are vwConfig!

global is_vwconfig
global automation_dir
global vwconfig_path

is_vwconfig = True

# Find current working directory and then define a global automation_dir
current_path = os.getcwd()
argv_path = sys.argv[0]

if os.path.isabs(current_path) and os.path.isabs(argv_path):
    current_path = argv_path
else:
    current_path = os.path.join(current_path, argv_path)

full_path = os.path.normpath(current_path)


if os.name == "nt":
    ps = "\\"
else:
    ps = "/"

    
vwconfig_path_list = os.path.split(full_path)
vwconfig_path = vwconfig_path_list[0]
automation_dir_list = os.path.split(vwconfig_path)
automation_dir = automation_dir_list[0]

# define vw_install_dir
automation_path_list = os.path.split(automation_dir)
vw_install_dir = automation_path_list[0]


python_lib_dir = "%s%slib%spython" % (vw_install_dir, ps, ps)
python_lib_dir_trailing = "%s%s" % (python_lib_dir, ps)

sys.path.insert(0, "%s%slib%swmx" % (automation_dir, ps, ps))
sys.path.insert(0, "%s" % (python_lib_dir))
sys.path.insert(0, "%svcl" % (python_lib_dir_trailing))
sys.path.insert(0, "%sPIL" % (python_lib_dir_trailing))

sys.path.insert(0, "%swiMix" % (python_lib_dir_trailing))
sys.path.insert(0, "%swimix" % (python_lib_dir_trailing))

sys.path.insert(0, "%s%sapps%swiMix" % (vw_install_dir, ps, ps))

# these need to be in __main__

current_group = "groupmike"
client_dict = {}
roaming_dict = {}
blog_dict = {}
callbacks = {}
cards = []
group_list = []
card_dict = {}
vw_dicts = {}
callback_dicts = {}
wimix_traffic_dict = {}
wimix_server_dict = {}
wimix_test_dict = {}

new_wml_file = ""
test_name = ""

from wmxConfig_startup import *

cleanup_from_last_run(automation_dir)
    
#from wmlParser import *
from wmxConfig_lib import *
from wmxConfig_defaults import *
from wmxConfig_tests import *
from wmxConfig_options import *


# do... stuff :-)
from wmxConfig_main import *
