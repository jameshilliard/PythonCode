#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#       check_testbed.py
#
#       Copyright 2012 rayofox <lhu@actiontec.com>
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#
#
#------------------------------------------------------------------------------

"""

Tool to check the automation test bed.


"""
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2012, Rayofox"
__version__ = "1.1"
__license__ = "MIT"
__history__ = """
Rev 1.0 : 2012/06/16
    Initial version
"""
#------------------------------------------------------------------------------
import os, sys, re
import time

from pprint import pprint
from pprint import pformat
import logging
from copy import deepcopy

from optparse import OptionParser
#import subprocess,signal,select

try:
    import pexpect
except:
    print 'Please install pexpect first'
    os.system('yum install -y pexpect')
    exit(1)


def txt_lines(s):
    """
    """
    m = r'\033\[[\d;]*\w'
    #zz = re.findall(m,s)
    #print zz
    lines = s.splitlines()
    rc = ''
    for line in lines:
        r = re.sub(m, '', line)
        rc += (r + '\n')
    return rc


class clicmd():
    """
    This class hope to implement all CLI interaction by telnet, ssh and minicom.
    scp, ftp, tftp is expected in later.
    """
    m_cli_type = 'ssh'
    m_cli_prompts = '[#$>]'
    m_login_prompts = None

    m_exp = None
    m_has_color = False
    # the repl handlers with page name
    m_hdlrs = {}

    m_dest_host = '127.0.0.1'
    m_dest_port = None
    m_username = 'root'
    m_password = 'actiontec'
    m_timeout = 60
    m_cmdlist = []
    m_cmdResplist = []
    m_mute = True

    m_mode_timeout = False
    m_wwsize = 120

    def __init__(self, cli_prompt=None, has_color=True, mode_timeout=False):
        """
        """
        self.m_mode_timeout = mode_timeout
        if cli_prompt:
            self.m_cli_prompts = cli_prompt
        self.m_login_prompts = ['"Press CTRL-A Z for help on special keys',
                                'Are you sure you want to continue connecting (yes/no)?', '(?i)password:', 'Login:',
                                'Connection refused']
        #self.m_login_prompts.append(self.m_cli_prompts)
        self.m_has_color = has_color

        # A little magic - Everything called cmdXXX is a command
        for k in dir(self):
            #print '==',k
            if k[:5] == '_cbf_':
                name = k[5:]
                method = getattr(self, k)
                self.m_hdlrs[name] = method

        return

    def remove_colors(self):
        """
        """
        if not self.m_has_color:
            res = self.m_cmdResplist
            newres = []
            for r in res:
                m = r'\033\[[\d;]*\w'
                #rr = re.sub(m,'',r,re.M)
                #newres.append(rr)
                lines = r.splitlines()
                rr = ''
                for line in lines:
                    ll = re.sub(m, '', line)
                    rr += (ll + '\n')
                    #print re.findall(m,line)
                    #pprint('==> ' + line )
                    #print ''
                    #pprint('===> ' + ll )
                newres.append(rr)

            self.m_cmdResplist = newres


    def _cbf_ssh(self):
        """
        """
        if not self.m_dest_host:
            self.m_dest_host = '127.0.0.1'

        cmd = 'ssh -l ' + self.m_username

        if self.m_dest_port:
            cmd += (' -p ' + self.m_dest_port)

        cmd += (' ' + self.m_dest_host)

        last_error = ''
        rc, last_error = self.__login(cmd)
        if rc:
            rc, last_error = self.__runcmd()
        else:
            print "== Login failed!"

        return rc, last_error

    def _cbf_telnet(self):
        """
        """
        if not self.m_dest_host:
            self.m_dest_host = '127.0.0.1'

        cmd = 'telnet ' + self.m_dest_host

        if self.m_dest_port:
            cmd += ('  ' + self.m_dest_port)

        last_error = ''
        rc, last_error = self.__login(cmd)
        if rc:
            rc, last_error = self.__runcmd()
        else:
            print "== Login failed!"

        return rc, last_error


    def _cbf_ftp(self):
        """
        """
        return

    def _cbf_tftp(self):
        """
        """
        return

    def _cbf_minicom(self):
        """
        """
        rc = False
        last_error = ''
        cfg_file = '/etc/minirc.' + self.m_dest_host
        if not os.path.exists(cfg_file):
            print '==', 'minicom config file is not exist : ', str(cfg_file)
            last_error = 'minicom config file is not exist : ' + str(cfg_file)
            return rc, last_error

        #
        cmd = 'minicom -8 -l -w -o -a off  ' + self.m_dest_host
        rc, last_error = self.__login(cmd)
        if rc:
            rc, last_error = self.__runcmd()
        else:
            print "== Login failed!"

        return rc, last_error


    def __login4minicom(self, cmd):
        """
        """
        self.m_exp = pexpect.spawn(cmd)
        self.m_exp.setecho(False)

        exp = self.m_exp
        timeout = self.m_timeout
        username = self.m_username
        password = self.m_password

        if not self.m_mute:
            exp.logfile = sys.stdout
        password_max_retry = 3
        password_retry = 0
        login_max_retry = 3
        login_retry = 0
        max_loops = 10

        timeout = 2

        i = 0
        rc = False
        last_error = ''

        retry_left = 10
        while retry_left > 0:

            print '--' * 32
            prompts = ['\n', pexpect.TIMEOUT, pexpect.EOF]
            index = exp.expect(prompts, timeout=5)
            #print(exp)
            print 'Index :', index
            if index == 0:
                pass
            elif index == 1:
                exp.sendline('\n')
                retry_left -= 1
                continue
            elif index == 2:
                retry_left -= 1
                continue
            line = exp.before
            exp.buffer = ''
            m1 = r'^Login:'
            m2 = r'^Password:'
            m3 = r'^>'
            #print exp
            pprint('Line : ' + line)
            #print 'Line:',len(line),txt_lines(line)
            r1 = re.findall(m1, line)
            r2 = re.findall(m2, line)
            r3 = re.findall(m3, line)

            if len(r1) > 0:
                # enter username
                print '==', 'Enter username'
                exp.sendline(username)
            elif len(r2) > 0:
                # enter password
                print '==', 'Enter password'
                exp.sendline(password)
            elif len(r3) > 0:
                # login success
                print '==', 'Login success!'
                rc = True
                break

        return rc, last_error


    def __login(self, cmd):
        """
        """

        self.m_exp = pexpect.spawn(cmd)
        #self.m_exp.setecho(False)

        exp = self.m_exp
        timeout = self.m_timeout
        username = self.m_username
        password = self.m_password

        if not self.m_mute:
            exp.logfile = sys.stdout
        password_max_retry = 3
        password_retry = 0
        login_max_retry = 3
        login_retry = 0
        max_loops = 10

        timeout = 5

        i = 0
        rc = False
        last_error = ''
        prompts = deepcopy(self.m_login_prompts)
        prompts.append(self.m_cli_prompts)

        #print prompts
        while i < max_loops:
            i += 1
            try:
                index = exp.expect(prompts, timeout)
                #print 'index = ',str(index)
                #print exp

                if index == 0:
                    exp.sendline('')
                elif index == 1:
                    exp.sendline('yes')
                elif index == 2:
                    if password_retry < password_max_retry:
                        password_retry += 1
                        #time.sleep(2)
                        #print '== Password prompt'
                        exp.sendline(password)
                    else:
                        print 'Retry password more than 3 times! '
                        last_error = 'Login password failed'
                        break
                elif index == 3:
                    if login_retry < login_max_retry:
                        login_retry += 1
                        #time.sleep(2)
                        print '== Password prompt'
                        exp.sendline(username)
                    else:
                        print 'Retry login more than 3 times! '
                        last_error = 'Login username failed'
                        break
                elif index == 4:
                    print '== Connection refused!'
                    last_error = 'Connection refused'
                    break
                else:
                    #print '== Login success!'
                    rc = True
                    break
            except pexpect.EOF:
                print "== Login failed : EOF"
                last_error = 'EOF'
                break
            except pexpect.TIMEOUT:
                print "== Login failed : TIMEOUT"
                exp.sendline('')
                #last_error = 'TIMEOUT'
                #break

        return rc, last_error

    def __runcmd(self):
        """
        """
        cmdlist = self.m_cmdlist
        timeout = self.m_timeout
        username = self.m_username
        password = self.m_password
        res = []
        last_error = ''
        exp = self.m_exp
        if not exp: return res, 'pexpect is empty'
        if not cmdlist: return res, ''
        for cmd in cmdlist:
            #print '\n\n'
            #print '=='*32
            # waiting for timeout 
            time_start = time.time()
            r = ''
            _cmd = cmd
            m = self.m_cli_prompts

            if 'ssh' == self.m_cli_type:
                ts = time.strftime('%Y-%m-%d_%H%M%S', time.localtime(time_start))
                #keyword = '12345678901234567890123456789012345678901234567890AT_CLICMD_RCODE:'
                keyword = ts + '_AT_CLICMD_RCODE:'
                m = keyword + '(\d+)'

                cmd_added = ';echo "' + keyword + '$?"'
                _cmd = cmd + (cmd_added)

                s = cmd.strip()
                if s.endswith('&'):
                    _cmd = cmd + (' echo "' + keyword + '$?"' )

            exp.buffer = ''
            exp.before = ''

            #print '--->CMD : ',_cmd
            #exp.setecho(True)

            sl = len(_cmd)
            wr, wc = exp.getwinsize()
            wc = sl + 20
            if wc < self.m_wwsize: wc = self.m_wwsize
            exp.setwinsize(wr, wc)

            exp.sendline(_cmd)
            #exp.buffer = ''
            #print exp
            last_len = 0
            matched_prompt = False
            cmd_rc = 0
            while True:

                time_end = time.time()
                if time_end - time_start >= timeout:
                    print '==', timeout, 'timeout waiting for command response!'
                    break
                    #
                pps = [pexpect.TIMEOUT, pexpect.EOF]
                index = exp.expect(pps, timeout=0.1)
                #print exp
                rr = exp.before

                if index == 0:
                    if len(rr) - len(_cmd) == 2:
                        last_len = len(rr)
                        #print '===> Empty response'
                        #continue
                    elif last_len < len(rr):
                        last_len = len(rr)
                        #continue
                    elif last_len == len(rr):
                        r = exp.before
                        #print '===',r
                        if self.m_mode_timeout or matched_prompt:
                            break
                        #
                    rf = re.findall(m, r[len(_cmd):])
                    if len(rf):
                    #print rf
                        cmd_rc = rf[0]
                        matched_prompt = True
                        if 'ssh' == self.m_cli_type:
                            r = re.sub(m, '', r)
                            break

                    continue

                elif index == 1:
                    print '==> EOF'
                    break
                    #continue

            if 'ssh' == self.m_cli_type:
                idx = r.find(cmd_added)
                r = r[:idx] + r[idx + len(cmd_added):]
                #s1 = len(cmd)
                #s2 = len(_cmd)
                #print s1,s2
                #ss1 = r[:s1] 
                #ss2 = r[s2-1:]


                #r = ss1 + ss2
                #print len(r)

                #print 'r : ',r
                lines = r.splitlines()
                lines[0] = cmd
                #lines.append('@@last_cmd_return_code:' + str(cmd_rc))
                r = '\r\n'.join(lines)

                r += ('@@last_cmd_return_code:' + str(cmd_rc) )

            #print '====> Append output : ',r
            res.append(r)
        self.m_cmdResplist = res

        self.remove_colors()
        return self.m_cmdResplist, last_error

    def run(self, cmdlist, cli_type='ssh', host='127.0.0.1', port=None, username='root', password='actiontec',
            cli_prompt=None, timeout=30, mute=False, wwsize=120):
        """
        """
        #print self.m_hdlrs
        if cli_type not in self.m_hdlrs.keys():
            print ""
            return False, 'Not support cli type : ' + str(cli_type)
            #
        if cli_prompt:
            self.m_cli_prompts = cli_prompt
        self.m_dest_host = host
        self.m_dest_port = port
        self.m_username = username
        self.m_password = password
        self.m_timeout = timeout
        self.m_cmdlist = cmdlist
        self.m_cmdResplist = []
        self.m_mute = mute
        self.m_cli_type = cli_type
        self.m_wwsize = wwsize
        #
        cbf = self.m_hdlrs[cli_type]
        rc, last_error = cbf()

        self.m_exp = None
        return rc, last_error

    def saveResp2file(self, fn, sep='\r\n\r\n'):
        """
        """
        if len(self.m_cmdResplist) == 0:
            print '==', 'Empty output!'
            return False

        if not fn:
            print '==', 'Illegal filename!'
            return False
            # create parent dir
        fn = os.path.abspath(fn)
        d = os.path.dirname(fn)
        fname = os.path.basename(fn)
        if not os.path.exists(d):
            os.makedirs(d)
        fd = open(fn, 'w')
        if fd:
            for resp in self.m_cmdResplist:

                fd.write(resp)
                if sep:
                    fd.write(str(sep))
            fd.close()
        else:
            print '==', 'Open file failed :', str(fn)
            return False

        return True

    def saveIndexResp2file(self, fn, idx=0):
        """
        """
        if len(self.m_cmdResplist) == 0:
            return False

        if idx >= len(self.m_cmdResplist):
            print "Index is out of range!"
            return False

        if not fn:
            return False
            # create parent dir
        fn = os.path.abspath(fn)
        d = os.path.dirname(fn)
        fname = os.path.basename(fn)
        if not os.path.exists(d):
            os.makedirs(d)
        fd = open(fn, 'w')
        if fd:
            resp = self.m_cmdResplist[idx]
            fd.write(resp)
            fd.close()
        else:
            return False

        return True

    def saveResp2DirByIndex(self, d, baseindex=0):
        """
        """
        if len(self.m_cmdResplist) == 0:
            return False

        if not d:
            return False

        d = os.path.abspath(d)
        # create parent dir
        #d = os.path.dirname(fn)
        #fname = os.path.basename(fn)
        if not os.path.exists(d):
            os.makedirs(d)

        for idx, resp in enumerate(self.m_cmdResplist):
            fn = d + '/' + str(baseindex + idx)
            fd = open(fn, 'w')
            if fd:
                fd.write(resp)
                fd.close()
        else:
            return False

        return True

    def dumpResp(self):
        """
        """
        for resp in self.m_cmdResplist:
            print '--' * 16
            print resp


