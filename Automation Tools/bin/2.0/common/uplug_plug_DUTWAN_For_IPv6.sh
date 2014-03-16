#!/bin/bash

#U_TYPE_DUT="PK5K1A"
#U_TYPE_DUT="BHR2"
while [ $# -gt 0 ]
    do
        case "$1" in
            -t)
                isUnplug=$2
                shift 2
                ;;
            *)
                echo "bash $0 -t [1/0]"
                exit 1
                ;;
        esac
    done
if [ "$isUnplug" == "0" ];then
    echo " $U_PATH_TBIN/switch_controller.sh -offall -e 0"
    $U_PATH_TBIN/switch_controller.sh -alloff -e 0
elif [  "$isUnplug" == "1" ];then
    if [ "$U_DUT_TYPE" == "PK5K1A" ];then
        echo "$U_PATH_TBIN/switch_controller.sh -line as "
        $U_PATH_TBIN/switch_controller.sh -line as
    else
        echo "$U_PATH_TBIN/switch_controller.sh -e 1"
        $U_PATH_TBIN/switch_controller.sh -e 1 
    fi
else
    echo "Unknow what you want to do..."
    exit 1
fi



