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
    -t)
        waittimes=$2
        echo "testtimes : ${waittimes}"
        shift 2
        ;;
    *)
        echo "verifyDUTping.sh -f <configFile> -i <interface> -t <waittimes>"
        exit 1
        ;;
    esac
done


echo "dhclient -r ${interface}"
dhclient -r ${interface}


count=1
echo ${count}
result=" "


while [ -n "${result}" ] && [ ${count} -le ${waittimes} ]
do
    echo "ifconfig ${interface} down"
    ifconfig ${interface} down
    
    echo "ifconfig ${interface} up"
    ifconfig ${interface} up
    
    echo "wpa_cli terminate"
    wpa_cli terminate
    
    echo "wpa_supplicant -c ${file} -i ${interface} -B"
    wpa_supplicant -c ${file} -i ${interface} -B

    sleep 5
    count=$((${count}+1))
    echo ${count}
    if [ ${count} -gt ${waittimes} ] ; then
        echo "timeout"
        exit 1
    fi
    result=`iwconfig ${interface} | grep "Not-Associated"`
    echo ${result}
done

echo "dhclient ${interface}"
dhclient ${interface}

echo "ifconfig ${interface}"
ifconfig ${interface}

echo "iwconfig ${interface}"
iwconfig ${interface}

exit 0
