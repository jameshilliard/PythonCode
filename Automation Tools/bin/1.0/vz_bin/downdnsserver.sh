#!/bin/sh
#################################################
#
#	This tool is to bring down DNS service on four 
#	test hosts.
#
#	by Hugo
#		05/14/2009
#
################################################

HOST1=`echo ${G_HOST_IP0%/*}`
HOST2=`echo ${G_HOST_IP1%/*}`
HOST3=`echo ${G_HOST_IP2%/*}`
HOST4=`echo ${G_HOST_IP3%/*}`

$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/hostone1.log -d $HOST1 -u $G_HOST_USR0 -p $G_HOST_PWD0 -v "service named stop"
$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/hostone2.log -d $HOST2 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "service named stop"
$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/hostone3.log -d $HOST3 -u $G_HOST_USR2 -p $G_HOST_PWD2 -v "service named stop"
$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/hostone4.log -d $HOST4 -u $G_HOST_USR3 -p $G_HOST_PWD3 -v "service named stop"

