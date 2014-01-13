#!/usr/bin/python -u
# -*- coding: utf-8 -*-
"""
Check reboot

1. retry ping destination during a period time
2. each retry send ping request count 10 , and interval 0.1 , total 1 second
3. expected 3 stages :
    a. ping success before do rebooting
    b. ping failed in rebooting
    c. ping success after rebooting done


"""

import os
import sys
import time
import re
import ctypes
from pprint import pprint
from pprint import pformat
import logging
from copy import deepcopy

import signal
from optparse import OptionParser
import subprocess, signal, select
import rfx_util


required_bin = {
    'iperf': 'traffic test',
    'tshark': 'packet capturing',
    'wpa_supplicant': 'wireless connection',
    'minicom': 'Serial port',
    'wine': 'UPnP test',
    #'wget' : '',
    'dhclient': '',
    'ping': '',
    'ipcalc': '',
    #'traceroute' : '',
    #'expect' : '',
    'curl': '',
    'nmap': '',
    'ntpdate': '',
    'pptpsetup': '',
    'pppd': '',
    'screen': '',
}


def waiting_input(prompt='', timeout=10):
    if len(prompt):
        sys.stdout.write(prompt + '   ')
        sys.stdout.flush()
    to = 1
    i = timeout
    while i > 0:
        rd = select.select([sys.stdin], [], [], to)[0]
        if not rd:

            sys.stdout.write('\b' * 3)
            sys.stdout.write('%03d' % (i + 1))
            sys.stdout.flush()
        else:
            return raw_input()
        i -= 1


def subproc(cmd, timeout=3600, mute=True):
    """
    subprogress to run command
    """
    rc = None
    output = ''
    #
    print('subproc : ' + cmd)
    if not mute: print('timout : ' + str(timeout))
    try:
        #
        p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True,
                             shell=True)
        pi, po, pe = p.stdin, p.stdout, p.stderr
        while_begin = time.time()
        while True:
            to = 600
            fs = select.select([p.stdout, p.stderr], [], [], to)
            #if p.poll() : break
            #print '==>',fs
            if p.stdout in fs[0]:
                #print '---xxx'
                tmp = p.stdout.readline()
                if tmp:
                    output += tmp
                    print(tmp)
                    #if not mute : print(tmp)
                else:
                    #print '---end'
                    #print time.time()
                    while None == p.poll(): pass
                    break
            elif p.stderr in fs[0]:
                #print "!!!!!!!!!!!!!!!"
                tmp = p.stderr.readline()
                if tmp:
                    output += tmp
                    #plogger.error(tmp)
                else:
                    #print 'end'
                    #print time.time()
                    while None == p.poll(): pass
                    break
            else:
                #print 'Timeout'
                #os.system('ps -f')
                s = os.popen('ps -f| grep -v grep |grep sleep').read()

                if len(s.strip()):
                    print('No output in sleep : ' + s)
                    continue

                print('Timeout ' + str(to) + ' seconds without any output!')
                print(os.popen('ps -p ' + str(p.pid)).read())
                p.kill()

                #os.kill(p.pid, signal.SIGKILL)
                break
                #timeout = timeout - (time.time() - while_begin)
            # Check the total timeout
            dur = time.time() - while_begin
            if dur > timeout:
                print('The subprocess is timeout more than ' + str(timeout))
                break
            # return
        rc = p.poll()
        # close all fds
        p.stdin.close()
        p.stdout.close()
        p.stderr.close()
        #print('return value : ' + str(rc))

    except Exception, e:
        print('Exception : ' + str(e))
        #rc = False
    return rc, output


def check_local_bin():
    """
    """
    for rbin in required_bin:
        cmd = 'which ' + rbin
        print('==BIN CHECK : %s' % rbin)
        rc = os.system(cmd)
        if str(rc) == '0':
            print('PASS', 'LAN PC BIN CHECK : %s' % rbin)
        else:
            #print 'FAILED','LAN PC BIN CHECK : ',rbin
            sys.stderr.write('AT_ERROR : %s %s \n' % ('LAN PC BIN CHECK : ', rbin))
            exit(1)


