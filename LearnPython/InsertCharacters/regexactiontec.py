#!/usr/bin/env python
#coding=utf-8

import os

import re

c = 'actiontec'


a =  os.path.abspath('aaa.txt')

regex=ur"actiontec"


filea = open(a, 'r')

for eachLine in filea:
    match = re.search(regex, eachLine)
    if match:
        print eachLine
    else:
        print "this line can't contain str 'actiontec' : " + eachLine

filea.close()