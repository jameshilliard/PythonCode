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
U_RUBYBIN=$SQAROOT/bin/$G_LIBVERSION/rbin
U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/ard/json
U_DEBUG=3
repeat=1

while [ 1 ]
do
echo "repeat=$repeat"
bash /root/actiontec/automation/bin/1.0/common/resetffjssh.sh
ruby  $U_RUBYBIN/Main.rb -f  $U_TESTPATH/06011000002.json -d $U_DEBUG -p A -u $U_USER -a $U_PWD -l /tmp/step_2_json.log
sleep 1
bash /root/actiontec/automation/bin/1.0/common/resetffjssh.sh
ruby /root/actiontec/automation/bin/1.0/rbin/Tools/initialize_BHR2.rb
sleep 1
repeat=`expr $repeat + 1`
done
