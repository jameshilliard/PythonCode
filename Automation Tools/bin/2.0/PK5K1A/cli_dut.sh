#!/bin/bash
# print version info
VER="1.0.0"
echo "$0 version : ${VER}"
echo "This scrpit is only for PK5001A!"

usage="usage: bash $0 -v <Input parameter> -o <Output file> [-test]\nInput parameter:wan.info | wan.stats | wan.dns | dut.date | wifi.info | findproc | dev.sysinfo | wifi.stats | wl.mac | wireless.conf | cwmp.info | wan.link | arp.table | br0.info | basic.info | layer2.stats | debug.info |dut.ratio"
# parse commandline
while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        U_PATH_TBIN=.
        G_CURRENTLOG=.
        G_PROD_IP_BR0_0_0=192.168.0.1
        U_DUT_TELNET_USER=root
        U_DUT_TELNET_PWD=admin
        U_DUT_TELNET_PORT=23
        #InternetGatewayDevice.WANDevice.1.WANConnectionDevice.6.WANIPConnection.1
        U_TR069_WANDEVICE_INDEX=InternetGatewayDevice.WANDevice.1
        U_WIRELESSINTERFACE=wlan6
        U_TR69_CUSTOM_PROCNAME=udhcpd
        TMP_DUT_WAN_IF=nas5
        U_TR069_CUSTOM_MANUFACTUREROUI=00247B
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
        rm -f $output
        shift 2
        ;;
    *)
        echo -e $usage
        exit 1
        ;;
    esac
