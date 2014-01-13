#!/bin/bash
#
# Description   :  This script is used to Upgrade/Downgrade DUT firmware version
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#29 Jun 2012    |   1.0.0   | Ares      | Inital Version       
#

VER="1.0.0"
echo "$0 version : ${VER}"

help(){
    cat <<usage
              
        -h                                    Show this help.
            
        -f:     <Current Version>             Change DUT from current version.
            
        -t:     <Destination Version>         Change DUT firmware version to destination version 
               
        -c                                    Check DUT current version   
        `basename $0`: [-h] -f(from): <current version> -t(to):   <destination version> [-check] 

usage
}
Check_Request=no
#U_CUSTOM_FW_DIR=/root/automation/firmware
DUT_Firmware_Upgrade_Waiting_Time=90
DUT_Reboot_Waiting_Time=120
#U_DUT_TYPE=CTLC2KA
#G_CURRENTLOG=/tmp
if [ "$U_DUT_TYPE" == "WECB" ] || [ "$U_DUT_TYPE" == "NcsWecb3000" ] || [ "$U_DUT_TYPE" == "TelusWecb3000"] || ["$U_DUT_TYPE" == "ComcastWecb3000"] || [ "$U_DUT_TYPE" == "VerizonWecb3000"];then
    exit 0
fi
TFTP_Server_Address=$G_HOST_TIP0_1_0
if [ -z "$TFTP_Server_Address" ];then
    TFTP_Server_Address=`ifconfig eth1|grep "inet addr"|awk -F: '{print $2}'|awk '{print $1}'`
fi
upgrade_flag=False
downgrade_flag=False
checkonly_flag=False
while [ $# -gt 0 ]; 
do
    case $1 in

        -h)
        echo "Show this script Help"
        help
        exit 0
        ;;
        -f)
        echo "Set DUT Current Version"
        Current_Version=$2              
        shift 2
        ;;
        -t)
        echo "Set change DUT firmware version to Destination Version"
        echo "Destination_Version is :"$2
        Destination_Version=$2
        if [ "$Check_Request" == "no" ] && [ -z "$Destination_Version" ];then
            echo echo -e "Haven't specify DUT destination firmware version !"  
            exit 1
        fi
        shift 2
        ;;
        -c)
        echo "Check DUT current firmware version"
        Check_Request=yes
        shift 1
        ;;
        --type)
        echo "Custom set change DUT firmware version  USE GUI CLI or TR69 mode! "
        mode=$2
        shift 2
        ;;
        -v)
        export $2
        shift 2
        ;;
        --downgrade)
            downgrade_flag=True
            shift
            ;;
        --upgrade)
            upgrade_flag=True
            shift
            ;;
        --checkonly)
            checkonly_flag=True
            shift
            ;;
        -o)
            output=$2
            shift 2
            ;;
        *)
        echo -e " AT_ERROR : Unknow parameter,Show the help list! "
        help
        exit 1
        ;;
    esac
done

DUT_Reboot_Waiting(){
        echo "DUT firmware refresh failed,Now will reboot DUT!"
        perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "reboot"  -l $G_CURRENTLOG -o DUT_Firmware_Refresh_Failed_Reboot.log
        echo -e "Waiting time:$DUT_Reboot_Waiting_Time s!"
        sleep $DUT_Reboot_Waiting_Time        
}

