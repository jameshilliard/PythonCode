#!/bin/bash
#   iface=$G_HOST_IF0_1_0
#
# Author        :   Howard Yin(hying@actiontec.com)
# Description   :
#   This tool is using to verify if the DUT is connected to WAN
#
#
# History      :
#   DATE        |   REV  | AUTH   | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version
#15 Nov 2011    |   1.0.1   | rayofox   | modify path from common to $U_PATH_TBIN
#16 Nov 2011    |   1.0.2   | rayofox   | add retry loop and more output
#30 Nov 2011    |   1.0.3   | Alex      | add -t option to specify duration of ping,default is 20 sec
#20 Mar 2012    |   1.0.4   | howard    | ping WAN host via default route interface
#

REV="$0 version 1.0.4 (20 Mar 2012)"
# print REV

echo "${REV}"

neg=0

usage="usage: bash $0 -i <interface> -t <timeout> -e <expect time> [-T:test] [n:negative]"
while getopts ":i:e:t:Tn" opt ;
do
    case $opt in
        i)
            iface=$OPTARG
            echo "interface : $iface"
            ;;
        #l)
        #   log=$OPTARG
        #   echo "log file : $log"
        #   ;;
        t)
            timeout=$OPTARG
            echo "timeout : $timeout"
            ;;
        e)
            expect_time=$OPTARG
            echo "expect time : $expect_time"
            ;;

        T)
            U_CUSTOM_WAN_HOST=192.168.100.1
            G_HOST_IF0_1_0=eth1
            G_CURRENTLOG=/dev/shm
            SQAROOT=/root/automation
            G_BINVERSION=2.0
            U_PATH_TBIN=$SQAROOT/bin/$G_BINVERSION/common
            G_PROD_IP_BR0_0_0=192.168.1.1
            G_HOST_TIP0_1_0=192.168.1.100
            ;;
        n)
            neg=1
            echo "negative test engaged"
            ;;
        ?)
            paralist=-1
            echo "WARN: '-$OPTARG' not supported."
            echo -e $usage
            exit 1
    esac
done

if [ -z "$iface" ] ;then
    iface=$G_HOST_IF0_1_0
fi

if [ -z "$timeout" ]; then
    timeout=20
    if [ "$U_DUT_TYPE" == "PK5K1A" ];then
        timeout=90
    fi
fi

def_rt_ifc=`route -n|grep "^0.0.0.0"|awk '{print $NF}'`

if [ "$def_rt_ifc" != "" ] ;then
    iface=$def_rt_ifc
fi

# print local route information
echo "ifconfig;route -n"
ifconfig
route -n

up_down_eth1(){
    echo "ip addr del $G_HOST_TIP0_1_0/24 dev $G_HOST_IF0_1_0"
    ip addr del $G_HOST_TIP0_1_0/24 dev $G_HOST_IF0_1_0
    echo "ip link set $G_HOST_IF0_1_0 down"
    ip link set $G_HOST_IF0_1_0 down
    echo "ip link set $G_HOST_IF0_1_0 up"
    ip link set $G_HOST_IF0_1_0 up
    echo "ip addr add $G_HOST_TIP0_1_0/24 dev $G_HOST_IF0_1_0"
    ip addr add $G_HOST_TIP0_1_0/24 dev $G_HOST_IF0_1_0
    }

#perl $SQAROOT/bin/$G_BINVERSION/common/verifyPing.pl -d $U_CUSTOM_WAN_HOST -I $iface -t 60 -l $G_CURRENTLOG 2>/dev/null
rc=1

timeout=`echo "$timeout/3" | bc`

start_time=`date +%s`

for i in `seq 3`; do
    echo "Try ping $U_CUSTOM_WAN_HOST $i ..."

    echo "python $U_PATH_TBIN/verifyPing.py -d $U_CUSTOM_WAN_HOST -I $iface -t $timeout -l $G_CURRENTLOG"

    python $U_PATH_TBIN/verifyPing.py -d $U_CUSTOM_WAN_HOST -I $iface -t $timeout -l $G_CURRENTLOG
    rc=$?
    if [ $rc -eq 0 ]; then
        break
    else
        echo "sleep 15s and try again"
        sleep 15
    fi

    if [ "$iface" == "$G_HOST_IF0_1_0" ] ;then
        up_down_eth1
    fi

    echo "ip route add default via $G_PROD_IP_BR0_0_0 dev $G_HOST_IF0_1_0"
    ip route add default via $G_PROD_IP_BR0_0_0 dev $iface
done

end_time=`date +%s`

let "spend_time = end_time - start_time"

if [ $neg -eq 0 ];then
    if [ $rc -eq 0 ]; then
        if [ "$expect_time" ] ;then
            echo "AT_INFO : spend_time  <$spend_time>"
            echo "AT_INFI : expect_time <$expect_time>"
            if [ $spend_time -le $expect_time ] ;then
                echo "AT_INFO : real spend time less than expect time"
                exit 0
            else
                echo "AT_ERROR : real spend time more than expect time"
                exit 1
            fi
        else
            exit 0
        fi
    else
        # add a step to get DUT WAN info for debug purpose
        $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/verifyDutWanConnected_wan_link_info.tmp
    
        echo -e " verifyPing.py failed! "
        echo "AT_ERROR : make sure DUT connected to WAN or tst.cfg is correct to setup the param U_CUSTOM_WAN_HOST!"
        exit 1
    fi
else
    if [ $rc -eq 1 ]; then
        exit 0
    else
        # add a step to get DUT WAN info for debug purpose
        $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/verifyDutWanConnected_wan_link_info.tmp
    
        echo -e " verifyPing.py negate failed! "
        echo "AT_ERROR : make sure DUT connected to WAN or tst.cfg is correct to setup the param U_CUSTOM_WAN_HOST!"
        exit 1
    fi
fi


