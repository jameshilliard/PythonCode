#!/bin/bash
# print version info
VER="1.0.2"
echo "$0 version : ${VER}"
echo "This scrpit is only for FiberTech!"

usage="usage: bash $0 -v <Input parameter> -o <Output file> [-test]\nInput parameter:wan.info | wan.stats | wan.dns | dut.date | cwmp.info | wan.link | arp.table | br0.info |dev.info | layer2.stats | basic.info | debug.info"
# parse commandline
while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        U_PATH_TBIN=.
        G_CURRENTLOG=./
        G_PROD_IP_BR0_0_0=192.168.1.1
        U_DUT_TELNET_USER=root
        U_DUT_TELNET_PWD=admin
        U_WIRELESSINTERFACE=wlan6
        #InternetGatewayDevice.WANDevice.1.WANConnectionDevice.6.WANIPConnection.1
        U_TR069_WANDEVICE_INDEX=InternetGatewayDevice.WANDevice.1
        U_DUT_TELNET_PORT=23
        shift 1
        ;;
    -v)
        param=$2
        echo "parameter input : $param"
        shift 2
        ;;
    -o)
        output=$2
        echo "delete output log File first: $output"
        rm -rf $output
        shift 2
        ;;
    *)
        echo -e $usage
        exit 1
        ;;
    esac
done

# cli subprocess
wan.info(){
    echo "wan.info"

    # login dut and execute cli command
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "route -n" -v "ifconfig" -t wanInfo.tmp -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    dos2unix  $G_CURRENTLOG/wanInfo.tmp

    # parse default route info 
    #dut_wan_if=`cat $G_CURRENTLOG/wanInfo.tmp|grep "^ *@0.0.0.0"|awk '{print $8}'`
    echo "$dut_wan_if"
    dut_wan_if=`awk '{if (/^\@0.0.0.0/) print $8}' $G_CURRENTLOG/wanInfo.tmp`
    dut_def_gw=`awk '{if (/^\@0.0.0.0/) print $2}' $G_CURRENTLOG/wanInfo.tmp`
    #dut_def_gw=`cat $G_CURRENTLOG/wanInfo.tmp|grep "^ *@0.0.0.0"|awk '{print $2}'`
    # check default gw
    echo "dut_def_gw : $dut_def_gw"
    if [ "$dut_def_gw" == "0.0.0.0" ] ;then
        echo "sed -n \"/^\@$dut_wan_if/{n;p}\" $G_CURRENTLOG/wanInfo.tmp |awk '{print $3}'| awk -F: '{print $2}' | sed '/^$/d'"
        dut_def_gw=`sed -n "/^\@$dut_wan_if/{n;p}" $G_CURRENTLOG/wanInfo.tmp |awk '{print $4}'| awk -F: '{print $2}' | sed '/^$/d'`
        echo "dut_def_gw : $dut_def_gw"
    fi
    
    # check default gw
    #echo "dut_def_gw = $dut_def_gw"
    #echo "dut_wan_if = $dut_wan_if"

    rc=`echo "$dut_def_gw" |grep  "\."`
    echo "rc=$rc"
    if [ -z "$dut_wan_if" || -z "$rc" ] ;then
        echo "TMP_DUT_WAN_IF=" >> $output
        echo "TMP_DUT_WAN_IP=" >> $output
        echo "TMP_DUT_DEF_GW=" >> $output
        echo "AT_ERROR : DUT WAN IF is empty!\n"
        exit 1
    fi

    # parse wan ip
    dut_wan_ip="`sed -n "/^\@$dut_wan_if/{n;p}" $G_CURRENTLOG/wanInfo.tmp |awk '{print $3}' | awk -F: '{print $2}'`"
    echo "dut_wan_ip=$dut_wan_ip"
    # check wan ip
    rc=`echo "$dut_wan_ip" |grep  "\."`
    echo "rc=$rc"
    if [ -z $rc ] ;then
        echo "TMP_DUT_WAN_IP="            >$output
    else
        echo "TMP_DUT_WAN_IP=$dut_wan_ip" >>$output
    fi

    # parse wan mask
    dut_wan_mask="`sed -n "/^@$dut_wan_if/{n;p}" $G_CURRENTLOG/wanInfo.tmp |awk '{print $4}'|awk -F: '{print $2}'`"
    # check wan mask
    echo "dut_wan_mask = $dut_wan_mask"

   #  # parse wan ip
   # dut_wan_ip=`grep -o "ip=[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}" $G_CURRENTLOG/wanInfo.tmp |awk -F = '{print $2}'`
   # # check wan ip
   # echo "dut_wan_ip = $dut_wan_ip"
   # rc=`echo "$dut_wan_ip" | grep  "\."`
   # echo "rc=$rc"
   # if [ -z $rc ]
   # then
   #     echo "-| FAIL : DUT WAN IP is error"
   #     exit -1
   # fi
    # parse wan macaddress
    dut_wan_mac=`grep "^@eth10" $G_CURRENTLOG/wanInfo.tmp |awk '{print $5}'` 
    echo "dut_wan_mac = $dut_wan_mac"

    dut_wan_ipv6=`grep -i "^@${dut_wan_if}  *Link" $G_CURRENTLOG/wanInfo.tmp -A 5|grep -i "inet6 addr:.*Scope:Link"|awk '{print $4}'|sed 's/^ *//g'|sed 's/ *$//g'`
    echo "dut_wan_ipv6=$dut_wan_ipv6"

    echo "TMP_DUT_WAN_IF=$dut_wan_if" >>$output
    echo "TMP_DUT_DEF_GW=$dut_def_gw" >> $output
    echo "TMP_DUT_WAN_MAC=$dut_wan_mac" >> $output
    echo "TMP_DUT_WAN_MASK=$dut_wan_mask" >> $output
    echo "TMP_DUT_WAN_IPV6=$dut_wan_ipv6" >> $output
}

