#!/bin/bash

#---------------------------------
# Name: Alex Dai
# Description:
# This script is used to
#
#--------------------------------
# History    :
#   DATE        |   REV     | AUTH    | INFO
#13 Apr 2012    |   1.0.0   | Alex    | Inital Version

#   CASE_NAME:FLAG_GUI_SETUP:FLAG_RESTORE:FLAG_GUI_CHECK:FLAG_TEMP_ID:GUI-SETUP-POST-FILES[+GUI-SETUP-POST-FILES]:POST-FILE-RESTORE:GUI-CHECK-POST-FILES[+GUI-CHECK-POST-FILES]:CONFIG_FILE_PARAMETERS
#
#   jobs to do in resolve_CONFIG_LOAD.h
#
#   {
#   CASE_NAME:  string , testcase name
#
#   FLAG_GUI_SETUP: integer , 1 for do setup , 0 for skip setup , store it to a variable
#
#   FLAG_RESTORE: integer , 1 for do restore , 0 for skip restore , store it to a variable
#
#   FLAG_GUI_CHECK:  integer , 1 for do GUI check , 0 for skip GUI check , store it to a variable
#
#   FLAG_TEMPLATE_ID:   integer , store it to a variable
#
#   GUI-SETUP-POST-FILES[+GUI-SETUP-POST-FILES]:    a list of post files seperated by comma and '+', store it to array1 ,array2 and so on
#
#   POST-FILE-RESTORE:  a list of post files seperated by comma ,  store it to array1 ,array2 and so on
#
#   GUI-CHECK-POST-FILES[+GUI-CHECK-POST-FILES]:    a list of post files seperated by comma and '+',  store it to array1 ,array2 and so on
#
#   CONFIG_FILE_PARAMETERS: string  ,and store SSID name(s) to an array , store wifi client config paramter to a variable
#######################################################################################################################

###======test parameters:=======
#while [ -n "$1" ];
#do
#    case "$1" in
#    -test)
#        echo debug "mode : test mode"
#        U_PATH_TBIN=/root/automation/bin/2.0/Q2KH
#        U_WIRELESS_SSID1="TELUS0122"
#        U_WIRELESS_SSID2="TELUS0122-2"
#        U_WIRELESS_SSID3="TELUS0122-3"
#        U_WIRELESS_SSID4="TELUS0122-4"
#        G_CURRENTLOG="./0052__B-GEN-SEC.FW-003.xml"
#        U_CUSTOM_CONFIG_LOAD="/root/automation/testsuites/2.0/Q2KH/alex/cfg/CONFIG_LOAD"
#        U_CUSTOM_SCAN_TCP_PORT=1-65535
#        U_CUSTOM_SCAN_UDP_PORT=1-1024
#        U_CUSTOM_IPERF_PORT="100,500,1000,10000,20000,30000,40000,50000,60000"
#        U_CUSTOM_IPERF_TCP_PORT=80
#        U_CUSTOM_IPERF_UDP_PORT=520
#        shift 1
#        ;;    
#    *)
#        echo "AT_ERROR : parameters input error!"
#        exit 1
#        ;;
#    esac
#done
##################################


case_name=`echo "$G_CURRENTLOG" | xargs -n1 basename |sed "s/^[0-9]\{4,\}__//g"`

flag_gui_setup=0

flag_restore=0

flag_gui_check=0

flag_template_id=0

gui_post_files1=(
)

gui_post_files2=(
)

restore_post_files=(
)

gui_check_post_files1=(
)

gui_check_post_files2=(
)

wifi_client_config=""

ssid_names=(
)


#   U_PATH_TBIN=$G_SQAROOT/bin/$G_BINVERSION/$U_DUT_TYPE

if [ -z $G_CURRENTLOG ] ;then
    log_dir=/tmp
else
    log_dir=$G_CURRENTLOG
fi

createlogname(){
    lognamex=`basename $0`
    
    ls $log_dir/$lognamex*.log 2> /dev/null
    
    if [ $? -gt 0 ]; then
        
        echo -e " current log : "$lognamex"_1.log"
        current_log=$log_dir/$lognamex"_1.log"
    else
        
        curr=`ls $log_dir/$lognamex*.log|wc -l`
        let "next=$curr+1"
        echo -e " current log : "$lognamex"_"$next".log"
        current_log=$log_dir/$lognamex"_"$next".log"
    fi
}

