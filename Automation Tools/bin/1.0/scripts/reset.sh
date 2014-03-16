#!/bin/bash
U_USER="admin"
U_PWD="admin1"
U_COMMONBIN=$SQAROOT/bin/1.0/common
U_DEBUG=3
U_MI424=$SQAROOT/bin/1.0/mi424wr/
G_CURRENTLOG=/root/work/eng/log
#U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
U_COMMONJSON=/root/work/eng/
echo $U_MI424
$U_COMMONBIN/busyscreen > /dev/null &
while [ 1 ]
do


ruby  $U_MI424/configDevice.rb  -o $G_CURRENTLOG/configdevice_rs.log -f  $U_COMMONJSON/restore_defaults.json  -d $U_DEBUG  -u $U_USER -p $U_PWD -i 192.168.1.1 --generate-test-file $G_CURRENTLOG/testsystem.json  
#perl $U_COMMONBIN/checkdut.pl -o  $G_CURRENTLOG/checkdut.log -d 192.168.1.1 -l $G_CURRENTLOG
done
killall busyscreen