Upgrade_DUT_Firmware(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.|head -n 1|awk -F. '{print $NF}'`
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use GUI  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
    if [ -z "$File_NAME" ];then
        echo "Destination fw version : ${U_DUT_TYPE}-${Destination_Version}.${EXT} not exist!"
        exit 1
    fi    
    echo "playback_http $U_DUT_TYPE  -v TMP_HTTP_HOST=$G_PROD_IP_BR0_0_0  --upgrade_firmware_file=$U_CUSTOM_FW_DIR/$File_NAME"
    playback_http $U_DUT_TYPE  -v TMP_HTTP_HOST=$G_PROD_IP_BR0_0_0  --upgrade_firmware_file=$U_CUSTOM_FW_DIR/$File_NAME
    rc=$?
    if [ "$rc" == "0" ];then
       echo -e  "DUT has upgraded from $Current_Version to $Destination_Version use GUI mode!"
       echo -e "Wait $DUT_Firmware_Upgrade_Waiting_Time seconds and check DUT firmware version !"
       echo "Waiting time:180s!"
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       if [ "$upgrade_flag" == "True" ];then
           sleep $DUT_Firmware_Upgrade_Waiting_Time
           sleep $DUT_Firmware_Upgrade_Waiting_Time
 
       fi
       
       DUT_Current_Info_Check $Destination_Version
   else
       echo -e "AT ERROR:Filed upgraded from $Current_Version to $Destination_Version use GUI mode!"  
       exit 1
    fi
}


Downgrade_DUT_Firmware_CTLC2KA(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.|head -n 1|awk -F. '{print $NF}'`
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use GUI  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
    if [ -z "$File_NAME" ];then
        echo "Destination fw version : ${U_DUT_TYPE}-${Destination_Version}.${EXT} not exist!"
        exit 1
    fi    
    #perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cp /bin/busybox /var/" -v "tftp -t i -g -f $File_NAME -d 3 $TFTP_Server_Address" -v "/var/busybox reboot" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cp /bin/busybox /var/" -v "tftp -t i -g -f $File_NAME $TFTP_Server_Address" -v "/var/busybox reboot" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log
    sleep $DUT_Firmware_Upgrade_Waiting_Time
    #perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT   -v "reboot" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade_reboot.log
        echo -e  "DUT has upgraded from $Current_Version to $Destination_Version use GUI mode!"
        echo "Waiting time:180s!"
        sleep $DUT_Firmware_Upgrade_Waiting_Time
        sleep $DUT_Firmware_Upgrade_Waiting_Time
        DUT_Current_Info_Check $Destination_Version
        echo -e  "DUT has downgraded from $Current_Version to $Destination_Version use cli mode !"

}

Downgrade_DUT_Firmware_TV2KH(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.|head -n 1|awk -F. '{print $NF}'`
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use GUI  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
    if [ -z "$File_NAME" ];then
        echo "Destination fw version : ${U_DUT_TYPE}-${Destination_Version}.${EXT} not exist!"
        exit 1
    fi    
    if [ "$Destination_Version" == "31.30L.48" ];then
        echo "Need to downgrade to middle fw version : 31.122L.03b"
        if [ ! -f $U_CUSTOM_FW_DIR/TV2KH-31.122L.03b_NoSignCheck.img ];then
            echo "$U_CUSTOM_FW_DIR/TV2KH-31.122L.03b_NoSignCheck.img NOT exist!"
            exit 1
        fi
        perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "tftp -t i -g -f TV2KH-31.122L.03b_NoSignCheck.img  $TFTP_Server_Address"  -l $G_CURRENTLOG -o DUT_Firmware_Downgrade_To_Middle.log
        echo "Waiting time:180s to check DUT current firmware!"
        sleep $DUT_Firmware_Upgrade_Waiting_Time
        sleep $DUT_Firmware_Upgrade_Waiting_Time
        DUT_Current_Info_Check 31.121L.03b_NoSignCheck
        echo "Begin to downgrade to Destination_Version :$Destination_Version"
        sleep 30

    fi
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "tftp -t i -g -f $File_NAME  $TFTP_Server_Address"  -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log
    #rc=$?
    echo "Waiting time:180s to check DUT current firmware!"
    sleep $DUT_Firmware_Upgrade_Waiting_Time
    sleep $DUT_Firmware_Upgrade_Waiting_Time
    #if [ $rc -eq 0 ];then
       echo -e  "DUT has downgraded  to $Destination_Version use cli mode !"
       DUT_Current_Info_Check $Destination_Version
   #else
    #    echo -e "AT ERROR:Filed downgraded from $Current_Version to $Destination_Version use cli mode !"  
    #    exit 1
    #fi

}

Downgrade_DUT_Firmware_PK5K1A(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.|head -n 1|awk -F. '{print $NF}'`
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use GUI  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
    if [ -z "$File_NAME" ];then
        echo "Destination fw version : ${U_DUT_TYPE}-${Destination_Version}.${EXT} not exist!"
        exit 1
    fi    
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cd /mnt/data" -v "tftp -l fwimg -r $File_NAME -g $TFTP_Server_Address " -v "upgrade fwimg fullimage 0 1" -v "reboot" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log
    rc=$?
    if [ "$rc" == "0" ];then
        echo "sleep $DUT_Firmware_Upgrade_Waiting_Time"
        sleep $DUT_Firmware_Upgrade_Waiting_Time
        sleep $DUT_Firmware_Upgrade_Waiting_Time
        DUT_Current_Info_Check $Destination_Version
        echo -e  "DUT has downgraded from $Current_Version to $Destination_Version use cli mode !"
    else
        echo -e "AT ERROR:Filed downgraded from $Current_Version to $Destination_Version use cli mode !"  
        exit 1
    fi
}

