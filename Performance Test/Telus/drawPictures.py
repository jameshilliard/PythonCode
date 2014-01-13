#coding=utf-8
'''
Created on Mar 31, 2013

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





## init data
'''
x = []
y = []
x_index=1
dates = []
    
nrows = table.nrows
ncols = table.ncols
print("nr=%d nc=%d \n"%(nrows,ncols))

    
for rownum in range(table.nrows):
    value = table.cell(rownum,4).value
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
            dates=[dt.datetime.fromtimestamp(date) for date in y]
            
            #print("index=%d" %x_index)
            x_index=x_index+1
      
        except:
            print("error")
print x_index
print y
print dates
'''


def readExcel(m, n):
    m_index = 1
    for rownum in range(table.nrows):
        value = table.cell(rownum, 2).value
        if rownum == 0:
            print("")
        else:
            try:
                value_int = int(value)
                m.append(m_index)
                n.append(value_int)
                m_index = m_index + 1

            except:
                print("error")
    print m_index
    print m
    print n


def drawPictures(x, y):
    fig = plt.figure(figsize=(15, 10))
    plt.subplots_adjust(bottom=0.5)
    plt.ylim(0, 400)
    plt.ylabel(u'memory')
    plt.xticks(rotation=2)
    ax = plt.gca()
    #xfmt = md.DateFormatter('%Y-%m-%d %H:%M:%S')
    #ax.xaxis.set_major_formatter(xfmt)
    #plt.plot(dates,n)
    #fig.autofmt_xdate()
    #a = [z*2 for z in range(1,181)]
    #print a
    plt.plot(x, y, 'r--')
    #plt.plot(x,a,'b')
    plt.grid()
    plt.show()
    fig.savefig("/home/roy/Desktop/20130328.pdf")


if __name__ == '__main__':
    print("main")
    data = xlrd.open_workbook('/home/roy/Downloads/C2000A_Ethernet_Script_Information.xls')

    sheet_names = data.sheet_names()
    print sheet_names
    table = data.sheets()[2]
    #table = data.sheet_by_index(0)
    #table = data.sheet_by_name(u'3.14')
    nrows = table.nrows
    ncols = table.ncols
    print("nr=%d nc=%d \n" % (nrows, ncols))
    print("Good")
    m = []
    n = []
    readExcel(m, n)
    drawPictures(m, n)
    
