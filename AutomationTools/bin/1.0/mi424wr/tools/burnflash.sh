#!/bin/bash 
dut=192.168.1.1
getout=1
count = 1
#while [ $getout > 0 ] ; do
    date=`date`
    echo " === > Test iteration $count -- $date"
    $SQAROOT/bin/1.0/mi424wr/fw-upgrade.rb -f ~/Download/20.8.0.rmt -d $dut 
    $SQAROOT/bin/1.0/common/checkdut.pl -d $dut
    $SQAROOT/bin/1.0/mi424wr/fw-upgrade.rb -f ~/Download/20.9.0.rmt -d $dut
    $SQAROOT/bin/1.0/common/checkdut.pl -d $dut
    $SQAROOT/bin/1.0/mi424wr/fw-upgrade.rb -f ~/Download/20.8.7.rmt -d $dut
    $SQAROOT/bin/1.0/common/checkdut.pl -d $dut
    let count++
#done 