#coding=utf-8
__author__ = 'royxu'
# Error Handing Example with shutdown and file-like objects - Chapter2 - shutdownfile.py

import socket
import sys
import time

host = sys.argv[1]
textport = sys.argv[2]
filename = sys.argv[3]

try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
except socket.error, e:
    print "Strange error creating socket: %s" % e
    sys.exit(1)

#Try prasing it as a numeric port number

try:
    port = int(textport)
except ValueError:
# that didn't work, so it's probably a protocol name.
# Look it up instead.
    try:
        port = socket.getservbyname(textport, 'tcp')
    except socket.error, e:
        print "Couldn't find your port: %s" % e
        sys.exit(1)

try:
    s.connect((host, port))
except socket.gaierror, e:
    print "Address-related erro connecting to server: %s" % e
    sys.exit(1)
except socket.error, e:
    print "Connection error: %s" % e
    sys.exit(1)

fd = s.makefile('rw', 0)

print "sleeping..."
time.sleep(10)
print "continuing."

try:
    fd.write("Get %s HTTP/1.0\r\n\r\n" % filename)
except socket.error, e:
    print "Error sending data : %s" % e
    sys.exit(1)

try:
    fd.flush()
except socket.error, e:
    print "error sending data (detected by flush): %s" % e
    sys.exit(1)

try:
    s.shutdown()
except socket.error, e:
    print "Error sending data(detected by shutdown): %s" % e
    sys.exit(1)

while 1:
    try:
        buf = fd.read(2048)
    except socket.error, e:
        print "Error receiving data: %s" % e
        sys.exit(1)
    if not len(buf):
        break
    sys.stdout.write(buf)