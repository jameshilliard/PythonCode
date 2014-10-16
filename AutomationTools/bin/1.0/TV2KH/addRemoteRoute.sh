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
     *)
    echo $usage
    exit 1
    ;;
esac
done

add(){
    net=`route -n|grep $iface|awk '{print $1}'|grep -v '^0'`
    echo "the destination net to be added on remote host is "$net
    perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/routetable.log -d $G_HOST_TIP1_0_0 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "route del -net $net/24" -v "route add -net $net/24 gw $TMP_DUT_WAN_IP" -v "route -n"
}

del(){
    net=`route -n|grep $iface|awk '{print $1}'|grep -v '^0'`
    echo "the destination net to be removed on remote host is "$net
    perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/routetable.log -d $G_HOST_TIP1_0_0 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "route del -net $net/24" -v "route -n"
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
