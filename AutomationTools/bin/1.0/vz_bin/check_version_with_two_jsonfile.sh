#!/bin/bash -w
#---------------------------------
# Name: Tom(caipenghao)
# Description: 
# This script is used to compare the version with system monitor json file and the upgrade from 
# internet's json file 
#
#
#--------------------------------

if [ $# -eq 0 ]
    then
	echo "check_version_with_two_jsonfile.sh -s <system monitor json file> -i <upgrade from internet json file> -l <logfile>"
	exit 1
fi

while [ $# -gt 0 ]
do
    case "$1" in
    -s)
	monitor_file=$2
	shift
	shift
	;;
    -i)
	internet_file=$2
	shift
	shift
	;;
    -l)
	log_file=$2
	shift
	shift
	;;
    *)
	echo "check_version_with_two_jsonfile.sh -s <system monitor json file> -i <upgrade from internet json file> -l <logfile>"
	exit 1
    esac       
done

if [ "$log_file" = "" ]
    then
	log_file=$G_CURRENTLOG/version_compare.log
fi

version=`grep "Firmware Version" $monitor_file | awk -F\" '{print $4}'`
if [ "$version" = "" ]
    then
	version="not find the version information"
fi

grep "$version" $internet_file
if [ $? = 0 ]; then
    echo "version find in system monitor file is $version,and is same with in the upgrade from internet json file" >$log_file
    exit 0
else
    echo "version find in system monitor file is $version,and is different with in the upgrade from internet json file" >$log_file
    exit 1
fi
