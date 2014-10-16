#!/bin/bash
# Author        :   Howard Yin(hying@actiontec.com)
# Description   :
#   This tool is using to restore the DUT wireless settings
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version       
#

REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV

echo "${REV}"
if [ -f "${U_CUSTOM_CONFIG_LOAD}" ] ;then
    wifi_restore_configure_file=$U_CUSTOM_CONFIG_LOAD
    
    #killall wpa_supplicant
    echo "wpa_cli terminate"
    wpa_cli terminate
    
    echo "sleep 3"
    sleep 3
    
    echo "dhclient -r"
    dhclient -r
    
    echo "route del default"
    route del default
    
    echo "ifconfig $G_HOST_IF0_1_0 $G_HOST_TIP0_1_0/24 up"
    ifconfig $G_HOST_IF0_1_0 $G_HOST_TIP0_1_0/24 up
    
    echo "route add default gw $G_PROD_IP_BR0_0_0 dev $G_HOST_IF0_1_0"
    route add default gw $G_PROD_IP_BR0_0_0 dev $G_HOST_IF0_1_0
    
    current_case=`echo $G_CURRENTLOG |grep -o "B.*xml"`
    #/dev/shm/current/B-GEN-WI.SEC-001.xml_3
    echo "current case $current_case"
    #current_case="B-GEN-WI.SEC-001.xml"
    #echo "current case $current_case"
    #B-GEN-WI.SEC-001.xml;1;1
    is_need_restore=0
    
    for line in `cat $wifi_restore_configure_file`
    do
        is_comment=`echo $line |cut -c1`
        case_name=`echo $line |cut -d: -f1`
        #is_configure=`echo $line |cut -d: -f2`
        if [ "$is_comment" != "#" -a "$case_name" == "$current_case" ] ;then
            is_need_restore=`echo $line |cut -d: -f3`
        fi
    done
    
    if [ $is_need_restore -eq 1 ] ;then
        $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-$U_DUT_TYPE-WI.CON-001-C999 $U_AUTO_CONF_PARAM
    fi
    exit 0
else
    echo "ERROR : CONFIG_LOAD file not found!"
    exit 1
fi
