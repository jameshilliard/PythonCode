#!/bin/bash
configs=$HOME/automation/platform/1.0/verizon2/testcases/port_triggering/json
bindir=$HOME/automation/bin/1.0/mi424wr

$bindir/confBuilder.rb --port-triggering --amount 50 --save-dir $configs --prefix tc_port_triggering_ --iteration-max 2 --imax-out 4 --max-port 1024
