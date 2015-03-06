#!/usr/bin/env PYTHON
#coding=utf-8

import pxssh
import getpass

"""
try:
    s = pxssh.pxssh()
    hostname = '192.168.8.2'
    username = 'root'
    password = '123qaz'
    s.login(hostname, username, password)
    s.sendline('uptime')
    s.prompt()
    print s.before
    s.sendLine('ls -l')
    s.prompt()
    print s.before
    s.sendline('df')
    s.prompt()
    print s.before
    s.logout()
    
except pxssh.ExceptionPxssh, e:
    print "pxssh failed on login."
    print str(e)
"""

try:
    s = pxssh.pxssh()
    hostname = raw_input('hostname: ')
    username = raw_input('username: ')
    password = getpass.getpass('password: ')
    s.login (hostname, username, password)
    s.sendline ('uptime') # run a command
    s.prompt() # match the prompt
    print s.before # print everything before the prompt.
    s.sendline ('ls -l')
    s.prompt()
    print s.before
    s.sendline ('df')
    s.prompt()
    print s.before
    s.logout()
except pxssh.ExceptionPxssh, e:
    print "pxssh failed on login."
    print str(e)
 
    