Downgrade_DUT_Firmware_FT(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.|head -n 1|awk -F. '{print $NF}'`
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use GUI  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
    if [ -z "$File_NAME" ];then
        echo "Destination fw version : ${U_DUT_TYPE}-${Destination_Version}.${EXT} not exist!"
        exit 1
    fi    
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cd /"  -v "startupdate $TFTP_Server_Address $File_NAME" -v "exit" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log
    rc=$?
    if [ "$rc" == "0" ];then
       echo -e  "DUT has downgraded from $Current_Version to $Destination_Version use cli mode !"
#       echo -e "Wait $DUT_Firmware_Upgrade_Waiting_Time seconds  and check DUT firmware version"
#       sleep $DUT_Firmware_Upgrade_Waiting_Time
#       perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cd /" -v "reboot" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade_reboot.log
       echo "Waiting time:180s!"
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       DUT_Current_Info_Check $Destination_Version
    else
       echo -e "AT ERROR:Filed downgraded from $Current_Version to $Destination_Version use mode !"  
       exit 1
    fi
}

Downgrade_DUT_Firmware_BHR4_OpenWRT(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.|head -n 1|awk -F. '{print $NF}'`
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use GUI  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
    if [ -z "$File_NAME" ];then
        echo "Destination fw version : ${U_DUT_TYPE}-${Destination_Version}.${EXT} not exist!"
        exit 1
    fi    
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cd /"  -v "startupdate $TFTP_Server_Address $File_NAME" -v "exit" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log
    rc=$?
    if [ "$rc" == "0" ];then
       echo -e  "DUT has downgraded from $Current_Version to $Destination_Version use cli mode !"
#       echo -e "Wait $DUT_Firmware_Upgrade_Waiting_Time seconds  and check DUT firmware version"
#       sleep $DUT_Firmware_Upgrade_Waiting_Time
#       perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cd /" -v "reboot" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade_reboot.log
       echo "Waiting time:180s!"
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       DUT_Current_Info_Check $Destination_Version
    else
       echo -e "AT ERROR:Filed downgraded from $Current_Version to $Destination_Version use mode !"  
       exit 1
    fi
}

