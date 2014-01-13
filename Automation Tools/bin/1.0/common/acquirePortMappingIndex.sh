#!/bin/bash

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

Node=$U_TR069_DEFAULT_CONNECTION_SERVICE.PortMapping.

awk -F. '{print "U_TR069_PORT_MAPPING_INDEX=" $offset}' offset=`echo $Node | awk -F. '{print NF}'` $G_CURRENTLOG/$input | sort -t "=" -nu -k 2.1 | tail -1 > $G_CURRENTLOG/$output
