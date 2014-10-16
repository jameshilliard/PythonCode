#!/usr/bin/python -u
# -*- coding: utf-8 -*-
#
#       sshcli.py
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
This is an useful utility for ssh command
"""
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2012, Rayofox"
__version__ = "0.1"
__license__ = "MIT"
__history__ = """
Rev 0.1 : 2012/12/03
    Initial version
"""
#------------------------------------------------------------------------------
from types import *
import sys, time, os
import re
from optparse import OptionParser
from optparse import OptionGroup
import logging
from pprint import pprint
from pprint import pformat
import xml.etree.ElementTree as etree
import subprocess, signal, select
from copy import deepcopy
import syslog
import traceback
import pexpect
import random
from datetime import datetime



class SSH_CLI() :
    """
    """
    _has_password_prompt = True
    _ssh_ip = '127.0.0.1'
    _ssh_port = 22
    _ssh_username='root'
    _ssh_password='123qaz'
    _ssh_login_timeout=30
    _ssh_cmd_timeout=120
    _logger = None
    _loghdlr = None
    def __init__(self,ssh_ip='127.0.0.1',ssh_port=22,ssh_username='',ssh_password='',ssh_login_timeout=30,ssh_cmd_timeout=120,logpath=None) :
        """
        """
        self._ssh_ip            = ssh_ip
        self._ssh_port          = ssh_port
        self._ssh_username      = ssh_username
        self._ssh_password      = ssh_password
        self._ssh_login_timeout = ssh_login_timeout
        self._ssh_cmd_timeout   = ssh_cmd_timeout
        self.prepare_log(logpath)

    def prepare_log(self,path) :
        """
        prepare the log
        """

        if not self._logger :
            self._logger = logging.getLogger('SSHCLI.SYS')
            hdr = logging.StreamHandler(sys.stdout)
            self._logger.addHandler(hdr)

        if not path or not os.path.exists(path) :
            #self._logfile = None

            return
        #path = '/root'
        logfile = os.path.join(path,'sshcli.log')
        #
        #print '--> setup log :',logfile


        if self._loghdlr :
            self._logger.removeHandler(self._loghdlr)
            self._loghdlr.close()
            self._loghdlr = None

        #

        self._loghdlr = logging.FileHandler(logfile)
        self._logger.addHandler(self._loghdlr)
        self._logger.setLevel(11)

    def info(self,msg) :
        """
        log info
        """

        if self._logger :
            self._logger.info(msg)
            #print '--> log : ',msg


    def error(self,msg) :
        """
        log error
        """

        if self._logger :
            self._logger.error(msg)


    def run(self,cmd,set_login_without_pwd=True,mute=True) :
        """
        """
        return self.runCmdList([cmd],set_login_without_pwd=set_login_without_pwd,mute=mute)

    def runCmdList(self,cmds,set_login_without_pwd=True,mute=True) :
        """
        """
        try :
            _cmd = 'ssh %s -p %d -l %s "'%(self._ssh_ip,self._ssh_port,self._ssh_username)
            strNow = datetime.now().strftime('%Y%m%d_%H%M%S')
            for idx,cmd in enumerate(cmds) :
                _cmd += '%s;echo RCODE_%s_%03d=$?;'%(cmd,strNow,idx+1)
            #
            _cmd += '"'

            login_timeout = self._ssh_login_timeout
            cmd_timeout   = self._ssh_cmd_timeout
            if 0==len(cmds):
                cmd_timeout = 2

            rc,output = self.__expect_run(_cmd,login_timeout=login_timeout,cmd_timeout=cmd_timeout,mute=mute)

            if not rc :
                return rc,output

            idx = 0
            sp = 'RCODE_%s_(\d*)=(\d*)'%strNow
            res = re.split(sp,output,re.M)
            #print(len(res))
            #pprint(res)

            resp = []
            if len(res) == 3*len(cmds)+1 :
                for idx,cmd in enumerate(cmds) :
                    #print('---> idx = %d'%idx)
                    cmd_output = res[idx*3]
                    cmd_idx = res[idx*3+1]
                    cmd_rc = res[idx*3+2]

                    resp.append((cmd_rc,cmd_output))

            #pprint(resp)
            if set_login_without_pwd and self._has_password_prompt :
                print('try to setup_login_without_password')
                self.setup_login_without_password()
            else :
                print('already login_without_password')
                pass

            return rc,resp
        except Exception,e :
            formatted_lines = traceback.format_exc().splitlines()
            return False, str(e)


    def scp(self,src,dest,recursion=True):
        """
        """
        cmd = 'scp -r -P %d %s %s@%s:%s '%(self._ssh_port,src,self._ssh_username,self._ssh_ip,dest)
        return self.__expect_run(cmd,cmd_timeout=-1,mute=False)

    def setup_login_without_password(self):
        """
        """
        rc = False
        fn = '/root/.ssh/id_rsa.pub'
        fn = os.path.abspath(fn)
        if not os.path.exists(fn) :
            print('File is not exist : %s'%fn)
            self.__create_rsa_pub_file()
        else :
            pass

        # append public key to server
        content = ''
        fd = open(fn,'r+')
        if fd :
            content = fd.read()
            fd.close()
        cmd = 'ssh %s -p %d " echo "%s" >>  /root/.ssh/authorized_keys"'%(self._ssh_ip,self._ssh_port,content)
        self.__expect_run(cmd)
        if self._has_password_prompt :
            return False
        else :
            return True


    def __create_rsa_pub_file(self) :
        """
        """
        cmd = 'ssh-keygen -t rsa'
        #
        prompts = [pexpect.TIMEOUT,pexpect.EOF]
        prompts.append(r'Enter file in which to save the key (/root/.ssh/id_rsa):')
        prompts.append(r'Overwrite (y/n)?')
        prompts.append(r'Enter passphrase (empty for no passphrase):')
        prompts.append(r'Enter same passphrase again:')
        timeout = 2
        rc = False
        output = ''
        exp = pexpect.spawn(cmd)
        exp.logfile = sys.stdout
        exp.buffer = ''
        exp.before = ''
        while 1 :
            index = exp.expect(prompts,timeout=timeout)
            print('------->%d'%index)
            if 0 == index : #timeout
                print('-- timeout')
                #print(exp)
                #break
                exp.sendline('')
            elif 1 == index : #EOF
                print('-- EOF')
                rc = True
                output = exp.before
                break
            elif 2 == index : #
                exp.sendline('YES')
            elif 3 == index : #
                exp.sendline('y')
            elif 4 == index :
                exp.sendline('')
            elif 5 == index :
                exp.sendline('')
            else :
                break

    def __expect_run(self,cmd,login_timeout=30,cmd_timeout=120,mute=True) :
        """
        """

        prompts = [pexpect.TIMEOUT,pexpect.EOF]
        prompts.append('Are you sure you want to continue connecting (yes/no)?')
        prompts.append("'s password:")
        prompts.append("Permission denied (publickey,password).")

        #print('--> Run cmd : %s'%cmd)
        exp = pexpect.spawn(cmd)
        if not mute :
            exp.logfile = sys.stdout
        exp.buffer = ''
        exp.before = ''

        #print '--->CMD : ',_cmd
        #exp.setecho(True)


        sl = len(cmd)
        wr,wc = exp.getwinsize()
        wc = sl + 20
        if wc < 120  : wc = 120
        exp.setwinsize(wr,wc)

        timeout = login_timeout
        rc = False
        output = ''
        self._has_password_prompt = False
        while 1 :
            index = exp.expect(prompts,timeout=timeout)
            #print('--->Index : %d'%index)
            if 0 == index : #timeout
                print('-- timeout')
                break
            elif 1 == index : #EOF
                print('-- EOF')
                exit_code = exp.exitstatus
                if not exit_code :
                    rc = True
                    output = exp.before
                    break
                else :
                    rc = False
                    output = exp.before
                    print(exp)
                    break
            elif 2 == index : # input yes
                exp.sendline('yes')
            elif 3 == index : # input password
                timeout = cmd_timeout
                exp.sendline(self._ssh_password)
                self._has_password_prompt = True
            elif 4 == index : # password invalid
                print('-- Wrong password')
                self._has_password_prompt = True
                break
            #elif 5 == index :
            #    pass
            else :
                break
        exp.close()
        if not rc :
            output = exp.exitstatus
        print('rc,output : %s,%s' % (rc,output) )

        return rc,output

    def dumpResp(self,cmdlist,resp) :
        """
        """
        msgfmt = 'resp = [%s]\n'

        contents = ''
        for idx,cmd in enumerate(cmdlist) :
            (cmd_rc,cmd_output) = resp[idx]
            if 0 == len(contents) : contents += '\n'
            content = '("%s",%s,"%s"),' % (cmd,cmd_rc,cmd_output)
            contents += (content + '\n')

        msg = msgfmt%contents


        return msg



#cli = SSH_CLI()
#cmds = ['ifconfig | grep "eth"','route -n','okok','ls abcdddef']

#rc,resp = cli.runCmdList(cmds)
#for idx,cmd in enumerate(cmds) :
#    (cmd_rc,cmd_output) = resp[idx]
#    print('--'*16)
#    print('cmd         : %s'%cmd)
#    print('cmd_rc      : %s'%cmd_rc)
#    print('cmd_output  : \n%s'%cmd_output)


def sshcmd(ssh_ip,ssh_port,ssh_username,ssh_password,cmdlist,mute=False) :
    """
    """
    rc = False
    resp = []
    try :
        CLI = SSH_CLI(ssh_ip=ssh_ip,ssh_port=ssh_port,ssh_username=ssh_username,ssh_password=ssh_password)
        rc,resp = CLI.runCmdList(cmdlist,mute=mute)
    except Exception,e :
        rc = False
        resp = str(e)
    return rc,resp

def scp(ssh_ip,ssh_port,ssh_username,ssh_password,src,dest,mute=False) :
    """
    """
    rc = False
    resp = []
    try :
        CLI = SSH_CLI(ssh_ip=ssh_ip,ssh_port=ssh_port,ssh_username=ssh_username,ssh_password=ssh_password)
        rc,resp = CLI.scp(src,dest,mute=mute)
    except Exception,e :
        rc = False
        resp = str(e)
    return rc,resp



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
    parser.add_option("-s", "--Seperate_Output_To_Dir", dest="saveas",
                            help="Save command response by command index under specified dictory")
    parser.add_option("-r", "--Raw", dest="raw",action="store_true",default=False,
                            help="retain the console color char")


    # Login info
    parser.add_option("-d", "--Destination", dest="host",default='127.0.0.1',
                            help="destination host to CLI (the config file extension for minicom)")
    parser.add_option("-P", "--Port", dest="port",default=22,
                            help="specified port to CLI")

    parser.add_option("-u", "--Username", dest="username",default='root',
                            help="Login username")
    parser.add_option("-p", "--Password", dest="password",default='123qaz',
                            help="Login password")

    parser.add_option("-S", "--scp_src", dest="scp_src",
                                help="scp source file or dirctory")
    parser.add_option("-D", "--scp_dest", dest="scp_dest",
                                    help="scp dest file or dirctory")


    #parser.add_option("-m", "--proMpt", dest="prompt",
    #                        help="Prompt when login success")

    # commands to run
    parser.add_option("-v", "--Verb", dest="verb", action="append",
                            help="The command(s) to run")


    #parser.add_option("-y", "--cli_tYpe", dest="cli_type",default = 'ssh',
    #                        help="The CLI type : ssh, telnet")

    parser.add_option("--mute", dest="mute",action="store_true",default = False,
                            help="do not print the expect output")
    parser.add_option("--timeout",dest="timeout",default = 600,
                            help="Timeout each expect when do login,default is 600 seconds")
    parser.add_option("--window_width",dest="wwsize",default = 120,
                            help="Window size of width, default is 120")


    (options, args) = parser.parse_args()
    # output the options list
    print '=='*32
    print 'Options :'
    excludes = ['read_file','read_module','ensure_value']
    for k in dir(options) :
        if k.startswith('_') or k in excludes:
            continue
        #
        v = getattr(options,k)
        print k,':',v
    #exit(1)
    print '=='*32
    print ''
    return args, options
 #------------------------------------------------------------------------------

def exportCurrentPath() :
    """
    """
    import os, sys

    path = sys.path[0]
    if os.path.isdir(path):
        #return path
        pass
    elif os.path.isfile(path):
        path = os.path.dirname(path)

    print '==add path :' , path
    sys.path.append(path)

def main() :
    """
    main entry
    """
    args, opts = parseCommandLine()
    # check args
    cli_type = 'ssh'
    host = ''
    username = ''
    password = ''
    cli_prompt = None



    #

    mute = opts.mute
    cmdlist = opts.verb

    rc = False
    resp = []

    if not cmdlist :
        cmdlist = []
    CLI = SSH_CLI(ssh_ip=opts.host,ssh_port=opts.port,ssh_username=opts.username,ssh_password=opts.password,ssh_cmd_timeout=opts.timeout)
    if opts.scp_src :
        src = opts.scp_src
        dst = src
        if opts.scp_dest :
            dst = opts.scp_dest
        rc,resp = CLI.scp(src,dst,mute=mute)
        print '=='*32
        print '==Done'

    else :

        rc,resp = CLI.runCmdList(cmdlist,mute=mute)

        #print res
        print '=='*32
        print '==Done'
        #print 'Last Error :',str(last_error)
        # dump results
        if rc :
            print(CLI.dumpResp(cmdlist,resp))
            #for idx,cmd in enumerate(cmdlist) :
            #    (cmd_rc,cmd_output) = resp[idx]
            #    print('--'*16)
            #    print('cmd         : %s'%cmd)
            #    print('cmd_rc      : %s'%cmd_rc)
            #    print('cmd_output  : \n%s'%cmd_output)

    if rc :
        exit_code = 0
    else :
        exit_code = 1
    print 'Exit Code :',exit_code
    exit(exit_code)





if __name__ == '__main__':
    """
    """

    main()