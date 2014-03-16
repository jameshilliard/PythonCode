#!/bin/bash
U_USER="admin"
U_PWD="admin1"
U_COMMONBIN=$SQAROOT/bin/1.0/common
U_DEBUG=3
U_MI424=$SQAROOT/bin/1.0/mi424wr/
G_CURRENTLOG=./log
#U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
U_DUT=10.10.10.254
U_COMMONJSON=./
echo $U_MI424
killall busyscreen
$U_COMMONBIN/busyscreen > /dev/null &


echo "test start"
while [ 1 ]
do
ruby  $U_MI424/configDevice.rb  -o $G_CURRENTLOG/configdevice_rs.log -f  $U_COMMONJSON/wireless_advanced.json  -d $U_DEBUG  -u $U_USER -p $U_PWD -i $U_DUT --generate-test-file $G_CURRENTLOG/testsystem.json  
#ruby  $U_MI424/configDevice.rb  -o $G_CURRENTLOG/configdevice_rs.log -f  $U_COMMONJSON/wps_enable2.json  -d $U_DEBUG  -u $U_USER -p $U_PWD -i 192.168.1.1 --generate-test-file $G_CURRENTLOG/testsystem.json  
#ruby  $U_MI424/configDevice.rb  -o $G_CURRENTLOG/configdevice_rs.log -f  $U_COMMONJSON/wps_enable2.json  -d $U_DEBUG  -u $U_USER -p $U_PWD -i 192.168.1.1 --generate-test-file $G_CURRENTLOG/testsystem.json  
#ruby  $U_MI424/configDevice.rb  -o $G_CURRENTLOG/configdevice_rs.log -f  $U_COMMONJSON/wps_disable.json  -d $U_DEBUG  -u $U_USER -p $U_PWD -i 192.168.1.1 --generate-test-file $G_CURRENTLOG/testsystem.json  
done
killall busyscreen
