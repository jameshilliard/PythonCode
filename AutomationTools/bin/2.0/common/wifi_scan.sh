#!/bin/bash
#
# Author        :   Howard Yin(hying@actiontec.com)
# Description   :
#   This tool is using to scan SSID.
#
#
# History      :
#   DATE        |   REV  | AUTH   | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version
#11 Nov 2011    |   1.0.1   | andy      | after ifconfig up wificard,wait 2 sec,make sure it's up
#16 Nov 2011    |   1.0.2   | rayofox   | addd sleep 5 after if wlanx up and down
#22 Nov 2011    |   1.0.3   | andy      | use iw instead of iwlist to avoid allocation failed,then needn't sleep 5 after if wlanx up and down
#24 NOV 2011    |   1.0.4   | andy      | 1:add "wpa_cli terminate" before scan ssid. 2:only ifconfig up wlanx once.
#09 Dec 2011    |   1.0.5   | rayofox   | ip link down and up wlan before scan
#21 Dec 2011    |   1.0.6   | Howard    | if cannot scan anything , exit
#10 Jan 2012    |   1.0.7   | rayofox   | code review with Howard, redesign the scan flow,add more retry and output info
#20 Mar 2012    |   1.0.8   | Howard    | display more SSID information when scan passed , such as BSS
#24 Jul 2012    |   1.0.9   | Howard    | now scan the SSID will try to match BSSID and SSID name

REV="$0 version 1.0.9 ( 24 Jul 2012)"
# print REV

echo "${REV}"



usage="bash $0 -i <wlan interface> -s <SSID> -t <test mode> -n <nega mode> -c <scan only mode>\n after running this tool, the interface that connected to the same net with wlan interface will be down.\n but if you engage the scan only mode by using the parameter c, the link status will be restored eventually."

scan_times=60

neg=0

check_retry=10

empty_retry=10

downed_ifs=(
)

down_index=0

scan_result=0

scan_only=0
wait_interval=10

while getopts ":w:i:s:thnc" opt ;
do
    case $opt in
        c)
            scan_only=1
            echo "scan only,the previous link status will be restored"
            ;;
        i)
            wlan=$OPTARG
            echo "interface : $wlan"
            ;;
        s)
            SSID=$OPTARG
            echo "SSID : $SSID"
            ;;
        t)
            G_PROD_IP_BR0_0_0=192.168.0.1
            ;;
        n)
            neg=1
            echo "negative test engaged"
            ;;
        w)
            capture_flag=$OPTARG
            ;;
        ?)
            paralist=-1
            echo "WARN: '-$OPTARG' not supported."
            echo -e $usage
            exit 1
    esac
done


if [ -z ${capture_flag} ];then
    capture_flag=1
fi


if [ "x$U_TMP_USING_NTGR" == "x1" ] ;then
    echo "python $U_PATH_TBIN/wifi_scan.py $*"
    capture_flag=0
    if [ $neg -eq 1 ] ;then
        if [ "$capture_flag" == "1" ];then
            python $U_PATH_TBIN/wifi_scan.py -i "$wlan" -s "\"$SSID\"" -n
        else
            python $U_PATH_TBIN/wifi_scan.py -i "$wlan" -s "\"$SSID\"" -n -w 0
        fi
    else
        if [ "$capture_flag" == "1" ];then
            python $U_PATH_TBIN/wifi_scan.py -i "$wlan" -s "\"$SSID\""
        else
            python $U_PATH_TBIN/wifi_scan.py -i "$wlan" -s "\"$SSID\"" -w 0
        fi
    fi

    rc_py=$?

    exit $rc_py
fi

if [ $neg -eq 1 ] ;then
    scan_times=80
fi

pause(){
    echo "scan NOT acting like it's supposed to be , stopped for debugging " | tee $G_LOG/current/skip_all_rest.LABEL
}