dut.date(){
    echo "date"
    
    # login dut and execute cli command
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "date" -t dutDate.tmp -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    dos2unix $G_CURRENTLOG/dutDate.tmp

    # parse dut date
    dut_date=`grep -A 1 "date" $G_CURRENTLOG/dutDate.tmp | tail -1 |  sed s/\@//g` 
    
    # check result
    if [ -z "$dut_date" ] ;then
        echo "FAIL : DUT date is empty!"
        echo "U_CUSTOM_LOCALTIME=" >> $output
        exit 1
    fi

    # output result
    echo "U_CUSTOM_LOCALTIME=$dut_date" >> $output
}

wan.stats(){
    echo "wan.stats"
    
    # login dut and execute cli command
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cat /proc/net/dev" -t wanStats.tmp -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    # parse wan stats
    # if the received Bytes' length more than 8 bit, interface field and receive bytes field will merge to one field.
    # so add code "awk -F: '{print $2}'" 
    BytesSent=`cat $G_CURRENTLOG/wanStats.tmp       |grep "eth10:" |awk -F: '{print $2}' |awk '{print $9}'`
    BytesReceived=`cat $G_CURRENTLOG/wanStats.tmp   |grep "eth10:" |awk -F: '{print $2}' |awk '{print $1}'`
    PacketsSent=`cat $G_CURRENTLOG/wanStats.tmp     |grep "eth10:" |awk -F: '{print $2}' |awk '{print $10}'`
    PacketsReceived=`cat $G_CURRENTLOG/wanStats.tmp |grep "eth10:" |awk -F: '{print $2}' |awk '{print $2}'`

    # output result
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$BytesSent"                         >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$BytesReceived"                 >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$PacketsSent"                     >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$PacketsReceived"             >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.BytesSent=$BytesSent"                      >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.BytesReceived=$BytesReceived"              >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.PacketsSent=$PacketsSent"                  >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.PacketsReceived=$PacketsReceived"          >> $output
}

