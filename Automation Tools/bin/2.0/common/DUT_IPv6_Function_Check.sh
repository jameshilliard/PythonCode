#!/bin/bash 
#
# Description   :  This script is used to DUT ipv6 function check,such as DUT ipv6 status,verify ping6 and so on.
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#26 Nov 2012    |   1.0.0   | Ares      | Inital Version       
#
VER="1.0.0"
echo "$0 version : ${VER}"
help(){
    cat <<usage

        -h                                                  Show this help.

        --wan_type:     <dhcp/pppoe/static/6rd>             Specify DUT IPv6 WAN type to check.

        --lan_if:       <Such as eth1 or eth2>              Specify IPv6 LAN client interface to check.              
        
        --lan_type:     <such as ula_disabled dnsv6>        Specify IPv6 LAN device type to check.

        -n                                                  Negative test.

        `basename $0`: [-h] --wan_type <dhcp/pppoe/static/6rd> --lan_if <lan interface> --lan_typ <such as ula_disabled dnsv6> [-n <Negative test>]
usage
}
Is_Negative_Test=0

while [ $# -gt 0 ];
do
    case $1 in
        -w)
            v_dutCheck=$2
            shift 2
            ;;
        -l)
            v_lanCheck=$2
            shift 2
            ;;
        -h)
            help
            shift 1
            ;;
        --wan_type)
            wan_type=$2;
            shift 2 
            ;;
        --lan_if)
            lan_if=$2
            shift 2
            ;;
        --lan_type)
            lan_type=$2
            shift 2
            ;;
        -n)
            Is_Negative_Test=1
            shift 1
            ;;
        *)
            echo "Unknow parameters,please get more information as follow..."
            help
            exit 1
            ;;
    esac
done

if [ -z "$wan_type" ];then
    echo "Haven't specified WAN Type, set WAN type to dhcp"
    wan_type=dhcp
fi

if [ -z "$lan_if" ];then
    echo "Haven't specified LAN interface, set LAN interface to eth1"
    lan_if=$G_HOST_IF0_1_0
fi

if [ -z "$ip_pro" ];then
    echo "Haven't sepcify ip protocol to check, set IP protocol to ipv4"
    ip_pro=ipv4
fi

if [ "$U_DUT_TYPE" == "BHR2" ];then
    c_dutCheck=0
    c_lanCheck=0
fi

if [ "$U_DUT_TYPE" == "BHR2" -a "$wan_type" == "none"  ];then
    v_dutCheck=0
    v_lanCheck=8
elif [ "$U_DUT_TYPE" == "BHR2" -a "$wan_type" == "no_dns"  ];then
    v_dutCheck=5
    v_lanCheck=5      
fi

Get_WAN_IPv6_Info(){
    echo "In function Get_WAN_IPv6_Info ,ssh WAN PC and get IPv6 information..."
    echo "$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WAN_IPv6_info.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v \"ifconfig\" -v \"ip -6 r \""
    $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WAN_IPv6_info.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "ifconfig" -v "ip -6 r" 
}

Clear_tun6rd(){
    if [ "$wan_type" == "6rd" ];then
        echo "$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/Clear_tun6rd.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v \"ip -6 route flush dev tun6rd\" -v \"ifconfig tun6rd down\" -v \"ip tunnel del tun6rd\" -v \"ifconfig\" -v \"ip -6 r\"" 
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/Clear_tun6rd.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "ip -6 route flush dev tun6rd" -v "ifconfig tun6rd down" -v "ip tunnel del tun6rd" -v "ifconfig" -v "ip -6 r"
    else 
        echo "WAN IPv6 type is :<$wan_type>,so no need to clear tun6rd."
    fi
}

