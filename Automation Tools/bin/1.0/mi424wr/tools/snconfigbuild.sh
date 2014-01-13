#!/bin/bash
configs=$HOME/automation/platform/1.0/verizon2/testcases/static_nat/json/portlists
bindir=$HOME/automation/bin/1.0/mi424wr
start=1
end=1000
while [ $end -lt 65001 ]
do
  $bindir/confBuilder.rb --sn-testrange $start-$end --save-dir $configs --prefix sn_test_$start-$end --sequential
  start=`expr $start + 1000`
  end=`expr $end + 1000`
done
$bindir/confBuilder.rb --sn-testrange 65001-65535 --save-dir $configs --prefix sn_test_65001-65535 --sequential
