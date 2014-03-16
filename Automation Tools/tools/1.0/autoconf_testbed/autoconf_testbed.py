#!/usr/bin/python 
"""

This tool can auto configuration test bed network device.

The config file is the format which created by autoscan_testbed.py

1. The /etc/sysconfig/network-scripts/ifcfg-ethx will update
2. The /etc/resolv.conf will update
3. The service network will restart


you can setup testbed :
python -u autoconf_testbed.py -c cfgfile

get usage :
python -u autoconf_testbed.py -h
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
from sshcmd import is_valid_ipv4
#------------------------------------------------------------------------------
env_list = []

ifcfg_cmd = ''
#------------------------------------------------------------------------------
def fetch_local(cmd):
    """
    execute local command and return result
    """
    pipe = os.popen(cmd)
    return pipe.read()

#------------------------------------------------------------------------------
def fetch_remote(host, username, password, cmd):
    """
    ssh to remote host and execute command and return result
    """
    res = ssh_cmd(host, username, password, cmd, timeout=opts['timeout'], debug=opts['debug'])
    #print '==',res
    return res

#------------------------------------------------------------------------------
def fetch_wanpc(cmd, timeout=None):
    """
    ssh to remote wan pc and execute command and return result
    """
    if not timeout: timeout = opts['timeout']
    debug = opts['debug']
    return ssh_cmd(os.environ['G_HOST_IP1'], os.environ['G_HOST_USR1'], os.environ['G_HOST_PWD1'], cmd, timeout=timeout,
                   debug=debug)

#------------------------------------------------------------------------------
def parse_cfgfile(fn):
    """
    parse config file created by autoscan_testbed.py
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
                os.environ[k] = v
                env_list.append(k)


def mk_ifcfg_file(host_idx=0, dev_idx=1):
    """
    create config file for network device
    """
    # 1. parse
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
        'USERCTL': 'yes',
        'PREFIX': '',
        'DEFROUT': 'no',
        'NOZEROCONF': 'yes',
    }
    global ifcfg_cmd
    # 
    if dev_idx == 0:
        print '==', 'Warning:', 'Attempt to setup management network device'
    host_idx = str(host_idx)
    dev_idx = str(dev_idx)
    ifcfg_ethx = {}
    ifcfg_ethx.update(ifcfg_tmpl)
    # 
    postfix = host_idx + '_' + dev_idx + '_0'
    postfix2 = host_idx + '_' + dev_idx + '_1'
    if os.environ.has_key('G_HOST_TIP' + postfix):

        ifcfg_ethx['DEVICE'] = os.getenv('G_HOST_IF' + postfix)
        ifcfg_ethx['HWADDR'] = os.getenv('G_HOST_MAC' + postfix)
        ifcfg_ethx['IPADDR'] = os.getenv('G_HOST_TIP' + postfix)
        ifcfg_ethx['NETMASK'] = os.getenv('G_HOST_TMASK' + postfix)
        ifcfg_ethx['GATEWAY'] = os.getenv('G_HOST_GW' + postfix)
        ifcfg_ethx['DNS1'] = os.getenv('G_HOST_DNS' + postfix)
        ifcfg_ethx['DNS2'] = os.getenv('G_HOST_DNS' + postfix2)
        # combine ifconfig command
        cmd = 'ifconfig ' + ifcfg_ethx['DEVICE'] + ' ' + ifcfg_ethx['IPADDR'] + ' netmask ' + ifcfg_ethx[
            'NETMASK'] + ';'
        ifcfg_cmd += cmd
        # calc prefix 
        ip = ifcfg_ethx['IPADDR']
        mask = ifcfg_ethx['NETMASK']
        if len(ip) and len(mask):
            cmd = 'ipcalc -p ' + ip + ' ' + mask
            #print cmd
            resp = os.popen(cmd).read()
            print resp
            match = r'PREFIX=(\d+)'
            res = re.findall(match, resp)
            if len(res):
                val = res[0]
                #print '==val:',val
                ifcfg_ethx['PREFIX'] = val
        if opts['debug']:
            print '==>', 'ifcfg-' + ifcfg_ethx['DEVICE']
            for (k, v) in ifcfg_ethx.items(): print k, ' = ', v
        # return
    return ifcfg_ethx