wan.dns(){
    echo "wan.dns"

    # login dut and execute cli command
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cat /etc/resolv.conf" -t wanDns.tmp -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    dos2unix $G_CURRENTLOG/wanDns.tmp
    
    # get the number of DNS servers
    dnsCount=`cat $G_CURRENTLOG/wanDns.tmp | grep "nameserver  *[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | wc -l`
    
    # parse result and output
    if [ $dnsCount -ge 2  ] ;then
        DNS1=`cat $G_CURRENTLOG/wanDns.tmp | grep "nameserver  *[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | awk '{print $2}' | head -1`
        echo "TMP_DUT_WAN_DNS_1=$DNS1" >> $output

        DNS2=`cat $G_CURRENTLOG/wanDns.tmp | grep "nameserver  *[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | awk '{print $2}' | head -2 | tail -1`
        echo "TMP_DUT_WAN_DNS_2=$DNS2" >> $output
    elif [ $dnsCount -eq 1  ] ;then
        DNS1=`cat $G_CURRENTLOG/wanDns.tmp | grep "nameserver  *[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | awk '{print $2}'`
        echo "TMP_DUT_WAN_DNS_1=$DNS1" >> $output
        echo "TMP_DUT_WAN_DNS_2="      >> $output
    else
        echo "TMP_DUT_WAN_DNS_1="      >> $output
        echo "TMP_DUT_WAN_DNS_2="      >> $output
    fi
}

cwmp.info(){
    echo "cwmp.info"
    perl $U_PATH_TBIN/DUTCmd.pl -o cwmpInfo.tmp -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -v "cli -g InternetGatewayDevice.ManagementServer." -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD 
    dos2unix $G_CURRENTLOG/cwmpInfo.tmp
    Acs_username=`cat $G_CURRENTLOG/cwmpInfo.tmp|grep -i "\.Username"               |awk -F= '{print $2}' |awk '{print $1}'`
    Acs_password=`cat $G_CURRENTLOG/cwmpInfo.tmp|grep -i "\.Password"               |awk -F= '{print $2}' |awk '{print $1}'`
    Req_Username=`cat $G_CURRENTLOG/cwmpInfo.tmp|grep -i "ConnectionRequestUsername"|awk -F= '{print $2}' |awk '{print $1}'`
    Req_Password=`cat $G_CURRENTLOG/cwmpInfo.tmp|grep -i "ConnectionRequestPassword"|awk -F= '{print $2}' |awk '{print $1}'`
    Req_URL=`cat $G_CURRENTLOG/cwmpInfo.tmp     |grep -i "ConnectionRequestURL"     |awk -F= '{print $2}' |awk '{print $1}'`
    Acs_URL=`cat $G_CURRENTLOG/cwmpInfo.tmp     |grep -i "\.URL"                    |awk -F= '{print $2}' |awk '{print $1}'`
    echo "TMP_DUT_CWMP_ACS_URL=$Acs_URL"                >$output
    echo "TMP_DUT_CWMP_CONN_ACS_USERNAME=$Acs_username" >>$output
    echo "TMP_DUT_CWMP_CONN_ACS_PASSWORD=$Acs_password" >>$output
    echo "TMP_DUT_CWMP_CONN_REQ_USERNAME=$Req_Username" >>$output
    echo "TMP_DUT_CWMP_CONN_REQ_PASSWORD=$Req_Password" >>$output
    echo "TMP_DUT_CWMP_CONN_REQ_URL=$Req_URL"           >>$output
}

wan.link(){
  echo "wan.link(get wan link mode)"
  rm -rf $G_CURRENTLOG/wanlink.tmp
  isplink=Unknown
  perl $U_PATH_TBIN/DUTCmd.pl -o wanlink.tmp -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -v "cli -g InternetGatewayDevice.Layer3Forwarding.DefaultConnectionService" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD
  if [ $? -ne 0 ];then
        exit 1
  fi 
  dos2unix $G_CURRENTLOG/wanlink.tmp
  ipoeflag=`grep -i "WANIPConnection" $G_CURRENTLOG/wanlink.tmp`
  pppoeflag=`grep -i "WANPPPConnection" $G_CURRENTLOG/wanlink.tmp`

  if [ "$ipoeflag" ] && [ -z "$pppoeflag" ];then
      isplink=IPOE
  elif [ "$pppoeflag" ] && [ -z "$ipoeflag" ];then
      isplink=PPPOE
  else
      echo -e " Cant judge WAN Link Mode! "
  fi

  echo "TMP_DUT_WAN_LINK=ETH" >$output
  echo "TMP_DUT_WAN_ISP_PROTO=$isplink" >>$output  

  }

