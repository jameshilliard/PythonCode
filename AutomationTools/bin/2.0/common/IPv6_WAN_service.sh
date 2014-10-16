#!/bin/bash
#set -x

if [ "$1" ] ;then
    service_type=$1
else
    echo "AT_ERROR : Haven't specified the service type"
    exit 1
fi

cecho(){
    case "$1" in
        "info")
            #color is green
            echo -e "====== $2 "
            ;;
        "warn")
            #color is yellow
            echo -e "====== $2 "
            ;;
        "fail")
            #color is red
            echo -e "====== $2 "
            ;;
        *)
            echo "====== $1 "
            ;;
    esac
}

Server_Path="$U_PATH_TOOLS/START_SERVERS"
install_dibbler(){ 
    if [ ! -e /usr/local/sbin/dibbler-server ] ;then
        echo "================================================================================"
        cecho info "install dibbler-server"
        dibbler_install_path="/etc/dibbler"
        mkdir $dibbler_install_path
        if [ -e $Server_Path/dibbler/dibbler-0.7.3-src.tar.gz ] ;then
            cd $dibbler_install_path
            tar -zxvf $Server_Path/dibbler/dibbler-0.7.3-src.tar.gz
            cd "dibbler-0.7.3"
            make
            make install
        else    
            cecho fail "Lack of rpm packages : dibbler-0.7.3-src.tar.gz"
            exit 1
        fi
    else
        echo "================================================================================"
        cecho info "dibbler-server is intalled"
    fi
}

install_udhcpd(){
    if [ ! -e /usr/sbin/udhcpd ] ;then
        echo "================================================================================"
        cecho info "install udhcpd"
        udhcpd_install_path="/etc/udhcpd"
        mkdir $udhcpd_install_path
        if [ -e $Server_Path/udhcpd/udhcp-0.9.8.tar.gz ] ;then
            cd $udhcpd_install_path
            tar -zxvf $Server_Path/udhcpd/udhcp-0.9.8.tar.gz
            cd "udhcp-0.9.8"
            make
            cp udhcpd /usr/sbin/
        else
            cecho fail "Lack of rpm packages : udhcp-0.9.8.tar.gz"
            exit 1
        fi
    else
        echo "================================================================================"
        cecho info "udhcpd is intalled"
    fi
}

udhcpd_setting(){

    echo "Setting udhcpd config files......"
    udhcpd_conf_file="/etc/udhcpd.conf"
    rc=`ifconfig ${G_HOST_IF1_2_0}.${U_CUSTOM_VLANETH}|grep -iw "inet addr"`
    if [ -z "$rc" ];then
        interface="${G_HOST_IF1_2_0}"
    else
        interface="${G_HOST_IF1_2_0}.${U_CUSTOM_VLANETH}"
    fi
    echo "WAN GW IP is : <${interface}>"
    rc=`ifconfig $interface|grep -iw "inet addr"`
    #inet addr:10.16.87.76 Bcast:10.16.87.255 Mask:255.255.255.0
    echo "$rc"
    optRouter=`echo $rc|sed 's/[a-zA-Z]//g'|sed 's/://g'|awk '{print $1}'` #10.16.87.76
    #echo $rc|sed 's/[a-zA-Z]//g'|sed 's/://g'|awk '{print $2}' #10.16.87.255
    optionSubnet=`echo $rc|sed 's/[a-zA-Z]//g'|sed 's/://g'|awk '{print $3}'` #255.255.255.0
    ipStart=`echo ${optRouter%\.*}\.200`
    ipEnd=`echo ${optRouter%\.*}\.210`
    if [ "$1" == "without_option_6rd" ];then
    echo "
start           $ipStart
end             $ipEnd
interface       $interface
#option  6rd     24,48,2001:470:a837::,$optRouter 
option  subnet  $optionSubnet
opt     router  $optRouter
option  dns     168.95.1.1,4.2.2.2   # appened to above DNS servers for a total of 3
option  domain  local
option  lease   60
">$udhcpd_conf_file
    else
    echo "
start           $ipStart
end             $ipEnd
interface       $interface
option  6rd     24,48,2001:470:a837::,$optRouter 
option  subnet  $optionSubnet
opt     router  $optRouter
option  dns     168.95.1.1,4.2.2.2   # appened to above DNS servers for a total of 3
option  domain  local
option  lease   60
">$udhcpd_conf_file
    fi


echo "Setting udhcpd config files done......"
cat $udhcpd_conf_file
echo "screen -dmS udhcpd udhcpd"
screen -dmS udhcpd udhcpd
echo "ps aux |grep -i udhcpd"
ps aux |grep -i udhcpd
}

