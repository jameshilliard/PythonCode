#!/bin/bash 
#---------------------------------
# Filename:	loop_dhclient.sh
# Author: 	Martin(Jing Ma)
# Description:	loop dhclient eth less than $cycle times in case of $eth can't get ip from DHCP server sometimes
# Usage: 	Usage: loop_dhclient.sh [-n true/false] [-d ip_addr] [-u user_id] [-p passwd] [-h pchostname] [-i eth] [-t timeout] [-c cycle]
# Date:		07/03/2009
#--------------------------------
#set -x 
#G_HOST_TIP3_0_0="192.168.10.206/24"
#G_HOST_IP3="192.168.10.206"
#G_HOST_IF3_1_0="eth1"
#G_CURRENTLOG="/tmp"
#U_COMMONBIN="/mnt/automation/bin/1.0/common"
while [ $# -gt 0 ]
do
	case $1 in
	-n)
		state=$2
		shift 2;;
	-d)
		ip_addr=$2
		shift 2;;
	-u)
		user_id=$2
		shift 2;;
	-p)
		passwd=$2
		shift 2;;
	-h)
		pchostname=$2
		flag=1
		shift 2;;
	-i)
		eth=$2
		shift 2;;
	-t)
		timeout=$2
		shift 2;;
	-c)
		cycle=$2
		shift 2;;
	esac
done

if [ -z $state ]; then
    state="true"	
fi

if [ -z $ip_addr ]; then
    ip_addr=`echo ${G_HOST_TIP3_0_0%/*}`	
fi

if [ -z $user_id ]; then
    user_id="root"	
fi

if [ -z $passwd ]; then
    passwd="actiontec"
fi

if [ -z $pchostname ]; then
    flag=0
    pchostname=`echo ${G_HOST_IP3}`
fi

if [ -z $eth ];then
    eth=`echo ${G_HOST_IF3_1_0}`
fi

if [ -z $timeout ]; then
    timeout=15
fi

if [ -z $cycle ]; then
    cycle=5	
fi

result=1
i=0
while [ $i -lt $cycle -a $result -ne 0 ]; do
	if [ $flag -eq 0 ]; then
	$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/getipfrombhr2wan.log -d $ip_addr -u $user_id -p $passwd -v "rm -f /var/lib/dhclient/dhclient.leases; killall dhclient; dhclient -r $eth; dhclient $eth -T $timeout; ifconfig $eth"
	else
	$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/getipfrombhr2wan.log -d $ip_addr -u $user_id -p $passwd -v "rm -f /var/lib/dhclient/dhclient.leases; killall dhclient; dhclient -r $eth; dhclient -H $pchostname $eth -T $timeout; ifconfig $eth"
	fi
	ip=`grep "inet addr" $G_CURRENTLOG/getipfrombhr2wan.log | awk '{print $2}' | awk -F: '{print $2}' `
	if [ -z $ip ]; then
		i=$[i+1]
	else
		result=0
	fi
done
    
if [ $result = 0 -a $state = "true" ]; then
	echo "dhclient success"
	exit 0
elif [ $result != 0 -a $state = "false" ]; then
	echo "dhclient success"
	exit 0
else
	echo "dhclient failed"
	exit 1
fi       
