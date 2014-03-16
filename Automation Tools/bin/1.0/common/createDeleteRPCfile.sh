#!/bin/bash

usage="Usage: creatDeleteRPCfile.sh -i <input file> -o <output file> [-h]"

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

grep -o $U_TR069_DEFAULT_CONNECTION_SERVICE.PortMapping.[0-9]*. $G_CURRENTLOG/$input | sort -t "." -nu -k 9.1 | tee $G_CURRENTLOG/$output

exit 0
