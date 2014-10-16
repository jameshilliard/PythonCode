#!/bin/bash
#
#--------------------------------
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version
#16 Nov 2011    |   1.0.2   | rayofox   | add retry loop ,and add more output message
#30 Nov 2011    |   1.0.3   | Alex      | add -t option to specify duration of ping,default is 10 sec
#10 Jan 2012    |   1.0.4   | rayofox   | code review with Howard
#13 Jun 2012    |   1.0.5   | howard    | to relink interface only if ping failed

REV="$0 version 1.0.5 (13 Jun 2012)"
# print REV

echo "${REV}"
# default parameter value
timeout=12
itf=$G_HOST_IF0_1_0

dest=$G_HOST_GW0_1_0

echo "G_HOST_TIP0_1_0 : ${G_HOST_TIP0_1_0}"

if [ ! -z "$G_HOST_TIP0_1_0" ]; then
    itf_ip=$G_HOST_TIP0_1_0/24
fi

if [ -z "$U_PATH_TBIN" ]; then
    U_PATH_TBIN=~/automation/bin/2.0/common
fi

if [ -z "$G_CURRENTLOG" ]; then
    G_CURRENTLOG=/tmp
fi

usage="usage: bash $0 [-t <timeout>|-i <interface>|-d <dest>|-a <ipaddr> | -help]"
while [ -n "$1" ];
do
    case "$1" in
    -t)
        timeout=$2
        shift 2
        ;;
    -i)
        itf=$2
        if [ -z "$itf_ip" ]; then
            itf_ip=`ip addr show scope global | grep global| grep $itf |awk '{print $2}'`
            echo "ipaddr : $itf_ip"
        fi
        shift 2
        ;;
    -d)
        dest=$2
        shift 2
        ;;
    -a)
        itf_ip=$2
        shift 2
        ;;
    *)
        echo -e $usage
        exit 1
        ;;
    esac
done

if [ -z "$U_CUSTOM_TESTBED_SV" ]; then
    U_CUSTOM_TESTBED_SV=0
fi

get_network(){
    ipaddr=$1
    _sys1=`head -n 1 /etc/issue | grep Ubuntu`
    isUbuntu=$?
    _sys2=`head -n 1 /etc/issue | grep Fedora`
    isFC=$?
    if [ "$isUbuntu" == "0" ];then
        #echo "System : $_sys1"
        #echo "ipcalc -n $ipaddr"
        #ipcalc -n $ipaddr
        rc="$(/usr/bin/ipcalc -n $ipaddr|grep Network|awk '{print $2}' ) "
    elif [ "$isFC" == "0" ];then
        #echo "System : $_sys2"
        #echo "ipcalc -n $ipaddr"
        #ipcalc -n $ipaddr
        rc="$(ipcalc -n $ipaddr)"
    fi
    #echo "subnet : $rc"
}

is_in_same_subnet(){
    IP1=$1
    IP2=$2
    get_network $IP1
    subnet1=`echo $rc | tr -d ' '`
    get_network $IP2
    subnet2=`echo $rc | tr -d ' '`
    #echo "IP($IP1) in network : $subnet1"
    #echo "IP($IP2) in network : $subnet2"
    if [ -z "$subnet1" ];then
        rc=1
        #echo "$rc : ($subnet1) is empty"
    else
        if [ "${subnet1}" == "${subnet2}" ];then
            rc=0
            #echo "0"
        else
            rc=1
            #echo "$rc : ($subnet1) is not equal to ($subnet2)"
        fi
    fi
}

disable_others_same_subnet(){
    SRC_IF=$1
    SRC_IPADDR=$2
    if [ -z "$SRC_IPADDR" ]; then
        SRC_IPADDR=`ip addr show scope global | grep global| grep $1 |awk '{print $2}'`
    fi
    echo "source ipaddr is : $SRC_IPADDR"
    if [ -z "$SRC_IPADDR" ]; then
        return
    fi
    ss=`ip addr show scope global | grep global | awk '{ if($NF) {if (ifname!=$NF) print $NF":"$2 } }' ifname=$SRC_IF`
    echo -e "----------\nall NICs : \n$ss\n-----------------"
    for line in $ss;do
        #echo "Line : $line"
        _itf=`echo $line | cut -d: -f 1`
        _itf_ip=`echo $line | cut -d: -f 2`
        is_in_same_subnet $SRC_IPADDR $_itf_ip
        if [ "$rc" == "0" ];then
            echo "  $_itf($_itf_ip) is in the same subnet with $SRC_IF($SRC_IPADDR)"
            echo "  release ip for $_itf : ip -4 addr flush dev $_itf"
            ip -4 addr flush dev $_itf
        else
            echo "  $_itf($_itf_ip) is not in the same subnet with $SRC_IF($SRC_IPADDR)"
        fi
    done

}

disable_all_in_subnet(){
    SRC_IPADDR=$1

    echo "source ipaddr is : $SRC_IPADDR"
    if [ -z "$SRC_IPADDR" ]; then
        echo "AT_ERROR : subnet ip is required "
        return
    fi
    ss=`ip addr show scope global | grep global | awk '{ if($7) { print $7":"$2 } }'`
    echo -e "----------\nall NICs : \n$ss\n-----------------"
    for line in $ss;do
        #echo "Line : $line"
        _itf=`echo $line | cut -d: -f 1`
        _itf_ip=`echo $line | cut -d: -f 2`
        is_in_same_subnet $SRC_IPADDR $_itf_ip
        if [ "$rc" == "0" ];then
            echo "  $_itf($_itf_ip) is in the same subnet with $SRC_IF($SRC_IPADDR)"
            echo "  release ip for $_itf : ip -4 addr flush dev $_itf"
            ip -4 addr flush dev $_itf
        else
            echo "  $_itf($_itf_ip) is not in the same subnet with $SRC_IF($SRC_IPADDR)"
        fi
    done

}

