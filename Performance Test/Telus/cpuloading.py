#coding=utf8
#!/usr/bin/env python

#

# Author: Elen Wang

# Version: 1.0

#

# This script collects CPU usage on all stations connected to CM32 serial server(10.206.1.5),

# and dump the information to TMS database (10.206.1.21).

# In order for data collection to work, the script needs to have access

# to 10.206.1.0 network.

#



from threading import Thread

from datetime import datetime

import pexpect, MySQLdb, os, sys, time, re


############restart the prograam



# list of DUT IP addresses

# Console User login

hosts = ['telnet 10.206.2.222 7003']

user = 'admin'

# list of unique passwords for each CPEs

passwords = ['s3mx4Bi3', 'k6Tr6hh3', 'hj4mY2at', '6tg3Zq6x', '7bt7ma2K', '42A3n86b']



#

# Start session on the soak stations

#

# collect function (ip address, dut number, login username, login password)

def collect_cpu(ip_addr, dut_num, dut_usr, dut_passwd):
    #########################################

    # Preparing Global parameters

    #########################################

    # MySQL login info

    mysql_url = 'localhost'

    mysql_user = 'root'

    mysql_passwd = '123qaz'

    mysql_db = 'elen_test'

    dutnum = dut_num

    timestamp = datetime.now()

    #########################################

    # Start pexpect connection

    #########################################

    print "INFO: Starting Telnet Session On DigiCM32: " + ip_addr

    session = pexpect.spawn(ip_addr)
    print ip_addr
    time.sleep(5)

    #    session.send('\n')

    j = session.expect(['.*Login : ', '.*Password : '], timeout=5)

    if j == 0:
        session.sendline("admin")

        time.sleep(3)
        session.sendline("admin")

    if j == 1:
        session.send('\n')

        time.sleep(5)

        session.expect('.*Login : ')

        session.sendline("admin")

        time.sleep(3)

        session.expect('.*')

        session.sendline("admin")


    # Log into the console

    session.send('\n')

    time.sleep(1)

    i = session.expect(['.*Login:', '.*Password:', '.*#'], timeout=5)

    if i == 0:

        session.sendline(dut_usr)

        time.sleep(3)

        session.expect('.*')

        session.sendline(dut_passwd)

    elif i == 1:

        session.send('\n')

        time.sleep(5)

        session.expect('.*Login:')

        session.sendline(dut_usr)

        time.sleep(3)

        session.expect('.*')

        session.sendline(dut_passwd)

    elif i == 2:

        print "INFO: Already logged in..."

    print "Collecting DUT's CPU usage"

    session.sendline('\n')

    time.sleep(1)

    session.expect('.*\#')

    session.sendline('mpstat -P ALL')

    time.sleep(3)

    index_1 = session.expect(['.*#', pexpect.EOF, pexpect.TIMEOUT])
    #    time.sleep(3)
    #    print 'After==><%s>'%session.after
    #    print session.before
    cpu_output = session.after
    #print cpu_output

    #    session.expect('.*#')

    ############################################

    # END OF OPERATION - EXIT AND CLOSE ALL SESSIONS

    # Exit Shell

    ############################################

    print "INFO: Exiting Shell and OS Prompt..."

    #    session.expect('(?i)#')

    session.sendline('exit')

    time.sleep(2)

    cpu = cpu_output.split()

    #    print cpu

    #    session.expect('.*')
    #
    #    session.sendline('exit')

    #########################################

    # Parsing PEXPECT outputs

    #########################################

    cp_ty = 'CPU'

    cpu = cpu_output.split()

    #    cpu_all = float(100) - float(cpu[31])
    #
    #    cpu0_soft = cpu[34]
    #
    #    cpu1_soft = cpu[45]
    #
    #    cpu0_sys = cpu[36]
    #
    #    cpu1_sys = cpu[47]
    #
    #    cpu0_idle = cpu[42]
    #
    #    cpu1_idle = cpu[53]

    cpu_idle = cpu[33]

    print cpu[33]
    #    print type(cpu_idle)

    print timestamp
    #    print type(timestamp)
    #########################################

    # Establish MySQL connection

    #########################################

    con = MySQLdb.Connection(host=mysql_url, user=mysql_user, passwd=mysql_passwd, db=mysql_db);
    print 'Connected to MySQL server'
    cur = con.cursor()

    ###########################################

    # MySQL Operations: Storing information

    ###########################################

    # CPU Table Headers (DUTNUM, SWVERSION, TYPE, CPU_ALL, CPU0_SOFT,

    # CPU1_SOFT, CPU0_SYS, CPU1_SYS, CPU0_IDLE, CPU1_IDLE, TIMESTAMP)
    cur.execute("use elen_test")
    print "INSERT INTO `cpu_loading` (`TIME`, `T_VALUE`, `VALUE`) VALUES ('%s','%s','%s') " % (timestamp, 100, cpu_idle)
    cur.execute("INSERT INTO `cpu_loading` (`TIME`, `T_VALUE`, `VALUE`) VALUES ('%s','%s','%s') " % (
        str(timestamp), 100, cpu_idle))

    con.commit()

    # Close MySQL connection

    if con:
        con.close()


##########################################

#

# Start multi-thread telnet session

#

##########################################

try:

    for index in range(0, len(hosts)):
        dut_num = index + 1

        t = Thread(target=collect_cpu, args=(hosts[index], dut_num, user, passwords[index]))

        t.start()

except:

    print "Oops, something went wrong..."

time.sleep(15)


def restart_program():
    python = sys.executable
    os.execl(python, python, *sys.argv)


if __name__ == "__main__":
    print 'The program will restart after 10 second'
    time.sleep(15)
    restart_program()
