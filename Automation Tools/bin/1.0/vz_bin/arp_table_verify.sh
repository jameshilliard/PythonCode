#!/bin/bash -w
#---------------------------------
# Name: Tom(caipenghao)
# Description: 
# This script is used to set the environment from verify the arp table's result
# usage arp_table_verify.sh -pc1 xxx -pc2 xxx -num xxx -f xxx
#
#--------------------------------

check_interface() {
    case "$pc1" in
    $G_HOST_IP0)
        str_mac1=`ifconfig $1 | grep HWaddr | awk '{print $5}' | tr A-Z a-z`
        str_ip1=`ifconfig $1 | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
        ;;
    $G_HOST_IP1)
        rm -f /tmp/pc1_eth1_info
        perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o /tmp/pc1_eth1_info -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "ifconfig $1"
        str_mac1=`cat /tmp/pc1_eth1_info | grep HWaddr | awk '{print $5}' | tr A-Z a-z`
        str_ip1=`cat /tmp/pc1_eth1_info | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
        ;;
    $G_HOST_IP2)
        rm -f /tmp/pc1_eth1_info
        perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o /tmp/pc1_eth1_info -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "ifconfig $1"
        str_mac1=`cat /tmp/pc1_eth1_info | grep HWaddr | awk '{print $5}' | tr A-Z a-z`
        str_ip1=`cat /tmp/pc1_eth1_info | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
        ;;
    $G_HOST_IP3)
        rm -f /tmp/pc1_eth1_info
        perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o /tmp/pc1_eth1_info -u $G_HOST_USR3 -p $G_HOST_PWD3 -d $G_HOST_IP3 -v "ifconfig $1"
        str_mac1=`cat /tmp/pc1_eth1_info | grep HWaddr | awk '{print $5}' | tr A-Z a-z`
        str_ip1=`cat /tmp/pc1_eth1_info | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
        ;;
    esac
    
    case "$pc2" in
    $G_HOST_IP0)
        str_mac2=`ifconfig $2 | grep HWaddr | awk '{print $5}' | tr A-Z a-z`
        str_ip2=`ifconfig $2 | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
        ;;
    $G_HOST_IP1)
        rm -f /tmp/pc1_eth1_info
        perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o /tmp/pc1_eth1_info -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "ifconfig $2"
        str_mac2=`cat /tmp/pc1_eth1_info | grep HWaddr | awk '{print $5}' | tr A-Z a-z`
        str_ip2=`cat /tmp/pc1_eth1_info | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
        ;;
    $G_HOST_IP2)
        rm -f /tmp/pc1_eth1_info
        perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o /tmp/pc1_eth1_info -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "ifconfig $2"
        str_mac2=`cat /tmp/pc1_eth1_info | grep HWaddr | awk '{print $5}' | tr A-Z a-z`
        str_ip2=`cat /tmp/pc1_eth1_info | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
        ;;
    $G_HOST_IP3)
        rm -f /tmp/pc1_eth1_info
        perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o /tmp/pc1_eth1_info -u $G_HOST_USR3 -p $G_HOST_PWD3 -d $G_HOST_IP3 -v "ifconfig $2"
        str_mac2=`cat /tmp/pc1_eth1_info | grep HWaddr | awk '{print $5}' | tr A-Z a-z`
        str_ip2=`cat /tmp/pc1_eth1_info | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}'`
        ;;
    esac
    grep "\"${str_ip1}\": \"${str_mac1}\"" $file
    res=$?
    grep "\"${str_ip2}\": \"${str_mac2}\"" $file
    res=`expr $res + $?`
    return $res
}

####################main
while [ $# -gt 0 ]
do
    case "$1" in
    
    -pc1)
	pc1=$2
	shift
	shift
	;;
    -pc2)
	pc2=$2
	shift
	shift
	;;
    -f)
	file=$2
	shift
	shift
	;;
    -eth1)
	eth1_array=$2
	shift
	shift
	;;
    -eth2)
	eth2_array=$2
	shift
	shift
	;;
    esac       
done
result=0

eth1=`echo $eth1_array | awk -F_ '{print $1}'`
eth2=`echo $eth2_array | awk -F_ '{print $1}'`
i=1
while [ "$eth" != "" ]
do
    check_interface "$eth1" "$eth2"
    result=`expr $result + $?`
    i=$[i+1]
    eth1=`echo $eth1_array | awk -F_ "{print $\"$i\"}"`
    eth2=`echo $eth2_array | awk -F_ "{print $\"$i\"}"`
done
rm sshcli_* -rf
exit $result



