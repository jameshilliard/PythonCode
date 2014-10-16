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

usage="Usage: checkCurrentConnectionType.sh -e <expect> [-h]\nexpample:\ncheckCurrentConnectionType.sh -e WANIPConnection\t#\n"

while getopts ":e:h" opt ;
do
	case $opt in
		e)
	        expect=$OPTARG
			;;

		h)
			echo -e $usage
			exit 0
			;;

		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo -e $usage
			exit 1
	esac
done

comment="# ----------------------- #"

if [ -z $expect ]; then
    echo -e " WARN: Please assign the expect WAN connection typ "
	echo $usage
	exit 1
fi

echo $U_TR069_DEFAULT_CONNECTION_SERVICE | grep $expect
if [ $? -eq 0 ]; then
	echo $comment
	echo "PASSED : current connection type is $expect"
	echo $comment
	exit 0
else
	echo $comment
    echo -e " FAILED : current connection type is NOT $expect "
	echo $comment
	exit 1
fi