LAN_IPv6_Info_Check(){
    echo "In function LAN_IPv6_Info_Check,GET LAN PC information..."
    LAN_IPv6_Info_Check_Result=0
    echo "Get LAN ipv6 route..."
    ifconfig                |tee $G_CURRENTLOG/LAN_IPv6_info.log
    ip -6 r                 |tee -a $G_CURRENTLOG/LAN_IPv6_info.log

    echo "Get LAN DNS server info..."
    cat /etc/resolv.conf    |tee -a $G_CURRENTLOG/LAN_IPv6_info.log

    echo "Checking $lan_if ipv6 prefix..."
    LAN_ULA_Prefix=`grep -i "X_AEI_COM_IPv6CurrULAPrefixID" $G_CURRENTLOG/InternetGatewayDevice.log | awk -F= '{print $2}'|awk '{print $1}'`
    LAN_Global_Prefix=`grep -i "X_AEI_COM_IPv6CurrPrefixID" $G_CURRENTLOG/InternetGatewayDevice.log | awk -F= '{print $2}'|awk '{print $1}'`
    echo "LAN ULA prefix got from DUT is : <$LAN_ULA_Prefix>"
    echo "LAN Global prefix got from DUT and dibbler server is : <$LAN_Global_Prefix>"
    for i in $lan_if
    do 
        lan_if_ULA_ipv6=`ip -6 addr show dev $i to $LAN_ULA_Prefix|grep -i inet6|awk '{print $2}'`
        lan_if_ipv6=`ip -6 addr show dev $i to $LAN_Global_Prefix|grep -i inet6|awk '{print $2}'`
        echo "LAN  IPv6 prefix is : <$lan_if_ipv6>"
        if [ "$lan_type" != "ula_disabled" ];then
            if [ -z "$lan_if_ipv6" ]||[ -z "$lan_if_ULA_ipv6" ];then
                 rc=0
                 retry_times=6
                 until [ $rc -eq $retry_times ]
                     do  
                        lan_if_ULA_ipv6=`ip -6 addr show dev $i to $LAN_ULA_Prefix|grep -i inet6|awk '{print $2}'`
                        lan_if_ipv6=`ip -6 addr show dev $i to $LAN_Global_Prefix|grep -i inet6|awk '{print $2}'`
                        if [ "$lan_if_ipv6" ]&&[ "$lan_if_ULA_ipv6" ];then

                            echo "Passed to LAN interface $i ipv6 global address..."
                            echo "LAN $i IPv6 ULA address is :<$lan_if_ULA_ipv6>"
                            echo "LAN $i IPv6 Global address is :<$lan_if_ipv6>"
                            if [ "$U_DUT_TYPE" == "BHR2" ];then
                                c_lanCheck=$(($c_lanCheck+1))
                                echo "c_lanCheck add ip2 is :<$c_lanCheck>"
                            fi
                            rc=$retry_times
                        elif  [ "$U_DUT_TYPE" == "BHR2" ]&&[ "$wan_type" == "none" ]&&[ -z "$lan_if_ipv6" ]&&[ "$lan_if_ULA_ipv6" ];then
                            c_lanCheck=$(($c_lanCheck+8))
                            echo "c_lanCheck add ip3 is :<$c_lanCheck>"
                            rc=$retry_times
                        else
                             let rc=$(($rc+1))
                             if [ $rc -lt $retry_times ];then
                                 echo "AT WARNING : Failed to get LAN PC IPv6 address...,retry:$rc after 15 seconds."
                                 sleep 15
                             elif [ $rc -eq $retry_times ];then
                                echo "AT_ERROR : LAN interface $i ipv6 global address mistake..."
                                ifconfig 
                                LAN_IPv6_Info_Check_Result=$(($LAN_IPv6_Info_Check_Result+1))
                             fi  
                         fi
                     done
            else
                echo "LAN $i ipv6 address check passed:<$lan_if_ipv6>,<$lan_if_ULA_ipv6>"
                if [ "$U_DUT_TYPE" == "BHR2" ];then
                    c_lanCheck=$(($c_lanCheck+1))
                    echo "c_lanCheck add ip1 is :<$c_lanCheck>"
                fi

            fi
        elif [ "$lan_type" == "ula_disabled" ];then
            if [ -z "$lan_if_ipv6" ]||[ -n "$lan_if_ULA_ipv6"  ];then
                 rc=0
                 retry_times=6
                 until [ $rc -eq $retry_times ]
                     do  
                        lan_if_ULA_ipv6=`ip -6 addr show dev $i to $LAN_ULA_Prefix|grep -i inet6|awk '{print $2}'`
                        lan_if_ipv6=`ip -6 addr show dev $i to $LAN_Global_Prefix|grep -i inet6|awk '{print $2}'`
                         if [ "$lan_if_ipv6" ]&&[ -z "$lan_if_ULA_ipv6" ];then
                             echo "Passed to LAN interface $i ipv6 global address..."
                             echo "LAN $i IPv6 ULA address is :<$lan_if_ULA_ipv6>"
                             echo "LAN $i IPv6 Global address is :<$lan_if_ipv6>"
                             rc=$retry_times
                         else
                             let rc=$(($rc+1))
                             if [ $rc -lt $retry_times ];then
                                 echo "AT WARNING : Failed to get LAN PC IPv6 address...,retry:$rc after 15 seconds."
                                 sleep 15
                             elif [ $rc -eq $retry_times ];then
                                echo "AT_ERROR : LAN interface $i ipv6 global address mistake..."
                                ifconfig 
                                LAN_IPv6_Info_Check_Result=$(($LAN_IPv6_Info_Check_Result+1))
                             fi  
                         fi
                     done
            elif [ -n "$lan_if_ipv6" ]&&[ -z "$lan_if_ULA_ipv6"  ];then
                echo "LAN $i ipv6 address check passed:<$lan_if_ipv6>,<$lan_if_ULA_ipv6>"
            fi           
        fi
    done
    echo "TMP_LAN_PC1_IF_ULA_IPV6=$lan_if_ULA_ipv6" |tee -a $U_CUSTOM_UPDATE_ENV_FILE
    echo "TMP_LAN_PC1_IF_GLOBAL_IPV6=$lan_if_ipv6" |tee -a $U_CUSTOM_UPDATE_ENV_FILE

    echo "Checking LAN PC ipv6 default gateway..."
    LAN_PC_IPv6_Default_Gateway=`ip -6 r |grep -i "default via"`
    if [ -z "$LAN_PC_IPv6_Default_Gateway" ];then
        echo "AT_ERROR : LAN PC IPv6 default gateway is None..."
        LAN_IPv6_Info_Check_Result=$(($LAN_IPv6_Info_Check_Result+1))
    else
        if [ "$U_DUT_TYPE" == "BHR2"  ];then
            c_lanCheck=$(($c_lanCheck+4))
            echo "c_lanCheck add gw is :<$c_lanCheck>"
        fi
        echo "LAN PC IPv6 Default Gateway check passed : <$LAN_PC_IPv6_Default_Gateway>"
    fi

    echo "Checking LAN PC IPv6 DNS Server..."
    if [ "$U_DUT_TYPE" == "CTLC2KA" ];then
        U_CUSTOM_IPV6_DNS_SERVERS1=`grep -iw X_BROADCOM_COM_IPv6InterfaceAddress $G_CURRENTLOG/InternetGatewayDevice.log |awk -F= '{print $2}'|grep -i [0-9]:|sed 's/(.*)//g'|awk -F/ '{print $1}'`
        U_CUSTOM_IPV6_DNS_SERVERS2=`grep -iw X_AEI_COM_IPv6ULAAddress $G_CURRENTLOG/InternetGatewayDevice.log |awk -F= '{print $2}'|grep -i [0-9]:|sed 's/(.*)//g'|awk -F/ '{print $1}'`
        echo "Current IPv6 LAN DNS expect are : <$U_CUSTOM_IPV6_DNS_SERVERS1> ,<$U_CUSTOM_IPV6_DNS_SERVERS2>"
    fi

    rc=0
    retry_times=6
    until [ $rc -eq $retry_times ]
        do  
            LAN_PC_IPv6_DNS1=`grep -io "$U_CUSTOM_IPV6_DNS_SERVERS1" /etc/resolv.conf`
            LAN_PC_IPv6_DNS2=`grep -io "$U_CUSTOM_IPV6_DNS_SERVERS2" /etc/resolv.conf`
            if [ "$LAN_PC_IPv6_DNS1" != "" ]||[ "$LAN_PC_IPv6_DNS2" != "" ] ;then
                echo " Passed on get LAN PC IPv6 DNS..." 
                if [ "$U_DUT_TYPE" == "BHR2"  ];then
                    c_lanCheck=$(($c_lanCheck+2))
                    echo "c_lanCheck add dns is :<$c_lanCheck>"
                fi
                rc=$retry_times
            else
                let rc=$(($rc+1))
                if [ $rc -lt $retry_times ];then
                    echo "AT ERROR:Failed to get LAN PC IPv6 DNS...,retry:$rc after 15 seconds."
                    sleep 15
                elif [ $rc -eq $retry_times ];then

                    echo "Failed to  check LAN PC IPv6 DNS after retry $(($rc-1)) times"
                    LAN_IPv6_Info_Check_Result=$(($LAN_IPv6_Info_Check_Result+1))
                fi  
            fi
        done
    echo "LAN PC IPv6 DNS check passed : <$LAN_PC_IPv6_DNS1> , <$LAN_PC_IPv6_DNS2>"
}

