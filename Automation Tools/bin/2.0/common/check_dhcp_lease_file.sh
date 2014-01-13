#!/bin/bash
#---------------------------------
# Name: Andy liu
# Description:
# This script is used to ckeck dhclient lease file
#
#--------------------------------
# History    :
#   DATE        |   REV     | AUTH      | INFO
#16 May 2012    |   1.0.0   | Andy      | Inital Version

REV="$0 version 1.0.0 (15 May 2012)"
echo "${REV}"

usage="$0 [--test : test mode ] -f <lease file> -i <interf0ace> [-a <expect ipaddress>] [-m <expect sbunet mask>] [-g <expect gateway>] [-s <DHCP pool start ipaddress> -e <DHCP pool end ipaddress>] [-d <Primary DNS,Secondary DNS>] [-t <lease time>] [-n : negative test] [--custom : use custom value] [--default : use default value]"

#if you want output more information set Debug to 1:comment 2:debug.
Debug=0

nega=0
result=0
Test_FW_Upgrade=False
while [ -n "$1" ];
do
    case "$1" in
        --test)
            echo "Mode : Test mode"
            U_PATH_TBIN=/root/automation/bin/2.0/common
            G_CURRENTLOG=/tmp
            mask="255.255.255.0"
            gw="192.168.0.1"
            minadd="192.168.0.2"
            maxadd="192.168.0.254"
            dns="192.168.0.1,10.20.10.10"
            lt="86400"
            shift 1
            ;;

        -f)
            echo "lease file : $2"
            lease_file=$2
            shift 2
            ;;

        -i)
            echo "interface : $2"
            interface=$2
            shift 2
            ;;

        -a)
            echo "ipaddress : $2"
            ipaddr=$2
            shift 2
            ;;

        -m)
            echo "mask : $2"
            mask=$2
            shift 2
            ;;

        -g)
            echo "gateway : $2"
            gw=$2
            shift 2
            ;;

        -s)
            echo "DHCP pool start address : $2"
            minadd=$2
            shift 2
            ;;

        -e)
            echo "DHCP pool end address : $2"
            maxadd=$2
            shift 2
            ;;

        -d)
            echo "DNS : $2"
            dns=$2
            shift 2
            ;;

        -t)
            echo "lease time : $2"
            lt=$2
            shift 2
            ;;

#        -o)
#            echo "output : $2"
#            output=$2
#            shift 2
#            ;;

        -n)
            echo "negative mode!"
            nega=1
            shift 1
            ;;

        --custom)
            echo "custom mode!"
            #ipaddr="$U_DUT_CUSTOM_LAN_IP"
            mask="$U_DUT_CUSTOM_LAN_NETMASK"
            gw="$U_DUT_CUSTOM_LAN_GATEWAY"
            minadd="$U_DUT_CUSTOM_LAN_MIN_ADDRESS"
            maxadd="$U_DUT_CUSTOM_LAN_MAX_ADDRESS"
            dns="$U_DUT_CUSTOM_LAN_DNS_1"",""$U_DUT_CUSTOM_LAN_DNS_2"
            lt="$U_DUT_CUSTOM_LAN_LEASETIME"
            shift 1
            ;;

        --default)
            echo "dafault mode!"
            #ipaddr="$G_PROD_IP_BR0_0_0"
            mask="$G_PROD_TMASK_BR0_0_0"
            gw="$G_PROD_GW_BR0_0_0"
            minadd="$G_PROD_DHCPSTART_BR0_0_0"
            maxadd="$G_PROD_DHCPEND_BR0_0_0"
            dns="$G_PROD_DNS1_BR0_0_0"",""$G_PROD_DNS2_BR0_0_0"
            lt="$G_PROD_LEASETIME_BR0_0_0"
            shift 1
            ;;
        --fwupgrade)
            Test_FW_Upgrade=True
            shift 1
            ;;

        *)
            echo $usage
            exit 1
            ;;
    esac
done

