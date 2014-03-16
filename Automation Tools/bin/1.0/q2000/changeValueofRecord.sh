#!/bin/bash 
#---------------------------------
# Filename:	changeValueofRecord.sh
# Author: 	Aleon
#
# Usage: 	
#bash ./changeValueofRecord.sh -n <username/channel> -v <new username/channel> -f <input file>
#		changeValueofRecord.sh -n ppp -v becky002 -f /root/automation/platform/1.0/q2000h/testcases/sanity/config/B-Q2K-BA.ASC-1.0-001-c-allow
#		changeValueofRecord.sh -n ppp -v becky002 -f "/root/automation/platform/1.0/q2000h/testcases/sanity/config/B-Q2K-BA.ASC-*"
#
#       changeValueofRecord.sh -n ssid0_authMac -v 00%3A20%3A2B%3A03%3A05%3A08 -f /mnt/automation/platform/1.0/q2000h/testcases/sanity/config/wireless/B-Q1K-WI.SEC-081-C001
#
#  	    changeValueofRecord.sh -n <pool_id> -s <startip> -e <endip> -m <mask> -g <gateway>] -f <input file>
#		changeValueofRecord.sh -n pool_1 -s 192.168.2.2 -e 192.168.2.22 -m 255.255.255.0 -g 192.168.2.1 -f "/mnt/automation/platform/1.0/q2000h/testcases/sanity/config/wireless/B-Q1K*"
#       change ip info in service blocking post:
#       changeValueofRecord.sh -n serviceBlock -v <ip> -f <input file>
#       change ip info in port forwarding post:
#       changeValueofRecord.sh -n portForwardSrvAddr -v <ip> -f <input file>
#       change ip info in DMZ post:
#       changeValueofRecord.sh -n dmzIp -v <ip> -f <input file>
#       change ip info in Website blocking post:
#       changeValueofRecord.sh -n websiteBlock -v <ip> -f <input file>
# Date:		05/10/2011
#--------------------------------

#set -x 

usage="Usage: changeValueofRecord.sh -n <username/channel/ssid> -v <new username/channel/mac> -f <input file>"
if [ $# -eq 0 ]; then
	echo $usage
	exit
fi

while [ $# -gt 0 ]
do
        case $1 in
        -n)
                node=$2
		#echo $node
                shift 2;;
        -v)
                value=$2
            if [[ $node = ssid[0-3]_authMac ]]; then
                value="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$value")"
                echo "$node MAC is changed to $value"
            fi
		#echo $value
		shift 2;;
        --v1Wep128)
                wepDef128key0=$2
		#echo $wepDef128key0
		shift 2;;
        --v2Wep128)
                wepDef128key1=$2
		#echo $wepDef128key1
		shift 2;;
        --v3Wep128)
                wepDef128key2=$2
		#echo $wepDef128key2
		shift 2;;
        --v4Wep128)
                wepDef128key3=$2
		#echo $wepDef128key3
		shift 2;;
        -s)
                startip=$2
		shift 2;;
        -e)
                endip=$2
		shift 2;;
        -m)
                mask=$2
		shift 2;;
        -g)
                gateway=$2
		shift 2;;
        -f)
                file="$2"
		#echo $file
                shift 2;;
        -h)
                echo $usage
		exit
		;;
        *)
            echo $usage
            exit 1
        ;;
        esac
done


if [ -z $node ]; then
	echo "WORN: Please assign the type of change"
	echo $usage
	exit 1
fi

if [ -z $value ] && [ -z $startip ]; then
    echo "WORN: Please assign destination value of change."
    echo $usage
    exit 1
fi

if [ $value ] && [ $startip ]; then
    echo "WORN: Please assign one kind destination value of change."
    echo $usage
    exit 1
fi

if [ $startip ]; then
    if [ -z $endip ] || [ -z $mask ] || [ -z $gateway ]; then
        echo "WORN: Please assign whole value of change."
        echo $usage
        exit 1
    fi
fi

if [ -z "$file" ]; then
	echo "WORN: Please assign input file."
	echo $usage
	exit 1
fi

comment="# ----------------------- #"

