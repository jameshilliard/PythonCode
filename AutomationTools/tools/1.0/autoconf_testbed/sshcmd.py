#!/usr/bin/python 
"""
This tool is execute command after ssh to remote 
python -u sshcmd.py -d 192.168.100.130 -u root -p actiontec -v "ifconfig -a;route -n"
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
import pexpect
import sys, time, os
import re

from optparse import OptionParser

#------------------------------------------------------------------------------
def is_valid_ipv4(ip):
    """Validates IPv4 addresses.
    """
    pattern = re.compile(r"""
        ^
        (?:
          # Dotted variants:
          (?:
            # Decimal 1-255 (no leading 0's)
            [3-9]\d?|2(?:5[0-5]|[0-4]?\d)?|1\d{0,2}
          |
            0x0*[0-9a-f]{1,2}  # Hexadecimal 0x0 - 0xFF (possible leading 0's)
          |
            0+[1-3]?[0-7]{0,2} # Octal 0 - 0377 (possible leading 0's)
          )
          (?:                  # Repeat 0-3 times, separated by a dot
            \.
            (?:
              [3-9]\d?|2(?:5[0-5]|[0-4]?\d)?|1\d{0,2}
            |
              0x0*[0-9a-f]{1,2}
            |
              0+[1-3]?[0-7]{0,2}
            )
          ){0,3}
        |
          0x0*[0-9a-f]{1,8}    # Hexadecimal notation, 0x0 - 0xffffffff
        |
          0+[0-3]?[0-7]{0,10}  # Octal notation, 0 - 037777777777
        |
          # Decimal notation, 1-4294967295:
          429496729[0-5]|42949672[0-8]\d|4294967[01]\d\d|429496[0-6]\d{3}|
          42949[0-5]\d{4}|4294[0-8]\d{5}|429[0-3]\d{6}|42[0-8]\d{7}|
          4[01]\d{8}|[1-3]\d{0,9}|[4-9]\d{0,8}
        )
        $
    """, re.VERBOSE | re.IGNORECASE)
    return pattern.match(ip) is not None


#------------------------------------------------------------------------------
def ssh_cmd(ip, user, passwd, cmd, timeout=15, debug=True):
    """
    """
    #ssh.logfile = sys.stdout
    #ssh.logfile_read = sys.stdout
    ssh = pexpect.spawn('ssh %s@%s ' % (user, ip), timeout=timeout)
    login = False
    r = ''
    try:
        #ssh = pexpect.spawn('ssh %s@%s "%s"' % (user,ip,cmd))
        #print "==",time.time()
        i = ssh.expect(['password:',
                        'continue connecting(yes/no)?',
                        'Permission denied, please try again.',
                        pexpect.EOF,
                        pexpect.TIMEOUT])
        #print "==",time.time()
        if debug: print '==>', ssh.before
        if i == 0:
            ssh.sendline(passwd)
        elif i == 1:
            ssh.sendline('yes')
            #ssh.close()
        elif i == 2:
            if debug: print '==', 'bad password'
            ssh.close()
            exit(-1)
        elif i == 3:
            if debug: print '==', 'EOF'
            exit(-1)
            #ssh.close()
        elif i == 4:
            if debug: print '==', 'TIMEOUT'
            exit(-1)
            #ssh.close()
    except pexpect.EOF:
        print '==', 'EOF'
        ssh.close()
    except pexpect.TIMEOUT:
        if debug: print '==', 'TIMEOUT'
        ssh.close()
    except Exception, e:
        if debug: print '==', e
        # check login
    i = ssh.expect([r'\[.*\]\s*#', pexpect.EOF, pexpect.TIMEOUT]);
    if debug: print '==>', ssh.before
    if i == 0:
        if debug: print '==', 'login in'
        login = True
    elif i == 1:
        if debug: print '==', 'EOF'
        exit(-1)
    elif i == 2:
        if debug: print '==', 'TIMEOUT'
        exit(-1)
        #
    if login:
        cmds = cmd.split(';')
        for c in cmds:
            #ssh.sendline('echo ""')
            ssh.sendline(c)
            if debug: print '==', c
            #r = ssh.before
            ssh.expect(['\[.*\]\s*#'])
            r += '\n'
            r += ssh.before
            #r = ssh.read()
        #ssh.expect(pexpect.EOF)
        ssh.close()
        #ssh.interact()
    return r

#------------------------------------------------------------------------------
def parseCommandLine():
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("-d", "--destination", dest="host",
                      help="destination ssh to,default is 127.0.0.1")
    parser.add_option("-u", "--username", dest="user",
                      help="destination username")
    parser.add_option("-p", "--password", dest="pswd",
                      help="destination password")
    parser.add_option("-v", "--command", dest="cmd",
                      help="command to execute")
    parser.add_option("-t", "--timeout", dest="timeout",
                      help="timout second,default is 15 seconds", type='int')
    parser.add_option("-q", "--quiet",
                      action="store_false", dest="verbose", default=True,
                      help="don't print status messages to stdout")

    (options, args) = parser.parse_args()
    #print options.filename,options.verbose

    #print dir(options)
    if options.host:
        opts['host'] = options.host
    if options.user:
        opts['user'] = options.user
    if options.pswd:
        opts['pswd'] = options.pswd
    if options.cmd:
        opts['cmd'] = options.cmd
    if options.timeout:
        opts['timeout'] = options.timeout
    if not options.verbose:
        opts['debug'] = False
        #print '==','debug is ',opts['debug']

#------------------------------------------------------------------------------

opts = {
    'host': '127.0.0.1',
    'user': 'root',
    'pswd': 'actiontec',
    'cmd': 'ip route show',
    'timeout': 15,
    'debug': True,
}


def main():
    parseCommandLine()
    res = ssh_cmd(opts['host'], opts['user'], opts['pswd'], opts['cmd'], timeout=opts['timeout'], debug=opts['debug'])
    if opts['debug']: print '-' * 32
    print res
    return res


if __name__ == '__main__':
    main()
