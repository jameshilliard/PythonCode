#! /bin/sh

HOST=`echo ${G_PROD_IP_ETH0_0_0%/*}`

$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/pingbhr2lan.log -d $G_HOST_IP2 -u $G_HOST_USR2 -p $G_HOST_PWD2 -v "ping $HOST -c 2;ifconfig $G_HOST_IF2_2_0"

cat $G_CURRENTLOG/pingbhr2lan.log | grep "Destination Host Unreachable"
if [ $? = 0 ];then
	exit 1
else
	exit 0
fi
