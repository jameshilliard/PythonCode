#! /bin/sh

HOST=`echo ${G_PROD_IP_ETH1_0_0%/*}`

$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/pingbhr2wan.log -d $G_HOST_TIP3_0_0 -u $G_HOST_USR3 -p $G_HOST_PWD3 -v "ping $HOST -c 2"

cat $G_CURRENTLOG/pingbhr2wan.log | grep 'unreachable\|100% packet loss'
if [ $? = 0 ];then
	exit 0
else
	exit 1
fi
