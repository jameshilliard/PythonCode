#!/bin/bash
# print version info
VER="1.0.0"
echo "$0 version : ${VER}"

usage="usage: bash $0 -v <Input parameter> -o <Output file> [-test]\nInput parameter:wan.info | wan.stats | wan.dns | dut.date | wifi.info | findproc | dev.sysinfo | wifi.stats | wl.mac | wireless.conf | cwmp.info | wan.link | arp.table | br0.info | rebootDUT | restoreDUT | layer2.stats | basic.info "
# parse commandline
while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        U_PATH_TBIN=.
        G_CURRENTLOG=.
        G_PROD_IP_BR0_0_0=192.168.2.1
        U_DUT_TELNET_USER=admin
        U_DUT_TELNET_PWD=admin1
        #InternetGatewayDevice.WANDevice.1.WANConnectionDevice.6.WANIPConnection.1
        U_TR069_WANDEVICE_INDEX=InternetGatewayDevice.WANDevice.1
        U_TR069_CUSTOM_MANUFACTUREROUI=00247B
        U_TR69_CUSTOM_PROCNAME=ssk
        U_WIRELESSINTERFACE=wlan6
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
sys.loading(){

perl $U_PATH_TBIN/DUTCmd.pl -o dut_cpu.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT  -v "meminfo" -v "sh" -v "mpstat -P ALL 5 1" -v "cat /proc/meminfo"
  sed -i 's/KB//g' $G_CURRENTLOG/dut_cpu.log
   cat  $G_CURRENTLOG/dut_cpu.log 

   sed -i 's/kB//g' $G_CURRENTLOG/dut_cpu.log
   m_use=`sed -i 's/KB//g' $G_CURRENTLOG/dut_cpu.log | cat $G_CURRENTLOG/dut_cpu.log | grep "Shared Memory in-use" | awk -F ":" '{ print $2}'` 
   echo "$m_use" 
   Shared_memory=`sed -i 's/KB//g' $G_CURRENTLOG/dut_cpu.log | cat $G_CURRENTLOG/dut_cpu.log  | grep "Total MDM Shared Memory Region" | awk -F ":" '{ print $2}' `
   echo "ishare_1:$Shared_memory"    
   echo "$Shared_memory" >> $G_CURRENTLOG/share_log   
   cat $G_CURRENTLOG/share_log
   #sed -i 's/^\ //g' $G_CURRENTLOG/share_log
   sed -i 's/[^0-9]//g' $G_CURRENTLOG/share_log
   share=`cat $G_CURRENTLOG/share_log`
   echo "share:$share"
   rm -rf $G_CURRENTLOG/share_log
   echo $m_use  >>  $G_CURRENTLOG/m_use_log
   sed -i 's/^0*//g' $G_CURRENTLOG/m_use_log
   sed -i 's/[^0-9]//g' $G_CURRENTLOG/m_use_log
   muse=`cat  $G_CURRENTLOG/m_use_log`
   rm -rf $G_CURRENTLOG/m_use_log
   echo "muse:$muse"
    #a=100
    a=$muse
    b=$share
    #b=200
    echo "a:$a" 
    echo "b:$b"
    p=$((a*100/b))
    echo ":$p"
    #percentage=$(printf "%d%%" $((a*100/b)))
    #TMP_DUT_LOADING_SHARED_MEMORY=$p
  # av_cpu=`cat $G_CURRENTLOG/dut_cpu.log  | grep "" | awk '{ print 
   cpu=`cat $G_CURRENTLOG/dut_cpu.log  | grep "Average:     all" | awk '{print $11}' `
   #let av_cpu=100-$cpu
   echo "$cpu" >>$G_CURRENTLOG/cpu
   sed -i 's/[^0-9.]//g' $G_CURRENTLOG/cpu
   cat $G_CURRENTLOG/cpu
   cpu=`cat  $G_CURRENTLOG/cpu`
   rm -rf $G_CURRENTLOG/cpu
   echo "average: $cpu"
   av_cpu=` awk 'BEGIN{printf ("%.2f",'100'-'$cpu')}'`
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
   echo "TMP_DUT_LOADING_SHARED_MEMORY=$p" >> $output
   echo "TMP_DUT_LOADING_SHARED_MEMORY=$p"
   exit 0
             }



wan.info(){
    echo "wan.info"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o dut_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"route show\" -v \"ifconfig\""
    perl $U_PATH_TBIN/DUTCmd.pl -o dut_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "route show" -v "ifconfig"

    dos2unix  $G_CURRENTLOG/dut_info.log
    # parse default route info 
    dut_wan_if=`awk '{if (/^ *default /) print $8}' $G_CURRENTLOG/dut_info.log`
    dut_def_gw=`awk '{if (/^ *default /) print $2}' $G_CURRENTLOG/dut_info.log`

    #echo "dut_wan_if = $dut_wan_if"
    #echo "dut_def_gw = $dut_def_gw"
    
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
    if [ -z $rc ]
    then
        echo "-| FAIL : DUT default gw failed"
        exit -1
    fi
    
    # parse wan ip
    dut_wan_ip="`sed -n "/^$dut_wan_if/{n;p}" $G_CURRENTLOG/dut_info.log |awk '{print $2}'|awk -F: '{print $2}'`"
    # check wan ip
    echo "dut_wan_ip = $dut_wan_ip"
    rc=`echo "$dut_wan_ip" | grep  "\."`
    if [ -z $rc ]
    then
        echo "-| FAIL : DUT WAN IP is error"
        exit -1
    fi

    # parse wan macaddress
    dut_wan_mac=`grep "^$dut_wan_if" $G_CURRENTLOG/dut_info.log |awk '{print $5}'|tr [A-Z] [a-z]`
    if [ -z "${dut_wan_mac}" ];then
        dut_wan_mac=`grep -i "^ *ewan0\.1  *Link.*HWaddr" $G_CURRENTLOG/dut_info.log |awk '{print $5}'|tr [A-Z] [a-z]`
        if [ -z "${dut_wan_mac}" ];then
            dut_wan_mac=`grep -i "^ *atm0  *Link.*HWaddr" $G_CURRENTLOG/dut_info.log |awk '{print $5}'|tr [A-Z] [a-z]`
            if [ -z "${dut_wan_mac}" ];then
                dut_wan_mac=`grep -i "^ *ptm0  *Link.*HWaddr" $G_CURRENTLOG/dut_info.log |awk '{print $5}'|tr [A-Z] [a-z]`
            fi
        fi 
    fi
    # check wan macaddress
    echo "dut_wan_mac = $dut_wan_mac"

    # parse wan mask
    dut_wan_mask="`sed -n "/^$dut_wan_if/{n;p}" $G_CURRENTLOG/dut_info.log |awk '{print $4}'|awk -F: '{print $2}'`"
    # check wan mask
    echo "dut_wan_mask=$dut_wan_mask"
    
    echo "TMP_DUT_WAN_IF=$dut_wan_if" >> $output
    echo "TMP_DUT_DEF_GW=$dut_def_gw" >> $output
    echo "TMP_DUT_WAN_IP=$dut_wan_ip" >> $output
    echo "TMP_DUT_WAN_MAC=$dut_wan_mac" >> $output
    echo "TMP_DUT_WAN_MASK=$dut_wan_mask" >> $output
    perl $U_PATH_TBIN/DUTCmd.pl -o wan_info_iptables.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "iptables -nvL" -v "ps"
}

