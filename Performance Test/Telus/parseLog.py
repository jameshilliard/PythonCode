#coding=utf-8
#!/usr/bin/env python
'''
Version 1.0

Created on 2013-3-21

@author: elen
'''

import sys, os
import re
import time
from pyExcelerator import *
#import telnet

#defined variable telnet log
filename = raw_input("Enter log path:")

#defined outputting date.
#def tm1():
#read eachline
#    list_date = []
#    f = open(filename,'r')
#    for el in f:
#        #print el
#        m_date = "^[0-9]{4}-+.*(([0-9]{2}:){2}[0-9]{2})\s$"
#        rc0 = re.search(m_date,el)
#        #print rc0
#        if rc0 is not None:
#            DATE = rc0.group().strip()
#            #print DATE
#            list_date.append(DATE)
#    print list_date
#    f.close()
#    return list_date
#tm1()



#define functions about outputting "Shared memory" 
def sharemem():
#creat an empty list
    list_e = []
    #define variable 'f' to read file you wanted.
    f = open(filename, 'r')
    #read file by each line.
    for el in f:
    # define variable m_e , begin with Shared Mmeory in-use and end in any string.
    # '\s' is any blank string.
        m_e = '^Shared Memory in-use.*\s'
        #define rc5 , search each line contain variable 'm_e'
        rc5 = re.search(m_e, el)
        if rc5 is not None:
        #split rc5's elements by blank, and output the last element.
            x = rc5.group().split()[-1]
            # x is a string, transform the format to int , and discard
            # last two characters  "KB"
            E = int(x[:-2])
            #append all the elements of E into list_e
            list_e.append(E)
        #print list_e
    f.close()
    return list_e


sharemem()


#define function about outputting "Memory in use"
def usedmem():
    list_x = []
    f = open(filename, 'r')
    for el in f:
        m_a = '^MemTotal:+\s.*'
        rc1 = re.search(m_a, el)
        if rc1 is not None:
            A = int(rc1.group().split()[-2])

        m_b = '^MemFree:+\s.*'
        rc2 = re.search(m_b, el)
        if rc2 is not None:
            B = int(rc2.group().split()[-2])

        m_c = '^Buffers:+\s.*'
        rc3 = re.search(m_c, el)
        if rc3 is not None:
            C = int(rc3.group().split()[-2])

        m_d = '^Cached:+\s.*'
        rc4 = re.search(m_d, el)
        if rc4 is not None:
            D = int(rc4.group().split()[-2])
            #define X = MemTotal - MemFree - Buffers - Cached.
            X = A - B - C - D
            list_x.append(X)
        #print list_x
    f.close()
    return list_x


usedmem()

#define function about outputting  "CPU idle"
def idlecpu():
    list_f = []
    f = open(filename, 'r')
    for el in f:
        m_f = '^([0-9]{2}:?){3}\s+[a-z]+.*'
        rc6 = re.search(m_f, el)
        if rc6 is not None:
            F = float(rc6.group().split()[-1])
            list_f.append(F)
        #print list_f
    f.close()
    return list_f


idlecpu()


def main():
    X = sharemem()
    Y = usedmem()
    Z = idlecpu()


if __name__ == '__main__':
    main()

module_dir = '/home/elenclient/workspace/practise/practise'
if module_dir not in sys.path:
    sys.path.append(module_dir)
    #print sys.path