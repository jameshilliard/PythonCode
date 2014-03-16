#!/bin/bash
# print version info
VER="1.0.0"
echo "$0 version : ${VER}"

usage="usage: bash $0 -v <Input parameter> -o <Output file> [-test]\nInput parameter:wan.info | wan.stats | wan.dns | dut.date | wifi.info | findproc | dev.sysinfo | wifi.stats | wl.mac | wireless.conf | cwmp.info | wan.link | arp.table | br0.info"

# parse commandline
while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        U_PATH_TBIN=.
        G_CURRENTLOG=.
        G_PROD_IP_BR0_0_0=192.168.1.65
        U_DUT_TELNET_USER=root
        U_DUT_TELNET_PWD=admin
        #InternetGatewayDevice.WANDevice.1.WANConnectionDevice.6.WANIPConnection.1
        U_TR069_WANDEVICE_INDEX=InternetGatewayDevice.WANDevice.1
        U_TR069_CUSTOM_MANUFACTUREROUI=00247B
        U_TR69_CUSTOM_PROCNAME=ssk
        U_WIRELESSINTERFACE=wlan6
        U_DUT_TELNET_PORT=23
        U_TMP_USING_NTGR=0
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

# cli subprocess
wan.info(){
    echo "wan.info"
    echo "perl $U_PATH_TBIN/DUTCmd.pl -o dut_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"route show\" -v \"ifconfig\""
    #perl $U_PATH_TBIN/DUTCmd.pl -o dut_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "route show" -v "ifconfig"
    perl $U_PATH_TBIN/sshcli.pl -o dut_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "route show" -v "ifconfig"

    dos2unix  $G_CURRENTLOG/dut_info.log
    # parse default route info 
    dut_wan_if=`awk '{if (/default/) print $8}' $G_CURRENTLOG/dut_info.log`
    dut_def_gw=`awk '{if (/default/) print $2}' $G_CURRENTLOG/dut_info.log`

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
    echo "dut_def_gw=$dut_def_gw"

    rc=`echo "$dut_def_gw" | grep  "\."`
    if [ -z $rc ]
    then
        echo "-| FAIL : DUT default gw failed"
        exit -1
    fi
    
    # parse wan ip
    dut_wan_ip="`sed -n "/^$dut_wan_if/{n;p}" $G_CURRENTLOG/dut_info.log |awk '{print $2}'|awk -F: '{print $2}'`"
    # check wan ip
    echo "dut_wan_ip=$dut_wan_ip"
    rc=`echo "$dut_wan_ip" | grep  "\."`
    if [ -z $rc ]
    then
        echo "-| FAIL : DUT WAN IP is error"
        exit -1
    fi

    # parse wan macaddress
    dut_wan_mac=`grep "^$dut_wan_if" $G_CURRENTLOG/dut_info.log |awk '{print $5}'`
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
    echo "dut_wan_mac=$dut_wan_mac"

    # parse wan mask
    dut_wan_mask="`sed -n "/^$dut_wan_if/{n;p}" $G_CURRENTLOG/dut_info.log |awk '{print $4}'|awk -F: '{print $2}'`"
    # check wan mask
    echo "dut_wan_mask=$dut_wan_mask"
    
    echo "TMP_DUT_WAN_IF=$dut_wan_if" >> $output
    echo "TMP_DUT_DEF_GW=$dut_def_gw" >> $output
    echo "TMP_DUT_WAN_IP=$dut_wan_ip" >> $output
    echo "TMP_DUT_WAN_MAC=$dut_wan_mac" >> $output
    echo "TMP_DUT_WAN_MASK=$dut_wan_mask" >> $output
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
    TRELLISds=`cat $G_CURRENTLOG/xdslctl.log             |grep "Trellis:"  |awk -FD: '{print $2}'|awk '{print $1}'`
    TRELLISus=`cat $G_CURRENTLOG/xdslctl.log             |grep "Trellis:"  |awk -FU: '{print $2}'|awk '{print $1}'`
    PowerManagementState=`cat $G_CURRENTLOG/xdslctl.log  |grep "Link Power State:" |awk -F: '{print $2}'|sed "s/ //g"`
    ACTINP=`cat $G_CURRENTLOG/xdslctl.log  |grep "^ *INP:"|awk '{print $2}'`
    

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
    echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.ACTINP=$ACTINP"                                                >> $output
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
    
    DNS1=`cat $G_CURRENTLOG/DUTDNS.log | grep "nameserver" | awk '{print $2}' | tail -2|head -1`
    echo "TMP_DUT_WAN_DNS_1=$DNS1" >> $output

    DNS2=`cat $G_CURRENTLOG/DUTDNS.log | grep "nameserver" | awk '{print $2}' | tail -1`
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
    if [ "$U_DUT_Wireless_Frequency" == "5" ];then
        echo "Test wireless for 5G"
        echo "perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cli -g Device.WiFi.AccessPoint.5.Security.PreSharedKey\" -v \"cli -g Device.WiFi.AccessPoint.6.Security.PreSharedKey\"  -v \"cli -g Device.WiFi.AccessPoint.7.Security.PreSharedKey\"  -v \"cli -g Device.WiFi.AccessPoint.8.Security.PreSharedKey\" -v \"cli -g Device.WiFi.AccessPoint.5.Security.WEPKey\" -v \"cli -g Device.WiFi.AccessPoint.6.Security.WEPKey\" -v \"cli -g Device.WiFi.AccessPoint.7.Security.WEPKey\" -v \"cli -g Device.WiFi.AccessPoint.8.Security.WEPKey\" -v \"cli -g Device.WiFi.SSID.5.SSID\" -v \"cli -g Device.WiFi.SSID.6.SSID\" -v \"cli -g Device.WiFi.SSID.7.SSID\" -v \"cli -g Device.WiFi.SSID.8.SSID\" -v \"flash all |grep ADDR\" -o $G_CURRENTLOG/wireless_ssid.log"

         perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cli -g Device.WiFi.AccessPoint.5.Security.PreSharedKey" -v "cli -g Device.WiFi.AccessPoint.6.Security.PreSharedKey"  -v "cli -g Device.WiFi.AccessPoint.7.Security.PreSharedKey"  -v "cli -g Device.WiFi.AccessPoint.8.Security.PreSharedKey" -v "cli -g Device.WiFi.AccessPoint.5.Security.WEPKey" -v "cli -g Device.WiFi.AccessPoint.6.Security.WEPKey" -v "cli -g Device.WiFi.AccessPoint.7.Security.WEPKey" -v "cli -g Device.WiFi.AccessPoint.8.Security.WEPKey" -v "cli -g Device.WiFi.SSID.5.SSID" -v "cli -g Device.WiFi.SSID.6.SSID" -v "cli -g Device.WiFi.SSID.7.SSID" -v "cli -g Device.WiFi.SSID.8.SSID" -v "flash all |grep ADDR" -o $G_CURRENTLOG/wireless_ssid.log
         dos2unix  $G_CURRENTLOG/wireless_ssid.log

         U_WIRELESS_SSID1_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.SSID.5.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
         U_WIRELESS_SSID2_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.SSID.6.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
         U_WIRELESS_SSID3_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.SSID.7.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`   
         U_WIRELESS_SSID4_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.SSID.8.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`

         U_WIRELESS_WEPKEY_DEF_64_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.AccessPoint.5.Security.WEPKey"|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
 
         U_WIRELESS_WEPKEY1_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.AccessPoint.5.Security.WEPKey"|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
         U_WIRELESS_WEPKEY2_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.AccessPoint.6.Security.WEPKey"|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
         U_WIRELESS_WEPKEY3_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.AccessPoint.7.Security.WEPKey"|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
         U_WIRELESS_WEPKEY4_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.AccessPoint.8.Security.WEPKey"|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`


         U_WIRELESS_WPAPSK1_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "Device.WiFi.AccessPoint.5.Security.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
         U_WIRELESS_WPAPSK2_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "Device.WiFi.AccessPoint.6.Security.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
         U_WIRELESS_WPAPSK3_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "Device.WiFi.AccessPoint.7.Security.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
         U_WIRELESS_WPAPSK4_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "Device.WiFi.AccessPoint.8.Security.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`

         U_WIRELESS_BSSID1_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HW_WLAN0_WLAN_ADDR1="|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'|tr [A-Z] [a-z]|awk 'BEGIN{FS=""}{print $1$2":"$3$4":"$5$6":"$7$8":"$9$10":"$11$12}'`
         U_WIRELESS_BSSID2_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HW_WLAN0_WLAN_ADDR2="|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'|tr [A-Z] [a-z]|awk 'BEGIN{FS=""}{print $1$2":"$3$4":"$5$6":"$7$8":"$9$10":"$11$12}'`
         U_WIRELESS_BSSID3_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HW_WLAN0_WLAN_ADDR3="|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'|tr [A-Z] [a-z]|awk 'BEGIN{FS=""}{print $1$2":"$3$4":"$5$6":"$7$8":"$9$10":"$11$12}'`
         U_WIRELESS_BSSID4_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HW_WLAN0_WLAN_ADDR4="|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'|tr [A-Z] [a-z]|awk 'BEGIN{FS=""}{print $1$2":"$3$4":"$5$6":"$7$8":"$9$10":"$11$12}'`
         
         echo "####wireless infomation about 5G"
         echo "U_WIRELESS_SSID1=$U_WIRELESS_SSID1_VALUE"                            > $output
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

         echo ""
         cat $output
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

        #echo "perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cli -s Device.WiFi.SSID.1.Enable int 1\" -v \"cli -s Device.WiFi.SSID.2.Enable int 1\" -v \"cli -s Device.WiFi.SSID.3.Enable int 1\" -v \"cli -s Device.WiFi.SSID.4.Enable int 1\" -o $G_CURRENTLOG/wireless_enable_ssid.log"

        #perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cli -s Device.WiFi.SSID.1.Enable int 1" -v "cli -s Device.WiFi.SSID.2.Enable int 1" -v "cli -s Device.WiFi.SSID.3.Enable int 1" -v "cli -s Device.WiFi.SSID.4.Enable int 1" -o $G_CURRENTLOG/wireless_enable_ssid.log
        #echo "waiting 30 seconds"
        #sleep 30
        
        echo "perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cli -g Device.WiFi.AccessPoint.1.Security.PreSharedKey\" -v \"cli -g Device.WiFi.AccessPoint.2.Security.PreSharedKey\"  -v \"cli -g Device.WiFi.AccessPoint.3.Security.PreSharedKey\"  -v \"cli -g Device.WiFi.AccessPoint.4.Security.PreSharedKey\" -v \"cli -g Device.WiFi.AccessPoint.1.Security.WEPKey\" -v \"cli -g Device.WiFi.AccessPoint.2.Security.WEPKey\" -v \"cli -g Device.WiFi.AccessPoint.3.Security.WEPKey\" -v \"cli -g Device.WiFi.AccessPoint.4.Security.WEPKey\" -v \"cli -g Device.WiFi.SSID.1.SSID\" -v \"cli -g Device.WiFi.SSID.2.SSID\" -v \"cli -g Device.WiFi.SSID.3.SSID\" -v \"cli -g Device.WiFi.SSID.4.SSID\" -v \"flash all |grep ADDR\" -o $G_CURRENTLOG/wireless_ssid.log"

        perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cli -g Device.WiFi.AccessPoint.1.Security.PreSharedKey" -v "cli -g Device.WiFi.AccessPoint.2.Security.PreSharedKey"  -v "cli -g Device.WiFi.AccessPoint.3.Security.PreSharedKey"  -v "cli -g Device.WiFi.AccessPoint.4.Security.PreSharedKey" -v "cli -g Device.WiFi.AccessPoint.1.Security.WEPKey" -v "cli -g Device.WiFi.AccessPoint.2.Security.WEPKey" -v "cli -g Device.WiFi.AccessPoint.3.Security.WEPKey" -v "cli -g Device.WiFi.AccessPoint.4.Security.WEPKey" -v "cli -g Device.WiFi.SSID.1.SSID" -v "cli -g Device.WiFi.SSID.2.SSID" -v "cli -g Device.WiFi.SSID.3.SSID" -v "cli -g Device.WiFi.SSID.4.SSID" -v "flash all |grep ADDR" -o $G_CURRENTLOG/wireless_ssid.log
#Dev    ice.WiFi.AccessPoint.1.Security.PreSharedKey = 00E843E200F44462 (String)
        dos2unix  $G_CURRENTLOG/wireless_ssid.log

        U_WIRELESS_SSID1_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.SSID.1.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
        U_WIRELESS_SSID2_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.SSID.2.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
        U_WIRELESS_SSID3_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.SSID.3.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`   
        U_WIRELESS_SSID4_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.SSID.4.SSID *="|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`

        U_WIRELESS_WEPKEY_DEF_64_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.AccessPoint.1.Security.WEPKey"|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
 
        U_WIRELESS_WEPKEY1_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.AccessPoint.1.Security.WEPKey"|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
        U_WIRELESS_WEPKEY2_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.AccessPoint.2.Security.WEPKey"|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
        U_WIRELESS_WEPKEY3_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.AccessPoint.3.Security.WEPKey"|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
        U_WIRELESS_WEPKEY4_VALUE=`cat  $G_CURRENTLOG/wireless_ssid.log  |grep "Device.WiFi.AccessPoint.4.Security.WEPKey"|sed 's/(String)//g'| awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`


        U_WIRELESS_WPAPSK1_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "Device.WiFi.AccessPoint.1.Security.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
        U_WIRELESS_WPAPSK2_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "Device.WiFi.AccessPoint.2.Security.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
        U_WIRELESS_WPAPSK3_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "Device.WiFi.AccessPoint.3.Security.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
        U_WIRELESS_WPAPSK4_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "Device.WiFi.AccessPoint.4.Security.PreSharedKey *=" |sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`

        U_WIRELESS_BSSID1_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HW_WLAN1_WLAN_ADDR1="|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'|tr [A-Z] [a-z]|awk 'BEGIN{FS=""}{print $1$2":"$3$4":"$5$6":"$7$8":"$9$10":"$11$12}'`
        U_WIRELESS_BSSID2_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HW_WLAN1_WLAN_ADDR2="|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'|tr [A-Z] [a-z]|awk 'BEGIN{FS=""}{print $1$2":"$3$4":"$5$6":"$7$8":"$9$10":"$11$12}'`
        U_WIRELESS_BSSID3_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HW_WLAN1_WLAN_ADDR3="|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'|tr [A-Z] [a-z]|awk 'BEGIN{FS=""}{print $1$2":"$3$4":"$5$6":"$7$8":"$9$10":"$11$12}'`
        U_WIRELESS_BSSID4_VALUE=`cat $G_CURRENTLOG/wireless_ssid.log | grep "HW_WLAN1_WLAN_ADDR4="|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'|tr [A-Z] [a-z]|awk 'BEGIN{FS=""}{print $1$2":"$3$4":"$5$6":"$7$8":"$9$10":"$11$12}'`
        echo "####wireless infomation about 2.4G"
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

        echo ""
        cat $output
fi
}

