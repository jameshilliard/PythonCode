#coding=utf-8
'''
Created on Mar 28, 2013

@author: roy
'''
'''
Created on Mar 26, 2013

@author: roy
'''
import matplotlib.pyplot as plt
import numpy as np
import xlrd
import os
import datetime as dt
import time
import matplotlib.dates as md
#from StringIO import StringIO




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
cur.execute(
    "INSERT INTO `cpu_loading` (`TIME`, `T_VALUE`, `VALUE`) VALUES ('%s','%s','%s') " % (str(timestamp), 100, cpu_idle))

con.commit()

# Close MySQL connection

if con:
    con.close()



##########################################





fig = plt.figure(figsize=(8, 4))
if __name__ == '__main__':
    data = xlrd.open_workbook('/home/roy/Downloads/C2000A_Ethernet_Script_Information.xls')

    plt.xlabel(u'second')
    plt.ylabel(u'memory')

    x_index = 1
    m_index = 1

    data.sheet_names()
    table = data.sheets()[0]
    table = data.sheet_by_index(0)
    table = data.sheet_by_name(u'3.13')
    print("Good")
    COLOR_INDEX = 1
    INDEX_NAME = ''

## init data
x = []
y = []
dates = []

nrows = table.nrows
ncols = table.ncols
print("nr=%d nc=%d \n" % (nrows, ncols))

for rownum in range(table.nrows):
    value = table.cell(rownum, 4).value
    if rownum == 0:
        print("")
    else:
        try:
            value_str = str(value)
            print value_str
            value_date1 = time.strptime(value_str, '%Y-%m-%d %H:%M:%S')
            x.append(x_index)
            print value_date1

            y.append(time.mktime(value_date1))
            print time.mktime(value_date1)
            dates = [dt.datetime.fromtimestamp(date) for date in y]

            #print("index=%d" %x_index)
            x_index = x_index + 1

        except:
            print("error")
print x_index
print y
print dates
m = []
n = []

for rownum in range(table.nrows):
    value = table.cell(rownum, 1).value
    if rownum == 0:
        print("")
    else:
        try:
            value_int = int(value)
            m.append(m_index)
            n.append(value_int)
            #print("index=%d"%m_index)
            m_index = m_index + 1

        except:
            print("error")
print m_index
print n

fig = plt.figure()
plt.subplots_adjust(bottom=0.5)
plt.ylim(240, 400)
plt.xticks(rotation=2)

ax = plt.gca()
xfmt = md.DateFormatter('%Y-%m-%d %H:%M:%S')
ax.xaxis.set_major_formatter(xfmt)
plt.plot(dates, n)

fig.autofmt_xdate()
plt.grid()
plt.show()
plt.savefig("/home/roy/Desktop/20130328.pdf")