#!/bin/bash
#---------------------------------
# Name: Howard Yin
# Description:
# This script is used to connect a wireless adapter to DUT.
#
#--------------------------------
# History    :
#   DATE        |   REV  | AUTH   | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version
#15 Nov 2011    |   1.0.1   | howard    | support static IP connect (not dhclient -r in static IP mode)
#22 Dec 2011    |   1.0.2   | howard    | changed wpa , NOT to wpa_cli terminate each time
#23 Dec 2011    |   1.0.3   | howard    | manage all wlan card this version
#27 Dec 2011    |   1.0.4   | howard    | when 4WAY_HANDSHAKE , restart wpa_supplicant
#07 Jan 2012    |   1.0.5   | howard    | do dhclient when status is completed in negative test mode and ping wan
# 9 Jan 2012    |   1.0.6   | Alex      | modified the option of command 'dhclient',add '-pf' option
#10 Jan 2012    |   1.0.7   | rayofox   | code review with Howard, redesign the connect flow,add more retry and output info
#12 Jan 2012    |   1.0.8   | howard    | added customized positive and negative retry time support
#01 Feb 2012    |   1.0.9   | howard    | fixed retry mechanize when wpa_cli status is 4WAY_HANDSHAKE in negative test mode
#06 Mar 2012    |   1.0.10  | howard    | added retry mechanize when wpa status is COMPLETED
#12 Mar 2012    |   1.0.11  | howard    | added retry whole fetch IP flow with another wifi_client routine
#27 Mar 2012    |   1.0.12  | howard    | added function to match client setting and server setting
#13 Apr 2012    |   1.0.13  | howard    | added try again with same wifi client when failed to get IP
#03 Sep 2012    |   1.0.14  | howard    | try ping LAN after connected to AP with static IP


REV="$0 version 1.0.14 (03 Sep 2012)"
# print REV
echo "${REV}"


while [ $# -gt 0 ]
do
    case "$1" in
    -n)
        nega=1
        echo "negative mode engaged!"
        shift 1
        ;;
    -f)
        file=$2
        echo "Config file : ${file}"
        dut_ap=`cat ${file}| grep " ssid=" | awk -F"\"" '{print $2}'`
        echo "DUT AP is : $dut_ap"
        shift 2
        ;;
    -i)
        interface=$2
        echo "Interface : ${interface}"
        shift 2
        ;;
    -t)
        waittimes=$2
        echo "testtimes : ${waittimes}"
        shift 2
        ;;
    -ip)
        address=$2
        echo "ipaddress used in static"
        shift 2
        ;;
    -H)
        hostname=$2
        echo "dhclient host name is ${hostname}"
        shift 2
        ;;
    -wps)
        wps_type=$2
        echo "wps_type is ${wps_type}"
        shift 2
        ;;
    -w)
        capture_flag=$2
        shift 2
        ;;
    -test)
        echo "engaged test mode"
        G_PROD_IP_BR0_0_0=192.168.0.1
        shift 1
        ;;

    *)
    echo "bash $0 -f <configFile> -i <interface> -t <waittimes> -ip <ipaddress for static> -H <hostname>"
        exit 1
        ;;
    esac
done



if [ -z ${nega} ] ;then
    nega=0
fi

if [ -z ${capture_flag} ];then
    capture_flag=1
fi

if [ "x$U_TMP_USING_NTGR" == "x1" ] ;then
    capture_flag=0
fi

debug_pause=0
tried_again=1
count=1
wpa_restart_retry=3
sleep_time=10
check_status_time=30
check_retry=5
mismatch_retry=24
wpa_logfile="/tmp/wpa_supplicant.log"
dhclient_time=5
dhclient_chance=$dhclient_time
#dut_ap=""


#
if [ -z "$waittimes" ];then
    waittimes=10
fi

if [ -z $U_CUSTOM_WIFI_SWITCH ] ;then
    echo "  no failed switch wifi card mode !"
    tried_again=4
fi

#   positive :  waittimes=$U_CUSTOM_WIFI_CONNECT_RETRY_POSITIVE
#   negative :  waittimes=$U_CUSTOM_WIFI_CONNECT_RETRY_NEGATIVE

if [ ${nega} -eq 0 ] ;then
    #positive test
    if [ ! -z $U_CUSTOM_WIFI_CONNECT_RETRY_POSITIVE ] ;then
        echo "re-defined connect retry time to ${U_CUSTOM_WIFI_CONNECT_RETRY_POSITIVE} ."
        waittimes=$U_CUSTOM_WIFI_CONNECT_RETRY_POSITIVE
    fi
else
    #negative test
    if [ ! -z $U_CUSTOM_WIFI_CONNECT_RETRY_NEGATIVE ] ;then
        echo "re-defined connect retry time to ${U_CUSTOM_WIFI_CONNECT_RETRY_NEGATIVE} ."
        waittimes=$U_CUSTOM_WIFI_CONNECT_RETRY_NEGATIVE
    fi
fi

