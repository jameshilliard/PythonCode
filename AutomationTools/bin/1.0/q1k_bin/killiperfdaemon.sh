#! /bin/sh

pidip=`ps aux | grep iperf | grep -v grep | grep -v killperf | awk '{ print $2 }'`

for i in $pidip
do
 kill -9 $i 2>/dev/null
done
