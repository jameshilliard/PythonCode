#!/usr/bin/env python
#coding=utf-8

import os

c = 'actiontec'


a =  os.path.abspath('aaa.txt')
b = os.path.abspath('bbb.txt')

filea = open(a, 'r')

for eachLine in filea:
    print eachLine
    eachLine =  eachLine[:2] + c + eachLine[2:]
    print eachLine
    fileb = open(b, 'a')
    fileb.writelines(eachLine)
    fileb.close()
    
filea.close()

