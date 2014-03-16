#!/usr/bin/env python

import re,sys
import __main__

global dom
global config
global docNode
global vw_dicts
global wmlInstance
global wml_file
global verbose
global duts

import sys, string, os
import time, threading, datetime
import random

from optparse import OptionParser, OptionGroup

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

sys.path.insert(0, "%s%slib%swml" % (automation_dir, ps, ps))
sys.path.insert(0, "%s" % (python_lib_dir))
sys.path.insert(0, "%svcl" % (python_lib_dir_trailing))
sys.path.insert(0, "%sPIL" % (python_lib_dir_trailing))

sys.path.insert(0, "%swave_engine" % (python_lib_dir_trailing))
sys.path.insert(0, "%swave_engine%smodels" % (python_lib_dir_trailing,ps))

# we need to build a recursive list of directories from the %s/apps folder to append, one at a time
# to our path so that we can import each of our tests.

for root, dirs, files in os.walk("%s%sapps" % (vw_install_dir, ps)):
    for dir_name in dirs:
        sys.path.insert(0, "%s%sapps%s%s" % (vw_install_dir, ps, ps, dir_name))

# these need to be in __main__

# Define default log directory location
if automation_dir:
    logs_dir = "%s/results" % (automation_dir)
else:
    logs_dir = "/tmp"

from wmlParser import *
import WaveEngine

###############
#
# UTILITY FUNCTIONS
#
###############

def write_comment(line):
    write_to_config("\n#%s" % line)


def write_commented_keylset(group, key, value):
    write_comment(form_keylset(group, key, value))

    
def write_keylset(group, key, value):
    global config
    
    line = form_keylset(group, key, value)
    write_to_config(line)


def return_keylset(group, key, value):
    return form_keylset(group, key, value)

    
def form_keylset(group, key, value):
    line = "keylset %s %s" % (group, key)
    
    if type(value) == list:
        line = "%s %s" % (line, list_to_keylset(value))
    else:
        if type(value) == str:
            if value.count(" ") != 0:
                value = "\"%s\"" % value
            elif value.count("\\") != 0:
                value = "\"%s\"" % value
                
        line = "%s %s" % (line, value)

    return line

 
def write_to_config(line=""):
    global config
    
    if len(config) == 0:
        config = "%s\n" % line
    else:
        config = "%s%s\n" % (config, line)

    
def list_to_keylset(ll):
    nlist = range(len(ll))
    
    for i in range(len(ll)):
        new_item = str(ll[i])
        nlist[i] = '"%s"' % new_item;
        
    return "{%s}" % " ".join(nlist)

    
def stripWhiteSpace(rootNode):
    to_delete = []
    for i in range(len(rootNode.childNodes)):
        node = rootNode.childNodes[i]
        if node.nodeType == node.TEXT_NODE:
            text_value = node.nodeValue.strip()
            if len(text_value) == 0:
                to_delete.append(node)
        if node.nodeType == node.ELEMENT_NODE:
            stripWhiteSpace(node)

    for node in to_delete:
        rootNode.removeChild(node)


def getTextValue(node):
    if len(node.childNodes) == 1:
        return node.firstChild.nodeValue
    else:
        value = ""
        for child in node.childNodes:
            if child.nodeType == node.TEXT_NODE:
                if len(value) == 0:
                    value = child.nodeValue.strip()
                else:
                    value = "%s %s" % (value, child.nodeValue.strip())
        return value


def format_port(port):
    pf = dict()
    #192.168.10.249_card1_port1
    if port.count("_") > 0:
        parts = port.split("_")
        card = parts[1][4:]
        port = parts[2][4:]
        pf['vwauto_format'] = "%s:%s.%s" % (parts[0], card, port)
        pf['wml_format'] = port
    #192.168.10.249:1.1
    elif port.count(":") > 0:
        parts = port.split(":")
        port_parts = parts[1].split('.');
        pf['vwauto_format'] = port
        pf['wml_format'] = "%s_card%s_port%s" % (parts[0], port_parts[0], port_parts[1])

    return pf

    
def is_value_default(path, key, value):
    global wmlParser
    global verbose
    
    metadata = wmlParser.wmlMetadata.getKeyMetadata(key, path, True)
    
    if metadata == None:
        print "WARNING: metadata is none, key is %s, path is %s" % (key, path)
        return

    if str(metadata['default']) == str(value):
        return True
        
    return False


def normalize_key(key):
    key = key.lower()
    return "%s%s" % (key[0].upper(), key[1:])


def make_camelcase(key):
    if key.count(" ") == 0:
        return key
    else:
        parts = key.split(" ")
        full_key = ""
        for part in parts:
            full_key = "%s%s" % (full_key, normalize_key(part))
    
        return full_key


def pop_random_dut(group, auxdut=False):
    global dut_group_mapping
    global duts
    global verbose
    global used_duts

    for i in range(len(dut_group_mapping[group])):
        dut = dut_group_mapping[group][i]
        if duts[dut]['AuxDut'] == auxdut:
            if len(dut_group_mapping[group]) == 1:
                return dut
            else:
                if dut in used_duts:
                    continue
                else:
                    used_duts.append(dut)
                    return dut_group_mapping[group].pop(i)
                    
    if auxdut == False:
        return dut_group_mapping[group][0]
    return None
    

def execute_subrules(rule, group):
    keys = __main__.__dict__.keys()
    
    rules = []

    keys.sort()
    for key in keys:
        if key.startswith("subrule_%s" % rule):
            exec("func = %s" % key)
            rules.append(func)
    
    for rule in rules:
        rule(group)
        

