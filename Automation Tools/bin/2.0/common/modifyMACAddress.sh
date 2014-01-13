#!/bin/bash
#---------------------------------
# Author        :   
# Description   :
#   This tool is using to used to modify MAC address.
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#14 Feb 2012    |   1.0.0   | Andy      | Inital Version

REV="$0 version 1.0.0 (14 Feb 2012)"
echo "${REV}"


usage="Usage: $0 -i <interface> -m <mac address> -o <ouput file> [-h]\nexpample:\n$0 -i eth1 -m 00:19:E0:0A:6D:17 -o mac_address.log\n"

while getopts ":i:m:o:h" opt ;
do
    case $opt in
        i)
            interface=$OPTARG
            echo "Interface : ${interface}"
            ;;
        m)
            macaddress=$OPTARG
            echo "new mac address : ${macaddress}"
            ;;
        o)
            output=$OPTARG
            echo "ouputfile : ${output}"
            ;;
        h)
            echo -e $usage
            exit 0
            ;;
        t)
            G_CURRENTLOG=/root/temp
            ;;

        ?)
            paralist=-1
            echo "AT_ERROT : '-$OPTARG' not supported."
            echo -e $usage
            exit 1
    esac
done

if [ -z "$interface" ] ;then
    echo -e " AT_ERROR : Please assign the interface "
    exit 1
fi

if [ -z "$output" ] ;then
    output=$G_CURRENTLOG/$0.log
    echo "ouputfile : ${output}"
fi

if [ -z "$macaddress" ] ;then
    macaddress="00:00:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4/')"
    echo "random mac address : ${macaddress}"
fi

echo "ifconfig $interface"
ifconfig $interface
if [ $? -ne 0 ] ;then
    echo "AT_ERROR : Device $interface not found."
    exit 1
fi

echo "ip -4 addr flush dev $interface"
ip -4 addr flush dev $interface
if [ $? -ne 0 ] ;then
    echo "AT_ERROR : Device $interface can not shut down."
    exit 1
fi

echo "ip link set $interface down"
ip link set $interface down

echo "ifconfig $interface hw ether $macaddress"
ifconfig $interface hw ether $macaddress
if [ $? -ne 0 ] ;then
    echo "AT_ERROR : Modify device $interface MAC address error."
    exit 1
fi

echo "ip link set $interface up"
ip link set $interface up

echo "ifconfig $interface"
ifconfig $interface

echo "TMP_RANDOM_MACADDRESS=$macaddress" > $output

exit 0
