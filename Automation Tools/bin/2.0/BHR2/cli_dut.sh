#!/bin/bash
# Update: Add the method of getting bhr2 wireless default info(bhr2.wifi()); Date: 2011-11-09; Owner: Prince Wang

#!/bin/bash

# Author               : Alex
# Description          :
#   This tool is used to get DUT info from CLI command.
#   Update: Add the method of getting bhr2 wireless default info(bhr2.wifi()); Date: 2011-11-09; Owner: Prince Wang
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#25 Nov 2011    |   1.0.0   | Alex      | Inital Version
#     .                .         .           .   
#     .                .         .           .
#28 Dec 2011    |   1.0.4   |           |
# 4 Jan 2012    |   1.0.5   | Alex      | add error info
#16 Jan 2012    |   1.0.6   | Alex      | add function cwmp.info
#18 Jan 2012    |   1.0.7   | Alex      | modify function wan.info/line 174,get dut wan MAC
#20 Jan 2012    |   1.0.8   | Alex      | fix bug of function cwmp.info
#28 Feb 2012    |   1.0.9   | Alex      | add function wan.link and wl.mac
# 7 Mar 2012    |   1.0.10  | Prince    | add function wifi.stats
#27 Mar 2012    |   1.0.11  | Alex      | add function arp.table
# 6 Apr 2012    |   1.0.12  | Prince    | add function br0.info
#############################################################################################################################

REV="$0 version 1.0.11 (27 Mar 2012)"
# print REV
echo "${REV}"


usage="usage: bash $0 -v <Input parameter> -o <Output file> [-test]\nInput parameter:wan.info | wan.stats | wan.dns | dut.date | cwmp.info |wan.link | wl.mac | wifi.stats | wifi.info | arp.table | br0.info | layer2.stats |basic.info |debug.info"
# parse commandline
while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        U_PATH_TBIN=.
        G_CURRENTLOG=.
        G_PROD_IP_BR0_0_0=192.168.173.1
        U_DUT_TELNET_USER=admin
        U_DUT_TELNET_PWD=admin1
        #InternetGatewayDevice.WANDevice.1.WANConnectionDevice.6.WANIPConnection.1
        U_TR069_WANDEVICE_INDEX=InternetGatewayDevice.WANDevice.1
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