compare_client_server(){
    compare_retry=10
    server_setting=""

    if [ "$dut_ap" == "$U_WIRELESS_SSID1" ] ;then
        curr_bssid=$U_WIRELESS_BSSID1
    elif [ "$dut_ap" == "$U_WIRELESS_SSID2" ] ;then
        curr_bssid=$U_WIRELESS_BSSID2
    elif [ "$dut_ap" == "$U_WIRELESS_SSID3" ] ;then
        curr_bssid=$U_WIRELESS_BSSID3
    elif [ "$dut_ap" == "$U_WIRELESS_SSID4" ] ;then
        curr_bssid=$U_WIRELESS_BSSID4
    fi

#   mismatch_retry=24
    let "mismatch_retry=$mismatch_retry-1"

    if [ $mismatch_retry -gt 0 ] ;then


        for c_retry in `seq 1 $compare_retry`
        do
            echo "try to match client and server : try $c_retry"
            #wpa_cli -i $interface scan

            server_setting=`wpa_cli -i $interface scan 1>/dev/null;wpa_cli -i $interface scan_results | grep  "^$curr_bssid.*$dut_ap\$" |awk '{print $4}'`

            if [ "$server_setting" != "" ] ;then
                echo "  Got server setting !"
                break
            else
                echo "  not got server setting yet"
                echo "      sleep 6"
                sleep 6
            fi
        done



        echo "  wifi setting on server : $server_setting"

        if [ "$server_setting" != "" ] ;then

            client_setting=`cat ${file} | grep "key_mgmt" | awk -F= '{print $2}'`

            if [ "$client_setting" == "WPA-PSK" ] ;then

                client_setting_proto=`cat ${file} | grep "proto" | awk -F= '{print $2}'`

                if [ "$client_setting_proto" == "WPA" ] ;then
                    client_setting="WPA-PSK"
                elif [ "$client_setting_proto" == "RSN" ] ;then
                    client_setting="WPA2-PSK"
                elif [ "$client_setting_proto" == "WPA RSN" ] ;then
                    client_setting="WPA.*-PSK"
                fi

                echo "  client setting is $client_setting"

                client_setting_pairwise=`cat ${file} | grep "pairwise" | awk -F= '{print $2}'`

                if [ "$client_setting_pairwise" == "TKIP" ] ;then
                    client_setting=$client_setting"-TKIP"
                elif [ "$client_setting_pairwise" == "CCMP" ] ;then
                    client_setting=$client_setting"-.*CCMP"
                fi

                echo "  client setting is $client_setting"

            elif [ "$client_setting" == "WPA-EAP" ] ;then

                client_setting_proto=`cat ${file} | grep "proto" | awk -F= '{print $2}'`

                if [ "$client_setting_proto" == "WPA" ] ;then
                    client_setting="WPA-EAP"
                elif [ "$client_setting_proto" == "RSN" ] ;then
                    client_setting="WPA2-EAP"
                fi

                echo "  client setting is $client_setting"

                client_setting_pairwise=`cat ${file} | grep "pairwise" | awk -F= '{print $2}'`

                if [ "$client_setting_pairwise" == "TKIP" ] ;then
                    client_setting=$client_setting"-TKIP"
                elif [ "$client_setting_pairwise" == "CCMP" ] ;then
                    client_setting=$client_setting"-.*CCMP"
                fi

                echo "  client setting is $client_setting"
            elif [ "$client_setting" == "IEEE8021X" ] ;then

                client_setting="WEP"

                echo "  client setting is $client_setting"

            elif [ "$client_setting" == "NONE" ] ;then

                client_setting_proto=`cat ${file} | grep "auth_alg" | awk -F= '{print $2}'`

                if [ "$client_setting_proto" != "" ] ;then
                    echo "  client setting is WEP $client_setting_proto"
                    client_setting="WEP"
                else
                    echo "  client setting is NONE"

                    client_setting="NONE"
                fi
            fi

            if [ "$client_setting" == "NONE" ] ;then
                echo "egrep \"\[WPS\]\"*\"\[ESS\]\""
                is_match=`echo $server_setting | grep -v "WPA" | grep -v "WEP"`
            else
                echo "egrep \"$client_setting\""
                is_match=`echo $server_setting | grep "$client_setting"`
            fi

            echo "  is_match : $is_match"

            if [ "$is_match" == "" ] ;then
                if [ $nega -eq 0 ] ;then
                    echo "  WARNING : client setting does not match the server setting"
                    sleep 10

                    compare_client_server

                elif [ $nega -eq 1 ] ;then
                    echo "  WARNING : client setting does not match the server setting"
                fi
            else
                echo "  client setting matches the server setting"
            fi
        else
            echo "  CANNOT scan the SSID $dut_ap , maybe it is in SSID broadcast hide mode ."
        fi
    else
        echo "  client and server did not match after all retry"
        echo "-| AT_ERROR : check wireless security mode failed ! The scan result($server_setting) is not matched to expected($client_setting)"
        pause
        if [ "$capture_flag" == "1" ];then
            stop_mon_capture
        fi
        exit 1
    fi

    }

#
dumpStateFlow(){
    cp -f $wpa_logfile $G_CURRENTLOG/
    echo -e "\n\n\n----------------"
    echo "WPA State Flow :"
    cat $wpa_logfile | grep "State:"
    echo -e "----------------\n\n\n"
    truncate -s 0 $wpa_logfile
}

pause(){
    #touch $G_LOG/current/skip_all_rest.LABEL

    if [ $debug_pause -eq 1 ] ;then
        echo "failed to fetch IP from DUT ,skiped all rest cases " | tee $G_LOG/current/skip_all_rest.LABEL
        echo "wpa_cli term"
        wpa_cli term
    else
        echo ""
    fi
    }

check_wlan_on(){
    if [ $check_wlan_on_retry -eq 0 ] ;then
        echo "AT_EEROR : timeout to turn on wlan($interface) !"
        #restore_net
        exit 1
    fi

    echo "ifconfig |grep $interface"
    is_wlan_on=`ifconfig |grep -o "$interface"`

    if [ "$is_wlan_on" == "$interface" ] ;then
        echo "$interface is ready,check wlan on PASS!"
        if [ "${capture_flag}" == "1" ];then
            start_mon_capture $interface
        fi
    else
        echo "ifconfig -a |grep $interface"
        is_wlan_exists=`ifconfig -a |grep -o "$interface"`

        if [ "$is_wlan_exists" == "" ] ;then
            echo "AT_ERROR : no such device as $interface on this machine ."
            let "check_wlan_on_retry=$check_wlan_on_retry-1"
            echo "sleep 5s,check it again..."
            sleep 5
            check_wlan_on
            #exit 1
        fi

        echo "$interface is not ready as it is supposed to be ...up down it and try again ..."

        echo "ip link set $interface up"
        ip link set $interface up

        echo "sleep 5 ... zzz"
        sleep 5

        let "check_wlan_on_retry=$check_wlan_on_retry-1"

        check_wlan_on
    fi
}

