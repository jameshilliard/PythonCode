#! /bin/sh 
# -n negative option
if [ $# -lt 2 ]; then
	echo "Usage: aipad_checkhostname.sh -n <on/off> [hostname]" 
	exit
fi

if [ $1 != "-n" ]; then
	echo "Usage: aipad_checkhostname.sh -n <on/off> [hostname]" 
	exit
fi

if [ -z $3 ]; then
	nameprefix="new-host"
else 
	nameprefix="$3"
fi

ipaddress=`sshcli.pl -l $G_CURRENTLOG -d $G_HOST_TIP3_0_0 -u $G_HOST_USR3 -p $G_HOST_PWD3 -v "ifconfig $G_HOST_IF3_1_0" | grep "inet addr" | awk '{print $2}' | cut -d: -f 2`
ipdut=`echo ${G_PROD_IP_ETH0_0_0%/*}`
ipwandut=`echo ${G_PROD_IP_ETH1_0_0%/*}`

sshcli.pl -l $G_CURRENTLOG -d $G_HOST_TIP3_0_0 -u $G_HOST_USR3 -p $G_HOST_PWD3 -v "ping -c 2 $ipwandut"

if [ $2 = on ]; then
	/bin/cp /etc/resolv.conf /etc/resolv.conf.bak
	echo "nameserver $ipdut" > /etc/resolv.conf
	/usr/bin/nslookup $ipaddress $ipdut	| grep $nameprefix
	result=$?
	/bin/cp /etc/resolv.conf.bak /etc/resolv.conf

	if [ $result != 0 ]; then
		echo "Fail to resolve host name on dut"		
		exit 1
	else
		echo "Succeed to resolve host name on dut"
		exit 0
	fi

fi

if [ $2 = off ]; then
	/bin/cp /etc/resolv.conf /etc/resolv.conf.bak
	echo "nameserver $ipdut" > /etc/resolv.conf
	/usr/bin/nslookup $ipaddress $ipdut	| grep $nameprefix
	result=$?
	/bin/cp /etc/resolv.conf.bak /etc/resolv.conf

	if [ $result != 0 ]; then
		echo "Fail to resolve host name on dut"		
		exit 0
	else
		echo "Succeed to resolve host name on dut"
		exit 1
	fi
fi
