#!/bin/sh
#---------------------------------
# Name: Tom(caipenghao)
# Description: 
# This script is used to change the dhcp server's dhcpd.conf and restart the service
#
#
#--------------------------------

HOST1=`echo ${G_HOST_IP0%/*}`
HOST2=`echo ${G_HOST_IP1%/*}`
HOST3=`echo ${G_HOST_IP2%/*}`
HOST4=`echo ${G_HOST_IP3%/*}`

# $1 is the path of the config file to replace
perl $U_COMMONBIN/clicfg.pl -c -d $G_HOST_IP2 -l $G_CURRENTLOG -u $G_HOST_USR2 -p $G_HOST_PWD2 -m "sftp> " -v "rm /etc/dhcpd.conf" -v "put $1 /etc/dhcpd.conf"
$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/restart_dhcp.log -d $HOST3 -u $G_HOST_USR2 -p $G_HOST_PWD2 -v "service dhcpd start 2>/dev/null"

