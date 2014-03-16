#!/bin/bash
cecho(){
    case "$1" in
        "info")
            #color is green
            echo -e "\033[32m====== $2 \033[0m"
            ;;
        "warn")
            #color is yellow
            echo -e "\033[33m====== $2 \033[0m"
            ;;
        "fail")
            #color is red
            echo -e "\033[31m====== $2 \033[0m"
            ;;
        *)
            echo "====== $1 "
            ;;
    esac
}

read_conf(){
    conf_file=./config_net.conf
    if [ "$1" ] ;then
        key=$1
    else
        cecho fail "Haven't specified key word"
    fi

    eval $key=`cat $conf_file | grep -v "^#" | grep $key | awk '{print $2}'`

    if [ -z "`eval echo \"$\"$key`" ] ;then
        cecho fail "Bad config file <$key> : `eval echo "$"$key`"
        #exit 1
    else
        cecho info "$key : `eval echo "$"$key`"
    fi
}

get_network_ip(){
    network_if=`route -n | grep "^0.0.0.0" | awk '{print $8}'`
    if [ "$network_if" ] ;then
        #network_ip=`ifconfig $network_if | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
        network_ip=`ip addr show | grep "scope global $network_if" | awk '{print $2}' | awk -F'/' '{print $1}'`
    else
        cecho fail "Can not get default route"
        exit 1
    fi
}

install_dhcpd(){
    if [ ! -e /usr/sbin/dhcpd ] ;then
        cecho info "install dhcpd"
        if [ -e dhcpd/dhcp-common-4.2.1-11.P1.fc15.i686.rpm ] ;then
            rpm -ivh dhcpd/dhcp-common-4.2.1-11.P1.fc15.i686.rpm
        else
            cecho fail "Lack of rpm packages : dhcpd/dhcp-common-4.2.1-11.P1.fc15.i686.rpm"
            exit 1
        fi
        if [ -e dhcpd/dhcp-libs-4.2.1-11.P1.fc15.i686.rpm ] ;then
            rpm -ivh dhcpd/dhcp-libs-4.2.1-11.P1.fc15.i686.rpm
        else
            cecho fail "Lack of rpm packages : dhcpd/dhcp-libs-4.2.1-11.P1.fc15.i686.rpm"
            exit 1
        fi
        if [ -e dhcpd/dhcp-4.2.1-11.P1.fc15.i686.rpm ] ;then
            rpm -ivh dhcpd/dhcp-4.2.1-11.P1.fc15.i686.rpm
        else
            cecho fail "Lack of rpm packages : dhcpd/dhcp-4.2.1-11.P1.fc15.i686.rpm"
            exit 1
        fi
        chkconfig dhcpd on
    else
        cecho info "dhcpd is intalled"
    fi
}

