#!/bin/bash -w
#---------------------------------
# Name: Andy
# Description: 
# This script is used to get IP with dhclient.
#
#--------------------------------
#G_CURRENTLOG=/root/automation/logs/logs140/B-GEN-TR98-BA.LANIPINTFA-004.xml_3
createlogname(){
    lognamex=$1
    echo "ls $G_CURRENTLOG/$lognamex*"
    ls $G_CURRENTLOG/$lognamex* 2> /dev/null
    if [  $? -gt 0 ]; then
        echo "file not exists"
        echo -e "\033[33m so the current file to be created is : "$lognamex"\033[0m"
        currlogfilename=$lognamex
    else
        echo "file exists"
        curr=`ls $G_CURRENTLOG/$lognamex*|wc -l`
        let "next=$curr"
        echo -e "\033[33m so the current file to be created is : "${lognamex}_$next"\033[0m"
        currlogfilename="${lognamex}_$next"
    fi
}

while [ -n "$1" ];
do
    case "$1" in

    -i)
        interface=$2
        echo "Interface : ${interface}"
        shift 2
        ;;
    -o)
        output=$2
        echo "ouputfile : ${output}"
        shift 2
        ;;
    *)
        echo "get_dhcp_IP.sh -i <interface>"
        exit 1
        ;;
    esac
done

if [ -z "$interface" ]; then
    echo -e "\033[33m WARN: Please assign the interface \033[0m"
    exit 1
fi

rm -f /tmp/dhclient_${interface}.pid
rm -f /tmp/dhclient_${interface}.leases
createlogname dhclient_${interface}.leases
leasesfile=/tmp/$currlogfilename
createlogname dhclient_${interface}.pid
pidfile=/tmp/$currlogfilename

#rm -f $pidfile
echo "dhclient -r $interface"
dhclient -r $interface
echo "dhclient -lf $leasesfile -pf $pidfile $interface"
dhclient -lf $leasesfile -pf $pidfile $interface
ifconfig $interface
route -n

if [ -n "$output" ]; then
    echo "output mode!"
    ifconfig $interface | grep -o 'inet addr[^ ]*' | awk -F : '{print "TMP_TR069_LANDHCP_DHCP_IP=" $2}' | tee $G_CURRENTLOG/$output
fi

exit 0