case $node in
    
    ppp)

	echo $comment
	echo "# Set PPPoE username to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/pppUserName[^&]*\&/pppUserName=$value\&/g" $i
	done
	;;

    channel)
	echo $comment
	echo "# Set Channel of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/wlChannel[^&]*\&/wlChannel=$value\&/g" $i
	done
	;;

    ssid0_authMac)

	echo $comment
	echo "# Set ssid0 mac to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/deny\&wlFltMacAddr_wl0v0[^&]*\&/deny\&wlFltMacAddr_wl0v0=$value\&/g" $i
	    sed -i "s/allow\&wlFltMacAddr_wl0v0[^&]*\&/allow\&wlFltMacAddr_wl0v0=$value\&/g" $i
	done
	;;

    ssid1_authMac)

	echo $comment
	echo "# Set ssid1 mac to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/deny\&wlFltMacAddr_wl0v1[^&]*\&/deny\&wlFltMacAddr_wl0v1=$value\&/g" $i
	    sed -i "s/allow\&wlFltMacAddr_wl0v1[^&]*\&/allow\&wlFltMacAddr_wl0v1=$value\&/g" $i
	done
	;;

    ssid2_authMac)

	echo $comment
	echo "# Set ssid2 mac to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/deny\&wlFltMacAddr_wl0v2[^&]*\&/deny\&wlFltMacAddr_wl0v2=$value\&/g" $i
	    sed -i "s/allow\&wlFltMacAddr_wl0v2[^&]*\&/allow\&wlFltMacAddr_wl0v2=$value\&/g" $i
	done
	;;

    ssid3_authMac)

	echo $comment
	echo "# Set ssid3 mac to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/deny\&wlFltMacAddr_wl0v3[^&]*\&/deny\&wlFltMacAddr_wl0v3=$value\&/g" $i
	    sed -i "s/allow\&wlFltMacAddr_wl0v3[^&]*\&/allow\&wlFltMacAddr_wl0v3=$value\&/g" $i
	done
	;;

    radius_server)
	echo $comment
	echo "# Set radius server of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/wlRadiusServerIP_wl0v0[^&]*\&/wlRadiusServerIP_wl0v0=$value\&/g" $i
	    sed -i "s/wlRadiusServerIP_wl0v1[^&]*\&/wlRadiusServerIP_wl0v1=$value\&/g" $i
	    sed -i "s/wlRadiusServerIP_wl0v2[^&]*\&/wlRadiusServerIP_wl0v2=$value\&/g" $i
	    sed -i "s/wlRadiusServerIP_wl0v3[^&]*\&/wlRadiusServerIP_wl0v3=$value\&/g" $i
	done
	;;

    radius_key)
	echo $comment
	echo "# Set radius secret of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/wlRadiusKey_wl0v0[^&]*\&/wlRadiusKey_wl0v0=$value\&/g" $i
	    sed -i "s/wlRadiusKey_wl0v1[^&]*\&/wlRadiusKey_wl0v1=$value\&/g" $i
	    sed -i "s/wlRadiusKey_wl0v2[^&]*\&/wlRadiusKey_wl0v2=$value\&/g" $i
	    sed -i "s/wlRadiusKey_wl0v3[^&]*\&/wlRadiusKey_wl0v3=$value\&/g" $i
	done
	;;

    ssid_0)
	echo $comment
	echo "# Set ssid_0 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/wlSsid_wl0v0[^&]*\&/wlSsid_wl0v0=$value\&/g" $i
	done
	;;

    ssid_1)
	echo $comment
	echo "# Set ssid_1 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/wlSsid_wl0v1[^&]*\&/wlSsid_wl0v1=$value\&/g" $i
	done
	;;
	
    ssid_2)
	echo $comment
	echo "# Set ssid_2 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/wlSsid_wl0v2[^&]*\&/wlSsid_wl0v2=$value\&/g" $i
	done
	;;

    ssid_3)
	echo $comment
	echo "# Set ssid_3 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/wlSsid_wl0v3[^&]*\&/wlSsid_wl0v3=$value\&/g" $i
	done
	;;

    websiteBlock)
	echo $comment
	echo "# Set DMZ ip address to : $value "
	echo $comment
	for i in `ls $file`
	do
        scdmz=$(grep "urlfilter.cmd" $i | sed "s/.*\(urlfilter.cmd\).*/X1zY/g")
        if [[ $scdmz == X1zY* ]]; then
            #echo "found"
            sed -i "s/^\(action=set_url.*&Lan_IP=\)[^&]*&Lan_PcName=[0-9\.]\{7,15\}/\1$value\&Lan_PcName=$value/g" $i
            sed -i "s/^\(action=remove_url&.*&rmLstIp=\)[0-9\.]\{7,15\}/\1$value/g" $i
        fi 
	done
	;;

    serviceBlock)
	echo $comment
	echo "# Set DMZ ip address to : $value "
	echo $comment
	for i in `ls $file`
	do
        scdmz=$(grep "serv_block.cmd" $i | sed "s/.*\(serv_block.cmd\).*/X1zY/g")
        if [[ $scdmz == X1zY* ]]; then
            #echo "found"
            sed -i "s/^\(rules=\)[\.0-9]\{7,15\}/\1$value/g" $i
        fi 
	done
	;;

    dmzIp)
	echo $comment
	echo "# Set DMZ ip address to : $value "
	echo $comment
	for i in `ls $file`
	do
        scdmz=$(grep "scdmz.cmd" $i | sed "s/.*\(scdmz.cmd\).*/X1zY/g")
        if [[ $scdmz == X1zY* ]]; then
            #echo "found"
            sed -i "s/^\(address=\)[\.0-9]\{7,15\}/\1$value/g" $i
        fi 
	done
	;;

    portForwardSrvAddr)
	echo $comment
	echo "# Set lan ip address of portForward to : $value "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/^\(.*action=add&srvName=aDv_PoRt_FoRwArDiNg&srvAddr=\)[0-9\.]\{7,15\}/\1$value/g" $i
        sed -i "s/^\(.*action=remove_port_forwarding&rmLst=\)[0-9\.]\{7,15\}/\1$value/g" $i
	done
	;;

    wepcustom64)
	echo $comment
	echo "# Set wepCustom64key of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/wlDefaultKeyFlagWep128Bit=[^1359].*&wlKeyBit_wl0v[0-9]=1&wlKeyIndex_wl0v[0-9]=\([0-9]\)&.*&wlKey\1_64_wl0v[0-9]=[^&]*&/&CHANGEthisWEPCUSTOM64KEY/g" $i
        sed -i "s/=[^&]*&CHANGEthisWEPCUSTOM64KEY/=$value\&/g" $i
	done
	;;

    wepcustom64_1)
	echo $comment
	echo "# Set wepCustom64key1 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/wlDefaultKeyFlagWep128Bit=1.*&wlKeyBit_wl0v[1-9]=1&wlKeyIndex_wl0v[1-9]=1&.*&wlKey1_64_wl0v[1-9]=[^&]*&/&CHANGEthisWEPCUSTOM64KEY/g" $i
	sed -i "s/wlDefaultKeyFlagWep128Bit=0.*&wlKeyBit_wl0v0=1&wlKeyIndex_wl0v0=1&.*&wlKey1_64_wl0v0=[^&]*&/&CHANGEthisWEPCUSTOM64KEY/g" $i
        sed -i "s/=[^&]*&CHANGEthisWEPCUSTOM64KEY/=$value\&/g" $i
	done
	;;

    wepcustom64_2)
	echo $comment
	echo "# Set wepCustom64key2 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/wlDefaultKeyFlagWep128Bit=1.*&wlKeyBit_wl0v[1-9]=1&wlKeyIndex_wl0v[1-9]=2&.*&wlKey2_64_wl0v[1-9]=[^&]*&/&CHANGEthisWEPCUSTOM64KEY/g" $i
        sed -i "s/wlDefaultKeyFlagWep128Bit=0.*&wlKeyBit_wl0v0=1&wlKeyIndex_wl0v0=2&.*&wlKey2_64_wl0v0=[^&]*&/&CHANGEthisWEPCUSTOM64KEY/g" $i
        sed -i "s/=[^&]*&CHANGEthisWEPCUSTOM64KEY/=$value\&/g" $i
	done
	;;

    wepcustom64_3)
	echo $comment
	echo "# Set wepCustom64key3 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/wlDefaultKeyFlagWep128Bit=1.*&wlKeyBit_wl0v[1-9]=1&wlKeyIndex_wl0v[1-9]=3&.*&wlKey3_64_wl0v[1-9]=[^&]*&/&CHANGEthisWEPCUSTOM64KEY/g" $i
        sed -i "s/wlDefaultKeyFlagWep128Bit=0.*&wlKeyBit_wl0v0=1&wlKeyIndex_wl0v0=3&.*&wlKey3_64_wl0v0=[^&]*&/&CHANGEthisWEPCUSTOM64KEY/g" $i
        sed -i "s/=[^&]*&CHANGEthisWEPCUSTOM64KEY/=$value\&/g" $i
	done
	;;

    wepcustom64_4)
	echo $comment
	echo "# Set wepCustom64key4 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/wlDefaultKeyFlagWep128Bit=1.*&wlKeyBit_wl0v[1-9]=1&wlKeyIndex_wl0v[1-9]=4&.*&wlKey4_64_wl0v[1-9]=[^&]*&/&CHANGEthisWEPCUSTOM64KEY/g" $i
        sed -i "s/wlDefaultKeyFlagWep128Bit=0.*&wlKeyBit_wl0v0=1&wlKeyIndex_wl0v0=4&.*&wlKey4_64_wl0v0=[^&]*&/&CHANGEthisWEPCUSTOM64KEY/g" $i
        sed -i "s/=[^&]*&CHANGEthisWEPCUSTOM64KEY/=$value\&/g" $i
	done
	;;

    wepcustom128)
	echo $comment
	echo "# Set wepCustom128key of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/wlDefaultKeyFlagWep128Bit=[^1359].*&wlKeyBit_wl0v[0-9]=2&wlKeyIndex_wl0v[0-9]=\([0-9]\)&.*&wlKey\1_128_wl0v[0-9]=[^&]*&/&CHANGEthisWEPCUSTOM128KEY/g" $i
        sed -i "s/=[^&]*&CHANGEthisWEPCUSTOM128KEY/=$value\&/g" $i
	done
	;;

    wepcustom128_1)
	echo $comment
	echo "# Set wepCustom128key1 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/wlDefaultKeyFlagWep128Bit=1.*&wlKeyBit_wl0v[1-9]=2&wlKeyIndex_wl0v[1-9]=1&.*&wlKey1_128_wl0v[1-9]=[^&]*&/&CHANGEthisWEPCUSTOM128KEY/g" $i
	sed -i "s/wlDefaultKeyFlagWep128Bit=0.*&wlKeyBit_wl0v0=2&wlKeyIndex_wl0v0=1&.*&wlKey1_128_wl0v0=[^&]*&/&CHANGEthisWEPCUSTOM128KEY/g" $i
        sed -i "s/=[^&]*&CHANGEthisWEPCUSTOM128KEY/=$value\&/g" $i
	done
	;;

    wepcustom128_2)
	echo $comment
	echo "# Set wepCustom128key2 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/wlDefaultKeyFlagWep128Bit=1.*&wlKeyBit_wl0v[1-9]=2&wlKeyIndex_wl0v[1-9]=2&.*&wlKey2_128_wl0v[1-9]=[^&]*&/&CHANGEthisWEPCUSTOM128KEY/g" $i
	sed -i "s/wlDefaultKeyFlagWep128Bit=0.*&wlKeyBit_wl0v0=2&wlKeyIndex_wl0v0=2&.*&wlKey2_128_wl0v0=[^&]*&/&CHANGEthisWEPCUSTOM128KEY/g" $i
        sed -i "s/=[^&]*&CHANGEthisWEPCUSTOM128KEY/=$value\&/g" $i
	done
	;;

    wepcustom128_3)
	echo $comment
	echo "# Set wepCustom128key3 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/wlDefaultKeyFlagWep128Bit=1.*&wlKeyBit_wl0v[1-9]=2&wlKeyIndex_wl0v[1-9]=3&.*&wlKey3_128_wl0v[1-9]=[^&]*&/&CHANGEthisWEPCUSTOM128KEY/g" $i
	sed -i "s/wlDefaultKeyFlagWep128Bit=0.*&wlKeyBit_wl0v0=2&wlKeyIndex_wl0v0=3&.*&wlKey3_128_wl0v0=[^&]*&/&CHANGEthisWEPCUSTOM128KEY/g" $i
        sed -i "s/=[^&]*&CHANGEthisWEPCUSTOM128KEY/=$value\&/g" $i
	done
	;;

    wepcustom128_4)
	echo $comment
	echo "# Set wepCustom128key4 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/wlDefaultKeyFlagWep128Bit=1.*&wlKeyBit_wl0v[1-9]=2&wlKeyIndex_wl0v[1-9]=4&.*&wlKey4_128_wl0v[1-9]=[^&]*&/&CHANGEthisWEPCUSTOM128KEY/g" $i
	sed -i "s/wlDefaultKeyFlagWep128Bit=0.*&wlKeyBit_wl0v0=2&wlKeyIndex_wl0v0=4&.*&wlKey4_128_wl0v0=[^&]*&/&CHANGEthisWEPCUSTOM128KEY/g" $i
        sed -i "s/=[^&]*&CHANGEthisWEPCUSTOM128KEY/=$value\&/g" $i
	done
	;;

    wepdef)
	echo $comment
	echo "# Set wepDef64key of wireless to : $value "
	echo "# Set wepDef128key0 of wireless to : $wepDef128key0 "
	echo "# Set wepDef128key1 of wireless to : $wepDef128key1 "
	echo "# Set wepDef128key2 of wireless to : $wepDef128key2 "
	echo "# Set wepDef128key3 of wireless to : $wepDef128key3 "
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/&wlDefaultKeyWep64Bit=[^&]*&wlDefaultKeyWep128Bit=[^&]*&wlDefaultKeyWep128Bit=[^&]*&wlDefaultKeyWep128Bit=[^&]*&wlDefaultKeyWep128Bit=[^&]*&/\&wlDefaultKeyWep64Bit=$value\&wlDefaultKeyWep128Bit=$wepDef128key0\&wlDefaultKeyWep128Bit=$wepDef128key1\&wlDefaultKeyWep128Bit=$wepDef128key2\&wlDefaultKeyWep128Bit=$wepDef128key3\&/g" $i
        sed -i "s/wlDefaultKeyFlagWep64Bit=1&wlDefaultKeyFlagWep128Bit=[1359]&.*wlKeyBit_wl0v\([0-3]\)=[^0]&[^&]*&[^&]*&wlKey[^&]*&/&CHANGEthisDefUsingKey\1\&/g" $i
        wepDef128key_index=$(grep CHANGEthisDefUsingKey[0-3] $i | sed "s/.*CHANGEthisDefUsingKey\(.\).*/\1/g")
        #echo $wepDef128key_index
        wepDef128key_index=$((${wepDef128key_index}+1))
        if [ -n $wepDef128key_index ]; then
            if [ $wepDef128key_index = "1" ]; then
                sed -i "s/=[^&]*&CHANGEthisDefUsingKey[0-3]/=$wepDef128key0/g" $i
            fi
            if [ $wepDef128key_index = "2" ]; then
                sed -i "s/=[^&]*&CHANGEthisDefUsingKey[0-3]/=$wepDef128key1/g" $i
            fi
            if [ $wepDef128key_index = "3" ]; then
                sed -i "s/=[^&]*&CHANGEthisDefUsingKey[0-3]/=$wepDef128key2/g" $i
            fi
            if [ $wepDef128key_index = "4" ]; then
                sed -i "s/=[^&]*&CHANGEthisDefUsingKey[0-3]/=$wepDef128key3/g" $i
            fi
        fi
    done
	;;

    psk_0)
	echo $comment
	echo "# Set wpa_0 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	number=$(grep wlDefaultKeyFlagPsk $i | wc -l)
	if [ $number -eq 1 ]; then
		flag=$(grep wlDefaultKeyFlagPsk $i | sed 's/\(.*\)wlDefaultKeyFlagPsk=\(.*\)\&wlDefaultKeyPsk[01]\(.*\)/\2/g' | sed 's/\(.*\)\&wlDefaultKeyPsk0\(.*\)/\1/g')
        	re=$((flag&1))
        	if [ $re = "1" ]; then
	        	sed -i "s/wlWpaPsk_wl0v0[^&]*\&/wlWpaPsk_wl0v0=$value\&/g" $i
        	fi
		sed -i "s/wlDefaultKeyPsk0[^&]*\&/wlDefaultKeyPsk0=$value\&/g" $i
	elif [ $number -ne 0 ] ;then	
		count=1
		for line in $(<$i)
		do
        	flag=$(echo $line | grep wlDefaultKeyFlagPsk | sed 's/\(.*\)wlDefaultKeyFlagPsk=\(.*\)\&wlDefaultKeyPsk[01]\(.*\)/\2/g' | sed 's/\(.*\)\&wlDefaultKeyPsk0\(.*\)/\1/g')
		
        	if [ -n "$flag" ];then
			row=`sed -n '/wlDefaultKeyFlagPsk/=' $i | sed -n "${count}p"`
			count=$(($count+1))
			re=$((flag&1))
        		if [ $re = "1" ]; then
	        		sed -i "$row s/wlWpaPsk_wl0v0[^&]*\&/wlWpaPsk_wl0v0=$value\&/g" $i
        		fi
	    		sed -i "$row s/wlDefaultKeyPsk0[^&]*\&/wlDefaultKeyPsk0=$value\&/g" $i
		fi
		done
	fi
	done
	;;

    psk_1)
	echo $comment
	echo "# Set wpa_1 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	number=$(grep wlDefaultKeyFlagPsk $i | wc -l)
	if [ $number -eq 1 ]; then
		flag=$(grep wlDefaultKeyFlagPsk $i | sed 's/\(.*\)wlDefaultKeyFlagPsk=\(.*\)\&wlDefaultKeyPsk[01]\(.*\)/\2/g' | sed 's/\(.*\)\&wlDefaultKeyPsk0\(.*\)/\1/g')
        	re=$((flag&2))
        	if [ $re = "2" ]; then
	        	sed -i "s/wlWpaPsk_wl0v1[^&]*\&/wlWpaPsk_wl0v1=$value\&/g" $i
        	fi
	    	sed -i "s/wlDefaultKeyPsk1[^&]*\&/wlDefaultKeyPsk1=$value\&/g" $i
	elif [ $number -ne 0 ] ;then
		count=1
		for line in $(<$i)
		do
        	flag=$(echo $line | grep wlDefaultKeyFlagPsk | sed 's/\(.*\)wlDefaultKeyFlagPsk=\(.*\)\&wlDefaultKeyPsk[01]\(.*\)/\2/g' | sed 's/\(.*\)\&wlDefaultKeyPsk0\(.*\)/\1/g')		
        	if [ -n "$flag" ];then
			row=`sed -n '/wlDefaultKeyFlagPsk/=' $i | sed -n "${count}p"`
			count=$(($count+1))
			re=$((flag&2))
        		if [ $re = "2" ]; then
	        		sed -i "$row s/wlWpaPsk_wl0v1[^&]*\&/wlWpaPsk_wl0v1=$value\&/g" $i
        		fi
	    		sed -i "$row s/wlDefaultKeyPsk1[^&]*\&/wlDefaultKeyPsk1=$value\&/g" $i
		fi
		done
	fi
	done
	;;

    psk_2)
	echo $comment
	echo "# Set wpa_2 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	number=$(grep wlDefaultKeyFlagPsk $i | wc -l)
	if [ $number -eq 1 ]; then
 		flag=$(grep wlDefaultKeyFlagPsk $i | sed 's/\(.*\)wlDefaultKeyFlagPsk=\(.*\)\&wlDefaultKeyPsk[01]\(.*\)/\2/g' | sed 's/\(.*\)\&wlDefaultKeyPsk0\(.*\)/\1/g')
        	re=$((flag & 4))
        	if [ $re = "4" ]; then
	        	sed -i "s/wlWpaPsk_wl0v2[^&]*\&/wlWpaPsk_wl0v2=$value\&/g" $i
        	fi
	    	sed -i "s/wlDefaultKeyPsk2[^&]*\&/wlDefaultKeyPsk2=$value\&/g" $i
	elif [ $number -ne 0 ] ;then
		count=1
		for line in $(<$i)
		do
        	flag=$(echo $line | grep wlDefaultKeyFlagPsk | sed 's/\(.*\)wlDefaultKeyFlagPsk=\(.*\)\&wlDefaultKeyPsk[01]\(.*\)/\2/g' | sed 's/\(.*\)\&wlDefaultKeyPsk0\(.*\)/\1/g')
		if [ -n "$flag" ];then
			row=`sed -n '/wlDefaultKeyFlagPsk/=' $i | sed -n "${count}p"`
			count=$(($count+1))
        		re=$((flag & 4))
        		if [ $re = "4" ]; then
	        		sed -i "$row s/wlWpaPsk_wl0v2[^&]*\&/wlWpaPsk_wl0v2=$value\&/g" $i
        		fi
	    		sed -i "$row s/wlDefaultKeyPsk2[^&]*\&/wlDefaultKeyPsk2=$value\&/g" $i
		fi
		done
	fi
	done
	;;

    psk_3)
	echo $comment
	echo "# Set wpa_3 of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	number=$(grep wlDefaultKeyFlagPsk $i | wc -l)
	if [ $number -eq 1 ]; then
		flag=$(grep wlDefaultKeyFlagPsk $i | sed 's/\(.*\)wlDefaultKeyFlagPsk=\(.*\)\&wlDefaultKeyPsk[01]\(.*\)/\2/g' | sed 's/\(.*\)\&wlDefaultKeyPsk0\(.*\)/\1/g')
        	re=$((flag & 8))
        	if [ $re = "8" ]; then
	        	sed -i "s/wlWpaPsk_wl0v3[^&]*\&/wlWpaPsk_wl0v3=$value\&/g" $i
        	fi
	    	sed -i "s/wlDefaultKeyPsk3[^&]*\&/wlDefaultKeyPsk3=$value\&/g" $i
	elif [ $number -ne 0 ] ;then
		count=1
		for line in $(<$i)
		do
        	flag=$(echo $line | grep wlDefaultKeyFlagPsk | sed 's/\(.*\)wlDefaultKeyFlagPsk=\(.*\)\&wlDefaultKeyPsk[01]\(.*\)/\2/g' | sed 's/\(.*\)\&wlDefaultKeyPsk0\(.*\)/\1/g')
		if [ -n "$flag" ];then
			row=`sed -n '/wlDefaultKeyFlagPsk/=' $i | sed -n "${count}p"`
			count=$(($count+1))
        		re=$((flag & 8))
        		if [ $re = "8" ]; then
	        		sed -i "$row s/wlWpaPsk_wl0v3[^&]*\&/wlWpaPsk_wl0v3=$value\&/g" $i
        		fi
	    		sed -i "$row s/wlDefaultKeyPsk3[^&]*\&/wlDefaultKeyPsk3=$value\&/g" $i
		fi
		done
	fi
	done
	;;

    psk_cus)
	echo $comment
	echo "# Set wpa_cus of wireless to : $value "
	echo $comment
	for i in `ls $file`
	do
	number=$(grep wlDefaultKeyFlagPsk $i | wc -l)
	if [ $number -eq 1 ]; then
		flag=$(grep wlDefaultKeyFlagPsk $i | sed 's/\(.*\)wlDefaultKeyFlagPsk=\(.*\)\&wlDefaultKeyPsk[01]\(.*\)/\2/g' | sed 's/\(.*\)\&wlDefaultKeyPsk0\(.*\)/\1/g')
        	re=$((flag & 1))
        	if [ $re = "0" ]; then
	        	sed -i "s/wlWpaPsk_wl0v0[^&]*\&/wlWpaPsk_wl0v0=$value\&/g" $i
        	fi
        	re=$((flag & 2))
        	if [ $re = "0" ]; then
	        	sed -i "s/wlWpaPsk_wl0v1[^&]*\&/wlWpaPsk_wl0v1=$value\&/g" $i
        	fi
        	re=$((flag & 4))
        	if [ $re = "0" ]; then
	        	sed -i "s/wlWpaPsk_wl0v2[^&]*\&/wlWpaPsk_wl0v2=$value\&/g" $i
        	fi
        	re=$((flag & 8))
        	if [ $re = "0" ]; then
	        	sed -i "s/wlWpaPsk_wl0v3[^&]*\&/wlWpaPsk_wl0v3=$value\&/g" $i
        	fi
	elif [ $number -ne 0 ] ;then
		count=1
		for line in $(<$i)
		do
        		flag=$(echo $line | grep wlDefaultKeyFlagPsk | sed 's/\(.*\)wlDefaultKeyFlagPsk=\(.*\)\&wlDefaultKeyPsk[01]\(.*\)/\2/g' | sed 's/\(.*\)\&wlDefaultKeyPsk0\(.*\)/\1/g')
		if [ -n "$flag" ];then
			row=`sed -n '/wlDefaultKeyFlagPsk/=' $i | sed -n "${count}p"`
			count=$(($count+1))	
        		re=$((flag & 1))
        		if [ $re = "0" ]; then
	       			sed -i "$row s/wlWpaPsk_wl0v0[^&]*\&/wlWpaPsk_wl0v0=$value\&/g" $i
        		fi
        		re=$((flag & 2))
        		if [ $re = "0" ]; then
	        		sed -i "$row s/wlWpaPsk_wl0v1[^&]*\&/wlWpaPsk_wl0v1=$value\&/g" $i
		        fi
		        re=$((flag & 4))
		        if [ $re = "0" ]; then
			        sed -i "$row s/wlWpaPsk_wl0v2[^&]*\&/wlWpaPsk_wl0v2=$value\&/g" $i
		        fi
		        re=$((flag & 8))
		        if [ $re = "0" ]; then
			        sed -i "$row s/wlWpaPsk_wl0v3[^&]*\&/wlWpaPsk_wl0v3=$value\&/g" $i
		        fi
		fi
		done
	fi
	done
	;;

    #source for santiy,by aliu

    vpi)
	echo $comment
	echo "# set VPI of connection to : $value "
    	for i in `ls $file`
    	do
        	sed -i "s/atmVpi.*\&atmVci/atmVpi=$value\&atmVci/g" $i
    	done
    	;;

    vci)
    	echo $comment
    	echo "# set VCI of connection to : $value "
    	for i in `ls $file`
    	do
        	sed -i "s/atmVci.*\&connMode/atmVci=$value\&connMode/g" $i
    	done
    	;;

    ppppwd)
	echo $comment
	echo "# Set PPPoE password to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/pppPassword.*\&pppIpExtension/pppPassword=$value\&pppIpExtension/g" $i
	done
	;;

    wanip)
	echo $comment
	echo "# Set WAN IP address to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/wanIpAddress.*\&wanSubnetMask/wanIpAddress=$value\&wanSubnetMask/g" $i
	done
	;;

    submask)
	echo $comment
	echo "# Set submask to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/wanSubnetMask.*\&wanIntfGateway/wanSubnetMask=$value\&wanIntfGateway/g" $i
	done
	;;

    defaultgw)
	echo $comment
	echo "# Set default gateway to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/wanIntfGateway.*\&enblEnetWan/wanIntfGateway=$value\&enblEnetWan/g" $i
	done
	;;

    dns1)
	echo $comment
	echo "# Set primary DNS to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/dnsPrimary.*\&dnsSecondary/dnsPrimary=$value\&dnsSecondary/g" $i
	done
	;;

    dns2)
	echo $comment
	echo "# Set secondary DNS to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/dnsSecondary.*\&dnsIfc/dnsSecondary=$value\&dnsIfc/g" $i
	done
	;;

    vlanid)
	echo $comment
	echo "# Set VLAN ID to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/vlanMuxId.*\&vlanMuxPr/vlanMuxId=$value\&vlanMuxPr/g" $i
	done
	;;

    tr69ACSuser)
	echo $comment
	echo "# Set tr69 ACS username to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/tr69cAcsUser*\&tr69cAcsPwd/tr69cAcsUser=$value\&tr69cAcsPwd/g" $i
	done
	;;

    tr69ACSpwd)
	echo $comment
	echo "# Set tr69 ACS password to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/tr69cAcsPwd*\&tr69cInformEnable/tr69cAcsPwd=$value\&tr69cInformEnabled/g" $i
	done
	;;

    tr69Requser)
	echo $comment
	echo "# Set tr69 connReq username to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/tr69cConnReqUser*\&tr69cConnReqPwd/tr69cConnReqUser=$value\&tr69cConnReqPwd/g" $i
	done
	;;

    tr69Reqpwd)
	echo $comment
	echo "# Set tr69 connReq password to : $value"
	echo $comment
	for i in `ls $file`
	do
	    sed -i "s/tr69cConnReqPwd*\&tr69cBackoffInterval/tr69cConnReqPwd=$value\&tr69cBackoffInterval/g" $i
	done
	;;

    #source for santiy,by aliu

    pool_1)
	echo $comment
	echo "# Set SSID2 DHCP Pool: {from $startip to $endip}/$mask gateway: $gateway"
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/dhcpEthStart1[^&]*\&/dhcpEthStart1=$startip\&/g" $i
        sed -i "s/dhcpEthEnd1[^&]*\&/dhcpEthEnd1=$endip\&/g" $i
        sed -i "s/dhcpSubnetMask1[^&]*\&/dhcpSubnetMask1=$mask\&/g" $i
        sed -i "s/ethIpAddress1[^&]*\&/ethIpAddress1=$gateway\&/g" $i
        #sed -i "s/dhcpEthStart1.*\&wlBrName_wl0v1/dhcpEthStart1=$startip\&dhcpEthEnd1=$endip\&dhcpSubnetMask1=$mask\&ethIpAddress1=$gateway\&wlBrName_wl0v1/g" $file
	done
	;;

    pool_2)
	echo $comment
	echo "# Set SSID3 DHCP Pool: {$startip - $endip}/$mask gateway: $gateway"
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/dhcpEthStart2[^&]*\&/dhcpEthStart2=$startip\&/g" $i
        sed -i "s/dhcpEthEnd2[^&]*\&/dhcpEthEnd2=$endip\&/g" $i
        sed -i "s/dhcpSubnetMask2[^&]*\&/dhcpSubnetMask2=$mask\&/g" $i
        sed -i "s/ethIpAddress2[^&]*\&/ethIpAddress2=$gateway\&/g" $i
        #sed -i "s/dhcpEthStart2.*\&wlBrName_wl0v2/dhcpEthStart2=$startip\&dhcpEthEnd2=$endip\&dhcpSubnetMask2=$mask\&ethIpAddress2=$gateway\&wlBrName_wl0v2/g" $file
	done
	;;

    pool_3)
	echo $comment
	echo "# Set SSID4 DHCP Pool: {$startip - $endip}/$mask gateway: $gateway"
	echo $comment
	for i in `ls $file`
	do
        sed -i "s/dhcpEthStart3[^&]*\&/dhcpEthStart3=$startip\&/g" $i
        sed -i "s/dhcpEthEnd3[^&]*\&/dhcpEthEnd3=$endip\&/g" $i
        sed -i "s/dhcpSubnetMask3[^&]*\&/dhcpSubnetMask3=$mask\&/g" $i
        sed -i "s/ethIpAddress3[^&]*\&/ethIpAddress3=$gateway\&/g" $i
        #sed -i "s/dhcpEthStart3.*\&wlBrName_wl0v3/dhcpEthStart3=$startip\&dhcpEthEnd3=$endip\&dhcpSubnetMask3=$mask\&ethIpAddress3=$gateway\&wlBrName_wl0v3/g" $file
	done
	;;

    *)
	echo $comment
	echo "WORN: please input correct type of change."
	echo $usage
	;;

esac