def check_rpc_bin(host, username, password):
    """
    """
    for rbin in required_bin:
        cmd = 'which ' + rbin
        print('==Remote PC BIN CHECK : %s' % rbin)
        r1, r2, resp = ssh_cmd(cmd, host, username, password, False)
        if str(r1) == '0':
            if not str(r2) == '0':
                print '\n\n\n'
                print '----------------'
                #print resp
                print '----------------'
                #print 'FAILED','REMOTE PC ' + host + ' BIN CHECK : ',rbin
                sys.stderr.write('AT_ERROR : %s %s \n' % ('REMOTE PC ' + host + ' BIN CHECK : ', rbin))
                exit(1)
        else:
            #print 'FAILED :','ssh REMOTE PC ' + host + ' failed during BIN CHECK'
            sys.stderr.write('AT_ERROR : %s %s \n' % ('ssh REMOTE PC ' + host + ' failed during BIN CHECK'))
            exit(1)


def check_rpc_ready(inf, rpcname):
    """
    """

    # 1. parse the information
    print '\n\n==', 'Parse the ' + rpcname + ' information...'
    z = inf.split(':')
    print z
    if 0 == len(z):
        print 'WARNING :', rpcname, 'is not ready, All test suites need 3PC SHOULD be commented!'
        return False
    else:
        host = z[0]
        if 0 == len(host):
            print 'WARNING :', rpcname, 'is not ready, All test suites need 3PC SHOULD be commented!'
            return False

    if not len(z) == 3:
        msg = 'Illegal ' + rpcname + ' information format , SHOULD be : IP:USERNAME:PASSWORD' + '\n'
        msg += ('If you DO NOT use this PC, make all of them empty!' + '\n')
        sys.stderr.write(msg)
        exit(1)
    [host, username, password] = z

    if 0 == len(host) or 0 == len(username) or 0 == len(password):
        msg = 'Illegal ' + rpcname + ' information format , SHOULD be : IP:USERNAME:PASSWORD' + '\n'
        msg += ('If you DO NOT use this PC, make all of them empty!' + '\n')
        sys.stderr.write(msg)
        exit(1)
    print '==[PASS]', 'Parse the ' + rpcname + ' information : ', host, username, password


    # 2. check the wan pc is reachable
    print '\n\n==', 'Check ' + rpcname + ' is reachable and SSH ready'
    cmd = 'killall -9 ping;killall -9 tshark'
    r1, r2, resp = ssh_cmd(cmd, host, username, password)
    if not str(r1) == '0':
        print '\n\n\n'
        #print '----------------'
        #print r1,r2
        #print '----------------'
        #print 'FAILED :','Check ' + rpcname + ' is reachable and SSH ready'
        sys.stderr.write('AT_ERROR : %s \n' % ('Check ' + rpcname + ' is reachable and SSH ready'))
        exit(1)

    # 3. check 3 NICs are all linked

    print '\n\n==', 'Check ' + rpcname + ' 3 NICs are all linked'
    cmd = "mii-tool | grep 'no link'"
    r1, r2, resp = ssh_cmd(cmd, host, username, password)
    if str(r2) == '0':
        print '\n\n\n'
        #print '----------------'
        #print r1,r2,resp
        #print '----------------'
        #print 'FAILED :','Check ' + rpcname + ' 3 NICs are all linked :\n',resp
        sys.stderr.write('AT_ERROR : %s %s \n' % ('Check ' + rpcname + ' 3 NICs are all linked :\n', str(resp) ))
        exit(1)

    print 'PASSED :', 'Check ' + rpcname + ' 3 NICs are all linked :\n'


    #
    print '\n\n==', 'Check ' + rpcname + ' 3 NICs names'
    cmd = 'ifconfig -a'
    r1, r2, resp = ssh_cmd(cmd, host, username, password)
    if str(r2) == '0':

        print '\n\n\n'
        nic_names = []
        eth0 = os.getenv('G_HOST_IF2_0_0', None)
        eth1 = os.getenv('G_HOST_IF2_1_0', None)
        eth2 = os.getenv('G_HOST_IF2_2_0', None)

        if rpcname == 'WAN PC':
            eth0 = os.getenv('G_HOST_IF1_0_0', None)
            eth1 = os.getenv('G_HOST_IF1_1_0', None)
            eth2 = os.getenv('G_HOST_IF1_2_0', None)

            nic_names.append('G_HOST_IF1_0_0')
            #nic_names.append('G_HOST_IF1_1_0')
            nic_names.append('G_HOST_IF1_2_0')
            pass
        else:
            nic_names.append('G_HOST_IF2_0_0')
            nic_names.append('G_HOST_IF2_1_0')
            nic_names.append('G_HOST_IF2_2_0')
            pass

        if not eth0 or not eth1 or not eth2:
            sys.stderr.write('AT_ERROR : %s %s \n' % ('Check ' + rpcname + ' NICs names failed : ',
                                                      'Some required parameters not defined in %s' % (str(nic_names))))
            exit(1)
            pass
        for eth in nic_names:
            en = os.getenv(eth, None)
            if resp.find(en + ' ') < 0 and resp.find(en + ':') < 0:
                sys.stderr.write('AT_ERROR : %s %s \n' % (
                'Check ' + rpcname + ' NICs names failed : ', 'Not found NIC name %s defined by %s' % (en, eth) ))
                exit(1)
                pass
            pass

        #
        lines = resp.splitlines()

        idx = 0

        while (idx < len(lines) ):
            line = ''
            line = lines[idx]
            idx += 1
            if line.startswith(eth0 + ' '):
                next_line = lines[idx]
                if next_line.find(host) < 0:
                    sys.stderr.write('AT_ERROR : %s %s \n' % ('Check ' + rpcname + ' NICs names failed : ',
                                                              'MGR interface(%s) not match to IP(%s)' % (eth0, host) ))
                    exit(1)
                    pass
                else:
                    break
                pass
            else:
                pass







                #sys.stderr.write('AT_ERROR : %s %s \n' % ('Check ' + rpcname + ' 3 NICs are all linked :\n',str(resp) ) )
                #exit(1)

    print 'PASSED :', 'Check ' + rpcname + ' 3 NICs names \n'

    cmd = cmdclearAppBG()
    ssh_cmd(cmd, host, username, password)

    return [host, username, password]