switch_control(){
    echo "Entry switch_control"
    for i in `seq 1 3`
    do
        echo "Try $i times..."
        echo "bash $U_PATH_TBIN/switch_controller.sh -u 0"
        bash $U_PATH_TBIN/switch_controller.sh -u 0
        rc_flash_u=$?
        echo "sleep $wait_interval"
        sleep $wait_interval
        if [ "$rc_flash_u" == "0" ] ;then
            echo "bash $U_PATH_TBIN/switch_controller.sh -u 1"
            bash $U_PATH_TBIN/switch_controller.sh -u 1
            rc_flash_u=$?
            if [ "$rc_flash_u" == "0" ] ;then
                echo "AT_INFO : turn on usb1 passed"
                return 0
            else
                echo "AT_ERROR : failed to turn on usb1"
            fi
        else
            echo "AT_ERROR : failed to turn down usb1"
        fi
    done
    exit 1

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
        
        curdate=`date +%m%d%H%M%S`
        
        echo "Sniff the wireless packets in air : $moniface"
        echo "bash $U_PATH_TBIN/raw_capture.sh --local -i $moniface -o lan_${moniface}_${curdate}.cap -t 3600 --begin"
        sleep 5
        bash $U_PATH_TBIN/raw_capture.sh --local -i $moniface -o lan_${moniface}_${curdate}.cap -t 3600 --begin
        return_code=$?
        echo "return_code : $return_code"
        
        if [ $return_code -eq 0 ];then
            echo "Sniff the wireless(${moniface}) packets in air SUCCESS!"
            break
        fi
        echo "Sniff the wireless(${moniface}) packets in air FAIL!"
    done
}

stop_mon_capture(){
        echo "Entry stop_mon_capture()"
        echo "Stop capture on Monitor wireless card : $moniface"
        echo "bash $U_PATH_TBIN/raw_capture.sh --local -i $moniface -o lan_${moniface}_${curdate}.cap --stop"
        sleep 5
        bash $U_PATH_TBIN/raw_capture.sh --local -i $moniface -o lan_${moniface}_${curdate}.cap --stop
        return_code=$?
        echo "return_code : $return_code"
        echo "iw dev $moniface del"
        iw dev $moniface del
        return_code=$?
        echo "return_code : $return_code"
        sleep 2
        ifconfig
        route -n
}

check_wlan_on(){
    echo "Entry check_wlan_on"
    if [ $check_retry -eq 0 ] ;then
        echo "AT_ERROR : no such device as $wlan on this machine."
        exit 1
    fi

    echo "ifconfig |grep $wlan"
    is_wlan_on=`ifconfig |grep -o "$wlan"`

    if [ "$is_wlan_on" == "$wlan" ] ;then
        echo "$wlan is ready"

        if [ "$capture_flag" == "1" ];then
            echo "start_mon_capture $wlan"
            start_mon_capture $wlan
        fi
    else
        echo "ifconfig -a |grep $wlan"
        is_wlan_exists=`ifconfig -a |grep -o "$wlan"`

        if [ "$is_wlan_exists" == "" ] ;then
            echo "AT_ERROR : no such device as $wlan on this machine."
            let "check_retry=$check_retry-1"

            echo "sleep $wait_interval"
            sleep $wait_interval
            if [ "$U_CUSTOM_NO_WECB" == "0" ] ;then
                if [ "$capture_flag" == "1" ];then
                    echo "stop_mon_capture $wlan"
                    stop_mon_capture
                fi
                switch_control
            fi
            
            echo "sleep $wait_interval"
            sleep $wait_interval
            check_wlan_on
        fi

        echo "ip link set $wlan up"
        ip link set $wlan up

        echo "sleep 2"
        sleep 2

        let "check_retry=$check_retry-1"
        check_wlan_on
    fi
}

