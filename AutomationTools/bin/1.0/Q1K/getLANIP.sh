#!/bin/bash
usage="getLANIP.sh -i <target interface>"
while [ -n "$1" ];
do
    case "$1" in

   -i)
        interface=$2
        shift 2
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done

ipaddr=`ifconfig|grep -A 1 $interface|tail -1|grep -o 'addr:[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}'|grep -o '[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}'`
#if [  $ipaddr -ne 0 ]; then
#    echo "found it"
    echo $ipaddr
#else
#    echo "sorry"
#fi
