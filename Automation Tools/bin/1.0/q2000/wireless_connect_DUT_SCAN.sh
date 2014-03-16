#!/bin/bash -w
#---------------------------------
# Name: Andy
# Description: 
# This script is used to config a wireless client connect DUT.
#
#--------------------------------
while [ $# -gt 0 ]
do
    case "$1" in

    -f)
        file=$2
	    echo "Config file : ${file}"
        shift 2
        ;;
    -i)
        interface=$2
        echo "Interface : ${interface}"
        shift 2
        ;;
    -s)
        ssid=$2
        #echo "ssid : ${ssid}"
        shift 2
        ;;
    *)
        echo "wireless_connect_DUT_SCAN.sh [-s ssidName] -f <configFile> -i <interface>"
        exit 1
        ;;
    esac
done

result=''
count1=1
count2=1

if [ -z "${ssid}" ]; then
    retryCount=1
else
    retryCount=3
fi

echo "dhclient -r ${interface}"
dhclient -r ${interface}

while [ -z "${result}" ] && [ ${count1} -le ${retryCount} ] && [ -z "${status_result}" ]
do
    count2=1
    echo "${count1}"
    count1=$((${count1}+1))

    echo "ifconfig ${interface} down"
    ifconfig ${interface} down

    sleep 2
    if [ -z "${ssid}" ]; then
        echo "wpa_cli terminate"
        wpa_cli terminate
   
        sleep 2
        echo "ifconfig ${interface} up"
        ifconfig ${interface} up
    else
        echo "ifconfig ${interface} up"
        ifconfig ${interface} up

        echo "wpa_cli terminate"
        wpa_cli terminate

        rm -rf /var/run/wpa_supplicant/wlan0
    fi   

    sleep 2

    echo "ifconfig ${interface} up"
    ifconfig ${interface} up

    echo "wpa_supplicant -c ${file} -i ${interface} -B"
    wpa_supplicant -c ${file} -i ${interface} -B

    if [ -n "${ssid}" ]; then
        sleep 5
    fi

    while [ -z "${result}" ] && [ ${count2} -le ${retryCount} ] && [ -z "${status_result}" ]
    do

        echo "$((${count1}-1)).${count2}"
        count2=$((${count2}+1))

        echo "wpa_cli scan"
        wpa_cli scan

        sleep 20

        ##################
	    echo "wpa_cli status"
	    wpa_cli status

        status_result=`wpa_cli status | grep "ssid=${ssid}"`

	    echo "wpa_cli scan_results"
	    wpa_cli scan_results

        result=`wpa_cli scan_results | grep "${ssid}"`

        #################

    done
done

if [ -n "${ssid}" ]; then
    echo "${result}"
fi

echo "wpa_cli status"
wpa_cli status

echo "wpa_cli scan_results"
wpa_cli scan_results

exit 0
