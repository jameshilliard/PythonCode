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

install_dns(){ 
    if [ ! -e /usr/sbin/named ] ;then
        cecho info "install DNS server"
        if [ -e bind/bind-license-9.8.3-1.fc15.noarch.rpm ] ;then
            rpm -ivh bind/bind-license-9.8.3-1.fc15.noarch.rpm
        else
            cecho fail "Lack of rpm packages : bind-license-9.8.3-1.fc15.noarch.rpm"
            exit 1
        fi
        if [ -e bind/bind-libs-9.8.3-1.fc15.i686.rpm ] ;then
            rpm -ivh bind/bind-libs-9.8.3-1.fc15.i686.rpm
        else
            cecho fail "Lack of rpm packages : bind-libs-9.8.3-1.fc15.i686.rpm"
            exit 1
        fi
        if [ -e bind/bind-libs-lite-9.8.3-1.fc15.i686.rpm ] ;then
            rpm -ivh bind/bind-libs-lite-9.8.3-1.fc15.i686.rpm
        else
            cecho fail "Lack of rpm packages : bind-libs-lite-9.8.3-1.fc15.i686.rpm"
            exit 1
        fi
        if [ -e bind/bind-9.8.3-1.fc15.i686.rpm ] ;then
            rpm -ivh bind/bind-9.8.3-1.fc15.i686.rpm
        else
            cecho "Lack of rpm packages : bind-9.8.3-1.fc15.i686.rpm"
            exit 1
        fi

        chkconfig named on
    else
        cecho info "DNS server is intalled"
    fi
}

### makesure the traceroute more then 1 step
set_default_gateway(){
    def_gw=`route -n | awk '{if (/^0.0.0.0/) print $2}'`
    if [ "$def_gw" ] ;then
        if [ -f "bind/trcrt.com.zone" ] ;then
            cp -f bind/trcrt.com.zone bind/trcrt.com.zone.bak
            echo "www IN A $def_gw" >> bind/trcrt.com.zone
        fi
    else
        cecho warn "Can not get default gateway"
        cecho warn "Please config /var/named/trcrt.com.zone by yourself"
    fi
}

echo "================================================================================"
#install_dns

set_default_gateway

# cp config
if [ -f "bind/named.conf" -a -f "bind/named.localhost" -a -f "bind/at.com.zone" -a -f "bind/vosky.com.zone" -a -f "bind/trcrt.com.zone" -a -f "bind/ping.com.zone" -a -f "bind/at1.com.zone" -a -f "bind/at2.com.zone" -a -f "bind/xdev.motive.com.zone" ] ;then
    mv -f /etc/named.conf /etc/named.conf.bak
    cp -rf bind/named.conf /etc/named.conf
    #cp -rf bind/named.localhost bind/at.com.zone bind/vosky.com.zone bind/trcrt.com.zone bind/ping.com.zone bind/at1.com.zone bind/at2.com.zone bind/xdev.motive.com.zone /var/named/
    cp -rf bind/named.localhost bind/*.zone /var/named/
    cp -rf bind/trcrt.com.zone.bak bind/trcrt.com.zone
else
    cecho fail "Lack of named.conf or zone files"
    exit 1
fi

if [ -f "bind/named" ] ;then
    cp -rf bind/named /etc/sysconfig/named
else
    cecho fail "Lack of named files"
    exit 1
fi

# change auth
#chgrp named /etc/named.conf /var/named/named.localhost /var/named/at.com.zone /var/named/vosky.com.zone /var/named/trcrt.com.zone /var/named/at1.com.zone /var/named/at2.com.zone /var/named/ping.com.zone /var/named/xdev.motive.com.zone
chgrp named /etc/named.conf /var/named/*
#echo "Force to kill all named process..."
#named_id=`ps aux |grep -i named |grep -v "grep"|awk '{print $2}'`
#if [ -n "$named_id" ];then
#    for i in "$named_id"
#        do
#            kill -9 $i
#        done
#fi
#ps aux |grep -i named
cecho info "start DNS server"
service named restart
service named status

echo "==============DNS start log============="
tail -20  /var/log/messages | grep named
