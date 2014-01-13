#!/bin/sh -w
#---------------------------------
# Name: Aleon
# Description: 
# This script is used to compare the value is right with expect value.
#
#--------------------------------

while [ $# -gt 0 ]
do
    case "$1" in

    -f)
        file=$2
	echo "File is :$file"
        shift 2
        ;;
    -n)
        node=$2
	echo "THe node is $node"
        shift 2
        ;;
    *)
        echo "verifyAutoChannel.sh  -n desc -f inputFile"
        exit 1
        ;;
    esac
done

# Get expect value.
echo "------------"
echo file= $file
echo node = $node
echo "------------"
expect=`cat $file | grep $node |awk '{print $0~/\|[0-9]+\|/ }'`

if [ $expect == 1 ];then
    echo "------------------------------\n"
    echo "PASS: Got the expect value!\n"
    echo "------------------------------\n"
    exit 0
else
    echo "------------------------------\n"
    echo "FAIL: Can't get the expect value!\n"
    echo "------------------------------\n"
    exit 1
fi

echo "Fail: Special Condition"
exit 1

