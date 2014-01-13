#! /bin/sh

HOST=`echo ${G_PROD_IP_ETH0_0_0%/*}`

$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/pingbhr2wan.log -d $G_HOST_IP2 -u $G_HOST_USR2 -p $G_HOST_PWD2 -v "ping $HOST -c 2"

cat $G_CURRENTLOG/pingbhr2wan.log | grep "2 received"

if [ $? = 0 ];then
	exit 1
else
	exit 0
fi