# Tese bed Self Checker
class TBSC():
    """
    """
    m_check_points = []
    m_hdlrs = {}
    m_ip = '127.0.0.1'
    m_username = 'root'
    m_password = 'automation'
    m_prompt = '[#$>]'

    m_results = []

    m_perl_list = None
    m_gem_list = None

    m_ifconfig = None
    m_ifconfig_all = None
    m_iwconfig = None
    m_eth_dev = None

    m_service_status = None

    m_cmds = []

    m_debuglevel = 1
    # m_failed = 0
    def __init__(self, ip, username, password):
        """
        """
        self.m_ip = ip
        self.m_username = username
        self.m_password = password

        # A little magic - Everything called cmdXXX is a command
        for k in dir(self):
            #print '==',k
            if k[:4] == 'chk_':
                name = k[4:]
                #print '-->',name
                method = getattr(self, k)
                self.m_hdlrs[name] = method

        return

    def dump_results(self, showall=False):
        """
        """
        msg = ''
        failed = 0
        for i, (rc, checkp) in enumerate(self.m_results):
            if not 'PASSED' == rc: failed += 1
            if 'PASSED' == rc and not showall:
                #msg += ('%03d [ %s ] ===> %s \n' % (i,r) )
                #print checkp
                continue

            msg += ('%03d [ %s ] ===> %s \n' % (i + 1, rc, checkp) )

        if 0 == failed:
            msg += "ALL PASSED !"
        return msg

    def add_result(self, checkp, rc, res=None):
        """
        """

        msg = "[ %s ] ==> %s" % (rc.strip(), str(checkp).strip() )
        self.m_results.append((rc.strip(), checkp.strip() ))
        print msg
        if self.m_debuglevel > 1:
            if res:
                print res
                print '\n' * 2
        elif self.m_debuglevel > 0 and 'FAILED' == rc:
            if res:
                print res
                print '\n' * 2

        return True


    def run_cmd(self, cmd):
        """
        """
        #cmd = re.sub('"','\\"',cmd)
        #mycmd = 'clicmd --mute -d %s -u %s -p %s -v \"%s\"' % (self.m_ip,self.m_username,self.m_password,cmd)
        #print 'to run cmd :',mycmd
        #resp = os.popen(mycmd).read()
        # # Check ssh result
        #m = r'Exit Code : (\d*)'
        #res = re.findall(m,resp)
        #if len(res) :
        #    exit_code = res[0]
        #    if exit_code.strip() == '0' :
        #        #return resp
        #        pass
        #    else :
        #        print '---------------------'
        #        print 'SSH ' + self.m_ip + ' failed! Checking terminated!'
        #        print '---------------------'
        #        print resp
        #        exit(1)
        #
        #dd = resp.split('Exit Code : 0')
        #if len(dd) == 2 :
        #    return dd[1]
        #else :
        #    return resp
        #print len(dd),dd
        #return resp

        cmds = []
        cmds.append(cmd)
        CLI = clicmd(has_color=False)
        res, last_error = CLI.run(cmds, cli_type='ssh', host=self.m_ip, username=self.m_username,
                                  password=self.m_password, cli_prompt=self.m_prompt, mute=True)

        exit_code = 0
        if last_error and len(last_error):
            print '==>', 'SSH failed'
            exit(1)

        return res[0]


    def run_cmds(self, cmds):
        """
        """

        CLI = clicmd(has_color=False)
        res, last_error = CLI.run(cmds, cli_type='ssh', host=self.m_ip, username=self.m_username,
                                  password=self.m_password, cli_prompt=self.m_prompt, mute=True)

        exit_code = 0
        if last_error and len(last_error):
            print '==>', 'SSH failed'
            exit(1)

        return res


    def chk_bin(self, checkpoint):
        """
        """
        #print '--check bin :',checkpoint
        cps = checkpoint.split()
        cmds = []
        for cp in cps:
            cmd = 'whereis ' + cp
            cmds.append(cmd)
        print '\n' * 2
        print '------> Binary Check :', checkpoint
        resp = self.run_cmds(cmds)
        for i, cp in enumerate(cps):

            # Check command result
            m = cp + ':(.*)'
            res = re.findall(m, resp[i])
            if len(res):
                path = res[0]
                if len(path) > 0:
                    self.add_result('Check Binary(' + cp + ') ', ' PASSED')
                else:
                    self.add_result('Check Binary(' + cp + ')', ' FAILED', resp[i])

        return True

    def chk_perl(self, checkpoint):
        """
        """

        # Get perl packages list
        if not self.m_perl_list:
            cmd = """perl -e 'print "@INC " ' | sed 's/ /\\n/g' | grep perl | xargs -i find {} -name '*.pm'"""
            self.m_perl_list = self.run_cmd(cmd)
        print '\n' * 2
        print '------> Perl Package Check :', checkpoint
        cps = checkpoint.split()

        for cp in cps:


            # Check command result
            m = cp
            if not m.endswith('.pm'):
                m = cp + '\.pm'
            res = re.findall(m, self.m_perl_list)
            #print '==',res
            if len(res):
                self.add_result('Check Perl Package(' + cp + ') ', ' PASSED')
            else:
                self.add_result('Check Perl Package(' + cp + ') ', ' FAILED')
        return True

    def chk_python(self, checkpoint):
        """
        """
        cps = checkpoint.split()
        cmds = []
        for cp in cps:
            #print '------> Python Package Check :',cp
            cmd = 'python -c "import %s"' % (cp)
            cmds.append(cmd)

        print '\n' * 2
        print '------> Python Check :', checkpoint
        resp = self.run_cmds(cmds)
        for i, cp in enumerate(cps):
            #print resp
            m = 'ImportError'
            res = re.findall(m, resp[i])
            if len(res) > 0:
                self.add_result('Check Python Package(' + cp + ') ', ' FAILED')
            else:
                self.add_result('Check Python Package(' + cp + ') ', ' PASSED')
        return True

    def chk_gem(self, checkpoint):
        """
        """
        #
        if not self.m_gem_list:
            cmd = 'gem list'
            self.m_gem_list = self.run_cmd(cmd)
            #print '-- gem list : ',self.m_gem_list
        #
        cps = checkpoint.split()

        print '\n' * 2
        print '------> Ruby Gem Check :', checkpoint

        for cp in cps:
            m = cp
            res = re.findall(m, self.m_gem_list)
            if len(res) > 0:
                self.add_result('Check Ruby Gem(' + cp + ') ', ' PASSED')
            else:
                self.add_result('Check Ruby Gem(' + cp + ') ', ' FAILED')
        return True

    def chk_eth(self, checkpoint):
        """
        """
        print '\n' * 2
        print '------> NICs Check :', checkpoint

        if not self.m_eth_dev:
            cmd = 'lspci | grep Ethernet'
            self.m_eth_dev = self.run_cmd(cmd)

        m = 'Ethernet controller:'
        res = re.findall(m, self.m_eth_dev)
        #print self.m_eth_dev
        #print res
        eth_num = len(res)
        #print 'Number of PCI Ethernet :',eth_num

        if not self.m_ifconfig:
            cmd = 'ifconfig'
            self.m_ifconfig = self.run_cmd(cmd)

        if not self.m_ifconfig_all:
            cmd = 'ifconfig -a'
            self.m_ifconfig_all = self.run_cmd(cmd)

        m = r'(\w*)\*(\d*)'
        res = re.findall(m, checkpoint)
        #print res
        if 0 == len(res):
            self.add_result('Check Ethernet Device(' + checkpoint + ') ', ' UNKNOWN')
            return False

        # 
        ctype, num = res[0]
        ctype = ctype.lower()
        if 'any' == ctype:
            num = int(num)
            if eth_num >= num:
                self.add_result('Check Ethernet Device(' + checkpoint + ') ', ' PASSED')
            else:
                self.add_result('Check Ethernet Device(' + checkpoint + ') ', ' FAILED')
        elif 'up' == ctype:
            pass

        return True

    def chk_wifi(self, checkpoint):
        """
        """
        print '\n' * 2
        print '------> WIFI Check :', checkpoint

        if not self.m_iwconfig:
            cmd = 'iwconfig'
            self.m_iwconfig = self.run_cmd(cmd)
        m = 'ESSID:'
        res = re.findall(m, self.m_iwconfig)
        #print self.m_eth_dev
        #print res
        wifi_num = len(res)
        print 'Number of Wireless Device :', wifi_num

        m = r'(\w*)\*(\d*)'
        res = re.findall(m, checkpoint)
        #print res
        if 0 == len(res):
            self.add_result('Check Wireless Device(' + checkpoint + ') ', ' UNKNOWN')
            return False

        # 
        ctype, num = res[0]
        ctype = ctype.lower()
        if 'any' == ctype:
            num = int(num)
            if wifi_num >= num:
                self.add_result('Check Wireless Device(' + checkpoint + ') ', ' PASSED')
            else:
                self.add_result('Check Wireless Device(' + checkpoint + ') ', ' FAILED')
        elif 'up' == ctype:
            pass

        return True

    def prepare_service_status(self):
        """
        """
        if not self.m_service_status:
            cmd = 'service --status-all | grep -B3 "Active:"'
            self.m_service_status = self.run_cmd(cmd)

            rr = self.m_service_status.split('--')
            #for i,r in enumerate(rr) :
            self.m_service_status = rr
        return True

    def get_service_status(self, r, sname):
        """
        """
        status = 'found'
        m = r'unrecognized service'
        res = re.findall(m, r)
        if len(res):
            status = 'NA'
        else:
        # error or loaded
            m = 'Loaded:\s*(\w*).*'
            res = re.findall(m, r)
            if len(res):
                s = res[0]
                status = s

                if s == 'loaded':
                    m = 'Active:\s*(\w*)\s*'
                    res = re.findall(m, r)
                    if len(res):
                        status = res[0]

        print 'service', sname, ':', status
        return status

    def chk_service_enabled(self, checkpoint):
        """
        """
        print '\n' * 2
        print '------> Service Enabled Check :', checkpoint
        cps = checkpoint.split()

        cmds = []
        for cp in cps:
            cmd = 'service ' + cp + ' status'
            cmds.append(cmd)
        resp = self.run_cmds(cmds)
        for i, cp in enumerate(cps):

            status = self.get_service_status(resp[i], cp)
            if status in ['found', 'active', 'loaded']:
                self.add_result('Check Service Enabled(' + cp + ') ', ' PASSED')
            else:
                self.add_result('Check Service Enabled(' + cp + ') ', ' FAILED', resp[i])
        return True

    def chk_service_disabled(self, checkpoint):
        """
        """
        print '\n' * 2
        print '------> Service Disabled Check :', checkpoint

        cps = checkpoint.split()

        cmds = []
        for cp in cps:
            cmd = 'service ' + cp + ' status'
            cmds.append(cmd)
        resp = self.run_cmds(cmds)
        for i, cp in enumerate(cps):

            status = self.get_service_status(resp[i], cp)

            if 'inactive' == status:
                self.add_result('Check Service Disabled(' + cp + ') ', ' PASSED')
            else:
                self.add_result('Check Service Disabled(' + cp + ') ', ' FAILED')
        return True

    def chk_service_not_enabled(self, checkpoint):
        """
        """
        print '\n' * 2
        print '------> Service Not Enabled Check :', checkpoint

        cps = checkpoint.split()

        cmds = []
        for cp in cps:
            cmd = 'service ' + cp + ' status'
            cmds.append(cmd)
        resp = self.run_cmds(cmds)
        for i, cp in enumerate(cps):

            status = self.get_service_status(resp[i], cp)

            if 'inactive' == status or 'NA' == status or 'error' == status:
                self.add_result('Check Service NOT Enabled(' + cp + ') ', ' PASSED')
            else:
                self.add_result('Check Service NOT Enabled(' + cp + ') ', ' FAILED')

        return True

    def chk_cmd(self, checkpoint):
        """
        """
        print '\n' * 2
        print '------> Command Check :', checkpoint

        cmd = checkpoint + '; echo AT_CODE : $?'
        resp = self.run_cmd(cmd)
        #print resp
        m = r'AT_CODE\s*:\s*(\d*)'
        res = re.findall(m, resp)
        #print res
        if len(res):
            ecode = (res[-1])
            #print '--<',ecode
            if '0' == ecode:
                self.add_result('Check Command True(' + checkpoint + ') ', ' PASSED')
            else:
                self.add_result('Check Command True(' + checkpoint + ') ', ' FAILED')
        return True

    def chk_cmdN(self, checkpoint):
        """
        """
        print '\n' * 2
        print '------> Command Negtive Check :', checkpoint

        cmd = checkpoint + '; echo AT_CODE : $?'
        resp = self.run_cmd(cmd)
        m = r'AT_CODE\s*:\s*(\d*)'
        res = re.findall(m, resp)
        #print res
        if len(res):
            ecode = (res[-1])
            #print '--<',ecode
            if '0' == ecode:
                self.add_result('Check Command False(' + checkpoint + ') ', ' FAILED')
            else:
                self.add_result('Check Command False(' + checkpoint + ') ', ' PASSED')

        return True

    def chk_listen_port(self, checkpoint):
        """
        """
        print '\n' * 2
        print '\n' * 2
        print '------> Listen Port Check :', checkpoint

        cps = checkpoint.split(' ')
        for cp in cps:
            if 0 == len(cp.strip()):
                continue
            print '------> Listen Port Check :', cp
            cmd = ''
            if 'tcp' == cp.lower():
                cmd = 'netstat -ltnp'
            elif 'udp' == cp.lower():
                cmd = 'netstat -lunp'
            resp = self.run_cmd(cmd)
            print resp

        return True


    def load(self, fn):
        """
        """
        if not os.path.exists(fn):
            print '==', 'File is not exist!'
            return False

        fd = open(fn)
        lines = []
        if fd:
            lines = fd.readlines()
            fd.close()

        #

        for line in lines:
            s = line.strip()
            if len(s) and not s.startswith('#'):
                self.m_check_points.append(s)

        #
        # print self.m_check_points
        return True


    def do_check(self):
        """
        """
        #
        if 0 == len(self.m_check_points):
            print 'No any check point specified!'
            return True

        for cp in self.m_check_points:
            m = r'^-(\S*)\s*(.*)'
            res = re.findall(m, cp)
            if len(res):
                key, params = res[0]
                if self.m_hdlrs.has_key(key):
                    cbf = self.m_hdlrs[key]
                    rc = cbf(params)
                else:
                    self.add_result('Not support check point : ' + cp, 'UNKOWN')
            else:
                self.add_result('Not support check point : ' + cp, 'UNKOWN')


    def pull_check_points(self, z):
        """
        """
        self.m_check_points += z


