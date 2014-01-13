#!/bin/bash -w
#---------------------------------
# Name: Tom(caipenghao)
# Description: 
# nslookup some address
# nslookup.sh -n <on/off> urls address
# example nslookup.sh -n on www.shqa.edu 10.10.10.73 //mean you expect to resolv www.shqa.edu to address 10.10.10.73 success
#--------------------------------
#when -n value is on this case is use to handle when you expect to resolv success
#when -n value is off this case is use to handle when you expect to resolv fail
set -x
if [ $# -lt 2 ]; then
	echo "Usage: aipad_checkhostname.sh -n <on/off> [context] [address]" 
	exit
fi

if [ $1 != "-n" ]; then
	echo "Usage: aipad_checkhostname.sh -n <on/off> [context] [address]" 
	exit
fi

if [ -z $3 ]; then
    context="www.shqa.com"	
else 
    context="$3"	
fi

if [ -z $4 ]; then
    address=10.10.10.10	
else 
    address="$4"	
fi

dutip=`echo ${G_PROD_IP_ETH0_0_0%/*}`
#dutip=192.168.0.1
if [ $2 = on ]; then
    nslookup $context $dutip | grep $address
    result=$?
    if [ $result != 0 ]; then
	echo "cannot resolv"
	exit 0
    else
	echo "resolv success"
        exit 1
    fi       
else
    nslookup $context $dutip | grep $address
    result=$?
    if [ $result != 0 ]; then
	echo "cannot resolv"
	exit 1
    else
	echo "resolv success"
	exit 0
    fi 
fi