Try_telnet_DUT(){
    echo "In function:Try telnet DUT..."
    rc=0
    retry_times=7
    until [ $rc -eq $retry_times ]
        do  
            perl $U_PATH_TBIN/DUTCmd.pl -o checkTelnet.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT 
            Telnet_check=$?
            if [ "$Telnet_check" == "0" ];then
                echo "Passed at telnet DUT ..."
                rc=$retry_times
            else
                let rc=$(($rc+1))
                if [ $rc -lt $retry_times ];then
                    echo "AT ERROR:Failed at telnet DUT...,retry:$rc after 15 seconds."
                    sleep 15
                elif [ $rc -eq $retry_times ];then
                  echo "Failed at login DUT check after retry $(($rc-1)) times"
                  ifconfig 
                  route -n
                fi  
            fi
        done
}

DUT_IPv6_Info_Check(){

    DUT_IPv6_Info_Check_Result=0  
    rc=0
    retry_times=7
    if [ "$U_DUT_TYPE" == "PK5K1A" ];then
        dutWanDhcpIpv6GlobalNode="InternetGatewayDevice.WANDevice.2.WANConnectionDevice.1.WANIPConnection.1.X_ACTIONTEC_COM_ExternalIPv6Address"
        dutWanPppoeIpv6GlobalNode="InternetGatewayDevice.WANDevice.2.WANConnectionDevice.1.WANPPPConnection.1.X_ACTIONTEC_COM_ExternalIPv6Address"
    elif [ "$U_DUT_TYPE" == "BHR2" ];then
        dutWanDhcpIpv6GlobalNode="InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.X_ACTIONTEC_COM_ExternalIPv6Address"
        dutWanPppoeIpv6GlobalNode="InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.1.X_ACTIONTEC_COM_ExternalIPv6Address"
    else
        dutWanDhcpIpv6GlobalNode="InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.X_BROADCOM_COM_ExternalIPv6Address"
        dutWanPppoeIpv6GlobalNode="InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.1.X_BROADCOM_COM_ExternalIPv6Address"
    fi

    until [ $rc -eq $retry_times ]
    do 
        echo "" >$G_CURRENTLOG/InternetGatewayDevice_Pre_Get.log   

        if [ "$U_DUT_TYPE" == "BHR2" ];then
            python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/InternetGatewayDevice_Pre_Get.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "system" -v "shell" -v "cli -g $dutWanDhcpIpv6GlobalNode" -v "cli -g $dutWanPppoeIpv6GlobalNode"
        else
            python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/InternetGatewayDevice_Pre_Get.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "sh" -v "cli -g $dutWanDhcpIpv6GlobalNode" -v "cli -g $dutWanPppoeIpv6GlobalNode"
        fi
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
    echo "python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/InternetGatewayDevice.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cli -g InternetGatewayDevice.\""
    echo "" >$G_CURRENTLOG/InternetGatewayDevice.log
    if [ "$U_DUT_TYPE" == "BHR2" ];then
        python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/InternetGatewayDevice.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "system" -v "shell" -v "cli -g InternetGatewayDevice."    
    else
        python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/InternetGatewayDevice.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "sh" -v "cli -g InternetGatewayDevice."    
    fi
    echo "Checking DUT WAN IPv6 global address..."
    if [ "$U_DUT_TYPE" == "PK5K1A" ]||[ "$U_DUT_TYPE" == "BHR2" ];then
        DUT_WAN_IPv6_Global_node="X_ACTIONTEC_COM_ExternalIPv6Address"
    else
        DUT_WAN_IPv6_Global_node="X_BROADCOM_COM_ExternalIPv6Address"
    fi
    DUT_WAN_IPv6_Global=`grep -i "$DUT_WAN_IPv6_Global_node" $G_CURRENTLOG/InternetGatewayDevice.log | awk -F= '{print $2}'|grep -n '[0-9]\{1,4\}:'`
    DUT_WAN_IPv6_Global_is=`grep -i "$DUT_WAN_IPv6_Global_node" $G_CURRENTLOG/InternetGatewayDevice.log | awk -F= '{print $2}'`
    if [ -z "$DUT_WAN_IPv6_Global" ];then
        echo "AT_ERROR : DUT IPv6 WAN IP check failed."
        DUT_IPv6_Info_Check_Result=$(($DUT_IPv6_Info_Check_Result+1))
    else
        if [ "$U_DUT_TYPE" == "BHR2" ];then
            c_dutCheck=$(($c_dutCheck+1))
            echo "c_dutCheck add ip is :<$c_dutCheck>"
        fi
        echo "DUT IPv6 WAN IP check passed."
    fi
    echo "DUT IPv6 global address is :$DUT_WAN_IPv6_Global_is "
    echo "TMP_DUT_WAN_IPV6_GLOBAL=$DUT_WAN_IPv6_Global" |tee -a $U_CUSTOM_UPDATE_ENV_FILE

    if [ "$U_DUT_TYPE" == "BHR2" ] ;then
        DUT_LAN_BR0_IPv6_Global_node="X_ACTIONTEC_COM_IPv6InterfaceAddress "
        if [ -z "${TMP_DUT_WAN_IPV6_LOCAL}" ];then
            echo "Try to get DUT WAN ipv6 link local address..."
            TMP_DUT_WAN_IPV6_LOCAL=`cat $G_CURRENTLOG/InternetGatewayDevice.log |grep -i "X_AEI_COM_IPv6LinkLocalAddress"|grep -io [0-9a-zA-Z]*:.*|sed 's/(String)//g'|awk '{print $1}'`
            echo "TMP_DUT_WAN_IPV6_LOCAL=$TMP_DUT_WAN_IPV6_LOCAL" | tee -a $U_CUSTOM_UPDATE_ENV_FILE
        fi
    fi
    
    TMP_DUT_LAN_BR0_IPV6_GLOBAL=`grep -i "$DUT_WAN_IPv6_Global_node" $G_CURRENTLOG/InternetGatewayDevice.log | awk -F= '{print $2}'| sed 's/ (String)//g'`
    echo "DUT LAN BR0 IPv6 global address is : $TMP_DUT_LAN_BR0_IPV6_GLOBAL "
    echo "TMP_DUT_LAN_BR0_IPV6_GLOBAL=$TMP_DUT_LAN_BR0_IPV6_GLOBAL" | tee -a $U_CUSTOM_UPDATE_ENV_FILE
    
    echo "Checking DUT IPv6 DNS..."
    DUT_WAN_IPv6_DNS=`grep -i IPv6DNSServers $G_CURRENTLOG/InternetGatewayDevice.log | awk -F= '{print $2}'`
    DUT_IPv6_DNS_Check1=`echo $DUT_WAN_IPv6_DNS | grep -i  $U_CUSTOM_IPV6_DNS_SERVERS1`
    DUT_IPv6_DNS_Check2=`echo $DUT_WAN_IPv6_DNS | grep -i  $U_CUSTOM_IPV6_DNS_SERVERS2`

    if [ -z "$DUT_IPv6_DNS_Check1" -a -z "$DUT_IPv6_DNS_Check2" ];then
        echo "AT_ERROR : DUT IPv6 DNS check failed.will sleep 75 seconds to check it again..."
        sleep 75
        echo "" >$G_CURRENTLOG/InternetGatewayDevice.log
        if [ "$U_DUT_TYPE" == "BHR2" ];then
            python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/InternetGatewayDevice.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "system" -v "shell" -v "cli -g InternetGatewayDevice."    
        else
            python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/InternetGatewayDevice.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "sh" -v "cli -g InternetGatewayDevice."    
        fi
        DUT_WAN_IPv6_DNS=`grep -i IPv6DNSServers $G_CURRENTLOG/InternetGatewayDevice.log | awk -F= '{print $2}'`
        DUT_IPv6_DNS_Check1=`echo $DUT_WAN_IPv6_DNS | grep -i  $U_CUSTOM_IPV6_DNS_SERVERS1`
        DUT_IPv6_DNS_Check2=`echo $DUT_WAN_IPv6_DNS | grep -i  $U_CUSTOM_IPV6_DNS_SERVERS2`
        if [ -z "$DUT_IPv6_DNS_Check1" -a -z "$DUT_IPv6_DNS_Check2" ];then
            echo "AT_ERROR : DUT IPv6 DNS check failed after wait 75 seconds..."
            DUT_IPv6_Info_Check_Result=$(($DUT_IPv6_Info_Check_Result+1))
        else
            if [ "$U_DUT_TYPE" == "BHR2" ];then
                c_dutCheck=$(($c_dutCheck+2))
                echo "c_dutCheck add dns2 is :<$c_dutCheck>"
            fi
            echo "DUT IPv6 DNS check passed after wait 75 seconds..."
        fi
    else
        if [ "$U_DUT_TYPE" == "BHR2" ];then
            c_dutCheck=$(($c_dutCheck+2))
            echo "c_dutCheck add dns1 is :<$c_dutCheck>"
        fi
        echo "DUT IPv6 DNS check passed."
    fi
    echo "DUT IPv6 DNS is : <$DUT_IPv6_DNS_Check1> , <$DUT_IPv6_DNS_Check2>"

    if [ "$U_DUT_TYPE" == "TDSV2200H" ];then
        Try_telnet_DUT
    fi

    if [ "$U_DUT_TYPE" == "PK5K1A" ]||[ "$U_DUT_TYPE" == "BHR2" ];then
        lay3_interface_node="InternetGatewayDevice.X_ACTIONTEC_COM_IPv6Layer3Forwarding.DefaultConnectionService"
    else
        lay3_interface_node="InternetGatewayDevice.X_BROADCOM_COM_IPv6Layer3Forwarding.DefaultConnectionService"
    fi
    echo "Checking DUT IPv6 Default gateway..."
    echo "python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/DUT_IPv6_Interface_Route.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"ifconfig\" -v \"ip -6 r\" -v \"cli -g $lay3_interface_node\""
    echo "" >$G_CURRENTLOG/DUT_IPv6_Interface_Route.log
    if [ "$U_DUT_TYPE" == "BHR2" ];then
        python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/DUT_IPv6_Interface_Route.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "system" -v "shell" -v "ifconfig" -v "ip -6 r" -v "cli -g $lay3_interface_node"

    else
        python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/DUT_IPv6_Interface_Route.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "sh" -v "ifconfig" -v "ip -6 r" -v "cli -g $lay3_interface_node"
    fi
    if [ "$wan_type" == "6rd" ];then
        echo "DUT IPv6 6rd mode,it\'s default gateway should be as :<::$TMP_DUT_DEF_GW>"
        DUT_EXP_Default_Gateway=`echo "::$TMP_DUT_DEF_GW"`
    elif [ "$wan_type" == "pppoe" ];then
        DUT_EXP_Default_Gateway=`echo "ppp"`
    else
        DUT_EXP_Default_Gateway=`echo ${U_CUSTOM_DUT_STATIC_IPV6_DEFAULT_GATEWAY%/*}`
    fi
    echo "grep -i \"$DUT_EXP_Default_Gateway\" $G_CURRENTLOG/DUT_IPv6_Interface_Route.log"
    Check_Default_Gateway=`grep -i "^default "  $G_CURRENTLOG/DUT_IPv6_Interface_Route.log|grep -i "$DUT_EXP_Default_Gateway"`
    if [ -z "$Check_Default_Gateway" ];then
        echo "Check the IPv4 WAN interface is ppp or not..."
        WAN_IF_NAME=`grep -i "DefaultConnectionService =" $G_CURRENTLOG/DUT_IPv6_Interface_Route.log |awk -F= '{print $2}'|awk '{print $1}'`
        echo "The current IPv4 WAN interface is :<$WAN_IF_NAME>"
        Is_WAN_PPP=`echo $WAN_IF_NAME|grep -i ppp`
        if [ -z "$Is_WAN_PPP" ];then
            echo "AT_ERROR : DUT ipv6 default gateway information mistake..."
            DUT_IPv6_Info_Check_Result=$(($DUT_IPv6_Info_Check_Result+1))   
        else
            echo "The current WAN type is PPPoE mode...,so the DUT default gw is : <$WAN_IF_NAME>"
            Check_Default_Gateway=`grep -i "^default "  $G_CURRENTLOG/DUT_IPv6_Interface_Route.log|grep -i "$WAN_IF_NAME"`
            if [ -z "$Check_Default_Gateway" ];then
                echo "AT_ERROR : DUT ipv6 default gateway information mistake as IPv4 WAN interface is : <$WAN_IF_NAME>..."
                DUT_IPv6_Info_Check_Result=$(($DUT_IPv6_Info_Check_Result+1))  
            else
                if [ "$U_DUT_TYPE" == "BHR2" ];then
                    c_dutCheck=$(($c_dutCheck+4))
                    echo "c_dutCheck add gw2 is :<$c_dutCheck>"
                fi
                echo "DUT ipv6 default gateway check passed : <$Check_Default_Gateway>"
            fi
        fi
    else
        if [ "$U_DUT_TYPE" == "BHR2" ];then
            c_dutCheck=$(($c_dutCheck+4))
            echo "c_dutCheck add gw1 is :<$c_dutCheck>"
        fi
        echo "DUT ipv6 default gateway check passed : <$Check_Default_Gateway>"
    fi

}

