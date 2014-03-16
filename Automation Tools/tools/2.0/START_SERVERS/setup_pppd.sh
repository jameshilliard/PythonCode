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

create_pppoe_server_conf()
{
    cecho info "config file for pppoe-server"
    echo "# config file for PPPoE " > pppoed/chap-secrets

    is_any_vlan=`ifconfig -a|grep "Link encap:Ethernet"|awk '{print $1}'|grep ".*\..*"`

    if [ "" != "$is_any_vlan" ] ;then
        for viface in `ifconfig -a|grep "Link encap:Ethernet"|awk '{print $1}'|grep ".*\..*"`
        do
            vlan_idx=`echo "$viface"|cut -d\. -f2`
            #            cecho info "append PPPoE config for VLAN $vlan_idx"
            #
            #            a_ip="10"
            #            b_ip=`echo "$vlan_idx/255+17" | bc`
            #            c_ip=`echo "$vlan_idx%255" | bc`
            #
            #            tmp_ppp_server_net=$a_ip"."$b_ip"."$c_ip"."

            eth2mac=`ifconfig $server_iface|grep "HWaddr"|awk '{print $NF}'`

            echo "eth2mac is >${eth2mac}<"
            ip_b=`echo ${eth2mac}|awk -F":" '{print $4}'`
            ip_c=`echo ${eth2mac}|awk -F":" '{print $5}'`
            ip_d=`echo ${eth2mac}|awk -F":" '{print $6}'`

            ((ip_b=0x$ip_b))
            ((ip_c=0x$ip_c))
            ((ip_d=0x$ip_d))

            ip_a="10"
            ip_b=`echo "${ip_b}%100+10"|bc`
            ip_c=`echo "${ip_c}%100+10"|bc`
            ip_d=`echo "${ip_d}%100+10"|bc`

            generated_IP="${ip_a}.${ip_b}.${ip_c}.${ip_d}"
            echo "generated_IP >$generated_IP<"

            echo "# for vlan $vlan_idx
    # PPP options for the PPPoE server
    # LIC: GPL
    #require-pap
    #login
    #lcp-echo-interval 10
    #lcp-echo-failure 2


    auth
    require-chap
    #login
    #default-mru
    mru 1492
    mtu 1492
    default-asyncmap
    lcp-echo-interval 40
    lcp-echo-failure 2
    ms-dns 192.168.55.254
    ms-dns ${generated_IP}
    noipdefault
    noipx
    defaultroute
    noproxyarp
    noktune
    netmask 255.255.255.255
    logfile /var/log/pppd.log
    ipv6 ::1000
    "> pppoed/pppoe-server-options

        done

        cp -rf  pppoed/pppoe-server-options /etc/ppp

        for viface in `ifconfig -a|grep "Link encap:Ethernet"|awk '{print $1}'|grep ".*\..*"`
        do
#            vlan_idx=`echo "$viface"|cut -d\. -f2`
#            cecho info "append PPPoE config for VLAN $vlan_idx"
#
#            a_ip="10"
#            b_ip=`echo "$vlan_idx/255+17" | bc`
#            c_ip=`echo "$vlan_idx%255" | bc`

            tmp_ppp_server_net=$ip_a"."$ip_b"."$ip_c"."

            echo "# for vlan $vlan_idx
    autotest001                 *               111111                  ${tmp_ppp_server_net}150
    autotest002                 *               111111                  ${tmp_ppp_server_net}150
    autotest003                 *               111111                  ${tmp_ppp_server_net}150
    autotest004                 *               111111                  ${tmp_ppp_server_net}150
    connect@centurylink.com     *               k4rNJMDb                ${tmp_ppp_server_net}150
    verizonfios                 *               verizonfios             ${tmp_ppp_server_net}150
    pptptest001                 pptpd           111111                  ${tmp_ppp_server_net}150
    pptptest002                 pptpd           111111                  ${tmp_ppp_server_net}150
    ">> pppoed/chap-secrets

        done

        cp -rf  pppoed/chap-secrets /etc/ppp
    else
        echo "# no VLAN
   # PPP options for the PPPoE server
   # LIC: GPL
   #require-pap
   #login
   #lcp-echo-interval 10
   #lcp-echo-failure 2


   auth
   require-chap
   #login
   #default-mru
   mru 1492
   mtu 1492
   default-asyncmap
   lcp-echo-interval 40
   lcp-echo-failure 2
   ms-dns 192.168.55.254
   ms-dns 10.100.100.254
   noipdefault
   noipx
   defaultroute
   noproxyarp
   noktune
   netmask 255.255.255.255
   logfile /var/log/pppd.log
   ipv6 ::1000
"> pppoed/pppoe-server-options

        cp -rf  pppoed/pppoe-server-options /etc/ppp

        echo "# no VLAN
    autotest001                 *               111111                  10.100.100.150
    autotest002                 *               111111                  10.100.100.150
    autotest003                 *               111111                  10.100.100.150
    autotest004                 *               111111                  10.100.100.150
    connect@centurylink.com     *               k4rNJMDb                10.100.100.150
    verizonfios                 *               verizonfios             10.100.100.150
    pptptest001                 pptpd           111111                  10.100.100.150
    pptptest002                 pptpd           111111                  10.100.100.150
">> pppoed/chap-secrets

        cp -rf  pppoed/chap-secrets /etc/ppp
    fi
}