wifi.info(){

    echo "=======Entry wifi.info"
    iwconfig | tee $G_CURRENTLOG/wireless_iwconfig.log  
    let number=1
    for wlan in `cat  $G_CURRENTLOG/wireless_iwconfig.log | grep "IEEE 802.11" | awk '{print $1}'|sort|uniq`
    do
        echo "wlan interface : $wlan"
        ifconfig $wlan | tee $G_CURRENTLOG/wireless_ifconfig_${wlan}.log
        if [ ${number} -eq 1 ]; then
             echo  "U_WIRELESSINTERFACE=$wlan"    >> $output
             echo  "U_WIRELESSCARD_MAC=`cat $G_CURRENTLOG/wireless_ifconfig_${wlan}.log  | grep "$wlan" | awk '{print $5}'`"        >> $output    
        elif [ ${number} -gt 1 ]; then  
             echo  "U_WIRELESSINTERFACE$number=$wlan"  >> $output
             echo  "U_WIRELESSCARD_MAC$number=`cat $G_CURRENTLOG/wireless_ifconfig_${wlan}.log  | grep "$wlan" | awk '{print $5}'`" >> $output
        fi
    let number=$number+1
    done

    rm -rf $G_CURRENTLOG/wireless_ssid.log
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"ifconfig -a\" -v \"cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID\" -v \"cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.2.SSID\" -v \"cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.3.SSID\" -v \"cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.4.SSID\" -v \"cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.PreSharedKey.1.PreSharedKey\" -v \"cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.2.PreSharedKey.1.PreSharedKey\" -v \"cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.3.PreSharedKey.1.PreSharedKey\" -v \"cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.4.PreSharedKey.1.PreSharedKey\" "

    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "ifconfig -a" -v "cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID" -v "cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.2.SSID" -v "cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.3.SSID" -v "cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.4.SSID" -v "cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.PreSharedKey.1.PreSharedKey" -v "cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.2.PreSharedKey.1.PreSharedKey" -v "cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.3.PreSharedKey.1.PreSharedKey" -v "cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.4.PreSharedKey.1.PreSharedKey" -o wireless_ssid.log
    dos2unix  $G_CURRENTLOG/wireless_ssid.log
       
    U_WIRELESS_SSID1_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    U_WIRELESS_SSID2_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "InternetGatewayDevice.LANDevice.1.WLANConfiguration.2.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    U_WIRELESS_SSID3_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "InternetGatewayDevice.LANDevice.1.WLANConfiguration.3.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`   
    U_WIRELESS_SSID4_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "InternetGatewayDevice.LANDevice.1.WLANConfiguration.4.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`

    U_WIRELESS_WPAPSK1_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.PreSharedKey.1.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    U_WIRELESS_WPAPSK2_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "InternetGatewayDevice.LANDevice.1.WLANConfiguration.2.PreSharedKey.1.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    U_WIRELESS_WPAPSK3_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "InternetGatewayDevice.LANDevice.1.WLANConfiguration.3.PreSharedKey.1.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    U_WIRELESS_WPAPSK4_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "InternetGatewayDevice.LANDevice.1.WLANConfiguration.4.PreSharedKey.1.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`

    U_WIRELESS_BSSID1_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HWaddr"|grep "^ *ath0 " |awk '{print $5}'|tr [A-Z] [a-z]`
    U_WIRELESS_BSSID2_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HWaddr"|grep "^ *ath1 " |awk '{print $5}'|tr [A-Z] [a-z]`
    U_WIRELESS_BSSID3_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HWaddr"|grep "^ *ath2 " |awk '{print $5}'|tr [A-Z] [a-z]`
    U_WIRELESS_BSSID4_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HWaddr"|grep "^ *ath3 " |awk '{print $5}'|tr [A-Z] [a-z]`
    
    echo "U_WIRELESS_SSID1=$U_WIRELESS_SSID1_VALUE"                            >> $output
    echo "U_WIRELESS_SSID2=$U_WIRELESS_SSID2_VALUE"                            >> $output
    echo "U_WIRELESS_SSID3=$U_WIRELESS_SSID3_VALUE"                            >> $output
    echo "U_WIRELESS_SSID4=$U_WIRELESS_SSID4_VALUE"                            >> $output

    echo "U_WIRELESS_WPAPSK1=$U_WIRELESS_WPAPSK1_VALUE"                        >> $output
    echo "U_WIRELESS_WPAPSK2=$U_WIRELESS_WPAPSK2_VALUE"                        >> $output
    echo "U_WIRELESS_WPAPSK3=$U_WIRELESS_WPAPSK3_VALUE"                        >> $output
    echo "U_WIRELESS_WPAPSK4=$U_WIRELESS_WPAPSK4_VALUE"                        >> $output

    echo "U_WIRELESS_WEPKEY_DEF_64=0987654321"                                 >> $output

    echo "U_WIRELESS_WEPKEY1=1A2B3C4D5E"                                       >> $output
    echo "U_WIRELESS_WEPKEY2=1A2B3C4D5E"                                       >> $output
    echo "U_WIRELESS_WEPKEY3=1A2B3C4D5E"                                       >> $output
    echo "U_WIRELESS_WEPKEY4=1A2B3C4D5E"                                       >> $output

    echo "U_WIRELESS_BSSID1=$U_WIRELESS_BSSID1_VALUE"                          >> $output
    echo "U_WIRELESS_BSSID2=$U_WIRELESS_BSSID2_VALUE"                          >> $output
    echo "U_WIRELESS_BSSID3=$U_WIRELESS_BSSID3_VALUE"                          >> $output
    echo "U_WIRELESS_BSSID4=$U_WIRELESS_BSSID4_VALUE"                          >> $output

    echo ""
    cat $output
}
  

  wl.mac(){
   echo "wl.mac"
   perl $U_PATH_TBIN/DUTCmd.pl -o wlmac.tmp -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "ifconfig -a"
   dos2unix $G_CURRENTLOG/wlmac.tmp
   wl1_mac=`cat $G_CURRENTLOG/wlmac.tmp |grep "ath0" |awk '{print $5}'`
   wl2_mac=`cat $G_CURRENTLOG/wlmac.tmp |grep "ath1" |awk '{print $5}'`
   wl3_mac=`cat $G_CURRENTLOG/wlmac.tmp |grep "ath2" |awk '{print $5}'`
   wl4_mac=`cat $G_CURRENTLOG/wlmac.tmp |grep "ath3" |awk '{print $5}'`

   echo "TMP_DUT_WIRELESS_BSSID1=$wl1_mac"    >$output
   echo "TMP_DUT_WIRELESS_BSSID2=$wl2_mac"   >>$output
   echo "TMP_DUT_WIRELESS_BSSID3=$wl3_mac"   >>$output
   echo "TMP_DUT_WIRELESS_BSSID4=$wl4_mac"   >>$output
}

