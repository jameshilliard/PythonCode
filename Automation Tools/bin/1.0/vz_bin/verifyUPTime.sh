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
        word=$2
	echo "THe key work is $word"
        shift 2
        ;;
    -v)
        value=$2
	echo "Expect value is $value"
        shift 2
        ;;
    *)
        echo "motiveValueGrep.sh -v compareValue -n keyWord -f inputFile"
        exit 1
        ;;
    esac
done

# Get expect value.
#expect=`cat $file  |grep "$word" | awk \'list=$2; {split(list,myarray,\"\<|\>\")}; {print myarray[2]}\'`
expect=`cat $file  |grep "$word" | awk '{split($0,myarray,"<|>")}; {print myarray[3]}'`
echo "------------"
echo file= $file
echo keyWord = $word
echo "get value is: $expect "
echo "------------"

if [ $expect > $value ] ;then
    echo "------------------------------\n"
    echo "PASS: It is successful to testing!\n"
    echo "------------------------------\n"
    exit 0
else
    echo "------------------------------\n"
    echo "FAIL: It is failure to testing!\n"
    echo "------------------------------\n"
    exit 1
fi

echo "Fail: Special Condition"
exit 1

