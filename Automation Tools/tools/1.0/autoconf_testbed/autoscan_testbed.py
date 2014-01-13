#!/usr/bin/python 
"""
This tool can auto scan the network device information of testbed.

you can scan local :
python -u autoscan_testbed.py 

you can scan local and remote and save result to file :
python -u autoscan_testbed.py -d 192.168.100.130 -u root -p actiontec -f result_file

you can scan local and remote setting in config file and save result to file :
python -u autoscan_testbed.py -c cfg_file -f result_file


you can edit the result file with your custom variable value,and to setup testbed with another tool autoconf_testbed.py:
python -u autoconf_testbed.py -c result_file

get usage :
python -u autoscan_testbed.py -h
"""
#------------------------------------------------------------------------------
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2011, Rayofox"
__version__ = "1.0"
__license__ = "MIT"
__history__ = """
Rev 1.0 : Initial version at 2011/08/31
"""
#------------------------------------------------------------------------------
import sys, time, os
import re
from optparse import OptionParser
from sshcmd import ssh_cmd
#------------------------------------------------------------------------------

cfg_tmpl = """
############################################################
# Test bed basic information
###########################################################


###########################################################
#Global 
###########################################################
G_HOST_DNS0             = 168.95.1.1
G_HOST_DNS1             = 10.20.10.10

###########################################################
# local test LAN PC
#
#
###########################################################
G_HOST_IP0              = 
G_HOST_USR0             = 
G_HOST_PWD0             = 
# eth0
G_HOST_IF0_0_0          = 
G_HOST_TIP0_0_0         = 
G_HOST_TMASK0_0_0       = 
G_HOST_MAC0_0_0         = 
G_HOST_GW0_0_0          = 
# eth1
G_HOST_IF0_1_0          = 
G_HOST_TIP0_1_0         = 
G_HOST_TMASK0_1_0       = 
G_HOST_MAC0_1_0         = 
G_HOST_GW0_1_0          = 
# eth2
G_HOST_IF0_2_0          = 
G_HOST_TIP0_2_0         = 
G_HOST_TMASK0_2_0       = 
G_HOST_MAC0_2_0         = 
G_HOST_GW0_2_0          = 

# 1st wlan
U_WIRELESSINTERFACE     = 
U_WIRELESSCARD_MAC      = 
# 2nd wlan 
U_WIRELESSINTERFACE2    = 
U_WIRELESSCARD_MAC2     = 
###########################################################
# test WAN PC
#
#
###########################################################
G_HOST_IP1              = 
G_HOST_USR1             = 
G_HOST_PWD1             = 
# eth0
G_HOST_IF1_0_0          = 
G_HOST_TIP1_0_0         = 
G_HOST_TMASK1_0_0       = 
G_HOST_MAC1_0_0         = 
G_HOST_GW1_0_0          = 
# eth1
G_HOST_IF1_1_0          = 
G_HOST_TIP1_1_0         = 
G_HOST_TMASK1_1_0       = 
G_HOST_MAC1_1_0         = 
G_HOST_GW1_1_0          = 
# eth2
G_HOST_IF1_2_0          = 
G_HOST_TIP1_2_0         = 
G_HOST_TMASK1_2_0       = 
G_HOST_MAC1_2_0         = 
G_HOST_GW1_2_0          = 

"""

dev_env = {}
#------------------------------------------------------------------------------
def is_wire_ethernet(devname):
    rc = False
    devname = str(devname)
    if devname.startswith('eth'): #named before FC15
        rc = True
    elif devname.startswith('em'): #named in FC15
        rc = True
    else:
        # p1p1 or pci1p1
        m = r'p\dp\d'
        if re.match(m, devname):
            rc = True
    return rc


def is_wifi(devname):
    rc = False
    devname = str(devname)
    if devname.startswith('wlan'):
        rc = True
    return rc

#------------------------------------------------------------------------------
def fetch_local(cmd):
    """
    execute command in local and return result
    """
    pipe = os.popen(cmd)
    return pipe.read()

#------------------------------------------------------------------------------
def fetch_remote(host, username, password, cmd):
    """
    ssh to remote and execute command and return result
    """
    res = ssh_cmd(host, username, password, cmd, timeout=opts['timeout'], debug=opts['debug'])
    #print '==',res
    return res

