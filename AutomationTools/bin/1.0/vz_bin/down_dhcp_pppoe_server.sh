#!/bin/sh
#set x
HOST1=`echo ${G_HOST_IP0%/*}`
HOST2=`echo ${G_HOST_IP1%/*}`
HOST3=`echo ${G_HOST_IP2%/*}`
HOST4=`echo ${G_HOST_IP3%/*}`

if [ -n "$HOST1" ]; then
$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/hostone1.log -d $HOST1 -u $G_HOST_USR0 -p $G_HOST_PWD0 -v "service dhcpd stop 2>/dev/null; piddhcp=`ps aux | grep dhcpd | grep -v grep | awk '{ print $2 }'`; kill $piddhcp 2>/dev/null"  -v "killall pppoe-server 2>/dev/null"
fi
if [ -n "$HOST2" ]; then
$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/hostone2.log -d $HOST2 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "service dhcpd stop 2>/dev/null; piddhcp=`ps aux | grep dhcpd | grep -v grep | awk '{ print $2 }'`; kill $piddhcp 2>/dev/null" -v "killall pppoe-server 2>/dev/null"
fi
if [ -n "$HOST3" ]; then
$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/hostone3.log -d $HOST3 -u $G_HOST_USR2 -p $G_HOST_PWD2 -v "service dhcpd stop 2>/dev/null; piddhcp=`ps aux | grep dhcpd | grep -v grep | awk '{ print $2 }'`; kill $piddhcp 2>/dev/null" -v "killall pppoe-server 2>/dev/null"
fi
if [ -n "$HOST4" ]; then
$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/hostone4.log -d $HOST4 -u $G_HOST_USR3 -p $G_HOST_PWD3 -v "service dhcpd stop 2>/dev/null; piddhcp=`ps aux | grep dhcpd | grep -v grep | awk '{ print $2 }'`; kill $piddhcp 2>/dev/null" -v "killall pppoe-server 2>/dev/null"
fi

