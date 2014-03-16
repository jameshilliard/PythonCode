__author__ = 'royxu'
#echo server -chapter 3 - echo server.py

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
        while 1:
            data = clientsock.recv(4096)
            if not len(data):
                break
            clientsock.sendall(data)
    except (KeyboardInterrupt, SystemExit):
        raise
    except:
        traceback.print_exc()

    #close the connection
    try:
        clientsock.close()
    except KeyboardInterrupt:
        raise
    except:
        traceback.print_exc()