dns_v6_setting(){
    echo "Setting bind9 to supprot ipv6 DNS..."
    bind9_ipv6_conf1="/etc/named.conf"
    bind9_ipv6_conf2="/var/named/ping.com.zone"
    sed -i 's/^.*listen-on-v6 port 53.*/    listen-on-v6 port 53 { any; };/g' $bind9_ipv6_conf1
    echo "Setting $bind9_ipv6_conf1 done..."
    sleep 3
    echo "Setting $bind9_ipv6_conf2 ..."
    sup_dnsv6=`cat $bind9_ipv6_conf2 |grep -i "ipv6 IN AAAA 3001:aaaa::1"`
    if [ -z "$sup_dnsv6" ];then
        echo "ipv6 IN AAAA 3001:aaaa::1" >>$bind9_ipv6_conf2
    else
        echo "DNS server already support ipv6..."
    fi
    cat $bind9_ipv6_conf2
    echo "Restart DNS service..."
    /etc/init.d/named restart
    dns_result=$?
    if [ $dns_result -ne 0 ];then
        echo "AT_ERROR : Restart DNS service for IPv6 test failed...,please check the config file /etc/named.conf"
        exit 1
    fi
}

wan_service_config(){

    rc=`ifconfig ${G_HOST_IF1_2_0}.${U_CUSTOM_VLANETH}|grep -iw "inet addr"`
    if [ -z "$rc" ];then
        interface="${G_HOST_IF1_2_0}"
    else
        interface="${G_HOST_IF1_2_0}.${U_CUSTOM_VLANETH}"
    fi
    echo "WAN GW IP is : <${interface}>"
    rc=`ifconfig $interface|grep -iw "inet addr"`
    echo "$rc"
    optRouter=`echo $rc|sed 's/[a-zA-Z]//g'|sed 's/://g'|awk '{print $1}'` #10.16.87.76
    install_dibbler

    install_udhcpd
    dibbler_server_PS_list=`ps aux |grep -i "dibbler-server" | grep -v "grep" | grep -v "SCREEN -dmS" | awk '{print $2}'`
    if [ -z "$dibbler_server_PS_list" ];then
        echo "No dibbler server running...."
    else
        for i in $dibbler_server_PS_list
        do
            echo "Kill dibbler server process:$i"
            kill -9 $i
        done
    fi

    udhcpd_PS_list=`ps aux |grep -i "udhcpd" | grep -v "grep" | grep -v "SCREEN -dmS" |awk '{print $2}'`
    if [ -z "$udhcpd_PS_list" ];then
        echo "No udhcpd server running...."
    else
        for j in $udhcpd_PS_list
        do
            echo "Kill udhcpd server process:$j"
            kill -9 $j
        done
    fi

    screen_udhcpd_list=`screen -ls |grep -i "udhcpd"|awk '{print $1}'`
    echo "udhcpd screen ps are :$screen_udhcpd_list"
    if [ -z "$screen_udhcpd_list" ];then
        echo "No udhcpd screen..."
    else
            echo "screen -wipe udhcpd"
            screen -wipe udhcpd
    fi
    echo "Now let's check the screen ps as command:screen -ls"
    screen -ls
    echo "Disable IPv4 and IPv6 firewall..."
    echo "iptables -F"
    iptables -F

    echo "ip6tables -F"
    ip6tables -F

    echo "Enable IPv4 and IPv6 forwarding..."
    echo "1" >/proc/sys/net/ipv4/ip_forward
    echo "1" >/proc/sys/net/ipv6/conf/all/forwarding

    echo "Specified service type is $1"
    cr_service_type=$1
    echo "$1" | grep -q "_6rd"
    rc=$?
    if [ $rc -eq 0 ];then
        echo "ip -6 route flush dev tun6rd"
        ip -6 route flush dev tun6rd

        echo "ip link set dev tun6rd down"
        ip link set dev tun6rd down

        echo "ip tunnel del tun6rd"
        ip tunnel del tun6rd

        echo "ip tunnel add tun6rd mode sit remote any local $TMP_DUT_DEF_GW ttl 64"
        ip tunnel add tun6rd mode sit remote any local $TMP_DUT_DEF_GW ttl 64

        echo "ip tunnel 6rd dev tun6rd 6rd-prefix 2001:470:a837::/48 6rd-relay_prefix `echo ${TMP_DUT_DEF_GW%.*}`.0/24"
        ip tunnel 6rd dev tun6rd 6rd-prefix 2001:470:a837::/48 6rd-relay_prefix `echo ${TMP_DUT_DEF_GW%.*}`.0/24

        echo "ip link set dev tun6rd up"
        ip link set dev tun6rd up

        echo "ip -6 addr add 3001::1000/64 dev tun6rd"
        ip -6 addr add 3001::1000/64 dev tun6rd

        echo "ip -6 route del 2001:470:a837:a000::/48"
        ip -6 route del 2001:470:a837:a000::/48

        echo "ip -6 route add 2001:470:a837:a000::/48 via ::$TMP_DUT_WAN_IP dev tun6rd"
        ip -6 route add 2001:470:a837:a000::/48 via ::$TMP_DUT_WAN_IP dev tun6rd

        if [ "$cr_service_type" == "dhcp_6rd" ] ;then
            udhcpd_setting
        elif [ "$cr_service_type" == "dhcp_6rd_without_option_6rd" ];then
            udhcpd_setting without_option_6rd
        fi
    elif [ "$1" == "dhcpdv6" ];then
        #sed  -i 's/iface ".*"/iface "eth2"/g'  /etc/dibbler/server.conf
        #sed  -i 's/iface ".*"/iface "ppp0"/g'  /etc/dibbler/server.conf
        dibbler_server_config="/etc/dibbler/server.conf"



        echo "
# Example server configuration file
#
# This config. file is considered all-purpose as it instructs server
# to provide almost every configuratio
#

# Logging level range: 1(Emergency)-8(Debug)
log-level 8

log-mode short

# set preference of this server to 0 (higher = more prefered)
preference 0

iface \"$interface\" {
// also ranges can be defines, instead of exact values
t1 180
t2 270
prefered-lifetime 360
valid-lifetime 720
 
# assign addresses from this pool
class {
    pool 2001:470:a837:1000::/64
}

# assign temporary addresses from this pool
ta-class {
    pool 3000::/96
}
 
#assign /96 prefixes from this pool
pd-class {
    pd-pool 2001:470:a837:a000::/52
    pd-length 56
}

# provide DNS server location to the clients
option dns-server 3001:aaaa::1,3001:aaaa::2
 
# provide their domain name
# option domain example.com

# provide vendor-specific data (vendor-id set to 5678)
option vendor-spec 5678-0x0002aaaa

# provide ntp-server information
option ntp-server 2000::200,2000::201,2000::202

# provide timezone information
option time-zone  CET

# provide VoIP parameter (SIP protocol servers and domain names)
option sip-server 2000::300,2000::302,2000::303,2000::304
option sip-domain sip1.example.com,sip2.example.com

# provide NIS information (server addresses and domain name)
option nis-server 2000::400,2000::401,2000::404,2000::405,2000::405
option nis-domain nis.example.com

# provide NIS+ information (server addresses and domain name)
option nis+-server 2000::501,2000::502
option nis+-domain nisplus.example.com

# provide fully qualified domain names for clients
# note that first, second and third entry is reserved
# for a specific address or a DUID
option fqdn 1 64 zebuline.example.com - 2000::1,
                kael.example.com - 2000::2,
                inara.example.com - 0x0001000043ce25b40013d4024bf5,
                zoe.example.com,
                malcolm.example.com,
                kaylee.example.com,
                jayne.example.com,
                wash.example.com
}
">$dibbler_server_config
        echo "Setting $dibbler_server_config done..."
        sleep 3
    elif [ "$1" == "pppoev6" ];then
        pppoev6_config1="/etc/dibbler/server.conf"
        pppoev6_config2="/etc/ppp/pppoe-server-options"
        WAN_PPPoe_count=`ifconfig |grep -i ppp.* |awk '{print $1}' |wc -l`
        echo "WAN_PPPoe_count is ==>:<$WAN_PPPoe_count>"
        if [ $WAN_PPPoe_count -ge 1 ];then
            echo "AT_WARNING : WAN PC have more then one pppoe interface..."
            WAN_PPPoe_interface=`ifconfig |grep -i ppp.*| awk '{if(NR==Line) print $1}' Line=$WAN_PPPoe_count`
            echo "Dibbler server will use : <$WAN_PPPoe_interface>"
        else
            echo "AT_ERROR : WAN PC no PPPoE interface,please check your IPv4 enviroment..."
            exit 1
        fi
        ifconfig
        echo "So Dibbler server will use ==>: <$WAN_PPPoe_interface>"
        echo "
