#!/bin/bash
# print version info
VER="1.0.0"
echo "$0 version : ${VER}"
echo "This scrpit is only for FiberTech!"

usage="usage: bash $0 -v <Input parameter> -o <Output file> [-test]\nInput parameter:wan.info | wan.stats | wan.dns | dut.date"
# parse commandline
while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        U_PATH_TBIN=./
        G_CURRENTLOG=./LOGS
        G_PROD_IP_BR0_0_0=192.168.1.1
        U_DUT_TELNET_USER=
        U_DUT_TELNET_PWD=
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

    # login dut and execute cli command
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "route -n" -v "ifconfig" -t wanInfo.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    dos2unix  $G_CURRENTLOG/wanInfo.log

    # parse default route info 
    dut_wan_if=`awk '{if (/^\@0.0.0.0/) print $8}' $G_CURRENTLOG/wanInfo.log`
    dut_def_gw=`awk '{if (/^\@0.0.0.0/) print $2}' $G_CURRENTLOG/wanInfo.log`
    
    # check default gw
    if [ "$dut_def_gw" = "*" ] ;then
        dut_def_gw="`sed -n "/^$dut_wan_if/{n;p}" $G_CURRENTLOG/wanInfo.log |awk '{print $3}'| awk -F: '{print $2}'`"
    fi
    
    # check default gw
    #echo "dut_def_gw = $dut_def_gw"
    #echo "dut_wan_if = $dut_wan_if"

    rc=`echo "$dut_def_gw" |grep  "\."`

    if [ -z "$dut_wan_if" || -z "$rc" ] ;then
        echo "TMP_DUT_WAN_IF=" >> $output
        echo "TMP_DUT_WAN_IP=" >> $output
        echo "TMP_DUT_DEF_GW=" >> $output
        exit 0
    fi

    # parse wan ip
    dut_wan_ip="`sed -n "/^\@$dut_wan_if/{n;p}" $G_CURRENTLOG/wanInfo.log |awk '{print $3}' | awk -F: '{print $2}'`"
    
    # check wan ip
    #echo "dut_wan_ip = $dut_wan_ip"
    rc=`echo "$dut_wan_ip" |grep  "\."`
    if [ -z $rc ] ;then
        echo "TMP_DUT_WAN_IP="            >> $output
    else
        echo "TMP_DUT_WAN_IP=$dut_wan_ip" >> $output
    fi

    # output result
    echo "TMP_DUT_WAN_IF=$dut_wan_if" >> $output
    echo "TMP_DUT_DEF_GW=$dut_def_gw" >> $output
}

dut.date(){
    echo "date"
    
    # login dut and execute cli command
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "date" -t dutDate.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    dos2unix $G_CURRENTLOG/dutDate.log

    # parse dut date
    dut_date=`grep -A 1 "date" $G_CURRENTLOG/dutDate.log | tail -1 |  sed s/\@//g` 
    
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
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cat /proc/net/dev" -t wanStats.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    # parse wan stats
    # if the received Bytes' length more than 8 bit, interface field and receive bytes field will merge to one field.
    # so add code "awk -F: '{print $2}'" 
    BytesSent=`cat $G_CURRENTLOG/wanStats.log       |grep "eth10:" |awk -F: '{print $2}' |awk '{print $9}'`
	BytesReceived=`cat $G_CURRENTLOG/wanStats.log   |grep "eth10:" |awk -F: '{print $2}' |awk '{print $1}'`
    PacketsSent=`cat $G_CURRENTLOG/wanStats.log     |grep "eth10:" |awk -F: '{print $2}' |awk '{print $10}'`
    PacketsReceived=`cat $G_CURRENTLOG/wanStats.log |grep "eth10:" |awk -F: '{print $2}' |awk '{print $2}'`

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
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cat /etc/resolv.conf" -t wanDns.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    dos2unix $G_CURRENTLOG/wanDns.log
    
    # get the number of DNS servers
    dnsCount=`cat $G_CURRENTLOG/wanDns.log | grep "nameserver" | wc -l`
    
    # parse result and output
    if [ $dnsCount -ge 2  ] ;then
        DNS1=`cat $G_CURRENTLOG/wanDns.log | grep "nameserver" | awk '{print $2}' | head -1`
        echo "G_PROD_DNS1_BR0_0_0=$DNS1" >> $output

        DNS2=`cat $G_CURRENTLOG/wanDns.log | grep "nameserver" | awk '{print $2}' | tail -1`
        echo "G_PROD_DNS2_BR0_0_0=$DNS2" >> $output
    elif [ $dnsCount -gt 1  ] ;then
        DNS1=`cat $G_CURRENTLOG/wanDns.log | grep "nameserver" | awk '{print $2}'`
        echo "G_PROD_DNS1_BR0_0_0=$DNS1" >> $output
        echo "G_PROD_DNS2_BR0_0_0="      >> $output
    else
        echo "G_PROD_DNS1_BR0_0_0="      >> $output
        echo "G_PROD_DNS2_BR0_0_0="      >> $output
    fi
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
