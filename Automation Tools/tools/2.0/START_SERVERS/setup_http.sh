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

install_http(){ 
    if [ ! -e /usr/sbin/httpd ] ;then
        cecho info "install http"
        if [ -e httpd/apr-1.4.6-1.fc15.i686.rpm ] ;then
            rpm -ivh httpd/apr-1.4.6-1.fc15.i686.rpm
        else
            cecho fail "Lack of rpm packages : apr-1.4.6-1.fc15.i686.rpm"
            exit 1
        fi
        if [ -e httpd/apr-util-1.3.12-1.fc15.i686.rpm ] ;then
            rpm -ivh httpd/apr-util-1.3.12-1.fc15.i686.rpm
        else
            cecho fail "Lack of rpm packages : apr-util-1.3.12-1.fc15.i686.rpm"
            exit 1
        fi
        if [ -e httpd/apr-util-ldap-1.3.12-1.fc15.i686.rpm ] ;then
            rpm -ivh httpd/apr-util-ldap-1.3.12-1.fc15.i686.rpm
        else
            cecho fail "Lack of rpm packages : apr-util-ldap-1.3.12-1.fc15.i686.rpm"
            exit 1
        fi
        if [ -e httpd/httpd-tools-2.2.22-1.fc15.i686.rpm ] ;then
            rpm -ivh httpd/httpd-tools-2.2.22-1.fc15.i686.rpm
        else
            cecho fail "Lack of rpm packages : httpd-2.2.22-1.fc15.i686.rpm"
            exit 1
        fi
        if [ -e httpd/httpd-2.2.22-1.fc15.i686.rpm ] ;then
            rpm -ivh httpd/httpd-2.2.22-1.fc15.i686.rpm
        else
            cecho fail "Lack of rpm packages : httpd-2.2.22-1.fc15.i686.rpm"
            exit 1
        fi

        chkconfig httpd on
    else
        cecho info "httpd is intalled"
    fi
}

echo "================================================================================"
#install_http

if [ -f httpd/index.html ] ;then
    cp -f httpd/index.html /var/www/html/
else
    cecho fail "Lack of index.html"
    exit 1
fi

cecho info "start httpd server"
service httpd restart
service httpd status
