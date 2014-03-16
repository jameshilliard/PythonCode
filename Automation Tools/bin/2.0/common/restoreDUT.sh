#!/bin/bash
#
# Author        :   Howard(hying@actiontec.com)
# Description   :
#   This tool is used to restore DUT to default state .
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#25 Feb 2012    |   1.0.0   | Howard    | Inital Version  
#

REV="$0 version 1.0.0 (25 Feb 2012)"
# print REV

echo "${REV}"

# USAGE
USAGE()
{
    cat <<usge
USAGE : 

    bash $0 

usge
}

reset_retry=3
telnet_retry=3
result=0

is_tnet_changed=0

post_file_loc=$G_SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition
post_file_ssid1=$G_SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/wireless/SEC/SSID2

check_tnet(){
    echo "in function check_tnet() ..."
    
    echo "wait 30s"
    sleep 30
    
    perl $U_PATH_TBIN/DUTCmd.pl -o checkTelnet.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT
    
    tnet_rc=$?
    
    #   is_tnet_changed U_DUT_TELNET_DEFAULT_STATUS
    
    if [ $is_tnet_changed -eq 0 -a $U_DUT_TELNET_DEFAULT_STATUS -eq 0 ] ;then
        if [ $tnet_rc -eq 1 ] ;then
            check_tnet_result=0
        else
            check_tnet_result=1
            let "telnet_retry=$telnet_retry-1"
        fi
    elif [ $is_tnet_changed -eq 0 -a $U_DUT_TELNET_DEFAULT_STATUS -eq 1 ] ;then
        if [ $tnet_rc -eq 0 ] ;then
            check_tnet_result=0
        else
            check_tnet_result=1
            let "telnet_retry=$telnet_retry-1"
        fi
    elif [ $is_tnet_changed -eq 1 -a $U_DUT_TELNET_DEFAULT_STATUS -eq 0 ] ;then
        if [ $tnet_rc -eq 0 ] ;then
            check_tnet_result=0
        else
            check_tnet_result=1
            let "telnet_retry=$telnet_retry-1"
        fi
    elif [ $is_tnet_changed -eq 1 -a $U_DUT_TELNET_DEFAULT_STATUS -eq 1 ] ;then
        if [ $tnet_rc -eq 1 ] ;then
            check_tnet_result=0
        else
            check_tnet_result=1
            let "telnet_retry=$telnet_retry-1"

        fi
    fi
    }

check_restore_DUT(){
    echo "in function check_restore_DUT() ..."
    
    echo "  try to telnet onto DUT ."
    
    check_tnet
    
    if [ $check_tnet_result -eq 0 ] ;then
        echo "  passed in checking restore DUT ."
        result=1
    elif [ $check_tnet_result -eq 1 ] ;then
        while  [ ${telnet_retry} -gt 0 ]
          do
            echo "Sleep 25s and retry..."
            sleep 25
            #Some product need about 15s to prepare telnet function.
            echo "retry DUT telnet ${telnet_retry} ..."
            check_tnet  
            if [ $check_tnet_result -eq 0 ] ;then
                echo "  passed in checking restore DUT ."
                result=1
                break
            fi
            if [ ${telnet_retry} -eq 0 ] ;then
                echo "AT_ERROR : restore DUT failed !"
                exit 1
            fi
          done
        let "reset_retry=$reset_retry-1"
    fi
    
    }
check_restore_DUT_GUI(){
    
    GUI_result=0
    until [ $rc -eq 3 ]
        do  
            sleep 15
            $U_PATH_TBIN/playback_http $U_DUT_TYPE   -g https://$G_PROD_IP_BR0_0_0 -s $G_CURRENTLOG/After_Restore_DUT_Check_GUI.html 
            GUI_check=$?
            if [ "$GUI_check" == "0" ];then
                echo " Passed in login DUT after restore default ."
                let GUI_result=1
                rc=3
            else
                
                let rc=$(($rc+1))
                if [ $rc -lt 3 ];then
                    echo " Failed in login DUT after restore default,will retry after 25 seconds."
                    sleep 25
                elif [ $rc -eq 3 ];then
                  echo "Failed in login DUT check after retry $rc times"
                let GUI_result=0
                fi  
            fi
        done
}
resetDUT(){
    echo "in function resetDUT() ..."
    
    echo "  DUT setting on GUI to restore default"
    
    $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.FACRESET-003-C002 $U_AUTO_CONF_PARAM
    
    rc_reset=$?
    
    if [ $rc_reset -gt 0 ] ;then
        echo "AT_ERROR : error occured in restore default on GUI ."
        exit 1
    fi
    
#   if [ -z $U_CUSTOM_DUT_RESTORE_TIME ] ;then
#       U_CUSTOM_DUT_RESTORE_TIME=60
#   fi
#   
#   echo "sleep $U_CUSTOM_DUT_RESTORE_TIME"
#    sleep $U_CUSTOM_DUT_RESTORE_TIME
   
    #####
    if [ "$old_dut_br0_ip" ] ;then
        G_PROD_IP_BR0_0_0=$TMP_DUT_BR0_IP
    fi
    #####
    echo "sleep 60"
    sleep 60
    date
    if [ "$U_DUT_TYPE" == "PK5K1A" ];then
        echo "sleep 120"
        sleep 120
        date
    fi
    bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120

    #echo "sleep 30"
    #sleep 30

    is_dut_avl=$?
    
    if [ $is_dut_avl -gt 0 ] ; then
        echo "AT_ERROR : DUT not available after restore ."
        exit 1
    fi
    
    is_tnet_changed=0
    
    }