sys.loading(){

perl $U_PATH_TBIN/DUTCmd.pl -o dut_cpu.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT  -v "kernel meminfo" -v "kernel cpu_load_avg"
  dos2unix $G_CURRENTLOG/dut_cpu.log
  sed -i 's/KB//g' $G_CURRENTLOG/dut_cpu.log
   cat  $G_CURRENTLOG/dut_cpu.log 

   sed -i 's/kB//g' $G_CURRENTLOG/dut_cpu.log
   #m_use=`sed -i 's/KB//g' $G_CURRENTLOG/dut_cpu.log | cat $G_CURRENTLOG/dut_cpu.log | grep "Shared Memory in-use" | awk -F ":" '{ print $2}'` 
   #echo "$m_use" 
   #Shared_memory=`sed -i 's/KB//g' $G_CURRENTLOG/dut_cpu.log | cat $G_CURRENTLOG/dut_cpu.log  | grep "Total MDM Shared Memory Region" | awk -F ":" '{ print $2}' `
   #echo "ishare_1:$Shared_memory"    
   #echo "$Shared_memory" >> $G_CURRENTLOG/share_log   
   #cat $G_CURRENTLOG/share_log
   #sed -i 's/^\ //g' $G_CURRENTLOG/share_log
   #sed -i 's/[^0-9]//g' $G_CURRENTLOG/share_log
   #share=`cat $G_CURRENTLOG/share_log`
   #echo "share:$share"
   #rm -rf $G_CURRENTLOG/share_log
   #echo $m_use  >>  $G_CURRENTLOG/m_use_log
   #sed -i 's/^0*//g' $G_CURRENTLOG/m_use_log
   #sed -i 's/[^0-9]//g' $G_CURRENTLOG/m_use_log
   #muse=`cat  $G_CURRENTLOG/m_use_log`
   #rm -rf $G_CURRENTLOG/m_use_log
   #echo "muse:$muse"
   # #a=100
   # a=$muse
   # b=$share
   # #b=200
   # echo "a:$a" 
   # echo "b:$b"
   # p=$((a*100/b))
   # echo ":$p"
    #percentage=$(printf "%d%%" $((a*100/b)))
    #TMP_DUT_LOADING_SHARED_MEMORY=$p
  # av_cpu=`cat $G_CURRENTLOG/dut_cpu.log  | grep "" | awk '{ print 
   cpu=`cat $G_CURRENTLOG/dut_cpu.log  | grep "^[0-9]\{1,2\}\.[0-9]\{1,2\}" | awk '{print $1}' `
   #let av_cpu=100-$cpu
   echo "$cpu" >>$G_CURRENTLOG/cpu
   sed -i 's/[^0-9.]//g' $G_CURRENTLOG/cpu
   sed -i 's/^$//g' $G_CURRENTLOG/cpu
   sed -i 's/\^M$//g' $G_CURRENTLOG/cpu
   cat $G_CURRENTLOG/cpu
   cpu=`cat  $G_CURRENTLOG/cpu`
   rm -rf $G_CURRENTLOG/cpu
   echo "average: $cpu"
   #av_cpu=` awk 'BEGIN{printf ("%.2f",'100'-'$cpu')}'`
   av_cpu=$cpu
   echo "$av_cpu"
   #aver="$av_cpu%"
   #echo "aver:$aver" 
   #TMP_DUT_LOADING_CPU=$av_cpu
   sed -i 's/\ kB$//g' $G_CURRENTLOG/dut_cpu.log
   #cat $G_CURRENTLOG/dut_cpu.log 
   MemTotal=`cat $G_CURRENTLOG/dut_cpu.log | grep "MemTotal:" | awk -F":" '{print $2}'`
   echo "$MemTotal" >>  $G_CURRENTLOG/MemTotal
   sed -i 's/[^0-9]//g' $G_CURRENTLOG/MemTotal
   m_total=`cat $G_CURRENTLOG/MemTotal`
   echo "m_total:$m_total"
   rm -rf $G_CURRENTLOG/MemTotal
   #cat $G_CURRENTLOG/dut_cpu.log
   Memfree=`cat $G_CURRENTLOG/dut_cpu.log | grep "=" | awk -F "=" '{print $2}'` 
   echo "free:$Memfree" 
   echo "$Memfree" >> $G_CURRENTLOG/LOD
   sed -i 's/[^0-9]//g' $G_CURRENTLOG/LOD
   m=`cat $G_CURRENTLOG/LOD`
   echo "m_free:$m"
   rm -rf $G_CURRENTLOG/LOD
  # OBBuffers=`cat $G_CURRENTLOG/dut_cpu.log | grep "Buffers:" | awk -F":" '{print $2}'`
  # echo "$Buffers" >> $G_CURRENTLOG/Buffers
  # sed -i 's/[^0-9]//g' $G_CURRENTLOG/Buffers
  # m_buff=`cat $G_CURRENTLOG/Buffers`
  # echo "m_buff:$m_buff"
  # rm -rf $G_CURRENTLOG/Buffers
  # Cached=`cat $G_CURRENTLOG/dut_cpu.log | grep "Cached:" | awk -F":" '{print $2}'`
  # echo "$Cached" >> $G_CURRENTLOG/Cached
  # sed -i 's/[^0-9]//g' $G_CURRENTLOG/Cached
  # sed -i 's/$//g' $G_CURRENTLOG/Cached
  # m_cach=`cat $G_CURRENTLOG/Cached`
  # echo "m_cach:$m_cach"
  # rm -rf $G_CURRENTLOG/Cached
   #a=$m_tota
   #let m_load=$m_total-$m_free
   #echo "load:$m_load" >  $G_CURRENTLOG/tolal
   #sed -i 's/[^0-9]//g' $G_CURRENTLOG/tolal
   #m_load=`cat $G_CURRENTLOG/tolal`
   #let m_load=$m_total-$m_cach
   #rm -rf  $G_CURRENTLOG/tolal
   #echo "m_load_new: $m_load"
   let load=$m_total-$m 
   #let m_load=$m_load-$m_buff
   echo "load:$load"
   let load=$load*100/$m_total
   echo "load:$load"
   #loa=$(printf "%d%%" $load)
   #TMP_DUT_LOADING_SYSTEM_MEMORY=$load
   echo "TMP_DUT_LOADING_SYSTEM_MEMORY=$load" >> $output
   echo "TMP_DUT_LOADING_SYSTEM_MEMORY=$load"
   echo "TMP_DUT_LOADING_CPU=$av_cpu" >> $output
   echo "TMP_DUT_LOADING_CPU=$av_cpu"
   echo "TMP_DUT_LOADING_SHARED_MEMORY=0" >> $output
   echo "TMP_DUT_LOADING_SHARED_MEMORY=0"
   exit 0
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


  #### Get SSID WEP key and WPA key
  echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"conf factory open\"  -v \"conf factory print dev\" -v "net ifconfig" -o bh2_wifi_ssid.log"
  perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "conf factory open"  -v "conf factory print dev" -v "net ifconfig" -o bh2_wifi_ssid.log
  dos2unix $G_CURRENTLOG/bh2_wifi_ssid.log

  ssid=`awk 'BEGIN {FS="("} /\(wl_ssid\(/ {print $3}' $G_CURRENTLOG/bh2_wifi_ssid.log`
  wireless_ssid=${ssid%%)*}

  wep=`awk 'BEGIN {FS="("} /\(key\(/ {print $3}' $G_CURRENTLOG/bh2_wifi_ssid.log`
  wireless_wepkey=${wep%%)*}

  wpa=`awk 'BEGIN {FS="("} /\(preshared_key\(/ {print $3}' $G_CURRENTLOG/bh2_wifi_ssid.log`
  wireless_wpakey=${wpa%%)*}
  if [ -z $wireless_wpakey ];then
      wireless_wpakey=1234567890ABCDEF
  fi
  echo "U_WIRELESS_SSID1=$wireless_ssid">>$output
  echo "U_WIRELESS_WEPKEY_DEF_64=$wireless_wepkey">>$output
  echo "U_WIRELESS_CUSTOM_WEP_KEY64bit1=$wireless_wepkey">>$output
  echo "U_WIRELESS_WPAPSK1=$wireless_wpakey">>$output

  echo "get BSSID"
      wl1_mac=`cat $G_CURRENTLOG/bh2_wifi_ssid.log |grep -i "Device ath0" -A 5 |grep MAC=|sed 's/^.*MAC=//g'|sed 's/ *$//g'|tr [A-Z] [a-z]`

      echo "U_WIRELESS_BSSID1=$wl1_mac"
      echo "U_WIRELESS_BSSID2=None"

      echo "U_WIRELESS_BSSID1=$wl1_mac"    >>$output
      echo "U_WIRELESS_BSSID2=None"        >>$output

}