###############
#
# RULES
#
# rules are executed in alphabetical (via sort) order. prefix with number, such as rule_1_rulename to make it come first.
#
###############

def rule_0_prework():
    global vw_dicts
    global verbose
    global wml_file
    
    if verbose:
        print "DEBUG: rule_0_prework()"

    write_comment("Auto-generated from: %s\n#At: %s" % (wml_file, datetime.datetime.today()))
    execute_subrules(0, False)
    

def subrule_0_0_ports_to_groups(group=False):
    global vw_dicts
    global group_to_ports
    global verbose
    global used_duts
    
    used_duts = []
    
    if verbose:
        print "DEBUG: subrule_0_ports_to_groups(%s)" % group
    
    group_to_ports = dict()
    
    waveChassisStore = vw_dicts['waveChassisStore']
    waveClientTableStore = vw_dicts['waveClientTableStore']
    waveTestSpecificStore = vw_dicts['waveTestSpecificStore']
    wavePortStore = vw_dicts['wavePortStore']
    
    if verbose:
        print "DEBUG: wavePortStore: %s" % wavePortStore
        print "DEBUG: _____"
        print "DEBUG: waveChassiStore: %s" % waveChassisStore
    
    test_name = waveTestSpecificStore.keys()[0]
    
    group_list = waveClientTableStore.keys()
    group_list.sort()

    cardcount = -1
    
    for chassis in waveChassisStore.keys():
        for card in waveChassisStore[chassis].keys():
            card_dict = waveChassisStore[chassis][card]
            for port in card_dict.keys():
                hw_port_dict = waveChassisStore[chassis][card][port]
                if hw_port_dict['PortType'] in WaveEngine.WiFiPortTypes:
                    cardcount = cardcount + 1
                
                port_name = hw_port_dict['PortName']
                formatted_port = "%s:%s.%s" % (chassis, hw_port_dict['CardID'], hw_port_dict['PortID'])
   
                port_dict = dict()
                port_dict['formatted_port'] = formatted_port
                port_dict['port_name'] = port_name
            
                for group in group_list:
                    if not(group_to_ports.has_key(group)):
                        group_to_ports[group] = []
                
                    if waveClientTableStore[group]['PortName'] == "Roam":
                        ssid = waveClientTableStore[group]['Ssid']
                        assigned_bssid = waveClientTableStore[group]['Bssid']
                    
                        if wavePortStore.has_key(port_name):
                            for bssid in wavePortStore[port_name]:
                                if wavePortStore[port_name][bssid] == ssid:
                                    if not(assigned_bssid == bssid):
                                        port_dict['AuxDut'] = True
                                        port_dict['Bssid'] = bssid
                                        port_dict['Ssid'] = ssid
                                        port_dict['Type'] = "802.11"
                                        port_dict['Channel'] = hw_port_dict['Channel']
                                    
                                        if hw_port_dict['PortType'] == '80211n':
                                            port_dict['RadioType'] = 'n'
                                        else:
                                            if int(port_dict['Channel']) > 15:
                                                port_dict['RadioType'] = "a"
                                            else:
                                                port_dict['RadioType'] = "bg"
                                    
                                        group_to_ports[group].append(port_dict)
                                    else:
                                        port_dict['AuxDut'] = False
                                        port_dict['Bssid'] = bssid
                                        port_dict['Ssid'] = ssid
                                        port_dict['Type'] = "802.11"
                                        port_dict['Channel'] = hw_port_dict['Channel']
                                    
                                        if hw_port_dict['PortType'] == '80211n':
                                            port_dict['RadioType'] = 'n'
                                        else:
                                            if int(port_dict['Channel']) > 15:
                                                port_dict['RadioType'] = "a"
                                            else:
                                                port_dict['RadioType'] = "bg"
                                        
                                        group_to_ports[group].append(port_dict)
                                    
                    if waveClientTableStore[group]['PortName'] == "None":
                        ssid = waveClientTableStore[group]['Ssid']
                        if wavePortStore.has_key(port_name):
                            for bssid in wavePortStore[port_name]:
                                if wavePortStore[port_name][bssid] == ssid:
                                    port_dict['AuxDut'] = False
                                    port_dict['Bssid'] = bssid
                                    port_dict['Ssid'] = ssid
                                    port_dict['Type'] = "802.11"
                                    port_dict['Channel'] = hw_port_dict['Channel']
                                
                                    if hw_port_dict['PortType'] == '80211n':
                                        port_dict['RadioType'] = 'n'
                                    else:
                                        if int(port_dict['Channel']) > 15:
                                            port_dict['RadioType'] = "a"
                                        else:
                                            port_dict['RadioType'] = "bg"
                                    
                                    group_to_ports[group].append(port_dict)

                    if waveClientTableStore[group]['PortName'] == "N/A":
                
                        ssid = waveClientTableStore[group]['Ssid']

                        if wavePortStore.has_key(port_name):
                            for bssid in wavePortStore[port_name]:
                                if wavePortStore[port_name][bssid] == ssid:
                                    port_dict['AuxDut'] = False
                                    port_dict['Bssid'] = bssid
                                    port_dict['Ssid'] = ssid
                                    port_dict['Type'] = "802.11"
                                    port_dict['Channel'] = hw_port_dict['Channel']
                                
                                    if hw_port_dict['PortType'] == '80211n':
                                        port_dict['RadioType'] = 'n'
                                    else:
                                        if int(port_dict['Channel']) > 15:
                                            port_dict['RadioType'] = "a"
                                        else:
                                            port_dict['RadioType'] = "bg"
                                
                                    group_to_ports[group].append(port_dict)
                                
                    if waveClientTableStore[group]['PortName'] == port_name:
                        if waveClientTableStore[group]['Interface'] == WaveEngine.EthInterface:
                            port_dict['Type'] = "802.3"
                            group_to_ports[group].append(port_dict)
                        else:
                            ssid = waveClientTableStore[group]['Ssid']
                            bssid = waveClientTableStore[group]['Bssid']
                            port_dict['AuxDut'] = False
                            port_dict['Bssid'] = bssid
                            port_dict['Ssid'] = ssid
                            port_dict['Type'] = "802.11"
                            port_dict['Channel'] = hw_port_dict['Channel']
                        
                            if hw_port_dict['PortType'] == '80211n':
                                port_dict['RadioType'] = 'n'
                            else:
                                if int(port_dict['Channel']) > 15:
                                    port_dict['RadioType'] = "a"
                                else:
                                    port_dict['RadioType'] = "bg"
                            
                            group_to_ports[group].append(port_dict)
 