# Example server configuration file
#
# This config. file is considered all-purpose as it instructs server
# to provide almost every configuratio
#

# Logging level range: 1(Emergency)-8(Debug)
log-level 8

log-mode short

# set preference of this server to 0 (higher = more prefered)
preference 0

iface \"$WAN_PPPoe_interface\" {
// also ranges can be defines, instead of exact values
t1 180
t2 270
prefered-lifetime 360
valid-lifetime 720
 
# assign addresses from this pool
class {
    pool 2001:470:a837:1000::/64
}

# assign temporary addresses from this pool
ta-class {
    pool 3000::/96
}
 
#assign /96 prefixes from this pool
pd-class {
    pd-pool 2001:470:a837:a000::/52
    pd-length 56
}

# provide DNS server location to the clients
option dns-server 3001:aaaa::1,3001:aaaa::2
 
# provide their domain name
# option domain example.com

# provide vendor-specific data (vendor-id set to 5678)
option vendor-spec 5678-0x0002aaaa

# provide ntp-server information
option ntp-server 2000::200,2000::201,2000::202

# provide timezone information
option time-zone  CET

# provide VoIP parameter (SIP protocol servers and domain names)
option sip-server 2000::300,2000::302,2000::303,2000::304
option sip-domain sip1.example.com,sip2.example.com