wan.info(){
    echo "wan.info"

    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"net main_wan\"  -v \"net route\" -o $G_CURRENTLOG/dut_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "net main_wan" -v "net route" -o dut_info.log

    dos2unix  $G_CURRENTLOG/dut_info.log
    # parse default route info 
    dut_wan_if=`grep "main wan device: " $G_CURRENTLOG/dut_info.log |awk -F ": " '{if (/main wan device/) print $2}' | grep -o "\w*"`
    dut_def_gw=`grep "$dut_wan_if" $G_CURRENTLOG/dut_info.log |awk '{if (/UG/) print $3}'`
    echo "dut_wan_if = $dut_wan_if"
    echo "dut_def_gw = $dut_def_gw"
    
    # check wan if
    if [ -z $dut_wan_if ]
    then
        echo "-| FAIL : DUT WAN IF is empty!\n"
        exit -1
    fi
    
    # check default gw
    if [ "$dut_def_gw" = "*" ]
    then
        #cmd="sed -n '/^$dut_wan_if/{n;p}' $G_CURRENTLOG/dut_info.log|awk '{print $3}'|awk -F: '{print $2}' "
        #echo "cmd = $cmd"
        #echo `sed -n '/^$dut_wan_if/{n;p}' $G_CURRENTLOG/dut_info.log `
        dut_def_gw="`sed -n "/^$dut_wan_if/{n;p}" $G_CURRENTLOG/dut_info.log |awk '{print $3}'|awk -F: '{print $2}'`"
    fi
    
    # check default gw again
    echo "dut_def_gw = $dut_def_gw"

    rc=`echo "$dut_def_gw" | grep  "\."`
#    if [ -z $rc ]
#    then
#        echo "-| FAIL : DUT default gw failed"
#        exit -1
#    fi
    
    #get wan ip
    cmd="net ifconfig $dut_wan_if"
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"$cmd\" -o WANIP.log |tee -a $G_CURRENTLOG/dut_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "$cmd" -o WANIP.log|tee -a $G_CURRENTLOG/dut_info.log

    dos2unix  $G_CURRENTLOG/dut_info.log

    # parse wan ip
    dut_wan_ip=`grep -o "ip=[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}" $G_CURRENTLOG/dut_info.log |awk -F = '{print $2}'`
    # check wan ip
    echo "dut_wan_ip = $dut_wan_ip"
    rc=`echo "$dut_wan_ip" | grep  "\."`
    if [ -z $rc ]
    then
        echo "-| FAIL : DUT WAN IP is error"
        exit -1
    fi

    # parse wan netmask
    dut_wan_mask=`grep -o "netmask=[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}" $G_CURRENTLOG/dut_info.log |awk -F = '{print $2}'`
    # check wan netmask
    echo "dut_wan_mask = $dut_wan_mask"
    rc=`echo "$dut_wan_mask" | grep  "\."`
    if [ -z $rc ]
    then
        echo "-| FAIL : DUT WAN Netmask is error"
        exit -1
    fi

    # parse wan macaddress
#    dut_wan_mac=`grep "^$dut_wan_if" $G_CURRENTLOG/dut_info.log |awk '{print $5}'`
    dut_wan_mac=`grep -o "MAC=[0-9a-zA-Z]\{1,\}:[0-9a-fA-F]\{1,\}:[0-9a-fA-F]\{1,\}:[0-9a-fA-F]\{1,\}:[0-9a-fA-F]\{1,\}:[0-9a-fA-F]\{1,\}" $G_CURRENTLOG/dut_info.log |awk -F = '{print $2}'`
    if [ -z "${dut_wan_mac}" ];then
         echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"net ifconfig eth1\" -o WANETH1IP.log|tee $G_CURRENTLOG/dut_eth1_info.log"
         perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "net ifconfig eth1" -o WANETH1IP.log|tee $G_CURRENTLOG/dut_eth1_info.log
         dut_wan_mac=`grep -o "MAC=[0-9a-zA-Z]\{1,\}:[0-9a-fA-F]\{1,\}:[0-9a-fA-F]\{1,\}:[0-9a-fA-F]\{1,\}:[0-9a-fA-F]\{1,\}:[0-9a-fA-F]\{1,\}" $G_CURRENTLOG/dut_eth1_info.log |awk -F = '{print $2}'`
    fi

    # parse IPv6 wan infomation
    # system shell
    # ip -6 a show eth1

    if [ "$dut_wan_if" ] ;then
        perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "system shell" -v "ip -6 a show $dut_wan_if" -o WAN_IPv6_info.log
        dos2unix $G_CURRENTLOG/WAN_IPv6_info.log

        dut_wan_ipv6_global=`grep -i "inet6 .*scope global" $G_CURRENTLOG/WAN_IPv6_info.log  | awk '{print $2}' | sed 's/^ *//g' | sed 's/ *$//g'`
        echo "dut_wan_ipv6_global = $dut_wan_ipv6_global"

        dut_wan_ipv6_local=`grep -i "inet6 .*scope link" $G_CURRENTLOG/WAN_IPv6_info.log  | awk '{print $2}' | sed 's/^ *//g' | sed 's/ *$//g'`
        echo "dut_wan_ipv6_local = $dut_wan_ipv6_local"
    fi

    # check wan macaddress
    echo "dut_wan_mac = $dut_wan_mac"
    
    echo "TMP_DUT_WAN_IF=$dut_wan_if" >> $output
    echo "TMP_DUT_DEF_GW=$dut_def_gw" >> $output
    echo "TMP_DUT_WAN_IP=$dut_wan_ip" >> $output
    echo "TMP_DUT_WAN_MAC=$dut_wan_mac" >> $output
    echo "TMP_DUT_WAN_MASK=$dut_wan_mask" >> $output
    echo "TMP_DUT_WAN_IPV6_LOCAL=$dut_wan_ipv6_local" >> $output
    echo "TMP_DUT_WAN_IPV6_GLOBAL=$dut_wan_ipv6_global" >> $output
}

