#!/bin/bash
# Author        :   Howard Yin(hying@actiontec.com)
# Description   :
#   This tool is using to configure the DUT
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version       
#02 Nov 2011    |   1.0.1   | howard    | added support for SSID 2 3 4
#   change history:

#   02 Nov 2011 added :
#       is_lnk=`ls -l $U_PATH_WIFITC/$current_case | cut -c 1`
#
#       if [ "$is_lnk" == "l" ] ; then
#           current_case=`ls -l  $U_PATH_WIFITC/$current_case | awk -F\> '{print $2}'|grep -o "B.*xml"`
#       fi


REV="$0 version 1.0.1 (2 Nov 2011)"
# print REV

echo "${REV}"
#$U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-GEN-WI.SEC-$current_case_index-C001
if [ "$U_DUT_TYPE" == "WECB" ] || [ "$U_DUT_TYPE" == "NcsWecb3000" ] || [ "$U_DUT_TYPE" == "TelusWecb3000"] || ["$U_DUT_TYPE" == "ComcastWecb3000"] || [ "$U_DUT_TYPE" == "VerizonWecb3000"];then
    echo "For WECB"
fi

if [ -f "${U_CUSTOM_CONFIG_LOAD}" ] ;then

    wifi_restore_configure_file=$U_CUSTOM_CONFIG_LOAD
    
    current_case=`echo $G_CURRENTLOG |grep -o "B.*xml"`
    source_case=$current_case
    echo "current case $current_case"

    is_lnk=`ls -l $U_PATH_WIFITC/$current_case | cut -c 1`

    if [ "$is_lnk" == "l" ] ; then
        if [ "$U_DUT_TYPE" == "WECB" ] || [ "$U_DUT_TYPE" == "NcsWecb3000" ] || [ "$U_DUT_TYPE" == "TelusWecb3000"] || ["$U_DUT_TYPE" == "ComcastWecb3000"] || [ "$U_DUT_TYPE" == "VerizonWecb3000"];then
            source_case=`readlink -f $U_PATH_WIFITC/$current_case | xargs basename`
            echo "WECB : actually , current is a link to -> $source_case"
        else
            current_case=`readlink -f $U_PATH_WIFITC/$current_case | xargs basename`
            echo "actually , current is a link to -> $current_case"
        fi
    fi

    current_case_index=`echo $current_case |awk -F- '{print $4}'|awk -F. '{print $1}'`
    
    is_need_configure=0
    
    for line in `cat $wifi_restore_configure_file`
    do
        is_comment=`echo $line |cut -c1`
        case_name=`echo $line |cut -d: -f1`
    
        #is_configure=`echo $line |cut -d: -f2`
        if [ "$U_DUT_TYPE" == "WECB" ] || [ "$U_DUT_TYPE" == "NcsWecb3000" ] || [ "$U_DUT_TYPE" == "TelusWecb3000"] || ["$U_DUT_TYPE" == "ComcastWecb3000"] || [ "$U_DUT_TYPE" == "VerizonWecb3000"];then
            if [ "$is_comment" != "#" -a "$case_name" == "$source_case" ] ;then
                is_need_configure=`echo $line |cut -d: -f2`
            fi
        else
            if [ "$is_comment" != "#" -a "$case_name" == "$current_case" ] ;then
                is_need_configure=`echo $line |cut -d: -f2`
            fi
        fi
    done
    
    if [ $is_need_configure -eq 1 ] ;then
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-GEN-WI.SEC-$current_case_index-C001 $U_AUTO_CONF_PARAM"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-GEN-WI.SEC-$current_case_index-C001 $U_AUTO_CONF_PARAM

        conf_rc=$?

        if [ $conf_rc -ne 0 ] ;then
            echo "AT_EEROR : configure DUT failed , please check your settings .."
            exit $conf_rc
        fi
    fi

    exit 0

else
    echo "AT_ERROR : CONFIG_LOAD file not found !:<$U_CUSTOM_CONFIG_LOAD>"
    exit 1
fi
