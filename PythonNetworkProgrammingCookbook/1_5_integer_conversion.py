#coding=utf-8
__author__ = 'root'
#!/usr/bin/env python
# Python Network Programming Cookbook -- Chapter -1
# This program is optimized for Python 2.7.
# It may run on any other version with/without modifications.

import socket

def covert_integer():
    data = 1234
    # 32-bit
    print "Original: %s => Long host byte order: %s, Network byte order: %s" %(data, socket.ntohl(data), socket.htonl(data))
    # 16-bit
    print "Original: %s => Short host byte order: %s, Network byte order: %s" %(data, socket.ntohs(data), socket.htons(data))


if __name__== '__main__':
    covert_integer()