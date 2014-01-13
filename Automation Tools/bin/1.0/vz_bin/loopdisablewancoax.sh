#! /bin/sh
#################################
# This script is for bug16396
#
#
# Created by Hugo 08/29/2009
#
#################################

U_VZBIN=$SQAROOT/bin/1.0/vz_bin
U_USER="admin"
U_PWD="admin1"
G_PROD_IP_ETH0_0_0="192.168.1.1"
U_COAX=0
repeat=1

while [ 1 ]
do
echo "repeat=$repeat"
U_COAX=0
ruby  $U_VZBIN/setupWanIf.rb -u $U_USER -p $U_PWD -d $G_PROD_IP_ETH0_0_0 -c $U_COAX
U_COAX=1
ruby  $U_VZBIN/setupWanIf.rb -u $U_USER -p $U_PWD -d $G_PROD_IP_ETH0_0_0 -c $U_COAX
sleep 1
repeat=`expr $repeat + 1`
done
