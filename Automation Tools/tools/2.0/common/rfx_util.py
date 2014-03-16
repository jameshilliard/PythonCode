#!/usr/bin/python -u
# -*- coding: utf-8 -*-
"""
All utilities collected by rayofox


"""
import os
import sys
import time
import re
import ctypes
from pprint import pprint
from pprint import pformat
import logging
from copy import deepcopy

import signal
from optparse import OptionParser

# for IP address translation
import socket
import struct


def str2uint(str):
#
    return socket.ntohl(struct.unpack("I", socket.inet_aton(str))[0])


def str2int(str):
    uint = socket.ntohl(struct.unpack("I", socket.inet_aton(str))[0])
    #   
    return struct.unpack("i", struct.pack('I', uint))[0]


def num2str(ip):
    if ip < 0:
        ip = struct.unpack("I", struct.pack('i', ip))[0]
    return socket.inet_ntoa(struct.pack('I', socket.htonl(ip)))


def calc_subnet_region(ip, netmask):
    """
    This function is to caculate the subnet begin IP and end IP with given IP and netmask
    """
    ip1 = ip.split(".")
    nm1 = netmask.split(".")
    a = [str(int(i) & int(m)) for i, m in map(None, ip1, nm1)]
    b = [str(int(i) | ctypes.c_ubyte(~int(m)).value) for i, m in map(None, ip1, nm1)]
    #return a,b
    #print '.'.join(nd(ip,nm)[0]) + "-" + '.'.join(nd(ip,nm)[1])
    ip_begin = '.'.join(a)
    ip_end = '.'.join(b)
    return ip_begin, ip_end


def is_in_same_subnet(ip1, ip2, netmask):
    """
    To check if ip1 and ip2 is in the same subnet with given netmask 
    """
    rc = False
    ip_begin, ip_end = calc_subnet_region(ip1, netmask)
    #print ip_begin,ip_end,ip1,ip2

    n_ip_begin = str2uint(ip_begin)
    n_ip_end = str2uint(ip_end)
    n_ip1 = str2uint(ip1)
    n_ip2 = str2uint(ip2)

    if (n_ip_begin <= n_ip1 <= n_ip_end) and (n_ip_begin <= n_ip2 <= n_ip_end):
        rc = True

    return rc


def exchange_netmask_IPv4_to_Dec(mask):
    """
    exchange netmaks IPv4 format to Decimal
    255.255.255.0        /24
    255.255.255.128      /25
    255.255.255.192      /26
    255.255.255.224      /27
    255.255.255.240      /28
    255.255.255.248      /29
    255.255.255.252      /30
    255.255.255.254      /31
    255.255.255.255      /32
    """
    count_bit = lambda bin_str: len([i for i in bin_str if i == '1'])
    mask_splited = mask.split('.')
    mask_count = [count_bit(bin((int(i)))) for i in mask_splited]
    return sum(mask_count)


def exchange_netmask_Dec_2_IPv4(num):
    """
    exchange netmaks Decimal format to IPv4 format
    255.255.255.0        /24
    255.255.255.128      /25
    255.255.255.192      /26
    255.255.255.224      /27
    255.255.255.240      /28
    255.255.255.248      /29
    255.255.255.252      /30
    255.255.255.254      /31
    255.255.255.255      /32
    """
    d = num

    z_ipv4 = []
    for i in range(4):
        if d >= 8:
            z_ipv4.append(8)
            d -= 8
        else:
            z_ipv4.append(d)
            d = 0
    s_ipv4 = []
    for seg in z_ipv4:
        s_ipv4.append(str(256 - (1 << (8 - seg) )))

    ss = '.'.join(s_ipv4)
    print ss
    return ss


###############################################################################

def unit_tests():
    """
    """
    assert (( calc_subnet_region('192.168.0.1', '255.255.255.0') ) == ('192.168.0.0', '192.168.0.255') )
    assert (is_in_same_subnet('192.168.0.51', '192.168.0.151', '255.255.255.0') )
    assert (is_in_same_subnet('192.168.0.11', '192.168.10.111', '255.255.0.0') )
    assert (not is_in_same_subnet('192.168.0.11', '192.168.10.111', '255.255.255.0') )
    return True


if __name__ == '__main__':
    """
    """
    print exchange_netmask_IPv4_to_Dec('255.255.255.238')
    exchange_netmask_Dec_2_IPv4(30)
    unit_tests()