restart_wpa(){
    if [ $wpa_restart_retry -gt 0 ] ;then
        wpa_restart_retry=$((${wpa_restart_retry}-1))
        echo "try restart wpa_supplicant --- left $wpa_restart_retry"

        echo "  wpa_cli terminate"
        wpa_cli terminate
        
        if [ "$U_CUSTOM_NO_WECB" == "0" ] ;then
            #echo "DO IT  , NOW !!!"
            #sleep 10
            if [ "$capture_flag" == "1" ];then
                stop_mon_capture
            fi
            for i in `seq 1 3`
            do
                echo "Try $i times to plug wireless card $interface by switch_board!"
                echo "bash $U_PATH_TBIN/switch_controller.sh -u 0"
                bash $U_PATH_TBIN/switch_controller.sh -u 0
                rc_flash_u=$?
                echo "sleep 5s"
                sleep 5
                if [ "$rc_flash_u" == "0" ] ;then
                    echo "bash $U_PATH_TBIN/switch_controller.sh -u 1"
                    bash $U_PATH_TBIN/switch_controller.sh -u 1
                    rc_flash_u=$?
                    if [ "$rc_flash_u" == "0" ] ;then
                        echo "AT_INFO : turn on usb 1 passed"
                        echo "sleep 15s"
                        sleep 15
                        check_wlan_on_retry=10
                        check_wlan_on
                        break
                    else
                        echo "AT_ERROR : failed to turn on usb1"
                        if [ $i -ge 3 ];then
                            if [ "$capture_flag" == "1" ];then
                                stop_mon_capture
                            fi
                            exit 1
                        fi
                        echo "sleep 10s,try another times..."
                        sleep 10
                    fi
                else
                    echo "AT_ERROR : failed to turn down usb1"
                    if [ $i -ge 3 ];then
                        if [ "$capture_flag" == "1" ];then
                            stop_mon_capture
                        fi
                        exit 1
                    fi
                    echo "sleep 10s,try another times..."
                    sleep 10
                fi
            done
        fi

        #echo "sleep 15s"

        #sleep 15

        if_wlan_on=`ifconfig | grep "$interface";echo $?`

        if [ "$if_wlan_on" == "1" ] ;then
            echo "  ip link set $interface up"
            ip link set $interface up
            sleep 5
        fi

        check_retry=5

        check_wpa

    else
        echo "-| AT_ERROR : restarting wpa_supplicant timeout(3 times)"
        pause
        if [ "$capture_flag" == "1" ];then
            stop_mon_capture
        fi
        exit 1
    fi

}

check_wpa(){
    # loop check
    echo "check wpa_supplicant left --$check_retry"

    if [ $check_retry -eq 0 ];then
        echo "AT_ERROR : retry check wpa_supplicant timeout"
        if [ "$capture_flag" == "1" ];then
            stop_mon_capture
        fi
        exit 1
    fi

    let "check_retry=$check_retry-1"

    #
    pgrep wpa_supplicant|xargs -n1 kill -9 2>/dev/null

    if_wlan_on=`ifconfig | grep "$interface"`

    if [ "$if_wlan_on" == "" ] ;then
        echo "  ip link set $interface up"
        ip link set $interface up
        sleep 5
    fi
    echo ""
    echo "  start control $interface with wpa_supplicant"

    wlan_conf_list="wpa_supplicant -d -f $wpa_logfile -i $interface -c /tmp/${interface}.conf -B "

    if [ -f "/tmp/${interface}.conf" ] ;then
        echo "    removing existing /tmp/${interface}.conf"
        rm -f /tmp/${interface}.conf

        echo "    cp $file /tmp/${interface}.conf"
        cp $file /tmp/${interface}.conf
    else
        echo "    cp $file /tmp/${interface}.conf"
        cp $file /tmp/${interface}.conf
    fi

    rm -rf $wpa_logfile

    echo $wlan_conf_list

    $wlan_conf_list

    if [ $? -gt 0 ] ;then
        cp -rf $wpa_logfile $G_CURRENTLOG/
        echo "-| AT_ERROR : $wlan_conf_list FAILED ! "
        exit 1
    else
        compare_client_server
    fi

    #check_wpa

}



add_default_route(){
    echo "route del default;route add default gw $G_HOST_GW0_1_0  dev ${interface}"
    route del default;route add default gw $G_HOST_GW0_1_0  dev ${interface}

    echo "ifconfig ${interface}"
    ifconfig ${interface}

    echo "iwconfig ${interface}"
    iwconfig ${interface}

    echo "route -n"

    route -n

}

check_channel(){
    #   frequency=$freq
        #   iwlist ${interface} channel |grep -o  "Current Frequency:[0-9.]* GHz" |grep -o "[0-9.]*"|sed "s/\.//g"
        client_freq=`cat $file |grep "frequency=" |awk -F= '{print $2}'`

        if [ -n "$client_freq" ] ;then
            server_freq=`iwlist ${interface} channel |grep -o  "Current Frequency:[0-9.]* GHz" |grep -o "[0-9.]*"|sed "s/\.//g"`

            echo "  client freq : $client_freq"
            echo "  server freq : $server_freq"

            if [ "$client_freq" != "$server_freq" ] ;then
                echo "  AT_ERROR : client freq did not match the server freq"
                pause

                exit 1
            else
                echo "  client freq  match the server freq"
            fi
        fi

    }
