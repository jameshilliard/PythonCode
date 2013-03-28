#coding=utf-8
'''
Created on Mar 21, 2013

@author: Tony
'''
import telnetlib    
import getpass
import sys
import os
import time
import re
import pexpect
from pyExcelerator  import *
import xlrd
from xlutils.copy import copy


#filename=str(time.strftime('%Y%m%d%H%M%S'))+".log"
#file_object = open('/home/20130326182749.log','r')
time = raw_input("Current Log Path:")
file_object1='/home/'+time
excel_number= raw_input("Enter your times:")


file_object= open(file_object1,'r')
try:
    all_the_text = file_object.readlines()
finally:
    file_object.close()



listShaMemInuse=[]  
for Shared_Memory_Inuse in all_the_text:
    rd1=re.search('^Shared Memory in-use\s.*',Shared_Memory_Inuse)
    if rd1 is not None:
        data1=rd1.group().split()[-1]
        data2=int(data1[:-2])
        listShaMemInuse.append(data2)
print listShaMemInuse
        
listTotalMemInuse=[]        
for el in all_the_text:
    m_a = '^MemTotal:+\s.*'
    rc1 = re.search(m_a,el)
    if rc1 is not None:
        MemTotal=int(rc1.group().split()[-2])
        
    m_b = '^MemFree:+\s.*'
    rc2 = re.search(m_b,el)
    if rc2 is not None:
        MemFree=int(rc2.group().split()[-2])

    m_c = '^Buffers:+\s.*'
    rc3 = re.search(m_c,el)
    if rc3 is not None:
        Buffers=int(rc3.group().split()[-2])
        
    m_d = '^Cached:+\s.*'
    rc4 = re.search(m_d,el)
    if rc4 is not None:
        Cached=int(rc4.group().split()[-2])
        TotalMemInuse=MemTotal-MemFree-Buffers-Cached
        listTotalMemInuse.append(TotalMemInuse)
print listTotalMemInuse

listCPUseIdle=[]        
for el in all_the_text:            
    m_f = '^([0-9]{2}:?){3}\s+[a-z]+.*'
    rc6 = re.search(m_f,el)
    if rc6 is not None:
        CPUseIdle = float(rc6.group().split()[-1])       
        listCPUseIdle.append(CPUseIdle)
print listCPUseIdle

listDate=[]                    
for el in all_the_text:
    rc7 = re.search('.*[A-Z]{3}\s[0-9]{4}\s$',el)
    if rc7 is not None:
        date = rc7.group()
        date = rc7.group().split()[0]+' '+rc7.group().split()[1]+' '+rc7.group().split()[2]+' '+rc7.group().split()[3]
        listDate.append(date)
print listDate[0]
            
#w = Workbook()
oldWb = xlrd.open_workbook('/root/workspace/test5/SharedMemoryInuse.xls');
#print oldWb; #<xlrd.book.Book object at 0x000000000315C940>
newWb = copy(oldWb);
#print newWb;  
ws = newWb.get_sheet(0) 
ws.write(0,int(excel_number),time)
#ws.write(0,1,u"Shared Memory In-use")
for i in range(len(listDate)):
#    ws.write(i+1,0,listDate[i])
    ws.write(i+1,int(excel_number),listShaMemInuse[i])
    i+=1
newWb.save('/root/workspace/test5/SharedMemoryInuse.xls')
        
        
#w = Workbook()
oldWb = xlrd.open_workbook('/root/workspace/test5/CPUseageIdle.xls');
newWb = copy(oldWb)  
ws = newWb.get_sheet(0) 
#ws.write(0,0,u"CPU us-age Idle")
#ws.write(0,1,u"Theoretical Value")
ws.write(0,int(excel_number),time)
#ws.write(0,2,listDate[0])
for i in range(len(listDate)):
#   ws.write(i+1,0,i+1)
    ws.write(i+1,int(excel_number),listCPUseIdle[i])
    i+=1
newWb.save('/root/workspace/test5/CPUseageIdle.xls')
   
#w = Workbook()
oldWb = xlrd.open_workbook('/root/workspace/test5/TotalMemInuse.xls');
newWb = copy(oldWb) 
ws = newWb.get_sheet(0)   
ws.write(0,int(excel_number),time)
for i in range(len(listDate)):
#    ws.write(i+1,0,listDate[i])
    ws.write(i+1,int(excel_number),listTotalMemInuse[i])
    i+=1
newWb.save('/root/workspace/test5/TotalMemInuse.xls')

#w = Workbook()  
#ws = w.add_sheet('sheet') 
#ws.write(0,1,u"Total Memery in-use")
#ws.write(0,2,u"Shared Memery in-use")
#ws.write(0,3,u"CPU Us-age idle")
#for i in range(len(listDate)):
#    ws.write(i+1,0,listDate[i])
#    ws.write(i+1,1,listTotalMemInuse[i])
#    ws.write(i+1,2,listShaMemInuse[i])
#    ws.write(i+1,3,listCPUseIdle[i])
#    i+=1
#w.save('Total.xls')