#coding=utf-8
__author__ = 'royxu'
# High-Level Gopher client -Chapter 1 - gopherlibclient.py
# gopher module has been removed from python 2.6

import gopherlib, sys

host = sys.argv[1]
file = sys.argv[2]

f = gopherlib.send_selecter(file, host)

for line in f.readlines():
    sys.stdout.write(line)
