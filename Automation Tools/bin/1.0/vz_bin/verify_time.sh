#!/bin/bash -w
#---------------------------------
# Name: Tom(caipenghao)
# Description: 
# This script is used to set the environment from verify the time get and set 
# usage verify_time.sh -j time_json_file -f time_get_use_system_date -offset time_offset
#
#--------------------------------
while [ $# -gt 0 ]
do
    case "$1" in
    
    -j)
	json_file=$2
	shift
	shift
	;;
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

if [ "$json_file" = "NOW" ] ;then
#compare dut's system time with the pc1's time now,the max err is 10 hours,check for the sync    
    json_year=`date -u | awk '{print $6}'`
    json_mon=`date -u  | awk '{print $2}'`
    json_day=`date -u  | awk '{print $3}'`
    json_hour=`date -u | awk '{print $4}' |  awk -F: '{print $1}'`
    json_min=`date -u  | awk '{print $4}' |  awk -F: '{print $2}'`
    MAXERR=600
else
#compare dut's system time with the setting json file    
    json_year=`cat $json_file | grep "year" | awk -F\" '{print $4}'`
    json_mon=`cat $json_file | grep "month" | awk -F\" '{print $4}'`
    json_day=`cat $json_file | grep "day" | awk -F\" '{print $4}'`
    json_hour=`cat $json_file | grep "hour" | awk -F\" '{print $4}'`
    json_min=`cat $json_file | grep "minute" | awk -F\" '{print $4}'`
    MAXERR=10
fi

echo "INFO: json setting: $json_year $json_mon $json_day $json_hour $json_min"
echo "INFO: dut system time : ${sys_year} $sys_mon $sys_day $sys_hour $sys_min"

if [ "$sys_year" != "$json_year" ] ; then
    exit 1
fi

if [ "$sys_mon" != "$json_mon" ] ; then
    exit 1
fi

declare -i day_diff

day_diff=`expr $sys_day - $json_day`
declare -i hour_diff
hour_diff=`expr $day_diff\*24`
declare -i real_offset
declare -i minute_diff
real_offset=`expr $sys_hour - $json_hour + $hour_diff - $time_offset`
minute_diff=`expr $real_offset\*60`
declare -i min_error
min_error=`expr $sys_min - $json_min + $minute_diff`

echo "time error is $min_error"

if [ $min_error -gt $MAXERR ] ; then
    exit 1
else
    if [ $min_error -lt $((0 - MAXERR)) ] ; then
	exit 1
    fi
fi

exit 0
