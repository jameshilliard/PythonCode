#!/bin/bash

install_vsftp(){
    if [ ! -e /usr/sbin/vsftpd ] ;then
        echo "install vsftp"
        if [ -e vsftpd/vsftpd-2.3.4-2.fc15.i686.rpm ] ;then
            rpm -ivh vsftpd/vsftpd-2.3.4-2.fc15.i686.rpm
        else
            echo "Lack vsftpd-2.3.4-2.fc15.i686.rpm"
            exit 1
        fi

        cp -f vsftpd/vsftpd-2.3.4-2.fc15.i686.rpm /var/ftp/pub/vsftpd.rpm

        chkconfig vsftpd on
    else
        echo "vsftp is intalled"
    fi
}

echo "========================================"
#install_vsftp

echo "start ftp server"
service vsftpd restart