debug.info(){
    echo "debug.info"
    rm -rf $output
    bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 60
    if [ $? -gt 0 ];then
        exit 1
    fi
    perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "ifconfig" -v "ps" -v "cli -g Device.WiFi." -v "flash all"  -o $G_CURRENTLOG/cli_dut_debug_info.log |tee $output

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
   rm -f $G_CURRENTLOG/cwmp.log
#Device.ManagementServer.EnableCWMP =1 (Int)
#Device.ManagementServer.URL =http://iiothdm13.iot.motive.com/cwmpWeb/CPEMgt (String)
#Device.ManagementServer.Username =001505SD113100100232 (String)
#Device.ManagementServer.Password =22b32f46568d (String)
#Device.ManagementServer.PeriodicInformEnable =1 (Int)
#Device.ManagementServer.PeriodicInformInterval =300 (Int)
#Device.ManagementServer.PeriodicInformTime =0000-00-00T00:00:00+0000 (String)
#Device.ManagementServer.ParameterKey = (String)
#Device.ManagementServer.ConnectionRequestURL =http://192.168.1.65:7547 (String)
#Device.ManagementServer.ConnectionRequestUsername =admin (String)
#Device.ManagementServer.ConnectionRequestPassword =newVOLUser1 (String)
#Device.ManagementServer.UpgradesManaged =0 (Int)
#Device.ManagementServer.KickURL = (String)
#Device.ManagementServer.DownloadProgressURL = (String)
#Device.ManagementServer.DefaultActiveNotificationThrottle =0 (Int)
#Device.ManagementServer.CWMPRetryMinimumWaitInterval =5 (Int)
#Device.ManagementServer.CWMPRetryIntervalMultiplier =2000 (Int)
#   
   perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cli -g Device.ManagementServer." -o $G_CURRENTLOG/cwmp.log
   dos2unix $G_CURRENTLOG/cwmp.log
   Acs_username=`cat $G_CURRENTLOG/cwmp.log|grep -i "Device.ManagementServer.Username *= *.*(String)"|sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ * $//g'`
   Acs_password=`cat $G_CURRENTLOG/cwmp.log|grep -i "Device.ManagementServer.Password *= *.*(String)"|sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ * $//g'`
   Req_Username=`cat $G_CURRENTLOG/cwmp.log|grep -i "Device.ManagementServer.ConnectionRequestUsername *= *.*(String)"|sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ * $//g'`
   Req_Password=`cat $G_CURRENTLOG/cwmp.log|grep -i "Device.ManagementServer.ConnectionRequestPassword *= *.*(String)"|sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ * $//g'`
   Req_URL=`cat $G_CURRENTLOG/cwmp.log|grep -i "Device.ManagementServer.ConnectionRequestURL *= *.*(String)"|sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ * $//g'`
   Acs_URL=`cat $G_CURRENTLOG/cwmp.log|grep -i "Device.ManagementServer.URL *= *.*(String)"|sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ * $//g'`
   echo "TMP_DUT_CWMP_ACS_URL=$Acs_URL" >$output
   echo "TMP_DUT_CWMP_CONN_ACS_USERNAME=$Acs_username" >>$output
   echo "TMP_DUT_CWMP_CONN_ACS_PASSWORD=$Acs_password" >>$output
   echo "TMP_DUT_CWMP_CONN_REQ_USERNAME=$Req_Username" >>$output
   echo "TMP_DUT_CWMP_CONN_REQ_PASSWORD=$Req_Password" >>$output
   echo "TMP_DUT_CWMP_CONN_REQ_URL=$Req_URL" >>$output
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
      echo "get br0 info for WECB"
      #startip=Unknown
      #endip=Unknown
      ##staticmask=Unknown
      #dhcpmask=Unknown
      #router=Unknown
      #br0dns1=Unknown
      #br0dns2=Unknown
      #lt=Unknown
      #dns_proxy=Unknown
      #echo "G_CURRENTLOG=$G_CURRENTLOG"
      #echo "output=$output"
      #echo "perl $U_PATH_TBIN/DUTCmd.pl -o br0info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cat /etc/udhcpd.conf\" -v \"ifconfig\""
      #perl $U_PATH_TBIN/DUTCmd.pl -o br0info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/udhcpd.conf" -v "ifconfig"
      #dos2unix $G_CURRENTLOG/br0info.log
      #startip=`grep "^ *start " $G_CURRENTLOG/br0info.log |awk '{print $2}'`
      #endip=`grep "^ *end " $G_CURRENTLOG/br0info.log |awk '{print $2}'`
      ##staticmask=`grep "^ *option subnet " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      #dhcpmask=`grep "^ *option subnet " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      #router=`grep "^ *option router " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      #br0dns1=`grep "^ *option dns " $G_CURRENTLOG/br0info.log |awk '{print $3}'| head -1`
      #br0dns2=`grep "^ *option dns " $G_CURRENTLOG/br0info.log |awk '{print $3}'| tail -1`
      #lt=`grep "^ *option lease " $G_CURRENTLOG/br0info.log |awk '{print $3}'`
      #dns_proxy=`grep "^ *dns_proxy " $G_CURRENTLOG/br0info.log |awk '{print $2}'`
      #br0mac=`grep "HWaddr" $G_CURRENTLOG/br0info.log|grep "^ *br0 "|awk '{print $5}'|tr [A-Z] [a-z]`
      ##echo "G_PROD_USR0=$U_DUT_TELNET_USER">>$output
      ##echo "G_PROD_PWD0=$U_DUT_TELNET_PWD">>$output
      #echo "G_PROD_IP_BR0_0_0=$G_PROD_IP_BR0_0_0">>$output
      echo "G_PROD_GW_BR0_0_0=$G_PROD_IP_BR0_0_0">$output
      #echo "G_PROD_TMASK_BR0_0_0=$dhcpmask">>$output
      ##echo "G_PROD_TMASK_BR0_0_0=$staticmask">>$output
      ##echo "TMP_DUT_WAN_DNS_1=$br0dns1">>$output
      ##echo "TMP_DUT_WAN_DNS_2=$br0dns2">>$output
      #echo "G_PROD_DHCPSTART_BR0_0_0=$startip">>$output
      #echo "G_PROD_DHCPEND_BR0_0_0=$endip">>$output
      #echo "G_PROD_LEASETIME_BR0_0_0=$lt">>$output
      #if [ "$dns_proxy" == "Unknown" ] ;then
      #    echo "G_PROD_DNS1_BR0_0_0=$br0dns1">>$output
      #    if [ "$br0dns1" == "$br0dns2" ] ;then
      #        echo "G_PROD_DNS2_BR0_0_0=">>$output
      #    else
      #        echo "G_PROD_DNS2_BR0_0_0=$br0dns2">>$output
      #    fi
      #else
      #    if [ "$dns_proxy" == "$br0dns2" ] ;then
      #        echo "G_PROD_DNS1_BR0_0_0=$br0dns2">>$output
      #        echo "G_PROD_DNS2_BR0_0_0=$br0dns1">>$output
      #    else
      #        echo "G_PROD_DNS1_BR0_0_0=$br0dns1">>$output
      #        if [ "$br0dns1" == "$br0dns2" ] ;then
      #            echo "G_PROD_DNS2_BR0_0_0=">>$output
      #        else
      #            echo "G_PROD_DNS2_BR0_0_0=$br0dns2">>$output
      #        fi
      #    fi
      #fi
      #echo "G_PROD_MAC_BR0_0_0=$br0mac">>$output
  }

