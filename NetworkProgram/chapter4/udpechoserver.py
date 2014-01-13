#coding=utf-8
__author__ = 'royxu'
import socket
import traceback

host = ''
port = 51423

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((host, port))

while 1:
    try:
        message, address = s.recvfrom(8192)
        print "Got data from", address
        #echo it back
        s.sendto(message, address)
    except(KeyboardInterrupt, SystemExit):
        raise
    except:
        traceback.print_exc()