# provide NIS information (server addresses and domain name)
option nis-server 2000::400,2000::401,2000::404,2000::405,2000::405
option nis-domain nis.example.com

# provide NIS+ information (server addresses and domain name)
option nis+-server 2000::501,2000::502
option nis+-domain nisplus.example.com

# provide fully qualified domain names for clients
# note that first, second and third entry is reserved
# for a specific address or a DUID
option fqdn 1 64 zebuline.example.com - 2000::1,
                kael.example.com - 2000::2,
                inara.example.com - 0x0001000043ce25b40013d4024bf5,
                zoe.example.com,
                malcolm.example.com,
                kaylee.example.com,
                jayne.example.com,
                wash.example.com
}">$pppoev6_config1
        echo "Setting $pppoev6_config1 done..."
        sup_ipv6_pppoe=`cat $pppoev6_config2|grep -i "ipv6 ::1000"`
        if [ -z "$sup_ipv6_pppoe" ];then
            echo "ipv6 ::1000" >>$pppoev6_config2
            echo "AT_ERROR : Lack ipv6 option for $pppoev6_config2"
            exit 1
        else
            echo "PPPoe service already support ipv6..."
        fi
    else 
        echo "AT_ERROR : Haven't specified WAN service type..."
        exit 1
    fi  
}