wireless.conf(){
        echo "grep wlan info"
        wireless_mac=`ifconfig $U_WIRELESSINTERFACE  | grep "HWaddr" | awk '{print $5}'`
        wireless_address=`ifconfig $U_WIRELESSINTERFACE | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
        echo "AssociatedDeviceMACAddress=$wireless_mac" > $output
        echo "AssociatedDeviceIPAddress=$wireless_address" >> $output
}

wifi.stats(){
    echo "wifi.stats"
    perl $U_PATH_TBIN/DUTCmd.pl -o xdslctl.tmp -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /proc/net/dev"
    dos2unix $G_CURRENTLOG/xdslctl.tmp    
    TotalBytesReceived=`cat $G_CURRENTLOG/xdslctl.tmp    |grep "ath0:" |awk -F: '{print $2}'|awk '{print $1}'`
    TotalPacketsReceived=`cat $G_CURRENTLOG/xdslctl.tmp  |grep "ath0:" |awk -F: '{print $2}'|awk '{print $2}'`
    TotalBytesSent=`cat $G_CURRENTLOG/xdslctl.tmp        |grep "ath0:" |awk -F: '{print $2}'|awk '{print $9}'`
    TotalPacketsSent=`cat $G_CURRENTLOG/xdslctl.tmp      |grep "ath0:" |awk -F: '{print $2}'|awk '{print $10}'`

    echo "TotalBytesSent=$TotalBytesSent"              > $output    
    echo "TotalPacketsSent=$TotalPacketsSent"          >> $output
    echo "TotalBytesReceived=$TotalBytesReceived"      >> $output
    echo "TotalPacketsReceived=$TotalPacketsReceived"  >> $output
} 

arp.table(){
    echo "arp.table"
    perl $U_PATH_TBIN/DUTCmd.pl -o getARPTable.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "arp -n"
    if [ $? != 0 ]; then
        echo "AT_ERROR : failed to execute DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/getARPTable.log
    sed -n "/\# arp \-n/,$"p $G_CURRENTLOG/getARPTable.log | grep "^? *([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\})" > $G_CURRENTLOG/tmpARPTable.log
    rc=$?
    echo "rc=$?"
    if [ $rc == 0 ];then
        line_index=1
        cat $G_CURRENTLOG/tmpARPTable.log | while read line
        do
            curline=`echo $line |sed "s/? //g"`
            echo "U_DUT_ARP_TABLE_LINE$line_index=$curline" | tee -a $output
            line_index=`echo "$line_index+1" | bc`
        done
    else
        echo "Not find valid data in $G_CURRENTLOG/getARPTable.log"
        exit 1
        #cat $G_CURRENTLOG/getARPTable.log
    fi
 }

br0.info(){
      echo "get br0 info for FT"
      startip=Unknown
      endip=Unknown
      #staticmask=Unknown
      dhcpmask=Unknown
      router=Unknown
      br0dns1=Unknown
      br0dns2=Unknown
      lt=Unknown
      echo "G_CURRENTLOG=$G_CURRENTLOG"
      echo "output=$output"
      echo "perl $U_PATH_TBIN/DUTCmd.pl -o br0info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cat /var/br0_udhcpd.conf\" -v \"ifconfig\""
      perl $U_PATH_TBIN/DUTCmd.pl -o br0info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /var/br0_udhcpd.conf" -v "ifconfig"
      dos2unix $G_CURRENTLOG/br0info.log
      startip=`grep "^ *start " $G_CURRENTLOG/br0info.log |awk '{print $2}'`
      endip=`grep "^ *end " $G_CURRENTLOG/br0info.log |awk '{print $2}'`
      #staticmask=`grep "^ *option subnet" $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      dhcpmask=`grep "^ *option subnet" $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      router=`grep "^ *option router " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      br0dns1=`grep "^ *option dns " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      br0dns2=`grep "^ *option dns " $G_CURRENTLOG/br0info.log |awk '{print $4}'`
      lt=`grep "^ *option lease " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      br0mac=`grep "HWaddr" $G_CURRENTLOG/br0info.log|grep "^ *br0 "|awk '{print $5}'|tr [A-Z] [a-z]`
      #echo "G_PROD_USR0=$U_DUT_TELNET_USER">>$output
      #echo "G_PROD_PWD0=$U_DUT_TELNET_PWD">>$output
      echo "G_PROD_IP_BR0_0_0=$G_PROD_IP_BR0_0_0">>$output
      echo "G_PROD_GW_BR0_0_0=$router">>$output
      echo "G_PROD_TMASK_BR0_0_0=$dhcpmask">>$output
      #echo "G_PROD_TMASK_BR0_0_0=$staticmask">>$output
      echo "G_PROD_DHCPSTART_BR0_0_0=$startip">>$output
      echo "G_PROD_DHCPEND_BR0_0_0=$endip">>$output
      echo "G_PROD_LEASETIME_BR0_0_0=$lt">>$output
      echo "G_PROD_DNS1_BR0_0_0=$br0dns1">>$output
      echo "G_PROD_DNS2_BR0_0_0=$br0dns2">>$output
      echo "G_PROD_MAC_BR0_0_0=$br0mac">>$output
}

