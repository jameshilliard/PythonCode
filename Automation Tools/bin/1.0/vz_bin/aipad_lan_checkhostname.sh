#! /bin/sh 
# -n negative testing (on/off) 
#
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

echo $nameprefix

ipaddress=`sshcli.pl -l $G_CURRENTLOG -d $G_HOST_IP2  -u $G_HOST_USR2 -p $G_HOST_PWD2 -v "ifconfig $G_HOST_IF2_1_0" | grep "inet addr" | awk '{print $2}' | cut -d: -f 2`
ipdut=`echo ${G_PROD_IP_ETH0_0_0%/*}`

sshcli.pl -l $G_CURRENTLOG -d $G_HOST_IP2 -u $G_HOST_USR2 -p $G_HOST_PWD2 -v "ping -c 2 $ipdut"

echo $ipaddress $ipdut

rm -rf sshcli*

if [ $2 = on ]; then
	/bin/cp /etc/resolv.conf /etc/resolv.conf.bak
	echo "nameserver $ipdut" > /etc/resolv.conf
	/usr/bin/nslookup $ipaddress $ipdut | grep "$nameprefix"
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
	/usr/bin/nslookup $ipaddress $ipdut | grep "$nameprefix"
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
