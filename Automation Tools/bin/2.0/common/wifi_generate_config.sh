#!/bin/bash
# Author        :   Howard Yin(hying@actiontec.com)
# Description   :
#   This tool is using to generate a wifi connect config file with given connection type
#   It is using all default value of DUT's wireless variables
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#13 Dec 2011    |   1.0.0   | howard    | Inital Version


REV="$0 version 1.0.0 (13 Dec 2011)"
# print REV

echo "${REV}"

USAGE(){
    cat <<usge
    
    USAGE : bash $0 [-i 1/2/3/4] -t <WEP | WPA | WPA2 | OFF> -s <your wlan ssid name> -f <config file to output> [-q <channel frequency>]

    OPTIONS:
          -i
                :   SSID index <numeric , like 1 2 3 or 4>
          -t
                :   a_b_c_d_e

                    #field a can be WEP , WPA , WPA8021X , WPA28021X , WEP8021X or WPA2
                    #field b can be OPEN or SHARED when field a is WEP , AES or TKIP when filed a is WPA or WPA2
                    #        field b can be omitted when you want to config client to OPEN (WEP) or TKIP (WPA/WPA2)
                    #field c can be CUS or DEF , means custom key or default key
                    #field d can be 1 , 2 , 3 or 4 if filed a is WEP , can be AES , TKIP or AESTKIP when field a is WPA or WPA2
                    #field e is only necessary when field a is WEP , it can be 128 or 64 depends on the bit length of key phrase
          -s
                :   ssid name
          -f
                :   config file name
          -q
                :   channel

usge

}

while [ -n "$1" ]; do
    case $1 in
        -i)
            ssid_index=$2
            echo "creating connection config file of SSID : ${ssid_index}"
            shift 2
            ;;
        -t)
            conn_type=$2
            echo "creating connection config file of type : ${conn_type}"
            shift 2
            ;;
        -s)
            ssid_name=$2
            echo "the ssid to be connected to is : ${ssid_name}"
            shift 2
            ;;
        -f)
            config_file=$2
            echo "the config file to be created is : ${config_file}"
            shift 2
            ;;
        -q)
            channel=$2
            echo "the channel is : ${channel}"
            shift 2
            ;;
        -test)
            echo "test mode"
            U_WIRELESS_SSID1=CenturyLink0037
            U_WIRELESS_SSID2=CenturyLink0038
            U_WIRELESS_SSID3=CenturyLink0039
            U_WIRELESS_SSID4=CenturyLink003A

            ###############################################
            # all default key is not used in FiberTech
            #
            ###############################################
            # default 64-bit wep key  of DUT
            U_WIRELESS_WEPKEY_DEF_64=FFC8FFFFC9
            # default 128-bit wep key  of DUT
            U_WIRELESS_WEPKEY1=ffc5ab2bff82ece8ce7a8e7ede
            U_WIRELESS_WEPKEY2=ffc5ab29ff82ece7ce7a8e7eec
            U_WIRELESS_WEPKEY3=ffc5ab27ff82ece6ce7a8d7ee2
            U_WIRELESS_WEPKEY4=ffc5ab25ff82ece5ce7a8d7ee4

            # default WPA/PSK of DUT
            U_WIRELESS_WPAPSK1=bfc14bab8539cbb9f460351ae8
            U_WIRELESS_WPAPSK2=bfc14bab8539cbb9f460351ae8
            U_WIRELESS_WPAPSK3=bfc14bab8539cbb9f460351ae8
            U_WIRELESS_WPAPSK4=bfc14bab8539cbb9f460351ae8

            U_WIRELESS_CONFIG_FILE1=wirelesssec_ssid1.conf
            U_WIRELESS_CONFIG_FILE2=wirelesssec_ssid2.conf
            U_WIRELESS_CONFIG_FILE3=wirelesssec_ssid3.conf
            U_WIRELESS_CONFIG_FILE4=wirelesssec_ssid4.conf

            # wireless channel
            U_WIRELESS_CHANNEL1=2412
            U_WIRELESS_CHANNEL2=2417
            U_WIRELESS_CHANNEL3=2422
            U_WIRELESS_CHANNEL4=2427
            U_WIRELESS_CHANNEL5=2432
            U_WIRELESS_CHANNEL6=2437
            U_WIRELESS_CHANNEL7=2442
            U_WIRELESS_CHANNEL8=2447
            U_WIRELESS_CHANNEL9=2452
            U_WIRELESS_CHANNEL10=2457
            U_WIRELESS_CHANNEL11=2462
            U_WIRELESS_KEY_MGMT_WEP=NONE
            U_WIRELESS_KEY_MGMT_WPA=WPA-PSK
            U_WIRELESS_KEY_MGMT_WPA_8021X=WPA-EAP
            U_WIRELESS_KEY_MGMT_WEP_8021X=IEEE8021X

            #wireless wep authentication type
            U_WIRELESS_AUTH_OPEN=OPEN
            U_WIRELESS_AUTH_SHARED=SHARED

            #wireless WPA protocal type
            U_WIRELESS_PROTO_WPA=WPA
            U_WIRELESS_PROTO_WPA2=RSN
            U_WIRELESS_PROTO_WPAWPA2=WPA+RSN

            #pairwise ciphers for WPA
            U_WIRELESS_PAIRWISE_TKIP=TKIP
            U_WIRELESS_PAIRWISE_AES=CCMP
            U_WIRELESS_PAIRWISE_TKIPAES=TKIP+CCMP
            U_WIRELESS_PROTO_ANYWPA=ANYWPA
            
            U_WIRELESS_CUSTOM_WPAPSK=caonima
            

            #group ciphers for WPA
            U_WIRELESS_GROUP_TKIP=TKIP
            U_WIRELESS_GROUP_AES=CCMP
            U_WIRELESS_GROUP_TKIPAES=TKIP+CCMP
            U_PATH_TBIN=.
            U_WIRELESS_CONNECTION_TYPE=WPA_TKIP_DEF_TKIP
            shift 1
            ;;
        -h)
            USAGE
            exit 1
            ;;
        *)
            USAGE
            exit 1
            ;;
    esac