resetDUT_WECB(){
    echo "in function resetDUT() ..."
    
    echo "  DUT setting on GUI to restore default"
    
#    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.FACRESET-003-C002 $U_AUTO_CONF_PARAM"
#    $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.FACRESET-003-C002 $U_AUTO_CONF_PARAM

    echo "bash $U_PATH_TBIN/run_single_fitnesse_case.sh -c MasterCaseLibrary.ComcastWecb3000.WecbRestoreDefault"
    bash $U_PATH_TBIN/run_single_fitnesse_case.sh -c MasterCaseLibrary.ComcastWecb3000.WecbRestoreDefault

    rc_reset=$?
    echo -e "The restore WECB result is :==>$rc_reset!"
    if [ $rc_reset -gt 0 ] ;then
        echo "AT_ERROR : error occured in restore default on GUI ."
        exit 1
    fi

    #bash $U_PATH_TBIN/getdefvalue.sh -tbs
    sleep 60
    bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120
    is_dut_avl=$?
    if [ $is_dut_avl -gt 0 ] ; then
        echo "AT_ERROR : DUT not available after restore ."
        exit 1
    fi
}


reverse_tnet_status(){
    echo "in function reverse_tnet_status() ..."
    
    echo "  DUT setting on GUI to change telnet status "
    
    is_tnet_changed=0
    
    echo "going to change telnet status."
    if [ $U_DUT_TELNET_DEFAULT_STATUS -eq 1 ] ;then
        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.FACRESET-003-REVERSE-C001 -v "U_DUT_TELNET_PWD=$U_DUT_TELNET_BAD_PWD" $U_AUTO_CONF_PARAM
    else
        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.FACRESET-003-REVERSE-C001 $U_AUTO_CONF_PARAM
    fi
    
    rc_change_tnet=$?
    
    if [ $rc_change_tnet -gt 0 ] ;then
        echo "AT_ERROR : error occured in changing telnet status on GUI ."
        exit 1
    fi
    
    is_tnet_changed=1
    sleep 15
    check_tnet
    
    if [ $check_tnet_result -eq 1 ] ;then
        echo "AT_ERROR : failed to reverse tnet status"
        exit 1
    fi
    
    }
   
do_power_cycle_dut=0

while [ -n "$1" ];
do
    case "$1" in
        -t)
            echo "test mode"
            U_DUT_TELNET_DEFAULT_STATUS=1
            shift 1
            ;;

        --old_dut_br0_ip)
            old_dut_br0_ip=$2
            echo "the old DUT BR0 IP : ${old_dut_br0_ip}"
            shift 2
            ;;

        -power_cycle_dut)
            do_power_cycle_dut=1
            echo "power cycle dut is enabled"
            shift 
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

#   reset_retry
if [ "$old_dut_br0_ip" ] ;then
    TMP_DUT_BR0_IP=$G_PROD_IP_BR0_0_0
    G_PROD_IP_BR0_0_0=$old_dut_br0_ip
fi

if [ "$U_DUT_TYPE" != "WECB" ] || [ "$U_DUT_TYPE" != "NcsWecb3000" ] || [ "$U_DUT_TYPE" != "TelusWecb3000"] || ["$U_DUT_TYPE" != "ComcastWecb3000"] || [ "$U_DUT_TYPE" != "VerizonWecb3000"];then
    while  [ ${reset_retry} -gt 0 ]
    do
        if [ "$do_power_cycle_dut" == "1" ]; then
            echo "== power cycle DUT before do restore..."
            bash $U_PATH_TBIN/switch_controller.sh -power 0
            rc=$?
            if [ $rc -ne 0 ];then
                exit 1
            fi
            sleep 10
            bash $U_PATH_TBIN/switch_controller.sh -power 1
            rc=$?
            if [ $rc -ne 0 ];then
                exit 1
            fi
            echo "== sleep after reboot $U_CUSTOM_DELAY_AFTER_REBOOT seconds..."
            sleep $U_CUSTOM_DELAY_AFTER_REBOOT
            echo "== make sure DUT LAN is reachable..."
            bash $U_PATH_TBIN/verifyDutLanConnected.sh
            rc=$?
            if [ $rc -ne 0 ];then
                exit 1
            fi

        fi
        
        echo "restore DUT try ${reset_retry} ..."
    
            reverse_tnet_status
        
            resetDUT
        
            check_restore_DUT
        if [ "$U_DUT_TYPE" != "FT" ];then
            if [ $result -eq 1 ] ;then
                echo "restore DUT passed !"
                if [ "$U_DUT_TYPE" == "PK5K1A" ];then
                     let i=1
                     retry_times=5
                     sleep_time=10
                     while true
                     do
                         rm -f $G_CURRENTLOG/wireless_debug_info.log
                         echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o wireless_debug_info.log -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"echo 7 > /proc/sys/kernel/printk\" -v \"echo 1 > /proc/net/mtlk/do_debug_assert\""
                         perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o wireless_debug_info.log -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "echo 7 > /proc/sys/kernel/printk" -v "echo 1 > /proc/net/mtlk/do_debug_assert"
                         if [ $? -eq 0 ];then
                             echo "pass"
                             break
                         else
                             let i=$i+1
                             if [ $i -gt ${retry_times} ];then
                                  exit 1
                             fi
                             echo "Try $i time..."
                             sleep ${sleep_time}
                         fi
                    done
                fi
                exit 0
            else
                if [ ${reset_retry} -eq 0 ] ;then
                    echo "AT_ERROR : restore DUT failed !"
                    exit 1
                fi
            fi
        elif [ "$U_DUT_TYPE" == "FT" ];then
            check_restore_DUT_GUI
            if [ $result -eq 1 ]&&[ $GUI_result -eq 1 ] ;then
                echo "restore DUT passed !"
                exit 0
            else
                if [ ${reset_retry} -eq 0 ] ;then
                    echo "AT_ERROR : restore DUT failed !"
                    exit 1
                fi
            fi
        fi
        
    done
