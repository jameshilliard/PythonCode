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

install_pptp(){
    if [ ! -e /usr/sbin/pptpd ] ;then
        cecho info "install pptp"
        if [ -e pptpd/pptpd-1.3.4-2.fc15.i686.rpm ] ;then
            rpm -ivh pptpd/pptpd-1.3.4-2.fc15.i686.rpm
        else
            cecho fail "Lack of pptpd-1.3.4-2.fc15.i686.rpm"
            exit 1
        fi

        chkconfig pptpd on
    else
        cecho info "pptp is intalled"
    fi
}

echo "================================================================================"
#install_pptp

if [ -f pptpd/pptpd.conf ] ;then
    cp -rf pptpd/pptpd.conf /etc/pptpd.conf
else
    cecho fail "Lack of pptpd.conf"
    exit 1
fi

if [ -f pptpd/options.pptpd ] ;then
    cp -rf pptpd/options.pptpd /etc/ppp/options.pptpd
else
    cecho fail "Lack of options.pptpd"
    exit 1
fi

echo "modify /etc/sysctl.conf"
sed -i 's/\(net.ipv4.ip_forward\) *= *0/\1 = 1/g' /etc/sysctl.conf

sysctl -p

cecho info "start pptpd server"
service pptpd restart
service pptpd status

cecho info "modify iptables"
iptables -A INPUT -p tcp --dport 1723 -j ACCEPT
iptables -A INPUT -p tcp --dport 47 -j ACCEPT
iptables -A INPUT -p gre -j ACCEPT

service iptables save
service iptables restart
