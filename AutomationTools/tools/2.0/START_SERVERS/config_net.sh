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
    if [ "$1" ] ;then
        key=$1
    else
        cecho fail "Haven't specified key word"
    fi

    eval $key=`cat $conf_file | grep -v "^#" | grep $key | awk '{print $2}'`

    if [ -z "`eval echo \"$\"$key`" ] ;then
        cecho fail "Bad config file <$key> : `eval echo "$"$key`"
        exit 1
    else
        cecho info "$key : `eval echo "$"$key`"
    fi
}

check_conf_file(){
    echo $split
    cecho info "check config file"

    if [ -f "$conf_file" ] ;then
        cecho info "Config file found , read config value from <$conf_file>"
    else

        cecho fail "Config file NOT found : <$conf_file>"
        exit 1
    fi
}

parse_conf_file(){
    echo $split
    cecho info "parse config file"

    read_conf LAN_MNGMT_IP
    read_conf WAN_MNGMT_IP
    read_conf WAN_MNGMT_IF
    read_conf WAN_NETWORK_IF
    read_conf WAN_SERVER_IF
    read_conf VLAN_LIST
    read_conf reconfig
}

rm_vlan(){
    echo $split
    cecho info "remove vlan"

    for viface in `ifconfig -a | grep "Link encap:Ethernet" | awk '{print $1}' | grep ".*\..*"`
    do
        cecho info "vconfig rem $viface"
        vconfig rem $viface
    done
}

shutting_down_ifs(){
    echo $split
    cecho info "shutting down interface"

    for iface in `ifconfig | grep "Link encap:Ethernet" | awk '{print $1}'`
    do
        if [ "$iface" != "$WAN_MNGMT_IF" ] ;then
            cecho info "ip flush : $iface"
            ip -4 addr flush dev $iface
        fi
    done
}

set_wan_management_ip(){
    echo $split
    cecho info "set WAN management IP"

    cecho info "ifconfig $WAN_MNGMT_IF $WAN_MNGMT_IP/24 up"
    ifconfig $WAN_MNGMT_IF $WAN_MNGMT_IP/24 up
}

set_nfs(){
    echo $split
    cecho info "set nfs"

    if [ "$LAN_MNGMT_IP" != "no" ] ;then
        nfs_path=${SQAROOT:-"/root/automation/"}

        cecho info "mount -v -t nfs -o nolock $LAN_MNGMT_IP:$nfs_path $nfs_path"
        mount -v -t nfs -o nolock $LAN_MNGMT_IP:$nfs_path $nfs_path

        ls_rc=`ls $nfs_path`

        if [ -z "$ls_rc" ] ;then
            cecho fail "Enable nfs failed"
            exit 1
        fi
    elif [ "$LAN_MNGMT_IP" == "no" ] ;then
        cecho info "Skipping nfs"
    else
        cecho fail "Bad config file <LAN_MNGMT_IP> : <$LAN_MNGMT_IP>"
        exit 1
    fi
}

set_wan_network_if(){
    echo $split
    cecho info "set WAN network interface"

    cecho info "WAN_NETWORK_IF : <$WAN_NETWORK_IF>"
    NIC=`echo $WAN_NETWORK_IF | awk 'BEGIN {FS=":"} {print $1}'`
    IP=` echo $WAN_NETWORK_IF | awk 'BEGIN {FS=":"} {print $2}'`
    GW=` echo $WAN_NETWORK_IF | awk 'BEGIN {FS=":"} {print $3}'`

    if [ "$NIC" -a "$IP" -a "$GW" ] ;then
        ifconfig -a | grep -q "$NIC[: ]"

        if [ $? -ne 0 ] ;then
            cecho fail "No such device for WAN network : <$NIC>"
            exit 1
        else
            cecho info "Manual mode :"

            cecho info "ip -4 addr flush dev $NIC"
            ip -4 addr flush dev $NIC

            cecho info "ifconfig $NIC $IP/24 up"
            ifconfig $NIC $IP/24 up

            cecho info "route del default"
            route del default 2> /dev/null

            cecho info "route add default gw $GW"
            route add default gw $GW
        fi
    elif [ "$NIC" -a "$IP" -a -z "$GW" ] ;then
        cecho fail "Bad config file <WAN_NETWORK_IF> : <$WAN_NETWORK_IF>"
        exit 1
    elif [ "$NIC" -a -z "$IP" ] ;then
        ifconfig -a | grep -q "$NIC[: ]"

        if [ $? -ne 0 ] ;then
            cecho fail "No such device for WAN network : <$NIC>"
            exit 1
        else
            cecho info "DHCP mode :"

            cecho info "dhclient -v -r $NIC"
            dhclient -v -r $NIC

            cecho info "dhclient -v $NIC"
            dhclient -v $NIC
        fi
    elif [ -z "$NIC" ] ;then
        cecho fail "Bad config file <WAN_NETWORK_IF> : <$WAN_NETWORK_IF>"
        exit 1
    fi

    # check default route
    route -n | grep -q "^0.0.0.0"
    if [ $? -ne 0 ] ;then
        cecho fail "Can not get default route"
        exit 1
    fi


    cecho info "cp ./resolv.conf /etc/resolv.conf"
    cp ./resolv.conf /etc/resolv.conf
}

