#!/usr/bin/python -u
import os, sys, re
import time

from pprint import pprint
from pprint import pformat
import logging
from copy import deepcopy

import signal
from optparse import OptionParser
# import subprocess,signal,select

try:
    import pexpect
except:
    print 'Please install pexpect first'
    os.system('yum install -y pexpect')
    exit(1)

# signum = int(sys.argv[1])


def txt_lines(s):
    """
    """
    m = r'\033\[[\d;]*\w'
    # zz = re.findall(m,s)
    # print zz
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
    rest_time = None

    def __init__(self, cli_prompt=None, has_color=True, mode_timeout=False):
        """
        """
        self.m_mode_timeout = mode_timeout
        print('exp timeout mode : %s' % str(mode_timeout))
        if cli_prompt:
            self.m_cli_prompts = cli_prompt
        self.m_login_prompts = ['"Press CTRL-A Z for help on special keys',
                                'Are you sure you want to continue connecting (yes/no)?', '(?i)password:', '(?i)Login:',
                                '(?i)Username:', '(?i)User name:', 'Connection refused']
        # self.m_login_prompts.append(self.m_cli_prompts)
        self.m_has_color = has_color

        # A little magic - Everything called cmdXXX is a command
        for k in dir(self):
            # print '==',k
            if k[:5] == '_cbf_':
                name = k[5:]
                method = getattr(self, k)
                self.m_hdlrs[name] = method

        return

    #------------------------------------------------------------------------------
    # remove control character from input string
    # otherwise will cause wordpress importer import failed
    # for wordpress importer, if contains contrl char, will fail to import wxr
    # eg:
    # 1. http://againinput4.blog.163.com/blog/static/172799491201110111145259/
    # content contains some invalid ascii control chars
    # 2. http://hi.baidu.com/notebookrelated/blog/item/8bd88e351d449789a71e12c2.html
    # 165th comment contains invalid control char: ETX
    # 3. http://green-waste.blog.163.com/blog/static/32677678200879111913911/
    # title contains control char:DC1, BS, DLE, DLE, DLE, DC1
    def removeCtlChr(self, inputString):
        validContent = '';
        for c in inputString:
            asciiVal = ord(c);
            validChrList = [
                9, # 9=\t=tab
                10, # 10=\n=LF=Line Feed=enter
                13, # 13=\r=CR=enter
                #                 27,
            ];
            # filter out others ASCII control character, and DEL=delete
            isValidChr = True;
            if (asciiVal == 0x7F):
                isValidChr = False;
            elif ((asciiVal < 32) and (asciiVal not in validChrList)):
                isValidChr = False;

            if (isValidChr):
                validContent += c;

        return validContent;

    def remove_colors(self):
        """
        """
        if not self.m_has_color:
            res = self.m_cmdResplist
            newres = []
            for r in res:
                m = r'\033\[[\d;]*\w'
                # rr = re.sub(m,'',r,re.M)
                # newres.append(rr)
                lines = r.splitlines()
                rr = ''
                for line in lines:
                    ll = re.sub(m, '', line)
                    rr += (ll + '\n')
                    # print re.findall(m,line)
                    # pprint('==> ' + line )
                    # print ''
                    # pprint('===> ' + ll )
                newres.append(self.removeCtlChr(rr))

            self.m_cmdResplist = newres


    def _cbf_ssh(self):
        """
        """
        if not self.m_dest_host:
            self.m_dest_host = '127.0.0.1'

        cmd = 'ssh -X -l ' + self.m_username

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

    def _cbf_scp(self):
        """
        """
        cmdlist = self.m_cmdlist
        for cmd in cmdlist:
            rc, last_error = self.__login(cmd, exp_EOF=True)

        return rc, last_error


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
            # print(exp)
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
            # print exp
            pprint('Line : ' + line)
            # print 'Line:',len(line),txt_lines(line)
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


    def __login(self, cmd, exp_EOF=False):
        """
        """

        timeout = self.m_timeout
        username = self.m_username
        password = self.m_password


        # exp.setecho(False)
        password_max_retry = 3
        password_retry = 0
        login_max_retry = 5
        login_retry = 0
        max_loops = 10

        timeout = 30

        i = 0
        rc = False
        last_error = ''
        prompts = deepcopy(self.m_login_prompts)
        prompts.append(self.m_cli_prompts)
        self.m_exp = None
        # print prompts
        while i < max_loops:
            exp = self.m_exp
            if not self.m_exp:
                self.m_exp = pexpect.spawn(cmd)
                exp = self.m_exp
                if not self.m_mute:
                    exp.logfile = sys.stdout
                    pass
                pass
            else:
                pass

            #
            i += 1
            try:
                index = exp.expect(prompts, timeout)
                # print('\n------> :::login expect index = %s\n' % str(index) )
                # print exp

                if index == 0:
                    exp.sendline('')
                elif index == 1:
                    exp.sendline('yes')
                elif index == 2:
                    if password_retry < password_max_retry:

                        password_retry += 1
                        # time.sleep(2)
                        # print '== Password prompt'
                        exp.sendline(password)
                    else:
                        print 'Retry password more than 3 times! '
                        last_error = 'Login password failed'
                        break
                elif index == 3 or index == 4 or index == 5:
                    if exp.before.find('Last') >= 0:
                        exp.sendline('')
                        continue
                    if login_retry < login_max_retry:
                        login_retry += 1
                        # time.sleep(2)
                        # print '== Password prompt'
                        exp.sendline(username)
                    else:
                        print 'Retry login more than 5 times! '
                        last_error = 'Login username failed'
                        break
                elif index == 6:
                    print('== Connection refused!')
                    last_error = 'Connection refused'
                    break
                else:
                    print('== Login success!')
                    rc = True
                    last_error = ''
                    break
            except pexpect.EOF:
                if exp_EOF:
                    rc = True
                    last_error = 'EOF'
                    break
                else:
                    print "== Login failed : EOF"
                    last_error = 'EOF'
                break
            except pexpect.TIMEOUT:
                print("== Login failed : TIMEOUT")
                exp.sendline('')
                last_error = 'TIMEOUT'
                rc = False
                exp.close()
                self.m_exp = None
                # break
                pass
            pass

        if not rc:
            print('Last error for login failed : %s' % str(last_error))
            pass

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
        if not exp:
            print('pexpect is empty!')
            return res, 'pexpect is empty'

        if not cmdlist:
            print('Command List is empty!')
            return res, ''
        for cmd in cmdlist:
            # print '\n\n'
            # print '=='*32
            # waiting for timeout
            time_start = time.time()
            r = ''
            _cmd = cmd
            m = self.m_cli_prompts

            if 'ssh' == self.m_cli_type:
                ts = time.strftime('%Y-%m-%d_%H%M%S', time.localtime(time_start))
                # keyword = '12345678901234567890123456789012345678901234567890AT_CLICMD_RCODE:'
                keyword = ts + '_AT_CLICMD_RCODE:'
                m = keyword + '(\d+)'

                cmd_added = ';echo "' + keyword + '$?"'
                _cmd = cmd + (cmd_added)

                s = cmd.strip()
                if s.endswith('&'):
                    _cmd = cmd + (' echo "' + keyword + '$?"')
                elif s.endswith(';'):
                    _cmd = cmd + (' echo "' + keyword + '$?"')
                    pass
                elif len(s) == 0:
                    _cmd = ' echo "' + keyword + '$?"'
                    pass

            exp.buffer = ''
            exp.before = ''

            print('--->CMD : %s' % _cmd)
            # exp.setecho(True)

            sl = len(_cmd)
            wr, wc = exp.getwinsize()
            wc = sl + 20
            if wc < self.m_wwsize: wc = self.m_wwsize
            exp.setwinsize(wr, wc)

            exp.sendline(_cmd)
            # exp.buffer = ''
            # print exp
            last_len = 0
            matched_prompt = False
            cmd_rc = 0
            while True:

                time_end = time.time()
                # print '-->',timeout,time_end - time_start
                if (time_end - time_start) >= float(timeout):
                    print '==', timeout, 'timeout waiting for command response!'

                    # try to check the network
                    if 'ssh' == self.m_cli_type or 'telnet' == self.m_cli_type:
                        cmd = 'nmap -sS  ' + str(self.m_dest_host)
                        os.system(cmd)
                    break
                    #
                pps = [pexpect.TIMEOUT, pexpect.EOF]
                index = exp.expect(pps, timeout=0.5)
                # print exp
                rr = exp.before

                if index == 0:
                    if len(rr) - len(_cmd) == 2:
                        last_len = len(rr)
                        # print '===> Empty response'
                        # continue
                    elif last_len < len(rr):
                        last_len = len(rr)
                        matched_prompt = False
                        # continue
                    elif last_len == len(rr):
                        r = exp.before
                        # print '===',r
                        if self.m_mode_timeout or matched_prompt:
                            print('==> No output and mode_timeout(%s) matched_prompt(%s)' % (
                            str(self.m_mode_timeout), str(matched_prompt)))
                            break
                        #
                    rf = re.findall(m, r[len(_cmd):])
                    if len(rf):
                        # print rf
                        cmd_rc = rf[0]
                        matched_prompt = True
                        if 'ssh' == self.m_cli_type:
                            r = re.sub(m, '', r)
                            break

                    continue

                elif index == 1:
                    print '==> EOF'
                    break
                    # continue

            if 'ssh' == self.m_cli_type:

                idx = r.find(cmd_added)
                r = r[:idx] + r[idx + len(cmd_added):]
                # s1 = len(cmd)
                # s2 = len(_cmd)
                # print s1,s2
                # ss1 = r[:s1]
                # ss2 = r[s2-1:]


                # r = ss1 + ss2
                # print len(r)

                # print 'r : ',r
                lines = r.splitlines()
                if len(lines):
                    lines[0] = cmd
                    # lines.append('@@last_cmd_return_code:' + str(cmd_rc))
                r = '\r\n'.join(lines)

                r += ('@@last_cmd_return_code:' + str(cmd_rc))

            # print '====> Append output : ',r
            res.append(r)

            if self.rest_time:
                print 'sleep %s sec for next command' % (self.rest_time)
                time.sleep(int(self.rest_time))
        self.m_cmdResplist = res

        self.remove_colors()
        return self.m_cmdResplist, last_error

    def run(self, cmdlist, cli_type='ssh', host='127.0.0.1', port=None, username='root', password='actiontec',
            cli_prompt=None, timeout=30, mute=False, wwsize=120, rest_time=None):
        """
        """
        # print self.m_hdlrs
        if cli_type not in self.m_hdlrs.keys():
            print ""
            return False, 'Not support cli type : ' + str(cli_type)
            #
        print('cmdlist :')
        pprint(cmdlist)

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
        self.rest_time = rest_time
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
        # d = os.path.dirname(fn)
        # fname = os.path.basename(fn)
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

    def sighandle(self, signum=0, e=0):
        """handle signal"""
        print 'i will kill myself'
        print 'receive signal: %d at %s' % (signum, str(time.ctime(time.time())))

        self.m_exp.kill(9)
        sys.exit(2)


