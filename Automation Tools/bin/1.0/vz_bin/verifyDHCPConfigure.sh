#!/bin/sh
# Author:	Aleon
# Description: 	This script is used to compare the value is correct with expect value.
# Date: 	2010.07.26
#--------------------------------

while [ $# -gt 0 ]
do
    case $1 in

    -f)
	file=$2
	echo "File is : $file"
	shift 2
	;;
    -e)
	expect=$2
	echo "Expect value is : $expect "
	shift 2
	;;
    -h)
	echo "VerifyDHCPConfigure.sh -f <file> -e <value> -h <help>"
	exit 1
	;;
	
    esac
done

value=`cat $file |grep configurable | awk -F '(' '{print $3}' | awk -F ')' '{print $1}'`

echo $value

if [ $value == $expect ] ;then
    echo "--------------------------------------------"
    echo "PASS: The configuration of DHCP status match with setting;"
    echo "--------------------------------------------"
    exit 0
else
    echo "--------------------------------------------\n"
    echo "FAIL: The configuration of DHCP status do not match with setting;\n"
    echo "--------------------------------------------\n"
    exit 1
fi

