#coding=utf-8
__author__ = 'root'

#!/usr/bin/env python
# Python Network Programming Cookbook -- Chapter - 1
# This program is optimized for Python 2.7. It may run on any
# other Python version with/without modifications.

import socket
def test_socket_timeout():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    print "Default socket timeout: %s" % s.gettimeout()
    s.settimeout(100)
    print "Current socket timeout: %s" % s.gettimeout()
if __name__ == '__main__':
    test_socket_timeout()