def subrule_0_1_make_duts(group=False):
    global vw_dicts
    global group_to_ports
    global duts
    global verbose
    
    if verbose:
        print "DEBUG: subrule_0_make_duts(%s)" % group
        print "DEBUG:", group_to_ports
    
    duts = dict()
    
    waveClientTableStore = vw_dicts['waveClientTableStore']
    wavePortStore = vw_dicts['wavePortStore']
    waveChassisStore = vw_dicts['waveChassisStore']
    waveTestSpecificStore = vw_dicts['waveTestSpecificStore']
    
    test_name = waveTestSpecificStore.keys()[0]
    
    group_list = waveClientTableStore.keys()
    group_list.sort()
    
    wireless_ports = []
    ether_ports = []
    
    appended_ports = []
    
    ether_port = None
    
    for group in group_list:
        ports = group_to_ports[group]
        
        for port in ports:
            if port['Type'] == "802.3":
                if appended_ports.count(port['formatted_port']) == 0:
                    ether_ports.append(port)
                    appended_ports.append(port['formatted_port'])
            elif port['Type'] == "802.11":
                if appended_ports.count(port['formatted_port']) == 0:
                    wireless_ports.append(port)
                    appended_ports.append(port['formatted_port'])
    
    for chassis in waveChassisStore.keys():
        
        for card in waveChassisStore[chassis].keys():
        
            card_dict = waveChassisStore[chassis][card]
            for port in card_dict.keys():
                hw_port_dict = waveChassisStore[chassis][card][port]
                port_name = hw_port_dict['PortName']
            
                if port_name not in wavePortStore.keys():
                    continue
                
                port_type = hw_port_dict['PortType']
                formatted_port = "%s:%s.%s" % (chassis, hw_port_dict['CardID'], hw_port_dict['PortID'])
                port_dict = dict()
                port_dict['formatted_port'] = formatted_port
            
                if appended_ports.count(formatted_port) == 0:
                    if port_type == WaveEngine.EthPortType:
                        port_dict['Type'] = "802.3"
                        ether_ports.append(port_dict)
                    else:
                        bssid = wavePortStore[port_name].keys()[0]
                        ssid = wavePortStore[port_name][bssid]
                    
                        port_dict['AuxDut'] = False
                        port_dict['Bssid'] = bssid
                        port_dict['Ssid'] = ssid
                        port_dict['Type'] = "802.11"
                        port_dict['Channel'] = hw_port_dict['Channel']
                    
                        if hw_port_dict['PortType'] == "80211n":
                            port_dict['RadioType'] = 'n'
                        else:
                            if int(port_dict['Channel']) > 15:
                                port_dict['RadioType'] = "a"
                            else:
                                port_dict['RadioType'] = "bg"

                        wireless_ports.append(port_dict)
   
    #
    # A sample config for a generic, unknown or unsupported AP.  In any case,
    # WaveAutomate will not try to configure this device.
    #
    #
    # Do not change the Vendor from generic.  To add a vendor to the output PDF, add it to the APModel line
    #keylset sample-generic-ap Vendor                          generic
    
    # Configure as needed.  These values are passed down into the PDF
    #keylset sample-generic-ap APModel                         unspecified
    #keylset sample-generic-ap APSwVersion                     unspecified
    
    # Hardware mappings between the AP and the Veriwave chassis
    #keylset sample-generic-ap Interface.802_11b.InterfaceType 802.11bg
    #keylset sample-generic-ap Interface.802_11b.WavetestPort  192.168.1.1:5
    
    #keylset sample-generic-ap Interface.802_11a.InterfaceType 802.11a
    #keylset sample-generic-ap Interface.802_11a.WavetestPort  192.168.1.1:6
    
    #keylset sample-generic-ap Interface.802_3.InterfaceType   802.3
    #keylset sample-generic-ap Interface.802_3.WavetestPort    192.168.1.1:1
    
    # The WaveAutomate configuration file is TCL. One can do many things to save
    # time and lessen the chance of errors
    #set sample-generic-ap2 ${sample-generic-ap}
    #keylset sample-generic-ap2 Interface.802_11b.WavetestPort 192.168.1.1:3
    #keylset sample-generic-ap2 Interface.802_11a.WavetestPort 192.168.1.1:4


    # lets be stupid about this. make a dut for every single wireless port
    # with the ethernet interface shared across all duts.
    
    dut_counter = 0
    for wireless_port in wireless_ports:
        dut_name = "generic_dut_%s" % dut_counter
        dut_counter = dut_counter + 1
        
        dut_def = dict()
        dut_def['ports'] = []
        dut_def['Vendor'] = "generic"
        dut_def['APSwVersion'] = "unspecified"
        dut_def['APModel'] = "unspecified"
        dut_def['Interface'] = dict()
        dut_def['Ssid'] = wireless_port['Ssid']
        
        if wireless_port['RadioType'] == "a":
            dut_def['Interface']['802_11a'] = dict()
            dut_def['Interface']['802_11a']['InterfaceType'] = "802.11a"
            dut_def['Interface']['802_11a']['WavetestPort'] = wireless_port['formatted_port']

        elif wireless_port['RadioType'] == 'bg':
            dut_def['Interface']['802_11b'] = dict()
            dut_def['Interface']['802_11b']['InterfaceType'] = "802.11bg"
            dut_def['Interface']['802_11b']['WavetestPort'] = wireless_port['formatted_port']
        
        else:
            dut_def['Interface']['802_11n'] = dict()
            dut_def['Interface']['802_11n']['InterfaceType'] = "802.11abgn"
            dut_def['Interface']['802_11n']['WavetestPort'] = wireless_port['formatted_port']
            
        dut_def['ports'].append(wireless_port['formatted_port'])
        dut_def['AuxDut'] = wireless_port['AuxDut']

        duts[dut_name] = dut_def
        
        
    for ether_port in ether_ports:
        
        dut_name = "generic_dut_%s" % dut_counter
        dut_counter = dut_counter + 1
        
        dut_def = dict()
        dut_def['ports'] = []
        dut_def['Vendor'] = "generic"
        dut_def['APSwVersion'] = "unspecified"
        dut_def['APModel'] = "unspecified"
        dut_def['Interface'] = dict()
        dut_def['AuxDut'] = False

        dut_def['Interface']['802_3'] = dict();
        dut_def['Interface']['802_3']['InterfaceType'] = "802.3"
        dut_def['Interface']['802_3']['WavetestPort'] = ether_port['formatted_port']
        
        dut_def['ports'].append(ether_port['formatted_port'])
        
        duts[dut_name] = dut_def
    