scan_SSID(){
    scan_retry=$scan_times
    empty_retry=$empty_retry
    check_retry=10

    if [ -z "$scan_retry" ];then
        scan_retry = 10
    fi

    if [ -z "$empty_retry" ];then
        empty_retry = 12
    fi

    isFound=0

    notFound=0

    if [ "$G_CURRENTLOG" == "" ] ;then
        scan_rc_loc=/tmp/last_wifi_scan_result.log
    else
        scan_rc_loc=$G_CURRENTLOG/last_wifi_scan_result.log
    fi

    rm -f $scan_rc_loc

    #for i in `seq 1 $scan_retry`
    while [ $scan_retry -gt 0 ]
    do
        echo ""
        echo "try scan $i"



        # judge if empty
        for j in `seq 1 $empty_retry`
        do
            #echo " in loop empty retry $j"
            #   iw dev $wlan scan > $scan_rc_loc

            current_scan_file="${scan_rc_loc}_$i"

            #rm -f $current_scan_file

            iw dev $wlan scan > $current_scan_file

            echo "scan_retry $i , empty retry $j" >> $scan_rc_loc
            cat $current_scan_file >> $scan_rc_loc
            echo "===============================" >> $scan_rc_loc

            anySSID=`grep SSID $current_scan_file |wc -l`

            if [ $anySSID -eq 0 ] ;then
                echo "==scan empty --$j"

                echo "scan result is empty, wlan might works incorrect"
                if [ $j -eq $empty_retry ] ;then
                    echo "--| AT_ERROR : scan result is always empty"
                    if [ "$capture_flag" == "1" ];then
                        echo "stop_mon_capture $wlan"
                        stop_mon_capture
                    fi
                    exit 1
                else
                    if [ "$j" == "3" -o "$j" == "6" -o "$j" == "9" ]; then
                        if [ "$capture_flag" == "1" ];then
                            echo "stop_mon_capture $wlan"
                            stop_mon_capture
                        fi

                        if [ "$U_CUSTOM_NO_WECB" == "0" ] ;then
                            switch_control
                        fi
 
                        echo "sleep $wait_interval"
                        sleep $wait_interval
                        
                        check_wlan_on
                        sleep 3
                    fi
                fi
            else
                break
            fi
        done
        # end of judge empty

        # search for dest SSID in scan result File

        #grep -B8 "$SSID" $current_scan_file
        #echo "U_WIRELESS_BSSID1=$U_WIRELESS_BSSID1_VALUE"                         >> $output
        #echo "U_WIRELESS_BSSID2=$U_WIRELESS_BSSID2_VALUE"                         >> $output
        #echo "U_WIRELESS_BSSID3=$U_WIRELESS_BSSID3_VALUE"                         >> $output
        #echo "U_WIRELESS_BSSID4=$U_WIRELESS_BSSID4_VALUE"                         >> $output

        #-v U_WIRELESS_SSID1=CenturyLink
        #-v U_WIRELESS_SSID2=SSID2
        #-v U_WIRELESS_SSID3=SSID3
        #-v U_WIRELESS_SSID4=SSID4

        if [ "$SSID" == "$U_WIRELESS_SSID1" ] ;then
            curr_bssid=$U_WIRELESS_BSSID1
        elif [ "$SSID" == "$U_WIRELESS_SSID2" ] ;then
            curr_bssid=$U_WIRELESS_BSSID2
        elif [ "$SSID" == "$U_WIRELESS_SSID3" ] ;then
            curr_bssid=$U_WIRELESS_BSSID3
        elif [ "$SSID" == "$U_WIRELESS_SSID4" ] ;then
            curr_bssid=$U_WIRELESS_BSSID4
        fi

        #   U_CUSTOM_SPECIFIED_SSID = SSID1

        if [ "x" == "x${curr_bssid}" ] ;then
            if [ "${U_CUSTOM_SPECIFIED_SSID}" == "SSID1" ] ;then
                curr_bssid=$U_WIRELESS_BSSID1
            elif [ "${U_CUSTOM_SPECIFIED_SSID}" == "SSID2" ] ;then
                curr_bssid=$U_WIRELESS_BSSID2
            elif [ "${U_CUSTOM_SPECIFIED_SSID}" == "SSID3" ] ;then
                curr_bssid=$U_WIRELESS_BSSID3
            elif [ "${U_CUSTOM_SPECIFIED_SSID}" == "SSID4" ] ;then
                curr_bssid=$U_WIRELESS_BSSID4
            fi
        fi

        echo ""
        echo "iw dev $wlan scan | grep \"$curr_bssid\s*$SSID$\""
        echo ""

        ncc=`cat $current_scan_file| grep -e "^BSS" -e "SSID:" | awk '{if (/^BSS/) {printf("%s\t"),$2}else {$1="" ;print $0} } ' | grep -e "\s*$SSID$"| grep -ie "$curr_bssid\s*$SSID$" | wc -l`

        if [ "$ncc" == "1" ]; then
            found_ssidname=`cat $current_scan_file| grep -e "^BSS" -e "SSID:" | awk '{if (/^BSS/) {printf("%s\t"),$2}else {$1="" ;print $0} } ' | grep -e "\s*$SSID$"| grep -ie "$curr_bssid\s*$SSID$"`
            echo "===> |$found_ssidname| <==="

            #   found desti SSID
            #   isFound=1

            if [ $neg -eq 0 ] ;then
                # positive mode
                let "isFound=$isFound+1"
                #let "scan_retry=$scan_retry-1"
            else
                # negative mdoe
                if [ $notFound -gt 0 ] ;then
                    echo "  not-found status unstable , reset not-found counting ."
                fi

                let "isFound=$isFound+1"
                notFound=0
            fi
        elif [ "$ncc" == "0" ] ;then
            echo "  no SSID named : $SSID , BSSID : $curr_bssid"

            # NOT found desti SSID
            if [ $neg -eq 0 ] ;then
                # positive mode
                if [ $notFound -eq 0 ] ;then
                    echo "  SSID became un-scannable ."
                fi

                let "notFound=$notFound+1"
                isFound=0

                echo -e "scan result (expected $SSID): \n $anySSID"
                #grep SSID  $scan_rc_loc
                cat $current_scan_file| grep -e "^BSS" -e "SSID:" | awk '{if (/^BSS/) {printf("%s\t"),$2}else {print $0} } '
                echo ""
            else
                # negative mdoe
                let "notFound=$notFound+1"
                #let "scan_retry=$scan_retry-1"
            fi
        else
            echo "AT_ERROR  : Duplicate SSID named : $SSID , BSSID : $curr_bssid"
            # add more debug info
            cat $current_scan_file| grep -e "^BSS" -e "SSID:" | awk '{if (/^BSS/) {printf("%s\t"),$2}else {$1="" ;print $0} } ' | grep -e "\s*$SSID$"| grep -ie "$curr_bssid\s*$SSID$"

            isFound=0
            let "notFound=$notFound+1"
            #let "scan_retry=$scan_retry-1"
            #exit 1
        fi

        echo "-----"
        #cat $current_scan_file| grep -e "^BSS" -e "SSID:" | awk '{if (/^BSS/) {printf("%s\t"),$2}else {$1="" ;print $0} } ' | grep -e "$curr_bssid\s*$SSID$"

        #

        #if [ $? -eq 0 ] ; then

        #else

        #fi

        # to judge if break out the loop

        if [ $neg -eq 0 ] ;then
            # positive mode
            # isFound=1
            if [ $isFound -eq 5 ] ;then
                echo "positive scan passed"
                scan_result=0
                break
            fi

        else
            # negative mdoe
            # notFound=1
            if [ $notFound -eq 5 ] ;then
                echo "negative scan passed"
                scan_result=0
                break
            fi
        fi

    let "scan_retry=$scan_retry-1"

    scan_result=1

    echo "sleep 3"

    sleep 3

    echo "  isFound = $isFound :: notFound = $notFound"

    done

}
echo "--------------------"
echo "disconnect wlan NIC from WPA and release IP ."

