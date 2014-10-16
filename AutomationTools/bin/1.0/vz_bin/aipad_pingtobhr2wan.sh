#! /bin/sh

HOST=`echo ${G_PROD_IP_ETH1_0_0%/*}`

$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/pingbhr2wan.log -d $G_HOST_TIP3_0_0 -u $G_HOST_USR3 -p $G_HOST_PWD3 -v "ping $HOST -c 2; ifconfig $G_HOST_IF3_1_0"

cat $G_CURRENTLOG/pingbhr2wan.log | grep "Destination Host Unreachable"
retone="$?"
cat $G_CURRENTLOG/pingbhr2wan.log | grep "Network is unreachable"
rettwo="$?"
if [ "$retone" = 0 -a "$rettwo" = 0 ];then
	exit 1
else
	exit 0
fi
