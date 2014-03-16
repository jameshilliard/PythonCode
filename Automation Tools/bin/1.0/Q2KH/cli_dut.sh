#!/bin/bash
# print version info
VER="1.0.0"
echo "$0 version : ${VER}"

usage="usage: bash $0 -v <Input parameter> -o <Output file> [-test]\nInput parameter:wan.info | wan.stats | wan.dns | dut.date"
# parse commandline
while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        U_PATH_TBIN=./
        G_CURRENTLOG=/root/Downloads/cli/LOGS
        G_PROD_IP_BR0_0_0=192.168.0.1
        U_DUT_TELNET_USER=admin
        U_DUT_TELNET_PWD=admin
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
        echo "output log File : $output"
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

    echo "perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -m \">\" -v \"route show\"  -v \"ifconfig\" -t $G_CURRENTLOG/dut_info.log"
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -m ">" -v "route show"  -v "ifconfig" |tee $G_CURRENTLOG/dut_info.log

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
    
    echo "TMP_DUT_WAN_IF=$dut_wan_if" >> $output
    echo "TMP_DUT_DEF_GW=$dut_def_gw" >> $output
    echo "TMP_DUT_WAN_IP=$dut_wan_ip" >> $output

}

dut.date(){
    echo "date"

    echo "perl $U_PATH_TBIN/DUTShellCmd.pl -o get_dut_time.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -v \"date\" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD | grep -A 1 '# date'| tail -1"

    dut_date=`perl $U_PATH_TBIN/DUTShellCmd.pl -o get_dut_time.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -v "date" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD | grep -A 1 '# date'| tail -1`
    
    echo "U_CUSTOM_LOCALTIME=$dut_date" >> $output
}

wan.stats(){

    # $U_TR069_WANDEVICE_INDEX means InternetGatewayDevice.WANDevice.1 or 2 3 
    echo "wan.stats"
    
    perl $U_PATH_TBIN/DUTCmd.pl -o xdslctl.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /proc/net/dev" -v "xdslctl info --show"

    #perl $U_PATH_TBIN/DUTCmd.pl -o xdslctl_info_show.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "xdslctl info --show"

    #perl $U_PATH_TBIN/DUTCmd.pl -o xdslctl_info.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "xdslctl info"
    
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
    modulationType=`cat $G_CURRENTLOG/xdslctl.log        |grep "Mode:"     |awk '{print $2}'`
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

}

wan.dns(){
    echo "wan.dns"
    perl $U_PATH_TBIN/DUTShellCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cat /etc/resolv.conf" -l $G_CURRENTLOG -o DUTDNS.log
        #remove ^M
    dos2unix $G_CURRENTLOG/DUTDNS.log
    
    DNS1=`cat $G_CURRENTLOG/DUTDNS.log | grep "nameserver" | awk '{print $2}' | tail -2|head -1`
    echo "G_PROD_DNS1_BR0_0_0=$DNS1" >> $output

    DNS2=`cat $G_CURRENTLOG/DUTDNS.log | grep "nameserver" | awk '{print $2}' | tail -1`
    echo "G_PROD_DNS2_BR0_0_0=$DNS2" >> $output
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
