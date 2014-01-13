#!/bin/bash -w
#---------------------------------
# Name: Tom(caipenghao)
# Description: 
# This script is used to compare the system monitor log is change or not
#
#--------------------------------

while [ $# -gt 0 ]
do
    case "$1" in
    
    -f)
	file=$2
	shift 2
	;;
    -l)
	logdir=$2
	shift 2
	;;
    *)
	echo "active_status_compare.sh -l logaddress -f inputfile"
	exit 1
	;;
    esac       
done

status_before=`grep "Active Status" $file | awk -F\" 'NR==1 {print $4}'`
status_after=`grep "Active Status" $file | awk -F\" 'NR==2 {print $4}'`

if ["status_before" = "" ];then
    echo "No status found in  the file" > $logdir
fi

if [ "$status_before" = "$status_after" ]; then
    echo "The status is same between two time point" > $logdir
else
    echo "The status is different between two time point" > $logdir
fi
