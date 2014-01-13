#! /bin/bash

#---------------------------------
# Name: Tom(caipenghao)
# Description: 
# This script is used to ping -M do
#
#
#--------------------------------

if [ $# -eq 0 ]
    then
	echo "mtuping.sh -n <0/1> -s <sizes> -c <times> -d <ip address> -I <interface>"
	exit 1
fi

echo $1 $2 $3 $4 $5 $6 $7 $8

while [ $# -gt 0 ]
do
    case "$1" in
    
    -h)
	echo "mtuping.sh -n <0/1> -s <sizes> -c <times> -d <ip address>"
	exit 1
	;;
    -n)
	negative=$2
	shift
	shift
	;;
    -s)
	sizes=$2
	shift
	shift
	;;
    -c)
	times=$2
	shift
	shift
	;;
    -d)
	address=$2
	shift
	shift
	;;
    -I)
	interface=$2
	shift
	shift
	;;
    -M)
	M=$2
	shift
	shift
	;;
    *)
	echo "mtuping.sh -n <0/1> -s <sizes> -c <times> -d <ip address>"
	exit 1
	;;
    esac       
done
echo $negative
echo $address
echo $interface

if [ $negative = 1 ] ; then
	if [ $M = do ] ; then
	    ping $address -M $M -s $sizes -c $times -I $interface | grep "Frag needed and DF set"
	else
	    ping $address -M $M -s $sizes -c $times -I $interface | grep "100% packet loss"
	fi
    if [ $? = 0 ]; then
	echo "ping failed,need frag or being blocked"
	exit 0 
    else
	echo "ping success"
	exit 1
    fi
else
    ping $address -M $M -s $sizes -c $times -I $interface
    if [ $? = 0 ]; then
	echo "ping success"
	exit 0 
    else
	echo "ping failed"
	exit 1
    fi
fi


