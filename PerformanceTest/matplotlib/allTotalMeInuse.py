#coding=utf-8
'''
Created on Mar 28, 2013

@author: Tony
'''
from pyExcelerator import *
import xlrd
import os
import re


w = Workbook()
ws = w.add_sheet('sheet')
ws.write(0, 0, u"Total Memery In-use")
ws.write(0, 1, u"Theoretical Value")

for i in range(200):
    ws.write(i + 1, 0, i + 1)
    ws.write(i + 1, 1, "90")
    i += 1

#ws.write(0,1,u"Shared Memory In-use")




dat = []
for i in os.listdir('/home/log'):
    dat.append(i)
    dat.sort()
print dat

for i in range(len(dat)):
    file_object1 = '/home/log/' + dat[i]
    file_object = open(file_object1, 'r')
    try:
        all_the_text = file_object.readlines()
    finally:
        file_object.close()
    arr = []
    for el in all_the_text:
        m_f = '^([0-9]{2}:?){3}\s+[a-z]+.*'
        rc6 = re.search(m_f, el)
        if rc6 is not None:
            CPUseIdle = float(rc6.group().split()[-1])
            arr.append(CPUseIdle)
            #   print arr

    while i < len(dat):
        i += 1
        #       print i,arr
        for l in range(len(arr)):
            ws.write(l + 1, i + 1, arr[l])
            l += 1
        break

for i in range(len(dat)):
    ws.write(0, i + 2, dat[i])
    i += 1

w.save('AllTotalMeInUse.xls')