start_mon_capture(){
    echo "Entry start_mon_capture()"
    cap_iface=$1
        
        for i in `seq 1 1`
        do        
            echo "Try $i times... "
            echo "ip link set $cap_iface up"
            ip link set $cap_iface up
            return_code=$?
            echo "return_code : $return_code"
            sleep 2

            if [ "$U_TMP_USING_NTGR" != "1" ];then
                echo "Start mon capture on TPLINK"
                rm -f $G_CURRENTLOG/iwconfig_interface.log
                rm -f $G_CURRENTLOG/ifconfig_mon_result.log
                iwconfig |tee $G_CURRENTLOG/iwconfig_interface.log 
                grep "^ *mon[0-9][0-9]* *IEEE.*Mode.*" $G_CURRENTLOG/iwconfig_interface.log
                if [ $? -eq 0 ];then
                    grep "^ *mon[0-9][0-9]* *IEEE.*Mode.*" $G_CURRENTLOG/iwconfig_interface.log|grep -o "^ *mon[0-9][0-9]* *"|sed 's/^ *//g'|sed 's/ *$//g'|tee $G_CURRENTLOG/ifconfig_mon_result.log
                    echo "del wireless interface belong to 'Mode:Monitor'"
                    for mon_interface in `cat $G_CURRENTLOG/ifconfig_mon_result.log`
                    do
                        echo ">${mon_interface}<"
                        echo "iw dev ${mon_interface} del"
                        iw dev ${mon_interface} del
                        return_code=$?
                        echo "return_code : $return_code"
                    done
                else
                    echo "Not exist wireless interface belong to 'Mode:Monitor'"
                fi
                
                echo "Name Monitor wireless card"
                echo "U_WIRELESSINTERFACE : $cap_iface"
                num=`echo $cap_iface|grep -o "[0-9][0-9]*$"`
                if [ -z "$num" ];then
                    moniface="mon1"
                fi
                moniface="mon${num}"
                echo "Monitor   interface : $moniface"
                echo "Put the wireless driver into Monitor Mode"
                echo "iw dev $cap_iface interface add $moniface type monitor"
                iw dev $cap_iface interface add $moniface type monitor
                return_code=$?
                echo "return_code : $return_code"
                sleep 2
            else
                echo "Start mon capture on Netgear"
                #${U_PATH_TOOLS}/netgear/wlx86 monitor 0
                #sleep 2
                ${U_PATH_TOOLS}/netgear/wlx86 monitor 1
                sleep 2
                moniface=`ifconfig -a|grep -o "^ *prism[0-9][0-9]*"`

            fi

            

            echo "ip link set $moniface up"
            ip link set $moniface up
            return_code=$?
            echo "return_code : $return_code"
            
            date1=`date +%m%d%H%M%S`
            
            echo "Sniff the wireless packets in air : $moniface"
            echo "bash $U_PATH_TBIN/raw_capture.sh --local -i $moniface -o lan_${moniface}_${date1}.cap -t 3600 --begin"
            sleep 5
            bash $U_PATH_TBIN/raw_capture.sh --local -i $moniface -o lan_${moniface}_${date1}.cap -t 3600 --begin
            return_code=$?
            echo "return_code : $return_code"
            
            if [ $return_code -eq 0 ];then
                echo "Sniff the wireless(${moniface}) packets in air SUCCESS!"
                ifconfig
                route -n
                break
            fi
            echo "Sniff the wireless(${moniface}) packets in air FAIL!"
        done
    }
start_wlan_capture(){
    echo "Entry start_wlan_capture()"
    cap_iface=$1
    for i in `seq 1 1`
    do        
        echo "Try $i times... "
        pid2kill=`ps aux|grep -v grep|grep tshark|grep "\-i  *${interface}"|awk '{print $2}'`
        echo "pid2kill:$pid2kill"
        if [ -n "$pid2kill" ];then
            echo "kill -9 ${pid2kill}"
            kill -9 ${pid2kill}
        fi
        echo "ip link set $cap_iface up"
        ip link set $cap_iface up
        return_code=$?
        echo "return_code : $return_code"
        sleep 2
        
        curdate=`date +%m%d%H%M%S`
        
        echo "Sniff the wireless packets in air : $cap_iface"
        echo "bash $U_PATH_TBIN/raw_capture.sh --local -i $cap_iface -o lan_${cap_iface}_${curdate}.cap -t 3600 --begin"
        sleep 5
        bash $U_PATH_TBIN/raw_capture.sh --local -i $cap_iface -o lan_${cap_iface}_${curdate}.cap -t 3600 --begin
        return_code=$?
        echo "return_code : $return_code"
        pid2kill=`ps aux|grep -v grep|grep tshark|grep "$G_CURRENTLOG/lan_${cap_iface}_${curdate}.cap"|awk '{print $2}'`
        echo "pid2kill:$pid2kill"
        if [ -n "$pid2kill" ];then
            echo "kill -9 ${pid2kill}" |tee -a ${G_CURRENTLOG}/kill_tshark_${interface}_${curdate}
            echo "U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE : ${U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE}"
            export U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE="${G_CURRENTLOG}/jobs_after_case"
            echo "U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE : ${U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE}"
            echo "${G_CURRENTLOG}/kill_tshark_${interface}_${curdate}"|tee -a ${U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE}
            echo "---------------------------------------------"
            cat ${U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE}
            echo "---------------------------------------------"
        fi
        if [ $return_code -eq 0 ];then
            echo "Sniff the wireless(${cap_iface}) packets in air SUCCESS!"
            break
        fi
        echo "Sniff the wireless(${cap_iface}) packets in air FAIL!"
    done
}

