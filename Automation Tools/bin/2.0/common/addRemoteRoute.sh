#!/bin/bash
opt=add
while [ $# -gt 0 ];
do
    case "$1" in
    -test)
    U_PATH_TBIN=./
    G_CURRENTLOG=/tmp
    G_HOST_TIP1_0_0=192.168.100.40
    G_HOST_USR1=root
    G_HOST_PWD1=actiontec
    TMP_DUT_WAN_IP=192.168.10.16
    shift 1
    ;;
    -del)
        opt=del
        shift 1
        ;;
    -i)
        iface=$2
        shift 2
        ;;
    -gw)
        TMP_DUT_WAN_IP=$2
        echo "re-define TMP_DUT_WAN_IP to "$2
        shift 2
        ;;
     *)
    echo $usage
    exit 1
    ;;
esac
done

#if [ -z $U_PATH_TBIN ] ;then
#	source resolve_CONFIG_LOAD.sh
#else
#	source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh
#fi
#
add(){
#    if [ "$traffic_type" == "out" ]; then
#        echo "traffic out testing,needn't add remote route!"
#        exit 0
#    fi
    net=`route -n|grep $iface|awk '{print $1}'|grep -v '^0'`
    echo "the destination net to be added on remote host is "$net
    perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/routetable.log -d $G_HOST_TIP1_0_0 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "route del -net $net/24" -v "route add -net $net/24 gw $TMP_DUT_WAN_IP" -v "route -n" -v "ifconfig" -v "ping $G_HOST_TIP0_1_0 -c 5"
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : excute sshcli.pl failed!"
    fi
}

del(){
    net=`route -n|grep $iface|awk '{print $1}'|grep -v '^0'`
    echo "the destination net to be removed on remote host is "$net
    perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/routetable.log -d $G_HOST_TIP1_0_0 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "route del -net $net/24" -v "route -n" -v "ifconfig"
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : excute sshcli.pl failed!"
    fi
}

#netres=`cat $G_CURRENTLOG/routetable.log|grep "^$net"|awk '{print $2}'`
#if [ "$netres" == "$TMP_DUT_WAN_IP" ]; then
#	echo "passed"
#	exit 0
#else
#	echo "error"
#	exit 1
#fi

$opt

exit 0
