#!/bin/bash
#-----------------------------------
#Name:Adny
#this script is to the restore ip,gw,DNS after lanch dhclient .
#-----------------------------------

if [ $# -eq 0 ] ;then
    echo "restore_dhcp.sh  -i interface -d IPaddress -p DNS1 -s DNS2 -g default_gateway -f default_interface"
    exit 1
fi

while [ $# -gt 0 ]
do
    case "$1" in
    -i)
        Interface=$2
        echo "Interface : $Interface"
        shift 2
        ;;
    -d)
        IPaddress=$2
        echo "IPaddress : $IPaddress"
        shift 2
        ;;
     -p)
        DNS1=$2
        echo "DNS1 : $DNS1"
        shift 2
        ;;
    -s)
        DNS2=$2
        echo "DNS2 : $DNS2"
        shift 2
        ;;
     -g)
        GW=$2
        echo "default GW : $GW"
        shift 2
        ;;
    -f)
        IF=$2
        echo "default interface : $IF"
        shift 2
        ;;
    esac
done

if [ -n $Interface ] && [ -n $IPaddress ] && [ -n $DNS1 ] && [ -n $DNS2 ] && [ -n $GW ] && [ -n $IF ] ;then
	ifconfig $Interface down
	ifconfig $Interface $IPaddress/24 up
	sleep 5;
	rm /etc/resolv.conf -f
	echo "nameserver $DNS1" >> /etc/resolv.conf
	echo "nameserver $DNS2" >> /etc/resolv.conf
	route del default
	sleep 1;
	route add default gw $GW dev $IF
	route -n
	exit 0
fi

echo "restore_dhcp.sh  -i interface -d IPaddress -p DNS1 -s DNS2 -g default_gateway -f default_interface"
exit 1
