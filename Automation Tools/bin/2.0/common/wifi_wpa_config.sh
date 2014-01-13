#!/bin/bash
# Author        :   Howard Yin(hying@actiontec.com)
# Description   :
#   This tool is using to create a wpa_cupplicant config file
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version
#18 Nov 2011    |   1.0.1   | howard    | added "scan_ssid=1"
#

REV="$0 version 1.0.1 (31 Oct 2011)"
# print REV

echo "${REV}"

help()
{
    cat <<HELP
./wifi_wpa_config.sh -s ssid -t proto -m key_mgmt
wifi_wpa_config.sh -- create the wireless config file

USAGE:    ./wifi_wpa_config.sh [-s ssid] [-t proto] [-m key_mgmt] [-w pairwise] [-g group] [-p psk] [-i index] [-k wep_key] [-a auth_alg] [-ca_cert ca_cert] [-cl_cert client_cert] [-cl_key client_key] [-f filename]

OPTIONS:
      -s, ssid name
      -t, protocal type: WPA or RSN
      -m, NONE, WPA-PSK or WPA_EAP
      -w, CCMP, TKIP, NONE
      -g, CCMP, TKIP, WEP104, WEP40
      -p, WPA preshared key
      -i, WEP key index
      -k, WEP key
      -a, OPEN, SHARED
      -f, config file name
      -q, frequency
      -ca_cert, ca_cert
      -cl_cert, client_cert
      -cl_key, client_key

EXAMPLES: bash wifi_wpa_config.sh -s ssid -m NONE -k wep_key -i key_index -a auth_alg -f wirelesssec.conf //WEP security type
          bash wifi_wpa_config.sh -s SSID -t WPA+RSN -m WPA-PSK -w TKIP+CCMP -g TKIP+CCMP -p 12345678901234567890 -f wirelesssec.conf //WPA&WPA2 security type, TKIP and AES encryption type
          bash wifi_wpa_config.sh -s SSID -t WPA -m WPA-PSK -w TKIP -g TKIP -p 12345678901234567890 -f wirelesssec.conf //WPA security type, TKIP encryption type
          bash wifi_wpa_config.sh -s ssid -m NONE -f wirelesssec.conf //Security off
          bash wifi_wpa_config.sh -s 11111 -t WPA -m WPA-EAP -w TKIP -g TKIP -ca_cert ~/automation/certs/ca.pem -cl_cert ~/automation/certs/client.pem -cl_key ~/automation/certs/client.key -f /tmp/aaaaa // WPA 802.1x
          bash wifi_wpa_config.sh -s 1111 -m IEEE8021X -ca_cert ~/automation/certs/ca.pem -cl_cert ~/automation/certs/client.pem -cl_key ~/automation/certs/client.key -f /tmp/aaaaa // IEEE 802.1x
HELP
    exit 1
}

while [ -n "$1" ]; do
    case $1 in
        -h)         help;shift 1;;
        -s)         ssid=$2;shift 2;;
        -t)         proto=$2;shift 2;;
        -m)         key_mgmt=$2;shift 2;;
        -w)         pairwise=$2;shift 2;;
        -g)         group=$2;shift 2;;
        -p)         psk=$2;shift 2;;
        -i)         index=$2;shift 2;;
        -k)         wep_key=$2;shift 2;;
        -a)         auth_alg=$2;shift 2;;
        -f)         file=$2;shift 2;;
        -c)         change=1;shift 1;;
        -q)         freq=$2;shift 2;;
        -ca_cert)   ca_cert=$2;shift 2;;
        -cl_cert)   cl_cert=$2;shift 2;;
        -cl_key)    cl_key=$2;shift 2;;
        *) break;;
    esac
done

if [ -z $ca_cert ] ;then
    ca_cert="$SQAROOT/certs/ca.pem"
fi

if [ -z $cl_cert ] ;then
    cl_cert="$SQAROOT/certs/client.pem"
fi