stop_mon_capture(){
    echo "Entry stop_mon_capture()"
    echo "Stop capture on Monitor wireless card : $moniface"
    echo "bash $U_PATH_TBIN/raw_capture.sh --local -i $moniface -o lan_${moniface}_${date1}.cap --stop"
    sleep 5
    bash $U_PATH_TBIN/raw_capture.sh --local -i $moniface -o lan_${moniface}_${date1}.cap --stop
    return_code=$?
    echo "return_code : $return_code"
    if [ "$U_TMP_USING_NTGR" != "1" ];then
        echo "iw dev $moniface del"
        iw dev $moniface del
    else
        echo "${U_PATH_TOOLS}/netgear/wlx86 monitor 0"
        ${U_PATH_TOOLS}/netgear/wlx86 monitor 0
    fi
    return_code=$?
    echo "return_code : $return_code"
    sleep 5
    ifconfig
    route -n
}

do_connect(){
    let "dhclient_chance=${dhclient_chance}-1"

    if [ -z "$address" ] ;then
        if [ -z "$hostname" ] ;then
            echo "rm -f /tmp/${interface}.pid"
            rm -f /tmp/${interface}.pid
            echo "ps aux |grep dhclient"


            grep_dhc_rc=`ps aux |grep dhclient|grep -v grep`

            if [ "x$grep_dhc_rc" !=  "x" ] ;then
                echo "pgrep dhclient |xargs -n1 -I nnn kill -9 nnn"
                pgrep dhclient |xargs -n1 -I nnn kill -9 nnn
            else
                echo "no remaining dhclient"
            fi
            
            echo "dhclient -v ${interface} -pf /tmp/${interface}.pid 2>&1"
            dhclient -v ${interface} -pf /tmp/${interface}.pid 2>&1

            #
            dhclient_rc0=$?
            
            if [ "${dhclient_rc0}" != "0" ] ;then
                ps aux |grep dhclient|grep -v grep
            fi
            
            #
            echo "killall dhclient"
            killall dhclient

            echo "ps aux |grep dhclient"
            ps aux |grep dhclient

            echo "ifconfig"
            ifconfig
            
            ifconfig ${interface}|grep "inet addr"
            if [ $? -eq 0 ] ;then
                if [ $nega -eq 0 ] ;then

                    echo "positive test passed"

                    #add_default_route
                    dumpStateFlow
                    if [ "$capture_flag" == "1" ];then
                        stop_mon_capture
                    fi
                    exit 0

                elif [ $nega -eq 1 ] ;then
                    #echo "negative test failed"

                    #add_default_route

                    perl $U_PATH_TBIN/verifyPing.pl -d $U_CUSTOM_WAN_HOST -I ${interface} -t 30 -l $G_CURRENTLOG

                    ping_rc=$?
                    if [ $ping_rc -eq 0 ]; then
                        echo "negative test failed"
                        echo "AT_ERROR : negtive failed,$interface connected to DUT, and fetched IP by dhclient"

                        dumpStateFlow

                        #pause
                        if [ "$capture_flag" == "1" ];then
                            stop_mon_capture
                        fi
                        #if [ $dhclient_chance -eq 0 ] ;then
                        exit 1
                        #fi
                    elif [ $ping_rc -ne 0 ]; then
                        echo "negative test passed"
                        dumpStateFlow
                        if [ "$capture_flag" == "1" ];then
                            stop_mon_capture
                        fi
                        exit 0
                    fi

                    #exit 1
                fi

            else
                if [ $nega -eq 0 ] ;then

                    #   tried_again

                    if [ $tried_again -le 3 ] ;then
                        echo "positive test failed"
                        echo "AT_ERROR : $interface connected to DUT, but can NOT fetch IP by dhclient"
                        if [ $dhclient_chance -eq 0 ] ;then
                            try_again
                        fi
                    else
                        echo "positive test failed"
                        echo "AT_ERROR : $interface connected to DUT, but can NOT fetch IP by dhclient"
                        dumpStateFlow

                        pause
                        if [ "$capture_flag" == "1" ];then
                            stop_mon_capture
                        fi
                        if [ $dhclient_chance -eq 0 ] ;then
                            exit 1
                        fi
                    fi
                    #

                elif [ $nega -eq 1 ] ;then
                    echo "negative test passed"

                    dumpStateFlow
                    if [ "$capture_flag" == "1" ];then
                        stop_mon_capture
                    fi
                    exit 0
                fi
            fi
        else
            echo "rm -f /tmp/${interface}.pid"
            rm -f /tmp/${interface}.pid
            echo "dhclient -v ${interface} -H ${hostname} -pf /tmp/${interface}.pid 2>&1"
            dhclient -v ${interface} '-H' ${hostname} -pf /tmp/${interface}.pid 2>&1

            echo "ifconfig "
            ifconfig 

            ifconfig ${interface}|grep "inet addr"
            if [ $? -eq 0 ] ;then
                if [ $nega -eq 0 ] ;then

                    echo "positive test passed"

                    #add_default_route

                    dumpStateFlow
                    if [ "$capture_flag" == "1" ];then
                        stop_mon_capture
                    fi
                    exit 0
                elif [ $nega -eq 1 ] ;then
                    echo "negative test failed"
                    echo "AT_ERROR : negtive failed,$interface connected to DUT, and fetched IP by dhclient"

                    dumpStateFlow

                    #pause
                    #add_default_route
                    if [ "$capture_flag" == "1" ];then
                        stop_mon_capture
                    fi
                    #if [ $dhclient_chance -eq 0 ] ;then
                    exit 1
                    #fi
                fi
            else
                if [ $nega -eq 0 ] ;then
                    if [ $tried_again -le 3 ] ;then
                        echo "positive test failed"
                        echo "AT_ERROR : $interface connected to DUT, but can NOT fetch IP by dhclient"
                        if [ $dhclient_chance -eq 0 ] ;then
                            try_again
                        fi
                    else
                        echo "positive test failed"
                        echo "AT_ERROR : $interface connected to DUT, but can NOT fetch IP by dhclient"
                        dumpStateFlow

                        pause
                        if [ "$capture_flag" == "1" ];then
                            stop_mon_capture
                        fi
                        if [ $dhclient_chance -eq 0 ] ;then
                            exit 1
                        fi
                    fi
                elif [ $nega -eq 1 ] ;then
                    echo "negative test passed"

                    dumpStateFlow
                    if [ "$capture_flag" == "1" ];then
                        stop_mon_capture
                    fi
                    exit 0
                fi
            fi
        fi

    else
        echo "rm -f /tmp/${interface}.pid"
        rm -f /tmp/${interface}.pid
        echo "ps aux |grep dhclient"


        grep_dhc_rc=`ps aux |grep dhclient|grep -v grep`

        if [ "x$grep_dhc_rc" !=  "x" ] ;then
            echo "pgrep dhclient |xargs -n1 -I nnn kill -9 nnn"
            pgrep dhclient |xargs -n1 -I nnn kill -9 nnn
        else
            echo "no remaining dhclient"
        fi
        
        echo "dhclient -v ${interface} -pf /tmp/${interface}.pid 2>&1"
        dhclient -v ${interface} -pf /tmp/${interface}.pid 2>&1

        #
        echo "killall dhclient"
        killall dhclient

        echo "ps aux |grep dhclient"
        ps aux |grep dhclient

        echo "ifconfig"
        ifconfig

        ifconfig ${interface}|grep "inet addr"
        if [ $? -eq 0 ] ;then
            if [ $nega -eq 0 ] ;then

                echo "positive test passed"

                #add_default_route

                ip -4 addr flush dev ${interface}

                ip link set ${interface} up
                ip addr add ${address}/24 dev ${interface}

                echo "set ${interface} to static IP ${address}"

                add_default_route

                dumpStateFlow
                if [ "$capture_flag" == "1" ];then
                    stop_mon_capture
                fi
                exit 0

            elif [ $nega -eq 1 ] ;then
                #echo "negative test failed"

                #add_default_route

                perl $U_PATH_TBIN/verifyPing.pl -d $U_CUSTOM_WAN_HOST -I ${interface} -t 30 -l $G_CURRENTLOG

                ping_rc=$?
                if [ $ping_rc -eq 0 ]; then
                    echo "negative test failed"
                    echo "AT_ERROR : negtive failed,$interface connected to DUT, and fetched IP by dhclient"

                    dumpStateFlow

                    #pause
                    if [ "$capture_flag" == "1" ];then
                        stop_mon_capture
                    fi
                    exit 1
                elif [ $ping_rc -ne 0 ]; then
                    echo "negative test passed"
                    dumpStateFlow
                    if [ "$capture_flag" == "1" ];then
                        stop_mon_capture
                    fi
                    exit 0
                fi

                #exit 1
            fi
        else
            echo "AT_ERROR : fetch IP via dhclient failed !"

            dumpStateFlow
            if [ "$capture_flag" == "1" ];then
                stop_mon_capture
            fi
            exit 1
        fi


    fi
}