set_wan_server_if(){
    echo $split
    cecho info "set WAN server interface"

    ifconfig -a | grep -q "$WAN_SERVER_IF[: ]"

    if [ $? -ne 0 ] ;then
        cecho fail "No such device for WAN SERVER : <$WAN_SERVER_IF>"
        exit 1
    fi

#    cecho info "ifconfig $WAN_SERVER_IF down"
#    ifconfig $WAN_SERVER_IF down

    cecho info "ifconfig $WAN_SERVER_IF 192.168.55.254/24 up"
    ifconfig $WAN_SERVER_IF 192.168.55.254/24 up
}

start_vlan(){
    echo $split
    cecho info "start VLAN"

    if [ "$VLAN_LIST" == "no" ] ;then
        cecho info "NO VLAN"
    else
        for vlan_id in `echo $VLAN_LIST | sed 's/,/ /g'`
        do
            cecho info "start VLAN $vlan_id"

#            # avoid ip 172.16.x.x
#            b_ip=`echo "$vlan_id/255+17" | bc`
#            c_ip=`echo "$vlan_id%255" | bc`
#
#            cecho info "vconfig add $WAN_SERVER_IF $vlan_id"
#            vconfig add $WAN_SERVER_IF $vlan_id 2>/dev/null
#
#            cecho info "ifconfig $WAN_SERVER_IF.$vlan_id 172.$b_ip.$c_ip.254/24 up"
#            ifconfig $WAN_SERVER_IF.$vlan_id 172.$b_ip.$c_ip.254/24 up

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

            cecho info "vconfig add $WAN_SERVER_IF $vlan_id"
            vconfig add $WAN_SERVER_IF $vlan_id 2>/dev/null

            cecho info "ifconfig $WAN_SERVER_IF.$vlan_id 10.${ip_b}.${ip_c}.${ip_d}/24 up"
            ifconfig $WAN_SERVER_IF.$vlan_id 10.${ip_b}.${ip_c}.${ip_d}/24 up

        done
    fi
}

start_servers(){
    bash setup_dhcpd.sh $VLAN_LIST
    bash setup_pppd.sh $WAN_SERVER_IF
    bash setup_gw.sh
#    bash setup_radius.sh #reconfig $conf_file
    bash setup_radius.sh '1' $conf_file
    bash setup_ftp.sh
    bash setup_http.sh
    bash setup_dns.sh
    bash setup_ntp.sh
    bash setup_pptp.sh
}

check_mail(){
    echo "starting to check mail settings"

#    if [ "${reconfig}" == "1" ] ;then
    if [ "1" == "1" ] ;then
        echo "# #
# By default we allow relaying from localhost...
Connect:localhost.localdomain       RELAY
Connect:localhost           RELAY
Connect:127.0.0.1           RELAY"> /etc/mail/access

    for i in `ifconfig |grep "inet addr"|grep -v "127.0.0.1"|awk '{print $2}'|sed "s/addr://g"|sed "s/\.[0-9]*$//g"`;
    do
        echo "$i                RELAY"|tee -a /etc/mail/access
    done

    cat /etc/mail/access


    makemap hash /etc/mail/access </etc/mail/access

    service sendmail restart
    fi

    }

conf_file=./config_net.conf

split="================================================================================"

main(){
    check_conf_file

    parse_conf_file

    rm_vlan

    shutting_down_ifs

####    set_wan_management_ip

####    set_nfs

    set_wan_network_if

    set_wan_server_if

    start_vlan

    start_servers

    check_mail
}

main

echo $split
ifconfig

route -n
