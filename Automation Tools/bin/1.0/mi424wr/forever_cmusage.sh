#!/bin/sh
RUBY_HOME=/home/cborn/automation/bin/1.0/mi424wr
logfile="cmusage.log"
DUT_IP="192.168.1.1"
DUT_USER="admin"
DUT_PASS="admin1"

echo "Started logging at `date`" > $logfile
echo "Initial information: " >> $logfile
ruby $RUBY_HOME/get_fwv.rb -i $DUT_IP -u $DUT_USER -p $DUT_PASS >> $logfile
echo " " >> $logfile
ruby $RUBY_HOME/get_dut_cmusage.rb --telnet-enabled >> $logfile
echo " " >> $logfile
echo "End initial information. Beginning recursive logging." >> $logfile
echo " " >> $logfile
while :
do
sleep 60
echo " " >> $logfile
echo "Retrieve time from system: `date`" >> $logfile
ruby $RUBY_HOME/get_dut_cmusage.rb --telnet-enabled >> $logfile
done
