#! /bin/sh -x
#################################################
#  verifyupnp.sh 
#     This script will try to verify if UPnP rules   
#  were added in successfully. In order to make the 
#  results accurated, suggest to reboot DUT to clean
#  existed UPnP rules
#
#  -n is_negtive test, 0 is negtive 1 is positive
#  -num expected line numbers of rules
#
#  Hugo 11/04/2009
#################################################
#G_HOST_TIP0_1_0="192.168.0.243/24"
#G_PROD_IP_ETH0_0_0="192.168.0.1"
#G_CURRENTLOG="/tmp"
#U_USER=admin
#U_PWD=admin

help="Usage: verifyupnp.sh -num <max number> -n(egative) "
if [ "$1" = "" ]; then
   echo $help
   exit 1
fi

HOSTIP=`echo ${G_HOST_TIP0_1_0%/*}`
is_negtive=1

let expectcount=0
let num_check=0
while [ $# -gt 0 ]
do
  case "$1" in
    -n)
       is_negtive=0
       shift
       ;;
    -num)
       expectcount=$2 
       shift
       shift
       ;;
    *)
       echo "Error= $help"
       exit 1
       ;;
  esac
done

$SQAROOT/bin/1.0/common/clicfg.pl -d $G_PROD_IP_ETH0_0_0 -i 23 -l $G_CURRENTLOG -u $U_USER -p $U_PWD -m "> " -v "iptables -t nat -nvL"

if [ $? != 0 ]; then
  echo "\nTelnet Login DUT fail, please check the cable connection or DUT settings in GUI\n"
  exit 1
fi

######################################################
#
#    grep        is_negtive       result
#   true(0)       false(1)         pass
#   false(1)      true(0)          pass
#   true          true             fail
#   false         false            fail         
#
######################################################
while [ $num_check -lt $expectcount ]
do

    cat $G_CURRENTLOG/clicfg.pl.log | grep $HOSTIP | grep 20$num_check 
    let result=$?
    
    if [ $result = 0 -a $is_negtive = 0 ]; then
	echo "port 20$num_check  found in iptables"
	echo "\nUPNP - Negtive test fail"
	exit 1
    fi
    if [ $result = 0 -a $is_negtive = 1 ]; then
	echo "port 20$num_check  found in iptables, test pass"
    fi
    if [ $result != 0 -a $is_negtive = 1 ]; then
	echo "port 20$num_check not found in iptables"
	echo "\nUPNP - Positive test fail"
	exit 1
    fi 
    if [ $result != 0 -a $is_negtive = 0 ]; then
	echo "port 20$num_check not found in iptables, test pass"
    fi
    num_check=`expr $num_check + 1`
done

echo "\n\nUPNP test pass"
exit 0