dut.date(){
    echo "date"

    perl $U_PATH_TBIN/DUTCmd.pl -o get_dut_time.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -v "system date" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    dos2unix $G_CURRENTLOG/get_dut_time.log

    sed -i s/[[:cntrl:]]//g $G_CURRENTLOG/get_dut_time.log

    dut_date=`cat $G_CURRENTLOG/get_dut_time.log| grep 'Local time:' |sed s/"Local time:[[:space:]]*"//g`
    
    echo "U_CUSTOM_LOCALTIME=$dut_date"
    echo "U_CUSTOM_LOCALTIME=$dut_date" >> $output
}

wan.stats(){
    echo "wan.stats"

   perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "net main_wan" -v "net route" -o dut_info.log

   if [ $? -ne 0 ]; then
       echo "ERROR:execute $U_PATH_TBIN/DUTCmd.pl error!"
   fi

    dos2unix  $G_CURRENTLOG/dut_info.log
    # parse default route info 
    dut_wan_if=`grep "main wan device: " $G_CURRENTLOG/dut_info.log |awk -F ": " '{if (/main wan device/) print $2}' | grep -o "\w*"`
    
    perl $U_PATH_TBIN/DUTCmd.pl -o xdslctl.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "system shell" -v "cat /proc/net/dev" 

   if [ $? -ne 0 ]; then
       echo "ERROR:execute $U_PATH_TBIN/DUTCmd.pl error!"
   fi

    BytesSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "$dut_wan_if:" |awk -F: '{print $2}'|awk '{print $9}'`
    BytesReceived=`cat $G_CURRENTLOG/xdslctl.log    |grep "$dut_wan_if:" |awk -F: '{print $2}'|awk '{print $1}'`
    PacketsSent=`cat $G_CURRENTLOG/xdslctl.log      |grep "$dut_wan_if:" |awk -F: '{print $2}'|awk '{print $10}'`
    PacketsReceived=`cat $G_CURRENTLOG/xdslctl.log  |grep "$dut_wan_if:" |awk -F: '{print $2}'|awk '{print $2}'`

    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$BytesSent"                                  >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$BytesReceived"                          >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$PacketsSent"                              >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$PacketsReceived"                      >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.BytesSent=$BytesSent"                               >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.BytesReceived=$BytesReceived"                       >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.PacketsSent=$PacketsSent"                           >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.PacketsReceived=$PacketsReceived"                   >> $output

}

wan.dns(){
    echo "wan.dns"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "net main_wan" -v "net route" -o dut_info.log

    dos2unix  $G_CURRENTLOG/dut_info.log
    # parse default route info 
    dut_wan_if=`grep "main wan device: " $G_CURRENTLOG/dut_info.log |awk -F ": " '{if (/main wan device/) print $2}' | grep -o "\w*"`
   
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "conf print dev/$dut_wan_if" -l $G_CURRENTLOG -o DUTDNS.log
        
    #remove ^M
    dos2unix $G_CURRENTLOG/DUTDNS.log
    dns_neg=`grep "is_dns_neg" $G_CURRENTLOG/DUTDNS.log |grep -o "[01]"`

    if [ "$dns_neg" = "1" ]; then
        perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "conf ram_print dev/$dut_wan_if" -l $G_CURRENTLOG -o DUTDNS.log
    fi

    #(name_server
    # (0(168.95.1.1))
    # (1(10.20.10.10))
    #)

    DNS1=`grep -A 2 "name_server" $G_CURRENTLOG/DUTDNS.log | grep "0(.*)" | grep -o "[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}"`
    echo "TMP_DUT_WAN_DNS_1=$DNS1"
    echo "TMP_DUT_WAN_DNS_1=$DNS1" >> $output

    DNS2=`grep -A 2 "name_server" $G_CURRENTLOG/DUTDNS.log | grep "1(.*)" | grep -o "[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}"`
    echo "TMP_DUT_WAN_DNS_2=$DNS2"
    echo "TMP_DUT_WAN_DNS_2=$DNS2" >> $output
}

wan.link() {
    echo "in wan.link"
    phylink="ETH"

    echo "perl $U_PATH_TBIN/DUTCmd.pl -o tmp_get_wan_link_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"net ifconfig\""
    perl $U_PATH_TBIN/DUTCmd.pl -o tmp_get_wan_link_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "net main_wan"
    if [ $? -ne 0 ];then
        exit 1
    fi 
    dos2unix  $G_CURRENTLOG/tmp_get_wan_link_info.log
    # parse default route info 
    dut_wan_if=`grep "main wan device: " $G_CURRENTLOG/tmp_get_wan_link_info.log |awk -F ": " '{if (/main wan device/) print $2}' | grep -o "\w*"`
    echo "dut_wan_if = $dut_wan_if"
    # check wan if
    if [ -z $dut_wan_if ]
    then
        echo "-| AT_ERROR : DUT WAN IF is empty!\n"
        exit 1
    fi

    ISPflag=`echo $dut_wan_if | cut -c 1,2,3`
    echo "ISPflag=$ISPflag"
    if [ "$ISPflag" == "eth" ]; then
        isplink="IPOE"
    elif [ "$ISPflag" == "cli" ]; then
        isplink="IPOE"
    elif [ "$ISPflag" == "ppp" ]; then
        isplink="PPPOE"
    else
        isplink="NONE"
    fi

    echo "TMP_DUT_WAN_LINK=$phylink"
    echo "TMP_DUT_WAN_ISP_PROTO=$isplink"

    echo "TMP_DUT_WAN_LINK=$phylink" >$output
    echo "TMP_DUT_WAN_ISP_PROTO=$isplink" >>$output
}

cwmp.info(){
    echo "in cwmp.info"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o tmp_get_cwmp_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"conf print cwmp/conn_req_username\" -v \"password_get_unobscured cwmp/conn_req_password\" -v \"conf print cwmp/attribute/InternetGatewayDevice/ManagementServer/ConnectionRequestURL/notified_value\""
    perl $U_PATH_TBIN/DUTCmd.pl -o tmp_get_cwmp_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "conf print cwmp/conn_req_username" -v "password_get_unobscured cwmp/conn_req_password" -v "conf print cwmp/attribute/InternetGatewayDevice/ManagementServer/ConnectionRequestURL/notified_value" -v "conf print cwmp/acs_url" -v "conf print cwmp/username" -v "password_get_unobscured cwmp/password" -v "conf print cwmp/acs_url_used"

    TMP_DUT_CWMP_ACS_URL=`grep "(acs_url(" $G_CURRENTLOG/tmp_get_cwmp_info.log |sed "s/.*(//g" |sed "s/).*//g"`
    TMP_DUT_CWMP_ACS_URL_USED=`grep "(acs_url_used(" $G_CURRENTLOG/tmp_get_cwmp_info.log |sed "s/.*(//g" |sed "s/).*//g"`
    TMP_DUT_CWMP_CONN_ACS_USERNAME=`grep "(username(" $G_CURRENTLOG/tmp_get_cwmp_info.log |sed "s/.*(//g" |sed "s/).*//g"`
    TMP_DUT_CWMP_CONN_ACS_PASSWORD=`grep -A1 "password_get_unobscured cwmp/password" $G_CURRENTLOG/tmp_get_cwmp_info.log |tail -1`
    TMP_DUT_CWMP_CONN_REQ_USERNAME=`grep "(conn_req_username(" $G_CURRENTLOG/tmp_get_cwmp_info.log |sed "s/.*(//g" |sed "s/).*//g"`
    TMP_DUT_CWMP_CONN_REQ_PASSWORD=`grep -A1 "password_get_unobscured cwmp/conn_req_password" $G_CURRENTLOG/tmp_get_cwmp_info.log |tail -1`
    TMP_DUT_CWMP_CONN_REQ_URL=`grep "(notified_value(" $G_CURRENTLOG/tmp_get_cwmp_info.log | sed "s/.*(//g" | sed "s/).*//g"`

    echo "TMP_DUT_CWMP_ACS_URL=$TMP_DUT_CWMP_ACS_URL"
    echo "TMP_DUT_CWMP_ACS_URL_USED=$TMP_DUT_CWMP_ACS_URL_USED"
    echo "TMP_DUT_CWMP_CONN_ACS_USERNAME=$TMP_DUT_CWMP_CONN_ACS_USERNAME"
    echo "TMP_DUT_CWMP_CONN_ACS_PASSWORD=$TMP_DUT_CWMP_CONN_ACS_PASSWORD"
    echo "TMP_DUT_CWMP_CONN_REQ_USERNAME=$TMP_DUT_CWMP_CONN_REQ_USERNAME"
    echo "TMP_DUT_CWMP_CONN_REQ_PASSWORD=$TMP_DUT_CWMP_CONN_REQ_PASSWORD"
    echo "TMP_DUT_CWMP_CONN_REQ_URL=$TMP_DUT_CWMP_CONN_REQ_URL"

    echo "TMP_DUT_CWMP_ACS_URL=$TMP_DUT_CWMP_ACS_URL" >>$output
    echo "TMP_DUT_CWMP_ACS_URL_USED=$TMP_DUT_CWMP_ACS_URL_USED" >>$output
    echo "TMP_DUT_CWMP_CONN_ACS_USERNAME=$TMP_DUT_CWMP_CONN_ACS_USERNAME" >>$output
    echo "TMP_DUT_CWMP_CONN_ACS_PASSWORD=$TMP_DUT_CWMP_CONN_ACS_PASSWORD" >>$output
    echo "TMP_DUT_CWMP_CONN_REQ_USERNAME=$TMP_DUT_CWMP_CONN_REQ_USERNAME" >>$output
    echo "TMP_DUT_CWMP_CONN_REQ_PASSWORD=$TMP_DUT_CWMP_CONN_REQ_PASSWORD" >>$output
    echo "TMP_DUT_CWMP_CONN_REQ_URL=$TMP_DUT_CWMP_CONN_REQ_URL" >>$output   
    dos2unix  $output
}
wl.mac(){
      echo "wl.mac"
      perl $U_PATH_TBIN/DUTCmd.pl -o wlmac.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "net ifconfig"
      dos2unix $G_CURRENTLOG/wlmac.log
      wl1_mac=`cat $G_CURRENTLOG/wlmac.log |grep -i "Device ath0" -A 5 |grep MAC=|sed 's/^.*MAC=//g'|sed 's/ *$//g'`

      echo "TMP_DUT_WIRELESS_BSSID1=$wl1_mac"
      echo "TMP_DUT_WIRELESS_BSSID2=None"

      echo "TMP_DUT_WIRELESS_BSSID1=$wl1_mac"    >$output
      echo "TMP_DUT_WIRELESS_BSSID2=None"        >>$output
  }
  
wifi.stats(){
      echo "wifi.stats"
      perl $U_PATH_TBIN/DUTCmd.pl -o wifistats.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "system shell" -v "cat /proc/net/dev"
      dos2unix $G_CURRENTLOG/wifistats.log    
      TotalBytesReceived=`cat $G_CURRENTLOG/wifistats.log    |grep "ath0:" |awk -F: '{print $2}'|awk '{print $1}'`
      TotalPacketsReceived=`cat $G_CURRENTLOG/wifistats.log  |grep "ath0:" |awk -F: '{print $2}'|awk '{print $2}'`
      TotalBytesSent=`cat $G_CURRENTLOG/wifistats.log        |grep "ath0:" |awk -F: '{print $2}'|awk '{print $9}'`
      TotalPacketsSent=`cat $G_CURRENTLOG/wifistats.log      |grep "ath0:" |awk -F: '{print $2}'|awk '{print $10}'`

      echo "TotalBytesSent=$TotalBytesSent"              > $output    
      echo "TotalPacketsSent=$TotalPacketsSent"          >> $output
      echo "TotalBytesReceived=$TotalBytesReceived"      >> $output
      echo "TotalPacketsReceived=$TotalPacketsReceived"  >> $output
 } 

arp.table(){
    echo "arp.table"
    perl $U_PATH_TBIN/DUTCmd.pl -o getARPTable.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "system shell" -v "system shell" -v "arp -n"
    if [ $? != 0 ]; then
        echo "AT_ERROR : failed to execute DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/getARPTable.log
    sed -n "/\# arp \-n/,$"p $G_CURRENTLOG/getARPTable.log | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" > $G_CURRENTLOG/tmpARPTable.log

    line_index=1
    cat $G_CURRENTLOG/tmpARPTable.log | while read line
    do
        echo "U_DUT_ARP_TABLE_LINE$line_index=$line" | tee -a $output
        line_index=`echo "$line_index+1" | bc`
    done
 }

br0.info(){
      echo "get br0 info for BHR2"
      startip=Unknown
      endip=Unknown
      staticmask=Unknown
      dhcpmask=Unknown
      echo "G_CURRENTLOG=$G_CURRENTLOG"
      echo "output=$output"
      echo "perl $U_PATH_TBIN/DUTCmd.pl -o br0info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"conf print dev/br0\" -v \"system exec ifconfig\""
      perl $U_PATH_TBIN/DUTCmd.pl -o br0info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "conf print dev/br0" -v "system exec ifconfig"
      dos2unix $G_CURRENTLOG/br0info.log
      startip=`grep "^ *(start_ip" $G_CURRENTLOG/br0info.log|head -n 1|awk -F\( '{print $3}'|awk -F\) '{print $1}'`
      endip=`grep "^ *(end_ip" $G_CURRENTLOG/br0info.log|head -n 1|awk -F\( '{print $3}'|awk -F\) '{print $1}'`
      staticmask=`grep "^ *(netmask" $G_CURRENTLOG/br0info.log|head -n 1|awk -F\( '{print $3}'|awk -F\) '{print $1}'`
      dhcpmask=`grep "^ *(netmask" $G_CURRENTLOG/br0info.log|tail -n 1|awk -F\( '{print $3}'|awk -F\) '{print $1}'`
      br0mac=`grep "HWaddr" $G_CURRENTLOG/br0info.log|grep "^ *br0 "|awk '{print $5}'|tr [A-Z] [a-z]`
      #echo "G_PROD_USR0=$U_DUT_TELNET_USER">>$output
      #echo "G_PROD_PWD0=$U_DUT_TELNET_PWD">>$output
      echo "G_PROD_IP_BR0_0_0=$G_PROD_IP_BR0_0_0">>$output
      echo "G_PROD_GW_BR0_0_0=$G_PROD_IP_BR0_0_0">>$output
      echo "G_PROD_TMASK_BR0_0_0=$dhcpmask">>$output
      #echo "G_PROD_TMASK_BR0_0_0=$staticmask">>$output
      echo "G_PROD_DHCPSTART_BR0_0_0=$startip">>$output
      echo "G_PROD_DHCPEND_BR0_0_0=$endip">>$output
      echo "G_PROD_DNS1_BR0_0_0=$G_PROD_IP_BR0_0_0">>$output
      echo "G_PROD_DNS2_BR0_0_0=">>$output
      echo "G_PROD_MAC_BR0_0_0=$br0mac">>$output
 }

dev.info(){
    echo "get DUT SN,FW,ModelName,ManufacturerOUI"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"conf print manufacturer\" -v \"system ver\""
    perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "conf print manufacturer" -v "system ver" -v "net ifconfig"
    if [ $? -ne 0 ];then
        echo "AT_ERROR : perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"conf print manufacturer\" -v \"system ver\""
        exit 1
    fi
    dos2unix $G_CURRENTLOG/devinfo.log
    dut_oui=`cat $G_CURRENTLOG/devinfo.log|grep "vendor_oui"|awk -F\( '{print $3}'|awk -F\) '{print $1}'`
    dut_sn=`cat $G_CURRENTLOG/devinfo.log|grep "serial_num"|awk -F\( '{print $3}'|awk -F\) '{print $1}'`
    dut_fw=`cat $G_CURRENTLOG/devinfo.log|grep "^Version:"|awk '{print $2}'|cut -d'.' -f 6-`
    dut_type=`cat $G_CURRENTLOG/devinfo.log|grep "model_number"|awk -F\( '{print $3}'|awk -F\) '{print $1}'`
    echo "U_DUT_SN=$dut_sn" >>$output
    echo "U_DUT_MODELNAME=$dut_type" >>$output
    echo "U_DUT_SW_VERSION=$dut_fw" >>$output
    echo "U_TR069_CUSTOM_MANUFACTUREROUI=$dut_oui" >>$output
}
layer2.stats(){
    echo "Get the connection status of layer2 interface for BHR2"
    let i=1
    retry_times=1
    sleep_time=10
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o layer2_connection_status.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v \"net main_wan\" -v \"net ifconfig\""
    while true
    do
        let fail_num=0
        rm -f $G_CURRENTLOG/layer2_connection_status.log
        perl $U_PATH_TBIN/DUTCmd.pl -o layer2_connection_status.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "net main_wan" -v "net ifconfig"
        if [ $? -eq 0 ];then
            dos2unix $G_CURRENTLOG/layer2_connection_status.log
            #main_wan_device=`grep -i "^ *main *wan *device:" $G_CURRENTLOG/layer2_connection_status.log|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
            main_wan_device=`grep -i "^ *main *wan *device:" $G_CURRENTLOG/layer2_connection_status.log|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'|sed "s/[^0-9a-zA-Z.]//g"`
            echo "main_wan_device : >$main_wan_device<"
            if [ -z "${main_wan_device}" ];then
                let i=$i+1
                if [ $i -gt ${retry_times} ];then
                    echo -e "\nAT_ERROR : Get the connection status of layer2 interface FAIL!\n"
                    cat $G_CURRENTLOG/layer2_connection_status.log
                    exit 1
                fi
                echo "Get the main wan device Fail,Try $i time..."
                sleep ${sleep_time}
            fi

            grep -i -A 2 "Device ${main_wan_device}" $G_CURRENTLOG/layer2_connection_status.log
            main_wan_status=`grep -i -A 2 "Device ${main_wan_device} " $G_CURRENTLOG/layer2_connection_status.log|grep "state="|awk '{print $2}'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'|sed "s/[^0-9a-zA-Z.]//g"`
            echo "main_wan_status : >$main_wan_status<"
            if [ "${main_wan_status}" == "running" -o "${main_wan_status}" == "up" ];then
                #echo "InternetGatewayDevice.WANDevice.3.WANEthernetInterfaceConfig.Status=Up"|tee $output
                echo "ETH=Up"|tee $output
                break
            elif [ "${main_wan_status}" == "down" -o "${main_wan_status}" == "disabled" ];then
                echo "ETH=Disabled"|tee $output
                break
            else
                let i=$i+1
                if [ $i -gt ${retry_times} ];then
                    echo -e "\nAT_ERROR : Get the connection status of layer2 interface FAIL!\n"
                    #cat $G_CURRENTLOG/layer2_connection_status.log
                    exit 1
                fi
                echo "Can't judge the WANEthernetInterfaceConfig.Status!Try $i time..."
                sleep ${sleep_time}
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
    echo "get bootloader basic info for BHR2"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o basicinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"gpv InternetGatewayDevice.DeviceInfo.AdditionalHardwareVersion\" -v \"sh\" -v \"factoryctl serialnum get\" -v \"factoryctl wpakey get\" -v \"factoryctl wpspin get\" -v \"ifconfig\""
    perl $U_PATH_TBIN/DUTCmd.pl -o basicinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "system exec ifconfig" -v "conf print manufacturer/hardware/version" -v "conf print /syslog/buffers/0/max_size" -v "conf print manufacturer/hardware/serial_num" -v "password_get_unobscured admin/user/0/password" -v "conf factory open" -v "conf factory print /dev/ath0/wps_pin" -v "conf factory print /dev/ath0/wpa/preshared_key" -v "conf factory close"
    if [ $? -ne 0 ];then
        exit 1
    fi
    dos2unix $G_CURRENTLOG/basicinfo.log
    basicmac=`grep "HWaddr" $G_CURRENTLOG/basicinfo.log|grep "^ *br0 "|awk '{print $5}'|tr [A-Z] [a-z]`
    boardid=`cat $G_CURRENTLOG/basicinfo.log|grep -i -A 1 "conf print manufacturer/hardware/version"|grep "(version("|awk -F\( '{print $3}'|awk -F\) '{print $1}'|sed 's/^ *//g'|sed 's/ *$//g'`
    logsize=`cat $G_CURRENTLOG/basicinfo.log|grep -i -A 1 "conf print /syslog/buffers/0/max_size"|grep "(max_size("|awk -F\( '{print $3}'|awk -F\) '{print $1}'|sed 's/^ *//g'|sed 's/ *$//g'`
    snnum=`cat $G_CURRENTLOG/basicinfo.log|grep -i -A 1 "conf print manufacturer/hardware/serial_num"|grep "(serial_num("|awk -F\( '{print $3}'|awk -F\) '{print $1}'|sed 's/^ *//g'|sed 's/ *$//g'`
    passwd=`cat $G_CURRENTLOG/basicinfo.log|grep -i -A 1 "password_get_unobscured admin/user/0/password"|tail -n1|sed 's/^ *//g'|sed 's/ *$//g'`
    wpakey=`cat $G_CURRENTLOG/basicinfo.log|grep -i -A 1 "conf factory print /dev/ath0/wpa/preshared_key"|grep "(preshared_key("|awk -F\( '{print $3}'|awk -F\) '{print $1}'|sed 's/^ *//g'|sed 's/ *$//g'`
    wpspin=`cat $G_CURRENTLOG/basicinfo.log|grep -i -A 1 "conf factory print /dev/ath0/wps_pin"|grep "(wps_pin("|awk -F\( '{print $3}'|awk -F\) '{print $1}'|sed 's/^ *//g'|sed 's/ *$//g'`
   
    echo "BASIC_MAC=$basicmac" >$output
    echo "BOARD_ID=$boardid"   >>$output
    echo "LOG_SIZW=$logsize"   >>$output
    echo "SERIAL_NUM=$snnum"   >>$output
    echo "PASSWORD=$passwd"    >>$output
    echo "WPA_KEY=$wpakey"     >>$output
    echo "WPS_PIN=$wpspin"     >>$output
    grep "= *$" $output
    if [ $? -eq 0 ];then
        echo "AT_ERROR : NULL Value are not allowed!"
   #     #cat $output
   #     #exit 1
    fi
    cat $output
}

debug.info(){
    echo "Get debug info : ps;iptables -nvL;iptables -vnL -t nat;ifconfig -a;route -n;adslinfo;"
    rm -rf $output
    bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 60
    if [ $? -gt 0 ];then
        exit 1
    fi
    perl $U_PATH_TBIN/DUTCmd.pl -o debug_info.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "system shell" -v "ifconfig -a" -v "route -n" -v "arp -n" -v "ps" -v "cat /proc/meminfo" | tee $output
    perl $U_PATH_TBIN/clicfg.pl -d $G_PROD_IP_BR0_0_0 -i 23 -m "Wireless Broadband Router>" -v "firewall dump" -v "conf print dev" -v "conf print fw" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD | tee -a $output
}

# main entry
$param 2> /dev/null

execute_result=$?

if [ $execute_result -eq 0 ] ;then
    if [ -f $output ] ;then
        dos2unix  $output
        echo "passed"
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
