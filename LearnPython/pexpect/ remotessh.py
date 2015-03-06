#!/usr/bin/env PYTHON
#coding=utf-8

import pexpect
import sys

child = pexpect.spawn('ssh root@192.168.8.2')
#fout = file('mylog.txt', 'w')
#child.logfile = fout
child.logfile = sys.stdout
child.expect("password:")
child.sendline("123qaz")
print "before:" + child.before
print "after:" + child.after
child.expect("#")
child.sendline('ls /root/')
child.expect('#')
print "\nend"