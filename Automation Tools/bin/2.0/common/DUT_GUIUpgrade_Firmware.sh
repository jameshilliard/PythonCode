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
TFTP_Server_Address=$G_HOST_TIP0_1_0
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
    EXT=`ls $U_CUSTOM_FW_DIR|grep $Destination_Version|head -n 1|awk -F. '{print $NF}'`
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use GUI  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME

    playback_http $U_DUT_TYPE  -v TMP_HTTP_HOST=$G_PROD_IP_BR0_0_0  --upgrade_firmware_file=$U_CUSTOM_FW_DIR/$File_NAME
    rc=$?
    if [ "$rc" == "0" ];then
       echo -e  "DUT has upgraded from $Current_Version to $Destination_Version use GUI mode!"
       echo -e "Wait $DUT_Firmware_Upgrade_Waiting_Time seconds nd check DUT firmware version !"
       echo "Waiting time:180s!"
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       sleep $DUT_Firmware_Upgrade_Waiting_Time
#DUT_Current_Info_Check $Destination_Version
   else
       echo -e "AT ERROR:Filed upgraded from $Current_Version to $Destination_Version use GUI mode!"  
       exit 1
    fi
}


Downgrade_DUT_Firmware_CTLC2KA(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $Destination_Version|head -n 1|awk -F. '{print $NF}'` 
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use tftp  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cp /bin/busybox /var/" -v "tftp -t i -g -f $File_NAME -d 3 $TFTP_Server_Address" -v "/var/busybox reboot" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log
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
##    EXT=`ls $U_CUSTOM_FW_DIR|grep $Destination_Version|head -n 1|awk -F. '{print $NF}'` 
##    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
##    echo -e "Change DUT firmware version use tftp  to version:"$Destination_Version
##    echo -e "$Destination_Version firmware name is :"$File_NAME
Upgrade_DUT_Firmware
##
##    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "tftp -t i -g -f $File_NAME  $TFTP_Server_Address"  -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log
##
##       echo -e  "DUT has downgraded  to $Destination_Version use cli mode !"
##       echo "Waiting time:180s to check DUT current firmware!"
##       sleep $DUT_Firmware_Upgrade_Waiting_Time
##       sleep $DUT_Firmware_Upgrade_Waiting_Time
##       DUT_Current_Info_Check $Destination_Version
##
}

Downgrade_DUT_Firmware_PK5K1A(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $Destination_Version|head -n 1|awk -F. '{print $NF}'`  
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use tftp  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
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
    EXT=`ls $U_CUSTOM_FW_DIR|grep $Destination_Version|head -n 1|awk -F. '{print $NF}'` 
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use tftp  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
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
    EXT=`ls $U_CUSTOM_FW_DIR|grep $Destination_Version|head -n 1|awk -F. '{print $NF}'` 
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use tftp  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT  -v "firmware_update start -u tftp://$TFTP_Server_Address/$File_NAME" -v "exit" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log
    rc=$?
    if [ "$rc" == "0" ];then
       echo -e  "DUT has downgraded from $Current_Version to $Destination_Version use cli mode !"
       echo -e "Wait $DUT_Firmware_Upgrade_Waiting_Time seconds  and check DUT firmware version"
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "system" -v "reboot" -l $G_CURRENTLOG -o DUT_Firmware_Downgrade_reboot.log
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
    EXT=`ls $U_CUSTOM_FW_DIR|grep $Destination_Version|head -n 1|awk -F. '{print $NF}'` 
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use tftp  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME

    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "tftp -t i -g -f $File_NAME  $TFTP_Server_Address"  -l $G_CURRENTLOG -o DUT_Firmware_Downgrade.log

       echo -e  "DUT has downgraded  to $Destination_Version use cli mode !"
       echo "Waiting time:180s to check DUT current firmware!"
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       sleep $DUT_Firmware_Upgrade_Waiting_Time
       DUT_Current_Info_Check $Destination_Version

}
Downgrade_DUT_Firmware_BCV1200(){
    EXT=`ls $U_CUSTOM_FW_DIR|grep $Destination_Version|head -n 1|awk -F. '{print $NF}'` 
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
    echo -e "Change DUT firmware version use tftp  to version:"$Destination_Version
    echo -e "$Destination_Version firmware name is :"$File_NAME

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
    retry_times=4
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
DUT_Current_Info_Check(){
    if [ -z "$1" ];then
        current_version_check=$Current_Version
    else
        current_version_check=$1
    fi
    echo -e "Current DUT version to check is :"$current_version_check   
#    Try_telnet_DUT
#    if [ $Telnet_check -eq 0 ];then
        bash $U_PATH_TBIN/cli_dut.sh -v dev.info  -o $G_CURRENTLOG/DUT_Default_Info_$current_version_check.log
#    else
#        echo fail "bash $U_PATH_TBIN/cli_dut.sh -v dev.info -o $G_CURRENTLOG/DUT_Default_Info_$current_version_check.log"
#        echo fail "AT_ERROR : Get DUT date info Failed"
#        exit 1
#    fi
        rc=$?
        echo "cli_dut.sh return value is ==> $rc"
        if [ $rc -eq 1 ];then
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
    tr_current_version_check=`echo $current_version_check|tr [A-Z] [a-z]`
    tr_DUT_Current_Version=`echo $DUT_Current_Version|tr [A-Z] [a-z]`
    if [ "$tr_current_version_check" != "$tr_DUT_Current_Version" ];then
        echo fail "AT_ERROR : DUT actual firmware version is :"$DUT_Current_Version
        echo "And the expect version is :"$current_version_check
        DUT_Reboot_Waiting
        exit 1
    fi
    if [ "$tr_current_version_check" == "$tr_DUT_Current_Version" ];then
        echo -e "Yes, DUT current version is:"$DUT_Current_Version
        exit 0
    fi
}

main(){
echo '===================================================>main function !'
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
    Downgrade_DUT_Firmware_$U_DUT_TYPE
fi
if [ -n "$Current_Version" ] && [ "$Check_Request" == "no" ] && [ -n "$Destination_Version" ];then
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
                Downgrade_DUT_Firmware_$U_DUT_TYPE 
            fi
fi

}
if [ "$mode" == "tr69" ] && [ -n "$Destination_Version" ];then
    EXT=`ls $U_CUSTOM_FW_DIR|grep $Destination_Version|head -n 1|awk -F. '{print $NF}'`      
    File_NAME=`ls $U_CUSTOM_FW_DIR|grep $U_DUT_TYPE-$Destination_Version\.$EXT`
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