do_MAC_initial(){
    echo "initial all the variables for WI.MAC cases"
        
    ConfRule=`grep "^$case_name" $G_CURRENTLOG/CONFIG_LOAD`

    if [ -z "$ConfRule" ]; then
        echo "AT_ERROR : No config rule for case $case_name!"
        exit 1
    fi
    echo "Config rule is : $ConfRule"

    flag_gui_setup=`echo $ConfRule | awk -F : '{print $2}'`

    flag_restore=`echo $ConfRule | awk -F : '{print $3}'`

    flag_gui_check=`echo $ConfRule | awk -F : '{print $4}'`

    flag_template_id=`echo $ConfRule | awk -F : '{print $5}'`

    GuiPostFiles=`echo $ConfRule | awk -F : '{print $6}'`

    RestorePostFiles=`echo $ConfRule | awk -F : '{print $7}'`

    GuiCheckPostFiles=`echo $ConfRule | awk -F : '{print $8}'`

    postFilesIndex=1
    line=''
    for line in `echo "$GuiPostFiles" | sed "s/,/ /g"`
    do
        if [ $postFilesIndex -eq 1 ]; then        
            gui_post_files1=(`echo $line | sed 's/+/ /g'`)
        elif [ $postFilesIndex -eq 2 ]; then
            gui_post_files2=(`echo $line | sed 's/+/ /g'`)
        fi
        let "postFilesIndex=$postFilesIndex+1"
    done
        
    restore_post_files=(`echo $RestorePostFiles | sed 's/+/ /g'`)

    checkPostFilesIndex=1
    line=''
    for line in `echo "$GuiCheckPostFiles" | sed "s/,/ /g"`
    do
#        arrName='gui_check_post_files'$checkPostFilesIndex
#        echo $arrName
#        eval $arrName=(`echo $line | sed 's/+/ /g'`)
        if [ $checkPostFilesIndex -eq 1 ]; then
            gui_check_post_files1=(`echo $line | sed 's/+/ /g'`)
        elif [ $checkPostFilesIndex -eq 2 ]; then
            gui_check_post_files2=(`echo $line | sed 's/+/ /g'`)
        fi
        let "checkPostFilesIndex=$checkPostFilesIndex+1"
    done

    wifi_client_config=`echo $ConfRule | awk -F : '{print $9}' | sed 's/.*\*//g'`
    SSID_number=`echo $ConfRule | awk -F : '{print $9}' |grep '*' | awk -F '*' '{print $1}'`


    if [ -n "$SSID_number" ]; then
        for idx in `seq 1 $SSID_number`
        do
            if [ -z "$SSIDs" ]; then
                eval tmp_ssid='$''U_WIRELESS_SSID'$idx
            else
                eval tmp_ssid='$''U_WIRELESS_SSID'$idx
                #SSIDs="$SSIDs $tmp_ssid"
            fi
            
            len_ssid_names=${#ssid_names[@]}
            ssid_names[len_ssid_names]=$tmp_ssid
        done
        #ssid_names=($SSIDs)
    fi
}

do_FW_initial(){

#expect_scan_result1=
#expect_scan_result2=
#expect_iperf_result1=
#expect_iperf_result2=
#expect_packt_read_filter=
#expect_ping_result1=
#expect_ping_result2=
#filtered_ports1=()
#blocked_ports1=()
#unblocked_ports1=()
#nmap_check_type= ## all_filtered_except | all_not_filtered_except |all_not_filtered


    echo "initial all the variables for SEC.FW cases"
    
    ConfRule=`grep "^$case_name" $G_CURRENTLOG/CONFIG_LOAD`

    if [ -z "$ConfRule" ]; then
        echo "AT_ERROR : No config rule for case $case_name!"
        exit 1
    fi
    echo "Config rule is : $ConfRule"

    flag_gui_setup=`echo $ConfRule | awk -F : '{print $2}'`

    flag_restore=`echo $ConfRule | awk -F : '{print $3}'`

    flag_icmp_request=`echo $ConfRule | awk -F : '{print $4}'`

    flag_traffic=`echo $ConfRule | awk -F : '{print $5}'`

    flag_template_id=`echo $ConfRule | awk -F : '{print $6}'`

    icmp_command=`echo $ConfRule | awk -F : '{print $7}'`

    GuiPostFiles=`echo $ConfRule | awk -F : '{print $8}'`

    RestorePostFiles=`echo $ConfRule | awk -F : '{print $9}'`

    nmap_port=`echo $ConfRule | awk -F : '{print $10}'`
#    nmap_port=`echo $ConfRule | awk -F : '{print $10}'|sed 's/(/{/g' |sed 's/)/}/g'`
#    nmap_port=`eval echo $nmap_port|sed 's/{/(/g'|sed 's/}/)/g'`

    iperf_port=`echo $ConfRule | awk -F : '{print $11}'`
#    iperf_port=`echo $ConfRule | awk -F : '{print $11}'|sed 's/(/{/g' |sed 's/)/}/g'`
#    iperf_port=`eval echo $iperf_port|sed 's/{/(/g'|sed 's/}/)/g'`

    expected_nmap_result=`echo "$ConfRule" | awk -F : '{print $12}'`
#    expected_nmap_result=`echo "$ConfRule" | awk -F : '{print $12}'|sed 's/(/{/g' |sed 's/)/}/g'`
#    echo $expected_nmap_result
#    expected_nmap_result=`eval echo $expected_nmap_result|sed 's/{/(/g'|sed 's/}/)/g'`
#    echo $expected_nmap_result

    expected_iperf_result=`echo $ConfRule | awk -F : '{print $13}'`
#    expected_iperf_result=`echo $ConfRule | awk -F : '{print $13}'|sed 's/(/{/g' |sed 's/)/}/g'`
#    expected_iperf_result=`eval echo $expected_iperf_result|sed 's/{/(/g'|sed 's/}/)/g'`

    expected_packet_read_filter=`echo $ConfRule | awk -F : '{print $14}'`
    negative_flag=`echo "$expected_packet_read_filter"|grep -o "^N"`
    if [ "$negative_flag" == "N" ]; then
        flag_icmp_negative=1
    else
        flag_icmp_negative=0
    fi
    expected_packet_read_filter=`echo $expected_packet_read_filter|sed 's/.*(//g'|sed 's/).*//g'`

    expected_ping_result=`echo $ConfRule | awk -F : '{print $15}'`

    if [ $flag_traffic = 0 ]; then
        traffic_type="in"
    elif [ $flag_traffic = 1 ];then
        traffic_type="out"
    else
        traffic_type="null"
    fi

    idx=1
    line=''
    for line in `echo "$GuiPostFiles" | sed "s/,/ /g"`
    do
        if [ $idx -eq 1 ]; then        
            gui_post_files1=(`echo $line | sed 's/+/ /g'`)
        elif [ $idx -eq 2 ]; then
            gui_post_files2=(`echo $line | sed 's/+/ /g'`)
        fi
        let "idx=$idx+1"
    done
        
    restore_post_files=(`echo $RestorePostFiles | sed 's/+/ /g'`)

    idx=1
    line=''
    for line in `echo "$nmap_port" | sed "s/+/ /g"`
    do
        if [ $idx -eq 1 ]; then        
            scan_port1=(`echo $line | sed 's/,/ /g'`)
        elif [ $idx -eq 2 ]; then
            scan_port2=(`echo $line | sed 's/,/ /g'`)            
        elif [ $idx -eq 3 ]; then
            scan_port3=(`echo $line | sed 's/,/ /g'`)
        fi
        let "idx=$idx+1"
    done

    idx=1
    line=''
    for line in `echo "$iperf_port" | sed "s/+/ /g"`
    do
        echo $line
        if [ $idx -eq 1 ]; then        
            iperf_port1=(`echo $line | sed 's/,/ /g'`)
        elif [ $idx -eq 2 ]; then
            iperf_port2=(`echo $line | sed 's/,/ /g'`)
        fi
        let "idx=$idx+1"
    done

    idx=1
    line=''
    for line in `echo "$expected_nmap_result" | sed "s/+/ /g"`
    do
        echo "$line"
        if [ $idx -eq 1 ]; then        
            nmap_check_type1=`echo $line | sed 's/(.*//g'`
            filtered_ports1=(`echo $line | grep "(.*)" | sed 's/.*(//g' | sed 's/).*//g' | sed 's/,/ /g'`)
        elif [ $idx -eq 2 ]; then
            nmap_check_type2=`echo $line | sed 's/(.*//g'`
            filtered_ports2=(`echo $line | grep "(.*)" | sed 's/.*(//g' | sed 's/).*//g' | sed 's/,/ /g'`)            
        elif [ $idx -eq 3 ]; then
            nmap_check_type3=`echo $line | sed 's/(.*//g'`
            filtered_ports3=(`echo $line | grep "(.*)" | sed 's/.*(//g' | sed 's/).*//g' | sed 's/,/ /g'`)
        fi
        let "idx=$idx+1"
    done

    idx=1
    line=''
    for line in `echo "$expected_iperf_result" | sed "s/+/ /g"`
    do
        echo $line
        if [ $idx -eq 1 ]; then        
            expected_iperf_result1=$line
            for rule in `echo "$line"|sed "s/&/ /"`
            do
                if [ `echo $rule|grep "unblocked"` ]; then
                    unblocked_ports1=(`echo $rule | sed 's/.*(//g' | sed 's/).*//g' | sed 's/,/ /g'`)
                else
                    blocked_ports1=(`echo $rule | sed 's/.*(//g' | sed 's/).*//g' | sed 's/,/ /g'`)
                fi
            done
        elif [ $idx -eq 2 ]; then
            expected_iperf_result2=$line
            for rule in `echo "$line"|sed "s/&/ /"`
            do
                if [ `echo $rule|grep "unblocked"` ]; then
                    unblocked_ports2=(`echo $rule | sed 's/.*(//g' | sed 's/).*//g' | sed 's/,/ /g'`)
                else
                    blocked_ports2=(`echo $rule | sed 's/.*(//g' | sed 's/).*//g' | sed 's/,/ /g'`)
                fi
            done
        fi
        let "idx=$idx+1"
    done

    idx=1
    line=''
    for line in `echo "$expected_ping_result" | sed "s/,/ /g"`
    do
        echo $line
        if [ $idx -eq 1 ]; then        
            expected_ping_result1="$line"
        elif [ $idx -eq 2 ]; then
            expected_ping_result2="$line"
        fi
        let "idx=$idx+1"
    done

}


do_check(){
    echo "case name : $case_name"

    echo "flag_gui_setup : $flag_gui_setup"
    
    echo "flag_restore : $flag_restore"
    
    echo "flag_gui_check : $flag_gui_check"

    echo "flag_icmp_request : $flag_icmp_request"
    
    echo "flag_template_id : $flag_template_id"
    
    echo "gui_post_files1 : ${gui_post_files1[@]}"
    
    echo "gui_post_files2 : ${gui_post_files2[@]}"
    
    echo "restore_post_files : ${restore_post_files[@]}"
    
    echo "gui_check_post_files1 : ${gui_check_post_files1[@]}"
    
    echo "gui_check_post_files2 :${gui_check_post_files2[@]}"
    
    echo "wifi_client_config : $wifi_client_config"
    
    echo "ssid_names : ${ssid_names[@]}"
    
    echo "ssid count : ${#ssid_names[@]}"

    echo "traffic_type : $traffic_type"

    echo "icmp_command : $icmp_command"

    echo "scan_port1 : ${scan_port1[@]}"

    echo "scan_port2 : ${scan_port2[@]}"

    echo "scan_port3 : ${scan_port3[@]}"
    
    echo "iperf_port1 : ${iperf_port1[@]}"

    echo "iperf_port2 : ${iperf_port2[@]}"

    if [ ${#filtered_ports1[@]} = 0 ]; then
        echo "expected_scan_result1 : $nmap_check_type1"
    else
        echo "expected_scan_result1 : $nmap_check_type1 ${filtered_ports1[@]}"
    fi

    if [ ${#filtered_ports2[@]} = 0 ]; then
        echo "expected_scan_result2 : $nmap_check_type2"
    else
        echo "expected_scan_result2 : $nmap_check_type2 ${filtered_ports2[@]}"
    fi

    if [ ${#filtered_ports3[@]} = 0 ]; then
        echo "expected_scan_result3 : $nmap_check_type3"
    else
        echo "expected_scan_result3 : $nmap_check_type3 ${filtered_ports3[@]}"
    fi

    echo "expected_iperf_result1 : blocked_ports1:${blocked_ports1[@]} + unblocked_ports1:${unblocked_ports1[@]}"

    echo "expected_iperf_result2 : blocked_ports2:${blocked_ports2[@]} + unblocked_ports2:${unblocked_ports2[@]}"

    echo "flag_icmp_negative : $flag_icmp_negative"

    echo "expected_icmp_packet_read_filter : $expected_packet_read_filter"

    echo "expected_ping_result1 : $expected_ping_result1"

    echo "expected_ping_result2 : $expected_ping_result2"

}
#createlogname

#echo "creating $current_log"
#touch $current_log
if [ -f "$U_CUSTOM_CONFIG_LOAD" ]; then
    if [ ! -f "$G_CURRENTLOG/CONFIG_LOAD" ]; then    
        dos2unix $U_CUSTOM_CONFIG_LOAD    
        echo "perl $U_PATH_TBIN/env2file.pl -i $U_CUSTOM_CONFIG_LOAD -o $G_CURRENTLOG/CONFIG_LOAD "
        perl $U_PATH_TBIN/env2file.pl -i $U_CUSTOM_CONFIG_LOAD -l $G_CURRENTLOG -o $G_CURRENTLOG/CONFIG_LOAD    
        if [ $? -ne 0 ]; then
            echo "AT_ERROR : excute env2file.pl fail!"
            exit 1
        fi
    fi
else
    echo "AT_ERROR : Config file \"$U_CUSTOM_CONFIG_LOAD\" is not exist!"
    exit 1
fi

if [ `echo $case_name|egrep -o "(WI\.MAC|19376|19377|32731)"|tail -1` ]; then
    do_MAC_initial
elif [ `echo $case_name|egrep -o "(SEC\.FW|19404)"|tail -1` ];then
    do_FW_initial
else
    do_FW_initial
fi

do_check
