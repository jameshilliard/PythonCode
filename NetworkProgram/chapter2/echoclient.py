#coding=utf-8
__author__ = 'royxu'
#Basic Connection Example -chapter2- connect.py

import socket
import sys

host = 'localhost'
port = 51423

data = "s" * 1024 # 10MB data

print "Creating socket……"
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((host, port))

byteswritten = 0
while byteswritten < len(data):
    startpos = byteswritten
    endpos = min(byteswritten + 1024, len(data))
    byteswritten += s.send(data[startpos:endpos])
    sys.stdout.write("Wrote %d byte \r" % byteswritten)
    sys.stdout.flush()

s.shutdown(1)

print "All data sent... "

while 1:
    buf = s.recv(1024)
    if not len(buf):
        break
    sys.stdout.write(buf)