elif [ "$U_DUT_TYPE" == "WECB" ] || [ "$U_DUT_TYPE" == "NcsWecb3000" ] || [ "$U_DUT_TYPE" == "TelusWecb3000"] || ["$U_DUT_TYPE" == "ComcastWecb3000"] || [ "$U_DUT_TYPE" == "VerizonWecb3000"];then
    bash $U_PATH_TBIN/setup_local_telnet.sh
    if [ $? -gt 0 ];then
        exit 1
    fi
    export U_WIRELESS_SSID1=CUSTOM_SSID1_NAME
    echo "Enable SSID1 and Change SSID1 Name to $U_WIRELESS_SSID1"
    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_ssid1/B-GEN-WI.SEC-011-C001"
    $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_ssid1/B-GEN-WI.SEC-011-C001
    if [ $? -gt 0 ] ;then
        echo "AT_ERROR : Enable SSID1 and Change SSID1 Name to $U_WIRELESS_SSID1 Fail!"
        exit 1
    fi
    echo "Enable SSID1 and Change SSID1 Name to $U_WIRELESS_SSID1 PASS!"
    echo "bash $U_PATH_TBIN/cli_dut.sh -v wifi.info -o $G_CURRENTLOG/cli_dut_wifi_info_1.log"
    bash $U_PATH_TBIN/cli_dut.sh -v wifi.info -o $G_CURRENTLOG/cli_dut_wifi_info_1.log
    if [ $? -gt 0 ];then
        echo "AT_ERROR : bash $U_PATH_TBIN/cli_dut.sh -v wifi.info -o $G_CURRENTLOG/cli_dut_wifi_info_1.log FAIL!"
        exit 1
    fi
    first_ssid1name=`grep "U_WIRELESS_SSID1" $G_CURRENTLOG/cli_dut_wifi_info_1.log|awk -F= '{print $2}'`
    echo "Before Restore : U_WIRELESS_SSID1=$first_ssid1name"
    if [ -z "$first_ssid1name" ];then
        echo "AT_ERROR : U_WIRELESS_SSID1 is NULL!"
        exit 1
    fi

    resetDUT_WECB
    bash $U_PATH_TBIN/setup_local_telnet.sh
    if [ $? -gt 0 ];then
        exit 1
    fi
    echo "Check DUT Restore!"
    echo "bash $U_PATH_TBIN/cli_dut.sh -v wifi.info -o $G_CURRENTLOG/cli_dut_wifi_info_2.log"
    bash $U_PATH_TBIN/cli_dut.sh -v wifi.info -o $G_CURRENTLOG/cli_dut_wifi_info_2.log
    if [ $? -gt 0 ];then
        echo "AT_ERROR : bash $U_PATH_TBIN/cli_dut.sh -v wifi.info -o $G_CURRENTLOG/cli_dut_wifi_info_2.log FAIL!"
        exit 1
    fi
    second_ssid1name=`grep "U_WIRELESS_SSID1" $G_CURRENTLOG/cli_dut_wifi_info_2.log|awk -F= '{print $2}'`
    echo "After Restore : U_WIRELESS_SSID1=$second_ssid1name"
    if [ -z "$second_ssid1name" ];then
        echo "AT_ERROR : U_WIRELESS_SSID1 is NULL!"
        exit 1
    fi
    echo ""
    echo "Before Restore : U_WIRELESS_SSID1=$first_ssid1name"
    echo "After  Restore : U_WIRELESS_SSID1=$second_ssid1name"
    if [ "$first_ssid1name" != "$second_ssid1name" ];then
        echo "U_WIRELESS_SSID1 changed after Restore,so Restore DUT Success!"
    else
        echo "U_WIRELESS_SSID1 NOT changed after Restore,so Restore DUT Fail!"
        exit 1
    fi
fi