if [ -z $cl_key ] ;then
    cl_key="$SQAROOT/certs/client.key"
fi

if [ -z $identity ] ;then
    identity="autotest@actiontec.com"
fi

if [ -z $private_key_passwd ] ;then
    if [ -z $U_WIRELESS_RADIUS_PRIVATE_PSK ] ;then
        private_key_passwd="123qaz"
    else
        private_key_passwd=$U_WIRELESS_RADIUS_PRIVATE_PSK
    fi
fi

if [ -n "$file" ]; then

    if [ "$ssid" == "$U_WIRELESS_SSID1" ] ;then
        curr_bssid=$U_WIRELESS_BSSID1
    elif [ "$ssid" == "$U_WIRELESS_SSID2" ] ;then
        curr_bssid=$U_WIRELESS_BSSID2
    elif [ "$ssid" == "$U_WIRELESS_SSID3" ] ;then
        curr_bssid=$U_WIRELESS_BSSID3
    elif [ "$ssid" == "$U_WIRELESS_SSID4" ] ;then
        curr_bssid=$U_WIRELESS_BSSID4
    fi

    #   U_CUSTOM_SPECIFIED_SSID = SSID1

    if [ "x" == "x${curr_bssid}" ] ;then

        if [ "$ssid" == "$U_CUSTOM_WIRELESS_SSID1" ] ;then
            curr_bssid=$U_WIRELESS_BSSID1
        elif [ "$ssid" == "$U_CUSTOM_WIRELESS_SSID2" ] ;then
            curr_bssid=$U_WIRELESS_BSSID2
        elif [ "$ssid" == "$U_CUSTOM_WIRELESS_SSID3" ] ;then
            curr_bssid=$U_WIRELESS_BSSID3
        elif [ "$ssid" == "$U_CUSTOM_WIRELESS_SSID4" ] ;then
            curr_bssid=$U_WIRELESS_BSSID4
        fi

        #if [ "${U_CUSTOM_SPECIFIED_SSID}" == "SSID1" ] ;then
        #    curr_bssid=$U_WIRELESS_BSSID1
        #elif [ "${U_CUSTOM_SPECIFIED_SSID}" == "SSID2" ] ;then
        #    curr_bssid=$U_WIRELESS_BSSID2
        #elif [ "${U_CUSTOM_SPECIFIED_SSID}" == "SSID3" ] ;then
        #    curr_bssid=$U_WIRELESS_BSSID3
        #elif [ "${U_CUSTOM_SPECIFIED_SSID}" == "SSID4" ] ;then
        #    curr_bssid=$U_WIRELESS_BSSID4
        #fi
    fi

    echo "ctrl_interface=/var/run/wpa_supplicant" |tee $file
    echo "eapol_version=1" |tee -a $file
    echo "ap_scan=1" |tee -a $file
    echo "fast_reauth=1" |tee -a $file
    echo "network={" |tee -a $file
    echo "    ssid=\"$ssid\"" |tee -a $file

    if [ "$curr_bssid" != "" ] ;then
        echo "    bssid=$curr_bssid" |tr [A-Z] [a-z]|tee -a $file
    fi

    echo "    scan_ssid=1" |tee -a $file
    echo "    key_mgmt=$key_mgmt" |tee -a $file
    echo "    priority=5" |tee -a $file

    if [ -n "$freq" ];then
        echo "  #  frequency=$freq" |tee -a $file
    fi

    if [ "$key_mgmt" = "NONE" ]; then
        if [ -n "$wep_key" ]; then
            echo "    wep_key$index=$wep_key" |tee -a $file
            echo "    wep_tx_keyidx=$index" |tee -a $file
            echo "    auth_alg=$auth_alg" |tee -a $file
        else
            if [ -n "$auth_alg" ] ;then
                echo "    auth_alg=$auth_alg" |tee -a $file
            fi
        fi
    fi

    if [ "$key_mgmt" = "WPA-PSK" ]; then
        if [ "$proto" == "ANYWPA" ] ;then
            echo "    proto=WPA+RSN" |tee -a $file

            if [ "$pairwise" == "BOTH" -o "$pairwise" == "TKIP+CCMP" ] ;then
                #echo " both"
                echo "    pairwise=TKIP+CCMP" |tee -a $file
            else
                #echo " $pairwise"
                echo "    pairwise=$pairwise" |tee -a $file
            fi
        else
            if [ "$pairwise" == "BOTH" -o "$pairwise" == "TKIP+CCMP" ] ;then
                #echo " both"
                echo "    pairwise=TKIP+CCMP" |tee -a $file
            else
                #echo " $pairwise"
                echo "    pairwise=$pairwise" |tee -a $file
            fi
            echo "    proto=$proto" |tee -a $file
            #echo "    pairwise=$pairwise" |tee -a $file
        fi

        #echo "    group=$group" >> $file


        len_psk=`echo $psk | wc -L`

        if [ $len_psk -ge 64 ] ;then
            echo "    psk=$psk" |tee -a $file
        elif [ $len_psk -lt 64 ] ;then
            echo "    psk=\"$psk\"" |tee -a $file
        fi
    fi

    if [ "$key_mgmt" = "WPA-EAP" ]; then
        echo "    eap=TLS" |tee -a $file

        if [ "$proto" == "ANYWPA" ] ;then
            echo "    proto=WPA+RSN" |tee -a $file

            if [ "$pairwise" == "BOTH" -o "$pairwise" == "TKIP+CCMP" ] ;then
                #echo " both"
                echo "    pairwise=TKIP+CCMP" |tee -a $file
            else
                #echo " $pairwise"
                echo "    pairwise=$pairwise" |tee -a $file
            fi
        else
            if [ "$pairwise" == "BOTH" -o "$pairwise" == "TKIP+CCMP" ] ;then
                #echo " both"
                echo "    pairwise=TKIP+CCMP" |tee -a $file
            else
                #echo " $pairwise"
                echo "    pairwise=$pairwise" |tee -a $file
            fi

            echo "    proto=$proto" |tee -a $file
            #echo "    pairwise=$pairwise" |tee -a $file
        fi

        #echo "    group=$group" >> $file

        len_psk=`echo $psk | wc -L`

        if [ $len_psk -ge 64 ] ;then
            echo "    psk=$psk" |tee -a $file
        elif [ $len_psk -lt 64 ] ;then
            echo "    psk=\"$psk\"" |tee -a $file
        fi

        echo "    identity=\"$identity\"" |tee -a $file
        echo "    ca_cert=\"$ca_cert\"" |tee -a $file
        echo "    client_cert=\"$cl_cert\"" |tee -a $file
        echo "    private_key=\"$cl_key\"" |tee -a $file
        echo "    private_key_passwd=\"$private_key_passwd\"" |tee -a $file
    fi

    if [ "$key_mgmt" = "IEEE8021X" ]; then
        if [ -n "$wep_key" ]; then
            echo "    wep_key$index=$wep_key" |tee -a $file
            echo "    wep_tx_keyidx=$index" |tee -a $file
            echo "    auth_alg=$auth_alg" |tee -a $file
        else
            if [ -n "$auth_alg" ] ;then
                echo "    auth_alg=$auth_alg" |tee -a $file
            fi
        fi

        echo "    eap=TLS" |tee -a $file
        echo "    identity=\"$identity\"" |tee -a $file
        echo "    ca_cert=\"$ca_cert\"" |tee -a $file
        echo "    client_cert=\"$cl_cert\"" |tee -a $file
        echo "    private_key=\"$cl_key\"" |tee -a $file
        echo "    private_key_passwd=\"$private_key_passwd\"" |tee -a $file
    fi
    echo "}" |tee -a $file
    #fi
    #find ./ -name "$file" | xargs sed -i "s/+/\ /g"
    sed -i "s/+/\ /g" "$file"
fi

#cat $file
exit 0