for wl_ifc in `iwconfig  2> /dev/null | grep -o ".*SSID"|awk '{print $1}'`
do
    echo "  wpa_cli -i $wl_ifc disconnect"
    wpa_cli -i $wl_ifc disconnect

    echo "  ip -4 addr flush dev $wl_ifc"
    ip -4 addr flush dev $wl_ifc

    echo "        removing existing /tmp/${wl_ifc}.conf"
    rm -f /tmp/${wl_ifc}.conf
done

echo "--------------------"
echo "check wlan on ..."
check_wlan_on

echo "--------------------"
echo "scan SSID ..."

t_start=`date +%s`
scan_SSID
if [ "$capture_flag" == "1" ];then
    echo "stop_mon_capture $wlan"
    stop_mon_capture
fi
echo "--------------------"

if [ $neg -eq 0 ] ;then
    # positive mode
    if [ $scan_result -eq 1 ] ;then
        echo "AT_ERROR : positive scan ESSID($SSID) FAILED"
    fi

else
    # negative mdoe
    if [ $scan_result -eq 1 ] ;then
        echo "AT_ERROR : negative scan ESSID($SSID) FAILED"
    fi
fi

t_end=`date +%s`
t_delta=`expr $t_end - $t_start`

echo "time consume in scanning : $t_delta" |tee -a $scan_rc_loc

exit $scan_result