def relaunch_nfs_bk(host, username, password, lanpc, rpcname):
    """
    """
    work_dir = '/root/automation/tools/2.0/START_SERVERS'
    # 3. relaunch the nfs client
    print '\n\n==', 'Relaunch the nfs client in ' + rpcname
    cmd = 'ls ' + work_dir
    r1, r2, resp = ssh_cmd(cmd, host, username, password)
    if str(r1) == '0':
        if str(r2) == '0':
            print '==', 'nfs client is ready, No need to relaunch'
        else:
            cmd = 'mount -v -t nfs -o nolock,nfsvers=3,proto=tcp,port=2049 ' + lanpc + ':/root/automation /root/automation'
            r1, r2, resp = ssh_cmd(cmd, host, username, password)
            print resp
            if str(r1) == '0':
                if not str(r2) == '0':
                    print '\n\n\n'
                    print '----------------'
                    print resp
                    print '----------------'
                    #print 'FAILED :','Relaunch the nfs client'
                    sys.stderr.write('AT_ERROR : %s  \n' % ('Relaunch the nfs client'))
                    exit(1)
            else:
                #print 'FAILED :','ssh ' + rpcname + ' failed'
                sys.stderr.write('AT_ERROR : %s \n' % ('ssh ' + rpcname + ' failed'))
                exit(1)
    else:
        #print 'FAILED :','ssh ' + rpcname + ' failed'
        sys.stderr.write('AT_ERROR : %s \n' % ('ssh ' + rpcname + ' failed'))
        exit(1)

    return True