done
sys.loading(){

perl $U_PATH_TBIN/DUTCmd.pl -o dut_cpu.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT  -v "mpstat -P ALL 5 1" -v "cat /proc/meminfo"
  sed -i 's/KB//g' $G_CURRENTLOG/dut_cpu.log
   cat  $G_CURRENTLOG/dut_cpu.log 

   sed -i 's/kB//g' $G_CURRENTLOG/dut_cpu.log
  # m_use=`sed -i 's/KB//g' $G_CURRENTLOG/dut_cpu.log | cat $G_CURRENTLOG/dut_cpu.log | grep "Shared Memory in-use" | awk -F ":" '{ print $2}'` 
   #echo "$m_use" 
   #Shared_memory=`sed -i 's/KB//g' $G_CURRENTLOG/dut_cpu.log | cat $G_CURRENTLOG/dut_cpu.log  | grep "Total MDM Shared Memory Region" | awk -F ":" '{ print $2}' `
   #echo "ishare_1:$Shared_memory"    
   #echo "$Shared_memory" >> $G_CURRENTLOG/share_log   
   #cat $G_CURRENTLOG/share_log
   ##sed -i 's/^\ //g' $G_CURRENTLOG/share_log
   #sed -i 's/[^0-9]//g' $G_CURRENTLOG/share_log
   #share=`cat $G_CURRENTLOG/share_log`
   #echo "share:$share"
   #rm -rf $G_CURRENTLOG/share_log
  # echo $m_use  >>  $G_CURRENTLOG/m_use_log
  # sed -i 's/^0*//g' $G_CURRENTLOG/m_use_log
  # sed -i 's/[^0-9]//g' $G_CURRENTLOG/m_use_log
  # muse=`cat  $G_CURRENTLOG/m_use_log`
  # rm -rf $G_CURRENTLOG/m_use_log
  # echo "muse:$muse"
    #a=100
  #  a=$muse
  #  b=$share
    #b=200
   # echo "a:$a" 
   # echo "b:$b"
   # p=$((a*100/b))
   # echo ":$p"
    #percentage=$(printf "%d%%" $((a*100/b)))
    #TMP_DUT_LOADING_SHARED_MEMORY=$p
  # av_cpu=`cat $G_CURRENTLOG/dut_cpu.log  | grep "" | awk '{ print 
   cpu=`cat $G_CURRENTLOG/dut_cpu.log  | grep "Average:     all" | awk '{print $11}' `
   echo "$cpu" >>$G_CURRENTLOG/cpu
   sed -i 's/[^0-9.]//g' $G_CURRENTLOG/cpu
   cat $G_CURRENTLOG/cpu
   cpu=`cat  $G_CURRENTLOG/cpu`
   rm -rf $G_CURRENTLOG/cpu 
   echo "average: $cpu"
   #aver="$av_cpu%"
   #av_cpu=$(echo "100-$cpu"|bc)
    av_cpu=` awk 'BEGIN{printf ("%.2f",'100'-'$cpu')}'`
   echo "aver:$av_cpu" 
   #TMP_DUT_LOADING_CPU=$av_cpu
   sed -i 's/\ kB$//g' $G_CURRENTLOG/dut_cpu.log
   #cat $G_CURRENTLOG/dut_cpu.log 
   MemTotal=`cat $G_CURRENTLOG/dut_cpu.log | grep "MemTotal:" | awk -F":" '{print $2}'`
   echo "$MemTotal" >>  $G_CURRENTLOG/MemTotal
   sed -i 's/[^0-9]//g' $G_CURRENTLOG/MemTotal
   m_total=`cat $G_CURRENTLOG/MemTotal`
   echo "m_total:$m_total"
   rm -rf $G_CURRENTLOG/MemTotal
   MemFree=`cat $G_CURRENTLOG/dut_cpu.log | grep "MemFree:" | awk -F":" '{print $2}'` 
   echo "$MemFree" >> $G_CURRENTLOG/MemFree
   sed -i 's/[^0-9]//g' $G_CURRENTLOG/MemFree
   m_free=`cat $G_CURRENTLOG/MemFree`
   echo "m_free:$m_free"
   rm -rf $G_CURRENTLOG/MemFree
   Buffers=`cat $G_CURRENTLOG/dut_cpu.log | grep "Buffers:" | awk -F":" '{print $2}'`
   echo "$Buffers" >> $G_CURRENTLOG/Buffers
   sed -i 's/[^0-9]//g' $G_CURRENTLOG/Buffers
   m_buff=`cat $G_CURRENTLOG/Buffers`
   echo "m_buff:$m_buff"
   rm -rf $G_CURRENTLOG/Buffers
   Cached=`cat $G_CURRENTLOG/dut_cpu.log | grep "Cached:" | awk -F":" '{print $2}'`
   echo "$Cached" >> $G_CURRENTLOG/Cached
   sed -i 's/[^0-9]//g' $G_CURRENTLOG/Cached
   sed -i 's/$//g' $G_CURRENTLOG/Cached
   m_cach=`cat $G_CURRENTLOG/Cached`
   echo "m_cach:$m_cach"
   rm -rf $G_CURRENTLOG/Cached
   #a=$m_tota
   let m_load=$m_total-$m_free
   #echo "load:$m_load" >  $G_CURRENTLOG/tolal
   #sed -i 's/[^0-9]//g' $G_CURRENTLOG/tolal
   #m_load=`cat $G_CURRENTLOG/tolal`
   let m_load=$m_load-$m_cach
   #rm -rf  $G_CURRENTLOG/tolal
   echo "m_load_new: $m_load"
   #load=`expr ($m_total) - ($m_cach)` 
   let m_load=$m_load-$m_buff
   echo "load:$m_load"
   let load=$m_load*100/$m_total
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


# cli subprocess
wan.info(){
    echo "wan.info"

    # login dut and execute cli command
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o wanInfo.tmp -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"route -n\" -v \"ifconfig\""
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o wanInfo.tmp -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "route -n" -v "ifconfig"

    dos2unix  $G_CURRENTLOG/wanInfo.tmp

    # parse default route info 
    dut_wan_if=`awk '{if (/^0.0.0.0/) print $8}' $G_CURRENTLOG/wanInfo.tmp`
    dut_def_gw=`awk '{if (/^0.0.0.0/) print $2}' $G_CURRENTLOG/wanInfo.tmp`

    if [ -z $dut_wan_if ];then
        echo "AT_ERROR : DUT WAN Interface is NONE! Please check WAN Connection!"
        exit 1
    fi
    # check default gw
    if [ "$dut_def_gw" = "*" ] ;then
        dut_def_gw="`sed -n "/^$dut_wan_if/{n;p}" $G_CURRENTLOG/wanInfo.tmp |awk '{print $3}'| awk -F: '{print $2}'`"
    fi
    
    rc=`echo "$dut_def_gw" |grep  "\."`

    if [ -z "$dut_wan_if" || -z "$rc" ] ;then
        echo "TMP_DUT_WAN_IF=" >> $output
        echo "TMP_DUT_WAN_IP=" >> $output
        echo "TMP_DUT_DEF_GW=" >> $output
        exit 0
    fi

    # parse wan ip
    dut_wan_ip="`sed -n "/^$dut_wan_if/{n;p}" $G_CURRENTLOG/wanInfo.tmp |awk '{print $2}' | awk -F: '{print $2}'`"
    
    # check wan ip
    echo "dut_wan_ip = $dut_wan_ip"
    rc=`echo "$dut_wan_ip" |grep  "\."`
    if [ -z $rc ] ;then
        echo "TMP_DUT_WAN_IP="            >> $output
    else
        echo "TMP_DUT_WAN_IP=$dut_wan_ip" >> $output
    fi

    # parse wan macaddress
    dut_wan_mac=`grep "^$dut_wan_if" $G_CURRENTLOG/wanInfo.tmp |awk '{print $5}'`
    if [ -z "${dut_wan_mac}" ];then
        dut_wan_mac=`grep -i "^ *nas2  *Link.*HWaddr" $G_CURRENTLOG/wanInfo.tmp |awk '{print $5}'|tr [A-Z] [a-z]`
        if [ -z "${dut_wan_mac}" ];then
            dut_wan_mac=`grep -i "^ *atm0  *Link.*HWaddr" $G_CURRENTLOG/wanInfo.tmp |awk '{print $5}'|tr [A-Z] [a-z]`
            if [ -z "${dut_wan_mac}" ];then
                dut_wan_mac=`grep -i "^ *ptm0  *Link.*HWaddr" $G_CURRENTLOG/wanInfo.tmp |awk '{print $5}'|tr [A-Z] [a-z]`
            fi
        fi 
    fi

    # check wan macaddress
    echo "dut_wan_mac=$dut_wan_mac"

    # parse wan mask
    dut_wan_mask="`sed -n "/^$dut_wan_if/{n;p}" $G_CURRENTLOG/wanInfo.tmp |awk '{print $4}'|awk -F: '{print $2}'`"
    # check wan mask
    echo "dut_wan_mask=$dut_wan_mask"
    
    dut_wan_ipv6=`grep -i "^ *${dut_wan_if}  *Link" $G_CURRENTLOG/wanInfo.tmp -A 5|grep -i "inet6 addr:.*Scope:Link"|awk '{print $3}'|sed 's/^ *//g'|sed 's/ *$//g'`

    dut_wan_ipv6_local=`grep -i "^ *${dut_wan_if}  *Link" $G_CURRENTLOG/wanInfo.tmp -A 5|grep -i "inet6 addr:.*Scope:Link"|awk '{print $3}'|sed 's/^ *//g'|sed 's/ *$//g'`
    echo "dut_wan_ipv6_local = $dut_wan_ipv6_local"

    dut_wan_ipv6_global=`grep -i "^ *${dut_wan_if}  *Link" $G_CURRENTLOG/wanInfo.tmp -A 5|grep -i "inet6 addr:.*Scope:Global"|awk '{print $3}'|sed 's/^ *//g'|sed 's/ *$//g'`
    echo "dut_wan_ipv6_global = $dut_wan_ipv6_global"

    # output result
    echo "TMP_DUT_WAN_IF=$dut_wan_if" >> $output
    echo "TMP_DUT_DEF_GW=$dut_def_gw" >> $output
    echo "TMP_DUT_WAN_MAC=$dut_wan_mac" >> $output
    echo "TMP_DUT_WAN_MASK=$dut_wan_mask" >> $output
    echo "TMP_DUT_WAN_IPV6_LOCAL=$dut_wan_ipv6_local" >> $output
    echo "TMP_DUT_WAN_IPV6_GLOBAL=$dut_wan_ipv6_global" >> $output
    perl $U_PATH_TBIN/DUTCmd.pl -o wan_info_iptables.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "iptables -nvL" -v "ps -aux"
}

dut.date(){
    echo "date"
    
    # login dut and execute cli command
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o dutDate.tmp -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "date"

    dos2unix $G_CURRENTLOG/dutDate.tmp

    # parse dut date
    dut_date=`grep -A 1 "date" $G_CURRENTLOG/dutDate.tmp | tail -1 |  sed 's/^ *//g'` 
    
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
    echo "TMP_DUT_WAN_IF=$TMP_DUT_WAN_IF"
    if [ -z "$TMP_DUT_WAN_IF" ];then
        perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o wanroute.log -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "route -n"
        dos2unix  $G_CURRENTLOG/wanroute.log
        # parse default route info 
        dut_wan_iface=`awk '{if (/^0.0.0.0/) print $8}' $G_CURRENTLOG/wanroute.log`
        TMP_DUT_WAN_IF=$dut_wan_iface
    fi

    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -o wanStats.tmp  -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cat /proc/net/dev" -v "adslinfo"

    dos2unix $G_CURRENTLOG/wanStats.tmp
    echo "TMP_DUT_WAN_IF=$TMP_DUT_WAN_IF"
    # parse wan stats
    # if the received Bytes' length more than 8 bit, interface field and receive bytes field will merge to one field.
    # so add code "awk -F: '{print $2}'" 
    BytesSent=`cat $G_CURRENTLOG/wanStats.tmp       |grep "$TMP_DUT_WAN_IF" |awk -F: '{print $2}' |awk '{print $9}'`
    BytesReceived=`cat $G_CURRENTLOG/wanStats.tmp   |grep "$TMP_DUT_WAN_IF" |awk -F: '{print $2}' |awk '{print $1}'`
    PacketsSent=`cat $G_CURRENTLOG/wanStats.tmp     |grep "$TMP_DUT_WAN_IF" |awk -F: '{print $2}' |awk '{print $10}'`
    PacketsReceived=`cat $G_CURRENTLOG/wanStats.tmp |grep "$TMP_DUT_WAN_IF" |awk -F: '{print $2}' |awk '{print $2}'`

    # output result
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$BytesSent"                         >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$BytesReceived"                 >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$PacketsSent"                     >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$PacketsReceived"             >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.Stats.BytesSent=$BytesSent"                           >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.Stats.BytesReceived=$BytesReceived"                   >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.Stats.PacketsSent=$PacketsSent"                       >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.Stats.PacketsReceived=$PacketsReceived"               >> $output

    DownstreamMaxRate=`cat $G_CURRENTLOG/wanStats.tmp     | grep "Maximum Attainable Data Rate"    | awk '{print $5}'`
    UpstreamMaxRate=`cat $G_CURRENTLOG/wanStats.tmp       | grep "Maximum Attainable Data Rate"    | awk '{print $7}'`
    DownstreamPower=`cat $G_CURRENTLOG/wanStats.tmp       | grep "Actual Aggregate Transmit Power" | awk '{print $5}'`
    UpstreamPower=`cat $G_CURRENTLOG/wanStats.tmp         | grep "Actual Aggregate Transmit Power" | awk '{print $7}'`
#    DownstreamAttenuation=`cat $G_CURRENTLOG/wanStats.tmp | grep "Attn(dB):" |awk '{print $2*10}'`
#    UpstreamAttenuation=`cat $G_CURRENTLOG/wanStats.tmp   | grep "Attn(dB):" |awk '{print $3*10}'`
    DownstreamNoiseMargin=`cat $G_CURRENTLOG/wanStats.tmp | grep "Signal-to-Noise Ratio Margin"    | awk '{print $4}'`
    UpstreamNoiseMargin=`cat $G_CURRENTLOG/wanStats.tmp   | grep "Signal-to-Noise Ratio Margin"    | awk '{print $6}'`
    DownstreamCurrRate=`cat $G_CURRENTLOG/wanStats.tmp    | grep "^Data Rate"                     | awk '{print $3}'`
    UpstreamCurrRate=`cat $G_CURRENTLOG/wanStats.tmp      | grep "^Data Rate"                     | awk '{print $5}'`

    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamMaxRate=$DownstreamMaxRate"                 >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamMaxRate=$UpstreamMaxRate"                     >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamPower=$DownstreamPower"                     >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamPower=$UpstreamPower"                         >> $output
#    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamAttenuation=$DownstreamAttenuation"         >> $output
#    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamAttenuation=$UpstreamAttenuation"             >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamNoiseMargin=$DownstreamNoiseMargin"         >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamNoiseMargin=$UpstreamNoiseMargin"             >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamCurrRate=$DownstreamCurrRate"               >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamCurrRate=$UpstreamCurrRate"                   >> $output

}

wan.dns(){
    echo "wan.dns"

    # login dut and execute cli command
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -o wanDns.tmp -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cat /etc/resolv.conf"

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

dev.sysinfo(){
    echo "sysinfo is begining"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"cat /proc/meminfo\" -l $G_CURRENTLOG -o sysinfo.log"
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cat /proc/meminfo" -l $G_CURRENTLOG -o sysinfo.log
        
    dos2unix $G_CURRENTLOG/sysinfo.log
    
    Total=`cat $G_CURRENTLOG/sysinfo.log | grep "MemTotal:" | awk '{print $2}'` 
    Free=`cat $G_CURRENTLOG/sysinfo.log | grep "MemFree:" | awk '{print $2}'`
    #Used=`cat $G_CURRENTLOG/sysinfo.log | grep "Buffers:" | awk '{print $3}'`
    Buffers=`cat $G_CURRENTLOG/sysinfo.log | grep "Buffers:" | awk '{print $2}'`
    MemoryUsed=`echo $Total" "$Free" "$Buffers| awk '{printf("%d",($1-$2-$3)*100/$1)}'`

    echo "InternetGatewayDevice.DeviceInfo.MemoryStatus.Total=$Total" >> $output 
    echo "InternetGatewayDevice.DeviceInfo.MemoryStatus.Free=$Free" >> $output
    echo "InternetGatewayDevice.DeviceInfo.X_${U_TR069_CUSTOM_MANUFACTUREROUI}_MemoryUsed=$MemoryUsed" >> $output
}

wifi.info(){
let i=0
let timeout=0
while true
do
    rm -f $G_CURRENTLOG/wireless_ssid_key.log
    rm -f $output
    rm -f $G_CURRENTLOG/wireless_iwconfig.log
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

    echo "=======Get wlan default settings"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"grep wl /flash/rc.conf\" -o wireless_ssid_key.log"
    perl $U_PATH_TBIN/DUTCmd.pl -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "ifconfig" -v "grep wl /flash/rc.conf" -o wireless_ssid_key.log
    
    dos2unix  $G_CURRENTLOG/wireless_ssid_key.log
       
    U_WIRELESS_SSID1_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log |grep "wlmn_0_ssid=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`
    U_WIRELESS_SSID2_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log |grep "wlmn_1_ssid=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`
    U_WIRELESS_SSID3_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log |grep "wlmn_2_ssid=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`   
    U_WIRELESS_SSID4_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log |grep "wlmn_3_ssid=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`

    U_WIRELESS_WEPKEY_DEF_64_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log | grep "wlDf_wep_64Key=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`
 
    U_WIRELESS_WEPKEY1_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log | grep "wlDf_wep_0_128Key=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`
    U_WIRELESS_WEPKEY2_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log | grep "wlDf_wep_1_128Key=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`
    U_WIRELESS_WEPKEY3_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log | grep "wlDf_wep_2_128Key=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`
    U_WIRELESS_WEPKEY4_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log | grep "wlDf_wep_3_128Key=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`
   
    U_WIRELESS_WPAPSK1_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log | grep "wlDf_psk_0=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`
    U_WIRELESS_WPAPSK2_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log | grep "wlDf_psk_1=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`
    U_WIRELESS_WPAPSK3_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log | grep "wlDf_psk_2=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`
    U_WIRELESS_WPAPSK4_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log | grep "wlDf_psk_3=" | awk -F = '{print $2}'|sed "s/^\"//g"|sed 's/\"$//g'`

    
    U_WIRELESS_BSSID1_VALUE=`cat $G_CURRENTLOG/wireless_ssid_key.log | grep "HWaddr" | grep "^wlan0 "|awk '{print $5}'|tr [A-Z] [a-z]`
    echo "U_WIRELESS_BSSID1_VALUE : $U_WIRELESS_BSSID1_VALUE"
    bssid1=`echo "$U_WIRELESS_BSSID1_VALUE"|awk -F: '{print $NF}'`
    echo "bssid1 : $bssid1"
    combssid=`echo "$U_WIRELESS_BSSID1_VALUE"|cut -d ':' -f 1-5`
    ((bssid1=0x$bssid1))
    bssid2=$(echo "${bssid1}+1"|bc)
    bssid3=$(echo "${bssid1}+2"|bc)
    bssid4=$(echo "${bssid1}+3"|bc)
    last2=$(echo "obase=16;${bssid2}"|bc)
    last3=$(echo "obase=16;${bssid3}"|bc)
    last4=$(echo "obase=16;${bssid4}"|bc)
    if [ `echo "$last2" |wc -c` -eq 2 ];then
        last2=0$last2
    fi
    if [ `echo "$last3" |wc -c` -eq 2 ];then
        last3=0$last3
    fi
    if [ `echo "$last4" |wc -c` -eq 2 ];then
        last4=0$last4
    fi
    U_WIRELESS_BSSID2_VALUE=`echo "$combssid:$last2"|tr [A-Z] [a-z]`
    U_WIRELESS_BSSID3_VALUE=`echo "$combssid:$last3"|tr [A-Z] [a-z]`
    U_WIRELESS_BSSID4_VALUE=`echo "$combssid:$last4"|tr [A-Z] [a-z]`

    echo "U_WIRELESS_SSID1=$U_WIRELESS_SSID1_VALUE"                            >> $output
    echo "U_WIRELESS_SSID2=$U_WIRELESS_SSID2_VALUE"                            >> $output
    echo "U_WIRELESS_SSID3=$U_WIRELESS_SSID3_VALUE"                            >> $output
    echo "U_WIRELESS_SSID4=$U_WIRELESS_SSID4_VALUE"                            >> $output

    echo "U_WIRELESS_WEPKEY_DEF_64=$U_WIRELESS_WEPKEY_DEF_64_VALUE"            >> $output

    echo "U_WIRELESS_WEPKEY1=$U_WIRELESS_WEPKEY1_VALUE"                        >> $output
    echo "U_WIRELESS_WEPKEY2=$U_WIRELESS_WEPKEY2_VALUE"                        >> $output
    echo "U_WIRELESS_WEPKEY3=$U_WIRELESS_WEPKEY3_VALUE"                        >> $output
    echo "U_WIRELESS_WEPKEY4=$U_WIRELESS_WEPKEY4_VALUE"                        >> $output

    echo "U_WIRELESS_WPAPSK1=$U_WIRELESS_WPAPSK1_VALUE"                        >> $output
    echo "U_WIRELESS_WPAPSK2=$U_WIRELESS_WPAPSK2_VALUE"                        >> $output
    echo "U_WIRELESS_WPAPSK3=$U_WIRELESS_WPAPSK3_VALUE"                        >> $output
    echo "U_WIRELESS_WPAPSK4=$U_WIRELESS_WPAPSK4_VALUE"                        >> $output

    echo "U_WIRELESS_BSSID1=$U_WIRELESS_BSSID1_VALUE"                         >> $output
    echo "U_WIRELESS_BSSID2=$U_WIRELESS_BSSID2_VALUE"                         >> $output
    echo "U_WIRELESS_BSSID3=$U_WIRELESS_BSSID3_VALUE"                         >> $output
    echo "U_WIRELESS_BSSID4=$U_WIRELESS_BSSID4_VALUE"                         >> $output
    cat $output
    echo "======================================================="
    grep "= *$" $output
    if [ $? -eq 0 ];then
        echo "AT_ERROE : Some variable's value is NONE!"
    else
        break
    fi
    let i=$i+1
    if [ $i -eq 10 ];then
        exit 1
    fi
    let timeout=$timeout+5
    echo "Try $i times again after $timeout seconds......"
    sleep $timeout
done
}


findproc(){
    echo "findproc"
    perl $U_PATH_TBIN/DUTCmd.pl -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "ps -aux" -o proc_info.log

    dos2unix $G_CURRENTLOG/proc_info.log
    grep -i "$U_TR69_CUSTOM_PROCNAME" $G_CURRENTLOG/proc_info.log
    if [ $? == 0 ];then
       echo "U_TR69_CUSTOM_PROCNAME=$U_TR69_CUSTOM_PROCNAME" >>$output
    else
       echo "U_TR69_CUSTOM_PROCNAME=" >>$output
    fi   
}

wifi.stats(){
    echo "wifi.stats"
    perl $U_PATH_TBIN/DUTCmd.pl -o ssid1.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cat /proc/net/dev"
    dos2unix $G_CURRENTLOG/ssid1.log    
    TotalBytesReceived=`cat $G_CURRENTLOG/ssid1.log    |grep "wlan0:" |awk -F: '{print $2}'|awk '{print $1}'`
    TotalPacketsReceived=`cat $G_CURRENTLOG/ssid1.log  |grep "wlan0:" |awk -F: '{print $2}'|awk '{print $2}'`
    TotalBytesSent=`cat $G_CURRENTLOG/ssid1.log        |grep "wlan0:" |awk -F: '{print $2}'|awk '{print $9}'`
    TotalPacketsSent=`cat $G_CURRENTLOG/ssid1.log      |grep "wlan0:" |awk -F: '{print $2}'|awk '{print $10}'`

    echo "TotalBytesSent=$TotalBytesSent"              >> $output
    echo "TotalBytesReceived=$TotalBytesReceived"      >> $output
    echo "TotalPacketsSent=$TotalPacketsSent"          >> $output
    echo "TotalPacketsReceived=$TotalPacketsReceived"  >> $output
}

wl.mac(){
   echo "wl.mac"
   perl $U_PATH_TBIN/DUTCmd.pl -o wlmac.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "ifconfig -a"
   dos2unix $G_CURRENTLOG/wlmac.log
   wl0_mac=`cat $G_CURRENTLOG/wlmac.log |grep "wlan0 " |awk '{print $5}'`
   wl01_mac=`cat $G_CURRENTLOG/wlmac.log|grep "wlan0.0"|awk '{print $5}'`
   echo "TMP_DUT_WIRELESS_BSSID1=$wl0_mac"    >>$output
   echo "TMP_DUT_WIRELESS_BSSID2=$wl01_mac"   >>$output
}

cwmp.info(){
     echo "get cwmp.info"
    
     perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o cwmpInfo.tmp -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cat /etc/rc.conf | grep mgmt_server"
     dos2unix $G_CURRENTLOG/cwmpInfo.tmp
     url=`cat $G_CURRENTLOG/cwmpInfo.tmp | grep  "mgmt_server_conrequrl" | cut -d '"' -f 2`
     username=`cat $G_CURRENTLOG/cwmpInfo.tmp | grep  "mgmt_server_conrequname" | cut -d '"' -f 2`
     password=`cat $G_CURRENTLOG/cwmpInfo.tmp | grep  "mgmt_server_conreqpasswd" | cut -d '"' -f 2`
     Acs_URL=`cat $G_CURRENTLOG/cwmpInfo.tmp |grep "mgmt_server_acsurl" |cut -d '"' -f 2 `
     Acs_username=`cat $G_CURRENTLOG/cwmpInfo.tmp |grep "mgmt_server_acsuname" |cut -d '"' -f 2 `
     Acs_password=`cat $G_CURRENTLOG/cwmpInfo.tmp |grep "mgmt_server_acspasswd" |cut -d '"' -f 2 `
     echo "TMP_DUT_CWMP_ACS_URL=$Acs_URL" >$output
     echo "TMP_DUT_CWMP_CONN_ACS_USERNAME=$Acs_username" >>$output
     echo "TMP_DUT_CWMP_CONN_ACS_PASSWORD=$Acs_password" >>$output
     echo "TMP_DUT_CWMP_CONN_REQ_USERNAME=$username"  >> $output
     echo "TMP_DUT_CWMP_CONN_REQ_PASSWORD=$password"  >> $output
     echo "TMP_DUT_CWMP_CONN_REQ_URL=$url"    >> $output
}

wireless.conf(){
    echo "grep wlan info"
        wireless_mac=`ifconfig $U_WIRELESSINTERFACE  | grep "HWaddr" | awk '{print $5}'`
        wireless_address=`ifconfig $U_WIRELESSINTERFACE | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
        echo "AssociatedDeviceMACAddress=$wireless_mac" > $output
        echo "AssociatedDeviceIPAddress=$wireless_address" >> $output
}

wan.link(){
    echo "wan.link(get wan link mode)"
    rm -rf $G_CURRENTLOG/wanlink.log
    phylink=ADSL
    isplink=Unknown
    perl $U_PATH_TBIN/DUTCmd.pl -o wanlink.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "ifconfig" -v "route -n"
    if [ $? -ne 0 ];then
        exit 1
    fi 
    dos2unix $G_CURRENTLOG/wanlink.log
    #adslflag=`grep -i "atm.*Link.*HWaddr" $G_CURRENTLOG/wanlink.log`
    #vdslflag=`grep -i "ptm.*Link.*HWaddr" $G_CURRENTLOG/wanlink.log`
    #atmipoeflag=`grep -i "default.*atm.*" $G_CURRENTLOG/wanlink.log`
    #ptmipoeflag=`grep -i "default.*ptm.*" $G_CURRENTLOG/wanlink.log`
    pppoeflag=`grep -i "0.0.0.0.*ppp.*" $G_CURRENTLOG/wanlink.log`
    #ipoeflag=`grep -i "default.*ewan.*" $G_CURRENTLOG/wanlink.log`
    l3inf=`cat $G_CURRENTLOG/wanlink.log | grep "^0.0.0.0.*"|awk '{print $NF}'`
  
    if [ "$pppoeflag" != "" ] ;then
        isplink=PPPOE
    else
        isplink=IPOE
    fi
        
    echo "TMP_DUT_WAN_LINK=$phylink" >$output
    echo "TMP_DUT_WAN_ISP_PROTO=$isplink" >>$output  
    echo "TMP_CUSTOM_WANINF=$l3inf" >>$output
  }

arp.table(){
    echo "arp.table"
    perl $U_PATH_TBIN/DUTCmd.pl -o getARPTable.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "arp -n"
    if [ $? != 0 ]; then
        echo "AT_ERROR : failed to execute DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/getARPTable.log
    sed -n "/\# arp \-n/,$"p $G_CURRENTLOG/getARPTable.log | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" > $G_CURRENTLOG/tmpARPTable.log
    rc=$?
    echo "rc=$?"
    if [ $rc == 0 ];then
        line_index=1
        cat $G_CURRENTLOG/tmpARPTable.log | while read line
        do
            echo "U_DUT_ARP_TABLE_LINE$line_index=$line" | tee -a $output
            line_index=`echo "$line_index+1" | bc`
        done
    else
        echo "Not find valid data in $G_CURRENTLOG/getARPTable.log"
        exit 1
        #cat $G_CURRENTLOG/getARPTable.log
    fi
 }

br0.info(){
      echo "get br0 info for PK5K1A"
      startip=Unknown
      endip=Unknown
      #staticmask=Unknown
      dhcpmask=Unknown
      nouter=Unknown
      br0dns1=Unknown
      br0dns2=Unknown
      lt=Unknown
      echo "G_CURRENTLOG=$G_CURRENTLOG"
      echo "output=$output"
      echo "perl $U_PATH_TBIN/DUTCmd.pl -o br0info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cat /etc/udhcpd.conf\" -v \"ifconfig\""
      perl $U_PATH_TBIN/DUTCmd.pl -o br0info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/udhcpd.conf" -v "ifconfig"
      dos2unix $G_CURRENTLOG/br0info.log
      startip=`grep "^ *start " $G_CURRENTLOG/br0info.log |awk '{print $2}'`
      endip=`grep "^ *end " $G_CURRENTLOG/br0info.log |awk '{print $2}'`
      #staticmask=`grep "^ *option subnet " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      dhcpmask=`grep "^ *option subnet " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      router=`grep "^ *option router " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      br0dns1=`grep "^ *option dns " $G_CURRENTLOG/br0info.log |awk '{print $3}' | awk -F, '{print $1}'`
      br0dns2=`grep "^ *option dns " $G_CURRENTLOG/br0info.log |awk '{print $3}' | awk -F, '{print $2}'`
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

get_pfo_index(){
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o pfo_index_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cat /etc/rc.conf\""
perl $U_PATH_TBIN/DUTCmd.pl -o pfo_index_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep PFD /etc/rc.conf"
dos2unix $G_CURRENTLOG/pfo_index_info.log
let index_count=`grep "^ *PFD_Count=" $G_CURRENTLOG/pfo_index_info.log|awk -F= '{print $2}'|sed 's/\"//g'`
echo "index_count=$index_count"
let index_num=`grep "^ *PFD_STATUS[0-9][0-9]*=\"1\"" $G_CURRENTLOG/pfo_index_info.log|wc -l`
echo "index_num=$index_num"
if [ "$index_count" == "0" || ${index_num}=="" ];then
    echo "Not exist PFO rules" && exit 1
elif [ "$index_count" != "$index_num" ];then
    echo "PFO index count not match the actual rule numbers!!!" && exit 1
fi
index_str=
for i in `cat $G_CURRENTLOG/pfo_index_info.log|grep "^ *PFD_STATUS[0-9][0-9]*=\"1\""`
do
    cur_index=`echo $i|awk -F= '{print $1}'|sed 's/PFD_STATUS//g'`
    index_str="${index_str}${cur_index},"
done
index_str=`echo "${index_str}"|sed 's/,$//'`
echo "PFO_RULE_INDEX=$index_str">$output
}

dev.info(){
    echo "get DUT SN,FW,ModelName,ManufacturerOUI"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cat /etc/ver.dat\" -v \"grep hostmap_0_devicename /etc/rc.conf\""
    perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/ver.dat" -v "uboot_env --get --name MANUSN" -v "grep hostmap_0_devicename /etc/rc.conf" -v "ifconfig"
    if [ $? -ne 0 ];then
        echo "AT_ERROR : perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cat /etc/ver.dat\" -v \"grep hostmap_0_devicename /etc/rc.conf\""
        exit 1
    fi
    dos2unix $G_CURRENTLOG/devinfo.log
    #dut_oui=`cat $G_CURRENTLOG/devinfo.log|grep "InternetGatewayDevice.DeviceInfo.ManufacturerOUI"|awk -F= '{print $2}'`
    dut_fw=`cat $G_CURRENTLOG/devinfo.log|grep -A1 'cat /etc/ver.dat'|tail -1`
    dut_sn=`cat $G_CURRENTLOG/devinfo.log|grep -A1 'uboot_env --get --name MANUSN'|tail -1`
    dut_type=`cat $G_CURRENTLOG/devinfo.log|grep -A1 'grep hostmap_0_devicename /etc/rc.conf'|tail -1|awk -F= '{print $2}'|sed 's/^" *//g'|sed 's/" *$//g'`
    #dut_type=`cat $G_CURRENTLOG/devinfo.log|grep "InternetGatewayDevice.DeviceInfo.ModelName"|awk -F= '{print $2}'`
    echo "U_DUT_SN=$dut_sn" >>$output
    echo "U_DUT_MODELNAME=$dut_type" >>$output
    echo "U_DUT_SW_VERSION=$dut_fw" >>$output
    #echo "U_TR069_CUSTOM_MANUFACTUREROUI=$dut_oui" >>$output
    cat $output
}

rebootDUT(){
    i=1
    echo "reboot DUT by telnet"
    while true
    do
        echo "perl $U_PATH_TBIN/DUTCmd.pl -o reboot_DUT.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v \"reboot\""
        perl $U_PATH_TBIN/DUTCmd.pl -o reboot_DUT.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "reboot"
        if [ $? -eq 0 ];then
            echo "DUT begin to reboot,Please Wait..."
            echo "TMP_DUT_REBOOT_RESULT=0" >$output
            break
        else
            let i=$i+1                 
            if [ $i -eq 4 ];then
                echo "function rebootDUT() run Fail"
                echo "TMP_DUT_REBOOT_RESULT=1" >$output
                exit 1
            fi
            echo "function rebootDUT() FAIL,Try $i Time..."
            sleep 10
        fi
    done
}

restoreDUT(){
    i=1
    echo "restore default DUT by telnet"
    while true
    do
        echo "perl $U_PATH_TBIN/DUTCmd.pl -o restoredefault_DUT.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -t 20 -v \"factorycfg.sh\""
        perl $U_PATH_TBIN/DUTCmd.pl -o restoredefault_DUT.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -t 20 -v "factorycfg.sh"
        grep -i "Restore *to *default *here" $G_CURRENTLOG/restoredefault_DUT.log
        #$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/restoredefault.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 --timeout=30 -v "factorycfg.sh"
        if [ $? -eq 0 ];then
            echo "DUT begin to restore default,Please Wait..."
            echo "TMP_DUT_RESTORE_RESULT=0" >$output
            break
        else
            let i=$i+1                 
            if [ $i -eq 4 ];then
                echo "function restoreDUT() run Fail"
                echo "TMP_DUT_RESTORE_RESULT=1" >$output
                exit 1
            fi
            echo "function restoreDUT() FAIL,Try $i Time..."
            sleep 10
        fi
    done
}

basic.info(){
    echo "get bootloader basic info for PK5K1A"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o basicinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"uboot_env --get --name MANUSN\" -v \"uboot_env --get --name ethaddr\" -v \"uboot_env --get --name WPAKEY\" -v \"uboot_env --get --name WPS_AP_PIN\" -v \"uboot_env --get --name HWRevision\" -v \"uboot_env --get --name PASSWORD\" -v \"uboot_env --get --name phym\""
    perl $U_PATH_TBIN/DUTCmd.pl -o basicinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "uboot_env --get --name MANUSN" -v "uboot_env --get --name ethaddr" -v "uboot_env --get --name WPAKEY" -v "uboot_env --get --name WPS_AP_PIN" -v "uboot_env --get --name HWRevision" -v "uboot_env --get --name PASSWORD" -v "uboot_env --get --name phym"
    if [ $? -ne 0 ];then
        exit 1
    fi
    dos2unix $G_CURRENTLOG/basicinfo.log
    boardid=`cat $G_CURRENTLOG/basicinfo.log|grep -A1 'uboot_env --get --name HWRevision'|tail -1|sed 's/^ *//g'|sed 's/ *$//g'`
    snnum=`cat $G_CURRENTLOG/basicinfo.log|grep -A1 'uboot_env --get --name MANUSN'|tail -1|sed 's/^ *//g'|sed 's/ *$//g'`
    wpakey=`cat $G_CURRENTLOG/basicinfo.log|grep -A1 'uboot_env --get --name WPAKEY'|tail -1|sed 's/^ *//g'|sed 's/ *$//g'`
    wpspin=`cat $G_CURRENTLOG/basicinfo.log|grep -A1 'uboot_env --get --name WPS_AP_PIN'|tail -1|sed 's/^ *//g'|sed 's/ *$//g'`
    basicmac=`cat $G_CURRENTLOG/basicinfo.log|grep -A1 'uboot_env --get --name ethaddr'|tail -1|sed 's/^ *//g'|sed 's/ *$//g'`
    passwd=`cat $G_CURRENTLOG/basicinfo.log|grep -A1 'uboot_env --get --name PASSWORD'|tail -1|sed 's/^ *//g'|sed 's/ *$//g'`
    logsize=`cat $G_CURRENTLOG/basicinfo.log|grep -A1 'uboot_env --get --name phym'|tail -1|sed 's/^ *//g'|sed 's/ *$//g'`
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

layer2.stats(){
    echo "Get the connection status of layer2 interface for PK5K1A"
    let i=1
    retry_times=5
    sleep_time=10
    while true
    do
         rm -f $G_CURRENTLOG/layer2_connection_status.log
         perl $U_PATH_TBIN/DUTCmd.pl -o layer2_connection_status.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "adslinfo"
         if [ $? -eq 0 ];then
             dos2unix $G_CURRENTLOG/layer2_connection_status.log
             grep -i "Modem Status *SHOWTIME,SYNC" $G_CURRENTLOG/layer2_connection_status.log
             if [ $? -eq 0 ];then
                 echo "ADSL=Up"         |tee   $output
             else
                 echo "ADSL=Disabled"   |tee   $output
             fi
             echo "ADSL2=Disabled"|tee -a $output
             echo "ADSL_BONDING=0"|tee -a $output
             break
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

debug.info(){
    echo "Get debug info : ps;iptables -nvL;iptables -vnL -t nat;ifconfig -a;route -n;adslinfo;"
    rm -rf $output
    bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 60
    if [ $? -gt 0 ];then
        exit 1
    fi
    #perl $U_PATH_TBIN/DUTCmd.pl -o debug_info.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "ifconfig -a" -v "route -n" -v "arp -n" -v "iptables -nvL" -v "iptables -nvL -t nat" -v "ps -aux" -v "adslinfo" -v "cat /proc/meminfo" | tee $output
    perl $U_PATH_TBIN/clicfg.pl -d $G_PROD_IP_BR0_0_0 -i 23 -m "~#" -v "cat /etc/rc.conf" -v "cat /tmp/system_status" -v "ifconfig -a" -v "route -n" -v "arp -n" -v "iptables -nvL" -v "iptables -nvL -t nat" -v "ps -aux" -v "adslinfo" -v "cat /proc/meminfo" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD | tee $output

}

dut.ratio(){
    echo "dut.ratio"
    rm -f $G_CURRENTLOG/Line_xdslctl.log
    perl $U_PATH_TBIN/DUTCmd.pl -o Line_xdslctl.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT  -v "adslinfo"
    dos2unix  $G_CURRENTLOG/Line_xdslctl.log
    Line1UpstreamCurrRate=`cat $G_CURRENTLOG/Line_xdslctl.log      |grep "^ *Data Rate " |awk '{print $5}'`

    Line1DownstreamCurrRate=`cat $G_CURRENTLOG/Line_xdslctl.log    |grep "^ *Data Rate " |awk '{print $3}'`
    #Line1CRCErrorsNearEnd=`cat $G_CURRENTLOG/Line_xdslctl.log |grep -A 3 "Total time"|grep "CRC:"|sed -n '1p'|awk -F: '{print $2}'|awk '{print $1}'`
    #Line1CRCErrorsFarEnd=`cat $G_CURRENTLOG/Line_xdslctl.log |grep -A 3 "Total time"|grep "CRC:"|sed -n '1p'|awk -F: '{print $2}'|awk '{print $2}'`
    #Line2CRCErrorsNearEnd=`cat $G_CURRENTLOG/Line_xdslctl.log |grep -A 3 "Total time"|grep "CRC:"|sed -n '2p'|awk -F: '{print $2}'|awk '{print $1}'`
    #Line2CRCErrorsFarEnd=`cat $G_CURRENTLOG/Line_xdslctl.log |grep -A 3 "Total time"|grep "CRC:"|sed -n '2p'|awk -F: '{print $2}'|awk '{print $2}'`

    #Line1FECNearEnd=`cat $G_CURRENTLOG/Line_xdslctl.log |grep -A 3 "Total time"|grep "FEC:"|sed -n '1p'|awk -F: '{print $2}'|awk '{print $1}'`
    #Line1FECFarEnd=`cat $G_CURRENTLOG/Line_xdslctl.log |grep -A 3 "Total time"|grep "FEC:"|sed -n '1p'|awk -F: '{print $2}'|awk '{print $2}'`
    #Line2FECNearEnd=`cat $G_CURRENTLOG/Line_xdslctl.log |grep -A 3 "Total time"|grep "FEC:"|sed -n '2p'|awk -F: '{print $2}'|awk '{print $1}'`
    #Line2FECFarEnd=`cat $G_CURRENTLOG/Line_xdslctl.log |grep -A 3 "Total time"|grep "FEC:"|sed -n '2p'|awk -F: '{print $2}'|awk '{print $2}'`

    #Line1DOWNSNR=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "SNR (dB):"|sed -n '1p'|awk -F: '{print $2}'|awk '{print $1}'`
    #Line1UPSNR=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "SNR (dB):"|sed -n '1p'|awk -F: '{print $2}'|awk '{print $2}'`
    #Line2DOWNSNR=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "SNR (dB):"|sed -n '2p'|awk -F: '{print $2}'|awk '{print $1}'`
    #Line2UPSNR=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "SNR (dB):"|sed -n '2p'|awk -F: '{print $2}'|awk '{print $2}'`

    #Line1DOWNAttn=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "Attn(dB):"|sed -n '1p'|awk -F: '{print $2}'|awk '{print $1}'`
    #Line1UPAttn=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "Attn(dB):"|sed -n '1p'|awk -F: '{print $2}'|awk '{print $2}'`
    #Line2DOWNAttn=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "Attn(dB):"|sed -n '2p'|awk -F: '{print $2}'|awk '{print $1}'`
    #Line2UPAttn=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "Attn(dB):"|sed -n '2p'|awk -F: '{print $2}'|awk '{print $2}'`

    #Line1DOWNPower=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "Pwr(dBm):"|sed -n '1p'|awk -F: '{print $2}'|awk '{print $1}'`
    #Line1UPPower=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "Pwr(dBm):"|sed -n '1p'|awk -F: '{print $2}'|awk '{print $2}'`
    #Line2DOWNPower=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "Pwr(dBm):"|sed -n '2p'|awk -F: '{print $2}'|awk '{print $1}'`
    #Line2UPPower=`cat $G_CURRENTLOG/Line_xdslctl.log |grep "Pwr(dBm):"|sed -n '2p'|awk -F: '{print $2}'|awk '{print $2}'`

    # perl $U_PATH_TBIN/DUTCmd.pl -o Line2_xdslctl.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT  -v "xdslctl1 info --show"
    #dos2unix  $G_CURRENTLOG/Line2_xdslctl.log
    #Line2UpstreamCurrRate=`cat $G_CURRENTLOG/Line_xdslctl.log      |grep "Bearer: 0" |sed -n '2p'|awk -F , '{print $2}' |awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`

    #Line2DownstreamCurrRate=`cat $G_CURRENTLOG/Line_xdslctl.log    |grep "Bearer: 0" |sed -n '2p'|awk -F , '{print $3}' |awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    
    if [ -z $Line1UpstreamCurrRate ];then
        echo TMP_DUT_LINE1_UP_STREAM=0>$output
    else
        echo TMP_DUT_LINE1_UP_STREAM=$Line1UpstreamCurrRate>$output
    fi
    if [ -z $Line1DownstreamCurrRate ];then
        echo TMP_DUT_LINE1_DOWN_STREAM=0>>$output
    else
        echo TMP_DUT_LINE1_DOWN_STREAM=$Line1DownstreamCurrRate>>$output
    fi

    #echo TMP_DUT_LINE1_CRC_NEAR_END=$Line1CRCErrorsNearEnd >>$output
    #echo TMP_DUT_LINE1_CRC_FAR_END=$Line1CRCErrorsFarEnd >>$output   
    #echo TMP_DUT_LINE1_FEC_NEAR_END=$Line1FECNearEnd >>$output
    #echo TMP_DUT_LINE1_FEC_FAR_END=$Line1FECFarEnd >>$output
    # echo TMP_DUT_LINE1_DOWN_SNR=$Line1DOWNSNR>>$output
    #echo TMP_DUT_LINE1_UP_SNR=$Line1UPSNR>>$output  
    #echo TMP_DUT_LINE1_DOWN_ATTN=$Line1DOWNAttn>>$output
    #echo TMP_DUT_LINE1_UP_ATTN=$Line1UPAttn>>$output   
    #echo TMP_DUT_LINE1_DOWN_POWER=$Line1DOWNPower>>$output
    #echo TMP_DUT_LINE1_UP_POWER=$Line1UPPower>>$output
    
    #if [ -z $Line2UpstreamCurrRate ];then
    #    echo TMP_DUT_LINE2_UP_STREAM=0>>$output
    #else
    #    echo TMP_DUT_LINE2_UP_STREAM=$Line2UpstreamCurrRate>>$output
    #fi
    #if [ -z $Line2DownstreamCurrRate ];then
    #    echo TMP_DUT_LINE2_DOWN_STREAM=0>>$output
    #else
    #    echo TMP_DUT_LINE2_DOWN_STREAM=$Line2DownstreamCurrRate>>$output
    #fi
    #echo TMP_DUT_LINE2_CRC_NEAR_END=$Line2CRCErrorsNearEnd >>$output
    #echo TMP_DUT_LINE2_CRC_FAR_END=$Line2CRCErrorsFarEnd >>$output
    #echo TMP_DUT_LINE2_FEC_NEAR_END=$Line2FECNearEnd >>$output
    #echo TMP_DUT_LINE2_FEC_FAR_END=$Line2FECFarEnd >>$output
    #echo TMP_DUT_LINE2_DOWN_SNR=$Line2DOWNSNR>>$output
    #echo TMP_DUT_LINE2_UP_SNR=$Line2UPSNR>>$output
    #echo TMP_DUT_LINE2_DOWN_ATTN=$Line2DOWNAttn>>$output
    #echo TMP_DUT_LINE2_UP_ATTN=$Line2UPAttn>>$output
    #echo TMP_DUT_LINE2_DOWN_POWER=$Line2DOWNPower>>$output
    #echo TMP_DUT_LINE2_UP_POWER=$Line2UPPower>>$output    
    cat $output
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
