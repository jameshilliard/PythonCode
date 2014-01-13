#coding=utf-8
__author__ = 'royxu'
#Basic Connection Example -chapter2- connect.py

import socket

print "Creating socket……"
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print "Done"

print "Connecting remote host……"

s.connect(("www.google.com.hk", 80))
print "Done"