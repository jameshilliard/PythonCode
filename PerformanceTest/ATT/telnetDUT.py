# -*- coding: utf-8 -*-
'''
Created on 2014-1-6
@author: Elen
'''

#import libs
import telnetlib
#import re
import sys
import os
import time
import shlex
import subprocess
import MySQLdb
#import getpass
from datetime import datetime

#异常处理，检查网络是否正常
command_line = "ping -c 1 192.168.1.254"
args = shlex.split(command_line)
try:
    subprocess.check_call(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    print "Website is there."
except subprocess.CalledProcessError:
    print "Couldn't get a ping.Please check your network connection!"
    exit(1)


#define variables
timestamp = datetime.now()
Host = "192.168.1.254"
mysql_url = '192.168.20.108'
mysql_user = 'root'
mysql_passwd = '123qaz'
mysql_db = 'python'
mysql_table = 'cpu_loading_reference'

#define function about telnet and do some operation
def telnet():
    tn = telnetlib.Telnet(Host)
    tn.read_until('.*#', timeout=5)
    time.sleep(1)
    tn.write("mpstat -P ALL\n")
    time.sleep(2)
    tn.write("exit\n")
    time.sleep(2)
    return tn.read_all()

#print str(telnet())

def run_program():
    #Starting Program
    print "=============Start!!!==============="
    #telnet log switch to a list
    index = str(telnet()).split()
    #filter the idle CPU
    cpu_idle = index[-27]
    #connect to DB
    con = MySQLdb.Connection(host=mysql_url, user=mysql_user, passwd=mysql_passwd, db=mysql_db)
    print 'Connected to MySQL server'
    cur = con.cursor()
    #select DB
    cur.execute("use %s" % mysql_db)
    #Insert Row and commit it
    cur.execute("INSERT INTO` %s ` (`TIME`, `REF_IDLE_CPU`, `IDLE_CPU`) VALUES ('%s','%s','%s') " % (
        mysql_table, str(timestamp), 100, cpu_idle))
    con.commit()
    # Close MySQL connection
    if con:
        con.close()

#main process
try:

    run_program()

except Exception, e:
    print e
    exit(1)

time.sleep(15)

#Restart the program
def restart_program():
    python = sys.executable
    os.execl(python, python, *sys.argv)


if __name__ == "__main__":
    print 'The program will restart after 10 second'
    time.sleep(15)
    restart_program()


