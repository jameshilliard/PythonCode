#!/bin/bash
#---------------------------------
# Name: Howard Yin
# Description:
# This script is used to
#
#--------------------------------
# History    :
#   DATE        |   REV  | AUTH   | INFO
#13 Apr 2012    |   1.0.0   | howard    | Inital Version

if [ -z $U_PATH_TBIN ] ;then
    source resolve_CONFIG_LOAD.sh
else
    source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh
fi

REV="$0 version 1.0.0 (13 Apr 2012)"
# print REV
echo "${REV}"

nega=0

while [ $# -gt 0 ]
do
    case "$1" in
    -n)
        nega=1
        echo "negative mode engaged!"
        shift 1
        ;;
    -s)
        ssid=$2
        if [ "$ssid" == "" ] ;then
            echo "AT_ERROR : ssid is empty !"
            exit 1
        fi
        echo "target SSID : ${ssid}"
        shift 2
        ;;
    *)
        echo ".."
        exit 1
        ;;
    esac
done

#   wifi_client_config=""
#
#   ssid_names=(
#   )

count_ssid=${#ssid_names[@]}

if [ $count_ssid -eq 0 -a "$ssid" == "" ] ;then
	ssid=$U_WIRELESS_CUSTOM_SSID_SEL
fi

do_each_scan(){
    echo "scan each SSID"
    if [ "$ssid" == "" ] ;then
        echo "to scan each SSID on DUT"
        
        count_ssid=${#ssid_names[@]}
        
        echo "number of SSID : ${count_ssid}"
        
		if [ $count_ssid -eq 0 ] ;then
			echo "AT_ERROR : intented to scan all SSIDs , but no SSID given ."
			exit 1
		fi
		
        scan_result=$count_ssid
        
        for ((i=0;i<${#ssid_names[@]};i++));
        do
            echo "scanning SSID $i"
            current_ssid=${ssid_names[i]}
#   bash $U_PATH_TBIN/wifi_scan.sh -s $U_WIRELESS_CUSTOM_SSID_SEL -i $U_WIRELESSINTERFACE
            #if [ $nega -eq 0 ] ;then
            bash $U_PATH_TBIN/wifi_scan.sh -s "$current_ssid" -i $U_WIRELESSINTERFACE
            
            scan_rc=$?
            
            if [ $scan_rc -eq 0 ] ;then
                let "scan_result=$scan_result-1"
            fi
            #else
            #   bash $U_PATH_TBIN/wifi_scan.sh -s $current_ssid -i $U_WIRELESSINTERFACE
            #fi
        done
        
        if [ $scan_result -gt 0 ] ;then
            echo "AT_ERROR : wifi scan failed"
            exit $scan_result
        else
            echo "wifi scan passed"
        fi
    else
        echo "to scan $ssid on DUT"
        bash $U_PATH_TBIN/wifi_scan.sh -s "$ssid" -i $U_WIRELESSINTERFACE
            
        scan_rc=$?
        
        if [ $scan_rc -gt 0 ] ;then
            echo "AT_ERROR : wifi scan failed"
            exit $scan_rc
        else
            echo "wifi scan passed"
        fi
    fi
    }

do_each_generate_config(){
    echo "config file of $wifi_client_config"
    
    if [ "$ssid" == "" ] ;then
        echo "to prepare wifi client config file for every SSID on DUT"
        
        count_ssid=${#ssid_names[@]}
        
        echo "number of SSID : ${count_ssid}"
        
        for ((i=0;i<${#ssid_names[@]};i++));
        do
            echo "generating config file of SSID $i"
            current_ssid=${ssid_names[i]}
            current_ssid_index=$((i+1))
            bash $U_PATH_TBIN/wifi_generate_config.sh -i $current_ssid_index -s "$current_ssid" -t $wifi_client_config -f $G_CURRENTLOG/wifi_config_file_$current_ssid_index
        done
    else
        echo "to prepare wifi client config file for $ssid"
        
        #   $U_WIRELESS_SSID1
        val_ssid1=`echo $U_WIRELESS_SSID1  |sed "s/[\\|\"]//g"`
        val_ssid2=`echo $U_WIRELESS_SSID2  |sed "s/[\\|\"]//g"`
        val_ssid3=`echo $U_WIRELESS_SSID3  |sed "s/[\\|\"]//g"`
        val_ssid4=`echo $U_WIRELESS_SSID4  |sed "s/[\\|\"]//g"`
        
        if [ "$ssid" == "$val_ssid1" ] ;then
            ssid_index=1
        elif [ "$ssid" == "$val_ssid2" ] ;then
            ssid_index=2
        elif [ "$ssid" == "$val_ssid3" ] ;then
            ssid_index=3
        elif [ "$ssid" == "$val_ssid4" ] ;then
            ssid_index=4
        else
            echo "AT_ERROR : wrong ssid name : $ssid"
            exit 1
        fi
        
        bash $U_PATH_TBIN/wifi_generate_config.sh -i $ssid_index -s "$ssid" -t $wifi_client_config -f $G_CURRENTLOG/wifi_config_file_$ssid_index
    fi  
    
    }

do_each_connect(){
    if [ "$ssid" == "" ] ;then
        echo "to connect each SSID on DUT"
        
        count_ssid=${#ssid_names[@]}
        
        echo "number of SSID : ${count_ssid}"
        
        conn_result=$count_ssid
        
        for ((i=0;i<${#ssid_names[@]};i++));
        do
            current_ssid_index=$((i+1))
            echo " == | >> connecting to SSID $current_ssid_index << | =="
                        
            if [ $nega -eq 0 ] ;then
                bash $U_PATH_TBIN/wifi_connect_DUT.sh -f $G_CURRENTLOG/wifi_config_file_$current_ssid_index -i $U_WIRELESSINTERFACE -t 10
            else
                bash $U_PATH_TBIN/wifi_connect_DUT.sh -f $G_CURRENTLOG/wifi_config_file_$current_ssid_index -i $U_WIRELESSINTERFACE -t 10 -n
            fi
            
            conn_rc=$?
            
            if [ $conn_rc -eq 0 ] ;then
                let "conn_result=$conn_result-1"
            fi
        done
        
        if [ $conn_result -eq 0 ] ;then
            echo "connect to every SSID passed"
        else
            echo "AT_ERROR : failed to connect to every SSID"
            exit $conn_result
        fi
    else
        echo "connect to SSID : $ssid"
        
        if [ $nega -eq 0 ] ;then
            bash $U_PATH_TBIN/wifi_connect_DUT.sh -f $G_CURRENTLOG/wifi_config_file_$ssid_index -i $U_WIRELESSINTERFACE -t 10
        else
            bash $U_PATH_TBIN/wifi_connect_DUT.sh -f $G_CURRENTLOG/wifi_config_file_$ssid_index -i $U_WIRELESSINTERFACE -t 10 -n
        fi
        
        conn_result=$?
        
        if [ $conn_result -eq 0 ] ;then
            echo "connect to every $ssid passed"
        else
            echo "AT_ERROR : failed to connect to $ssid"
            exit $conn_result
        fi
    fi
    
    }
    
do_each_scan

do_each_generate_config

do_each_connect
