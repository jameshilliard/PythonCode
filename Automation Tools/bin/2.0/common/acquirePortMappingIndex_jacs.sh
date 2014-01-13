#!/bin/bash
# Author        :   
# Description   :
#   
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   |           | Inital Version       
#

REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV

echo "${REV}"

usage="Usage: acquirePortMappingIndex.sh -i <input file> -o <output file> [-h]"

while getopts ":i:o:h" opt ;
do
	case $opt in
		i)
	        input=$OPTARG
			;;

		o)
			output=$OPTARG
			;;

		h)
			echo -e $usage
			exit 0
			;;

		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo $usage
			exit 1
	esac
done

if [ -z $input ]; then
	echo "WARN: Please assign the input file"
	echo $usage
	exit 1
fi

if [ -z $output ]; then
	echo "WARN: Please assign the output file"
	echo $usage
	exit 1
fi
#   <InstanceNumber>3</InstanceNumber>
#   echo "<InstanceNumber>3</InstanceNumber>" |grep -o "InstanceNumber\>[0-9]\{1,\}" |sed "s/InstanceNumber\>//g"
#Node=$U_TR069_DEFAULT_CONNECTION_SERVICE.PortMapping.
mapping_index=`cat $G_CURRENTLOG/$input |grep -o "InstanceNumber>[0-9]\{1,\}"|sed "s/InstanceNumber>//g"`

echo "U_TR069_PORT_MAPPING_INDEX=$mapping_index" > $G_CURRENTLOG/$output

#awk -F. '{print "U_TR069_PORT_MAPPING_INDEX=" $offset}' offset=`echo $Node | awk -F. '{print NF}'` $G_CURRENTLOG/$input | sort -t "=" -nu -k 2.1 | tail -1 > $G_CURRENTLOG/$output
