#!/bin/bash

#---------------------------------
# Name: Howard Yin
# Description:
# This script is used to
#
#--------------------------------
# History    :
#   DATE        |   REV  | AUTH   | INFO
#03 May 2012    |   1.0.0   | Howard    | Inital Version

#   U_PATH_TBIN=$G_SQAROOT/bin/$G_BINVERSION/$U_DUT_TYPE

if [ -z $U_PATH_TBIN ] ;then
    source resolve_CONFIG_LOAD.sh
else
    source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh
fi

REV="$0 version 1.0.0 (03 May 2012)"
# print REV
echo "${REV}"

#input:
#    -d <dest ip address>
#    -p <port to scan>
#    -u :scan udp port,default scan tcp port if not defined
#    -f <output to file>

#is_udp=0

while [ $# -gt 0 ]
do
    case "$1" in
    -d)
        dest=$2
        echo "  to scan ${dest}"
        shift 2
        ;;
    -i)
        index=$2
        echo " index of being used by case ${index}"
        shift 2
        ;;
    -p)
        port=$2
        echo "  port to scan ${port}"
        shift 2
        ;;
    -u)
        is_udp=1
        echo "  to scan udp ports"
        shift 1
        ;;
    -f)
        output=$2
        echo "  output to ${output}"
        shift 2
        ;;
    -6)
        is_ipv6=1
        echo "  to scan ipv6 ports"
        shift 1
        ;;
    *)
        echo ".."
        exit 1
        ;;
    esac
done

if [ -z $index ] ;then
    index=1
fi

if [ -z $output ] ;then
    output=$G_CURRENTLOG/nmap_${index}.log
fi

#   traffic_type="in/out"
#   scan_port1=
#   scan_port2=

if [ -z $dest ] ;then
    if [ "$traffic_type" == "in" ] ;then
        dest=$G_HOST_TIP0_1_0
    elif [ "$traffic_type" == "out" ] ;then
        dest=$TMP_DUT_DEF_GW
    else
        echo "AT_ERROR : traffic_type ${traffic_type} error"
        exit 1
    fi
fi

scan_port="scan_port"$index

if [ -z $port ] ;then
    port=`eval echo '$'{$scan_port}`
fi

WAN_scan(){
    echo "in function WAN_scan() ..."

    if [ -z "$is_ipv6" ] ;then
        echo "do ipv4 scan"
        if [ -z $is_udp ] ;then
            echo "do TCP port scan"

            perl $U_PATH_TBIN/sshcli.pl -t 3600 -l $G_CURRENTLOG -o $G_CURRENTLOG/remote_nmap_${index}.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "nmap -p $port -T4 --min-rate 300 -d2 -v $dest |tee $output"
        else
            echo "do UDP port scan"

            perl $U_PATH_TBIN/sshcli.pl -t 3600 -l $G_CURRENTLOG -o $G_CURRENTLOG/remote_nmap_${index}.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "nmap -6 -sT -P0 -p $port -T4 -d2 $dest |tee $output"
        fi
    else
        echo "do ipv6 scan"
        if [ -z $is_udp ] ;then
            echo "do TCP port scan"

            if [ "$U_DUT_TYPE" == "BHR2" ] ;then
                perl $U_PATH_TBIN/sshcli.pl -t 3600 -l $G_CURRENTLOG -o $G_CURRENTLOG/remote_nmap_${index}.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "nmap -6 -sT -P0 -p $port -T4 -d2 $dest | tee $output"
            else
                perl $U_PATH_TBIN/sshcli.pl -t 3600 -l $G_CURRENTLOG -o $G_CURRENTLOG/remote_nmap_${index}.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "nmap -6 -sT -Pn -p $port -T4 --min-rate 300 -d3 -v $dest |tee $output"
            fi
        else
            echo "do UDP port scan"

            if [ "$U_DUT_TYPE" == "BHR2" ] ;then
                perl $U_PATH_TBIN/sshcli.pl -t 3600 -l $G_CURRENTLOG -o $G_CURRENTLOG/remote_nmap_${index}.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "nmap -6 -sU -P0 -p $port -T2 -d2 $dest | tee $output"
            else
                perl $U_PATH_TBIN/sshcli.pl -t 3600 -l $G_CURRENTLOG -o $G_CURRENTLOG/remote_nmap_${index}.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "nmap -6 -sU -sV -p $port -T4 --min-rate 300 -A -d2 -v $dest |tee $output"
            fi
        fi
    fi

    rc_nmap=$?

    if [ $rc_nmap -gt 0 ] ;then
        echo "AT_ERROR : error occured when doing nmap , please check the arguments"
        exit 1
    else
        echo "nmap done !"
        exit 0
    fi
}

LAN_scan(){
    echo "in function LAN_scan() ..."

    if [ -z "$is_ipv6" ] ;then
        echo "do ipv4 scan"
        if [ -z $is_udp ] ;then
            echo "do TCP port scan"
            nmap -p $port -T4 --min-rate 300 -d2 -v $dest |tee $output
        else
            echo "do UDP port scan"
            nmap -sU -sV -p $port -T4 --min-rate 300 -A -d2 -v $dest |tee $output
        fi
    else
        echo "do ipv6 scan"
        if [ -z $is_udp ] ;then
            echo "do TCP port scan"
            if [ "$U_DUT_TYPE" == "BHR2" ] ;then
                nmap -6 -sT -P0 -p $port -T4 -d2 $dest |tee $output
            else
                nmap -6 -sT -Pn -p $port -T4 --min-rate 300 -d3 -v $dest |tee $output
            fi
        else
            echo "do UDP port scan"
            if [ "$U_DUT_TYPE" == "BHR2" ] ;then
                nmap -6 -sU -P0 -p $port -T2 -d2 $dest |tee $output
            else
                nmap -6 -sU -sV -p $port -T4 --min-rate 300 -A -d2 -v $dest |tee $output
            fi
        fi
    fi

    rc_nmap=$?

    if [ $rc_nmap -gt 0 ] ;then
        echo "AT_ERROR : error occured when doing nmap , please check the arguments"
        exit 1
    else
        echo "nmap done !"
        exit 0
    fi
}

if [ "$traffic_type" == "in" ] ;then
    WAN_scan
elif [ "$traffic_type" == "out" ] ;then
    LAN_scan
fi