if [ ! -f "$lease_file" ] ;then
    echo "AT_ERROR : No such file <$lease_file>"
    exit 1
else
    [ $Debug -gt 0 ] && echo "Makesure only one lease node"
    lease_node_count=`grep "^lease {" $lease_file | wc -l`
    [ $Debug -gt 1 ] && echo "Debug : lease node count : <$lease_node_count>"
    if [ "$lease_node_count" -ne 1 ] ;then
        echo "AT_ERROR : The number of lease nodes is not equal to 1."
        exit 1
    fi
fi

####lease file
####lease {
####  interface "eth1";
####  fixed-address 192.168.0.2;
####  option subnet-mask 255.255.255.0;
####  option dhcp-lease-time 86400;
####  option routers 192.168.0.1;
####  option dhcp-message-type 5;
####  option dhcp-server-identifier 192.168.0.1;
####  option domain-name-servers 192.168.0.1,10.20.10.10;
####  option domain-name "Home";
####  renew 2 2012/05/15 19:19:36;
####  rebind 3 2012/05/16 06:55:06;
####  expire 3 2012/05/16 09:55:06;
####}

if [ -z "$interface" ] ;then
    echo "Haven't specified interface,use default interface: eth1"
    interface=eth1

    [ $Debug -gt 0 ] && echo "Makesure lease file contain the correct infterfase's information"
    grep -q "^ *interface \"$interface\"" $lease_file
    rc=$?
    [ $Debug -gt 1 ] && echo "Debug : The interface in lease file is <"`grep "^ *interface" $lease_file`">"
    if [ "$rc" -ne 0 ] ;then
        echo "AT_ERROR : Can NOT find the information about interface <$interface>"
        exit 1
    fi
fi

#if [ -z "$output" ] ;then
#    echo "Warning : output file is empty."
#    echo "Set output file : <$G_CURRENTLOG/$interface>"
#    output=$G_CURRENTLOG/$interface
#fi
echo "=========================================================================="

[ $Debug -gt 0 ] && echo "Test the ip address is expect"
if [ "$ipaddr" ] ;then
    grep -q "^ *fixed-address $ipaddr" $lease_file
    rc=$?
    [ $Debug -gt 1 ] && echo "Debug : The ip address in lease file is <"`grep "^ *fixed-address" $lease_file`">" 
    if [ "$rc" -eq 0 ] ;then
        echo "Found expect ip address : <$ipaddr>"
    else
        echo "NOT found expect ip address : <$ipaddr>"
        let "result=$result+1"
    fi
fi

[ $Debug -gt 0 ] && echo "Test subnet mask is expect"
if [ "$mask" ] ;then
    grep -q "^ *option subnet-mask $mask;" $lease_file
    rc=$?
    [ $Debug -gt 1 ] && echo "Debug : The subnet mask in lease file is <"`grep "^ *option subnet-mask" $lease_file`">"
    if [ "$rc" -eq 0 ] ;then
        echo "Found expect subnet mask : <$mask>"
    else
        echo "NOT found expect subnet mask : <$mask>"
        let "result=$result+1"
    fi
fi

[ $Debug -gt 0 ] && echo "Test gateway is expect"
if [ "$gw" ] ;then
    grep -q "^ *option routers $gw;" $lease_file
    rc=$?
    [ $Debug -gt 1 ] && echo "Debug : The gateway in lease file is <"`grep "^ *option routers" $lease_file`">"
    if [ "$rc" -eq 0 ] ;then
        echo "Found expect gateway : <$gw>"
    else
        echo "NOT found expect gateway : <$gw>"
        let "result=$result+1"
    fi
fi

[ $Debug -gt 0 ] && echo "Test DHCP pool is valid"
if [ "$minadd" -a -z "$maxadd" ] || [ -z "$minadd" -a "$maxadd" ] ;then
    echo "AT_ERROR : Please assign the both DHCP pool star address <$minadd> and end address <$maxadd>"
    exit 1