def relaunch_nfs(host, username, password, lanpc, rpcname):
    """
    """
    work_dir = '/root/automation/tools/2.0/START_SERVERS'
    # relaunch the nfs client
    print '\n\n==', 'Relaunch the nfs client in ' + rpcname

    cmd = 'umount -l /root/automation; mount -v -t nfs -o nolock,nfsvers=3,proto=tcp,port=2049 ' + lanpc + ':/root/automation /root/automation'
    r1, r2, resp = ssh_cmd(cmd, host, username, password)
    if str(r1) == '0':
        if str(r2) == '0':
            print '==', 'PASS : nfs client relaunch done!'
            return True
        else:
            #print 'FAILED :','Relaunch the nfs client'
            sys.stderr.write('AT_ERROR : %s \n' % ('Relaunch the nfs client'))
            exit(1)
    else:
        #print 'FAILED :','ssh ' + rpcname + ' failed'
        sys.stderr.write('AT_ERROR : %s \n' % ('ssh ' + rpcname + ' failed'))
        exit(1)

    return True


def cmdclearAppBG():
    """
    """
    cmd = ''
    cmd += 'killall ping;'
    cmd += 'killall dhclient;'
    cmd += 'killall tshark;'
    cmd += 'killall tcpdump;'
    cmd += 'killall iperf;'
    cmd += 'killall nmap;'
    cmd += 'wpa_cli terminate'

    return cmd


def check_lanpc(ipaddr):
    """
    """
    print '======', 'check LAN PC', ipaddr

    nic_names = []
    nic_names.append('G_HOST_IF0_0_0')
    nic_names.append('G_HOST_IF0_1_0')
    nic_names.append('G_HOST_IF0_2_0')
    for nic in nic_names:
        ifname = os.getenv(nic, None)
        if not ifname:
            sys.stderr.write('AT_ERROR : %s \n' % ('Not found required parameter : %s' % nic))
            exit(1)
            pass
        else:
            cmd = 'ifconfig %s' % ifname
            res = os.system(cmd)
            if res == 0:
                pass
            else:
                sys.stderr.write('AT_ERROR : %s \n' % ('Not found NIC(%s) : %s' % (nic, ifname) ))
                exit(1)
                pass
            if nic == 'G_HOST_IF0_0_0':
                cmd = 'ifconfig %s | grep "%s"' % (ifname, ipaddr)
                res = os.system(cmd)
                if res == 0:
                    pass
                else:
                    sys.stderr.write('AT_ERROR : %s \n' % (
                    'Bad MGR NIC(%s:%s) match to IP(%s:%s)' % (nic, ifname, 'G_HOST_IP0', ipaddr) ))
                    exit(1)
                    pass

    print '======', 'setup LAN PC', ipaddr

    check_local_bin()
    pass


def setup_lanpc(ipaddr, ip_wanpc):
    """
    """
    print '--' * 32


    # 0. some other cleanup
    cmd = cmdclearAppBG()
    os.system(cmd)
    # only for LAN PC
    os.system('service iptables stop')
    os.system('clear_iptables.sh')

    os_ver = os.popen('uname -r').read()
    print '\n\n==', 'OS version : ', os_ver
    # 1. diable lanpc iptables
    print '==', 'Disable iptables'
    os.system('service iptables stop')

    # 2. restart lanpc nfs
    print '\n\n==', 'Restart NFS server'
    rule = '/root/automation ' + ipaddr + '/24(rw,sync,no_wdelay,no_subtree_check,fsid=0,no_root_squash)'
    os.system('echo "' + rule + '" > /etc/exports')
    if os_ver > '3.0':
        os.system('service nfs-server restart')
    else:
        os.system('service nfs restart')
        #print '==','check '

    # 3. sync ntp
    print '\n\n==', 'Sync NTP from WAN PC'

    # try stop local ntpd first
    os.system('service ntpd stop')

    return True


def ssh_cmd(cmd, host, username, password, mute=True):
    """
    """
    #mute = False
    o_file = '/tmp/ssh_cmd_ret.log'
    os.popen('rm -rf ' + o_file)
    cmd = ('"' + cmd + '"')
    cmd2 = 'clicmd '
    if mute:
        cmd2 += '--mute '
    cmd2 += '-d ' + host + ' -u ' + username + ' -p ' + password + ' -v ' + cmd + ' -o  ' + o_file + '; echo CLICMD_RET : $?'
    rc, res = subproc(cmd2, mute=mute)
    resp = ''
    if os.path.exists(o_file):
        fd = open(o_file, 'r')
        if fd:
            resp = fd.read()
            fd.close()

    #print
    # r1 : clicmd return means ssh success/failed ; r2 : return value of cmd to run in remote host
    m1 = r'CLICMD_RET\s*:\s*(\d*)'
    m2 = r'@@last_cmd_return_code\s*:\s*(\d*)'
    z1 = re.findall(m1, res)
    z2 = re.findall(m2, resp)
    r1 = None
    r2 = None
    if len(z1): r1 = str(z1[0]).strip()
    if len(z2): r2 = str(z2[0]).strip()

    print '-->', r1, r2

    return r1, r2, resp