Out_put_ipv6_ENV(){

    rc=`ifconfig ${G_HOST_IF1_2_0}.${U_CUSTOM_VLANETH}|grep -iw "inet addr"`
    if [ -z "$rc" ];then
        interface=${G_HOST_IF1_2_0}
    else
        interface="${G_HOST_IF1_2_0}.${U_CUSTOM_VLANETH}"
    fi
    echo "WAN GW IP is : <${interface}>"
    rc=`ifconfig $interface|grep -iw "inet addr"`
    echo "$rc"
    optRouter=`echo $rc|sed 's/[a-zA-Z]//g'|sed 's/://g'|awk '{print $1}'` 

    echo "Out put IPv6 ENV to LAN ..."
    if [ -f /etc/dibbler/server.conf ];then
        U_CUSTOM_IPV6_WAN_PREFIX=`cat /etc/dibbler/server.conf|grep -A 3 ^class|grep pool|awk '{print $2}'`        
        U_CUSTOM_IPV6_DNS_SERVERS1=`cat /etc/dibbler/server.conf|grep -i dns-server|awk '{print $3}'|awk -F, '{print $1}'` 
        U_CUSTOM_IPV6_DNS_SERVERS2=`cat /etc/dibbler/server.conf|grep -i dns-server|awk '{print $3}'|awk -F, '{print $2}'` 
        U_CUSTOM_DUT_STATIC_LAN_PREFIX=`cat /etc/dibbler/server.conf|grep -A3 -i pd-class|grep -i pd-pool|awk '{print $2}'`
        U_CUSTOM_DUT_STATIC_LAN_PREFIX_LENGTH=`cat /etc/dibbler/server.conf|grep -A3 -i pd-class|grep -i pd-length|awk '{print $2}'`
    else
        echo 'AT_ERROR : /etc/dibbler/server.conf not exist,please check your dibbler server setting...'
        exit 1
    fi

    U_CUSTOM_DUT_STATIC_IPV6_ADDRESS="2001:470:a837:1000::1/64"
    Is_WAN_6rd=`echo $service_type |grep -i 6rd`
    if [ -z "$Is_WAN_6rd" ]||[ "$service_type" == "dhcp_6rd" ];then
        U_CUSTOM_DUT_STATIC_IPV6_DEFAULT_GATEWAY=`ifconfig $interface |grep -i inet6|grep -i link|awk '{print $3}'|awk -F/ '{print $1}'`
    else
        WAN_PPPoE_IF_COUNT=`ifconfig |grep -i ppp.* -c`
        if [ $WAN_PPPoE_IF_COUNT -gt 1 ];then
            echo "AT_ERROR : There are more than 1 or no pppoe interface on WAN PC,Please check your networe settings."
            echo "ifconfig |grep -i ppp.*"
            ifconfig |grep -i ppp.*
            exit 1 
        else
            WAN_PPPoE_IF=`ifconfig |grep -i ppp.* |awk '{print $1}'`
            echo "WAN pppoe interface is :<$WAN_PPPoE_IF>,and it's ipv6 link local address will set as DUT default gateway."
            U_CUSTOM_DUT_STATIC_IPV6_DEFAULT_GATEWAY=`ifconfig $WAN_PPPoE_IF |grep -i inet6|grep -i link|awk '{print $3}'|awk -F/ '{print $1}'`
    
        fi
    fi
    U_CUSTOM_DUT_STATIC_IPV6_PREFIX_LENGTH="64"
    U_CUSTOM_DUT_PPPOE_6RD_PREFIX="2001:470:a837::"
    U_CUSTOM_DUT_PPPOE_6RD_PREFIX_LENGTH="48"
    U_CUSTOM_DUT_PPPOE_IPV4_CE_MASK_LENGTH="24"
    U_CUSTOM_HOST_TIP_V6_1_2_0=`ifconfig $interface|grep -i inet6 |grep -i "Scope:Global"|awk '{print $3}'`

    echo  -e "U_CUSTOM_IPV6_WAN_PREFIX=$U_CUSTOM_IPV6_WAN_PREFIX
    U_CUSTOM_IPV6_WAN_SERVER_INTERFACE=$interface
    U_CUSTOM_IPV6_DNS_SERVERS1=$U_CUSTOM_IPV6_DNS_SERVERS1
    U_CUSTOM_IPV6_DNS_SERVERS2=$U_CUSTOM_IPV6_DNS_SERVERS2
    U_CUSTOM_DUT_STATIC_LAN_PREFIX=$U_CUSTOM_DUT_STATIC_LAN_PREFIX
    U_CUSTOM_DUT_STATIC_LAN_PREFIX_LENGTH=$U_CUSTOM_DUT_STATIC_LAN_PREFIX_LENGTH
    U_CUSTOM_DUT_STATIC_IPV6_ADDRESS=$U_CUSTOM_DUT_STATIC_IPV6_ADDRESS
    U_CUSTOM_DUT_STATIC_IPV6_DEFAULT_GATEWAY=$U_CUSTOM_DUT_STATIC_IPV6_DEFAULT_GATEWAY
    U_CUSTOM_DUT_STATIC_IPV6_PREFIX_LENGTH=$U_CUSTOM_DUT_STATIC_IPV6_PREFIX_LENGTH
    U_CUSTOM_DUT_PPPOE_6RD_PREFIX=$U_CUSTOM_DUT_PPPOE_6RD_PREFIX
    U_CUSTOM_DUT_PPPOE_6RD_PREFIX_LENGTH=$U_CUSTOM_DUT_PPPOE_6RD_PREFIX_LENGTH
    U_CUSTOM_DUT_PPPOE_IPV4_CE_MASK_LENGTH=$U_CUSTOM_DUT_PPPOE_IPV4_CE_MASK_LENGTH
    U_CUSTOM_DUT_PPPOE_IPV4_BORDE_ROUTE_ADDRESS=$TMP_DUT_DEF_GW
    U_CUSTOM_HOST_TIP_V6_1_2_0=$U_CUSTOM_HOST_TIP_V6_1_2_0" | tee $U_CUSTOM_UPDATE_ENV_FILE
    echo "Put ENV Done..."
}