Downgrade_DUT_Firmware_BHR2(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.|head -n 1|awk -F. '{print $NF}'`
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use GUI  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
    if [ -z "$File_NAME" ];then
        echo "Destination fw version : ${U_DUT_TYPE}-${Destination_Version}.${EXT} not exist!"
        exit 1
    fi    
    if [ "$Destination_Version" == "20.11.0" ] || [ "$Destination_Version" == "20.9.0" ];then
        perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT  -v "flash load -u tftp://$TFTP_Server_Address/$File_NAME -s 4" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log -t 100
    else
        perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT  -v "firmware_update start -u tftp://$TFTP_Server_Address/$File_NAME" -v "exit" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log
    fi
    rc=$?
    if [ "$rc" == "0" ];then
       echo -e  "DUT has downgraded from $Current_Version to $Destination_Version use cli mode !"
       echo -e "Wait $DUT_Firmware_Upgrade_Waiting_Time seconds  and check DUT firmware version"
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "system reboot" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade_reboot.log
       echo "Waiting time:180s!"
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       $U_AUTO_CONF_BIN $U_DUT_TYPE /root/automation/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition/B-GEN-ENV.PRE-DUT.TELNET-001-C001
       DUT_Current_Info_Check $Destination_Version
    else
       echo -e "AT ERROR:Filed downgraded from $Current_Version to $Destination_Version use cli mode !"  
       exit 1
    fi
}
Downgrade_DUT_Firmware_BAR1KH(){
    Upgrade_DUT_Firmware
}
Downgrade_DUT_Firmware_TDSV2200H(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.|head -n 1|awk -F. '{print $NF}'`
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use GUI  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
    if [ -z "$File_NAME" ];then
        echo "Destination fw version : ${U_DUT_TYPE}-${Destination_Version}.${EXT} not exist!"
        exit 1
    fi    
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "tftp -t i -g -f $File_NAME  $TFTP_Server_Address"  -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log

       echo -e  "DUT has downgraded  to $Destination_Version use cli mode !"
       echo "Waiting time:180s to check DUT current firmware!"
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       DUT_Current_Info_Check $Destination_Version

}
Downgrade_DUT_Firmware_BCV1200(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.|head -n 1|awk -F. '{print $NF}'`
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use GUI  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
    if [ -z "$File_NAME" ];then
        echo "Destination fw version : ${U_DUT_TYPE}-${Destination_Version}.${EXT} not exist!"
        exit 1
    fi    
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "tftp -t i -g -f $File_NAME  $TFTP_Server_Address"  -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log

       echo -e  "DUT has downgraded  to $Destination_Version use cli mode !"
       echo "Waiting time:180s to check DUT current firmware!"
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       DUT_Current_Info_Check $Destination_Version

}

Try_telnet_DUT(){
    echo "In function:Try telnet DUT..."
    rc=0
    retry_times=10
    until [ $rc -eq $retry_times ]
        do  
            perl $U_PATH_TBIN/DUTCmd.pl -o checkTelnet.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT 
            Telnet_check=$?
            if [ "$Telnet_check" == "0" ];then
                echo " Passed in telnet DUT after firmware upgrade..."
                rc=$retry_times
            else
                let rc=$(($rc+1))
                if [ $rc -lt $retry_times ];then
                    echo "AT ERROR:Failed in telnet DUT after firmware upgrade...,retry:$rc after 15 seconds."
                    sleep 20
                elif [ $rc -eq $retry_times ];then
                  echo "Failed in login DUT check after retry $(($rc-1)) times"
                fi  
            fi
        done
}

Enable_DUT_Local_Telnet(){
    echo "Verify DUT LAN connect and enable DUT local telnet..."
    if [ "$upgrade_flag" == "True" ] || [ "$downgrade_flag" == "True" ];then
        pingtest
    else
        bash $U_PATH_TBIN/verifyDutLanConnected.sh
    fi
    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition/B-GEN-ENV.PRE-DUT.TELNET-001-C001"
    $U_AUTO_CONF_BIN $U_DUT_TYPE $SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition/B-GEN-ENV.PRE-DUT.TELNET-001-C001
    echo "Verify DUT LAN connect and Check the LAN device is able to telnet into DUT..."
    if [ "$upgrade_flag" == "True" ] || [ "$downgrade_flag" == "True" ];then
        pingtest
    else
        bash $U_PATH_TBIN/verifyDutLanConnected.sh
    fi
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o FirmwareUpgrade_checkTelnet.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT"
    perl $U_PATH_TBIN/DUTCmd.pl -o FirmwareUpgrade_checkTelnet.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT
    rc=$?
    if [ $rc -ne 0 ];then
        echo "AT_ERROR : Failed to telnet DUT after enable DUT local telnet,will have some retry..."
    fi
}

Check_and_force_flash_Current_FW(){
    if [ -z "$1" ];then
        current_version_check=$Current_Version
    else
        current_version_check=$1
    fi
    echo -e "Current DUT version to check is :"$current_version_check   
    bash $U_PATH_TBIN/cli_dut.sh -v dev.info  -o $G_CURRENTLOG/DUT_Default_Info_$current_version_check.log
    rc=$?
    echo "cli_dut.sh return value is ==> $rc"
    if [ $rc -eq 1 ];then
        Enable_DUT_Local_Telnet
        Try_telnet_DUT
        if [ $Telnet_check -eq 0 ];then
            bash $U_PATH_TBIN/cli_dut.sh -v dev.info  -o $G_CURRENTLOG/DUT_Default_Info_$current_version_check.log
        else
            echo fail "bash $U_PATH_TBIN/cli_dut.sh -v dev.info -o $G_CURRENTLOG/DUT_Default_Info_$current_version_check.log"
            echo fail "AT_ERROR : Get DUT date info Failed"
            exit 1
         fi
    fi
    DUT_Current_Version=`grep 'U_DUT_SW_VERSION' $G_CURRENTLOG/DUT_Default_Info_$current_version_check.log |awk -F= '{print $2}'`
    if [ -z $DUT_Current_Version ];then
        echo "Haven't get DUT current version,maybe DUT is rebooting,will retry it..."
        Try_telnet_DUT
        if [ $Telnet_check -eq 0 ];then
            bash $U_PATH_TBIN/cli_dut.sh -v dev.info  -o $G_CURRENTLOG/DUT_Default_Info_retry_$current_version_check.log
            DUT_Current_Version=`grep 'U_DUT_SW_VERSION' $G_CURRENTLOG/DUT_Default_Info_retry_$current_version_check.log |awk -F= '{print $2}'`
        else
            echo fail "bash $U_PATH_TBIN/cli_dut.sh -v dev.info -o $G_CURRENTLOG/DUT_Default_Info_retry_$current_version_check.log"
            echo fail "AT_ERROR : Get DUT date info Failed"
            exit 1
            fi
    fi
    tr_current_version_check=`echo $current_version_check|tr [A-Z] [a-z]`
    tr_DUT_Current_Version=`echo $DUT_Current_Version|tr [A-Z] [a-z]`
    if [ "$tr_current_version_check" != "$tr_DUT_Current_Version" ];then
        echo fail "AT_ERROR : DUT actual firmware version is :"$DUT_Current_Version
        echo "And the expect version is :"$current_version_check
        Downgrade_DUT_Firmware_$U_DUT_TYPE
    elif [ "$tr_current_version_check" == "$tr_DUT_Current_Version" ];then
        echo -e "Yes, DUT current version is:"$DUT_Current_Version
        exit 0
    fi
}
pingtest(){
    echo "Enter pingtest()"
    ipaddr=$1
    if [ -z "$ipaddr" ];then
        ipaddr=$G_PROD_IP_BR0_0_0
    fi
    for i in `seq 1 60`
    do
        echo "--------------------------------------------------"
        echo "Try ${i} times"
        ifconfig
        route -n
        echo "ping $ipaddr -c 1"
        ping $ipaddr -c 1
        if [ $? -eq 0 ];then
            return 0
        fi
        echo "sleep 5 seconds"
        sleep 5
    done
    exit 1
}
DUT_Current_Info_Check(){
    
    if [ -z "$1" ];then
        current_version_check=$Current_Version
    else
        current_version_check=$1
    fi
    echo "check DUT LAN connection..."
    python $U_PATH_TBIN/verifyPing.py -d $G_PROD_IP_BR0_0_0 -I eth1 -t 240 -l $G_CURRENTLOG
    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : Verified DUT LAN connection failed..."
    fi    
    echo -e "Current DUT version to check is :"$current_version_check   
    bash $U_PATH_TBIN/cli_dut.sh -v dev.info  -o $G_CURRENTLOG/DUT_Default_Info_$current_version_check.log
    rc=$?
    echo "cli_dut.sh return value is ==> $rc"
    if [ $rc -eq 1 ];then
        if [ "$upgrade_flag" == "True" ] ;then
            echo "Check fw version after Upgrade!"
            if [ "$U_DUT_TYPE" == "TV2KH" ];then
                if [ "$Current_Version" == "31.30L.48" ];then
                    Update_ENV_VAR
                    echo "Check fw version after Downgrade!"
                    echo "Enalbe telnet!"
                    Enable_DUT_Local_Telnet
                fi
            elif [ "$U_DUT_TYPE" == "BAR1KH" ];then
                if [ "$Current_Version" == "33.00L.28" ];then
                    Update_ENV_VAR
                    echo "Check fw version after Downgrade!"
                    echo "Enalbe telnet!"
                    Enable_DUT_Local_Telnet
                fi
            fi
        elif [ "$checkonly_flag" == "True" ];then
            echo "Only Check fw version!"
        elif [ "$downgrade_flag" == "True" ] ;then
            Update_ENV_VAR
            echo "Check fw version after Downgrade!"
            echo "Enalbe telnet!"
            Enable_DUT_Local_Telnet
        else
            echo "Enalbe telnet!"
            Enable_DUT_Local_Telnet
        fi
        Try_telnet_DUT
        if [ $Telnet_check -eq 0 ];then
            bash $U_PATH_TBIN/cli_dut.sh -v dev.info  -o $G_CURRENTLOG/DUT_Default_Info_$current_version_check.log
        else
            echo fail "bash $U_PATH_TBIN/cli_dut.sh -v dev.info -o $G_CURRENTLOG/DUT_Default_Info_$current_version_check.log"
            echo fail "AT_ERROR : Get DUT dev info Failed"
            exit 1
         fi
    fi
    DUT_Current_Version=`grep 'U_DUT_SW_VERSION' $G_CURRENTLOG/DUT_Default_Info_$current_version_check.log |awk -F= '{print $2}'`
    if [ -z $DUT_Current_Version ];then
        echo "Haven't get DUT current version,maybe DUT is rebooting,will retry it..."
        Try_telnet_DUT
        if [ $Telnet_check -eq 0 ];then
            bash $U_PATH_TBIN/cli_dut.sh -v dev.info  -o $G_CURRENTLOG/DUT_Default_Info_retry_$current_version_check.log
            DUT_Current_Version=`grep 'U_DUT_SW_VERSION' $G_CURRENTLOG/DUT_Default_Info_retry_$current_version_check.log |awk -F= '{print $2}'`
        else
            echo fail "bash $U_PATH_TBIN/cli_dut.sh -v dev.info -o $G_CURRENTLOG/DUT_Default_Info_retry_$current_version_check.log"
            echo fail "AT_ERROR : Get DUT date info Failed"
            exit 1
            fi
    fi
    tr_current_version_check=`echo $current_version_check|tr [A-Z] [a-z]`
    tr_DUT_Current_Version=`echo $DUT_Current_Version|tr [A-Z] [a-z]`
    if [ "$tr_current_version_check" != "$tr_DUT_Current_Version" ];then
        echo fail "AT_ERROR : DUT actual firmware version is :"$DUT_Current_Version
        echo "And the expect version is :"$current_version_check
        if [ "$U_DUT_TYPE" == "TV2KH" ] && [ "$DUT_Current_Version" == "31.60L.18" ];then
            echo "U_DUT_TYPE : $U_DUT_TYPE,DUT_Current_Version : $DUT_Current_Version"
            echo "No need reboot!"
        else
            DUT_Reboot_Waiting
        fi
        exit 1
    fi
    if [ "$tr_current_version_check" == "$tr_DUT_Current_Version" ];then
        echo -e "Yes, DUT current version is:"$DUT_Current_Version
        if [ "$downgrade_flag" == "True" ] || [ "$upgrade_flag" == "True" ] ;then
            Update_ENV_VAR
            echo "U_DUT_SW_VERSION=$DUT_Current_Version" | tee -a $output
        fi
        return 0
    fi
}
GetPostfileDirc(){
    echo "Enter GetPostfileDirc()"
    fw_version=$1
    echo "firmware version : $fw_version"
    
    mapping_table=$SQAROOT/testsuites/2.0/$U_DUT_TYPE/cfg/POSTFILE_MAPPING_TABLE
    echo "Postfile mapping table : $mapping_table"
    if [ ! -f $mapping_table ];then
        echo "AT_ERROR : $mapping_table not EXIST!"
        exit 1
    fi
    cat $mapping_table
    if [ -n $fw_version ];then
        
        grep -i "^$fw_version *:" $mapping_table
        if [ $? -eq 0 ];then
            U_DUT_FW_VERSION=`grep -i "^$fw_version *:" $mapping_table|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
        else
            U_DUT_FW_VERSION=`grep -i "^default *:" $mapping_table|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
        fi
        
    else
        U_DUT_FW_VERSION=`grep -i "^default *:" $mapping_table|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    fi
    echo "U_DUT_FW_VERSION : $U_DUT_FW_VERSION"
    if [ -z $U_DUT_FW_VERSION ];then
        echo "AT_ERROR : U_DUT_FW_VERSION IS NULL!"
        exit 1
    fi
    export U_DUT_FW_VERSION=$U_DUT_FW_VERSION
    echo "Leave GetPostfileDirc()"

}
Update_ENV_VAR(){
    echo "Update ENV Variable base fw version"
    if [ "$downgrade_flag" == "True" ] || [ "$upgrade_flag" == "True" ];then
        echo "U_DUT_TYPE : '${U_DUT_TYPE}'"
        echo "Destination_Version : '${Destination_Version}'"
        echo "downgrade_flag : '${downgrade_flag}'"
        echo "upgrade_flag : '${upgrade_flag}'"
        if [ "$U_DUT_TYPE" == "TV2KH" ];then
            if [ "$downgrade_flag" == "True" ];then
                if [ "$Destination_Version" == "31.60L.18" ] || [ "$Destination_Version" == "31.60L.17" ] || [ "$Destination_Version" == "31.30L.57" ] ;then
                    export U_DUT_HTTP_PWD=Thr33scr33n!
                    echo "U_DUT_HTTP_PWD=Thr33scr33n!" |tee $output
                    GetPostfileDirc $Destination_Version
                    echo U_DUT_FW_VERSION=$U_DUT_FW_VERSION |tee -a $output
                elif [ "$Destination_Version" == "31.30L.48" ] && [ "$current_version_check" == "31.30L.48" ];then
                    export U_DUT_HTTP_PWD=m3di@r00m!
                    echo "U_DUT_HTTP_PWD=m3di@r00m!" |tee $output
                    GetPostfileDirc $Destination_Version
                    echo U_DUT_FW_VERSION=$U_DUT_FW_VERSION |tee -a $output
                elif [ "$Destination_Version" == "31.30L.48" ] && [ "$current_version_check" == "31.121L.03b_NoSignCheck" ];then
                    echo "Downgrade to Middle fw version 31.122L.03b,No need update ENV var!"
                else
                    echo ""
                fi
            elif [ "$upgrade_flag" == "True" ];then
                export U_DUT_HTTP_PWD=$U_DUT_HTTP_PWD_CURRENT
                echo U_DUT_HTTP_PWD=$U_DUT_HTTP_PWD_CURRENT |tee $output
                #export U_DUT_FW_VERSION=$U_DUT_FW_VERSION_CURRENT
                #echo U_DUT_FW_VERSION=$U_DUT_FW_VERSION_CURRENT |tee -a $output
                GetPostfileDirc
                echo U_DUT_FW_VERSION=$U_DUT_FW_VERSION |tee -a $output
            else
                echo "No need update env variables for TV2KH $Destination_Version"
            fi

        elif [ "$U_DUT_TYPE" == "BAR1KH" ];then
            echo "BAR1KH"
            if [ "$Destination_Version" == "33.00L.28" ] && [ "$downgrade_flag" == "True" ];then
                GetPostfileDirc $Destination_Version
                echo U_DUT_FW_VERSION=$U_DUT_FW_VERSION |tee $output
            elif [ "$upgrade_flag" == "True" ];then
                GetPostfileDirc
                echo U_DUT_FW_VERSION=$U_DUT_FW_VERSION |tee $output
            else
                echo "No need update env variables for BAR1KH $Destination_Version"
            fi

        elif [ "$U_DUT_TYPE" == "BHR2" ];then
            echo "BHR2"
            if [ "$Destination_Version" == "20.9.0" ] && [ "$downgrade_flag" == "True" ];then
                GetPostfileDirc $Destination_Version
                echo U_DUT_FW_VERSION=$U_DUT_FW_VERSION |tee $output
            elif [ "$upgrade_flag" == "True" ];then
                GetPostfileDirc
                echo U_DUT_FW_VERSION=$U_DUT_FW_VERSION |tee $output
            else
                echo "No need update env variables for BHR2 $Destination_Version"
            fi

        fi
        if [ -f $output ];then
            sed -i "s/=/=\"/g" $output
            sed -i "/=/ s/ *$/\"/g" $output
            sed -i 's/`/\\`/g' $output
        fi
    else
        echo "No need update env variables"
    fi
}

