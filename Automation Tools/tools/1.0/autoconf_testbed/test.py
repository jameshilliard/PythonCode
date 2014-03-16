#!/usr/bin/python

import pexpect
import sys, time, os
import re

import pxssh
import getpass


def ssh_cmd(ip, user, passwd, cmd):
    ssh = pexpect.spawn('ssh %s@%s "%s"' % (user, ip, cmd))
    #ssh.logfile = sys.stdout
    #ssh.logfile_read = sys.stdout
    r = ''
    try:
        print "==", time.time()
        i = ssh.expect(['password:', 'continue connecting(yes/no)?', pexpect.EOF, pexpect.TIMEOUT])
        print "==", time.time()
        #print '\n==',ssh.before
        if i == 0:
            ssh.sendline(passwd)
        elif i == 1:
            ssh.sendline('yes')
            #ssh.close()
        elif i == 2:
            print '==', 'EOF'
            #ssh.close()
        elif i == 3:
            print '==', 'TIMEOUT'
            #ssh.close()
    #except pexpect.EOF:
    #    print '==','EOF'
    #    ssh.close()
    #except pexpect.TIMEOUT:
    #    print '==','TIMEOUT'
    #    ssh.close()
    except Exception, e:
        print '==', e
    else:
        r = ssh.read()
        ssh.expect(pexpect.EOF)
        ssh.close()
        #ssh.interact()
    return r


now = time.strftime("%m%d%y_%I%M%S%p", time.localtime())
print now


def ssh_cli(hostname, username, password):
    try:
        s = pxssh.pxssh()
        #hostname = raw_input('hostname: ')
        #username = raw_input('username: ')
        #password = getpass.getpass('password: ')
        s.login(hostname, username, password)
        s.sendline('uptime')  # run a command
        s.prompt()             # match the prompt
        print s.before         # print everything before the prompt.
        s.sendline('ls -l')
        s.prompt()
        print s.before
        s.sendline('df')
        s.prompt()
        print s.before
        s.logout()
    except pxssh.ExceptionPxssh, e:
        print "pxssh failed on login."
        print str(e)


ssh_info = {
    'host': '192.168.100.130',
    'username': 'root',
    'password': 'actiontec',
}

#ssh_cli(ssh_info['host'],ssh_info['username'],ssh_info['password'])
#print "---"*32,'\n'
#res = ssh_cmd(ssh_info['host'],ssh_info['username'],ssh_info['password'],'echo -e "route -n\n";route -n;echo "ip route show";ip route show')
print "---" * 32, '\n'
#print res

#pipe = os.popen('ifconfig')
#print pipe.read()

s = "name  =ray"
m = r'[^=]*\s*=\s*(.*)'
s = re.sub(m, '\s*ok', s)
print s

s = """
G_HOST_IP0=192.168.10.241  
G_HOST_USR0=  a
G_HOST_PWD0= b

G_HOST_IP1=  c
G_HOST_USR1=  d
G_HOST_PWD1= e
"""
hash_cfg = {
    'name': 'ray',
    'age',
'33',
}