def subrule_0_2_duts_to_groups(group=False):
    global vw_dicts
    global group_to_ports
    global duts
    global dut_group_mapping
    global verbose
    
    waveTestSpecificStore = vw_dicts['waveTestSpecificStore']
    test_name = waveTestSpecificStore.keys()[0]
    
    if verbose:
        print "DEBUG: subrule_0_duts_to_groups(%s)" % group
    
    dut_group_mapping = dict()
    
    waveClientTableStore = vw_dicts['waveClientTableStore']
    group_list = waveClientTableStore.keys()
    group_list.sort()
    
    wireless_duts = []
    if test_name == "wimix_script":
        dut_list = duts.keys()
        
        for dut in dut_list:
            if duts[dut]['Interface'].has_key('802_11b') or duts[dut]['Interface'].has_key('802_11a'):
                wireless_duts.append(dut)
                
        for i in range(len(group_list)):
            group = group_list[i]
            dut_group_mapping[group] = []
            
            if len(wireless_duts) > i:
                dut_group_mapping[group].append(wireless_duts[i])
                waveClientTableStore[group]['Ssid'] = duts[wireless_duts[i]]['Ssid']
            else:
                dut_group_mapping[group].append(wireless_duts[0])
                waveClientTableStore[group]['Ssid'] = duts[wireless_duts[0]]['Ssid']
                
    else:
        for group in group_list:
            dut_group_mapping[group] = []
            
            ports = group_to_ports[group]
        
            if waveClientTableStore[group]['Interface'] == "802.3 Ethernet":
                for dut in duts.keys():
                    formatted_port = ports[0]['formatted_port']
                    if duts[dut]['ports'].count(formatted_port) > 0:
                        if duts[dut]['AuxDut'] == False:
                            dut_group_mapping[group].append(dut)
    
            for port in ports:
                if port['Type'] == "802.3":
                    continue
                    
                for dut in duts.keys():
                    if duts[dut]['ports'].count(port['formatted_port']) > 0:
                        dut_group_mapping[group].append(dut)


def rule_1_chassisName():
    global config
    global vw_dicts
    global verbose
    
    if verbose:
        print "DEBUG: rule_1_chassisName()"

    write_keylset("global_config", "ChassisName", vw_dicts['waveChassisStore'].keys()[0])


def rule_2_licenseKeyComment():
    global verbose
    
    if verbose:
        print "DEBUG: rule_2_licenseKeyComment()"
        
    write_comment("License Keys for running tests beyond the basic benchmarking tests")
    write_commented_keylset("global_config", "LicenseKey", ['#####-#####-#####', '#####-#####-#####'])


def rule_3_direction():
    global vw_dicts
    global verbose
    
    if verbose:
        print "DEBUG: rule_3_direction()"
        
    waveMappingStore = vw_dicts['waveMappingStore']
    
    if len(waveMappingStore) == 0:
        if verbose:
            print "DEBUG: WaveMappingStore was empty, not defining Direction"
        return
    else:
        write_keylset("global_config", "Direction", [waveMappingStore[4]])


