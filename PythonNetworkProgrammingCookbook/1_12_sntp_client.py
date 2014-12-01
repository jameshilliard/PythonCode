# coding=utf-8
__author__ = 'root'

#!/usr/bin/env python
# Python Network Programming Cookbook -- Chapter - 1
# This program is optimized for Python 2.7. It may run on any
# other Python version with/without modifications.

import socket

import struct

import sys

import time

NTP_SERVER = '202.120.2.101'

TIME1970 = 2208988800L


def sntp_client():
    client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    data = '\x1b' + 47 * '\0'
    client.sendto(data, (NTP_SERVER, 123))
    data, address = client.recvfrom(1024)
    if data:
        print 'Response received from:', address
        t = struct.unpack('!12I', data)[10]
        t -= TIME1970
        print '\tTime=%s' % time.ctime(t)


if __name__ == '__main__':
    sntp_client()