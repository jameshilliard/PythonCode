#!/bin/bash -w
#---------------------------------
# Name: Howard Yin
# Description: 
# This script is used to connect a wireless adapter to DUT.
#
#--------------------------------
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version       
#

REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV
echo "${REV}"

nega=0

while [ $# -gt 0 ]
do
    case "$1" in
    -n)
        nega=1
        echo "nega mode engaged!"
        shift 1
        ;;
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
    -ip)
        address=$2
        echo "ipaddress used in static"
        shift 2
        ;;
    -H)
        hostname=$2
        echo "dhclient host name is ${hostname}"
        shift 2
        ;;
    -test)
        echo "engaged test mode"
        G_PROD_IP_BR0_0_0=192.168.0.1
        shift 1
        ;;

    *)
    echo "bash $0 -f <configFile> -i <interface> -t <waittimes> -ip <ipaddress for static> -H <hostname>"
        exit 1
        ;;
    esac
done

count=1

sleep_time=10

echo "wpa_cli terminate"

wpa_cli terminate -i $interface

echo "ifconfig $interface down"

ifconfig $interface down

echo "dhclient -r"

dhclient -r

echo "ifconfig $interface up"

ifconfig $interface up

echo "wpa_supplicant -c ${file} -i ${interface} -B"

wpa_supplicant -c ${file} -i ${interface} -B

#  6. check wpa_supplicant status(wpa_cli status)
#  7. process in different status
#  7.1 ASSOCIATING
#  7.2 SCANNING
#  7.3 ASSOCIATED
#  7.4 DISCONNECTED
#  7.5 CONNECTING
#  7.6 COMPLETED
#   This means connection is completed
#   return 0 and exit 
#  8. loop step 6,7 more times (10 times)

add_default_route(){
    echo "route del default;route add default gw $G_PROD_IP_BR0_0_0  dev ${interface}"
    route del default;route add default gw $G_PROD_IP_BR0_0_0  dev ${interface}

    echo "ifconfig ${interface}"
    ifconfig ${interface}

    echo "iwconfig ${interface}"
    iwconfig ${interface}

    echo "route -n"

    route -n

    #perl $U_PATH_TBIN/verifyPing.pl '-d' $U_CUSTOM_WAN_HOST '-I' ${interface} '-t' 60 '-o' ping.log '-l' $G_CURRENTLOG

    #if [ $nega -eq 0 ] ;then
    #    if [ $? -eq 0 ] ;then
    #        echo "ping WAN SITE passed !"
    #        exit 0
    #    else
    #        echo "ping WAN SITE failed !"
    #        exit 1
    #    fi
    #elif [ $nega -eq 1 ] ;then
    #    if [ $? -eq 0 ] ;then
    #        echo "ping WAN SITE passed !"
    #        exit 1
    #    else
    #        echo "ping WAN SITE failed !"
    #        exit 0
    #    fi
    #fi
}

do_connect(){
    if [ -z "$address" ] ;then
        if [ -z "$hostname" ] ;then
            echo "dhclient ${interface}"
            dhclient ${interface}
    
            ifconfig ${interface}|grep "inet addr"
            if [ $? -eq 0 ] ;then
                if [ $nega -eq 0 ] ;then
                    echo "posi test passed"
                    
                    add_default_route 
    
                    exit 0
    
                elif [ $nega -eq 1 ] ;then
                    echo "nega test failed"
    
                    add_default_route
    
                    exit 1
                fi
                   
            else
                if [ $nega -eq 0 ] ;then
                    echo "posi test failed"
    
                    exit 1
                elif [ $nega -eq 1 ] ;then
                    echo "nega test passed"
    
                    exit 0
                fi
            fi
        else
            echo "dhclient ${interface} -H ${hostname}"
            dhclient ${interface} '-H' ${hostname}
    
            ifconfig ${interface}|grep "inet addr"
            if [ $? -eq 0 ] ;then
                if [ $nega -eq 0 ] ;then
                    echo "posi test passed"
                    
                    add_default_route
    
                    exit 0
                elif [ $nega -eq 1 ] ;then
                    echo "nega test failed"
    
                    add_default_route
    
                    exit 1
                fi
            else
                if [ $nega -eq 0 ] ;then
                    echo "posi test failed"
    
                    exit 1
                elif [ $nega -eq 1 ] ;then
                    echo "nega test passed"
    
                    exit 0
                fi
            fi
        fi
        
    else
        ifconfig ${interface} ${address}/24 up
        echo "set ${interface} to static IP ${address}"
    
        add_default_route
    
        exit 0
    fi
}

while  [ ${count} -le ${waittimes} ]
do
    wpa_status=`wpa_cli status | grep "wpa_state"`

	if [ "${wpa_status}" == "wpa_state=COMPLETED" ] ; then
        echo "${wpa_status}"
        echo "connection OK"
        break
    elif [ "${wpa_status}" == "wpa_state=SCANNING" ] ; then
        echo "${wpa_status}"
		#wpa_cli scan_results
        echo "sleep $sleep_time"
        sleep $sleep_time
    elif [ "${wpa_status}" == "wpa_state=ASSOCIATING" ] ; then
        echo "${wpa_status}"
		#wpa_cli scan_results
        echo "sleep $sleep_time"
        sleep $sleep_time
    elif [ "${wpa_status}" == "wpa_state=ASSOCIATED" ] ; then
        echo "${wpa_status}"
		#wpa_cli scan_results
        echo "sleep $sleep_time"
        sleep $sleep_time
    elif [ "${wpa_status}" == "wpa_state=DISCONNECTED" ] ; then
        echo "${wpa_status}"
		#wpa_cli scan_results
        echo "sleep $sleep_time"
        sleep $sleep_time
    elif [ "${wpa_status}" == "wpa_state=CONNECTING" ] ; then
        echo "${wpa_status}"
		#wpa_cli scan_results
        echo "sleep $sleep_time"
        sleep $sleep_time
    else
        echo "${wpa_status}"
		#wpa_cli scan_results
        echo "sleep $sleep_time"
        sleep $sleep_time
	fi

	echo "try ${count} ..."

    count=$((${count}+1))
done



if [ "${wpa_status}" != "wpa_state=COMPLETED" ] ; then
    echo "connection timeout ! status is not completed !"

    do_connect
    #exit 1
else
    do_connect
fi



