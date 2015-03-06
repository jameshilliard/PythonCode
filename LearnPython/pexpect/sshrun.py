#!/usr/bin/env PYTHON
#coding=utf-8

import pexpect

pexpect.run('ssh root@192.168.8.2', timeout = -1, events={'password:':'123qaz'})

print "\nend"