#------------------------------------------------------------------------------
def save_ifcfg_file(hash_cfg, local=True):
    """
    save the network device config file ifcfg-ethx to /ect/sysconfig/network-scripts/
    """
    if not is_valid_ipv4(hash_cfg['IPADDR']) or not len(hash_cfg['DEVICE']):
        if opts['debug']: print '==', 'IPADDR and DEVICE invalid'
        return False
    content = ''
    for (k, v) in hash_cfg.items():
        if not v: v = ''
        s = k + '=' + v
        content += (s + '\n')

    fname = 'ifcfg-' + hash_cfg['DEVICE']
    fname = '/etc/sysconfig/network-scripts/' + fname
    cmd = 'echo "' + content + '" > ' + fname
    print '==>', cmd
    if local:
        fetch_local(cmd)
    else:
        #fetch_remote(os.environ['G_HOST_IP1'],os.environ['G_HOST_USR1'],os.environ['G_HOST_PWD1'],cmd)
        fetch_wanpc(cmd)

#------------------------------------------------------------------------------
def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("-c", "--configfile", dest="cfgfile",
                      help="The config file to setup")
    parser.add_option("-t", "--timeout", dest="timeout",
                      help="timout second,default is 15 seconds", type='int')
    parser.add_option("-q", "--quiet",
                      action="store_false", dest="verbose", default=True,
                      help="don't print status messages to stdout")

    (options, args) = parser.parse_args()
    #print options.filename,options.verbose

    #print dir(options)
    if options.cfgfile:
        opts['cfgfile'] = options.cfgfile
        parse_cfgfile(options.cfgfile)
    else:
        print '==', '-c is required'
        parser.print_help()
        exit(-1)
    if options.timeout:
        opts['timeout'] = options.timeout
    if not options.verbose:
        opts['debug'] = False

#------------------------------------------------------------------------------
opts = {
    'timeout': 15,
    'debug': True,
    'file': None,
    'cfgfile': None,
}


def main():
    """
    main entry
    """
    parseCommandLine()
    # make setup command 
    # restart network
    ifcfg_cmd = ''
    cmd_restart_network = '/etc/init.d/network restart'
    # reset dns
    cmd_setup_dns = ''
    if os.environ.has_key('G_HOST_DNS0'):
        dns = os.environ['G_HOST_DNS0']
        cmd_setup_dns += ('echo "nameserver ' + dns + '" > /etc/resolv.conf;' )
    if os.environ.has_key('G_HOST_DNS1'):
        dns = os.environ['G_HOST_DNS1']
        cmd_setup_dns += ('echo "nameserver ' + dns + '" >> /etc/resolv.conf;' )

    # local    
    hash_cfg = mk_ifcfg_file(0, 1)
    save_ifcfg_file(hash_cfg)
    hash_cfg = mk_ifcfg_file(0, 2)
    save_ifcfg_file(hash_cfg)
    # effective immediately
    if opts['debug']: print '==', 'restart local network service'
    fetch_local(cmd_restart_network)
    # setup dns
    #if len(cmd_setup_dns) :
    #    fetch_local(cmd_setup_dns)
    if len(ifcfg_cmd):
        fetch_local(ifcfg_cmd)
        # remote
    ifcfg_cmd = ''
    host = os.getenv('G_HOST_IP1')
    user = os.getenv('G_HOST_USR1')
    pswd = os.getenv('G_HOST_PWD1')
    if not host or not user or not pswd:
        print '==', 'no remote'
        return
    else:
    # 'try ssh to remote '
        fetch_remote('whoami', 15)
    hash_cfg = mk_ifcfg_file(1, 1)
    save_ifcfg_file(hash_cfg, local=False)
    hash_cfg = mk_ifcfg_file(1, 2)
    save_ifcfg_file(hash_cfg, local=False)
    # effective immediately
    if opts['debug']: print '==', 'restart remote network service'
    fetch_wanpc(cmd_restart_network)
    #fetch_remote(os.environ['G_HOST_IP1'],os.environ['G_HOST_USR1'],os.environ['G_HOST_PWD1'],cmd_restart_network)
    # setup dns
    #if len(cmd_setup_dns) :
    #    fetch_remote(cmd_setup_dns)
    if len(ifcfg_cmd):
        fetch_local(ifcfg_cmd)


if __name__ == '__main__':
    main()
    exit(0)
