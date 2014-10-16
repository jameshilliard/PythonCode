#coding=utf-8
'''
Created on 2013-3-28

@author: jemmy
'''
import telnetlib
import getpass
import sys
import os
import time
import xlrd
from pyExcelerator import *
import
#define
Host = "192.168.0.1"
Port = "70001"
#Host = raw_iput("IP",)
username = "admin"
password = "admin"

filename = str(time.strftime('%Y%m%d%H%M%S'))


def telnet():
# product:
    tn = telnetlib.Telnet(Host)
    telnetlib.Telnet(Host, Port)
    tn.read_until("Login: ")
    tn.write(username + "\n")
    tn.read_until("Password: ")
    tn.write(password + "\n")
    tn.write("meminfo \n")
    tn.write("sh \n")
    tn.write("cat /proc/meminfo \n")
    tn.write("mpstat -P ALL \n")
    tn.write("date \n")
    tn.write("exit \n")
    tn.write("exit \n")
    return tn.read_all()


telnet()
time.sleep(5)

#define 
def getlog(s):
    print "getlog!---------------------------------------"
    f = open('/home/' + filename, 'a')
    f.write(s)
    f.close()

#define
for i in range(1, 10000000):
    print i
    telnet()
    log = str(telnet())
    getlog(log)
    time.sleep(5)