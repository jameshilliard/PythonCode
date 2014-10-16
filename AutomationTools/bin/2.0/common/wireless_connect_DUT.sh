#!/bin/bash -w
#---------------------------------
# Name: Andy
# Description: 
# This script is used to config a wireless client connect DUT.
#
#--------------------------------
# History       :
#   DATE        |   REV     | AUTH      | INFO
# 1 Nov 2011    |   1.0.0   | rayofox   | Inital Version       
# 9 Jan 2012    |   1.0.1   | Alex      | modified the option of command 'dhclient',add '-pf' option


REV="$0 version 1.0.1 ( 9 Jan 2012)"

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
    *)
    echo "wireless_connect_DUT.sh -f <configFile> -i <interface> -t <waittimes> -ip <ipaddress for static> -H <hostname>"
        exit 1
        ;;
    esac
done


#echo "dhclient -r ${interface}"
#rm -f /tmp/$interface.dhclog
#dhclient -r ${interface}
    
count=1
result=" "

dhcpcReleased=0

# 
route del default

while  [ ${count} -le ${waittimes} ]
do
	if [ "${result}" == "wpa_state=COMPLETED" ] ; then
		if [ ${dhcpcReleased} -eq 0    ] ;then
            ps aux|grep dhclient|grep ${interface}|grep -o "dhclient .*"|sed "s/dhclient/dhclient -r/g" |while read cmd
            do
                echo "command :$cmd"
                $cmd
            done
			dhcpcReleased=1
			count=1
		else 
			break
		fi
	fi

	if [ "${result}" == "wpa_state=SCANNING" ] ; then
		wpa_cli scan_results
	fi
	echo ${count}
    count=$((${count}+1))
    
    # down wlan
    #echo "ip link set ${interface} down"
    #ip addr del dev ${interface}
    #ip link set ${interface} down

    sleep 2
    echo "wpa_cli terminate"
    wpa_cli terminate -i $interface
    
    #sleep 2
    #echo "ip link set ${interface} up"
    #ip link set ${interface} up

    sleep 2
    echo "wpa_supplicant -c ${file} -i ${interface} -B"
    wpa_supplicant -c ${file} -i ${interface} -B

    sleep 15
    
    #result=`iwconfig ${interface} | grep "Not-Associated"`
    echo "wpa_cli status"
    result=`wpa_cli status`
    
    echo ${result}
    ##################

    result=`wpa_cli status | grep "wpa_state"`

    #################
	
    
    echo ${result}
done

#if [ ${count} -gt ${waittimes} ] ; then
if [ "${result}" != "wpa_state=COMPLETED" ] ; then
    echo "timeout"
    #exit 1
fi

if [ -z "$address" ] ;then
    echo "rm -f /tmp/${interface}.pid"
    rm -f /tmp/${interface}.pid
    if [ -z "$hostname" ] ;then
#        echo "dhclient ${interface} -pf ${interface}"
#        dhclient ${interface} '-pf' /tmp/$interface.dhclog
        echo "dhclient ${interface} -pf /tmp/${interface}.pid"
        dhclient ${interface} -pf /tmp/${interface}.pid
    else
#        echo "dhclient ${interface} -pf -H ${hostname} ${interface}"
#        dhclient ${interface} '-H' ${hostname} '-pf' /tmp/$interface.dhclog
        echo "dhclient ${interface} -H ${hostname} -pf /tmp/${interface}.pid"
        dhclient ${interface} '-H' ${hostname} -pf /tmp/${interface}.pid
    fi
    
else
    ip link set ${interface} up
    ip addr add ${address}/24 dev ${interface}
fi


echo "ifconfig ${interface}"
ifconfig ${interface}

echo "iwconfig ${interface}"
iwconfig ${interface}

echo "route del default;route add default gw $G_PROD_GW_BR0_0_0 dev ${interface} ;route -n;"
route del default;route add default gw $G_PROD_GW_BR0_0_0  dev ${interface} ;route -n;

exit 0