dev.info(){
    echo "get DUT SN,FW,ModelName,ManufacturerOUI"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cli -g InternetGatewayDevice.DeviceInfo.ManufacturerOUI\" -v \"cli -g InternetGatewayDevice.DeviceInfo.SerialNumber\" -v \"cli -g InternetGatewayDevice.DeviceInfo.SoftwareVersion\" -v \"cli -g InternetGatewayDevice.DeviceInfo.ModelName\""
    perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "ifconfig" -v "cli -g InternetGatewayDevice.DeviceInfo.ManufacturerOUI" -v "cli -g InternetGatewayDevice.DeviceInfo.SerialNumber" -v "cli -g InternetGatewayDevice.DeviceInfo.SoftwareVersion" -v "cli -g InternetGatewayDevice.DeviceInfo.ModelName"
    if [ $? -ne 0 ];then
        echo "AT_ERROR : perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cli -g InternetGatewayDevice.DeviceInfo.ManufacturerOUI\" -v \"cli -g InternetGatewayDevice.DeviceInfo.SerialNumber\" -v \"cli -g InternetGatewayDevice.DeviceInfo.SoftwareVersion\" -v \"cli -g InternetGatewayDevice.DeviceInfo.ModelName\""
        exit 1
    fi
    dos2unix $G_CURRENTLOG/devinfo.log
    dut_oui=`cat $G_CURRENTLOG/devinfo.log|grep "InternetGatewayDevice.DeviceInfo.ManufacturerOUI *="|awk -F= '{print $2}'|awk '{print $1}'`
    dut_sn=`cat $G_CURRENTLOG/devinfo.log|grep "InternetGatewayDevice.DeviceInfo.SerialNumber *="|awk -F= '{print $2}'|awk '{print $1}'`
    dut_fw=`cat $G_CURRENTLOG/devinfo.log|grep "InternetGatewayDevice.DeviceInfo.SoftwareVersion *="|awk -F= '{print $2}'|awk '{print $1}'`
    dut_type=`cat $G_CURRENTLOG/devinfo.log|grep "InternetGatewayDevice.DeviceInfo.ModelName *="|awk -F= '{print $2}'|awk '{print $1}'`
    echo "U_DUT_SN=$dut_sn" >>$output
    echo "U_DUT_MODELNAME=$dut_type" >>$output
    echo "U_DUT_SW_VERSION=$dut_fw" >>$output
    echo "U_TR069_CUSTOM_MANUFACTUREROUI=$dut_oui" >>$output
    cat $output
}

