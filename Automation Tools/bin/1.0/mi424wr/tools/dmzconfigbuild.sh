#!/bin/bash
configs=$HOME/automation/platform/1.0/verizon2/testcases/dmz_host/json/portlists
bindir=$HOME/automation/bin/1.0/mi424wr
start=1
end=1000
while [ $end -lt 65001 ]
do
  $bindir/confBuilder.rb --dmz-testrange $start-$end --save-dir $configs --prefix dmz_portlist_$start-$end --sequential
  start=`expr $start + 1000`
  end=`expr $end + 1000`
done
$bindir/confBuilder.rb --dmz-testrange 65001-65535 --save-dir $configs --prefix dmz_portlist_65001-65535 --sequential