# cmdlist = ['sh','ifconfig','route -n']
# CLI = clicmd(has_color=False)
# CLI = clicmd()
# telnet
# res,last_error = CLI.run(cmdlist,cli_type='telnet',host='192.168.0.1',username='admin',password='QwestM0dem',cli_prompt='[#$>]')

# print '\n'*3
# print '=='*32

# ssh
# cmdlist = ['ls','ifconfig','cat /var/log/messages']
# res,last_error = CLI.run(cmdlist,cli_type='ssh',host='127.0.0.1',username='root',password='actiontec',cli_prompt='[#$>]')


# scp
# cmdlist = ['scp -','ifconfig','cat /var/log/messages']
# res,last_error = CLI.run(cmdlist,cli_type='scp',host='192.168.100.16',username='root',password='actiontec')

# print 'last error :',last_error

# Save result with different methods
# CLI.saveIndexResp2file('resp001')
# CLI.saveResp2file('aaaa')
# CLI.saveResp2DirByIndex('expresp')


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
    parser.add_option("-s", "--Seperate_Output_To_Dir", dest="saveas",
                      help="Save command response by command index under specified dictory")
    parser.add_option("-r", "--Raw", dest="raw", action="store_true", default=False,
                      help="retain the console color char")


    # Login info
    parser.add_option("-d", "--Destination", dest="host", # default='127.0.0.1',
                      help="destination host to CLI (the config file extension for minicom)")
    parser.add_option("-P", "--Port", dest="port",
                      help="specified port to CLI")

    parser.add_option("-u", "--Username", dest="username", default='root',
                      help="Login username")
    parser.add_option("-p", "--Password", dest="password", default='automation',
                      help="Login password")

    parser.add_option("-m", "--proMpt", dest="prompt",
                      help="Prompt when login success")

    # commands to run
    parser.add_option("-v", "--Verb", dest="verb", action="append",
                      help="The command(s) to run")

    parser.add_option("-y", "--cli_tYpe", dest="cli_type", default='ssh',
                      help="The CLI type : ssh, telnet")

    parser.add_option("--mute", dest="mute", action="store_true", default=False,
                      help="do not print the expect output")
    parser.add_option("--timeout", dest="timeout", default=600,
                      help="Timeout each expect when do login,default is 600 seconds")

    # parser.add_option("--disable_exp_timeout",dest="exp_no_to",action="store_true",default = False,help="Check command end by timeout no output")
    parser.add_option("--window_width", dest="wwsize", default=120,
                      help="Window size of width, default is 120")
    parser.add_option("--rest_time", dest="rest_time", default=None,
                      help="time to sleep between commands")

    (options, args) = parser.parse_args()
    # output the options list
    print '==' * 32
    print 'Options :'
    excludes = ['read_file', 'read_module', 'ensure_value']
    for k in dir(options):
        if k.startswith('_') or k in excludes:
            continue
            #
        v = getattr(options, k)
        print k, ':', v
        # exit(1)
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
        # return path
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
    cli_type = 'ssh'
    host = ''
    username = ''
    password = ''
    cli_prompt = None
    rest_time = None


    #
    cmdlist = opts.verb
    # CLI = clicmd(has_color=opts.raw,mode_timeout=(not opts.exp_no_to) )
    CLI = clicmd(has_color=opts.raw)

    # signal.signal(15, CLI.sighandle)
    #
    sig_ids = [2, 4, 6, 8, 11, 15]
    # sig_ids = [n for n in range(20)]
    for sig in sig_ids:
        # print sig
        signal.signal(sig, CLI.sighandle)

    res, last_error = CLI.run(cmdlist, cli_type=opts.cli_type, host=opts.host, port=opts.port,
                              username=opts.username, password=opts.password,
                              cli_prompt=opts.prompt, mute=opts.mute, timeout=opts.timeout, rest_time=opts.rest_time)


    # print res
    print '==' * 32
    print '==Done'
    print 'Last Error :', str(last_error)

    exit_code = 0
    if last_error and len(last_error):
        exit_code = 1

    print 'Exit Code :', exit_code

    #
    print '==' * 32
    print 'Save to File ...'
    if opts.outfile:
        CLI.saveResp2file(opts.outfile)

    if opts.saveas:
        CLI.saveResp2DirByIndex(opts.saveas)

    if not opts.outfile and not opts.saveas:
        print 'No file specified!'
        # else :
        print '==' * 32
        print 'Dump Response :'
        CLI.dumpResp()

    exit(exit_code)


if __name__ == '__main__':
    """
    """

    main()


