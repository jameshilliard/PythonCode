#!/bin/bash
# Author        :   Howard Yin(hying@actiontec.com)
# Description   :
#   This tool is using to configure the DUT
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version       
#

REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV

echo "${REV}"
#$U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-$U_DUT_TYPE-WI.SEC-$current_case_index-C001
if [ -f "${U_CUSTOM_CONFIG_LOAD}" ] ;then

    wifi_restore_configure_file=$U_CUSTOM_CONFIG_LOAD
    
    current_case=`echo $G_CURRENTLOG |grep -o "B.*xml"`
    current_case_index=`echo $current_case |awk -F- '{print $4}'|awk -F. '{print $1}'`
    echo "current case $current_case"
    is_need_configure=0
    
    for line in `cat $wifi_restore_configure_file`
    do
        is_comment=`echo $line |cut -c1`
        case_name=`echo $line |cut -d: -f1`
    
        #is_configure=`echo $line |cut -d: -f2`
        if [ "$is_comment" != "#" -a "$case_name" == "$current_case" ] ;then
            is_need_configure=`echo $line |cut -d: -f2`
        fi
    done
    
    if [ $is_need_configure -eq 1 ] ;then
        $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-$U_DUT_TYPE-WI.SEC-$current_case_index-C001 $U_AUTO_CONF_PARAM
    fi

    exit 0

else
    echo "ERROR : CONFIG_LOAD file not found !"
    exit 1
fi