LAN_dns_v6_test(){

    echo "SSH to WAN PC and restart DNS server to release DNS cache..."
    $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WAN_IPv6_info.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "/etc/init.d/named restart"  
    ipv6_ping_test=ipv6.ping.com
    echo "In function LAN dns forced to use v6 testing..."
    rc=0
    retry_times=6
    if [ "$U_DUT_TYPE" == "CTLC2KA" ];then
        echo "python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/InternetGatewayDevice_DNS.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"cli -g InternetGatewayDevice.\""
        echo "" >$G_CURRENTLOG/InternetGatewayDevice_DNS.log
        python $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/InternetGatewayDevice_DNS.log -y telnet -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "sh" -v "cli -g InternetGatewayDevice."    
        U_CUSTOM_IPV6_DNS_SERVERS1=`grep -iw X_BROADCOM_COM_IPv6InterfaceAddress $G_CURRENTLOG/InternetGatewayDevice_DNS.log |awk -F= '{print $2}'|grep -i [0-9]:|sed 's/(.*)//g'|awk -F/ '{print $1}'`
        U_CUSTOM_IPV6_DNS_SERVERS2=`grep -iw X_AEI_COM_IPv6ULAAddress $G_CURRENTLOG/InternetGatewayDevice_DNS.log |awk -F= '{print $2}'|grep -i [0-9]:|sed 's/(.*)//g'|awk -F/ '{print $1}'`
        echo "Current IPv6 LAN DNS expect are : <$U_CUSTOM_IPV6_DNS_SERVERS1> ,<$U_CUSTOM_IPV6_DNS_SERVERS2>"
    fi 
    until [ $rc -eq $retry_times ]
        do  
            LAN_PC_IPv6_DNS1=`grep -io "$U_CUSTOM_IPV6_DNS_SERVERS1" /etc/resolv.conf`
            LAN_PC_IPv6_DNS2=`grep -io "$U_CUSTOM_IPV6_DNS_SERVERS2" /etc/resolv.conf`

            if [ "$LAN_PC_IPv6_DNS1" != "" ]||[ "$LAN_PC_IPv6_DNS2" != "" ];then
                echo "Passed on get LAN PC IPv6 DNS..."
                echo "LAN PC IPv6 DNS check passed : <$LAN_PC_IPv6_DNS1> , <$LAN_PC_IPv6_DNS2>"
                echo "cp -f /etc/resolv.conf   /etc/resolv.conf.bak"
                cp -f /etc/resolv.conf   /etc/resolv.conf.bak
                echo "$LAN_PC_IPv6_DNS1" >/etc/resolv.conf
                echo "$LAN_PC_IPv6_DNS2" >>/etc/resolv.conf
                echo "cat /etc/resolv.conf"
                ping6 $ipv6_ping_test -c 10
                cp -f /etc/resolv.conf.bak /etc/resolv.conf
                rc=$retry_times
            else
                let rc=$(($rc+1))
                if [ $rc -lt $retry_times ];then
                    echo "AT ERROR:Failed to get LAN PC IPv6 DNS...,retry:$rc after 15 seconds."
                    sleep 15
                elif [ $rc -eq $retry_times ];then
                    echo "AT_ERROR : LAN /etc/resolv.conf haven't get ipv6 DNS server... "
                    
                    exit 1
                fi  
            fi
        done
        cat /etc/resolv.conf
        if [ "$U_DUT_TYPE" == "CTLC2KA" ];then
            if [ -n "$LAN_PC_IPv6_DNS1" ];then
                U_CUSTOM_IPV6_DNS_SERVERS1=$LAN_PC_IPv6_DNS1
            else
                U_CUSTOM_IPV6_DNS_SERVERS1=$LAN_PC_IPv6_DNS2
            fi
                echo "U_CUSTOM_IPV6_DNS_SERVERS1=$U_CUSTOM_IPV6_DNS_SERVERS1" | tee -a $U_CUSTOM_UPDATE_ENV_FILE
        fi
}