def setup_wanpc(host, username, password, lanip):
    """
    """
    #
    #check_rpc_bin(host,username,password)
    # 1. relauch NFS
    work_dir = '/root/automation/tools/2.0/START_SERVERS'
    relaunch_nfs(host, username, password, lanip, 'WAN PC')

    # 2. Start WAN PC Services
    print '\n\n==', 'Start WAN PC Services'
    wan_cfg = '/root/automation/tools/2.0/START_SERVERS/config_net.conf'
    if not os.path.exists(wan_cfg):
        #print 'FAILED :','Start WAN PC Services'
        #print 'Please make sure the config file for WAN PC is ready :',wan_cfg
        sys.stderr.write('AT_ERROR : %s\n%s %s \n' % (
        'Start WAN PC Services', 'Please make sure the config file for WAN PC is ready :', wan_cfg))
        exit(1)
    else:
        print 'Please double check the config file for WAN PC in ', wan_cfg
        #waiting_input('Press anykey to continue... ',10)

    #return
    # to
    cmd = 'cd /root/automation/tools/2.0/START_SERVERS/ ; ./config_net.sh'
    r1, r2, resp = ssh_cmd(cmd, host, username, password, False)
    print '---->(%s) (%s)' % (r1, r2)
    if str(r1) == '0':
        if not str(r2) == '0':
            print '\n\n\n'
            print '----------------'
            #print resp
            print '----------------'
            #print 'FAILED :','Start WAN PC Services'
            sys.stderr.write('AT_ERROR : %s \n' % ('Start WAN PC Services'))
            exit(1)
        else:
            print 'PASS :', 'Start WAN PC Services'
            #exit(1)
    else:
        #print 'FAILED :','ssh WAN PC failed during starting WAN PC Service'
        sys.stderr.write('AT_ERROR : %s \n' % ('ssh WAN PC failed during starting WAN PC Service'))
        exit(1)


    # 3. Check Motive Server is reachable
    wan = 'xatechdm.xdev.motive.com'
    cmd = 'ping ' + wan + ' -c 5 -W 60 '
    print '\n\n==', 'Ensure WAN PC can visit Internet : ' + wan
    r1, r2, resp = ssh_cmd(cmd, host, username, password, False)
    if str(r1) == '0':
        if not str(r2) == '0':
            print '\n\n\n'
            print '----------------'
            #print resp
            print '----------------'
            #print 'FAILED :','Ensure WAN PC can visit Internet : ' + wan
            sys.stderr.write('AT_ERROR : %s \n' % ('Ensure WAN PC can visit Internet : ' + wan))
            exit(1)
    else:
        #print 'FAILED :','ssh WAN PC failed during ensuring WAN PC can visit Motive Server'
        sys.stderr.write('AT_ERROR : %s \n' % ('ssh WAN PC failed during ensuring WAN PC can visit Motive Server'))
        exit(1)

    return True