def rule_4_sourceDestination():
    global vw_dicts
    global verbose
    
    if verbose:
        print "DEBUG: rule_4_sourceDestination()"
        
    waveTestSpecificStore = vw_dicts['waveTestSpecificStore']
    waveMappingStore = vw_dicts['waveMappingStore']
    wavePortStore = vw_dicts['wavePortStore']
    waveChassisStore = vw_dicts['waveChassisStore']
    waveClientTableStore = vw_dicts['waveClientTableStore']
    
    sourceList = []
    destList = []
    
    group_list = waveClientTableStore.keys()
    
    test_name = waveTestSpecificStore.keys()[0]
        
    if test_name == "wimix_script":
        sourceList.append(group_list[0])
        destList = group_list[1:]
        
    if waveTestSpecificStore[test_name].has_key('roamTraffic'):
        for i in range(len(waveTestSpecificStore[test_name]['roamTraffic'])):
            sdPair = waveTestSpecificStore[test_name]['roamTraffic'][i]
            sourceList.append(sdPair[0])
            destList.append(sdPair[1])

    if len(waveMappingStore) > 0:
        sourceList = waveMappingStore[1]
        destList = waveMappingStore[2]

    # couple of other places to look for it.
    # one, waveTestSpecificStore[test_name]['AutoMap']['trafficDirection'] (Qos*)
     
    # two, waveTestSpecificStore[test_name]['TrafficDir'] (Tcp Goodput)

    ether_groups = []
    wireless_groups = []
    
    # sort groups into either ethernet or wireless.
    for group in waveClientTableStore.keys():
        if waveClientTableStore[group]['Interface'] == "802.3 Ethernet":
            ether_groups.append(group)
        if waveClientTableStore[group]['Interface'].startswith("802.11 a/b/g"):
            wireless_groups.append(group)
            
    if waveTestSpecificStore[test_name].has_key("AutoMap"):
        raw_direction = waveTestSpecificStore[test_name]['AutoMap']['trafficDirection']
        
        if raw_direction.lower() == "wireless to ethernet":
            sourceList = wireless_groups
            destList = ether_groups
        else:
            sourceList = ether_groups
            destList = wireless_groups
        
    if waveTestSpecificStore[test_name].has_key("TrafficDir"):
        raw_direction = waveTestSpecificStore[test_name]['TrafficDir']
        
        if raw_direction.lower() == "wireless to ethernet":
            sourceList = wireless_groups
            destList = ether_groups
        else:
            sourceList = ether_groups
            destList = wireless_groups

    if len(sourceList) > 0 and len(destList) > 0:
        write_keylset("global_config", "Source", sourceList)
        write_keylset("global_config", "Destination", destList)
        

def rule_4_channel():
    global vw_dicts
    global verbose
    
    if verbose:
        print "DEBUG: rule_4_channel()"
        
    channel_list = []
    waveChassisStore = vw_dicts['waveChassisStore']
    
    if verbose:
        print "DEBUG: waveChassisStore: %s" % waveChassisStore
        
    for chassis in waveChassisStore.keys():
        for card in waveChassisStore[chassis].keys():
            card_dict = waveChassisStore[chassis][card]
            for port in card_dict.keys():
                if waveChassisStore[chassis][card][port]['PortType'] == "80211" and waveChassisStore[chassis][card][port]['BindStatus'] == 'True':
                    if channel_list.count(waveChassisStore[chassis][card][port]['Channel']) == 0:
                        channel_list.append(waveChassisStore[chassis][card][port]['Channel'])

    write_keylset("global_config", "Channel", channel_list)


def rule_5_global_options():
    global vw_dicts
    global wmlParser
    global verbose
    
    if verbose:
        print "DEBUG: rule_5_global_options()"
    
    waveTestStore = vw_dicts['waveTestStore']
    waveMappingStore = vw_dicts['waveMappingStore']
    
    for key in waveTestStore.keys():
        if key == "DutInfo":
            continue
            
        write_comment("%s Global Options" % key)
        write_to_config()
        
        for global_option in waveTestStore[key].keys():
            if not(is_value_default("waveTestStore.%s" % key, global_option, waveTestStore[key][global_option])):
                write_keylset("global_config", global_option, waveTestStore[key][global_option])
    

def rule_6_testlist():
    global vw_dicts
    global verbose
    
    if verbose:
        print "DEBUG: rule_6_testlist()"
        
    waveTestSpecificStore = vw_dicts['waveTestSpecificStore']
    
    # if there's more than one key in this dict, its an undefined result, assume key 0, this should be a list anyway.
    test_list = waveTestSpecificStore.keys()
    
    write_comment("Tests - you may define more than one in a TCL list.")
    write_keylset("global_config", "TestList", test_list)


def rule_7_groups():
    global vw_dicts
    global wmlParser
    global verbose
    
    if verbose:
        print "DEBUG: rule_7_groups()"
        
    waveClientTableStore = vw_dicts['waveClientTableStore']
    waveSecurityStore = vw_dicts['waveSecurityStore']
    waveTestSpecificStore = vw_dicts['waveTestSpecificStore']
    waveTestStore = vw_dicts['waveTestStore']
    
    group_list = waveClientTableStore.keys()
    group_list.sort()
    
    for group in group_list:
        write_comment("Group %s" % group)
        
        # write our GroupType
        
        if waveClientTableStore[group]['Interface'] == "802.3 Ethernet":
            write_keylset(group, "GroupType", "802.3")
        elif waveClientTableStore[group]['Interface'] == '802.11 a/b/g/n':
            write_keylset(group, "GroupType", "802.11abgn")
        else:
            write_keylset(group, "GroupType", "802.11abg")

        execute_subrules("7", group)


def subrule_7_a_duts(group):
    global dut_group_mapping
    global duts
    global verbose
    
    if verbose:
        print "DEBUG: subrule_7_a_duts(%s)" % group
        
    main_dut = pop_random_dut(group)
    
    if main_dut != None:
        write_keylset(group, "Dut", main_dut)
        
    aux_dut = pop_random_dut(group, True)
    
    if aux_dut != None:
        write_keylset(group, "AuxDut", main_dut)
        

