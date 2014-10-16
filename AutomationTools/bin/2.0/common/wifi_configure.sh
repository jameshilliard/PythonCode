#!/bin/bash
# Author        :   Howard Yin(hying@actiontec.com)
# Description   :
#   This tool is using to configure/restore the DUT
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#13 Dec 2011    |   1.0.0   | howard    | Inital Version       
# 9 Jan 2012    |   1.0.1   | Alex      | modified the option of command 'dhclient',add '-pf' option
#10 Jan 2012    |   1.0.2   | rayofox   | code review with Howard


REV="$0 version 1.0.2 ( 10 Jan 2012)"
# print REV

echo "${REV}"

USAGE(){
    cat <<usge
    USAGE : bash $0 -configure / -restore  -v "key = value"
    
    OPTIONS:
    
          -configure
                    :   use this option to configure DUT
          -restore
                    :   use this option to restore DUT
          -v
                    :   temp variables
    
    NOTE : Do NOT use -configure and -restore togather !!!
    
usge

}

option=configure

while [ -n "$1" ];
do
    case "$1" in
    -configure)
        option=configure
        echo "option : ${option}"
        shift 1
        ;;
    -restore)
        option=restore
        echo "option : ${option}"
        shift 1
        ;;
    -v)
        param=$2
        echo "param is : ${param}"
        shift 2
        ;;
    -help)
        USAGE
        exit 1
        ;;
    *)
        USAGE
        exit 1
        ;;
    esac
done
#   B-GEN-WI.SEC-001.xml
configure(){
    if [ -f "${U_CUSTOM_CONFIG_LOAD}" ] ;then
    
        wifi_restore_configure_file=$U_CUSTOM_CONFIG_LOAD
        
        current_case=`echo $G_CURRENTLOG | xargs basename |grep -o "B.*xml"`
    
        echo "current case $current_case"
    
        #$U_PATH_WIFITC
        is_lnk=`ls -l $U_PATH_WIFITC/$current_case | cut -c 1`
    
        if [ "$is_lnk" == "l" ] ; then
            current_case=`readlink -f $U_PATH_WIFITC/$current_case | xargs basename`
            echo "actually , current is a link to -> $current_case"
        fi
    
        current_case_index=`echo $current_case |awk -F- '{print $4}'|awk -F. '{print $1}'`
        current_case_class=`echo $current_case |awk -F- '{print $3}'`
    
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
            if [ -n "$param" ] ;then
                $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-GEN-$current_case_class-$current_case_index-C001 -v "$param" $U_AUTO_CONF_PARAM
            else
                $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-GEN-$current_case_class-$current_case_index-C001 $U_AUTO_CONF_PARAM
            fi
        fi
    
        conf_rc=$?

        if [ $conf_rc -ne 0 ] ;then
            echo "AT_ERROR : configure DUT failed , please check your settings .."
            exit $conf_rc
        fi
    
    else
        echo "AT_ERROR : CONFIG_LOAD file not found ! :<$U_CUSTOM_CONFIG_LOAD>"
        exit 1
    fi
}

restore(){
    if [ -f "${U_CUSTOM_CONFIG_LOAD}" ] ;then
        wifi_restore_configure_file=$U_CUSTOM_CONFIG_LOAD
        
        #killall wpa_supplicant
        #echo "wpa_cli terminate"
        #wpa_cli terminate
        # disable wlan 

        echo ""
        echo "to disable wlan"
        wpa_cli disconnect
        
        ip -4 addr flush dev $U_WIRELESSINTERFACE
        echo ""
    
        echo "sleep 3"
        sleep 3
        
        # killall dhclient pid
        echo ""
        echo "killall dhclient"
        killall dhclient
    
        #bcast=`echo $G_PROD_GW_BR0_0_0 |cut -d. -f 1,2,3`"\."
        #echo $bcast
        #downifs=`ifconfig | grep -B 1 $bcast |grep HWaddr |grep -v $interface| awk '{print $1}'`
        #for ifs in `echo $downifs`
        #do
        #    ps aux|grep dhclient|grep $ifs|grep -o "dhclient .*"|sed "s/dhclient/dhclient -r/g" |while read cmd
        #    do
        #        echo "command :$cmd"
        #        $cmd
        #    done
        #done
        
        #echo "route del default"
        #route del default
        
        #echo "ip link set $G_HOST_IF0_1_0 $G_HOST_TIP0_1_0/24 up"
        #ip link set $G_HOST_IF0_1_0 up
        #ip addr add $G_HOST_TIP0_1_0/24 dev $G_HOST_IF0_1_0 
        
        #echo "route add default gw $G_PROD_IP_BR0_0_0 dev $G_HOST_IF0_1_0"
        #route add default gw $G_PROD_IP_BR0_0_0 dev $G_HOST_IF0_1_0
        
        bash $U_PATH_TBIN/verifyDutLanConnected.sh
        
        ping_rc=$?
        
        if [ $ping_rc -ne 0 ] ;then
            echo "AT_ERROR : DUT br0 is currently unreachable ... "
            exit $ping_rc
        fi
    
        
        current_case=`echo $G_CURRENTLOG | xargs basename |grep -o "B.*xml"`
        current_case_class=`echo $current_case |awk -F- '{print $3}'`
        echo "current case $current_case"
    
        is_lnk=`ls -l $U_PATH_WIFITC/$current_case | cut -c 1`
    
        if [ "$is_lnk" == "l" ] ; then
            current_case=`readlink -f $U_PATH_WIFITC/$current_case | xargs basename`
            echo "actually , current is a link to -> $current_case"
        fi
    
        is_need_restore=0
        
        for line in `cat $wifi_restore_configure_file`
        do
            is_comment=`echo $line |cut -c1`
            case_name=`echo $line |cut -d: -f1`

            if [ "$is_comment" != "#" -a "$case_name" == "$current_case" ] ;then
                is_need_restore=`echo $line |cut -d: -f3`
            fi
        done
        
        if [ $is_need_restore -eq 1 ] ;then
            if [ -n "$param" ] ;then
                $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-GEN-$current_case_class-001-C999 -v "$param" $U_AUTO_CONF_PARAM 
            else
                $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/B-GEN-$current_case_class-001-C999 $U_AUTO_CONF_PARAM
            fi
        fi
        conf_rc=$?

        if [ $conf_rc -ne 0 ] ;then
            echo "AT_ERROR : resotre configure DUT failed , please check your settings .."
            exit $conf_rc
        fi
    else
        echo "AT_ERROR : CONFIG_LOAD file not found! : <$U_CUSTOM_CONFIG_LOAD>"
        exit 1
    fi
}

$option
