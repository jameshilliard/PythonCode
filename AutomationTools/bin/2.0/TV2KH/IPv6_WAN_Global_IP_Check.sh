#!/bin/bash
#
# Description   :  This script is used to check TV2KH ipv6 WAN IP 
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#17 Jan 2013    |   1.0.0   | Ares      | Inital Version  
VER="1.0.0"
echo "$0 version : ${VER}"
help(){
    cat <<usage

        -h                                                  Show this help.

        -t:     <dhcpv6/pppoe/static/6rd>                   Specify DUT IPv6 WAN type to check.

        -n                                                  Negative test.

        `basename $0`: [-h] [-t <dhcpv6/pppoe/static/6rd>]  [-n <Negative test>]
usage
}
Is_Negative_Test=0
while [ $# -gt 0 ];
do
    case $1 in
        -h)
            help
            shift 1
            ;;
        -t)
            wan_type=$2;
            shift 2
            ;;
        -n)
            Is_Negative_Test=1
            shift 1
            ;;
        -test)
            G_CURRENTLOG="/tmp"
            G_PROD_IP_BR0_0_0="192.168.1.254"
            U_DUT_TELNET_USER="admin"
            U_DUT_TELNET_PWD="password"
            ;;
        *)
            echo "Unknow parameters,please get more information as follow..."
            help
            exit 1
            ;;
    esac
done

if [ -z "$wan_type" ];then
    echo "DUT IPv6 WAN type is not DHCPv6 mode..."
fi

Check_DUT_IPv6_WAN_IP(){
    rc=0
    retry_times=7
    until [ $rc -eq $retry_times ]
        do 
            echo "" >$G_CURRENTLOG/InternetGatewayDevice_Pre_Get.log    
            perl $U_PATH_TBIN/DUTShellCmd.pl -l $G_CURRENTLOG -o InternetGatewayDevice_Pre_Get.log -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cli -g InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.X_BROADCOM_COM_ExternalIPv6Address" -v "cli -g InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.1.X_BROADCOM_COM_ExternalIPv6Address"
            DUT_current_ipv6_address=`grep -i "ExternalIPv6Address =" $G_CURRENTLOG/InternetGatewayDevice_Pre_Get.log|sed 's/(String)//g'|awk -F= '{print $2}'|grep -i ".*:"`
            if [ -n "$DUT_current_ipv6_address" ];then
                echo "Passed on get DUT WAN IPv6 address :==> <$DUT_current_ipv6_address>"
                rc=$retry_times
            else
                let rc=$(($rc+1))
                if [ $rc -lt $retry_times ];then
                    echo "AT ERROR:Failed to get DUT WAN IPv6 address...,retry:$rc after 15 seconds."
                    sleep 15
                elif [ $rc -eq $retry_times ];then
                  echo "Failed to  check LAN PC IPv6 DNS after retry $(($rc-1)) times"
                fi  
            fi
        done
    echo "In function DUT_IPv6_Info_Check,GET DUT InternetGatewayDevice LAN and WAN information..."
    echo "perl $U_PATH_TBIN/DUTShellCmd.pl -l $G_CURRENTLOG -o InternetGatewayDevice.log -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cli -g InternetGatewayDevice.\""
    echo "" >$G_CURRENTLOG/InternetGatewayDevice.log
    perl $U_PATH_TBIN/DUTShellCmd.pl -l $G_CURRENTLOG -o InternetGatewayDevice.log -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cli -g InternetGatewayDevice."

    echo "Checking DUT WAN IPv6 global address..."
    DUT_WAN_IPv6_Global=`grep -i "X_BROADCOM_COM_ExternalIPv6Address" $G_CURRENTLOG/InternetGatewayDevice.log | awk -F= '{print $2}'|grep -n '[0-9]\{1,4\}:'`
    DUT_WAN_IPv6_Global_is=`grep -i "X_BROADCOM_COM_ExternalIPv6Address" $G_CURRENTLOG/InternetGatewayDevice.log | awk -F= '{print $2}'`
    if [ -z "$DUT_WAN_IPv6_Global" ];then
        if [ $Is_Negative_Test -eq 0 ];then
            echo "AT_ERROR : DUT IPv6 WAN IP check failed."
            exit 1
        elif [ $Is_Negative_Test -eq 1 ];then
            echo "DUT IPv6 WAN IP get passed."
            exit 0
        fi
    elif [ -n "$DUT_WAN_IPv6_Global" ];then
        if [ $Is_Negative_Test -eq 1 ];then
            echo "AT_ERROR : DUT IPv6 WAN IP check failed."
        elif [ $Is_Negative_Test -eq 0 ];then
            echo "DUT IPv6 WAN IP get passed."
        fi
    fi
}

