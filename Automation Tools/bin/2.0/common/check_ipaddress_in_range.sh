#! /bin/bash
#---------------------------------
#
#--------------------------------
# Author        :   Tom(caipenghao)
# Description   :
#   this script is to check the ip in logfile(ifconfig eth) is in the range of the json logfile or dhcp config file.
#   check_ipaddress_in_range.sh -j jsonfile -l logfile to check with the jsonfile 
#   check_ipaddress_in_range.sh -c dhcp_config_file -l logfile to check with the dhcp config file
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | Tom       | Inital Version       
#

REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV

echo "${REV}"


if [ $# -eq 0 ]
    then
	echo "check_ipaddress_in_range.sh -l logaddress -h help -c configfile -j jsonfile"
	exit 1
fi

while [ $# -gt 0 ]
do
    case "$1" in
    
    -h)
	echo "check_ipaddress_in_range.sh -l logaddress -h help -c configfile -j jsonfile"
	exit 1
	;;
    -l)
	logadr=$2
	shift
	shift
	;;
    -c)
	configfile=$2
	shift
	shift
	;;
    -j)
	jsonfile=$2
	shift
	shift
	;;
    *)
	echo "check_ipaddress_in_range.sh -l logaddress -h help -c configfile -j jsonfile"
	exit 1
	;;
    esac       
done


if [ -z $jsonfile ]; then
	ip_min=`grep range $configfile | awk '{print $2}' | awk -F. '{print $4}'`
    ip_tmp=`grep range $configfile | awk '{print $3}' | awk -F. '{print $4}'`
    ip_max=`echo ${ip_tmp%;}`
    ip=`grep "inet addr" $logadr | awk '{print $2}' | awk -F: '{print $2}' | awk -F. '{print $4}'`
	echo "$ip $ip_min $ip_max"
    if [ "$ip" -ge "$ip_min" ]; then
        if [ "$ip" -le "$ip_max" ]; then
            echo -e " ipaddress is in the range! "
        	exit 0
        else
            echo -e " AT_ERROR : ipaddress is NOT in the range! "
            exit 1
        fi
    else
        echo -e " AT_ERROR : ipaddress is NOT in the range! "
        exit 1
    fi
else
	ip_tmp=`grep "Start IP Address" $jsonfile | awk -F: '{print $2}' | awk -F. '{print $4}'`
	ip_min=`echo ${ip_tmp%\"*}`
    ip_tmp=`grep "End IP Address" $jsonfile | awk -F: '{print $2}' | awk -F. '{print $4}'`
    ip_max=`echo ${ip_tmp%\"*}`
    ip=`grep "inet addr" $logadr | awk '{print $2}' | awk -F: '{print $2}' | awk -F. '{print $4}'`
	echo "$ip $ip_min $ip_max"
    if [ "$ip" -ge "$ip_min" ]; then
        if [ "$ip" -le "$ip_max" ]; then 
            echo -e " ipaddress is in the range! "
        	exit 0
        else
            echo -e " AT_ERROR : ipaddress is NOT in the range! "
            exit 1
        fi
    else
        echo -e " AT_ERROR : ipaddress is NOT in the range! "
        exit 1
    fi
fi