#------------------------------------------------------------------------------
def parse_ifconfig(resp):
    """
    parse result of command 'ifconfig ' and return network device information 
    """
    devs = []
    dev_info = {}
    lines = resp.splitlines()
    if_idx = 0
    iw_idx = 0
    for line in lines:
        #print '==>',line
        # match dev,type,hwaddr
        match = r'^([^\s]*)\s*Link\s*encap:(\w+)\s*HWaddr\s*([\w:]+)'
        r = re.findall(match, line, re.I)
        if len(r):
            #print r
            # add a new device
            (devname, devtype, hwaddr) = r[0]
            if dev_info.has_key('DEVICE'):
                info = {}
                info.update(dev_info)
                devs.append(info)
                dev_info = {}
            dev_info['DEVICE'], dev_info['TYPE'], dev_info['HWADDR'] = r[0]
            continue
            # match ip,bcast,mask
        match = r'\s*inet\s*addr:([\.\d]*)\s*Bcast:([\.\d]*)\s*Mask:([\.\d]*)'
        r = re.findall(match, line, re.I)
        #print '==>',r
        if len(r):
            dev_info['IPADDR'], dev_info['BROADCAST'], dev_info['NETMASK'] = r[0]
        # add the last
    if dev_info.has_key('DEVICE'):
        info = {}
        info.update(dev_info)
        devs.append(info)
        #print '==>',devs
    return devs

#------------------------------------------------------------------------------

ifcfg_tmpl = {
    'DEVICE': '',
    'HWADDR': '',
    'NM_CONTROLLED': 'no',
    'ONBOOT': 'yes',
    'BOOTPROTO': 'none',
    'TYPE': 'Ethernet',
    'IPADDR': '',
    'NETMASK': '',
    'GATEWAY': '',
    'DNS1': '',
    'DNS2': '',
    'IPV6INIT': 'no',
    'USERCTL': '',
    'PREFIX': '',
    'DEFROUT': 'no',
    'NOZEROCONF': 'yes',
}


def parse_ifcfg_file(resp):
    """
    parse ifcfg-ethx file and return network device information
    """
    dev_info = {}
    dev_info.update(ifcfg_tmpl)
    lines = resp.splitlines()
    for line in lines:
        if line.startswith('#'): continue
        match = r'([^=&]*)\s*=\s*(.*)'
        res = re.findall(match, line)
        if len(res):
            (k, v) = res[0]
            dev_info[k] = v
    return dev_info

#------------------------------------------------------------------------------
def save_ifconfig(devs, host_idx=0):
    """
    save the network device information to testbed envrionment variables
    return the string list format "K=V"
    """
    kvmap = {
        #'G_HOST_IP${host_idx}':'ip',
        'G_HOST_TIP${host_idx}_${dev_idx}_0': 'IPADDR',
        'G_HOST_TMASK${host_idx}_${dev_idx}_0': 'NETMASK',
        'G_HOST_IF${host_idx}_${dev_idx}_0': 'DEVICE',
        'G_HOST_GW${host_idx}_${dev_idx}_0': 'GATEWAY',
        'G_HOST_MAC${host_idx}_${dev_idx}_0': 'HWADDR',
    }
    r = []
    #host_idx = '0'
    #if not local : host_idx = '1'
    host_idx = str(host_idx)
    eth_idx = 0
    wlan_idx = 0
    for dev in devs:
        #print '==dev:',dev
        devname = dev['DEVICE']
        #match = r'eth(\d)'
        #res = re.findall(match,ifname)
        #if len(res) :
        if is_wire_ethernet(devname):
            dev_idx = str(eth_idx)
            eth_idx += 1
            for (k, v) in kvmap.items():
                k = re.sub('\$\{host_idx\}', host_idx, k)
                k = re.sub('\$\{dev_idx\}', dev_idx, k)
                if dev.has_key(v):
                    s = k + '=' + dev[v]
                    os.environ[k] = dev[v]
                    r.append(s)
        elif is_wifi(devname) and host_idx == '0':
            #print '==',dev
            if wlan_idx == 0:
                wlan_idx += 1
                os.environ['U_WIRELESSINTERFACE'] = devname
                os.environ['U_WIRELESSCARD_MAC'] = dev['HWADDR']
            else:
                os.environ['U_WIRELESSINTERFACE2'] = devname
                os.environ['U_WIRELESSCARD_MAC2'] = dev['HWADDR']

    return r


