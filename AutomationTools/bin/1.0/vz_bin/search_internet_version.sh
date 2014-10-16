#!/bin/bash -w
#---------------------------------
# Name: Tom(caipenghao)
# Description: 
# This script is used to search the information of the internet versions and the connect status 
#
#
#--------------------------------

grep "Status: OK" $1
result=$?
grep "Internet Version: New Wireless Broadband Router version" $1
result=`expr $result \+ $?`
if [ $result = 0 ]; then
    echo "New version available and connection status Ok"
    exit 0
else
    exit 1
fi
