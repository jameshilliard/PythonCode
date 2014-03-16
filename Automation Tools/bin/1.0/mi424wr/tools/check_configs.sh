#!/bin/bash
configs=$HOME/automation/platform/1.0/verizon2/testcases/port_forwarding/json
bindir=$HOME/automation/bin/1.0/mi424wr
logs=$HOME/logging
prefix=$1
end=$2
$bindir/configDevice.rb -d 3 --profile XvfbTest -u admin -p admin1 -i 192.168.1.1 --no-log -f $configs/cleanPF.json
for ((i=1 ; i<=$end ; i++))
do
  checkfile=$configs/$prefix$i.json
  $bindir/configDevice.rb -d 3 --profile XvfbTest -u admin -p admin1 -i 192.168.1.1 -o $logs/log_$i.log -f $checkfile
  $bindir/configDevice.rb -d 3 --profile XvfbTest -u admin -p admin1 -i 192.168.1.1 --no-log -f $configs/cleanPF.json
done