#!/bin/bash

# Author        :   
# Description   :
#   This tool is using 
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   |           | Inital Version       
#22 Nov 2011    |   1.0.1   |  andy     | Manual team want to set number Of Objects by variable,if sometime they want to do.
#23 Nov 2011    |   1.0.2   |  andy     | fix <Failed> ouput BUG,test on CEPInfo 002-004.

REV="$0 version 1.0.2 (23 Nov 2011)"
# print REV

echo "${REV}"

usage="Usage: checkNumberOfObjectX.sh -n <Node of Entries> -i <GPV log> [-c <number Of Objects >] [-h]\nexpample: checkNumberOfObjectEX.sh -n PortMappingNumberOfEntries -c 1 -i GPV_B-GEN-TR98-BA.PFO-001-RPC-001_output.log\n"

#defaults
numberOfObject=-1

while getopts ":n:i:c:th" opt ;
do
	case $opt in
		i)
			GPVfile=$OPTARG
			;;
        n)
			node=$OPTARG
			;;
        c)
            numberOfObject=$OPTARG
            ;;
		h)
			echo -e $usage
			exit 0
			;;
        t)
            G_CURRENTLOG=/root/automation/logs/current/B-GEN-TR98-CPE.INFO-002.xml_1_FAILED
            ;;
		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo -e $usage
			exit 1
	esac
done

if [ -z "$GPVfile" ]; then
    echo -e "WARN: Please assign the GPV log"
	echo $usage
	exit 1
fi

if [ -z "$node" ]; then
    echo -e "WARN: Please assign the node of NumberOfEntries"
	echo $usage
	exit 1
fi

numberOfEnties=`grep "$node" $G_CURRENTLOG/$GPVfile | awk '{print $3}'`

numberOfFields=`grep "$node" $G_CURRENTLOG/$GPVfile | awk '{print $1}' | awk -F . '{print NF+1}'`

grep -v "$node" $G_CURRENTLOG/$GPVfile > $G_CURRENTLOG/${GPVfile}.tmp

if [ $numberOfObject -lt 0 ] ;then
    numberOfObject=`cut -d . -f 1-$numberOfFields $G_CURRENTLOG/${GPVfile}.tmp | sort -t . -unk $numberOfFields | wc -l`
fi

if [ $numberOfEnties -eq $numberOfObject ]; then
    echo "PASS:the Number Of Entries($numberOfEnties) is equal to the number of objects($numberOfObject)"
    exit 0
else
    echo -e "FAILED:the Number Of Entries($numberOfEnties) is not equal to the number of objects($numberOfObject)"
	exit 1
fi