#------------------------------------------------------------------------------
def scan_local():
    """
    scan local network device info 
    """
    env_tbl = []
    # 1. ifconfig
    res = fetch_local('ifconfig -a')
    devs = parse_ifconfig(res)
    # 2. cat /etc/sysconfig/network-scripts/ifcfg-ethx
    wlan_idx = 0
    eth_idx = 0
    for dev in devs:
        devname = dev['DEVICE']
        if is_wire_ethernet(devname):
            cmd = 'cat /etc/sysconfig/network-scripts/ifcfg-' + devname
            res = fetch_local(cmd)
            if len(res):
                dev_info = parse_ifcfg_file(res)
                if opts['debug']: print '==', dev_info
                dev.update(dev_info)
                #elif is_wifi(devname) :
                #    #print '==',dev
                #    if wlan_idx == 0 :
                #        wlan_idx += 1
                #        os.environ['U_WIRELESSINTERFACE'] = devname
                #        os.environ['U_WIRELESSCARD_MAC'] = dev['HWADDR']
                #    else :
                #        os.environ['U_WIRELESSINTERFACE2'] = devname
                #        os.environ['U_WIRELESSCARD_MAC2'] = dev['HWADDR']
                #    #dev.update(dev_info)
                #print '=={',res
    res = save_ifconfig(devs, host_idx=0)


    #print res
    env_tbl = res
    return env_tbl

#------------------------------------------------------------------------------
def scan_remote(host, username, password):
    """
    scan remote network device information
    """
    env_tbl = []
    # 1. 
    res = fetch_remote(host, username, password, 'ifconfig -a')
    devs = parse_ifconfig(res)
    # 2. cat /etc/sysconfig/network-scripts/ifcfg-ethx
    for dev in devs:
        devname = dev['DEVICE']
        if is_wire_ethernet(devname):
            cmd = 'cat /etc/sysconfig/network-scripts/ifcfg-' + devname
            res = fetch_remote(host, username, password, cmd)
            if len(res):
                dev_info = parse_ifcfg_file(res)
                dev.update(dev_info)
    res = save_ifconfig(devs, host_idx=1)
    #print res
    env_tbl = res
    return env_tbl

#------------------------------------------------------------------------------
def scan_network_cfg(host, username, password, host_idx=0):
    """
    scan host network device information with ssh
    """
    env_tbl = []
    # 1. 
    res = fetch_remote(host, username, password, 'ifconfig -a')
    devs = parse_ifconfig(res)
    # 2. cat /etc/sysconfig/network-scripts/ifcfg-ethx
    for dev in devs:
        devname = dev['DEVICE']
        if is_wire_ethernet(devname):
            cmd = 'cat /etc/sysconfig/network-scripts/ifcfg-' + devname
            res = fetch_remote(host, username, password, cmd)
            if len(res):
                dev_info = parse_ifcfg_file(res)
                dev.update(dev_info)
    res = save_ifconfig(devs, host_idx=host_idx)
    #print res
    env_tbl = res
    return env_tbl

#------------------------------------------------------------------------------
def parse_cfgfile(fn):
    """
    parse config file and save the config
    """
    fd = open(fn, 'r')
    if not fd:
        print '==', 'can not open config file ', fn
        exit(-1)
    lines = fd.readlines()
    opts['cfgfile_lines'] = lines
    fd.close()
    for line in lines:
        if not line.startswith('#'):
            res = os.popen('echo ' + line).read()
            #print res
            match = '([^=\s]*)\s*=\s*(.*)'
            rr = re.findall(match, res)
            #print rr
            if len(rr) > 0:
                (k, v) = rr[0]
                os.environ[k] = ' '
                match = r'G_HOST_\w+\d$'
                if re.match(match, k):
                    os.environ[k] = v

#------------------------------------------------------------------------------
def sub_kv_func(m):
    """
    callback function to do replacement format 'k=v'
    """
    r = m.group(0)
    k = m.group(1)
    z = m.group(2)
    v = m.group(3)
    z = re.sub('\n', '', z)
    #print m
    if os.environ.has_key(k):
        r = k + z + os.environ[k]
        #if len(v)==0 :
        #    r += '\n'
        #print rr
    return r


def update_cfgfile(env_tbl, fn=None):
    """
    update the cfgfile and return result in file or output to stdout
    """
    if len(env_tbl) == 0:
        print "==", "env table is empty"
        return True
    newlines = []
    for line in opts['cfgfile_lines']:
        if not line.startswith('#'):
            match = '([^=\s]*)(\s*=\s*)(.*)'
            p = re.compile(match)
            line = p.sub(sub_kv_func, line)
            line += '\n'
            newlines.append(line)
        else:
            line += '\n'
            newlines.append(line)
        # save to file
    if fn:
        fd = open(fn, 'w')
        if fd:
            fd.writelines(newlines)
            fd.close()
    else:
        print '==>', 'result :'
        for line in newlines:
            print line
    return True