def subrule_7_b_clientoptions(group):
    global vw_dicts
    global wmlParser
    global verbose
    
    if verbose:
        print "DEBUG: subrule_7_b_clientoptions(%s)" % group
    
    waveClientTableStore = vw_dicts['waveClientTableStore']
    
    waveSecurityStore = vw_dicts['waveSecurityStore']
    waveTestSpecificStore = vw_dicts['waveTestSpecificStore']
    
    ignore_list = ["Enable", "PortName", "Interface", "NodeId", "Name", "Bssid"]
    write_comment("Group %s - Client Options" % group)
    # get our list of available options.
    
    na_fix_list = ['CtsToSelf', 'MgmtRetries', 'DataRetries', 'CwMin', 'CwMax', 'Sifs', 'Difs', 'SlotTime', 'AckTimeout', 'TransmitDeference']
    bad_values = ['N/A', 'None', -1, '-1']
    
    options = wmlParser.wmlMetadata.getKeysByPath("waveClientTableStore.%s" % group);
    for option in options:
        if option in na_fix_list:
            if verbose:
                print "WARNING: encountered option %s in na_fix_list, its value is %s" % (option,waveClientTableStore[group][option])
            if waveClientTableStore[group][option] in bad_values:
                waveClientTableStore[group][option] = 0

        if ignore_list.count(option) == 0:
            if option == "nPhySettings":
                for nKey in waveClientTableStore[group][option]:
                    if not(is_value_default("waveClientTableStore.%s.nPhySettings" % group, nKey, waveClientTableStore[group][option][nKey])):
                        write_keylset(group, nKey, waveClientTableStore[group][option][nKey])
            else:
                if not(is_value_default("waveClientTableStore.%s" % group, option, waveClientTableStore[group][option])):
                    write_keylset(group, option, waveClientTableStore[group][option])
   
    
def subrule_7_c_security(group):
    global vw_dicts
    global wmlParser
    global verbose
    
    if verbose:
        print "DEBUG: subrule_7_c_security(%s)" % group
        
    waveClientTableStore = vw_dicts['waveClientTableStore']
    waveSecurityStore = vw_dicts['waveSecurityStore']
    waveTestSpecificStore = vw_dicts['waveTestSpecificStore']
    
    method = waveSecurityStore[group]['Method']
    
    
    options = ['PrivateKeyFile', 'RootCertificate', 'StartIndex', 'ClientCertificate', 'AnonymousIdentity', 
    'EnableValidateCertificate','Identity', 'Password']
                    
    if waveClientTableStore[group]['Interface'].startswith("802.11 a/b/g"):
        write_comment("Group %s - Security Options" % group)
        write_keylset(group, 'Method', [method])
        
        for option in options:
            if option == "Method":
                write_keylset(group, option, [waveSecurityStore[group][option]])
            else:
                if not(is_value_default("waveSecurityStore.%s" % group, option, waveSecurityStore[group][option])):
                    write_keylset(group, option, waveSecurityStore[group][option])
    
    if method.startswith("WEP-"):
        keytype = waveSecurityStore[group]['KeyType']
        keytype = "%s%s" % (keytype[0].upper(), keytype[1:])
        
        if method.count("40") > 0:
            keywidth = 40
        else:
            keywidth = 128
            
        write_keylset(group, "WepKey%s%s" % (keywidth, keytype), waveSecurityStore[group]['NetworkKey'])
    
    
    if method.count("PSK") > 0:
        keytype = waveSecurityStore[group]['KeyType']
        keytype = "%s%s" % (keytype[0].upper(), keytype[1:])
        
        write_keylset(group, "Psk%s" % keytype, waveSecurityStore[group]['NetworkKey'])
        

def subrule_7_d_roaming(group):
    global vw_dicts
    global verbose
    
    if verbose:
        print "DEBUG: subrule_7_d_roaming(%s)" % group
    
    waveTestSpecificStore = vw_dicts['waveTestSpecificStore']
    waveClientTableStore = vw_dicts['waveClientTableStore']
    
    test_name = waveTestSpecificStore.keys()[0]
    
    group_list = waveClientTableStore.keys()
    
    ignore_list = ["portNameList", "bssidList", "ssid"]
    
    for group in group_list:
        if waveTestSpecificStore[test_name].has_key(group):
            options = wmlParser.wmlMetadata.getKeysByPath("waveTestSpecificStore.%s.%s" % (test_name, group));
            write_comment("Group %s - Roaming Options" % group)
            for option in options:
                if ignore_list.count(option) == 0:
                    if not(is_value_default("waveTestSpecificStore.%s.%s" % (test_name, group), option, waveTestSpecificStore[test_name][group][option])):
                        write_keylset(group, option, waveTestSpecificStore[test_name][group][option])