main(){
echo '===================================================>main function !'

echo "Setting tftp server..."
service xinetd restart

if [ "$Check_Request" == "yes" ];then
    if [ -z "$Current_Version" ];then
        echo -e "Haven't specify DUT current firmware version for check !"   
        exit 1
    else
        echo -e "Check DUT current firmware version!"
        DUT_Current_Info_Check
    fi
fi
if [ "$Check_Request" == "no" ] && [ -z "$Destination_Version" ];then
    echo -e "Haven't specify DUT destination firmware version !"   
    exit 1
fi
if [ -z "$Current_Version" ] && [ "$Check_Request" == "no" ] && [ -n "$Destination_Version" ];then
    echo -e "Force change DUT firmware to $Destination_Version"
    Check_and_force_flash_Current_FW $Destination_Version
fi

if [ "$upgrade_flag" == "True" ];then
    echo "Upgrade_DUT_Firmware from $Current_Version to $Destination_Version"
    Upgrade_DUT_Firmware
elif [ "$downgrade_flag" == "True" ];then
    echo "Downgrade_DUT_Firmware_$U_DUT_TYPE to $Destination_Version"
    Check_and_force_flash_Current_FW $Destination_Version
elif [ -n "$Current_Version" ] && [ "$Check_Request" == "no" ] && [ -n "$Destination_Version" ];then
            echo -e "Compare DUT firmware version"
            str_a=$Current_Version
            str_b=$Destination_Version
            if [ "$str_a" \< "$str_b" ];then
                echo -e "The high version is ":$str_b
                echo -e "Use GUI upgrade firmware version mode!"
                Upgrade_DUT_Firmware
            fi
            if [ "$str_a" \> "$str_b" ];then
                echo -e "The high version is ":$str_a
                echo -e "Use cli command upgrade firmware version mode!"
                Check_and_force_flash_Current_FW $Destination_Version
            fi
fi

}
if [ "$mode" == "tr69" ] && [ -n "$Destination_Version" ];then
    EXT=`ls $U_CUSTOM_FW_DIR|grep $Destination_Version|head -n 1|awk -F. '{print $NF}'`      
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    if [ -z "$File_NAME" ];then
        echo "Destination fw version : ${U_DUT_TYPE}-${Destination_Version}.${EXT} not exist!"
        exit 1
    fi
    echo -e "Copy the firmware file $File_NAME from $U_CUSTOM_FW_DIR to /var/www/html "
    perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/copy_$File_NAME.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "cp $U_CUSTOM_FW_DIR/$File_NAME /var/www/html" &
    echo "bash tr69client.sh -s $U_DUT_SN -g \"http://$TMP_DUT_DEF_GW/$File_NAME\" -v downld -o $G_CURRENTLOG/tr69_upgrade_output.log -l $G_CURRENTLOG/tr69_upgrade_log.log -f $G_CURRENTLOG/tr69_upgrade_soap.log -x 5"
    
    bash tr69client.sh -s $U_DUT_SN -g "http://$TMP_DUT_DEF_GW/$File_NAME" -v downld -o $G_CURRENTLOG/tr69_upgrade_output.log -l $G_CURRENTLOG/tr69_upgrade_log.log -f $G_CURRENTLOG/tr69_upgrade_soap.log -x 5
    rc=$?
    if [ "$rc" == "0" ];then
       DUT_Current_Info_Check $Destination_Version
    else
       echo -e "AT ERROR:Filed downgraded from $Current_Version to $Destination_Version use tr69 mode !"  
       exit 1
    fi
else
    main
fi

