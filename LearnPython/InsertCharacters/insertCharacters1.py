#!/usr/bin/env python
#coding=utf-8

import os

c = 'actiontec'


a =  os.path.abspath('aaa.txt')

b =  os.path.abspath('bbb.txt')

filea = open(a, 'r')

flist = filea.readlines()
flist2 = []

print flist

for element in flist:
    print element
    element =  element[:2] + c + element[2:]
    print element   
    flist2.append(element)
    
print flist

filea.close()

print flist2


f=open(a,'w')

f.writelines(flist2)

f.close()