def rule_8_test():
    global vw_dicts
    global verbose
    
    if verbose:
        print "DEBUG: rule_8_test()"
        
    waveTestSpecificStore = vw_dicts['waveTestSpecificStore']
    
    if verbose:
        print "DEBUG: waveTestSpecificStore: %s" % waveTestSpecificStore
        
    test_name = waveTestSpecificStore.keys()[0]
    
    if test_name == "wimix_script":
        if verbose:
            print "DEBUG: skipping general test: wimix_script found"
            return
            
    write_comment("%s Options" % test_name)
    write_keylset(test_name, "Test", test_name)
    
    ignore_list = []
    
    options = wmlParser.wmlMetadata.getKeysByPath("waveTestSpecificStore.%s" % test_name);

    if len(options) == 1 and options[0].startswith("__") == True:
        if verbose:
            print "DEBUG: this is a test that defines its options at the group level. skipping test level config generation"
        return
     
    for option in options:
        if ignore_list.count(option) == 0:
            if waveTestSpecificStore[test_name].has_key(option):
                if type(waveTestSpecificStore[test_name][option]) == dict:
                    sub_options = wmlParser.wmlMetadata.getKeysByPath("waveTestSpecificStore.%s.%s" % (test_name, option));
                    normalized = normalize_key(option)
                    
                    for sub_option in sub_options:
                        full_keylset_name = "%s%s" % (normalized, sub_option)
                        
                        if ignore_list.count(sub_option) == 0:
                            if waveTestSpecificStore[test_name][option].has_key(sub_option):
                                if not(is_value_default("waveTestSpecificStore.%s.%s" % (test_name, option), sub_option, waveTestSpecificStore[test_name][option][sub_option])):
                                    write_keylset(test_name, full_keylset_name, waveTestSpecificStore[test_name][option][sub_option])
                else:
                    if waveTestSpecificStore[test_name].has_key(option):
                        if not(is_value_default("waveTestSpecificStore.%s" % test_name, option, waveTestSpecificStore[test_name][option])):
                            write_keylset(test_name, option, waveTestSpecificStore[test_name][option])
   

def rule_9_wimix_script():
    global vw_dicts
    global verbose
    global wml_file
    if verbose:
        print "DEBUG: rule_9_wimix_script()"
  
 
    waveTestSpecificStore = vw_dicts['waveTestSpecificStore']
    
    if verbose:
        print "DEBUG: waveTestSpecificStore: %s" % waveTestSpecificStore
        
    test_name = waveTestSpecificStore.keys()[0]
    
    if test_name != "wimix_script":
        if verbose:
            print "DEBUG: skipping rule rule_9_wimix_script(): wimix_script not found"
        return

    write_comment("Wimix Test Settings")
    
    if wml_file.count(".wcl") != 0:
		test_name = "wave_client"
		
    wimix = waveTestSpecificStore['wimix_script']
    
    wimix_mode = wimix['wimixMode']
    
    if wimix_mode == 1:
        wimix_mode = "Client"
        wimix_dict = wimix['clientWimix']
        
    else:
        wimix_mode = "Traffic"
        wimix_dict = wimix['trafficWimix']

    write_keylset(test_name, "wimixMode", wimix_mode)

    ignore_list = ['perTraffic', 'perClients', 'clientList', 'trafficList', 'delay', 'endTime', 'loadPps', 'numClients', 'clientGroupList']

    profile_name = wimix_dict['testProfile']
    profile_dict = wimix_dict['profiles'][profile_name]
    
    for key in wimix_dict:
        if type(wimix_dict[key]) == dict:
            continue
        write_keylset(test_name, key, wimix_dict[key])
        
    for key in profile_dict:
        if type(profile_dict[key]) == dict:
            continue
        else:
            if key not in ignore_list:   
                write_keylset(test_name, key, profile_dict[key])

    if wimix_mode == "Client":
        item_list = profile_dict['clientList']
        client_list = profile_dict['trafficList']
        percent_list = profile_dict['perClients']
        type_key = "TrafficType"
        prefix_key = "ClientMix"
    else:
        item_list = profile_dict['trafficList']
        client_list = profile_dict['clientGroupList']
        percent_list = profile_dict['perTraffic']
        type_key = "ClientType"
        prefix_key = "TrafficMix"
        
    all_use = ['delay', 'endTime']
   
    for i in range(len(item_list)):
        item_name = make_camelcase(item_list[i])
        percentage = percent_list[i]
        type_item = client_list[i]
        type_list = type_item.split(',')
        
        full_prefix = "%s.%s" % (prefix_key, item_name)
        
        write_keylset(test_name, "%s.%s" % (full_prefix, type_key), type_list)
        write_keylset(test_name, "%s.%s" % (full_prefix, "Percentage"), percentage)
        
        for key in all_use:
            if profile_dict.has_key(key):
                write_keylset(test_name, "%s.%s" % (full_prefix, key), profile_dict[key][i]) 
    
    execute_subrules("9", None)    
    

def subrule_9_a_wimix_traffic(group=None):
    global vw_dicts
    global verbose
    
    write_comment("Wimix Traffic Profiles")
    
    wimixTrafficStore = vw_dicts['wimixTrafficStore']
    
    profile_list = wimixTrafficStore.keys()

    for profile_name in profile_list:
        profile_key_name = make_camelcase(profile_name)
        
        prepend_key = "Wimixtraffic"
        write_to_config("\n")
        
        profile_keys = wimixTrafficStore[profile_name]
        
        do_later = []
        for key in profile_keys:
            if type(wimixTrafficStore[profile_name][key]) == dict:
                do_later.append(key)
            else:
                full_key = "%s%s" % (normalize_key(prepend_key), key)
                write_keylset(profile_key_name, full_key, wimixTrafficStore[profile_name][key])
            
        for prepend_key in do_later:
            sub_keys = wimixTrafficStore[profile_name][prepend_key].keys()
            
            for key in sub_keys:
                full_key = "%s%s" % (normalize_key(prepend_key), key)
                write_keylset(profile_key_name, full_key, wimixTrafficStore[profile_name][prepend_key][key])
    
    