main(){

    rc=`ifconfig ${G_HOST_IF1_2_0}.${U_CUSTOM_VLANETH}|grep -iw "inet addr"`
    if [ -z "$rc" ];then
        interface=${G_HOST_IF1_2_0}
    else
        interface="${G_HOST_IF1_2_0}.${U_CUSTOM_VLANETH}"
    fi
    echo "WAN GW IP is : <${interface}>"
    rc=`ifconfig $interface|grep -iw "inet addr"`
    echo "$rc"
    optRouter=`echo $rc|sed 's/[a-zA-Z]//g'|sed 's/://g'|awk '{print $1}'` 


    Is_Exist_tun6rd=`ifconfig |grep -i tun6rd`
    if [ -z "$Is_Exist_tun6rd" ];then
        echo "No 6rd tunnel exist on WAN PC."
    else
        echo "Delete tun6rd..."
        ip -6 flush tun6rd
        ip link set dev tun6rd down
        ip tunnel del tun6rd
    fi

    ip -6 r |grep -i 2001:470:a837::/48* >/tmp/ipv6_route_list
    route_list=/tmp/ipv6_route_list
    route_list_count=`grep -c -i 2001:470:a837::/48* $route_list`
    for linenumber in `seq 1 $route_list_count`
    do
        line=`sed -n "$linenumber"p $route_list`
        echo "Delete IPv6 route is : <$line>"
        ip -6 r del $line
    done

    TMP_DUT_WAN_IPV6_LOCAL=`echo ${TMP_DUT_WAN_IPV6_LOCAL%/*}`

    echo "ip -6 a a 3001:aaaa::1/64 dev $interface"
    ip -6 a a 3001:aaaa::1/64 dev $interface

    dns_v6_setting

    echo "Service type is $service_type..."
    wan_service_config $service_type
    
    echo "Waitting about 5 seconds for WAN PPPoE interface ready..."
    sleep 10
    wan_server_type=`echo $service_type |grep -i pppoe`
    if [ -z "$wan_server_type" ];then
        echo "ip -6 r add 2001:470:a837::/48 via $TMP_DUT_WAN_IPV6_LOCAL dev $interface"
        ip -6 r add 2001:470:a837::/48 via $TMP_DUT_WAN_IPV6_LOCAL dev $interface  
    else
        WAN_PPPoe_count=`ifconfig |grep -i ppp.* |awk '{print $1}' |wc -l`
        if [ $WAN_PPPoe_count -gt 1 ];then
            echo "AT_WARNING : WAN PC have more then one pppoe interface..."
            echo 'ifconfig |grep -i ppp.*'
            ifconfig |grep -i ppp.*
            WAN_PPPoe_interface=`ifconfig |grep -i ppp.*|awk '{if(NR==Line) print $1}' Line=$WAN_PPPoe_count`
        elif [ $WAN_PPPoe_count -eq 1 ];then
            WAN_PPPoe_interface=`ifconfig |grep -i ppp.*|awk '{print $1}'`
        else
            echo "AT_ERROR : WAN PC no PPPoE interface,please check your IPv4 enviroment..."
            ifconfig 
            exit 1
        fi

        echo "ip -6 r flush default"
        ip -6 r flush default
        
        echo "ip -6 r add dev $WAN_PPPoe_interface"
        ip -6 r add dev $WAN_PPPoe_interface
    fi
    ip -6 r flush dev lo

    echo "Check WAN interface information..."
    echo "ifconfig -a"
    ifconfig -a

    echo "ip -6 r"
    ip -6 r

    Out_put_ipv6_ENV
}

main