create_dhcpd_conf_perf(){
    vlan_list=$1
    read_conf WAN_SERVER_IF

    get_network_ip

    if [ "$vlan_list" == "no" ] ;then
        cecho info "NO VLAN mode"

        echo "# untagged , no VLAN
subnet 192.168.55.0 netmask 255.255.255.0 {
    option routers                  192.168.55.254;
    option subnet-mask              255.255.255.0;
    option domain-name-servers      192.168.55.254,$network_ip;
    option time-offset              -18000;
    range dynamic-bootp             192.168.55.1 192.168.55.1;
    default-lease-time              43200;
    max-lease-time                  86400;
    min-lease-time                  43200;
}
"> $dhcp_conf

    else
        echo "#" > $dhcp_conf

        for vlan_id in `echo $VLAN_LIST | sed 's/,/ /g'`
        do
            cecho info "append dhcp config for VLAN $vlan_id"

            eth2mac=`ifconfig $WAN_SERVER_IF|grep "HWaddr"|awk '{print $NF}'`

            echo "eth2mac is >${eth2mac}<"
            ip_b=`echo ${eth2mac}|awk -F":" '{print $4}'`
            ip_c=`echo ${eth2mac}|awk -F":" '{print $5}'`
            ip_d=`echo ${eth2mac}|awk -F":" '{print $6}'`

            ((ip_b=0x$ip_b))
            ((ip_c=0x$ip_c))
            ((ip_d=0x$ip_d))

            ip_b=`echo "${ip_b}%100+10"|bc`
            ip_c=`echo "${ip_c}%100+10"|bc`
            ip_d=`echo "${ip_d}%100+10"|bc`

            generated_IP="10.${ip_b}.${ip_c}.${ip_d}"
            echo "generated_IP >$generated_IP<"

            echo "# VLAN $vlan_id
subnet 10.${ip_b}.${ip_c}.0 netmask 255.255.255.0 {
option routers                  10.${ip_b}.${ip_c}.${ip_d};
option subnet-mask              255.255.255.0;
option domain-name-servers      10.${ip_b}.${ip_c}.${ip_d},192.168.55.254;
option time-offset              -18000;
range dynamic-bootp             10.${ip_b}.${ip_c}.150 10.${ip_b}.${ip_c}.150;
default-lease-time              43200;
max-lease-time                  86400;
min-lease-time                  43200;
}
">> $dhcp_conf

    done
fi

cp $dhcp_conf /etc/dhcp/dhcpd.conf
update_ip_pool
}

create_dhcpd_conf(){
    vlan_list=$1
    read_conf WAN_SERVER_IF
    get_network_ip

    if [ "$vlan_list" == "no" ] ;then
        cecho info "NO VLAN mode"

        echo "# untagged , no VLAN
subnet 192.168.55.0 netmask 255.255.255.0 {
    option routers                  192.168.55.254;
    option subnet-mask              255.255.255.0;
    option domain-name-servers      192.168.55.254,$network_ip;
    option time-offset              -18000;
    range dynamic-bootp             192.168.55.1 192.168.55.1;
    default-lease-time              300;
    max-lease-time                  300;
    min-lease-time                  300;
}
"> $dhcp_conf

    else
        echo "#" > $dhcp_conf

        for vlan_id in `echo $VLAN_LIST | sed 's/,/ /g'`
        do
            cecho info "append dhcp config for VLAN $vlan_id"

            #            # avoid ip 172.16.x.x
            #            b_ip=`echo "$vlan_id/255+17" | bc`
            #            c_ip=`echo "$vlan_id%255" | bc`
            #
            #            echo "# VLAN $vlan_id
            #subnet 172.$b_ip.$c_ip.0 netmask 255.255.255.0 {
            #    option routers                  172.$b_ip.$c_ip.254;
            #    option subnet-mask              255.255.255.0;
            #    option domain-name-servers      172.$b_ip.$c_ip.254,192.168.55.254;
            #    option time-offset              -18000;
            #    range dynamic-bootp             172.$b_ip.$c_ip.1 172.$b_ip.$c_ip.253;
            #    default-lease-time              21600;
            #    max-lease-time                  43200;
            #}
            #">> $dhcp_conf

            eth2mac=`ifconfig $WAN_SERVER_IF|grep "HWaddr"|awk '{print $NF}'`

            echo "eth2mac is >${eth2mac}<"
            ip_b=`echo ${eth2mac}|awk -F":" '{print $4}'`
            ip_c=`echo ${eth2mac}|awk -F":" '{print $5}'`
            ip_d=`echo ${eth2mac}|awk -F":" '{print $6}'`

            ((ip_b=0x$ip_b))
            ((ip_c=0x$ip_c))
            ((ip_d=0x$ip_d))

            ip_b=`echo "${ip_b}%100+10"|bc`
            ip_c=`echo "${ip_c}%100+10"|bc`
            ip_d=`echo "${ip_d}%100+10"|bc`

            generated_IP="10.${ip_b}.${ip_c}.${ip_d}"
            echo "generated_IP >$generated_IP<"

            echo "# VLAN $vlan_id
subnet 10.${ip_b}.${ip_c}.0 netmask 255.255.255.0 {
option routers                  10.${ip_b}.${ip_c}.${ip_d};
option subnet-mask              255.255.255.0;
option domain-name-servers      10.${ip_b}.${ip_c}.${ip_d},192.168.55.254;
option time-offset              -18000;
range dynamic-bootp             10.${ip_b}.${ip_c}.150 10.${ip_b}.${ip_c}.150;
default-lease-time              300;
max-lease-time                  300;
min-lease-time                  300;
}
">> $dhcp_conf

    done
fi

cp $dhcp_conf /etc/dhcp/dhcpd.conf
update_ip_pool
}

