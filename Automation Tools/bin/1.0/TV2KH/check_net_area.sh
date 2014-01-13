#!/bin/bash
usage="check_net_area.sh -net <net> -i <if>"
# eg check_net_area.sh -net 192.168.10.254 -i eth2
USAGE(){
cat <<usge
    USAGE : bash $0 -net 192.168.10.254 -i eth2  

    OPTIONS:

	  -net: a given net or IPAddress,this script will check if an interface's ipaddress belong to this param's net
	  -i:   a given interface,eth1 p3p2 etc...

    EXAMPLES:   bash $0 -net 192.168.1.0 -i eth1
                bash $0 -net 192.168.10.254 -i eth2
usge
}
while [ -n "$1" ];
do
    case "$1" in
    -net)
        net=$2
        echo "net : ${net}"
        shift 2
        ;;
    -i)
        iface=$2
        echo "iface : ${iface}"
        shift 2
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
ifacenet=`ifconfig $iface|grep -o 'inet addr:[^ ]*'|awk -F : '{print $2}'|awk -F . '{print $1.$2.$3}'`
#echo "iface net is : "$ifacenet
netnet=`echo $net |awk -F . '{print $1.$2.$3}'`
#echo "net's net is : "$netnet
if [ $ifacenet -eq $netnet ]; then
    echo "$iface belong to $net area"
    exit 0
else
    echo "$iface dont belong to $net area"
    exit 1
fi
