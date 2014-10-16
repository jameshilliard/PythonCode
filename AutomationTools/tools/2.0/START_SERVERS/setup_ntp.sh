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

install_ntp(){ 
    if [ ! -e /usr/sbin/ntpd ] ;then
        cecho info "install ntp"
        if [ -e ntpd/ntp-4.2.6p3-4.fc15.i686.rpm ] ;then
            rpm -ivh ntpd/ntp-4.2.6p3-4.fc15.i686.rpm
        else
            cecho fail "Lack of rpm packages : ntp-4.2.6p3-4.fc15.i686.rpm"
            exit 1
        fi

        chkconfig ntpd on

        grep -q "ntpd" /etc/crontab

        if [ "$?" -ne 0 ] ;then
            echo "00 10 * * * root {service ntpd restart; /sbin/hwclock -w}" >> /etc/crontab

            chkconfig crond on

            service crond restart
            service crond status
        fi

    else
        cecho info "ntpd is intalled"
    fi
}

echo "================================================================================"
#install_ntp

if [ -f ntpd/ntp.conf ] ;then
    cp -rf ntpd/ntp.conf /etc/ntp.conf
else
    cecho fail "Lack of ntp.conf"
    exit 1
fi

cecho info "stop ntpd server"
service ntpd stop

cecho info "ntpdate 50.97.210.169"
ntpdate 50.97.210.169

cecho info "start ntpd server"
service ntpd restart
service ntpd status