Get_DUT_Current_WAN_IPv6_linklocal_IP(){

    echo "Get DUT IPv6 WAN Global address..."
    echo "" >$G_CURRENTLOG/DUT_IPv6_Clobal_Pre_Get.log
    perl $U_PATH_TBIN/DUTShellCmd.pl -l $G_CURRENTLOG -o DUT_IPv6_Clobal_Pre_Get.log -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cli -g InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.X_BROADCOM_COM_ExternalIPv6Address" -v "cli -g InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.1.X_BROADCOM_COM_ExternalIPv6Address"

    DUT_current_ipv6_address=`grep -i "ExternalIPv6Address =" $G_CURRENTLOG/DUT_IPv6_Clobal_Pre_Get.log|sed 's/(String)//g'|awk -F= '{print $2}'|grep -i ".*:"`

    if [ "$wan_type" == "dhcpv6" ];then
        echo "Get DUT current IPv6 WAN interface..."
        echo "" >$G_CURRENTLOG/Get_DUT_IPv6_WAN_Interface.log
        perl $U_PATH_TBIN/DUTShellCmd.pl -l $G_CURRENTLOG -o Get_DUT_IPv6_WAN_Interface.log -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "cli -g InternetGatewayDevice.X_BROADCOM_COM_IPv6Layer3Forwarding.DefaultConnectionService"
        DUT_IPv4_Current_WAN_Interface=`grep -i "DefaultConnectionService =" $G_CURRENTLOG/Get_DUT_IPv6_WAN_Interface.log|awk -F= '{print $2}'|awk '{print $1}'`
   
        echo "Get DUT $DUT_IPv4_Current_WAN_Interface information..."
        echo "" >$G_CURRENTLOG/Get_DUT_WAN_Interface.log
        perl $U_PATH_TBIN/DUTShellCmd.pl -l $G_CURRENTLOG -o Get_DUT_WAN_Interface.log -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "sh" -v "ifconfig $DUT_IPv4_Current_WAN_Interface"
        DUT_WAN_Link_Local_Address=`grep -i "link" $G_CURRENTLOG/Get_DUT_WAN_Interface.log|grep -i inet6|awk '{print $3}'`
        echo "DUT WAN IPv6 link local address is :<$DUT_WAN_Link_Local_Address>"

    else
        echo "Use DUT br0 link local address......"
        echo "" >$G_CURRENTLOG/DUT_Br0_Info.log
        echo "perl $U_PATH_TBIN/DUTShellCmd.pl -l $G_CURRENTLOG -o DUT_Br0_Info.log -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"sh\" -v \"ifconfig br0\""
        perl $U_PATH_TBIN/DUTShellCmd.pl -l $G_CURRENTLOG -o DUT_Br0_Info.log -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "sh" -v "ifconfig br0"
        DUT_WAN_Link_Local_Address=`grep -i "link" $G_CURRENTLOG/DUT_Br0_Info.log|grep -i inet6|awk '{print $3}'`
    
    fi
    DUT_WAN_IPv6_EUI_64=`echo $DUT_WAN_Link_Local_Address|awk -F:: '{print $2}'`
    IPv6_WAN_Global_Check=`echo $DUT_current_ipv6_address|grep -i $DUT_WAN_IPv6_EUI_64`
    
    if [ -z "$IPv6_WAN_Global_Check" ];then
        echo "AT_ERROR : DUT IPv6 WAN Global address check Failed!"
        echo "DUT EUI_64 address is : <$DUT_WAN_IPv6_EUI_64>"
        echo "BUT DUT IPv6 WAN Global address is : <$DUT_current_ipv6_address>"
        exit 1
    else
        echo "DUT IPv6 WAN Global IP EUI_64 address is : <$DUT_WAN_IPv6_EUI_64>"
        echo "OK,DUT IPv6 WAN Global address EUI_64 check Passed : <$DUT_current_ipv6_address>"

    fi


}

main(){
    Check_DUT_IPv6_WAN_IP
    Get_DUT_Current_WAN_IPv6_linklocal_IP
}

main