done

if [ -z $U_WIRELESS_PROTO_ANYWPA ] ;then
    U_WIRELESS_PROTO_ANYWPA=ANYWPA
fi

if [ -z "$conn_type" ] ;then
    conn_type=$U_WIRELESS_CONNECTION_TYPE
    echo "connection type not in arguments , using $U_WIRELESS_CONNECTION_TYPE as connection type ."
fi

if [ -z "$ssid_index" ] ;then
    ssid_index=1
fi

# handel the default keys
if [ $ssid_index -eq 1 ] ;then
    WEPKEY_SEL=$U_WIRELESS_WEPKEY1
    WPAPSK_SEL=$U_WIRELESS_WPAPSK1
elif [ $ssid_index -eq 2 ] ;then
    WEPKEY_SEL=$U_WIRELESS_WEPKEY2
    WPAPSK_SEL=$U_WIRELESS_WPAPSK2
elif [ $ssid_index -eq 3 ] ;then
    WEPKEY_SEL=$U_WIRELESS_WEPKEY3
    WPAPSK_SEL=$U_WIRELESS_WPAPSK3
elif [ $ssid_index -eq 4 ] ;then
    WEPKEY_SEL=$U_WIRELESS_WEPKEY4
    WPAPSK_SEL=$U_WIRELESS_WPAPSK4
fi