do_scan(){

    else_retry=0
    assoced_retry=0
    assoc_retry=0
    scan_retry=0

    while  [ ${count} -le ${waittimes} ]
    do
        echo "try connect to DUT --${count}"
        count=$((${count}+1))
        echo "sleep $check_status_time to wait for wpa_supplicant status"
        sleep $check_status_time
        #
        #   wpa_cli -i $interface scan_results | grep "$dut_ap"
        #
        #wpa_status='wpa_state='`cat $wpa_logfile |grep 'State:' |tail -1 |awk '{print $NF}'`
        wpa_status=`wpa_cli -i $interface status 2>&1 | grep "wpa_state"`
        echo "wpa_cli -i $interface status"
        wpa_cli -i $interface status 2>&1
        echo ""

        #echo "check status : ${wpa_status}"

        if [ "${wpa_status}" == "wpa_state=COMPLETED" ] ; then
            completed_check=0

            for complete_try in `seq 1 15`
            do
                wpa_status=`wpa_cli -i $interface status 2>&1 | grep "wpa_state"`
                if [ "${wpa_status}" == "wpa_state=COMPLETED" ] ; then
                    let "completed_check=$completed_check+1"

                    every_5=`echo "$complete_try%5" |bc`

                    if [ "$every_5" == "0" ] ;then
                        echo "  connection stayed COMPLETED for $complete_try sec(s)"
                    fi

                    echo "sleep 2 to wait for status"
                    sleep 2
                else
                    echo "  connection status changed to ${wpa_status}"
                    break
                fi
            done

            if [ $completed_check -eq 15 ] ;then
                echo "wpa status stays COMPLETED."
                break
            else
                echo "wpa status is not stable."
                restart_wpa
            fi

        elif [ "${wpa_status}" == "wpa_state=SCANNING" ] ; then
            #wpa_cli scan_results
            scan_retry=$((${scan_retry}+1))
            echo "scan retry ==> $scan_retry"
            if [ -z "$dut_ap" ];then
                echo ""
            else
                echo "----------"
                wpa_cli -i $interface scan_results | grep "$dut_ap"
                echo "wpa config:"
                cat ${file}
                echo "----------"
            fi
            if [ ${scan_retry} -eq 4 -a "$nega" == "0" ];then
                scan_retry=0
                #
                echo "--------------"
                echo -e "Scan results : \n"`wpa_cli -i $interface scan_results`
                #
                echo "--------------"
                echo "Try reconnect ..."

                echo "down/up wlan($interface)"
                if [ "$capture_flag" == "1" ];then
                    stop_mon_capture
                fi
                ip link set ${interface} down
                sleep 3
                ip link set ${interface} up
                if [ "${capture_flag}" == "1" ];then
                    start_mon_capture $interface
                fi

                echo "reconnect wpa_supplicant"
                wpa_cli -i $interface disconnect
                #wpa_cli -i $interface status
                sleep 3
                wpa_cli -i $interface reconnect
                #wpa_cli -i $interface status

                restart_wpa
            fi
            echo "  sleep $sleep_time"
            sleep $sleep_time
        elif [ "${wpa_status}" == "wpa_state=ASSOCIATING" ] ; then
            assoc_retry=$((${assoc_retry}+1))
            #wpa_cli scan_results
            if [ ${assoc_retry} -eq 4 -a "$nega" == "0" ];then
                assoc_retry=0
                echo "Try reconnect ..."

                echo "down/up wlan($interface)"
                if [ "$capture_flag" == "1" ];then
                    stop_mon_capture
                fi
                ip link set ${interface} down
                sleep 3
                ip link set ${interface} up

                if [ "${capture_flag}" == "1" ];then
                    start_mon_capture $interface
                fi

                echo "reconnect wpa_supplicant"


                ##wpa_cli disconnect
                #wpa_cli status
                sleep 3
                ##wpa_cli reconnect
                #wpa_cli status
                restart_wpa
            fi
            echo "  sleep $sleep_time"
            sleep $sleep_time
        elif [ "${wpa_status}" == "wpa_state=ASSOCIATED" ] ; then
            assoced_retry=$((${assoced_retry}+1))

            if [ ${assoced_retry} -eq 8 -a "$nega" == "0" ];then
                pause
                echo "AT_ERROR : Always ASSOCIATED"
                #break
                assoced_retry=0
                echo "Try reconnect ..."

                echo "down/up wlan($interface)"
                if [ "$capture_flag" == "1" ];then
                    stop_mon_capture
                fi
                ip link set ${interface} down
                sleep 3
                ip link set ${interface} up
                if [ "${capture_flag}" == "1" ];then
                    start_mon_capture $interface
                fi

                echo "reconnect wpa_supplicant"

                sleep 3

                restart_wpa
            fi
            echo "  sleep $sleep_time"
            sleep $sleep_time
        elif [ "${wpa_status}" == "wpa_state=DISCONNECTED" ] ; then

            echo "Check the wlan status..."
            if_wlan_on=`ifconfig | grep "$interface";echo $?`

            if [ "$if_wlan_on" == "1" ] ;then
                echo "  ip link set $interface up"
                #ip link set $interface up
                ifconfig $interface up
                sleep 2
            else
                echo "  $interface is already up"
                #ifconfig
            fi
            #
            wpa_cli -i $interface reconnect
            echo "  sleep $sleep_time"
            sleep $sleep_time
        elif [ "${wpa_status}" == "wpa_state=CONNECTING" ] ; then
            #wpa_cli scan_results
            echo "  sleep $sleep_time"
            sleep $sleep_time
        elif [ "${wpa_status}" == "wpa_state=4WAY_HANDSHAKE" -a $nega -eq 0 ] ; then
            echo "  positive mode ! wpa_status is 4WAY_HANDSHAKE ..."
            restart_wpa
        elif [ "${wpa_status}" == "wpa_state=4WAY_HANDSHAKE" -a $nega -eq 1 ] ; then
            echo "  negative mode ! wpa_status is 4WAY_HANDSHAKE ..."

            wpa_cli sta
            echo "  sleep $sleep_time"
            sleep $sleep_time
            #restart_wpa
        else
            echo "${wpa_status}" | grep "wpa_state="
            rrc=$?
            if [ "$rrc" == "0" ] ; then
                #wpa_status other

                else_retry=$((${else_retry}+1))

                if [ ${else_retry} -eq 4 -a "$nega" == "0" ];then
                    else_retry=0
                    echo "Try reconnect ..."

                    echo "down/up wlan($interface)"
                    if [ "$capture_flag" == "1" ];then
                        stop_mon_capture
                    fi
                    ip link set ${interface} down
                    sleep 3
                    ip link set ${interface} up
                    if [ "${capture_flag}" == "1" ];then
                        start_mon_capture $interface
                    fi

                    echo "reconnect wpa_supplicant"

                    sleep 3

                    restart_wpa
                fi
                echo "  sleep $sleep_time"
                sleep $sleep_time
            else
                # the wpa_supplicant may down
                echo "wpa_supplicnat may down ..."
                ifconfig
                ps aux | grep wpa_ | grep -v grep
                echo "try restart wpa_supplicant ..."
                #wpa_restarted=0
                restart_wpa
                #wpa_restarted=0
                #wpa_cli scan_results
                echo "  sleep $sleep_time"
                sleep $sleep_time
            fi
        fi

    done



    #if [ "${wpa_status}" != "wpa_state=COMPLETED" -a "${wpa_status}" != "wpa_state=ASSOCIATED" ] ; then
    if [ "${wpa_status}" != "wpa_state=COMPLETED" ] ; then

        if [ $nega -eq 0 ] ;then


            if [ $tried_again -le 3 ] ;then
                echo "positive test failed"
                echo "  AT_ERROR : connection timeout ! last status is (${wpa_status}), expected COMPLETED!"
                try_again
            elif [ $tried_again -gt 3 ] ;then
                echo "positive test failed"
                echo "  AT_ERROR : connection timeout ! last status is (${wpa_status}), expected COMPLETED!"
                dumpStateFlow

                pause
                if [ "$capture_flag" == "1" ];then
                    stop_mon_capture
                fi
                exit 1
            fi


        elif [ $nega -eq 1 ] ;then
            echo "negative test passed"

            echo "wpa_cli -i $interface reconnect"

            wpa_cli -i $interface disconnect

            dumpStateFlow
            if [ "$capture_flag" == "1" ];then
                stop_mon_capture
            fi
            exit 0
        fi
    else
        
        #tried_again=0
        if [ "${capture_flag}" == "1" ];then
            echo "start_wlan_capture $interface"
            #start_wlan_capture $interface
        fi
        if [ $nega -eq 0 ] ;then
            for iiiiiiiiiiii in `seq 1 $dhclient_chance`
            do
                do_connect
                check_channel
            done
        elif [ $nega -eq 1 ] ;then
            #echo "negative test failed"
            for iiiiiiiiiiii in `seq 1 $dhclient_chance`
            do
                do_connect
                #check_channel
            done
            #exit 1
        fi

    fi
}

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
    ss=`ip addr show scope global | grep global | awk '{ if($7) {if (ifname!=$7) print $7":"$2 } }' ifname=$SRC_IF`
    echo -e "----------\nall NICs : \n$ss\n-----------------"
    for line in $ss;do
        #echo "Line : $line"
        _itf=`echo $line | cut -d: -f 1`
        _itf_ip=`echo $line | cut -d: -f 2`
        is_in_same_subnet $SRC_IPADDR $_itf_ip
        if [ "$rc" == "0" ];then
            echo "$_itf($_itf_ip) is in the same subnet with $SRC_IF($SRC_IPADDR)"
            echo "release ip for $_itf"
            ip -4 addr flush dev $_itf
        else
            echo "$_itf($_itf_ip) is not in the same subnet with $SRC_IF($SRC_IPADDR)"
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
            echo "$_itf($_itf_ip) is in the same subnet with $SRC_IF($SRC_IPADDR)"
            echo "release ip for $_itf"
            ip -4 addr flush dev $_itf
        else
            echo "$_itf($_itf_ip) is not in the same subnet with $SRC_IF($SRC_IPADDR)"
        fi
    done

}