#------------------------------------------------------------------------------
def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("-c", "--configfile", dest="cfgfile",
                      help="The config file ")
    parser.add_option("-d", "--destination", dest="host",
                      help="wan pc ssh to")
    parser.add_option("-f", "--file", dest="file",
                      help="save config file as")
    parser.add_option("-u", "--username", dest="user",
                      help="wan pc username")
    parser.add_option("-p", "--password", dest="pswd",
                      help="wan pc password")
    #parser.add_option("-v", "--command", dest="cmd",
    #              help="command to execute")
    parser.add_option("-t", "--timeout", dest="timeout",
                      help="timout second,default is 15 seconds", type='int')
    parser.add_option("-q", "--quiet",
                      action="store_false", dest="verbose", default=True,
                      help="don't print status messages to stdout")

    (options, args) = parser.parse_args()
    #print options.filename,options.verbose

    #print dir(options)
    if not options.verbose:
        opts['debug'] = False
    if options.cfgfile:
        opts['cfgfile'] = options.cfgfile
        parse_cfgfile(options.cfgfile)
    if options.host:
        opts['host'] = options.host
        os.environ['G_HOST_IP1'] = options.host
    if options.user:
        opts['user'] = options.user
        os.environ['G_HOST_USR1'] = options.user
    if options.pswd:
        opts['pswd'] = options.pswd
        os.environ['G_HOST_PWD1'] = options.pswd
        #if options.cmd:
    #    opts['cmd'] = options.cmd
    if options.timeout:
        opts['timeout'] = options.timeout
    if options.file:
        opts['file'] = options.file


#------------------------------------------------------------------------------
opts = {
    'host': None,
    'user': 'root',
    'pswd': 'actiontec',
    'cmd': 'ip route show',
    'timeout': 15,
    'debug': True,
    'file': None,
    'cfgfile': None,
    'cfgfile_lines': None,
}


def main():
    """
    main entry
    """
    parseCommandLine()
    env_tbl = []
    #res = ssh_cmd(opts['host'],opts['user'],opts['pswd'],opts['cmd'],opts['timeout'])
    #env_tbl += scan_local()
    #env_tbl += scan_remote()
    #print '-'*32
    #print res
    #return res
    #print env_tbl

    # scan local
    if os.environ.has_key('G_HOST_USR0') and os.environ.has_key('G_HOST_PWD0'):
        if opts['debug']: print '==', 'scan local with ssh'
        tbl = [
            #'G_HOST_IP0=127.0.0.1',
            'G_HOST_USR0=' + os.environ['G_HOST_USR0'],
            'G_HOST_PWD0=' + os.environ['G_HOST_PWD0'],
        ]
        env_tbl += tbl
        env_tbl += scan_network_cfg('127.0.0.1', os.environ['G_HOST_USR0'], os.environ['G_HOST_PWD0'], host_idx=0)
    else:
        if opts['debug']: print '==', 'scan local without ssh'
        env_tbl += scan_local()
    if os.environ.has_key('G_HOST_TIP0_0_0'):
        tbl = [( 'G_HOST_IP0=' + os.environ['G_HOST_TIP0_0_0'] )]
        env_tbl += tbl
        os.environ['G_HOST_IP0'] = os.environ['G_HOST_TIP0_0_0']
        # scan remote
    if os.environ.has_key('G_HOST_IP1') and os.environ.has_key('G_HOST_USR1') and os.environ.has_key('G_HOST_PWD1'):
        tbl = [
            'G_HOST_IP1=' + os.environ['G_HOST_IP1'],
            'G_HOST_USR1=' + os.environ['G_HOST_USR1'],
            'G_HOST_PWD1=' + os.environ['G_HOST_PWD1'],
        ]
        env_tbl += tbl
        env_tbl += scan_network_cfg(os.environ['G_HOST_IP1'], os.environ['G_HOST_USR1'], os.environ['G_HOST_PWD1'],
                                    host_idx=1)
    else:
        if opts['debug']: print '==', 'can not scan remote'

    # output result
    if not opts['cfgfile']:
        opts['cfgfile_lines'] = cfg_tmpl.splitlines()
    update_cfgfile(env_tbl, opts['file'])


if __name__ == '__main__':
    main()
    exit(0)
