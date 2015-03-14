#!/usr/bin/env PYTHON
#coding=utf-8

import psutil
from subprocess import PIPE

p = psutil.Popen(["/usr/bin/python", "-c", "print('hello')"], stdout=PIPE)
print p.name()
print p.username()
print p.communicate()
#print p.cpu_times()