try_again(){

    echo "in function try_again() ..."
    echo "  tring again with another LAN wifi client ..."

    #   U_CUSTOM_WIFI_SWITCH=1,0
    count=1
    wpa_restart_retry=3
    sleep_time=10
    check_retry=5
    tried_again=4
    dhclient_chance=$dhclient_time

    if [ "" == "$U_WIRELESSINTERFACE2" ] ;then
        echo "  AT_ERROR : you don't have a second wifi client , so you don't have a second chance ."
        exit 1
    fi

    if [ $U_CUSTOM_WIFI_SWITCH -eq 1 ] ;then
        if [ "$interface" == "$U_WIRELESSINTERFACE" ] ;then
            echo "  using $U_WIRELESSINTERFACE2 instead of $U_WIRELESSINTERFACE ..."
            interface=$U_WIRELESSINTERFACE2
        elif [ "$interface" == "$U_WIRELESSINTERFACE2" ] ;then
            echo "  using $U_WIRELESSINTERFACE instead of $U_WIRELESSINTERFACE2 ..."
            interface=$U_WIRELESSINTERFACE
        fi
    elif [ $U_CUSTOM_WIFI_SWITCH -eq 0 ] ;then
        echo "  using $U_WIRELESSINTERFACE to try again"
        restart_wpa
    fi



    echo "  >> try again $tried_again << ..."

    #let "tried_again=$tried_again+1"

    echo -e "\n----------------------------"
    echo "disable_all_in_subnet DUT's br0"
    disable_all_in_subnet $G_PROD_GW_BR0_0_0/24
    #exit 1


    #
    echo -e "\n----------------------------"
    echo "try remove file /tmp/${interface}.conf "
    rm -rf /tmp/${interface}.conf > /dev/null 2>&1


    echo -e "\n----------------------------"
    echo "check wpa_supplicant"
    check_wpa


    echo -e "\n----------------------------"
    echo "try connect to DUT"
    do_scan

    }

