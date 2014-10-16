#!/bin/bash
U_USER="admin"
U_PWD="admin1"
U_COMMONBIN=$SQAROOT/bin/1.0/common
U_DEBUG=3
U_MI424=$SQAROOT/bin/1.0/mi424wr/
G_CURRENTLOG=/tmp
#U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
U_COMMONJSON=./
G_PROD_IP_ETH0_0_0="192.168.1.1"
echo $U_MI424
logfile="dutstatus.txt"
tempfile="dutinfo.txt"

rm $G_CURRENTLOG/$tempfile -f
rm $G_CURRENTLOG/$logfile -f
touch $G_CURRENTLOG/$tempfile
touch $G_CURRENTLOG/$logfile
#sleep 900
while [ 1 ]
do
    perl $U_COMMONBIN/clicfg.pl -i 23 -u $U_USER -p $U_PWD -l $G_CURRENTLOG -d $G_PROD_IP_ETH0_0_0 -t $tempfile  -n -m "Wireless Broadband Router> " -v "system ver" -v "system date" -v "kernel meminfo" -v "conf print manufacturer"  -v "system cat proc/uptime" -v "system http_intercept_status" -v "system cat proc/loadavg"  -v "system cat proc/slabinfo"  -v "firewall dump -pn" 
    DATE=`date`
    echo "****************************" >> $G_CURRENTLOG/$logfile
    echo $DATE >> $G_CURRENTLOG/$logfile
    echo "****************************" >> $G_CURRENTLOG/$logfile
    dos2unix $G_CURRENTLOG/$tempfile 
    dos2unix $G_CURRENTLOG/$tempfile
    perl -pi -e "s/@//" $G_CURRENTLOG/$tempfile
    cat $G_CURRENTLOG/$tempfile >> $G_CURRENTLOG/$logfile
    rm -f $G_CURRENTLOG/$tempfile
    sleep 900
done
