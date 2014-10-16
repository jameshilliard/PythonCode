#!/bin/bash -w
#---------------------------------
# Name: Tom(caipenghao)
# Description: 
# This script is used to check the port is open or not in the nmap log file 
#
#--------------------------------

while [ $# -gt 0 ]
do
    case "$1" in
    
    -f)
	file=$2
	shift 2
	;;
    -p)
	port=$2
	shift 2
	;;
    *)
	echo "nmap_check.sh -p port -f inputfile"
	exit 1
	;;
    esac       
done

status=`cat $file | grep ^${port}/ |  awk '{print $2}'`
echo "status of $port is $status"

if [ "$status" != "closed" ]; then
    exit 0
else
    exit 1
fi

