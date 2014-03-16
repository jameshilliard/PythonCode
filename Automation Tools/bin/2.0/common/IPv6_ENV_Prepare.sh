#!/bin/bash
#
# Description   :  This script is used to set IPv6 test environment
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
# 6 Nov 2012    |   1.0.0   | Ares      | Inital Version       
# 3 Dec 2012    |   1.0.1   | Andy      | format the script, use the variable repalce hard code

VER="1.0.0"
echo "$0 version : ${VER}"

help(){
    cat <<usage

        -h                                                         Show this help.

        --WAN:     <dhcpdv6/pppoev6/dhcp_6rd/pppoe_6rd>            Specify WAN PC service type.

        --LAN:     <stateless/stateful>                            Specify LAN PC dibbler client type.

        --IF :     <eth1/eth2...>                                  Specify LAN interface for get IPv6 address.                   

        -test                                                      test mode.

        `basename $0`: [-h] --WAN <dhcpdv6/pppoev6/dhcp_6rd/pppoe_6rd> --LAN <stateless/stateful> --IF <eth1/eth2...>  [-test]
usage
}

while [ $# -gt 0 ];
do
    case $1 in

        -h)
            echo "Show this script Help..."
            help
            exit 0
            ;;

        --WAN)
            echo "Set WAN IPv6 service type..."
            wan_service=$2              
            shift 2
            ;;

        --LAN)
            echo "Set LAN IPv6 type...stateless or stateful"
            lan_ipv6_mode=$2
            shift 2
            ;;
        --IF)            
            echo "Sepcify LAN interface to get IPv6 address."
            lan_if=$2
            shift 2 
            ;;
        -test)
            G_HOST_IP1="192.168.100.101"
            G_HOST_USR1="root"
            G_HOST_PWD1="actiontec"
            U_PATH_TBIN="/root/automation/bin/2.0/common"
            G_CURRENTLOG="/root/ares"
            DUT_WAN_ipv6_link_local_address="fe80::428b:7ff:fee0:482"
            shift 1
            ;;
        *)
            echo -e " AT_ERROR : Unknow parameter,Show the help list! "
            help
            exit 1
            ;;
    esac
done

if [ -z "$lan_if" ];then
    echo "Not sepcified LAN interface,Set to default :<$G_HOST_IF0_1_0>"
    lan_if=$G_HOST_IF0_1_0
fi

client_config(){
    client_config_file="/etc/dibbler/client.conf"
    echo "Check if $lan_if is ip..."
    Is_Up=`ifconfig |grep -i $lan_if`
    if [ -z "$Is_Up" ];then
        echo "ifconfig $Is_Up up"
        ifconfig $lan_if up
    fi
if [ "$1" == "stateless" ] ;then
         echo "
log-mode short
log-level 7
iface \"$lan_if\" {
#ia
  option dns-server
#  option domain
}" >$client_config_file
elif [ "$1" == "stateful" ] ;then
        echo "
log-mode short
log-level 7
iface \"$lan_if\" {
ia
  option dns-server
#  option domain
}" >$client_config_file
else
    echo "AT_ERROR : Unknow IPv6 LAN type <$1>"
    exit 1
fi
}

wan_service_setting(){
    echo "In WAN PC IPv6 service setting..."
    if [ "$wan_service" == "dhcpdv6" ];then
        echo "ssh WAN PC and setting dibbler server as dhcpdv6..."
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/IPv6_WAN_config.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "source $U_CUSTOM_RUNTIME_ENV_FILE" -v "bash $U_PATH_TBIN/IPv6_WAN_service.sh   $wan_service"   -v "screen -dmS dibbler dibbler-server run"

    elif [ "$wan_service" == "pppoev6" ];then
        echo "ssh WAN PC and setting dibbler server as pppoev6..."
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/IPv6_WAN_config.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "source $U_CUSTOM_RUNTIME_ENV_FILE" -v "bash $U_PATH_TBIN/IPv6_WAN_service.sh   $wan_service"   -v "screen -dmS dibbler dibbler-server run"

    elif [ "$wan_service" == "dhcp_6rd" -o "$wan_service" == "pppoe_6rd" -o "$wan_service" == "dhcp_6rd_without_option_6rd" ];then
        echo "ssh WAN PC and setting $wan_service environment..."
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/IPv6_WAN_config.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "source $U_CUSTOM_RUNTIME_ENV_FILE" -v "bash $U_PATH_TBIN/IPv6_WAN_service.sh   $wan_service"  
    elif [ "$wan_service" == "stop" ];then
        echo "Check WAN PC no IPv6 service start......"
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/IPv6_WAN_config.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1  -v "source $U_CUSTOM_RUNTIME_ENV_FILE" -v "bash $U_PATH_TBIN/IPv6_WAN_service.sh   dhcpdv6" -v "killall -9 dibbler-server" -v "killall -9 udhcpd" -v "ps aux |grep -i dibbler-server" -v "ps aux|grep -i udhcpd" -v "/etc/init.d/named stop"

    fi
}

install_dibbler(){
    echo "In function install_dibbler... "
    if [ ! -e /usr/local/sbin/dibbler-client ] ;then
        echo "================================================================================"
        echo "Info : install dibbler-client"
        dibbler_install_path="/etc/dibbler"
        Client_Path="/root/automation/tools/2.0/START_SERVERS"
        mkdir $dibbler_install_path
        if [ -e $Client_Path/dibbler/dibbler-0.7.3-src.tar.gz ] ;then
            cd $dibbler_install_path
            tar -zxvf $Client_Path/dibbler/dibbler-0.7.3-src.tar.gz
            cd "dibbler-0.7.3"
            make
            make install
        else
            echo "AT_ERROR : Lack of rpm packages : dibbler-0.7.3-src.tar.gz"
            exit 1
        fi
    else
        echo "================================================================================"
        echo "Info : dibbler-client is intalled"
    fi
}

lan_client_setting(){
    echo "In LAN IPv6 client setting... "
    echo "ip6tables -F"
    ip6tables -F

    echo "dibbler-client stop"
    dibbler-client stop

    echo "killall -9 dibbler-client"
    killall -9 dibbler-client
    
    if [ "$lan_ipv6_mode" == "stateless" ];then
        echo "LAN IPv6 mode : stateless"
        client_config stateless
#        echo "screen -dmS dibbler dibbler-client run"
#        screen -dmS dibbler dibbler-client run
    elif [ "$lan_ipv6_mode" == "stateful" ];then
        echo "LAN IPv6 mode : stateful"
        client_config stateful
#        echo "screen -dmS dibbler dibbler-client run"
#        screen -dmS dibbler dibbler-client run
    elif [ "$wan_service" == "6rd" ]&&[ "$lan_ipv6_mode" == "" ] ;then
        echo "In IPv6 6rd mode......"
        return 0
    elif [ "$lan_ipv6_mode" == "stop" ];then
        echo "Stop LAN dibbler client......"
        dibbler-client stop
        killall -9 dibbler-client
        return 0
    else
        echo "AT_ERROR : Unknow LAN ipv6 mode,please see help get more information..."
        help
        exit 1
    fi
}

main(){
    install_dibbler

    if [ "$wan_service" ] ;then
        wan_service_setting
    fi

    if [ "$lan_ipv6_mode" ] ;then
        lan_client_setting
    fi
}

main