dut.date(){
    echo "date"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o dut_time.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"sh\" -v \"date\" | grep -A 1 '# date'| tail -1"
    dut_date=`perl $U_PATH_TBIN/DUTCmd.pl -o dut_time.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "date" | grep -A 1 '# date'| tail -1`
    
    echo "U_CUSTOM_LOCALTIME=$dut_date" >> $output
}

wan.stats(){

    # $U_TR069_WANDEVICE_INDEX means InternetGatewayDevice.WANDevice.1 or 2 3 
    echo "wan.stats"
    #G_CURRENTLOG=/root/automation/bin/2.0/Q2KH
    #perl  DUTCmd.pl -o xdslctl.log -l /root/automation/bin/2.0/Q2KH/ -d 192.168.0.1 -u admin -p QwestM0dem -v "cat /proc/net/dev" -v "xdslctl info --show"

       
    perl $U_PATH_TBIN/DUTCmd.pl -o xdslctl.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cat /proc/net/dev" -v "xdslctl info --show"

    #perl $U_PATH_TBIN/DUTCmd.pl -o xdslctl_info_show.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "xdslctl info --show"

    #perl $U_PATH_TBIN/DUTCmd.pl -o xdslctl_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "xdslctl info"
    

    ErrorsSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $11}'`
    ErrorsReceived=`cat $G_CURRENTLOG/xdslctl.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $3}'`
    UnicastPacketsSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $10}'`
    UnicastPacketsReceived=`cat $G_CURRENTLOG/xdslctl.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $2}'`
    DiscardPacketsSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $12}'`
    DiscardPacketsReceived=`cat $G_CURRENTLOG/xdslctl.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $4}'`
    MulticastPacketsSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $16}'`
    MulticastPacketsReceived=`cat $G_CURRENTLOG/xdslctl.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $8}'`

    BroadcastPacketsSent=
    BroadcastPacketsReceived=
    UnknownProtoPacketsReceived=
   #gpv InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.Stats. have  but  cat /proc/net/dev not have
   # BroadcastPacketsSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $3}'`
   # BroadcastPacketsReceived=`cat $G_CURRENTLOG/xdslctl.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $3}'`
   # UnknownProtoPacketsReceived=`cat $G_CURRENTLOG/xdslctl.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $3}'`
    echo "connection type : WAN EthernetInterfaceConfig"
    BytesSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "ewan0.1:" |awk -F: '{print $2}'|awk '{print $9}'`
    BytesReceived=`cat $G_CURRENTLOG/xdslctl.log    |grep "ewan0.1:" |awk -F: '{print $2}'|awk '{print $1}'`
    PacketsSent=`cat $G_CURRENTLOG/xdslctl.log      |grep "ewan0.1:" |awk -F: '{print $2}'|awk '{print $10}'`
    PacketsReceived=`cat $G_CURRENTLOG/xdslctl.log  |grep "ewan0.1:" |awk -F: '{print $2}'|awk '{print $2}'`

    if [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.3" ] ;then
        echo "connection type : WAN ETHERNET"
        TotalBytesSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "ewan0.1:" |awk -F: '{print $2}'|awk '{print $9}'`
        TotalBytesReceived=`cat $G_CURRENTLOG/xdslctl.log    |grep "ewan0.1:" |awk -F: '{print $2}'|awk '{print $1}'`
        TotalPacketsSent=`cat $G_CURRENTLOG/xdslctl.log      |grep "ewan0.1:" |awk -F: '{print $2}'|awk '{print $10}'`
        TotalPacketsReceived=`cat $G_CURRENTLOG/xdslctl.log  |grep "ewan0.1:" |awk -F: '{print $2}'|awk '{print $2}'`
    elif [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.2" ] ;then
        echo "connection type : VDSL"
        TotalBytesSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "ptm0.1:" |awk -F: '{print $2}'|awk '{print $9}'`
        TotalBytesReceived=`cat $G_CURRENTLOG/xdslctl.log    |grep "ptm0.1:" |awk -F: '{print $2}'|awk '{print $1}'`
        TotalPacketsSent=`cat $G_CURRENTLOG/xdslctl.log      |grep "ptm0.1:" |awk -F: '{print $2}'|awk '{print $10}'`
        TotalPacketsReceived=`cat $G_CURRENTLOG/xdslctl.log  |grep "ptm0.1:" |awk -F: '{print $2}'|awk '{print $2}'` 
 
    elif [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.1" ] ;then
        echo "connection type : ADSL"
        TotalBytesSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "atm0:" |awk -F: '{print $2}'|awk '{print $9}'`
        TotalBytesReceived=`cat $G_CURRENTLOG/xdslctl.log    |grep "atm0:" |awk -F: '{print $2}'|awk '{print $1}'`
        TotalPacketsSent=`cat $G_CURRENTLOG/xdslctl.log      |grep "atm0:" |awk -F: '{print $2}'|awk '{print $10}'`
        TotalPacketsReceived=`cat $G_CURRENTLOG/xdslctl.log  |grep "atm0:" |awk -F: '{print $2}'|awk '{print $2}'`

    elif [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.12" ] ;then
        echo "connection type : ADSL"
        TotalBytesSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "atm0:" |awk -F: '{print $2}'|awk '{print $9}'`
        TotalBytesReceived=`cat $G_CURRENTL/OG/xdslctl.log    |grep "atm0:" |awk -F: '{print $2}'|awk '{print $1}'`
        TotalPacketsSent=`cat $G_CURRENTLOG/xdslctl.log      |grep "atm0:" |awk -F: '{print $2}'|awk '{print $10}'`
        TotalPacketsReceived=`cat $G_CURRENTLOG/xdslctl.log  |grep "atm0:" |awk -F: '{print $2}'|awk '{print $2}'`
    elif [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.13" ] ; then
        echo "connection type : VDSL"
        TotalBytesSent=`cat $G_CURRENTLOG/xdslctl.log        |grep "ptm0.1:" |awk -F: '{print $2}'|awk '{print $9}'`
        TotalBytesReceived=`cat $G_CURRENTLOG/xdslctl.log    |grep "ptm0.1:" |awk -F: '{print $2}'|awk '{print $1}'`
        TotalPacketsSent=`cat $G_CURRENTLOG/xdslctl.log      |grep "ptm0.1:" |awk -F: '{print $2}'|awk '{print $10}'`
        TotalPacketsReceived=`cat $G_CURRENTLOG/xdslctl.log  |grep "ptm0.1:" |awk -F: '{print $2}'|awk '{print $2}'` 
    fi
    

    modulationType=`cat $G_CURRENTLOG/xdslctl.log        |grep "Mode:"     |awk '{print $2}'`
    if  [ "$modulationType" == "ADSL2+" ] ;then
   
            modulationType="ADSL_2plus"
    fi
            
    Layer1UpstreamMaxBitRate=`cat $G_CURRENTLOG/xdslctl.log    |grep "Max:    Upstream rate" |awk -F, '{print $1}'|awk '{print $5}'`
    Layer1DownstreamMaxBitRate=`cat $G_CURRENTLOG/xdslctl.log  |grep "Max:.*Downstream rate"|grep -o "Downstream rate.*Kbps" |awk '{print $4}'`
    CurrentProfile=`cat $G_CURRENTLOG/xdslctl.log        |grep "VDSL2 Profile" |awk '{print $4}'|sed "s/[^0-9a-zA-Z]//g"`
    DownstreamMaxRate=`cat $G_CURRENTLOG/xdslctl.log     |grep "Max:.*Downstream rate =" |awk -F, '{print $2}' |awk '{print $4}'`
    UpstreamMaxRate=`cat $G_CURRENTLOG/xdslctl.log       |grep "Max:.*Upstream rate ="   |awk -F, '{print $1}' |awk '{print $5}'`
    DownstreamPower=`cat $G_CURRENTLOG/xdslctl.log       |grep "Pwr(dBm):" |awk '{print $2*10}'`
    UpstreamPower=`cat $G_CURRENTLOG/xdslctl.log         |grep "Pwr(dBm):" |awk '{print $3*10}'`
    DownstreamAttenuation=`cat $G_CURRENTLOG/xdslctl.log |grep "Attn(dB):" |awk '{print $2*10}'`
    UpstreamAttenuation=`cat $G_CURRENTLOG/xdslctl.log   |grep "Attn(dB):" |awk '{print $3*10}'`
    DownstreamNoiseMargin=`cat $G_CURRENTLOG/xdslctl.log |grep "SNR (dB):" |awk '{print $3*10}'`
    UpstreamNoiseMargin=`cat $G_CURRENTLOG/xdslctl.log   |grep "SNR (dB):" |awk '{print $4*10}'`
    DownstreamCurrRate=`cat $G_CURRENTLOG/xdslctl.log    |grep "Bearer: 0" |awk -F , '{print $3}' |awk '{print $4}'`
    UpstreamCurrRate=`cat $G_CURRENTLOG/xdslctl.log      |grep "Bearer: 0" |awk -F , '{print $2}' |awk '{print $4}'`
    TRELLISds=`cat $G_CURRENTLOG/xdslctl.log             |grep "Trellis:"  |awk '{print $2}'`
    TRELLISus=`cat $G_CURRENTLOG/xdslctl.log             |grep "Trellis:"  |awk '{print $2}'`
    PowerManagementState=`cat $G_CURRENTLOG/xdslctl.log  |grep "Link Power State:" |awk -F: '{print $2}'|sed "s/ //g"`
    

    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$TotalBytesSent"                             >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$TotalBytesReceived"                     >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$TotalPacketsSent"                         >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$TotalPacketsReceived"                 >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1UpstreamMaxBitRate=$Layer1UpstreamMaxBitRate"         >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1DownstreamMaxBitRate=$Layer1DownstreamMaxBitRate"     >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.BytesSent=$BytesSent"                               >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.BytesReceived=$BytesReceived"                       >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.PacketsSent=$PacketsSent"                           >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.PacketsReceived=$PacketsReceived"                   >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.CurrentProfile=$CurrentProfile"                                >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamMaxRate=$DownstreamMaxRate"                          >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamMaxRate=$UpstreamMaxRate"                              >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamPower=$DownstreamPower"                              >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamPower=$UpstreamPower"                                  >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamAttenuation=$DownstreamAttenuation"                  >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamAttenuation=$UpstreamAttenuation"                      >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamNoiseMargin=$DownstreamNoiseMargin"                  >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamNoiseMargin=$UpstreamNoiseMargin"                      >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.ModulationType=$modulationType"                                >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamCurrRate=$DownstreamCurrRate"                        >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamCurrRate=$UpstreamCurrRate"                            >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISds=$TRELLISds"                                          >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISus=$TRELLISus"                                          >> $output
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.PowerManagementState=$PowerManagementState"                    >> $output
    echo "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.ErrorsSent=$ErrorsSent"   >> $output
    echo "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.ErrorsReceived=$ErrorsReceived"   >> $output
    echo "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.UnicastPacketsSent=$UnicastPacketsSent"   >> $output
    echo "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.UnicastPacketsReceived=$UnicastPacketsReceived"   >> $output
    echo "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.DiscardPacketsSent=$DiscardPacketsSent"   >> $output
    echo "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.DiscardPacketsReceived=$DiscardPacketsReceived"   >> $output
    echo "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.MulticastPacketsSent=$MulticastPacketsSent"   >> $output 
    echo "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.MulticastPacketsReceived=$MulticastPacketsReceived"   >> $output

#cat /proc/net/dev is have not these nodes in current
 #  echo "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.BroadcastPacketsSent=$BroadcastPacketsSent"   >> $output
#   echo "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.BroadcastPacketsReceived=$BroadcastPacketsReceived"   >> $output
#   echo "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.UnknownProtoPacketsReceived=$UnknownProtoPacketsReceived"   >> $output

}

wan.dns(){
    echo "wan.dns"
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cat /etc/resolv.conf" -l $G_CURRENTLOG -o DUTDNS.log
        
    dos2unix $G_CURRENTLOG/DUTDNS.log
    
    DNS1=`cat $G_CURRENTLOG/DUTDNS.log | grep "nameserver  *[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | awk '{print $2}' | head -1`
    echo "TMP_DUT_WAN_DNS_1=$DNS1" >> $output

    DNS2=`cat $G_CURRENTLOG/DUTDNS.log | grep "nameserver  *[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | awk '{print $2}' | head -2 | tail -1`
    echo "TMP_DUT_WAN_DNS_2=$DNS2" >> $output
}
##########################################################################
#Number of processes: 59
# 12:10am  up 33 min, 
#load average: 1 min:1.23, 5 min:1.11, 15 min:0.99
#              total         used         free       shared      buffers
#  Mem:        60052        54140         5912            0         4304
# Swap:            0            0            0
#Total:        60052        54140         5912
###########################################################################
dev.sysinfo(){
    echo "sysinfo is begining"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"sh\" -v \"sysinfo\" -l $G_CURRENTLOG -o sysinfo.log"
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "sysinfo" -l $G_CURRENTLOG -o sysinfo.log
        
    dos2unix $G_CURRENTLOG/sysinfo.log
    
    Total=`cat $G_CURRENTLOG/sysinfo.log | grep "Mem:" | awk '{print $2}'` 
    Free=`cat $G_CURRENTLOG/sysinfo.log | grep "Mem:" | awk '{print $4}'`
    Used=`cat $G_CURRENTLOG/sysinfo.log | grep "Mem:" | awk '{print $3}'`
    Buffers=`cat $G_CURRENTLOG/sysinfo.log | grep "Mem:" | awk '{print $6}'`
    MemoryUsed=`echo $Total" "$Buffers" "$Used | awk '{printf("%d",($3-$2)*100/$1)}'`

    echo "InternetGatewayDevice.DeviceInfo.MemoryStatus.Total=$Total" >> $output 
    echo "InternetGatewayDevice.DeviceInfo.MemoryStatus.Free=$Free" >> $output
    echo "InternetGatewayDevice.DeviceInfo.X_${U_TR069_CUSTOM_MANUFACTUREROUI}_MemoryUsed=$MemoryUsed" >> $output
}


wifi.info(){

    echo "=======Entry wifi.info"
    #check swversion
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"swversion\" -o cli_dut_swversion.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "swversion" -o cli_dut_swversion.log
    dos2unix $G_CURRENTLOG/cli_dut_swversion.log
    swversion=`cat $G_CURRENTLOG/cli_dut_swversion.log|grep swversion -A 1|tail -n1|sed 's/^ *//g'|sed 's/ *$//g'`
    echo "swversion=\"$swversion\""

    if [ "$swversion" == "33.00L.28" ];then
        for i in `seq 1 10`
        do
            rm -f $output
            echo "The swversion is ${swversion},GA release version!"
            
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
            rm -f $G_CURRENTLOG/cli_dut_dumpcfg.log
            perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "dumpcfg" -o cli_dut_dumpcfg.log
            dos2unix $G_CURRENTLOG/cli_dut_dumpcfg.log

            U_WIRELESS_SSID1_VALUE=`cat  $G_CURRENTLOG/cli_dut_dumpcfg.log  |grep "WlVirtIntfCfg instance=\"1\"" -A5|grep -o "<WlSsid>.*</WlSsid>"|sed 's/<\/*WlSsid>//g'`
            U_WIRELESS_SSID2_VALUE=`cat  $G_CURRENTLOG/cli_dut_dumpcfg.log  |grep "WlVirtIntfCfg instance=\"2\"" -A5|grep -o "<WlSsid>.*</WlSsid>"|sed 's/<\/*WlSsid>//g'`
            U_WIRELESS_SSID3_VALUE=`cat  $G_CURRENTLOG/cli_dut_dumpcfg.log  |grep "WlVirtIntfCfg instance=\"3\"" -A5|grep -o "<WlSsid>.*</WlSsid>"|sed 's/<\/*WlSsid>//g'`
            U_WIRELESS_SSID4_VALUE=`cat  $G_CURRENTLOG/cli_dut_dumpcfg.log  |grep "WlVirtIntfCfg instance=\"4\"" -A5|grep -o "<WlSsid>.*</WlSsid>"|sed 's/<\/*WlSsid>//g'`

            U_WIRELESS_WEPKEY_DEF_64_VALUE=`cat  $G_CURRENTLOG/cli_dut_dumpcfg.log | grep -o "<WlDefaultKeyWep64Bit>.*</WlDefaultKeyWep64Bit>" | sed 's/<\/*WlDefaultKeyWep64Bit>//g'`
 
            U_WIRELESS_WEPKEY1_VALUE=`cat  $G_CURRENTLOG/cli_dut_dumpcfg.log | grep -o "<WlDefaultKeyWep128Bit0>.*</WlDefaultKeyWep128Bit0>" | sed 's/<\/*WlDefaultKeyWep128Bit0>//g'`
            U_WIRELESS_WEPKEY2_VALUE=`cat  $G_CURRENTLOG/cli_dut_dumpcfg.log | grep -o "<WlDefaultKeyWep128Bit1>.*</WlDefaultKeyWep128Bit1>" | sed 's/<\/*WlDefaultKeyWep128Bit1>//g'`
            U_WIRELESS_WEPKEY3_VALUE=`cat  $G_CURRENTLOG/cli_dut_dumpcfg.log | grep -o "<WlDefaultKeyWep128Bit2>.*</WlDefaultKeyWep128Bit2>" | sed 's/<\/*WlDefaultKeyWep128Bit2>//g'`
            U_WIRELESS_WEPKEY4_VALUE=`cat  $G_CURRENTLOG/cli_dut_dumpcfg.log | grep -o "<WlDefaultKeyWep128Bit3>.*</WlDefaultKeyWep128Bit3>" | sed 's/<\/*WlDefaultKeyWep128Bit3>//g'`
   
            U_WIRELESS_WPAPSK1_VALUE=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log | grep -o "<WlDefaultKeyPsk0>.*</WlDefaultKeyPsk0>" | sed  's/<\/*WlDefaultKeyPsk0>//g'`
            U_WIRELESS_WPAPSK2_VALUE=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log | grep -o "<WlDefaultKeyPsk1>.*</WlDefaultKeyPsk1>" | sed  's/<\/*WlDefaultKeyPsk1>//g'`
            U_WIRELESS_WPAPSK3_VALUE=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log | grep -o "<WlDefaultKeyPsk2>.*</WlDefaultKeyPsk2>" | sed  's/<\/*WlDefaultKeyPsk2>//g'`
            U_WIRELESS_WPAPSK4_VALUE=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log | grep -o "<WlDefaultKeyPsk3>.*</WlDefaultKeyPsk3>" | sed  's/<\/*WlDefaultKeyPsk3>//g'`

            U_WIRELESS_BSSID1_VALUE=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log | grep "WlVirtIntfCfg instance=\"1\"" -A5 | grep -o "<WlBssMacAddr>.*</WlBssMacAddr>"|sed 's/<\/*WlBssMacAddr>//g'`
            U_WIRELESS_BSSID2_VALUE=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log | grep "WlVirtIntfCfg instance=\"2\"" -A5 | grep -o "<WlBssMacAddr>.*</WlBssMacAddr>"|sed 's/<\/*WlBssMacAddr>//g'`
            U_WIRELESS_BSSID3_VALUE=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log | grep "WlVirtIntfCfg instance=\"3\"" -A5 | grep -o "<WlBssMacAddr>.*</WlBssMacAddr>"|sed 's/<\/*WlBssMacAddr>//g'`
            U_WIRELESS_BSSID4_VALUE=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log | grep "WlVirtIntfCfg instance=\"4\"" -A5 | grep -o "<WlBssMacAddr>.*</WlBssMacAddr>"|sed 's/<\/*WlBssMacAddr>//g'`

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

            echo "U_WIRELESS_BSSID1=$U_WIRELESS_BSSID1_VALUE"                          >> $output
            echo "U_WIRELESS_BSSID2=$U_WIRELESS_BSSID2_VALUE"                          >> $output
            echo "U_WIRELESS_BSSID3=$U_WIRELESS_BSSID3_VALUE"                          >> $output
            echo "U_WIRELESS_BSSID4=$U_WIRELESS_BSSID4_VALUE"                          >> $output

            cat $output

            grep "= *$" $output
            if [ $? -eq 0 ];then
                let i=$i+1
                echo "Some variables is Null,Try $i time..."
                echo "sleep 10"
                sleep 10
            else
                break
            fi
        done
    else
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
        perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "gpv InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.X_BROADCOM_COM_WlanAdapter.WlBaseCfg." -o wireless_weppsk.log
        perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "gpv InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.X_BROADCOM_COM_WlanAdapter.WlVirtIntfCfg." -o wireless_ssid.log

        dos2unix  $G_CURRENTLOG/wireless_wep_psk.log
        dos2unix  $G_CURRENTLOG/wireless_ssid.log
           
        U_WIRELESS_SSID1_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "WlVirtIntfCfg\.1\.WlSsid=" | awk -F = '{print $2}'`
        U_WIRELESS_SSID2_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "WlVirtIntfCfg\.2\.WlSsid=" | awk -F = '{print $2}'`
        U_WIRELESS_SSID3_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "WlVirtIntfCfg\.3\.WlSsid=" | awk -F = '{print $2}'`   
        U_WIRELESS_SSID4_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "WlVirtIntfCfg\.4\.WlSsid=" | awk -F = '{print $2}'`

        U_WIRELESS_WEPKEY_DEF_64_VALUE=`cat  $G_CURRENTLOG/wireless_weppsk.log | grep "WlDefaultKeyWep64Bit=" | awk -F = '{print $2}'`
 
        U_WIRELESS_WEPKEY1_VALUE=`cat  $G_CURRENTLOG/wireless_weppsk.log | grep "WlBaseCfg\.WlDefaultKeyWep128Bit0=" | awk -F = '{print $2}'`
        U_WIRELESS_WEPKEY2_VALUE=`cat  $G_CURRENTLOG/wireless_weppsk.log | grep "WlBaseCfg\.WlDefaultKeyWep128Bit1=" | awk -F = '{print $2}'`
        U_WIRELESS_WEPKEY3_VALUE=`cat  $G_CURRENTLOG/wireless_weppsk.log | grep "WlBaseCfg\.WlDefaultKeyWep128Bit2=" | awk -F = '{print $2}'`
        U_WIRELESS_WEPKEY4_VALUE=`cat  $G_CURRENTLOG/wireless_weppsk.log | grep "WlBaseCfg\.WlDefaultKeyWep128Bit3=" | awk -F = '{print $2}'`
   
        U_WIRELESS_WPAPSK1_VALUE=`cat $G_CURRENTLOG/wireless_weppsk.log | grep "WlBaseCfg\.WlDefaultKeyPsk0=" | awk -F = '{print $2}'`
        U_WIRELESS_WPAPSK2_VALUE=`cat $G_CURRENTLOG/wireless_weppsk.log | grep "WlBaseCfg\.WlDefaultKeyPsk1=" | awk -F = '{print $2}'`
        U_WIRELESS_WPAPSK3_VALUE=`cat $G_CURRENTLOG/wireless_weppsk.log | grep "WlBaseCfg\.WlDefaultKeyPsk2=" | awk -F = '{print $2}'`
        U_WIRELESS_WPAPSK4_VALUE=`cat $G_CURRENTLOG/wireless_weppsk.log | grep "WlBaseCfg\.WlDefaultKeyPsk3=" | awk -F = '{print $2}'`

        U_WIRELESS_BSSID1_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "WlVirtIntfCfg\.1\.WlBssMacAddr=" | awk -F = '{print $2}'|tr [A-Z] [a-z]`
        U_WIRELESS_BSSID2_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "WlVirtIntfCfg\.2\.WlBssMacAddr=" | awk -F = '{print $2}'|tr [A-Z] [a-z]`
        U_WIRELESS_BSSID3_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "WlVirtIntfCfg\.3\.WlBssMacAddr=" | awk -F = '{print $2}'|tr [A-Z] [a-z]`
        U_WIRELESS_BSSID4_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "WlVirtIntfCfg\.4\.WlBssMacAddr=" | awk -F = '{print $2}'|tr [A-Z] [a-z]`

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

        echo "U_WIRELESS_BSSID1=$U_WIRELESS_BSSID1_VALUE"                          >> $output
        echo "U_WIRELESS_BSSID2=$U_WIRELESS_BSSID2_VALUE"                          >> $output
        echo "U_WIRELESS_BSSID3=$U_WIRELESS_BSSID3_VALUE"                          >> $output
        echo "U_WIRELESS_BSSID4=$U_WIRELESS_BSSID4_VALUE"                          >> $output
        cat $output
    fi
        
}


findproc(){
    echo "findproc"
    perl $U_PATH_TBIN/DUTCmd.pl -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "ps -aux" -o /proc_info.log

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
    perl $U_PATH_TBIN/DUTCmd.pl -o wl0.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cat /proc/net/dev"
    dos2unix $G_CURRENTLOG/wl0.log    
    TotalBytesReceived=`cat $G_CURRENTLOG/wl0.log    |grep "wl0:" |awk -F: '{print $2}'|awk '{print $1}'`
    TotalPacketsReceived=`cat $G_CURRENTLOG/wl0.log  |grep "wl0:" |awk -F: '{print $2}'|awk '{print $2}'`
    TotalBytesSent=`cat $G_CURRENTLOG/wl0.log        |grep "wl0:" |awk -F: '{print $2}'|awk '{print $9}'`
    TotalPacketsSent=`cat $G_CURRENTLOG/wl0.log      |grep "wl0:" |awk -F: '{print $2}'|awk '{print $10}'`

    echo "TotalBytesSent=$TotalBytesSent"              >> $output
    echo "TotalBytesReceived=$TotalBytesReceived"      >> $output
    echo "TotalPacketsSent=$TotalPacketsSent"          >> $output
    echo "TotalPacketsReceived=$TotalPacketsReceived"  >> $output
}    

wl.mac(){
   echo "wl.mac"
   perl $U_PATH_TBIN/DUTCmd.pl -o wlmac.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "ifconfig -a"
   dos2unix $G_CURRENTLOG/wlmac.log
   wl0_mac=`cat $G_CURRENTLOG/wlmac.log |grep "wl0 " |awk '{print $5}'`
   wl01_mac=`cat $G_CURRENTLOG/wlmac.log|grep "wl0.1"|awk '{print $5}'`
   echo "TMP_DUT_WIRELESS_BSSID1=$wl0_mac"    >>$output
   echo "TMP_DUT_WIRELESS_BSSID2=$wl01_mac"   >>$output
}  

cwmp.info(){
   echo "cwmp.info"
   #check swversion
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"swversion\" -o cli_dut_swversion.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "swversion" -o cli_dut_swversion.log
    dos2unix $G_CURRENTLOG/cli_dut_swversion.log
    swversion=`cat $G_CURRENTLOG/cli_dut_swversion.log|grep swversion -A 1|tail -n1|sed 's/^ *//g'|sed 's/ *$//g'`
    echo "swversion=\"$swversion\""

    if [ "$swversion" == "33.00L.28" ];then
        for i in `seq 1 10`
        do
            rm -f $G_CURRENTLOG/cli_dut_dumpcfg.log
            echo "perl $U_PATH_TBIN/DUTCmd.pl -o cli_dut_dumpcfg.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"dumpcfg\""
            perl $U_PATH_TBIN/DUTCmd.pl -o cli_dut_dumpcfg.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "dumpcfg"
            dos2unix $G_CURRENTLOG/cli_dut_dumpcfg.log
            Acs_username=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log|grep -A 10 "<ManagementServer>"|grep -o "<Username>.*</Username>"|sed 's/<\/*Username>//g'`
            Acs_password=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log|grep -A 10 "<ManagementServer>"|grep -o "<Password>.*</Password>"|sed 's/<\/*Password>//g'`
            Req_Username=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log|grep -A 10 "<ManagementServer>"|grep -o "<ConnectionRequestUsername>.*</ConnectionRequestUsername>"|sed 's/<\/*ConnectionRequestUsername>//g'`
            Req_Password=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log|grep -A 10 "<ManagementServer>"|grep -o "<ConnectionRequestPassword>.*</ConnectionRequestPassword>"|sed 's/<\/*ConnectionRequestPassword>//g'`
            Req_URL=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log|grep -A 10 "<ManagementServer>"|grep -o "<ConnectionRequestURL.*>.*</ConnectionRequestURL>"|awk -F\> '{print $2}'|awk -F\< '{print $1}'`
            Acs_URL=`cat $G_CURRENTLOG/cli_dut_dumpcfg.log|grep -A 10 "<ManagementServer>"|grep -o "<URL>.*</URL>"|sed 's/<\/*URL>//g'`
            echo "TMP_DUT_CWMP_ACS_URL=$Acs_URL" >$output
            echo "TMP_DUT_CWMP_CONN_ACS_USERNAME=$Acs_username" >>$output
            echo "TMP_DUT_CWMP_CONN_ACS_PASSWORD=$Acs_password" >>$output
            echo "TMP_DUT_CWMP_CONN_REQ_USERNAME=$Req_Username" >>$output
            echo "TMP_DUT_CWMP_CONN_REQ_PASSWORD=$Req_Password" >>$output
            echo "TMP_DUT_CWMP_CONN_REQ_URL=$Req_URL" >>$output

            cat $output

            grep "= *$" $output
            if [ $? -eq 0 ];then
                let i=$i+1
                echo "Some variables is Null,Try $i time..."
                echo "sleep 10"
                sleep 10
            else
                break
            fi
        done
    else
        rm -f $G_CURRENTLOG/cwmp.log
        perl $U_PATH_TBIN/DUTCmd.pl -o cwmp.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "gpv InternetGatewayDevice.ManagementServer."
        dos2unix $G_CURRENTLOG/cwmp.log
        Acs_username=`cat $G_CURRENTLOG/cwmp.log|grep -i "\.Username"|awk -F= '{print $2}'`
        Acs_password=`cat $G_CURRENTLOG/cwmp.log|grep -i "\.Password"|awk -F= '{print $2}'`
        Req_Username=`cat $G_CURRENTLOG/cwmp.log|grep -i "ConnectionRequestUsername"|awk -F= '{print $2}'`
        Req_Password=`cat $G_CURRENTLOG/cwmp.log|grep -i "ConnectionRequestPassword"|awk -F= '{print $2}'`
        Req_URL=`cat $G_CURRENTLOG/cwmp.log|grep -i "ConnectionRequestURL"|awk -F= '{print $2}'`
        Acs_URL=`cat $G_CURRENTLOG/cwmp.log|grep -i "\.URL="|awk -F= '{print $2}'`
        echo "TMP_DUT_CWMP_ACS_URL=$Acs_URL" >$output
        echo "TMP_DUT_CWMP_CONN_ACS_USERNAME=$Acs_username" >>$output
        echo "TMP_DUT_CWMP_CONN_ACS_PASSWORD=$Acs_password" >>$output
        echo "TMP_DUT_CWMP_CONN_REQ_USERNAME=$Req_Username" >>$output
        echo "TMP_DUT_CWMP_CONN_REQ_PASSWORD=$Req_Password" >>$output
        echo "TMP_DUT_CWMP_CONN_REQ_URL=$Req_URL" >>$output
    fi
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
    phylink=Unknown
    isplink=Unknown
    perl $U_PATH_TBIN/DUTCmd.pl -o wanlink.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "ifconfig" -v "route show"
    if [ $? -ne 0 ];then
        exit 1
    fi 
    dos2unix $G_CURRENTLOG/wanlink.log
    adslflag=`grep -i "atm.*Link.*HWaddr" $G_CURRENTLOG/wanlink.log`
    vdslflag=`grep -i "ptm.*Link.*HWaddr" $G_CURRENTLOG/wanlink.log`
    atmipoeflag=`grep -i "default.*atm.*" $G_CURRENTLOG/wanlink.log`
    ptmipoeflag=`grep -i "default.*ptm.*" $G_CURRENTLOG/wanlink.log`
    pppoeflag=`grep -i "default.*ppp.*" $G_CURRENTLOG/wanlink.log`
    ipoeflag=`grep -i "default.*ewan.*" $G_CURRENTLOG/wanlink.log`
    l3inf=`cat $G_CURRENTLOG/wanlink.log | grep "^default.*"|awk '{print $NF}'`
  

    if [ "$adslflag" != "" ] ;then
        phylink=ADSL
      
        if [ "$atmipoeflag" != "" ] ;then
            isplink=IPOE
        elif [ "$pppoeflag" != "" ] ;then
            isplink=PPPOE
        fi
        
    elif [ "$vdslflag" != "" ] ;then
        phylink=VDSL
     
        if [ "$ptmipoeflag" != "" ] ;then
            isplink=IPOE
        elif [ "$pppoeflag" != "" ] ;then
            isplink=PPPOE
        fi
        
    elif [ "$adslflag" == "" ] && [ "$vdslflag" == "" ] ;then
        phylink=ETH
        
        if [ "$ipoeflag" != "" ] ;then
            isplink=IPOE
        elif [ "$pppoeflag" != "" ] ;then
            isplink=PPPOE
        fi
        
    else
        echo -e " Cant judge WAN Link Mode! "
    fi

    echo "TMP_DUT_WAN_LINK=$phylink" >$output
    echo "TMP_DUT_WAN_ISP_PROTO=$isplink" >>$output  
    echo "TMP_CUSTOM_WANINF=$l3inf" >>$output
# TMP_CUSTOM_WANINF
  }

arp.table(){
    echo "arp.table"
    perl $U_PATH_TBIN/DUTCmd.pl -o getARPTable.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "arp show"
    if [ $? != 0 ]; then
        echo "AT_ERROR : failed to execute DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/getARPTable.log
    sed -n "/> arp show/,$"p $G_CURRENTLOG/getARPTable.log | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" > $G_CURRENTLOG/tmpARPTable.log
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
      echo "get br0 info for BAR1KH"
      startip=Unknown
      endip=Unknown
      staticmask=Unknown
      dhcpmask=Unknown
      router=Unknown
      dns=Unknown
      echo "G_CURRENTLOG=$G_CURRENTLOG"
      echo "output=$output"
      echo "perl $U_PATH_TBIN/DUTCmd.pl -o br0info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cat /etc/udhcpd.conf\" -v \"ifconfig\""
      perl $U_PATH_TBIN/DUTCmd.pl -o br0info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/udhcpd.conf" -v "ifconfig"
      dos2unix $G_CURRENTLOG/br0info.log
      startip=`grep "^ *start " $G_CURRENTLOG/br0info.log |awk '{print $2}'`
      endip=`grep "^ *end " $G_CURRENTLOG/br0info.log |awk '{print $2}'`
      staticmask=`grep "^ *option subnet " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      dhcpmask=`grep "^ *option subnet " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      router=`grep "^ *option router " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      br0dns1=`grep "^ *option dns " $G_CURRENTLOG/br0info.log | head -1 |awk '{print $3}'`
      br0dns2=`grep "^ *option dns " $G_CURRENTLOG/br0info.log | tail -1 |awk '{print $3}'`
      br0mac=`grep "HWaddr" $G_CURRENTLOG/br0info.log|grep "^ *br0 "|awk '{print $5}'|tr [A-Z] [a-z]`
      lt=`grep "^ *option lease " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      echo "########DUT br0 info" >>$output
      #echo "G_PROD_USR0=$U_DUT_TELNET_USER">>$output
      #echo "G_PROD_PWD0=$U_DUT_TELNET_PWD">>$output
      echo "G_PROD_IP_BR0_0_0=$G_PROD_IP_BR0_0_0">>$output
      echo "G_PROD_GW_BR0_0_0=$router">>$output
      echo "G_PROD_TMASK_BR0_0_0=$dhcpmask">>$output
      #echo "G_PROD_TMASK_BR0_0_0=$staticmask">>$output
      echo "G_PROD_DNS1_BR0_0_0=$br0dns1">>$output
      echo "G_PROD_DNS2_BR0_0_0=$br0dns2">>$output
      echo "G_PROD_DHCPSTART_BR0_0_0=$startip">>$output
      echo "G_PROD_DHCPEND_BR0_0_0=$endip">>$output
      echo "G_PROD_MAC_BR0_0_0=$br0mac">>$output
      echo "G_PROD_LEASETIME_BR0_0_0=$lt">>$output
      cat $output
}

dev.info(){
    echo "get DUT SN,FW,ModelName,ManufacturerOUI"
    date_format=`date +%m%d_%H%M%S`
    
    echo "perl $U_PATH_TBIN/clicfg.pl -d $G_PROD_IP_BR0_0_0 -i 23 -m \"^ >\" -v \"dumpcfg\" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD | tee $G_CURRENTLOG/dumpcfg_${date_format}"
    perl $U_PATH_TBIN/clicfg.pl -d $G_PROD_IP_BR0_0_0 -i 23 -m "^ >" -v "dumpcfg" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD | tee $G_CURRENTLOG/dumpcfg_${date_format}
    #check swversion
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"swversion\" -o cli_dut_swversion.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -port $U_DUT_TELNET_PORT -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "swversion" -o cli_dut_swversion.log
    dos2unix $G_CURRENTLOG/cli_dut_swversion.log
    swversion=`cat $G_CURRENTLOG/cli_dut_swversion.log|grep swversion -A 1|tail -n1|sed 's/^ *//g'|sed 's/ *$//g'`
    echo "swversion=\"$swversion\""

    if [ "$swversion" == "33.00L.28" ];then
        rm -f $G_CURRENTLOG/cli_dut_devinfo.log
        echo "perl $U_PATH_TBIN/DUTCmd.pl -o cli_dut_devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"dumpcfg\""
        perl $U_PATH_TBIN/DUTCmd.pl -o cli_dut_devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "factoryctl serialnum get"
        dos2unix $G_CURRENTLOG/cli_dut_devinfo.log
        dut_oui="001505"
        dut_sn=`cat $G_CURRENTLOG/cli_dut_devinfo.log|grep -i -A 1 "factoryctl serialnum get"|grep -i "Return Value = "|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
        dut_fw=$swversion
        dut_type="BAR1KH"
        echo "U_DUT_SN=$dut_sn" >>$output
        echo "U_DUT_MODELNAME=$dut_type" >>$output
        echo "U_DUT_SW_VERSION=$dut_fw" >>$output
        echo "U_TR069_CUSTOM_MANUFACTUREROUI=$dut_oui" >>$output

        cat $output

    else

        echo  "perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"gpv InternetGatewayDevice.DeviceInfo.ManufacturerOUI\" -v \"gpv InternetGatewayDevice.DeviceInfo.SerialNumber\" -v \"gpv InternetGatewayDevice.DeviceInfo.SoftwareVersion\" -v \"gpv InternetGatewayDevice.DeviceInfo.ModelName\""
        perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "ifconfig" -v "gpv InternetGatewayDevice.DeviceInfo.ManufacturerOUI" -v "gpv InternetGatewayDevice.DeviceInfo.SerialNumber" -v "gpv InternetGatewayDevice.DeviceInfo.SoftwareVersion" -v "gpv InternetGatewayDevice.DeviceInfo.ModelName"
        if [ $? -ne 0 ];then
            echo  "AT_ERROR  : perl $U_PATH_TBIN/DUTCmd.pl -o devinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"gpv InternetGatewayDevice.DeviceInfo.ManufacturerOUI\" -v \"gpv InternetGatewayDevice.DeviceInfo.SerialNumber\" -v \"gpv InternetGatewayDevice.DeviceInfo.SoftwareVersion\" -v \"gpv InternetGatewayDevice.DeviceInfo.ModelName\""
            exit 1
        fi
        dos2unix $G_CURRENTLOG/devinfo.log
        dut_oui=`cat $G_CURRENTLOG/devinfo.log|grep "InternetGatewayDevice.DeviceInfo.ManufacturerOUI="|awk -F= '{print $2}'`
        dut_sn=`cat $G_CURRENTLOG/devinfo.log|grep "InternetGatewayDevice.DeviceInfo.SerialNumber="|awk -F= '{print $2}'`
        dut_fw=`cat $G_CURRENTLOG/devinfo.log|grep "InternetGatewayDevice.DeviceInfo.SoftwareVersion="|awk -F= '{print $2}'`
        dut_type=`cat $G_CURRENTLOG/devinfo.log|grep "InternetGatewayDevice.DeviceInfo.ModelName="|awk -F= '{print $2}'`
        echo "U_DUT_SN=$dut_sn" >>$output
        echo "U_DUT_MODELNAME=$dut_type" >>$output
        echo "U_DUT_SW_VERSION=$dut_fw" >>$output
        echo "U_TR069_CUSTOM_MANUFACTUREROUI=$dut_oui" >>$output
        cat $output
    fi
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
        echo "perl $U_PATH_TBIN/DUTCmd.pl -o restoredefault_DUT.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v \"restoredefault\""
        perl $U_PATH_TBIN/DUTCmd.pl -o restoredefault_DUT.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "restoredefault"
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

layer2.stats(){
    echo "Get the connection status of layer2 interface for BAR1KH"
    let i=1
    retry_times=5
    sleep_time=10
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o layer2_connection_status.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v \"gpv InternetGatewayDevice.WANDevice.3.WANEthernetInterfaceConfig.Status\""
    while true
    do
        let fail_num=0
        rm -f $G_CURRENTLOG/layer2_connection_status.log
        perl $U_PATH_TBIN/DUTCmd.pl -o layer2_connection_status.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "gpv InternetGatewayDevice.WANDevice.3.WANEthernetInterfaceConfig.Status"
        if [ $? -eq 0 ];then
            dos2unix $G_CURRENTLOG/layer2_connection_status.log
            grep -i "InternetGatewayDevice.WANDevice.3.WANEthernetInterfaceConfig.Status *= *[0-9A-Za-z][0-9A-Za-z]*" $G_CURRENTLOG/layer2_connection_status.log
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
                eth=`grep -i "InternetGatewayDevice.WANDevice.3.WANEthernetInterfaceConfig.Status *= *[0-9A-Za-z][0-9A-Za-z]*" $G_CURRENTLOG/layer2_connection_status.log|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
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
    echo "get bootloader basic info for BAR1KH"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o basicinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"gpv InternetGatewayDevice.DeviceInfo.AdditionalHardwareVersion\" -v \"sh\" -v \"factoryctl serialnum get\" -v \"factoryctl wpakey get\" -v \"factoryctl wpspin get\" -v \"ifconfig\""
    perl $U_PATH_TBIN/DUTCmd.pl -o basicinfo.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "gpv InternetGatewayDevice.DeviceInfo.AdditionalHardwareVersion" -v "sh" -v "factoryctl serialnum get" -v "factoryctl wpakey get" -v "factoryctl wpspin get" -v "ifconfig"
    if [ $? -ne 0 ];then
        exit 1
    fi
    dos2unix $G_CURRENTLOG/basicinfo.log
    boardid=`cat $G_CURRENTLOG/basicinfo.log|grep -i "InternetGatewayDevice.DeviceInfo.AdditionalHardwareVersion=BoardId="|awk -F= '{print $3}'|sed 's/^ *//g'|sed 's/ *$//g'`
    snnum=`cat $G_CURRENTLOG/basicinfo.log|grep -i -A 1 "factoryctl serialnum get"|grep -i "Return Value = "|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    wpakey=`cat $G_CURRENTLOG/basicinfo.log|grep -i -A 1 "factoryctl wpakey get"|grep -i "Return Value = "|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    wpspin=`cat $G_CURRENTLOG/basicinfo.log|grep -i -A 1 "factoryctl wpspin get"|grep -i "Return Value = "|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    basicmac=`grep "HWaddr" $G_CURRENTLOG/basicinfo.log|grep "^ *br0 "|awk '{print $5}'|tr [A-Z] [a-z]`
    echo "BOARD_ID=$boardid" >$output
    echo "SERIAL_NUM=$snnum" >>$output
    echo "WPA_KEY=$wpakey" >>$output
    echo "WPS_PIN=$wpspin" >>$output
    echo "BASIC_MAC=$basicmac" >>$output
    grep "= *$" $output
    if [ $? -eq 0 ];then
        echo "AT_ERROR : NULL Value are not allowed!"
        #cat $output
        #exit 1
    fi
    cat $output
}

debug.info(){
    echo "Get debug info : ps;iptables -nvL;iptables -vnL -t nat;ifconfig -a;route show;dumpcfg;xdslctl info;"
    rm -rf $output
    bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 60
    if [ $? -gt 0 ];then
        exit 1
    fi
    #perl $U_PATH_TBIN/DUTCmd.pl -o debug_info.log -l $G_CURRENTLOG -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "dumpsysinfo" | tee $output
    perl $U_PATH_TBIN/clicfg.pl -d $G_PROD_IP_BR0_0_0 -i 23 -m "^ >" -v "dumpsysinfo" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD | tee $output

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