layer2.stats(){
    echo "Get the connection status of layer2 interface for OpenWRT"
    let i=1
    retry_times=5
    sleep_time=10
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o layer2_connection_status.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v \"cli -g InternetGatewayDevice.WANDevice.1.WANEthernetInterfaceConfig.Status\""
    while true
    do
        let fail_num=0
        rm -f $G_CURRENTLOG/layer2_connection_status.log
        perl $U_PATH_TBIN/DUTCmd.pl -o layer2_connection_status.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "cli -g InternetGatewayDevice.WANDevice.1.WANEthernetInterfaceConfig.Status"
        if [ $? -eq 0 ];then
            dos2unix $G_CURRENTLOG/layer2_connection_status.log
            grep -i "InternetGatewayDevice.WANDevice.1.WANEthernetInterfaceConfig.Status *= *[0-9A-Za-z][0-9A-Za-z]*" $G_CURRENTLOG/layer2_connection_status.log
            let fail_num=${fail_num}+$?
            echo "fail_num=${fail_num}"
            if [ ${fail_num} -gt 0 ];then
                let i=$i+1
                if [ $i -gt ${retry_times} ];then
                    echo -e "\nAT_ERROR : Get the connection status of layer2 interface FAIL!\n"
                    cat $G_CURRENTLOG/layer2_connection_status.log
                    exit 1
                fi
                echo "Get the connection status of layer2 interface FAIL,Try $i time..."
                sleep ${sleep_time}
            else
                #cat $G_CURRENTLOG/layer2_connection_status.log|grep -i "^ *InternetGatewayDevice.*="|tee $output
                eth=`grep -i "InternetGatewayDevice.WANDevice.1.WANEthernetInterfaceConfig.Status *= *[0-9A-Za-z][0-9A-Za-z]*" $G_CURRENTLOG/layer2_connection_status.log|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
                echo "ETH=$eth"|tee $output
                break
            fi
        else
            let i=$i+1
            if [ $i -gt ${retry_times} ];then
                echo -e "\nAT_ERROR : Get the connection status of layer2 interface FAIL!\n"
                exit 1
            fi
            echo "Get the connection status of layer2 interface FAIL,Try $i time..."
            sleep ${sleep_time}
        fi
    done
}

basic.info(){
    echo "get bootloader basic info for OpenWRT"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o basicinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cli -g InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.MACAddress\" -v \"cli -ga InternetGatewayDevice.DeviceInfo.HardwareVersion\" -v \"cli -ga InternetGatewayDevice.DeviceInfo.SerialNumber\" -v \"cli -ga InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.WPS.DevicePassword\" -v \"cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.PreSharedKey.1.PreSharedKey\" -v \"cli -ga InternetGatewayDevice.X_ACTIONTEC_SystemConfig.systemLoggingBufferSize\" -v \"cli -ga InternetGatewayDevice.X_ACTIONTEC_Multiple_Users.1.crypt_pw\""
    perl $U_PATH_TBIN/DUTCmd.pl -o basicinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cli -g InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.MACAddress" -v "cli -ga InternetGatewayDevice.DeviceInfo.HardwareVersion" -v "cli -ga InternetGatewayDevice.DeviceInfo.SerialNumber" -v "cli -ga InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.WPS.DevicePassword" -v "cli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.PreSharedKey.1.PreSharedKey" -v "cli -ga InternetGatewayDevice.X_ACTIONTEC_SystemConfig.systemLoggingBufferSize" -v "cli -ga InternetGatewayDevice.X_ACTIONTEC_Multiple_Users.1.crypt_pw"
    if [ $? -ne 0 ];then
        exit 1
    fi

    dos2unix $G_CURRENTLOG/basicinfo.log
    wpakey=`cat $G_CURRENTLOG/basicinfo.log | grep "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.PreSharedKey.1.PreSharedKey *=" |sed 's/(.*)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    wpspin=`cat $G_CURRENTLOG/basicinfo.log | grep "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.WPS.DevicePassword *=" |sed 's/(.*)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    boardid=`cat $G_CURRENTLOG/basicinfo.log | grep "InternetGatewayDevice.DeviceInfo.HardwareVersion *=" |sed 's/(.*)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    basicmac=`cat $G_CURRENTLOG/basicinfo.log | grep "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.MACAddress *=" |sed 's/(.*)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    snnum=`cat $G_CURRENTLOG/basicinfo.log | grep "InternetGatewayDevice.DeviceInfo.SerialNumber *=" |sed 's/(.*)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    logsize=`cat $G_CURRENTLOG/basicinfo.log | grep "InternetGatewayDevice.X_ACTIONTEC_SystemConfig.systemLoggingBufferSize *=" |sed 's/(.*)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    passwd=`cat $G_CURRENTLOG/basicinfo.log | grep "InternetGatewayDevice.X_ACTIONTEC_Multiple_Users.1.crypt_pw *=" |sed 's/(.*)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`

    echo "BOARD_ID=$boardid"    >$output
    echo "SERIAL_NUM=$snnum"   >>$output
    echo "WPA_KEY=$wpakey"     >>$output
    echo "WPS_PIN=$wpspin"     >>$output
    echo "BASIC_MAC=$basicmac" >>$output
    echo "PASSWORD=$passwd"    >>$output
    echo "LOG_SIZE=$logsize"   >>$output
    grep "= *$" $output
    if [ $? -eq 0 ];then
        echo "AT_ERROR : NULL Value are not allowed!"
        #cat $output
        #exit 1
    fi
    cat $output
}

debug.info(){
    echo "Get debug info : ps;iptables -nvL;iptables -vnL -t nat;ifconfig -a;route -n;"
    rm -rf $output
    bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 60
    if [ $? -gt 0 ];then
        exit 1
    fi
    perl $U_PATH_TBIN/DUTCmd.pl -o debug_info.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "cat /proc/meminfo" -v "ifconfig -a" -v "route -n" -v "arp -n" -v "ps" -v "iptables -nvL" -v "iptables -vnL -t nat" -v "cli -g InternetGatewayDevice." | tee $output
}

# main entry
$param 2> /dev/null

execute_result=$?

if [ $execute_result -eq 0 ] ;then
    if [ -f $output ] ;then
        echo "passed"
        exit 0
    else
        echo "fail, generating output file failed !"
        exit 1
    fi
elif [ $execute_result -eq 127 ] ;then
    echo "the parameter in [-v $param ] undefined"
    echo -e $usage
    exit 1
else
    echo "ERROR occured !"
    echo -e $usage
    exit 1
fi
