#!/usr/bin/env PYTHON

import pexpect
import sys

import pexpect
import sys
ip="192.168.8.2"
user="root"
passwd="123qaz"
target_file="/root/log.html"
child = pexpect.spawn('/usr/bin/ssh', [user+'@'+ip])
fout = file('mylog.txt','w')
child.logfile = fout
try:
    child.expect('(?i)password')
    child.sendline(passwd)
    child.expect('#')
    child.sendline('tar -czf /root/nginx_access.tar.gz '+target_file)
    child.expect('#')
    print child.before
    child.sendline('exit')
    fout.close()
    
except EOF:
    print "expect EOF"

except TIMEOUT:
    print "expect TIMEOUT"

child = pexpect.spawn('/usr/bin/scp', [user+'@'+ip+':/root/nginx_access.tar.gz','/root'])
fout = file('mylog.txt','a')
child.logfile = fout
try:
    child.expect('(?i)password')
    child.sendline(passwd)
    child.expect(pexpect.EOF)

except EOF:
    print "expect EOF"

except TIMEOUT:
    print "expect TIMEOUT"