Prepare_LAN_Link_Local(){
    echo "Check current LAN PC interface <$LAN_Device_link_local> IPv6 link local is ready or not ......"
    LAN_Device_link_local=`ifconfig $lan_if|grep -i "inet6" |grep -i "link"|awk '{print $3}'`
    if [ -z "$LAN_Device_link_local" ]&&[ $Is_Negative_Test -eq 0 ];then
        echo "Warnning : <$lan_if> have no IPv6 link local address,will down and up it..."
        ifconfig $lan_if down
        sleep 1
        ifconfig $lan_if up
        sleep 5
        ifconfig $lan_if
    else
        echo "<$lan_if> is ready for do IPv6 test..."
        return 0
    fi

}

Add_WAN_IPv6_route(){

    echo "In function : Add WAN ipv6 route..."
    TMP_DUT_WAN_IPV6_LOCAL=`cat $G_CURRENTLOG/InternetGatewayDevice.log|grep -i X_AEI_COM_IPv6LinkLocalAddress|grep -io [[:alnum:]]*:.*|sed 's/(String)//g'`
    echo -e "$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/Add_WAN_IPv6_route.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v \"ip -6 r del 2001:470:a837::/48\" -v \"ip -6 r add 2001:470:a837::/48 via $TMP_DUT_WAN_IPV6_LOCAL dev $U_CUSTOM_IPV6_WAN_SERVER_INTERFACE\" -v \"ip -6 r\""
    $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/Add_WAN_IPv6_route.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "ip -6 r del 2001:470:a837::/48" -v "ip -6 r add 2001:470:a837::/48 via $TMP_DUT_WAN_IPV6_LOCAL dev $U_CUSTOM_IPV6_WAN_SERVER_INTERFACE" -v "ip -6 r"

}

