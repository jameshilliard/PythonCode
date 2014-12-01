# coding=utf-8
__author__ = 'root'

#!/usr/bin/env python
# Python Network Programming Cookbook -- Chapter - 1
# This program is optimized for Python 2.7. It may run on any
# other Python version with/without modifications.

import socket


def test_socket_modes():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setblocking(1)
    s.settimeout(0.5)
    s.bind(('127.0.0.1', 0))

    socket_address = s.getsockname()
    print "Trvial Server launched on socket: %s" % str(socket_address)

    while (1):
        s.listen(1)


if __name__ == '__main__':
    test_socket_modes()
