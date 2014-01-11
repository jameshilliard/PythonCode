#coding=utf-8
__author__ = 'royxu'
#Revised Connection Example -chapter2- connect2.py

import socket

print "Creating socket……"
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print "Done"

print "Looking up port number....."

port = socket.getservbyname('http', 'tcp')
print "Done"

print "Connecting remote host on port %d..." % port

s.connect(("www.google.com.hk", port))
print "Done"