#if [ "x$U_TMP_USING_NTGR" == "x1" ] ;then
#    
#    params=" -f "$file" -i "$interface" -t "$waittimes
#    
#    if [ "x$nega" == "x1" ] ;then
#        params=$params" -n "
#    fi
#    
#    if [ "x$address" != "x" ] ;then
#        params=$params" -a "$address
#    fi
#    
#    if [ "x$hostname" != "x" ] ;then
#        params=$params" -H "$hostname
#    fi
#    
#    echo "python $U_PATH_TBIN/wifi_connect_DUT.py $params"
#    
#    python $U_PATH_TBIN/wifi_connect_DUT.py $params
#    
#    rc_py=$?
#    
#    exit $rc_py
#fi
#
echo "parameter list"

if [ -z "$G_PROD_GW_BR0_0_0" ];then
    G_PROD_GW_BR0_0_0=192.168.1.1
fi


#
echo -e "\n----------------------------"
echo "disable_all_in_subnet DUT's br0"
disable_all_in_subnet $G_PROD_GW_BR0_0_0/24
#exit 1


#
echo -e "\n----------------------------"
echo "try remove file /tmp/${interface}.conf "
rm -rf /tmp/${interface}.conf > /dev/null 2>&1
truncate -s 0 $wpa_logfile
if [ "${capture_flag}" == "1" ];then
    echo "start_mon_capture $interface"
    start_mon_capture $interface
fi

echo -e "\n----------------------------"
echo "check wpa_supplicant"
check_wpa


echo -e "\n----------------------------"
echo "try connect to DUT"
do_scan
if [ "$capture_flag" == "1" ];then
    stop_mon_capture
fi