#is_in_same_subnet 192.168.1.100/24 192.168.10.22/24
#disable_others_same_subnet $itf
#exit 1


# print the parameter list
echo "-------Parameter List-------"
echo "destination   : $dest"
echo "NIC interface : $itf"
echo "NIC address   : $itf_ip"
echo "timeout       : $timeout"
echo "----------------------------"

# Check parameter
if [ -z "$dest" ]; then
    echo "AT_ERROR : must specify an destination IP address to ping"
    exit 1
fi

if [ -z "$itf" ]; then
    echo "AT_ERROR : must specify an NIC"
    exit 1
fi

if [ -z "$itf_ip" ]; then
    echo "AT_ERROR : must specify an IP address for the given NIC"
    exit 1
else
    ori_itf_ip=`ip addr show scope global | grep global | awk '{ if($7) { print $7":"$2 } }'|grep $itf| cut -d: -f 2`

    echo "  original ip : "$ori_itf_ip

    if [ "$ori_itf_ip" != "$itf_ip" ] ;then
        echo "== try relink the NIC $itf"

        if [ $U_CUSTOM_TESTBED_SV = 0 ]; then
            echo "ip -4 addr flush dev $itf"
            ip -4 addr flush dev $itf

            echo "ifconfig $itf $itf_ip up"
            #dhclient -v $itf  -pf ${itf}.pid
            ifconfig $itf $itf_ip up
        elif [ $U_CUSTOM_TESTBED_SV = 1 ]; then
            echo "/sbin/ifdown $itf"
            /sbin/ifdown $itf

            echo "/sbin/ifup $itf"
            /sbin/ifup $itf
        else
            echo "AT_ERROR : invalid parameter U_CUSTOM_TESTBED_SV"
            exit 1
        fi

        #if [ $U_CUSTOM_TESTBED_SV = 0 ]; then
            echo "if route del default"
            ip route del default

            echo "ip route add default via $dest dev $itf"
            ip route add default via $dest dev $itf
        #fi

        echo "show route and network config info"
        ifconfig
        route -n
    else
        #if [ $U_CUSTOM_TESTBED_SV = 0 ]; then
            echo "if route del default"
            ip route del default

            echo "ip route add default via $dest dev $itf"
            ip route add default via $dest dev $itf
        #fi

        echo "show route and network config info"
        ifconfig
        route -n
    fi
fi
# print local route information
echo "show local network info :"
ifconfig
route -n

echo "To disable others NIC in the same subnet with $itf"
disable_others_same_subnet $itf $itf_ip/24

####


# to ping DUT
#perl $G_SQAROOT/bin/$G_BINVERSION/common/verifyPing.pl -d $G_PROD_IP_BR0_0_0 -I $G_HOST_IF0_1_0 -t 10 -l $G_CURRENTLOG 2>/dev/null
rc=1


retry=10
ttt=`expr $timeout / $retry`
for i in `seq $retry`; do
    echo "Try ping $dest $retry($i) each timeout($ttt) ..."
    wlFlag=`echo $itf | grep -o "wlan"`

    if [ "$wlFlag" = "wlan" ]; then
        perl $U_PATH_TBIN/verifyPing.pl -d $dest -I $itf -c 5 -t $ttt -l $G_CURRENTLOG
    else
        perl $U_PATH_TBIN/verifyPing.pl -d $dest -I $itf -t $ttt -l $G_CURRENTLOG
    fi

    rc=$?

    if [ $rc -eq 0 ]; then
        #echo "---------------------------------"
        #echo "try to scan TCP port of DUT with nmap"
        #nmap -v -n -sS $dest
        #echo "----------------------------------"

        break
    else
        every5=`echo "$i%5"|bc`

        if [ "$every5" == "1" ] ;then
            echo "== try relink the NIC $itf"

            if [ $U_CUSTOM_TESTBED_SV = 0 ]; then
                echo "ip -4 addr flush dev $itf"
                ip -4 addr flush dev $itf

                echo "ifconfig $itf $itf_ip up"
                #dhclient -v $itf  -pf ${itf}.pid
                ifconfig $itf $itf_ip up
            elif [ $U_CUSTOM_TESTBED_SV = 1 ]; then
                echo "/sbin/ifdown $itf"
                /sbin/ifdown $itf

                echo "/sbin/ifup $itf"
                /sbin/ifup $itf
            else
                echo "AT_ERROR : invalid parameter U_CUSTOM_TESTBED_SV"
                exit 1
            fi

            #if [ $U_CUSTOM_TESTBED_SV = 0 ]; then
                echo "if route del default"
                ip route del default

                echo "ip route add default via $dest dev $itf"
                ip route add default via $dest dev $itf
            #fi

            echo "show route and network config info"
            ifconfig
            route -n
        fi

    fi
done


if [ $rc -eq 0 ]; then
    exit 0
else
    echo -e " verifyPing.pl failed! "
    echo "AT_ERROR : make sure LANPC connected to DUT or tb.cfg is correct to setup DUT's info!"
    exit 1
fi
