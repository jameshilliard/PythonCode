#!/bin/bash
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#30 Jul 2012    |   1.1.0   | Ares      | fix AT BUG 10819
VER="1.1.0"
echo "$0 version : ${VER}"
help(){
	cat <<usage
			  
		-h              Show this help.
			
		-ping           Use command "ping"  to send ICMP,you can also use parameter -ICMP_COMMAND to get .
			
		-traceroute     Use command "traceroute" to send ICMP,you can also use parameter -ICMP_COMMAND to get. 
		       
		-in             Traffic in mode         
			        
		-out            Traffic out mode

		-f              Set out put log's name.

		-flag_request   Get it's ICMP check mode(request or reply).
			
`basename $0`: [-h] [-ping/-traceroute] [-f file name ] [-in/out] [-flag_request 0/1]

usage
}
#G_HOST_TIP1_1_0=172.16.10.107  #:WAN_PC_IP
#G_HOST_TIP0_1_0=192.168.55.103  #:LAN_PC_IP
#G_HOST_GW0_1_0=192.168.0.1   #gw ip address or DUT factory default  ip address 
#U_PATH_TBIN=/root/automation/bin/2.0/common
#G_CURRENTLOG=/root/automation/logs/tmp
if [ -z $U_PATH_TBIN ] ;then
	source resolve_CONFIG_LOAD.sh
else
	source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh
fi
#flag_request=1
#icmp_command=ping
flag=$flag_icmp_request
Operation=$icmp_command

while [ $# -gt 0 ]; 
do
	case $1 in
 
		-h)
		echo "Show this script Help"
		help
		exit 0
		;;

		-ping)
		echo "Set command ping to send ICMP"
		Operation=ping				
		shift 1
		;;

		-traceroute)
		echo "Set command traceroute to send ICMP"
		Operation=traceroute
		shift 1
		;;

		-in)
		echo "Traffic in send ICMP mode"
		traffic_type=in
		shift 1
		;;

		-f)
		echo "Set out put log file name"
		log_file=$2
		shift 2
		;;
		-out)
		echo "Traffic out send ICMP mode"
		traffic_type=out
		shift 1
		;;
		-flag_request)
		echo "Check is ICMP request or reply"
		flag=$2
		shift 2
		;;
		*)
		echo -e " AT_ERROR : Unknow parameter,Show the help list! "
		help
		exit 1
		;;
	esac
done
	
timeout=60
pktcount=10
#G_HOST_IF0_1_0="eth1"
#G_HOST_IF1_1_0="eth2"
interface1=$G_HOST_IF0_1_0 
interface2=$G_HOST_IF1_2_0
if [ -z $log_file ];then
    log_file=Network_check.log
fi

if [ -z $Operation ];then
    echo  -e "  AT_ERROR : Haven't get icmp command,Please make sure you defined ICMP_COMMAND in your  CONFIG_LOAD!  "
    echo -e "You can get help use parameter: -h "
exit 1
fi

if [ "$Operation" == "ping" ] && [ -z $traffic_type ];then
    echo -e " AT_ERROR : Unknow traffic type,Please make sure you defined Traffic type in your  CONFIG_LOAD!  "
    echo -e "You can get help use parameter: -h "
exit 1
fi

#if [ $-z $flag ];then
#echo -e " AT_ERROR : Unknow you want ICMP request or reply,Please make sure you defined flag_request in your  CONFIG_LOAD!"
#echo -e "You can get help use parameter: -h "
#exit 1
#fi

if [ "$Operation" == "ping" ] && [ "$traffic_type" == "in" ] && [ "$flag" == "1" ];then
 echo "Ping LAN eth1 ip address from WAN eth1==>>"
 perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/$log_file -t 120 -l $G_CURRENTLOG -d $G_HOST_TIP1_0_0 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "ping  -d $G_HOST_TIP0_1_0 -t $timeout -c $pktcount "
#First test DUT ip address 
if [ $? -ne 0 ]; then
    echo "AT_ERROR : excute sshcli.pl failed!"
    exit 1
fi
fi

if [ "$Operation" == "ping" ] && [ "$traffic_type" == "in" ] && [ "$flag" == "0" ];then
    echo "ping in 0"
    echo "Ping WAN from LAN eth1==>>"
    ifconfig eth1 $G_HOST_TIP0_1_0 up
    ip -4 addr flush dev eth2
    route del default
    route add default gw $G_HOST_GW0_1_0
    perl $U_PATH_TBIN/verifyPing.pl -d $TMP_DUT_DEF_GW -I $interface1 -t $timeout  -c $pktcount -l $G_CURRENTLOG  -o $log_file
fi

if [ "$Operation" == "ping" ] && [ "$traffic_type" == "out" ] && [ "$flag" == "1" ];then
    echo "ping out 1"
    echo "Ping WAN from LAN eth1==>>"
    ifconfig eth1 $G_HOST_TIP0_1_0 up
    ip -4 addr flush dev eth2
    route del default
    route add default gw $G_HOST_GW0_1_0
    perl $U_PATH_TBIN/verifyPing.pl -d $TMP_DUT_DEF_GW -I $interface1 -t $timeout  -c $pktcount  -l $G_CURRENTLOG -o $log_file
fi

if [ "$Operation" == "ping" ] && [ "$traffic_type" == "out" ] && [ "$flag" == "0" ];then
    echo "Ping LAN eth1 ip address from WAN eth1==>>"
    perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/$log_file -t 120 -l $G_CURRENTLOG  -d $G_HOST_TIP1_0_0 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "ping $G_HOST_TIP0_1_0  -t $timeout -c $pktcount" 

 fi

if [ "$Operation" == "traceroute" ] && [ "$traffic_type" == "in" ];then
    echo "Traceroute WAN eth1 ip address from LAN eth1==>>"  |tee $G_CURRENTLOG/$log_file	
	traceroute  -i $interface1  -I $G_HOST_TIP1_2_0 |tee -a $G_CURRENTLOG/$log_file


fi
if [ "$Operation" == "traceroute" ] && [ "$traffic_type" == "out" ];then
    echo "Traceroute LAN eth1 ip address from WAN eth1==>"    |tee $G_CURRENTLOG/$log_file
    perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/$log_file -t 120 -l $G_CURRENTLOG -d $G_HOST_TIP1_0_0 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "traceroute   -I $G_HOST_TIP0_1_0"

fi

#if [ -f $G_CURRENTLOG/$log_file ];then
#   send_result=`grep -i "Destination Host Unreachable" $G_CURRENTLOG/$log_file`
#   if [ -z $send_result ];then
#    echo -e " `basename $0` :Send ICMP use command \"$Operation\" succeed! "
#   else
#   echo -e " AT_ERROR :Destination Host Unreachable,Please check your network setting!"
#      exit 1
#   fi
#fi
#rm -f Network_check.log
#rm -f $U_PATH_TBIN/verifyTraceroute.log	
exit 0 
