#!/bin/bash
#
# Author        :   Prince(pwang@actiontec.com)
# Description   :
#   This tool is used to on and off switch for usb interface.
while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        export U_PATH_TBIN=/root/automation/bin/2.0/common
        export G_CURRENTLOG=/tmp
        export U_CUSTOM_WECB_IP=192.168.8.35
        export U_CUSTOM_WECB_USR=root
        export U_CUSTOM_WECB_PSW=admin
        export U_PATH_TOOLS=/root/automation/tools/2.0
        export G_HOST_USR2=root
        export G_HOST_PWD2=123qaz
        export G_HOST_IP2=192.168.8.41
        shift 1
        ;;
    -d)
        testbed=$2
        echo "Replug the wireless card for ${testbed}"
        shift 2
        ;;
    *)
        echo -e $usage
        exit 1
        ;;
    esac
done

if [ -z ${testbed} ];then
    testbed=LAN1
fi

retry_time=5
sleep_time=5

function load_driver(){

    if [ ${testbed} == "LAN2" ];then
        echo "Load wireless driver for LAN PC 2"
        echo "$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/load_driver.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v \"cp $U_PATH_TOOLS/netgear/*  /lib/modules/2.6.38.6-26.rc1.fc15.i686.PAE/kernel/drivers/net/\" -v \"sleep 5\" -v \"depmod -a\" -v \"sleep 10\" -v \"modprobe bcm_usbshim\" -v \"sleep 10\" -v \"modprobe wl\" -v \"sleep 10\""
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/load_driver.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "cp $U_PATH_TOOLS/netgear/*  /lib/modules/2.6.38.6-26.rc1.fc15.i686.PAE/kernel/drivers/net/" -v "sleep 5" -v "depmod -a" -v "sleep 10" -v "modprobe bcm_usbshim" -v "sleep 10" -v "modprobe wl"
    else
        echo "Load wireless driver for LAN PC 1"
        echo "cp $U_PATH_TOOLS/netgear/*  /lib/modules/2.6.38.6-26.rc1.fc15.i686.PAE/kernel/drivers/net/"
        cp $U_PATH_TOOLS/netgear/*  /lib/modules/2.6.38.6-26.rc1.fc15.i686.PAE/kernel/drivers/net/
        sleep 5
        echo "depmod -a"
        depmod -a
        sleep 10
        echo "modprobe bcm_usbshim"
        modprobe bcm_usbshim
        sleep 10
        echo "modprobe wl"
        modprobe wl
        sleep 10
    fi
}

function ReplugUSB(){
    echo "Replug wireless card"
    
    for i in `seq 1 $retry_time`
    do
        echo "ping $U_CUSTOM_WECB_IP -c 1"
        ping $U_CUSTOM_WECB_IP -c 1
        if [ $? -eq 0 ];then
            echo "ping $U_CUSTOM_WECB_IP Success!"
            break
        else
            echo "AT_ERROR : ping $U_CUSTOM_WECB_IP Fail!"
            sleep $sleep_time
            if [ $i -eq $retry_time ];then
                exit 1
            fi
        fi
    
    done
    
    for i in `seq 1 $retry_time`
    do
        echo "bash $U_PATH_TBIN/switch_controller.sh -u 0"
        bash $U_PATH_TBIN/switch_controller.sh -u 0
        if [ $? -eq 0 ];then
            echo "bash $U_PATH_TBIN/switch_controller.sh -u 0 Success!"
            break
        else        
            echo "AT_ERROR : bash $U_PATH_TBIN/switch_controller.sh -u 0 Fail!"
            sleep $sleep_time
            if [ $i -eq $retry_time ];then
                exit 1
            fi
        fi
    done

    echo "sleep $sleep_time"
    sleep $sleep_time
    for i in `seq 1 $retry_time`
    do
        echo "bash $U_PATH_TBIN/switch_controller.sh -u 1"
        bash $U_PATH_TBIN/switch_controller.sh -u 1
        if [ $? -eq 0 ];then
            echo "bash $U_PATH_TBIN/switch_controller.sh -u 1 Success!"
            break
        else        
            echo "AT_ERROR : bash $U_PATH_TBIN/switch_controller.sh -u 1 Fail!"
            sleep $sleep_time
            if [ $i -eq $retry_time ];then
                exit 1
            fi
        fi
    done

    echo "sleep $sleep_time"
    sleep $sleep_time
    for i in `seq 1 $retry_time`
    do
        echo "bash $U_PATH_TBIN/switch_controller.sh -w 0"
        bash $U_PATH_TBIN/switch_controller.sh -w 0
        if [ $? -eq 0 ];then
            echo "bash $U_PATH_TBIN/switch_controller.sh -w 0 Success!"
            break
        else        
            echo "AT_ERROR : bash $U_PATH_TBIN/switch_controller.sh -w 0 Fail!"
            sleep $sleep_time
            if [ $i -eq $retry_time ];then
                exit 1
            fi
        fi
    done

    echo "sleep $sleep_time"
    sleep $sleep_time
    for i in `seq 1 $retry_time`
    do
        echo "bash $U_PATH_TBIN/switch_controller.sh -w 1"
        bash $U_PATH_TBIN/switch_controller.sh -w 1
        if [ $? -eq 0 ];then
            echo "bash $U_PATH_TBIN/switch_controller.sh -w 1 Success!"
            break
        else        
            echo "AT_ERROR : bash $U_PATH_TBIN/switch_controller.sh -w 1 Fail!"
            sleep $sleep_time
            if [ $i -eq $retry_time ];then
                exit 1
            fi
        fi
    done
    echo ""
    echo "AT_INFO : Replug switch USB interface PASS!"
}

load_driver

for j in `seq 1 $retry_time`
do
    ifconfig -a
    
    if [  $j -eq 2 ] ;then
		ReplugUSB
		echo "sleep 1m"
		sleep 1m
    fi
    
    
    rc1=0
    rc2=0
    sleep $sleep_time
    if [ ${testbed} == "LAN2" ];then
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/cli_cmd_lan2_ifconfig.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "ifconfig -a"
        grep "^ *wlan" $G_CURRENTLOG/cli_cmd_lan2_ifconfig.log
        rc2=$?
    fi

    echo "ifconfig -a"
    ifconfig -a
    ifconfig -a|grep -i "^ *wlan"
    rc1=$?

    if [ $rc1 -eq 0 ] && [ $rc2 -eq 0 ];then
        echo "AT_INFO : Check wireless Card Pass!"
        break
    elif [ $rc1 -ne 0 ] && [ $rc2 -eq 0 ];then
        echo "AT_ERROR : Check wireless Card Fail on LAN PC 1!"
        if [ $j -eq $retry_time ];then
            exit 1
        fi
        sleep $sleep_time
    elif [ $rc1 -eq 0 ] && [ $rc2 -ne 0 ];then
        echo "AT_ERROR : Check wireless Card Fail on LAN PC 2!"
        if [ $j -eq $retry_time ];then
            exit 1
        fi
        sleep $sleep_time
    elif [ $rc1 -ne 0 ] && [ $rc2 -ne 0 ];then
        echo "AT_ERROR : Check wireless Card Fail on LAN PC 1 and LAN PC 2!"
        if [ $j -eq $retry_time ];then
            exit 1
        fi
        sleep $sleep_time
    else
        echo '----------------------------------'
        if [ $j -eq $retry_time ];then
            exit 1
        fi
        sleep $sleep_time
    fi
done
