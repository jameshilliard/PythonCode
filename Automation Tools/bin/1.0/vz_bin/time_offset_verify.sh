#!/bin/bash -w
#---------------------------------
# Name: Tom(caipenghao)
# Description: 
# This script is used to set the environment from verify the time get and set 
# usage time_offset_verify.sh  -f time_get_use_system_date -offset time_offset
#
#--------------------------------
while [ $# -gt 0 ]
do
    case "$1" in
    -f)
	time_file=$2
	shift
	shift
	;;
    -offset)
	declare -i time_offset
	time_offset=$2
	shift
	shift
	;;
    esac       
done
sed -i "s///g" $time_file
sys_mon=`cat $time_file | grep "Local time" | awk '{print $4}'`
sys_day=`cat $time_file | grep "Local time" | awk '{print $5}'`
sys_hour=`cat $time_file | grep "Local time" | awk '{print $6}' | awk -F: '{print $1}'`
sys_min=`cat $time_file | grep "Local time" | awk '{print $6}' | awk -F: '{print $2}'`
sys_year=`cat $time_file | grep "Local time" | awk '{print $7}'`

UTC_mon=`cat $time_file | grep "UTC   time" | awk '{print $4}'`
UTC_day=`cat $time_file | grep "UTC   time" | awk '{print $5}'`
UTC_hour=`cat $time_file | grep "UTC   time" | awk '{print $6}' | awk -F: '{print $1}'`
UTC_min=`cat $time_file | grep "UTC   time" | awk '{print $6}' | awk -F: '{print $2}'`
UTC_year=`cat $time_file | grep "UTC   time" | awk '{print $7}'`

echo "UTC : $UTC_year $UTC_mon $UTC_day $UTC_hour $UTC_min"
echo "sys : ${sys_year} $sys_mon $sys_day $sys_hour $sys_min"

if [ "$sys_year" != "$UTC_year" ] ; then
    exit 1
fi

if [ "$sys_mon" != "$UTC_mon" ] ; then
    exit 1
fi

declare -i day_diff

day_diff=`expr $sys_day - $UTC_day`
declare -i hour_diff
hour_diff=`expr $day_diff\*24`
echo $hour_diff
declare -i real_offset

real_offset=`expr $sys_hour - $UTC_hour + $hour_diff`
if [ $real_offset -ne $time_offset ] ; then
    exit 1
fi

declare -i min_error
min_error=`expr $sys_min - $UTC_min`

if [ $min_error -gt 10 ] ; then
    exit 1
fi

exit 0
