#coding=utf-8
__author__ = 'royxu'
#UDP Wrong Time Server -Chapter 4 - udptimeserver.py

import socket
import traceback
import struct
import time

host = ''
port = 51423

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((host, port))

while 1:
    try:
        message, address = s.recvfrom(8192)
        secs = int(time.time())
        secs -= 60 * 60 * 24
        secs += 2208988800
        reply = struct.pack("!I", secs)
        s.sendto(reply, address)
    except (KeyboardInterrupt, SystemExit):
        raise
    except:
        traceback.print_exc()