#------------------------------------------------------------------------------

def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: [options]\n"
    usage += ('\nGet detail introduction and sample usange with command : pydoc ' + os.path.abspath(__file__) + '\n\n')

    parser = OptionParser(usage=usage)
    # save response 
    parser.add_option("-o", "--Output_file", dest="outfile",
                      help="output the command(s) response to file")
    # Login info
    parser.add_option("-d", "--Destination", dest="host", default='127.0.0.1',
                      help="destination host to CLI (the config file extension for minicom)")
    parser.add_option("-u", "--Username", dest="username", default='root',
                      help="Login username")
    parser.add_option("-p", "--Password", dest="password", default='automation',
                      help="Login password")

    parser.add_option("-c", "--check_cfg", dest="chkcfg",
                      help="config file for check point")

    # commands to run
    parser.add_option("-v", "--check_point", dest="cps", action="append",
                      help="The check point(s) to run")
    parser.add_option("--all", dest="showall", default=False, action="store_true",
                      help="Show all results including PASSED ")

    (options, args) = parser.parse_args()

    print '==' * 32
    print 'Options :'
    excludes = ['read_file', 'read_module', 'ensure_value']
    for k in dir(options):
        if k.startswith('_') or k in excludes:
            continue
            #
        v = getattr(options, k)
        print k, v
        #exit(1)
    print '==' * 32
    print ''
    return args, options
    #------------------------------------------------------------------------------


def exportCurrentPath():
    """
    """
    import os, sys

    path = sys.path[0]
    if os.path.isdir(path):
        #return path
        pass
    elif os.path.isfile(path):
        path = os.path.dirname(path)

    print '==add path :', path
    sys.path.append(path)


def main():
    """
    main entry
    """
    args, opts = parseCommandLine()
    # check args
    #if not opts.chkcfg :
    #print '==',''
    #print '==','Please specify the config file for check point with -c!'
    #exit(1)
    checker = TBSC(opts.host, opts.username, opts.password)

    rc = True
    if opts.chkcfg:
        rc = checker.load(opts.chkcfg)

    if opts.cps:
        checker.pull_check_points(opts.cps)
    if rc:
        checker.do_check()

    print '\r' * 3
    print '==' * 16
    print 'Check Results : '
    res = checker.dump_results(opts.showall)
    print res
    # save to file
    if opts.outfile:
        fd = open(opts.outfile, 'w')
        if fd:
            fd.write(res)
            fd.close()
        else:
            print '--', 'Can not save to file :', opts.outfile
            exit(1)
    exit(0)


if __name__ == '__main__':
    """
    """
    main()
    
    




