#!/bin/bash
#-----------------------------------
#Name:Adny
#this script is to check the default gateway is correct.
#-----------------------------------

if [ $# -eq 0 ] ;then
    echo "check_DNS.sh -p primatyDNS -s secondaryDNS"
    exit 1
fi

while [ $# -gt 0 ]
do
    case "$1" in
    -p)
        EDNS1=$2
        echo "DNS1 : $EDNS1"
        shift 2
        ;;
    -s)
        EDNS2=$2
        echo "DNS2 : $EDNS2"
        shift 2
        ;;
    esac
done

cat /etc/resolv.conf

if [ -n $EDNS1 ] && [ -n $EDNS2 ] ;then
    echo "==primaty DNS=="
	cat /etc/resolv.conf | grep $EDNS1
	if [ $? -eq 0 ] ;then
        echo "==secondray DNS=="
		cat /etc/resolv.conf | grep $EDNS2
		if [ $? -eq 0 ] ;then
			echo "DNS server's IP address list is correct."
			exit 0
		fi
	fi
fi

echo "DNS server's IP address list is worng."
exit 1
	
