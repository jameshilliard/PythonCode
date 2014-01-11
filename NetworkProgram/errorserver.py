#coding=utf-8
__author__ = 'royxu'
#server with Error Handing - Chapter 3 -errorserver.py

import socket
import traceback

host = ''
port = 51423

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((host, port))
s.listen(1)

while 1:
    try:
        clientsock, clientaddr = s.accept()
    except KeyboardInterrupt:
        raise
    except:
        traceback.print_exc()
        continue

    #Process the connection
    try:
        print "Got connection from", clientsock.getpeername()
        # Progress the request here
    except:
        traceback.print_exc()

    #close the connection
    try:
        clientsock.close()
    except KeyboardInterrupt:
        raise
    except:
        traceback.print_exc()