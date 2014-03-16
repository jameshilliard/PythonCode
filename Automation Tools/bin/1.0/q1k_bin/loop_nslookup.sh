#!/bin/bash 
#---------------------------------
# Filename:	loop_nslookup.sh
# Author: 	Martin(Jing Ma)
# Description:	loop nslookup some ip_addr
# Usage: 	loop_nslookup.sh -n <true/false> <url> <ip_addr> [cycle]
# Date:		07/02/2009
#--------------------------------

#set -x 
if [ $# -lt 2 ]; then
	echo "Usage: loop_nslookup.sh -n <true/false> url ip_addr cycle" 
	exit
fi

if [ $1 != "-n" ]; then
	echo "Usage: loop_nslookup.sh -n <true/false> url ip_addr cycle" 
	exit
fi

if [ -z $3 ]; then
    url="www.shqa.edu"	
else 
    url="$3"	
fi

if [ -z $4 ]; then
    ip_addr=10.10.10.150	
else 
    ip_addr="$4"	
fi

if [ -z $5 ]; then
    cycle=5	
else 
    cycle="$5"	
fi

dutip=`echo ${G_PROD_IP_ETH0_0_0%/*}`

if [ $2 = "true" ]; then
	result=1
	i=0
	while [ $i -lt $cycle -a $result -ne 0 ]; do
	    nslookup $url $dutip | grep -5 $ip_addr
	    result=$?
	    i=$[i+1]
	sleep 5
	done
    
    if [ $result != 0 ]; then
	echo "Failed:resolution failed"
	exit 1
    else
	echo "Success:resolution success"
	exit 0
    fi       
else
	info="SERVFAIL"
    result=1
	i=0
	while [ $i -lt $cycle -a $result -ne 0 ]; do
	    nslookup $url $dutip | grep -5 $info 
	    result=$?
	    i=$[i+1]
	sleep 5
    done
    
    if [ $result != 0 ]; then
	echo "Failed:resolution success"
	exit 1 
    else
	echo "Success:resolution failed"
	exit 0 
    fi       
fi

