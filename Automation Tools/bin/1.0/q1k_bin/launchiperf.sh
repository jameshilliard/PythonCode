#! /bin/sh 
##########################################################################
# This script is supposed to run under testframework
# The purpose is to start iperf daemon on LAN PC, iperf client on WAN PC 
#  
#   
#
#
#   Created by Hugo 11-10-2009
#
#########################################################################

function kill_iperfdaemon
{
  pidip=`ps aux | grep iperf | grep -v grep | grep -v launch | awk '{ print $2 }'`
  for i in $pidip
  do
   kill -9 $i 2>/dev/null
  done
}

# For debug
function for_debug
{
G_HOST_IP1="192.168.100.52/24"
G_HOST_TIP1_1_0="10.10.10.47/24"
G_HOST_USR1="root"
G_HOST_PWD1="actiontec"
G_CURRENTLOG="/tmp"
G_PROD_IP_ETH0_0_0="192.168.1.1/24"
G_PROD_IP_ETH1_0_0="10.10.10.254/24"
G_HOST_GW0_0_0="192.168.100.1"
}

protype='tcp'
duttype='q1000'
bind_ip=`echo ${G_HOST_TIP1_1_0%/*}`
bind_listen_ip=`echo ${G_HOST_TIP0_1_0%/*}`
while [ $# -gt 0 ]
do
  case "$1" in
    -p)
       serport=$2
       shift
       shift
       ;;
    -h)
       echo "Usage: launchiperf.sh [-p <iperf listen port local>] [-dp <dut listen port>] [-ptype <udp/tcp>] [-dut <bhr2,q1000>] [-B <bind ip>]"
       exit 0
       ;;
    -dp)
       dutport=$2
       shift
       shift
       ;;
    -ptype)
       protype=$2
       shift
       shift
       ;;
    -dut)
       duttype=$2
       shift
       shift
       ;;
    -B)
       bind_ip=$2
       shift
       shift
       ;;
    *)
       echo "Usage: launchiperf.sh [-p <iperf listen port>] [-dp <dut listen port>] [-ptype <udp/tcp>] [-dut <bhr2,q1000>]"
       exit 0
   esac
done

kill_iperfdaemon
CLIHOST=`echo ${G_HOST_IP1%/*}`
if [ $duttype == 'q1000' ]; then
    WANDUT=`cat $G_CURRENTLOG/wanip.log`
else
    WANDUT=`echo ${G_PROD_IP_ETH1_0_0%/*}`
fi
GATEW=`echo ${G_PROD_IP_ETH0_0_0%/*}`

echo "bind_ip $bind_ip"
echo "proto type $protype"
echo "dut type $duttype"
echo "dut port $dutport"
echo "WAN DUT $WANDUT"
echo "GATEW $GATEW"

defgw=`route -n | grep ^0.0.0.0 | awk '{print $2}' | tr -d ' '`
echo "System default gw: $defgw"
if [ -z $defgw ]; then
    echo "there is no a default gw, test would take G_HOST_GW0_0_0=$G_HOST_GW0_0_0 as it"
    defgw=$G_HOST_GW0_0_0
fi

if [ $GATEW != $defgw ]; then
  echo "excute: route del default gw $defgw"
  route del default gw $defgw
  echo "excute: route add default gw $GATEW"
  route add default gw $GATEW
fi

if [ "$serport" = "" ]; then 
  rseed=$RANDOM
  while [ $rseed = 65535 ]
  do
    rseed=$RANDOM
  done
  serport=`expr $rseed % 65535`
fi

if [ "$dutport" = "" ]; then
  dutport=$serport
fi

# remote copy killiperf bash file 
clicfg.pl -o 500 -n -c -d $G_HOST_IP1 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -m "sftp> " -v "put $SQAROOT/bin/1.0/q1k_bin/killiperfdaemon.sh /tmp"

case $protype in
    'tcp')
	# Start Iperf server
	echo "server port is $serport"
	echo "excute: iperf -s -p $serport -B $bind_listen_ip"
	iperf -s -p $serport -B $bind_listen_ip&
	# remote excute Iperf client
	sshcli.pl -t 500 -l $G_CURRENTLOG -o $G_CURRENTLOG/killiperfclient.log -d $CLIHOST -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "bash /tmp/killiperfdaemon.sh"
    	sshcli.pl -t 500 -l $G_CURRENTLOG -o $G_CURRENTLOG/iperfclient.log -d $CLIHOST -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "iperf -c $WANDUT -p $dutport -i 1 -t 5 -B $bind_ip"
    	;;
    'udp')
	# Start Iperf server
	echo "server port is $serport"
	echo "excute: iperf -s -p $serport -u -B $bind_listen_ip"
	iperf -s -p $serport -u -B $bind_listen_ip&
	# remote excute Iperf client
	sshcli.pl -t 500 -l $G_CURRENTLOG -o $G_CURRENTLOG/killiperfclient.log -d $CLIHOST -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "bash /tmp/killiperfdaemon.sh"
    	sshcli.pl -t 500 -l $G_CURRENTLOG -o $G_CURRENTLOG/iperfclient.log -d $CLIHOST -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "iperf -c $WANDUT -p $dutport -i 1 -t 5 -u -B $bind_ip"
	;;
    
    *) 
	echo "please give tcp or udp as protocol type"
	exit 
	;;
esac

echo "kill iperf daemon"
kill_iperfdaemon
# To recover previous default gw
if [ $GATEW != $defgw ]; then
  route del default gw $GATEW
  echo "excute: route del default gw $GATEW"
  route add default gw $defgw
  echo "excute: route add default gw $defgw"
fi
