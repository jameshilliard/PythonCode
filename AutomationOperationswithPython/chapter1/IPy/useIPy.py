#!/usr/bin/env PYTHON
#coding=utf-8

from IPy import IP

ip_s = raw_input("please input a IP or a net work:")
ips = IP(ip_s)

if len(ips)>1:
    print ips.net()
    print ips.netmask()
    print ips.broadcast()
    print ips.reverseNames()[0]
    print ips.len()

else:
    print ips.reverseName()[0]
    
print ips.strHex()
print ips.strBin()
print ips.iptype()