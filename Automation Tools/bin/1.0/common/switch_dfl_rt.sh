#!/bin/bash
#$G_HOST_GW0_1_0=192.168.1.254 $G_HOST_IF0_1_0=eth1 $G_HOST_IF0_2_0=eth2
usage="switch_dfl_rt.sh [-test] -i <interface> -addr <ipaddress> -gw <gateway>"
USAGE(){
    cat <<usge
    USAGE : bash $0 [-test] -i <interface> -addr <IPAddress> -gw <gateway>  
    
    OPTIONS:
    
    	  -test:    test mode,set all the global variables if it is not run in testcase
    	  -i:       the interface that you want to swtich the default route to,eg. eth1 p3p1 etc..
    	  -addr:    the IPAddress of the given interface,this param can be omitted
                    if omitted,it just ifconfig interface up
    	  -gw:      the gateway of the default route
    
    NOTE : if you DON'T run this script in testcase , please put [-test] option in front of all the other options
           in testcases,if you omit -i and -gw and -addr,it will switch the default route to the first NIC card connected
           to the DUT
    
    EXAMPLES:   bash $0 -i eth2 -addr 192.168.1.225 -gw 192.168.1.254
                bash $0 -i eth1 -gw 192.168.1.254
                bash $0
usge

}
interface=$G_HOST_IF0_1_0
#ipaddr=$G_HOST_TIP0_1_0
gtway=$G_HOST_GW0_1_0
while [ -n "$1" ];
do
    case "$1" in
    -addr)
        ipaddr=$2
        echo "ipaddr : ${ipaddr}"
        shift 2
        ;;
    -gw)
        gtway=$2
        echo "gateway : ${gtway}"
        shift 2
        ;;
    -i)
        interface=$2
        echo "target interface : ${interface}"
        shift 2
        ;;
    -test)
        G_HOST_GW0_1_0=192.168.1.254
        G_HOST_GW0_2_0=192.168.1.254
        G_HOST_IF0_1_0=eth1
        G_HOST_IF0_2_0=eth2
        G_HOST_TIP0_1_0=192.168.1.200
        G_HOST_TIP0_2_0=192.168.1.225
        shift 1
        ;;
    -help)
        USAGE
        exit 1
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done
route del default
if [ -z $ipaddr ]; then
    echo "ipaddr not given"
    ifconfig ${interface} up
else
    ifconfig ${interface} $ipaddr/24 up
fi

bcast=`ifconfig ${interface} | grep -o 'Bcast:[^ ]*'`
echo $bcast
downifs=`ifconfig | grep -B 1 $bcast |grep HWaddr |grep -v $interface| awk '{print $1}'`
for i in `echo $downifs`
do
    dhclient -r $i
    dhclient $i
    dhclient -r $i
    ifconfig $i down
    echo "shutting down $i"
done
route add default gw $gtway dev $interface
ifconfig
route -n