WEP(){
    echo "security type : WEP"

    # OFF | WEP_OPEN_CUS_1_128 | WEP_SHARED_CUS_2 | WPA_TKIP_DEF_TKIP | WPA_AES_CUS_TKIPAES | WPA2_TKIP_DEF_TKIP | WPA2_AES_CUS_AES
    echo $conn_type|grep "_"
    if [ $? -ne 0 ] ;then
        echo "ERROR : security type error"
        exit 1
    fi

    enc=`echo $conn_type |cut -d_ -f 2`
    key_type=`echo $conn_type |cut -d_ -f 3`
    wep_key_index=`echo $conn_type |cut -d_ -f 4`
    wep_key_bit=`echo $conn_type |cut -d_ -f 5`

    if [ "$key_type" == "" -o "$key_type" == "DEF" ] ;then
        echo "using default key ..."
        if [ "$enc" == "" -o "$enc" == "OPEN" ] ;then
            echo "auth mode OPEN ..."
            if [ -n "$channel" ] ;then
                echo "channel : $channel ..."
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $WEPKEY_SEL -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
            else
                echo "channel : auto"
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $WEPKEY_SEL -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file
            fi
        elif [ "$enc" == "SHARED" ] ;then
            echo "auth mode SHARED ..."
            if [ -n "$channel" ] ;then
                echo "channel : $channel"
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $WEPKEY_SEL -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
            else
                echo "channel : auto"
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $WEPKEY_SEL -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file
            fi
        fi
    elif [ "$key_type" == "CUS" ] ;then
        echo "using custom key ..."
        if [ "$enc" == "" -o "$enc" == "OPEN" ] ;then
            echo "auth mode OPEN ..."
            if [ "$wep_key_index" == "1" ] ;then
                echo "key index 1"
                if [ -n "$channel" ] ;then
                    echo "channel : $channel"
                    #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                    if [ "$wep_key_bit" == "128" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                    elif [ "$wep_key_bit" == "64" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                    fi
                else
                    echo "channel : auto"
                    if [ "$wep_key_bit" == "128" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                    elif [ "$wep_key_bit" == "64" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                    fi
                fi
            elif [ "$wep_key_index" == "2" ] ;then
                echo "key index 2"
                if [ -n "$channel" ] ;then
                    echo "channel : $channel"
                    #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                    if [ "$wep_key_bit" == "128" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -i 1 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                    elif [ "$wep_key_bit" == "64" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -i 1 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                    fi
                else
                    echo "channel : auto"
                    if [ "$wep_key_bit" == "128" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -i 1 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                    elif [ "$wep_key_bit" == "64" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -i 1 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                    fi
                fi
            elif [ "$wep_key_index" == "3" ] ;then
                echo "key index 3"
                if [ -n "$channel" ] ;then
                    echo "channel : $channel"
                    #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                    if [ "$wep_key_bit" == "128" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -i 2 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                    elif [ "$wep_key_bit" == "64" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -i 2 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                    fi
                else
                    echo "channel : auto"
                    if [ "$wep_key_bit" == "128" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -i 2 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                    elif [ "$wep_key_bit" == "64" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -i 2 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                    fi
                fi
            elif [ "$wep_key_index" == "4" ] ;then
                echo "key index 4"
                if [ -n "$channel" ] ;then
                    echo "channel : $channel"
                    #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                    if [ "$wep_key_bit" == "128" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -i 3 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                    elif [ "$wep_key_bit" == "64" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -i 3 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                    fi
                else
                    echo "channel : auto"
                    if [ "$wep_key_bit" == "128" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -i 3 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                    elif [ "$wep_key_bit" == "64" ] ;then
                        echo "wep key bit : $wep_key_bit"
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -i 3 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                    fi
                fi
            else
                echo "ERROR : wep key index error , only support 1 2 3 and 4 , not support $wep_key_index"
                exit 1
            fi


        elif [ "$enc" == "SHARED" ] ;then
            echo "auth mode SHARED ..."
            if [ "$wep_key_index" == "1" ] ;then
                echo "key index 1"
                if [ -n "$channel" ] ;then
                    #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                    if [ "$wep_key_bit" == "128" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                    elif [ "$wep_key_bit" == "64" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                    fi
                else
                    if [ "$wep_key_bit" == "128" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                    elif [ "$wep_key_bit" == "64" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                    fi
                fi
            elif [ "$wep_key_index" == "2" ] ;then
                echo "key index 2"
                if [ -n "$channel" ] ;then
                    #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                    if [ "$wep_key_bit" == "128" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -i 1 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                    elif [ "$wep_key_bit" == "64" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -i 1 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                    fi
                else
                    if [ "$wep_key_bit" == "128" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -i 1 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                    elif [ "$wep_key_bit" == "64" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -i 1 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                    fi
                fi
            elif [ "$wep_key_index" == "3" ] ;then
                echo "key index 3"
                if [ -n "$channel" ] ;then
                    #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                    if [ "$wep_key_bit" == "128" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -i 2 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                    elif [ "$wep_key_bit" == "64" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -i 2 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                    fi
                else
                    if [ "$wep_key_bit" == "128" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -i 2 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                    elif [ "$wep_key_bit" == "64" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -i 2 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                    fi
                fi
            elif [ "$wep_key_index" == "4" ] ;then
                echo "key index 4"
                if [ -n "$channel" ] ;then
                    #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                    if [ "$wep_key_bit" == "128" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -i 3 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                    elif [ "$wep_key_bit" == "64" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -i 3 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                    fi
                else
                    if [ "$wep_key_bit" == "128" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -i 3 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                    elif [ "$wep_key_bit" == "64" ] ;then
                        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP -k $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -i 3 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                    fi
                fi
            else
                echo "ERROR : wep key index error , only support 1 2 3 and 4 , not support $wep_key_index"
                exit 1
            fi
        fi
    fi
}

WPA(){
    echo "security type : WPA"
    # OFF | WEP_OPEN_CUS_1_128 | WEP_SHARED_CUS_2 | WPA_TKIP_DEF_TKIP | WPA_AES_CUS_TKIPAES | WPA2_TKIP_DEF_TKIP | WPA2_AES_CUS_AES
    echo $conn_type|grep "_"
    if [ $? -ne 0 ] ;then
        echo "ERROR : security type error"
        exit 1
    fi

    enc=`echo $conn_type |cut -d_ -f 2`
    key_type=`echo $conn_type |cut -d_ -f 3`
    #wpa_group=`echo $conn_type |cut -d_ -f 4`

    if [ "$key_type" == "" -o "$key_type" == "DEF" ] ;then
        echo "key type : DEFAULT key"
        if [  "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP -p $WPAPSK_SEL -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            echo "encription mode : AES"

            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES -p $WPAPSK_SEL -f $config_file
            fi
        elif [ "$enc" == "BOTH" ] ;then
            echo "encription mode : BOTH"

            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES -p $WPAPSK_SEL -f $config_file
            fi
        fi

    elif [ "$key_type" == "CUS" ] ;then
        echo "key type : CUSTOM key"
        if [  "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            echo "encription mode : AES"

            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi
        elif [ "$enc" == "BOTH" ] ;then
            echo "encription mode : BOTH"

            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi

        fi
    else
        echo "ERROR : key type not correct ."
        exit 1
    fi


}

WPA2(){
    echo "security type : WPA2"
    # OFF | WEP_OPEN_CUS_1_128 | WEP_SHARED_CUS_2 | WPA_TKIP_DEF_TKIP | WPA_AES_CUS_TKIPAES | WPA2_TKIP_DEF_TKIP | WPA2_AES_CUS_AES
    echo $conn_type|grep "_"
    if [ $? -ne 0 ] ;then
        echo "ERROR : security type error"
        exit 1
    fi

    enc=`echo $conn_type |cut -d_ -f 2`
    key_type=`echo $conn_type |cut -d_ -f 3`
    #wpa_group=`echo $conn_type |cut -d_ -f 4`

    if [  "$key_type" == "DEF" ] ;then
        echo "key type : DEFAULT key"
        if [  "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP -p $WPAPSK_SEL -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            echo "encription mode : AES"

            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES -p $WPAPSK_SEL -f $config_file
            fi
        elif [ "$enc" == "BOTH" ] ;then
            echo "encription mode : BOTH"

            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES -p $WPAPSK_SEL -f $config_file
            fi

        fi

    elif [ "$key_type" == "CUS" ] ;then
        echo "key type : CUSTOM key"
        if [  "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi
        elif [ "$enc" == "BOTH" ] ;then
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi

        fi
    else
		echo "AT_ERROR : error key type !"
		exit 1
    fi


}

ANYWPA(){
    echo "security type : ANYWPA"
    # OFF | WEP_OPEN_CUS_1_128 | WEP_SHARED_CUS_2 | WPA_TKIP_DEF_TKIP | WPA_AES_CUS_TKIPAES | WPA2_TKIP_DEF_TKIP | WPA2_AES_CUS_AES
    echo $conn_type|grep "_"
    if [ $? -ne 0 ] ;then
        echo "ERROR : security type error"
        exit 1
    fi

    enc=`echo $conn_type |cut -d_ -f 2`
    key_type=`echo $conn_type |cut -d_ -f 3`
    #wpa_group=`echo $conn_type |cut -d_ -f 4`

    if [  "$key_type" == "DEF" ] ;then
        echo "key type : DEFAULT key"
        if [  "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP  -p $WPAPSK_SEL -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            echo "encription mode : AES"

            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES  -p $WPAPSK_SEL -f $config_file
            fi

        elif [ "$enc" == "BOTH" ] ;then
            echo "encription mode : BOTH"
            #if [ "$wpa_group" == "AES" ] ;then
                #echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $WPAPSK_SEL -f $config_file
            fi

        fi

    elif [ "$key_type" == "CUS" ] ;then
        echo "key type : CUSTOM key"
        if [ "$enc" == "" -o "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP -g $U_WIRELESS_GROUP_TKIP -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIP -g $U_WIRELESS_GROUP_TKIP -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            #if [ "$wpa_group" == "AES" ] ;then
                #echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_AES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi

        elif [ "$enc" == "BOTH" ] ;then
            #if [ "$wpa_group" == "AES" ] ;then
             #   echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi

        fi
    else
		echo "AT_ERROR : error key type !"
		exit 1
    fi


}

OFF(){
    echo "security type : NONE"

    if [ -n "$channel" ] ;then
        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m NONE -f $config_file -q $channel
    else
        bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m NONE -f $config_file
    fi
}

#################################################################################################################################
#############################           8021X           #########################################################################
#################################################################################################################################

WEP8021X(){
    echo "security type : WEP8021X"

    # OFF | WEP_OPEN_CUS_1_128 | WEP_SHARED_CUS_2 | WPA_TKIP_DEF_TKIP | WPA_AES_CUS_TKIPAES | WPA2_TKIP_DEF_TKIP | WPA2_AES_CUS_AES
    echo $conn_type|grep "_"
    if [ $? -ne 0 ] ;then
        enc=""
		key_type=""
		wep_key_index=""
		wep_key_bit=""
	else
		enc=`echo $conn_type |cut -d_ -f 2`
		key_type=`echo $conn_type |cut -d_ -f 3`
		wep_key_index=`echo $conn_type |cut -d_ -f 4`
		wep_key_bit=`echo $conn_type |cut -d_ -f 5`
    fi

    
    
    if [ "" == "$key_type" ] ;then
        if [ "$enc" == "OPEN" ] ;then
            echo "auth mode OPEN ..."
            if [ -n "$channel" ] ;then
                echo "channel : $channel ..."
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X  -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
            else
                echo "channel : auto"
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X  -a $U_WIRELESS_AUTH_OPEN -f $config_file
            fi
        elif [ "$enc" == "SHARED" ] ;then
            echo "auth mode SHARED ..."
            if [ -n "$channel" ] ;then
                echo "channel : $channel"
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X  -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
            else
                echo "channel : auto"
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X  -a $U_WIRELESS_AUTH_SHARED -f $config_file
            fi
        elif [ "$enc" == "" ] ;then
            echo "auth mode NONE ..."
            if [ -n "$channel" ] ;then
                echo "channel : $channel"
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X   -f $config_file -q $channel
            else
                echo "channel : auto"
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X   -f $config_file
            fi
        fi
    else
        #echo ""
        if [ "$key_type" == "DEF" ] ;then
            echo "using default key ..."
            if [ "$enc" == "" -o "$enc" == "OPEN" ] ;then
                echo "auth mode OPEN ..."
                if [ -n "$channel" ] ;then
                    echo "channel : $channel ..."
                    bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $WEPKEY_SEL -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                else
                    echo "channel : auto"
                    bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $WEPKEY_SEL -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                fi
            elif [ "$enc" == "SHARED" ] ;then
                echo "auth mode SHARED ..."
                if [ -n "$channel" ] ;then
                    echo "channel : $channel"
                    bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $WEPKEY_SEL -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                else
                    echo "channel : auto"
                    bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $WEPKEY_SEL -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                fi
            fi
        elif [ "$key_type" == "CUS" ] ;then
            echo "using custom key ..."
            if [ "$enc" == "" -o "$enc" == "OPEN" ] ;then
                echo "auth mode OPEN ..."
                if [ "$wep_key_index" == "1" ] ;then
                    echo "key index 1"
                    if [ -n "$channel" ] ;then
                        echo "channel : $channel"
                        #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                        if [ "$wep_key_bit" == "128" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                        elif [ "$wep_key_bit" == "64" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                        fi
                    else
                        echo "channel : auto"
                        if [ "$wep_key_bit" == "128" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                        elif [ "$wep_key_bit" == "64" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -i 0 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                        fi
                    fi
                elif [ "$wep_key_index" == "2" ] ;then
                    echo "key index 2"
                    if [ -n "$channel" ] ;then
                        echo "channel : $channel"
                        #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                        if [ "$wep_key_bit" == "128" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -i 1 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                        elif [ "$wep_key_bit" == "64" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -i 1 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                        fi
                    else
                        echo "channel : auto"
                        if [ "$wep_key_bit" == "128" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -i 1 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                        elif [ "$wep_key_bit" == "64" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -i 1 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                        fi
                    fi
                elif [ "$wep_key_index" == "3" ] ;then
                    echo "key index 3"
                    if [ -n "$channel" ] ;then
                        echo "channel : $channel"
                        #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                        if [ "$wep_key_bit" == "128" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -i 2 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                        elif [ "$wep_key_bit" == "64" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -i 2 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                        fi
                    else
                        echo "channel : auto"
                        if [ "$wep_key_bit" == "128" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -i 2 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                        elif [ "$wep_key_bit" == "64" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -i 2 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                        fi
                    fi
                elif [ "$wep_key_index" == "4" ] ;then
                    echo "key index 4"
                    if [ -n "$channel" ] ;then
                        echo "channel : $channel"
                        #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                        if [ "$wep_key_bit" == "128" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -i 3 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                        elif [ "$wep_key_bit" == "64" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -i 3 -a $U_WIRELESS_AUTH_OPEN -f $config_file -q $channel
                        fi
                    else
                        echo "channel : auto"
                        if [ "$wep_key_bit" == "128" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -i 3 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                        elif [ "$wep_key_bit" == "64" ] ;then
                            echo "wep key bit : $wep_key_bit"
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -i 3 -a $U_WIRELESS_AUTH_OPEN -f $config_file
                        fi
                    fi
                else
                    echo "ERROR : wep key index error , only support 1 2 3 and 4 , not support $wep_key_index"
                    exit 1
                fi


            elif [ "$enc" == "SHARED" ] ;then
                echo "auth mode SHARED ..."
                if [ "$wep_key_index" == "1" ] ;then
                    echo "key index 1"
                    if [ -n "$channel" ] ;then
                        #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                        if [ "$wep_key_bit" == "128" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                        elif [ "$wep_key_bit" == "64" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                        fi
                    else
                        if [ "$wep_key_bit" == "128" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit1 -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                        elif [ "$wep_key_bit" == "64" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit1 -i 0 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                        fi
                    fi
                elif [ "$wep_key_index" == "2" ] ;then
                    echo "key index 2"
                    if [ -n "$channel" ] ;then
                        #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                        if [ "$wep_key_bit" == "128" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -i 1 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                        elif [ "$wep_key_bit" == "64" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -i 1 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                        fi
                    else
                        if [ "$wep_key_bit" == "128" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit2 -i 1 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                        elif [ "$wep_key_bit" == "64" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit2 -i 1 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                        fi
                    fi
                elif [ "$wep_key_index" == "3" ] ;then
                    echo "key index 3"
                    if [ -n "$channel" ] ;then
                        #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                        if [ "$wep_key_bit" == "128" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -i 2 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                        elif [ "$wep_key_bit" == "64" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -i 2 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                        fi
                    else
                        if [ "$wep_key_bit" == "128" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit3 -i 2 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                        elif [ "$wep_key_bit" == "64" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit3 -i 2 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                        fi
                    fi
                elif [ "$wep_key_index" == "4" ] ;then
                    echo "key index 4"
                    if [ -n "$channel" ] ;then
                        #   $U_WIRELESS_CUSTOM_WEP_KEY128bit1
                        if [ "$wep_key_bit" == "128" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -i 3 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                        elif [ "$wep_key_bit" == "64" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -i 3 -a $U_WIRELESS_AUTH_SHARED -f $config_file -q $channel
                        fi
                    else
                        if [ "$wep_key_bit" == "128" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY128bit4 -i 3 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                        elif [ "$wep_key_bit" == "64" ] ;then
                            bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -m $U_WIRELESS_KEY_MGMT_WEP_8021X -k $U_WIRELESS_CUSTOM_WEP_KEY64bit4 -i 3 -a $U_WIRELESS_AUTH_SHARED -f $config_file
                        fi
                    fi
                else
                    echo "ERROR : wep key index error , only support 1 2 3 and 4 , not support $wep_key_index"
                    exit 1
                fi
            fi
        fi
    fi

    
}

WPA8021X(){
    echo "security type : WPA8021X"
    # OFF | WEP_OPEN_CUS_1_128 | WEP_SHARED_CUS_2 | WPA_TKIP_DEF_TKIP | WPA_AES_CUS_TKIPAES | WPA2_TKIP_DEF_TKIP | WPA2_AES_CUS_AES
    echo $conn_type|grep "_"
    if [ $? -ne 0 ] ;then
        echo "ERROR : security type error"
        exit 1
    fi

    enc=`echo $conn_type |cut -d_ -f 2`
    key_type=`echo $conn_type |cut -d_ -f 3`
    #wpa_group=`echo $conn_type |cut -d_ -f 4`

    if [  "$key_type" == "DEF" ] ;then
        echo "key type : DEFAULT key"
        if [  "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP  -p $WPAPSK_SEL -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            echo "encription mode : AES"
            #if [ "$wpa_group" == "AES" ] ;then
                #echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $WPAPSK_SEL -f $config_file
            fi
        elif [ "$enc" == "BOTH" ] ;then
            echo "encription mode : BOTH"
            #if [ "$wpa_group" == "AES" ] ;then
                #echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $WPAPSK_SEL -f $config_file
            fi

        fi

    elif [ "$key_type" == "CUS" ] ;then
        echo "key type : CUSTOM key"
        if [ "$enc" == "" -o "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP -g $U_WIRELESS_GROUP_TKIP -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP -g $U_WIRELESS_GROUP_TKIP -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            echo "encription mode : AES"
            #if [ "$wpa_group" == "AES" ] ;then
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi
        elif [ "$enc" == "BOTH" ] ;then
            echo "encription mode : BOTH"
            #if [ "$wpa_group" == "AES" ] ;then
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi

        fi
    else
        echo "ERROR : key type not correct ."
        exit 1
    fi


}

WPA28021X(){
    echo "security type : WPA28021X"
    # OFF | WEP_OPEN_CUS_1_128 | WEP_SHARED_CUS_2 | WPA_TKIP_DEF_TKIP | WPA_AES_CUS_TKIPAES | WPA2_TKIP_DEF_TKIP | WPA2_AES_CUS_AES
    echo $conn_type|grep "_"
    if [ $? -ne 0 ] ;then
        echo "ERROR : security type error"
        exit 1
    fi

    enc=`echo $conn_type |cut -d_ -f 2`
    key_type=`echo $conn_type |cut -d_ -f 3`
    #wpa_group=`echo $conn_type |cut -d_ -f 4`

    if [  "$key_type" == "DEF" ] ;then
        echo "key type : DEFAULT key"
        if [  "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP  -p $WPAPSK_SEL -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            echo "encription mode : AES"
            #if [ "$wpa_group" == "AES" ] ;then
                #echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $WPAPSK_SEL -f $config_file
            fi
        elif [ "$enc" == "BOTH" ] ;then
            echo "encription mode : BOTH"
            #if [ "$wpa_group" == "AES" ] ;then
                #echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $WPAPSK_SEL -f $config_file
            fi

        fi

    elif [ "$key_type" == "CUS" ] ;then
        echo "key type : CUSTOM key"
        if [  "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            #if [ "$wpa_group" == "AES" ] ;then
            #    echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi
        elif [ "$enc" == "BOTH" ] ;then
            #if [ "$wpa_group" == "AES" ] ;then
            #    echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_WPA2 -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi

        fi
    else
		echo "AT_ERROR : error key type !"
		exit 1
    fi


}

ANYWPA8021X(){
    echo "security type : ANYWPA8021X"
    # OFF | WEP_OPEN_CUS_1_128 | WEP_SHARED_CUS_2 | WPA_TKIP_DEF_TKIP | WPA_AES_CUS_TKIPAES | WPA2_TKIP_DEF_TKIP | WPA2_AES_CUS_AES
    echo $conn_type|grep "_"
    if [ $? -ne 0 ] ;then
        echo "ERROR : security type error"
        exit 1
    fi

    enc=`echo $conn_type |cut -d_ -f 2`
    key_type=`echo $conn_type |cut -d_ -f 3`
    #wpa_group=`echo $conn_type |cut -d_ -f 4`

    if [ "$key_type" == "" -o "$key_type" == "DEF" ] ;then
        echo "key type : DEFAULT key"
        if [ "$enc" == "" -o "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP  -p $WPAPSK_SEL -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            echo "encription mode : AES"
            #if [ "$wpa_group" == "AES" ] ;then
                #echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $WPAPSK_SEL -f $config_file
            fi


        elif [ "$enc" == "BOTH" ] ;then
            echo "encription mode : BOTH"
            #if [ "$wpa_group" == "AES" ] ;then
                #echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $WPAPSK_SEL -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $WPAPSK_SEL -f $config_file
            fi


        fi

    elif [ "$key_type" == "CUS" ] ;then
        echo "key type : CUSTOM key"
        if [ "$enc" == "" -o "$enc" == "TKIP" ] ;then
            echo "encription mode : TKIP"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIP  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi
        elif [ "$enc" == "AES" ] ;then
            #if [ "$wpa_group" == "AES" ] ;then
                #echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_AES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi

        elif [ "$enc" == "BOTH" ] ;then
            #if [ "$wpa_group" == "AES" ] ;then
                #echo "group : AES"
            if [ -n "$channel" ] ;then
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file -q $channel
            else
                bash $U_PATH_TBIN/wifi_wpa_config.sh -s "$ssid_name" -t $U_WIRELESS_PROTO_ANYWPA -m $U_WIRELESS_KEY_MGMT_WPA_8021X -w $U_WIRELESS_PAIRWISE_TKIPAES  -p $U_WIRELESS_CUSTOM_WPAPSK -f $config_file
            fi

        fi
    else
		echo "AT_ERROR : error key type !"
		exit 1
    fi


}

method=`echo $conn_type |cut -d_ -f 1`

$method

rc=$?

exit $rc