def subrule_9_b_wimix_servers(group=None):
    global vw_dicts
    global verbose

    write_comment("Wimix Server Profiles")
    
    wimixServerStore = vw_dicts['wimixServerStore']
    
    profile_list = wimixServerStore.keys()

    for profile_name in profile_list:
        prepend_key = "Wimixserver"
        
        write_to_config("\n")
        profile_keys = wimixServerStore[profile_name]
        
        do_later = []
        for key in profile_keys:
            if type(wimixServerStore[profile_name][key]) == dict:
                do_later.append(key)
            else:
                if key == "ethPort":
                    fp = format_port(wimixServerStore[profile_name][key])
                    wimixServerStore[profile_name][key] = fp['vwauto_format']
                    
                full_key = "%s%s" % (normalize_key(prepend_key), key)
                write_keylset(profile_name, full_key, wimixServerStore[profile_name][key])
            
        for prepend_key in do_later:
            sub_keys = wimixServerStore[profile_name][prepend_key].keys()
            
            for key in sub_keys:
                full_key = "%s%s" % (normalize_key(prepend_key), key)
                write_keylset(profile_name, full_key, wimixServerStore[profile_name][prepend_key][key])
                

def rule_10_dut_definitions():
    global duts
    global verbose
    
    if verbose:
        print "DEBUG: rule_9_dut_definitions()"
        
    write_comment("Generic Dut Definitions")
    
    dut_list = duts.keys();
    dut_list.sort()
    
    for dut in dut_list:
        write_comment("Generic Dut - %s" % dut)
        for key in duts[dut].keys():
            if key == "AuxDut" or key == "ports" or key == "Ssid":
                continue
                
            if key == "Interface":
                for interface in duts[dut][key]:
                    for int_key in duts[dut][key][interface]:
                        write_keylset(dut, "%s.%s.%s" % (key, interface, int_key), duts[dut][key][interface][int_key])
            else:
                write_keylset(dut, key, duts[dut][key])
            

def rule_11_common_licensekey_source():
    global verbose
    
    if verbose:
        print "DEBUG: rule_10_common_licensekey_source()"
        
    write_comment("Source a file looking for a license key definition")
    write_to_config('catch {source [file join $env(HOME) "vw_licenses.tcl"]}')
    
    #if {[catch {source $full_lib} result]} {


###############
#
# wmlMetadata callbacks
#
###############


def __groupname__callback():
    global vw_dicts
    
    group_list = vw_dicts['waveClientTableStore'].keys()
    return group_list


def __groupname__valuecallback(resolvedKeyList, path):
    global vw_dicts
    
    waveClientTableStore = vw_dicts['waveClientTableStore']
    
    if waveClientTableStore.has_key(resolvedKeyList[0]):
        return waveClientTableStore[resolvedKeyList[0]]
        
    return None

def sort_rule(x, y):

    if not(x.startswith("rule_")):
        return 1
   
    if not(y.startswith("rule_")):
        return -1
        
    rule1 = int(x.split("_")[1])
    rule2 = int(y.split("_")[1])
    
    return rule1 - rule2

def wml_to_config(wfile, output_file=None, v=False):
    global wmlParser
    global config
    global wml_file
    global vw_dicts
    global verbose
    global oparser
    
    wml_file = wfile
    
    verbose = v
    
    if verbose:
        print "DEBUG: vw_install_dir is ", vw_install_dir
        print "DEBUG: wml_to_config(%s, %s)" % (wml_file, output_file)
    
    config = ""
    vw_dicts = dict()
    
    try:
        stat_results = os.stat(wml_file);
    except OSError:
        print "The specified wml file, %s, could not be found, or read" % wml_file
        oparser.print_help()
        sys.exit(0)

    wmlParser = parseWml(wml_file)
    
    # register callbacks for wmlMetadata
    wmlParser.wmlMetadata.registerMetavar("__groupname__", __groupname__callback, __groupname__valuecallback)
    wmlParser.wmlMetadata.registerMetavar("__80211groupname__", __groupname__callback, __groupname__valuecallback)

    vw_dict_list = wmlParser.parseWmlConfig(wml_file)
    
    for i in range(len(wmlParser.wmlMetadata.rootDictionaries)):
        dict_name = wmlParser.wmlMetadata.rootDictionaries[i]
        if i == len(vw_dict_list):
            break
        vw_dicts[dict_name] = vw_dict_list[i]
        
    keys = __main__.__dict__.keys()
    
    rules = []
    
    keys.sort(sort_rule)
    for key in keys:
        if key.startswith("rule_"):
            exec("func = %s" % key)
            rules.append(func)
    
    for rule in rules:
        rule()

    if output_file == None:
        print config
    else:
        try:
            if verbose:
                print "DEBUG: saving to output to file %s" % output_file
           
            if output_file != None:
                outfile = open(output_file, 'w')
                outfile.write("%s\n" % config)
                outfile.close()
            else:
                print config
                
        except IOError:
            print "ERROR: could not open %s for writing!" % output_file
            sys.exit(1)
            
        
###############
#
# MAIN
#
###############

# execute all of our defined rules:


if __name__ == "__main__":
    
    global options
    global oparser
    
    usage = "usage: %prog [options] WMLFILE"
    oparser = OptionParser(usage)
    oparser.set_conflict_handler("resolve")
    
    # vwConfig mode, and various options related to it.
    oparser.add_option("-o", "--output", dest="output_file", type="string",
                    help="file to save results to, if not specified, it will save to stdout",
                    metavar="output_file")
    oparser.add_option("-v", "--verbose", dest="verbose", action="store_true",
                    help="include debug output",
                    metavar="verbose")
    (options, args) = oparser.parse_args()
    
    if len(args) > 0:
        wml_file = args[0]
        if options.verbose:
            print "DEBUG: loading wml file %s" % wml_file
    else:
        wml_file = "new.wml"
        
    if options.verbose:
        v = True
    else:
        v = False
        
    if options.output_file:
        wml_to_config(wml_file, options.output_file, v)
    else:
        wml_to_config(wml_file, None, v)
