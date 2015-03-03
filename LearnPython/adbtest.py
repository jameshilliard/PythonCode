#!/usr/bin/env python
#coding=utf-8

import pexpect

import os

import re

import sys

import time



command = '/Users/royxu/Downloads/adt-bundle-mac-x86_64/sdk/platform-tools/adb devices'

cmd = '/Users/royxu/Downloads/adt-bundle-mac-x86_64/sdk/platform-tools/adb kill-server'

'''
regex=ur"\tdevice"

udid = []

log = pexpect.run(cmd)


log1 = pexpect.run(command)

print log1

print log

print type(log1)

log1 = log1.splitlines()

for element in log1:         
    match = re.search(regex, element)
    if match:
        print element 
        
        element = element.split('\t')
        
        print element
        
        print element[0]
                        
        udid.append(element[0])
        
print type(udid)

print udid

print "pass"

adbshell = ' -s ' + str(udid[0]) + " shell"  

print type(adbshell)

print adbshell
'''
pexpect.run(cmd)

#pexpect.spawn('/Users/royxu/Downloads/adt-bundle-mac-x86_64/sdk/platform-tools/adb')

#child = pexpect.spawn('/Users/royxu/Downloads/adt-bundle-mac-x86_64/sdk/platform-tools/adb -s 015d2ebeae24020c shell')

print "-----pexpect.spawn---------"

child = pexpect.spawn('/Users/royxu/Downloads/adt-bundle-mac-x86_64/sdk/platform-tools/adb', ['-s', '015d2ebeae24020c', 'shell'])

fout = file('mylog.txt','w')

child.logfile = fout

print "-----pexpect.expect---------"

child.expect(["shell@grouper", pexpect.EOF, pexpect.TIMEOUT])
print '------child.sendline'

child.sendline("ping -c 4 192.168.1.254")

child.expect(["rtt min/avg/max/mdev",pexpect.EOF, pexpect.TIMEOUT])

child.close(True)
