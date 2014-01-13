#!/sbin/sh

killiperf="eval kill -9 `ps ax |awk '/iperf/ {print $1}'`"
$killiperf
exit
exit$?
