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

install_radius(){
    cecho info "install radius"
    if [ ! -e /usr/sbin/radiusd ] ;then
        if [ -e freeradius/freeradius-2.1.12-2.fc15.i686.rpm ] ;then
            rpm -ivh freeradius/freeradius-2.1.12-2.fc15.i686.rpm
        else
            cecho fail "Lack of freeradius-2.1.12-2.fc15.i686.rpm"
            exit 1
        fi
        if [ -e freeradius/freeradius-utils-2.1.12-2.fc15.i686.rpm ] ;then
            rpm -ivh freeradius/freeradius-utils-2.1.12-2.fc15.i686.rpm
        else
            cecho fail "Lack of freeradius-utils-2.1.12-2.fc15.i686.rpm"
            exit 1
        fi

        chkconfig radiusd on
    else
        cecho info "radius server is intalled"
    fi    
}

create_clients(){
    cecho info "Create clients files"
    rm -f freeradius/clients.conf

    # dhcpd
    grep "subnet " /etc/dhcp/dhcpd.conf | awk '{print $2" "$4}' | sort -u -o dhcpd.tmp
    
    lines=`cat dhcpd.tmp | wc -l`

    for line_index in `seq 1 $lines`
    do
        line=`sed -n "$line_index"p dhcpd.tmp`
        prefix=`ipcalc -p $line | awk -F '=' '{print $2}'`
        network=`echo $line | awk '{print $1}'`
        echo "client $network/$prefix {
    secret    = automation
    shortname = automation-dhcp-$line_index
}
">> freeradius/clients.conf
    done
    rm -f dhcpd.tmp

#    # PPPoE
#    ps aux | grep "pppoe-server " | grep -v "grep" | awk '{print $NF}' | sort -u -o pppoe.tmp
#
#    lines=`cat pppoe.tmp | wc -l`
#
#    for line_index in `seq 1 $lines`
#    do
#        line=`sed -n "$line_index"p pppoe.tmp`
#        network=`ipcalc -n $line | awk -F '=' '{print $2}'`
#        prefix=`echo $line | awk -F '/' '{print $2}'`
#        echo "client $network/$prefix {
#    secret    = automation
#    shortname = automation-pppoe-$line_index
#}
#">> freeradius/clients.conf
#    done
#    rm -f pppoe.tmp
}

create_certs(){
    cecho info "Create certs"
    if [ ! -f freeradius/certs/ca.cnf -a -f freeradius/certs/server.cnf -a -f freeradius/certs/client.cnf ] ;then
        cecho fail "Lack of certificate config file : ca.cnf server.cnf client.cnf"
        exit 1
    else
        cp -rf freeradius/certs/ca.cnf freeradius/certs/server.cnf freeradius/certs/client.cnf /etc/raddb/certs/
    fi

    cd /etc/raddb/certs/
    make destroycerts
    make
    make client

    if [ ! -d "$SQAROOT/certs" ] ;then
        cecho warn "$SQAROOT/certs not exist , makesure service : nfs is start"
        cecho warn "you can copy /etc/raddb/certs/client.pem /etc/raddb/certs/client.key /etc/raddb/certs/ca.pem by yourself"
    else
        cp -rf client.pem client.key ca.pem $SQAROOT/certs/
    fi
    cd -
}

reconfig=${1:-"1"}
conf_file=${2:-"./config_net.conf"}
echo "================================================================================"

if [ "$reconfig" != "1" ] ;then
    cecho info "The reconfig flag is not 1"
    cecho info "Skipping config radius server..."

    create_clients

    if [ ! -f freeradius/clients.conf ] ;then 
        cecho fail "Create clients.conf failed"
        exit 1
    fi

    # copy config file to /etc/raddb/
    cp -rf freeradius/clients.conf /etc/raddb/

    # rastart radius server
    service radiusd restart
    service radiusd status

    exit 0
else
    if [ -f "$conf_file" ] ;then
        sed -i '/reconfig/ s/1/0/g' $conf_file
    fi
fi

# makesure install freeradius
#install_radius

# makesure config directories is existing
if [ ! -d /etc/raddb ] ;then
    cecho fail "No such directory : /etc/raddb"
    exit 1
fi

if [ ! -d /etc/raddb/certs ] ;then
    cecho fail "No such directory : /etc/raddb/certs"
    exit 1
fi

# maksesure custom config files is existing
if [ ! -f freeradius/radiusd.conf ] ;then
    cecho fial "No such custom config file : `pwd`/freeradius/radiusd.conf"
    exit 1
fi

if [ ! -f freeradius/eap.conf ] ;then 
    cecho fail "No such custom config file : `pwd`/freeradius/eap.conf"
    exit 1
fi

create_clients

if [ ! -f freeradius/clients.conf ] ;then 
    cecho fail "Create clients.conf failed"
    exit 1
fi

# copy config file to /etc/raddb/
cp -rf freeradius/radiusd.conf freeradius/eap.conf freeradius/clients.conf /etc/raddb/

create_certs

cecho info "start radius server"
service radiusd restart
service radiusd status