dev.info(){
    echo "get DUT SN,FW,ModelName,ManufacturerOUI"
    echo  "perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cat /etc/version\" -o $G_CURRENTLOG/devinfo.log"
    perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/version" -v "cli -g Device.DeviceInfo.SerialNumber" -v "cli -g Device.DeviceInfo.ModelName" -v "cli -g Device.DeviceInfo.ManufacturerOUI" -o $G_CURRENTLOG/devinfo.log
    dos2unix $G_CURRENTLOG/devinfo.log
    dut_oui=`cat $G_CURRENTLOG/devinfo.log|grep -i "Device.DeviceInfo.ManufacturerOUI *= *.*(String)"|sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ * $//g'`
    dut_sn=`cat $G_CURRENTLOG/devinfo.log |grep -i "Device.DeviceInfo.SerialNumber *= *.*(String)"|sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ * $//g'`
    dut_fw=`cat $G_CURRENTLOG/devinfo.log|grep  -i "The SW version is:"|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/ * $//g'`
    dut_type=`cat $G_CURRENTLOG/devinfo.log|grep -i "Device.DeviceInfo.ModelName *= *.*(String)"|sed 's/(String)//g'|awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ * $//g'`
    echo "U_DUT_SN=$dut_sn" >$output
    echo "U_DUT_MODELNAME=$dut_type" >>$output
    echo "U_DUT_SW_VERSION=$dut_fw" >>$output
    echo "U_TR069_CUSTOM_MANUFACTUREROUI=$dut_oui" >>$output
    cat $output
}

rebootDUT(){
    i=1
    echo "reboot WECB by ssh"
    while true
    do
        echo "perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"reboot\""
        perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "reboot"
        if [ $? -eq 0 ];then
            echo "WECB begin to reboot,Please Wait..."
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
            sleep 20
        fi
    done
}

restoreDUT(){
    i=1
    echo "restore default by ssh"
    while true
    do
        echo "perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"killall data_center\" -v \"rm -f /mnt/rt_conf/*.zml.gz\" -v \"sync\" -v \"flash reset\""
        perl $U_PATH_TBIN/sshcli.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "killall data_center" -v "rm -f /mnt/rt_conf/*.zml.gz" -v "sync" -v "flash reset"
        if [ $? -eq 0 ];then
            echo "WECB begin to restore default,Please Wait..."
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
            sleep 20
        fi
    done
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