fi

[ $Debug -gt 0 ] && echo "Test the <$interface> ip address is in the DHCP pool"
if [ "$minadd" -a "$maxadd" ] ;then
    [ $Debug -gt 0 ] && echo "Get the ip address of <$interface>"
    ifconfig $interface > $G_CURRENTLOG/${interface}_ifconfig.log
    current_ip=`grep "inet addr" $G_CURRENTLOG/${interface}_ifconfig.log | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
    echo "range $minadd $maxadd" > $G_CURRENTLOG/ipaddress_range_file.conf
    [ $Debug -gt 0 ] && echo "Execute check_ipaddress_in_range.sh for test ip in range"
    bash $U_PATH_TBIN/check_ipaddress_in_range.sh -c $G_CURRENTLOG/ipaddress_range_file.conf -l $G_CURRENTLOG/${interface}_ifconfig.log >/dev/dull
    if [ $? -eq 0 ] ;then
        echo "The <$interface> ip address <$current_ip> is in the DHCP pool : <$minadd> -- <$maxadd>"
    else
        echo "The <$interface> ip address <$current_ip> is NOT in the DHCP pool : <$minadd> -- <$maxadd>"
        let "result=$result+1"
    fi
fi

[ $Debug -gt 0 ] && echo "Test the DNS is expect"
if [ "$Test_FW_Upgrade" == "True" ];then 
    if [ "$U_DUT_TYPE" == "TV2KH" ];then
        if  [ "$U_CUSTOM_PREVIOUS_GA_FW_VER" == "31.30L.57" ] || [ "$U_CUSTOM_PREVIOUS_GA_FW_VER" == "31.30L.48" ];then
            dns=""
        fi
    fi
fi

if [ "$dns" ] ;then
    [ $Debug -gt 0 ] && echo "Parse the input of DNS"
    [ $Debug -gt 1 ] && echo "Debug : The input of DNS is <$dns>"
    dns1=`echo "$dns" | awk -F, '{print $1}'`
    echo  "dns1 is:>$dns1<"
    dns2=`echo "$dns" | awk -F, '{print $2}'`
    echo  "dns2 is:>$dns2<"
#    if [ -z "$dns1" -o -z "$dns2" ] ;then
#        echo "AT_ERROR : Bad DNS input <$dns>"
#        exit 1
#    fi
    echo "grep -q \"^ *option domain-name-servers $dns1,\{0,1\}$dns2;\" $lease_file "
    grep -q "^ *option domain-name-servers $dns1,\{0,1\}$dns2;" $lease_file
    rc=$?
    [ $Debug -gt 1 ] && echo "Debug : The DNS in lease file is <"`grep "^ *option domain-name-servers" $lease_file`">"
    if [ "$rc" -eq 0 ] ;then
        echo "Found expect DNS : <$dns>"
    else
        echo "NOT found expect DNS : <$dns>"
        let "result=$result+1"
    fi
fi

[ $Debug -gt 0 ] && echo "Test the lease time is expect"
if [ "$lt" ] ;then
    grep -q "^ *option dhcp-lease-time $lt;" $lease_file
    rc=$?
    [ $Debug -gt 1 ] && echo "Debug : The lease time in lease file is <"`grep "^ *option dhcp-lease-time" $lease_file`">"
    if [ "$rc" -eq 0 ] ;then
        echo "Found expect lease time : <$lt>"
    else
        echo "NOT found expect lease time : <$lt>"
        let "result=$result+1"
    fi
fi

if [ "$nega" -eq 0 ] ;then
    if [ $result -eq 0 ] ;then
        echo "Positive test is passed"
        exit 0
    else
        echo "AT_ERROR : Positive test is failed. result : <$result>"
        exit 1
    fi
else
    if [ $result -eq 0 ] ;then
        echo "AT_ERROR : Negative is failed. result : <$result>"
        exit 1
    else
        echo "Negative is passed."
        exit 0
    fi
fi
