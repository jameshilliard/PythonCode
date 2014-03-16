#!/bin/bash
help()
{
    cat <<HELP
./writeconfig.sh -s ssid -t proto -m key_mgmt
writeconfig2.sh -- create the wireless config file

USAGE:    ./writeconfig2.sh [-s ssid] [-t proto] [-m key_mgmt] [-w pairwise] [-g group] [-p psk] [-i index] [-k wep_key] [-a auth_alg] [-ca_cert ca_cert] [-cl_cert client_cert] [-cl_key client_key] [-f filename]

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
      -c, change some parameter's value
      -b, 
      -q, frequency
      -ca_cert, ca_cert
      -cl_cert, client_cert
      -cl_key, client_key

EXAMPLES: bash writeconfig.sh -s ssid -m NONE -k wep_key -i key_index -a auth_alg -f wirelesssec.conf //WEP security type
          bash writeconfig.sh -s SSID -t WPA+RSN -m WPA-PSK -w TKIP+CCMP -g TKIP+CCMP -p 12345678901234567890 -f wirelesssec.conf //WPA&WPA2 security type, TKIP and AES encryption type
          bash writeconfig.sh -s SSID -t WPA -m WPA-PSK -w TKIP -g TKIP -p 12345678901234567890 -f wirelesssec.conf //WPA security type, TKIP encryption type
          bash writeconfig.sh -s ssid -m NONE -f wirelesssec.conf //Security off
          bash writeconfig.sh -c -q 2412 -f wirelesssec.conf //change channel
          bash writeconfig.sh -c -s ssid -f wirelesssec.conf //change ssid name 
          bash writeconfig.sh -s 11111 -t WPA -m WPA-EAP -w TKIP -g TKIP -ca_cert /usr/local/etc/raddb/certs/ca.pem -cl_cert /usr/local/etc/raddb/certs/client.pem -cl_key /usr/local/etc/raddb/certs/client.key -f aaaaa // WPA 802.1x
          bash writeconfig.sh -s 1111 -m IEEE8021X -ca_cert /usr/local/etc/raddb/certs/ca.pem -cl_cert /usr/local/etc/raddb/certs/client.pem -cl_key /usr/local/etc/raddb/certs/client.key -f aaaaa // IEEE 802.1x
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

if [ -n "$file" ]; then
    if [ "$change" = "1" ]; then
        if [ -n "$ssid" ];then
            find . -name "$file" | xargs sed -i "s/ssid=.*/ssid=\"$ssid\"/g" $file
        fi
        if [ -n "$psk" ];then
            find . -name "$file" | xargs sed -i "s/psk=.*/psk=\"$psk\"/g" $file
        fi
        if [ -n "$freq" ];then
            find . -name "$file" | xargs sed -i "s/\#frequency.*/frequency=$freq/g" $file
            find . -name "$file" | xargs sed -i "s/frequency.*/frequency=$freq/g" $file
        fi
    fi

    if [ "$change" != "1" ]; then
        echo "ctrl_interface=/var/run/wpa_supplicant" > $file 
        echo "eapol_version=1" >> $file
        echo "ap_scan=1" >> $file
        echo "fast_reauth=1" >> $file
        echo "network={" >> $file
        echo "    ssid=\"$ssid\"" >> $file
        echo "    scan_ssid=1" >> $file
        echo "    key_mgmt=$key_mgmt" >> $file
        echo "    priority=5" >> $file
        if [ -n "$freq" ];then
            echo "    frequency=$freq" >> $file
        fi
        if [ "$key_mgmt" = "NONE" ]; then
            if [ -n "$wep_key" ]; then
                echo "    wep_key$index=$wep_key" >> $file
                echo "    wep_tx_keyidx=$index" >> $file 
                echo "    auth_alg=$auth_alg" >> $file 
            fi
        fi
        if [ "$key_mgmt" = "WPA-PSK" ]; then
            echo "    proto=$proto" >> $file
            echo "    group=$group" >> $file
            echo "    pairwise=$pairwise" >> $file
            echo "    psk=\"$psk\"" >> $file
        fi
        if [ "$key_mgmt" = "WPA-EAP" ]; then
            echo "    eap=TLS" >> $file
            echo "    proto=$proto" >> $file
            echo "    group=$group" >> $file
            echo "    pairwise=$pairwise" >> $file
            echo "    identity=\"autotest@actiontec.com\"" >> $file
            echo "    ca_cert=\"$ca_cert\"" >> $file
            echo "    client_cert=\"$cl_cert\"" >> $file
            echo "    private_key=\"$cl_key\"" >> $file
            echo "    private_key_passwd=\"actiontec\"" >> $file
        fi
        if [ "$key_mgmt" = "IEEE8021X" ]; then
            echo "    eap=TLS" >> $file
            echo "    identity=\"autotest@actiontec.com\"" >> $file
            echo "    ca_cert=\"$ca_cert\"" >> $file
            echo "    client_cert=\"$cl_cert\"" >> $file
            echo "    private_key=\"$cl_key\"" >> $file
            echo "    private_key_passwd=\"actiontec\"" >> $file
        fi
        echo "}" >> $file
    fi
    #find ./ -name "$file" | xargs sed -i "s/+/\ /g"
    sed -i "s/+/\ /g" "$file"
fi
exit 0
