#coding=utf-8
# __author__ = 'royxu'

import socket
import time
import sys
import struct

hostname = 'localhost'
port = 51423

host = socket.gethostbyname(hostname)

print host
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.sendto('', (host, port))

print "Looking for replies; press Ctrl-C to stop."
buf = s.recvfrom(2048)[0]
if len(buf) != 4:
    print "Wrong-sized reply %d: %s" % (len(buf), buf)
    sys.exit(1)

secs = struct.unpack("!I", buf)[0]
secs -= 2208988800

print secs

print time.ctime(int(secs))