main(){
    Prepare_LAN_Link_Local
    LAN_IF_List=`ifconfig | grep eth.* | awk '{print $1}'`
    for dev in $LAN_IF_List
    do
        if [ "$dev" != "$G_HOST_IF0_0_0" ];then 
            echo "Start to Check $dev ipv6 address..."
            ipv6_global=`ifconfig $dev |grep -i global|awk '{print $3}'`
            echo "LAN <$dev> ipv6 global address is :<$ipv6_global>"
            if [ -z  "$ipv6_global" ];then
                echo "$dev no ipv6 global address..."
            else
                    for i in $ipv6_global
                    do 
                        if [ "$dev" != "$lan_if" ];then
                            echo "$dev is not need ipv6 test,so will flush it ipv6 address..."
                            ip -6 a flush dev $dev
                        else
                            echo "ip -6 a del dev $dev $i"
                            ip -6 a del dev $dev $i
                        fi
                    done
            fi
        fi
    done

    if [ "$lan_if" != "$G_HOST_IF0_2_0" ];then
         echo "$dev is not need ipv6 test,so will flush it ipv6 address..."
         ip -6 a flush dev $G_HOST_IF0_2_0
         ip -6 r flush dev $G_HOST_IF0_2_0
    fi

    echo "Sleep 15 seconds and showing LAN interface information..."
    sleep 15
    echo "ifconfig -a"
    ifconfig -a

    echo "ip -6 r"
    ip -6 r

    echo "route add default gw $G_PROD_IP_BR0_0_0"
    route add default gw $G_PROD_IP_BR0_0_0
    echo "screen -dmS dibbler dibbler-client run"
    screen -dmS dibbler dibbler-client run
    
    if [ "$lan_type" == "dnsv6" ];then
        LAN_dns_v6_test
        ping6 ipv6.ping.com -c 180
    else
        echo "LAN ipv6 ping test maybe use ipv4 dns server to resolv..."
        if [ $Is_Negative_Test -eq 0 ];then
            Get_WAN_IPv6_Info    
            DUT_IPv6_Info_Check
            LAN_IPv6_Info_Check
            if [ "$U_DUT_TYPE" == "BHR2" ];then
                Add_WAN_IPv6_route
            fi
            ping6 3001:aaaa::1 -c 4
            ping6_result=$?
            if [ $ping6_result -ne 0 ];then
                if [ "$U_DUT_TYPE" == "BHR2" -a "$wan_type" == "none"  ];then
                    echo "BHR2 IPv6 WAN type none ping6 test passed."
                else

                    echo "AT_ERROR : IPv6 function ping6 test failed."
                    ifconfig 
                    ip -6 r 
                    exit 1
                fi
            else
                if [ "$U_DUT_TYPE" == "BHR2" -a "$wan_type" == "none"  ];then
                    echo "AT_ERROR : BHR2 IPv6 WAN type none ping6 test Failed."
                    ifconfig 
                    ip -6 r 
                    exit 1
                else
                    echo "IPv6 function ping6 test passed."
                fi
            fi
            if [ "$U_DUT_TYPE" == "BHR2" -a "$wan_type" == "none"  ];then
                if [ "$c_dutCheck" -le 3 -a "$c_lanCheck" -ge 8 ];then
                    echo "OK,BHR2 IPv6 WAN none check passed..."
                else
                    echo "AT_ERROR,BHR2 IPv6 WAN none check Failed:<$c_dutCheck><$c_lanCheck>"
                    exit 1
                
                fi
            elif [ "$U_DUT_TYPE" == "BHR2" -a "$wan_type" == "no_dns"  ];then
                if [ "$c_dutCheck" -eq 5 -a "$c_lanCheck" -eq 5 ];then
                    echo "OK,BHR2 IPv6 WAN none check passed..."
                else
                    echo "AT_ERROR,BHR2 IPv6 WAN no DNS check Failed:<$c_dutCheck><$c_lanCheck>"
                    exit 1
                fi
            else
                if [ $LAN_IPv6_Info_Check_Result -ne 0 -o $DUT_IPv6_Info_Check_Result -ne 0 ];then
                    echo "AT_ERROR : IPv6 function check failed,please check DUT,WAN AND LAN IPv6 information..."
                    exit 1
                else 
                    echo "IPv6 function check passed."
                fi
            fi
        elif [ $Is_Negative_Test -eq 1 ];then
            if [ "$lan_type" != "disable" ];then
                echo "DUT IPv6 negative function test..."
                DUT_IPv6_Info_Check
                echo "The result of negative test is :$DUT_IPv6_Info_Check_Result"

                if [ $DUT_IPv6_Info_Check_Result -lt 1 ]&&[ "$wan_type" != "static" ];then
                    echo "AT_ERROR : IPv6 function negative check failed,please check DUT,WAN AND LAN IPv6 information..."
                    exit 1
                elif  [ $DUT_IPv6_Info_Check_Result -eq 3 ]||[ "$wan_type" == "static" -a $DUT_IPv6_Info_Check_Result -ge 1 ];then
                    echo "IPv6 function negative check passed."
                else
                    echo "IPv6 function negative check passed..."
                fi
            else
                echo "DUT WAN IPv6 function positive test and LAN device IPv6 function negative test..."
                DUT_IPv6_Info_Check
                LAN_IPv6_Info_Check
                echo "The result of DUT positive test is :<$DUT_IPv6_Info_Check_Result>"
                echo "The result of LAN device negative test is :<$LAN_IPv6_Info_Check_Result>"
                if [ $DUT_IPv6_Info_Check_Result -ne 0 ]; then
                    echo "DUT_IPv6_Info_Check_Result not equal 0"
                else
                    echo "DUT_IPv6_Info_Check_Result equal 0"
                fi
                
                if [ $LAN_IPv6_Info_Check_Result -le 1 ]; then
                    echo "LAN_IPv6_Info_Check_Result less equal 1"
                else
                    echo "LAN_IPv6_Info_Check_Result not less equal 1"
                fi

                if [ $DUT_IPv6_Info_Check_Result -eq 0 -a $LAN_IPv6_Info_Check_Result -ge 2 ];then
                    echo "DUT WAN IPv6 function positive test and LAN device IPv6 function negative test passed..."
                    return 0
                else
                    echo "AT_ERROR : LAN_IPv6_Info_CheckDUT WAN IPv6 function positive test and LAN device IPv6 function negative test failed..."
                    exit 1

                fi

#                if [ $DUT_IPv6_Info_Check_Result -ne 0 -o $LAN_IPv6_Info_Check_Result -le 1 ];then
#                    echo "AT_ERROR : LAN_IPv6_Info_CheckDUT WAN IPv6 function positive test and LAN device IPv6 function negative test failed..."
#                    exit 1
#                elif  [ $DUT_IPv6_Info_Check_Result -eq 0 -a $LAN_IPv6_Info_Check_Result -ge 2 ];then
#                    echo "DUT WAN IPv6 function positive test and LAN device IPv6 function negative test passed..."
#                    return 0
#                fi
            fi
        else
            echo "Noting..."
        fi
    fi
}

main
            
        