start_pppoe_server()
{
    cecho info "start pppoe-server"
    is_any_vlan=`ifconfig -a|grep "Link encap:Ethernet"|awk '{print $1}'|grep ".*\..*"`

    if [ "" != "$is_any_vlan" ] ;then

        for viface in `ifconfig -a|grep "Link encap:Ethernet"|awk '{print $1}'|grep ".*\..*"`
        do
            eth2mac=`ifconfig $server_iface|grep "HWaddr"|awk '{print $NF}'`

            echo "eth2mac is >${eth2mac}<"
            ip_b=`echo ${eth2mac}|awk -F":" '{print $4}'`
            ip_c=`echo ${eth2mac}|awk -F":" '{print $5}'`
            ip_d=`echo ${eth2mac}|awk -F":" '{print $6}'`

            ((ip_b=0x$ip_b))
            ((ip_c=0x$ip_c))
            ((ip_d=0x$ip_d))

            ip_a="10"
            ip_b=`echo "${ip_b}%100+10"|bc`
            ip_c=`echo "${ip_c}%100+10"|bc`
            ip_d=`echo "${ip_d}%100+10"|bc`

            generated_IP="${ip_a}.${ip_b}.${ip_c}.${ip_d}"
            echo "generated_IP >$generated_IP<"

            # need to limit the number of sessions per peer MAC address with -x n
            cecho info "    pppoe-server -x 1 -I $viface -L ${generated_IP}/24"
            pppoe-server  -I $viface -L ${generated_IP}/24
            TMP_DUT_DEF_GW=`echo ${generated_IP}`
        done
    else
        # need to limit the number of sessions per peer MAC address with -x n
        cecho info "pppoe-server -I $server_iface -L 10.100.100.254/24"

        pppoe-server -I $server_iface -L 10.100.100.254/24
        TMP_DUT_DEF_GW="10.100.100.254"
    fi
    echo  -e "TMP_DUT_DEF_GW=$TMP_DUT_DEF_GW" | tee $U_CUSTOM_UPDATE_ENV_FILE
}

stop_pppoe_server(){
    cecho info "killing all existing pppoe-server"

    cecho info "killall pppoe-server"
    killall pppoe-server

    cecho info "sleep 5"
    sleep 5

    for ppp in `ps aux | grep "pppoe-server " | grep -v grep | awk '{print $2}'`
    do
        cecho info "kill -9 $ppp"
        kill -9 $ppp
    done

    cecho info "killing all existing pppd"
    
    cecho info "sleep 5"
    sleep 5

    for pppd in `ps aux | grep "pppd " | grep -v grep | awk '{print $2}'`
    do
        cecho info "kill -s SIGINT $pppd"
        kill -s SIGINT $pppd
    done

    cecho info "sleep 5"
    sleep 5

    for pppd in `ps aux | grep "pppd " | grep -v grep | awk '{print $2}'`
    do
        cecho info "kill -s SIGTERM $pppd"
        kill -s SIGTERM $pppd
    done


    cecho info "sleep 5"
    sleep 5

    for pppd in `ps aux | grep "pppd " | grep -v grep | awk '{print $2}'`
    do
        cecho info "kill -9 $pppd"
        kill -9 $pppd
    done
}

updateENV(){
    configFile1="/etc/ppp/chap-secrets"
    configFile2="/etc/ppp/pppoe-server-options"
    TMP_DUT_WAN_IP=`cat ${configFile1}|grep -i "autotest001"|grep -ioE \([0-9]+.\)\{3\}[0-9]+|head -1`  
    TMP_DUT_WAN_MASK=`cat ${configFile2}|grep -i "netmask"|grep -ioE \([0-9]+.\)\{3\}[0-9]+`
    TMP_DUT_WAN_DNS_1=`cat ${configFile2}|grep -i "ms-dns"|grep -ioE \([0-9]+.\)\{3\}[0-9]+|sed -n '1p'`
    TMP_DUT_WAN_DNS_2=`cat ${configFile2}|grep -i "ms-dns"|grep -ioE \([0-9]+.\)\{3\}[0-9]+|sed -n '2p'`
    echo  -e "TMP_DUT_WAN_IP=$TMP_DUT_WAN_IP
    TMP_DUT_WAN_MASK=$TMP_DUT_WAN_MASK
    TMP_DUT_WAN_DNS_1=$TMP_DUT_WAN_DNS_1
    TMP_DUT_WAN_DNS_2=$TMP_DUT_WAN_DNS_2" | tee $U_CUSTOM_UPDATE_ENV_FILE
    echo "Put ENV Done..."

}



server_iface=$1

echo "================================================================================"

cecho info "config pppoe-server"


if [ -z "$2" ] ;then
    create_pppoe_server_conf
else
    if [ "$2" -a "$2" != "start" -a "$2" != "stop" ] ;then
        cecho fail "AT_ERROR : Invalid argument -- $2"
    fi

    if [ "$2" == "stop" -o "$2" == "start" -o -z "$2" ] ;then
        stop_pppoe_server
    fi

    if [ "$2" == "start" -o -z "$2" ] ;then
        start_pppoe_server
    fi
fi

service pppoe-server status
ps aux | grep pppoe-server | grep -v grep
updateENV
