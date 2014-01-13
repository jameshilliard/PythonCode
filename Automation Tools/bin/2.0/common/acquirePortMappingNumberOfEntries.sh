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

usage="Usage: acquirePortMappingNumberOfEntries.sh -i <input file> -o <output file> [-h]"

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

awk '{print "TMP_TR069_PORT_MAPPING_NUMBER_OF_ENTRIES=" $3}' $G_CURRENTLOG/$input | tee $G_CURRENTLOG/$output
