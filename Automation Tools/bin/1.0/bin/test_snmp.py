#!/usr/bin/env python

#
# $Id: test_snmp.py,v 1.2.4.1 2007/11/27 14:22:07 manderson Exp $
#


import sys, string, os

## XXX - if windows, make sure c:\program files\veriwave\library.zip is in

# Find current working directory and then define a global automation_dir
current_path = os.getcwd()
argv_path = sys.argv[0]

if os.path.isabs(current_path) and os.path.isabs(argv_path):
    current_path = argv_path
else:
    current_path = os.path.join(current_path, argv_path)

full_path = os.path.normpath(current_path)

vwconfig_path_list = os.path.split(full_path)
vwconfig_path = vwconfig_path_list[0]
automation_dir_list = os.path.split(vwconfig_path)
automation_dir = automation_dir_list[0]

# Need path to automation python lib
# insert a path to we_lib
sys.path.insert(0, "%s/lib/python" % (automation_dir))

# define vw_install_dir
automation_path_list = os.path.split(automation_dir)
vw_install_dir = automation_path_list[0]

# Need paths to apps python libs
sys.path.insert(0, "%s/lib/python" % (vw_install_dir))

# all the above path funkiness stolen from vwConfig.py

from vwSnmpWrap_lib import *

##################################### Main ###################################
# Commandline execution starts here


#top of the enterprie mib (1.3.6.1.4.1)
# airspace enterprise id 14179
# 1.3.6.1.4.1.14179.1.1.5.1.0 cpu
# 1.3.6.1.4.1.141791.1.5.2.0 total ram
# 1.3.6.1.4.1.141791.1..5.3.0 free ram

systemip = "10.10.250.2"
community = "public"
oid_dict={}
oid_dict["1.3.6.1.4.1.14179.1.1.5.1"]={}
oid_dict["1.3.6.1.4.1.14179.1.1.5.1"]["name"]="cpu load"
oid_dict["1.3.6.1.4.1.14179.1.1.5.2"]={}
oid_dict["1.3.6.1.4.1.14179.1.1.5.2"]["name"]="total memory" 
oid_dict["1.3.6.1.4.1.14179.1.1.5.3"]={}
oid_dict["1.3.6.1.4.1.14179.1.1.5.3"]["name"]="free memory"

# don't call the net snmp libraries use simple stub
print "\n\ncalling as stub with default dummy returns"
(ret_val,query_errors) = vw_do_snmp_query(systemip,community,oid_dict)
if (ret_val == 0):
    vw_print_oid_dict(oid_dict)

# calling with cisco controller snmp vals
#
# call the net snmp libraries and actually do a query
print "\n\nattempt a real query via netsnmp tools"
snmp_query = vw_build_snmp_command_string(systemip,community,oid_dict)
print "snmp query we wil run is",snmp_query
(ret_val,query_errors) = vw_do_snmp_query(systemip,community,oid_dict,0)
if (ret_val == 0):
    vw_print_oid_dict(oid_dict)

oid_dict={}
oid_dict["1.3.6.1.4.1.14179.1.1.27.1"]={}
oid_dict["1.3.6.1.4.1.14179.1.1.27.1"]["name"]="cpu load"
oid_dict["1.3.6.1.4.1.14179.1.1.5.2"]={}
oid_dict["1.3.6.1.4.1.14179.1.1.5.2"]["name"]="total memory"
oid_dict["1.3.6.1.4.1.14179.1.1.5.3"]={}
oid_dict["1.3.6.1.4.1.14179.1.1.5.3"]["name"]="free memory"

# calling with cisco controller snmp vals which cause a mismatch
#
# call the net snmp libraries and actually do a query
print "\n\ncalling in manner which will cause mismatched oid return values"
snmp_query = vw_build_snmp_command_string(systemip,community,oid_dict)
print "snmp query we wil run is",snmp_query
(ret_val,query_errors) = vw_do_snmp_query(systemip,community,oid_dict,0)
if ret_val == 0:
    vw_print_oid_dict(oid_dict)
else:
    if  ret_val == -3:
        print "Error: query returned value from unexpected oid"
        vw_print_oid_dict_detail(oid_dict)
#

oid_dict={}
oid_dict["1.3.6.1.4.1.14179.1.1.5.1"]={}
oid_dict["1.3.6.1.4.1.14179.1.1.5.1"]["name"]="cpu load"
oid_dict["1.3.6.1.4.1.14179.1.1.5.2"]={}
oid_dict["1.3.6.1.4.1.14179.1.1.5.2"]["name"]="total memory"
oid_dict["1.3.6.1.4.1.14179.1.1.5.3"]={}
oid_dict["1.3.6.1.4.1.14179.1.1.5.3"]["name"]="free memory"
oid_dict["foo.1.3.6.1.4.1.14179.1.1.5.3"]={}
oid_dict["foo.1.3.6.1.4.1.14179.1.1.5.3"]["name"]="free memory"

# calling with cisco controller snmp vals which cause an snmp query failure
#
# call the net snmp libraries and cause an snmp query failure
print "\n\ncalling in manner which will cause an snmp query failure"
snmp_query = vw_build_snmp_command_string(systemip,community,oid_dict)
print "snmp query we wil run is",snmp_query
(ret_val,query_errors) = vw_do_snmp_query(systemip,community,oid_dict,0)
if ret_val == 0:
    vw_print_oid_dict(oid_dict)
else:
    if  ret_val == -1:
        print "Snmp_query_error:", query_errors

