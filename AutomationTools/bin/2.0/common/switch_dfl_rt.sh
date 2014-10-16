#!/bin/bash
# History	  :
#   DATE		|   REV  | AUTH   | INFO
#13 Dec 2011	|   1.0.0   | howard	| Inital Version	   
# 9 Jan 2012	|   1.0.1   | Alex	  | modified the option of command 'dhclient',add '-pf' option
#10 Jan 2012	|   1.0.2   | Alex	  | fix bug after modifying last time. Using "ifconfig -a" instead of "ifconfig" to find the interface connecting to DUT.
#21 Mar 2012	|   1.0.3   | howard	| added release and disconn wlan from wpa routine 

REV="$0 version 1.0.3 (21 Mar 2012)"
# print REV

echo "${REV}"

#$G_HOST_GW0_1_0=192.168.1.254 $G_HOST_IF0_1_0=eth1 $G_HOST_IF0_2_0=eth2
usage="switch_dfl_rt.sh [-test] -i <interface> -addr <ipaddress> -gw <gateway>"
USAGE(){
	cat <<usge
	USAGE : bash $0 [-test] -i <interface> -addr <IPAddress> -gw <gateway>  
	
	OPTIONS:
	
		  -test:	test mode,set all the global variables if it is not run in testcase
		  -i:	  the interface that you want to swtich the default route to,eg. eth1 p3p1 etc..
		  -addr:	the IPAddress of the given interface,this param can be omitted
					if omitted,it just ifconfig interface up
		  -gw:	the gateway of the default route
	
	NOTE : if you DON'T run this script in testcase , please put [-test] option in front of all the other options
		   in testcases,if you omit -i and -gw and -addr,it will switch the default route to the first NIC card connected
		   to the DUT
	
	EXAMPLES:   bash $0 -i eth2 -addr 192.168.1.225 -gw 192.168.1.254
				bash $0 -i eth1 -gw 192.168.1.254
				bash $0
usge

}

interface=$G_HOST_IF0_1_0

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
		G_HOST_GW0_1_0=192.168.1.1
		G_HOST_GW0_2_0=192.168.1.1
		G_HOST_IF0_1_0=eth1
		G_HOST_IF0_2_0=eth2
		G_HOST_TIP0_1_0=192.168.1.100
		G_HOST_TIP0_2_0=192.168.1.200
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

if [ -z "$U_CUSTOM_TESTBED_SV" ]; then
    U_CUSTOM_TESTBED_SV=0 
fi

if [ "$interface" == "$G_HOST_IF0_1_0" -o  "$interface" == "$G_HOST_IF0_2_0" ] ;then
	for wl_ifc in `iwconfig  2> /dev/null | grep -o ".*SSID"|awk '{print $1}'`
	do
		echo "  wpa_cli -i $wl_ifc disconnect"
		wpa_cli -i $wl_ifc disconnect
		
		echo "  ip -4 addr flush dev $wl_ifc"
		ip -4 addr flush dev $wl_ifc

		echo "		removing existing /tmp/${wl_ifc}.conf"
		rm -f /tmp/${wl_ifc}.conf
	done
else
	for wl_ifc in `iwconfig  2> /dev/null | grep -o ".*SSID"|awk '{print $1}'`
	do
		if [ "$wl_ifc" != "$interface" ] ;then
			echo "  wpa_cli -i $wl_ifc disconnect"
			wpa_cli -i $wl_ifc disconnect
			
			echo "  ip -4 addr flush dev $wl_ifc"
			ip -4 addr flush dev $wl_ifc

			echo "		removing existing /tmp/${wl_ifc}.conf"
			rm -f /tmp/${wl_ifc}.conf
		fi
	done
fi

	
route del default
if [ -z "$ipaddr" ]; then
	echo "ipaddr not given"
	ifconfig ${interface} up
else
    if [ $U_CUSTOM_TESTBED_SV = 0 ]; then	
        ifconfig ${interface} $ipaddr/24 up
    elif [ $U_CUSTOM_TESTBED_SV = 1 ]; then
        echo "/sbin/ifup $interface"
        /sbin/ifup $interface
    else
        echo "AT_ERROR : invalid parameter U_CUSTOM_TESTBED_SV"
        exit 1
    fi
fi

bcast=`echo $gtway |cut -d. -f 1,2,3`"\."
echo $bcast
downifs=`ifconfig -a | grep -B 1 $bcast |grep HWaddr |grep -v $interface| awk '{print $1}'`
for i in `echo $downifs`
do
    if [ $U_CUSTOM_TESTBED_SV = 0 ]; then	
        ip -4 addr flush dev $i
        echo "shutting down $i"
    elif [ $U_CUSTOM_TESTBED_SV = 1 ]; then
        echo "/sbin/ifdown $i"
        /sbin/ifdown $i
    else
        echo "AT_ERROR : invalid parameter U_CUSTOM_TESTBED_SV"
        exit 1
    fi
done

ifconfig $interface |grep "inet addr:"

if [ $U_CUSTOM_TESTBED_SV = 0 -a $? -eq 0 ] ;then
	route add default gw $gtway dev $interface
fi

ifconfig
route -n
