#!/bin/bash
# Author        :   Howard Yin(hying@actiontec.com)
# Description   :
#   This tool is using to restore the DUT wireless settings
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version       
#02 Nov 2011    |   1.0.1   | howard    | added support for SSID 2 3 4
#09 Jan 2012    |   1.0.2   | Alex      | modified the option of command 'dhclient',add '-pf' option
#10 Jan 2012    |   1.0.3   | rayofox   | code review with Howard
#21 Mar 2012    |   1.0.4   | howard    | disable all wlan NIC before doing restore

REV="$0 version 1.0.4 (21 Mar 2012)"
# print REV

echo "${REV}"
if [ -f "${U_CUSTOM_CONFIG_LOAD}" ] ;then
    wifi_restore_configure_file=$U_CUSTOM_CONFIG_LOAD
    
    #killall wpa_supplicant
    echo "killall wpa_supplicant"
    pgrep wpa_supplicant|xargs -n1 kill -9 2>/dev/null
    
    # disable wlan 
    echo ""
    echo "gordon change to not to do disable wlan"
    
##    for wl_ifc in `iwconfig  2> /dev/null | grep -o ".*SSID"|awk '{print $1}'`
##  do
##      echo "  wpa_cli -i $wl_ifc disconnect"
##      wpa_cli -i $wl_ifc disconnect
        
##      echo "  ip -4 addr flush dev $wl_ifc"
##      ip -4 addr flush dev $wl_ifc
    
##      echo "        removing existing /tmp/${wl_ifc}.conf"
##      rm -f /tmp/${wl_ifc}.conf
##  done
        
##    echo ""
    
    
##    echo "sleep 3"
##    sleep 3
    
    # killall dhclient pid
    echo ""
    echo "just killall dhclient"
    killall dhclient

    bash $U_PATH_TBIN/verifyDutLanConnected.sh
    

    ping_rc=$?

    if [ $ping_rc -ne 0 ] ;then
        echo "AT_ERROR : DUT br0 is currently unreachable ... "
        exit $ping_rc
    fi
    
    current_case=`echo $G_CURRENTLOG |grep -o "B.*xml"`

    echo "current case $current_case"

    is_lnk=`ls -l $U_PATH_WIFITC/$current_case | cut -c 1`

    if [ "$is_lnk" == "l" ] ; then
        current_case=`readlink -f $U_PATH_WIFITC/$current_case | xargs basename`
    fi

    #/dev/shm/current/B-GEN-WI.SEC-001.xml_3
    
    echo "actually , current is a link to -> $current_case"
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
        $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-GEN-WI.CON-001-C999 $U_AUTO_CONF_PARAM

        conf_rc=$?

        if [ $conf_rc -ne 0 ] ;then
            echo "AT_ERROR : configure DUT failed , please check your settings .."
            exit $conf_rc
        fi
    fi
    exit 0
else
    echo "AT_ERROR : CONFIG_LOAD file not found!"
    exit 1
fi
