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
    -v)
        value=$2
	echo "Expect value is $value"
        shift 2
        ;;
    *)
        echo "verifyDataTransRate.sh -v expectValue -n node -f inputFile"
        exit 1
        ;;
    esac
done

# Get expect value.
expect=`cat $file | grep $node |awk '{print $9}' | tr -d '|'`
echo "------------"
echo file= $file
echo node = $node
echo $expect
echo "get value is: $expect "
echo "------------"

if [ $expect = $value ] ;then
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

