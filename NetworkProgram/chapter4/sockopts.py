__author__ = 'royxu'
#Get list of available socket options -- Chapter 3 -- socketopts.py

import socket

solist = [x for x in dir(socket) if x.startswith('SO_')]

solist.sort()

for x in solist:
    print x