update_ip_pool(){
    if [ -z "$SQAROOT" ];then
        SQAROOT=/root/automation
    fi
    if [ -f $SQAROOT/logs/current/runtime_env ];then
        echo "source $SQAROOT/logs/current/runtime_env"
        source $SQAROOT/logs/current/runtime_env

        if [ $U_DUT_TYPE == WECB ];then
            echo "U_DUT_TYPE=WECB,Need extend IP pool"
            sed -i '/range dynamic-bootp/ s/1;/10;/' /etc/dhcp/dhcpd.conf
            sed -i '/range dynamic-bootp/ s/150;/160;/' /etc/dhcp/dhcpd.conf
            echo "cat /etc/dhcp/dhcpd.conf"
            cat /etc/dhcp/dhcpd.conf
        else
            echo "U_DUT_TYPE=$U_DUT_TYPE,NO need extend IP pool"
        fi

    else
        echo "$SQAROOT/logs/current/runtime_env Not Exist!"
    fi
}

VLAN_LIST=${1:-"no"}
dhcp_conf=dhcpd/dhcpd.conf
echo "================================================================================"
#install_dhcpd

read_conf TESTTYPE

if [ "x${TESTTYPE}" == "xperf"  ] ; then
    create_dhcpd_conf_perf $VLAN_LIST
else
    create_dhcpd_conf $VLAN_LIST
fi



echo "" > /var/lib/dhcpd/dhcpd.leases
echo "" > /var/lib/dhcpd/dhcpd.leases~

updateENV(){
    configFile="/etc/dhcp/dhcpd.conf"
    TMP_DUT_WAN_IP=`cat ${configFile}|grep -i "range dynamic-bootp"|grep -ioE \([0-9]+.\)\{3\}[0-9]+|head -1`  
    TMP_DUT_WAN_MASK=`cat ${configFile}|grep -i "option subnet-mask"|grep -ioE \([0-9]+.\)\{3\}[0-9]+`
    TMP_DUT_DEF_GW=`cat ${configFile}|grep -i "option routers"|grep -ioE \([0-9]+.\)\{3\}[0-9]+`
    TMP_DUT_WAN_DNS_1=`cat ${configFile}|grep -i "option domain-name-servers"|grep -ioE \([0-9]+.\)\{3\}[0-9]+,\([0-9]+.\)\{3\}[0-9]+|awk -F, '{print $1}'`
    TMP_DUT_WAN_DNS_2=`cat ${configFile}|grep -i "option domain-name-servers"|grep -ioE \([0-9]+.\)\{3\}[0-9]+,\([0-9]+.\)\{3\}[0-9]+|awk -F, '{print $2}'`
    
    echo  -e "TMP_DUT_WAN_IP=$TMP_DUT_WAN_IP
    TMP_DUT_WAN_MASK=$TMP_DUT_WAN_MASK
    TMP_DUT_DEF_GW=$TMP_DUT_DEF_GW
    TMP_DUT_WAN_DNS_1=$TMP_DUT_WAN_DNS_1
    TMP_DUT_WAN_DNS_2=$TMP_DUT_WAN_DNS_2" | tee $U_CUSTOM_UPDATE_ENV_FILE
    echo "Put ENV Done..."

}
updateENV
#cecho info "start dhcpd server"
#service dhcpd restart
#service dhcpd status
