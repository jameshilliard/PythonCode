#coding=utf-8
__author__ = 'royxu'

#simple Gopher client with file like interface - Chapter 1
#gopherclient3.py
import socket
import sys

port = 70
host = sys.argv[1]
filename = sys.argv[2]

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((host, port))
fd = s.makefile('rw', 0)

fd.write(filename + "\r\n")

for line in fd.readline():
    sys.stdout.write(line)