def setup_lanpc2(host, username, password, lanip, ip_wanpc):
    """
    """

    #check_rpc_bin(host,username,password)
    #work_dir = '/root/automation/tools/2.0/START_SERVERS'
    relaunch_nfs(host, username, password, lanip, 'LAN PC 2')

    # sync NTP
    print '\n\n==', 'Sync NTP from WAN PC'
    # try stop local ntpd first
    os.system('service ntpd stop')

    cmd = 'ntpdate ' + ip_wanpc
    r1, r2, resp = ssh_cmd(cmd, host, username, password, False)
    if str(r1) == '0':
        if not str(r2) == '0':
            print '\n\n\n'
            print '----------------'
            #print resp
            print '----------------'
            #print 'FAILED :','Sync NTP from WAN PC : ' + ip_wanpc
            sys.stderr.write('AT_ERROR : %s \n' % ('Sync NTP from WAN PC : ' + ip_wanpc))
            exit(1)
    else:
        #print 'FAILED :','ssh WAN PC failed during Sync NTP from WAN PC'
        sys.stderr.write('AT_ERROR : %s \n' % ('ssh WAN PC failed during Sync NTP from WAN PC'))
        exit(1)

    return True


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: tb_ready.py LAN_PC_MGR_IP WAN_PC_MGR_IP:USERNAME:PASSWORD [LAN_PC2_MGR_IP:USERNAME:PASSWORD] [OPTIONS]\n"
    usage += ('\nGet detail introduction and sample usange with command : pydoc ' + os.path.abspath(__file__) )

    parser = OptionParser(usage=usage)
    # save response
    parser.add_option("-o", "--output", dest="outfile",
                      help="output the command(s) response to file")
    parser.add_option("-m", "--mask", dest="mask",
                      help="subnet mask ,default is 255.255.255.0")
    (options, args) = parser.parse_args()
    # output the options list
    print '==' * 32
    print 'Args :'
    print args
    print '==' * 32
    print 'Options :'
    excludes = ['read_file', 'read_module', 'ensure_value']
    for k in dir(options):
        if k.startswith('_') or k in excludes:
            continue
            #
        v = getattr(options, k)
        print k, ':', v
        #exit(1)
    print '==' * 32
    print ''

    # check args
    if len(args) < 2:
        #print 'The arguments MUST more than 3!'
        sys.stderr.write('AT_ERROR : %s \n' % ('The arguments MUST more than 2!'))
        parser.print_help()
        exit(1)

    return args, options


def main():
    """
    """

    args, opts = parseCommandLine()

    logging.basicConfig(format='%(levelname)-8s : %(message)s')

    ip_lanpc = args[0]
    inf_wanpc = args[1]
    inf_lanpc2 = "::"
    if len(args) > 2:
        inf_lanpc2 = args[2]
        pass

    check_lanpc(ip_lanpc)

    # 1. check WAN PC is ready

    wan_pc_inf = check_rpc_ready(inf_wanpc, 'WAN PC')
    [ip_wanpc, username, password] = wan_pc_inf

    nmask = '255.255.255.0'
    if opts.mask:
        nmask = opts.mask
    if not rfx_util.is_in_same_subnet(ip_lanpc, ip_wanpc, '255.255.255.0'):
        #print 'FALIED :','LAN PC and WAN PC are not in the same subnetwork for Management'
        sys.stderr.write('AT_ERROR : %s \n' % ('LAN PC and WAN PC are not in the same subnetwork for Management'))
        exit(1)

    # Check lan pc 2 ready [optional]
    lan_pc2_inf = check_rpc_ready(inf_lanpc2, 'LAN PC 2')

    setup_lanpc(ip_lanpc, ip_wanpc)
    #return
    #

    [ip_wanpc, username, password] = wan_pc_inf
    setup_wanpc(ip_wanpc, username, password, ip_lanpc)

    #
    if lan_pc2_inf:
        [ip_lanpc2, username, password] = lan_pc2_inf
        setup_lanpc2(ip_lanpc2, username, password, ip_lanpc, ip_wanpc)

    # local setup after WAN PC ready
    cmd = 'ntpdate ' + ip_wanpc
    r = os.system(cmd)
    if str(r) == '0':
        print 'PASSED :', 'Sync NTP from WAN PC'
    else:
        #print 'FAILED :','Sync NTP from WAN PC'
        sys.stderr.write('AT_ERROR : %s \n' % ('Sync NTP from WAN PC'))
        exit(1)

    print '\n\n'
    print '==' * 16
    print '==PASS', 'LAN PC ready'
    print '==PASS', 'WAN PC ready'
    if lan_pc2_inf:
        print '==PASS', 'LAN PC 2 ready'
    else:
        print '==PASS', 'LAN PC 2 is not in used'

    exit(0)


if __name__ == '__main__':
    """
    """

    main()
