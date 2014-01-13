#!/bin/bash
count=0
lim=$4
log=$3
ip=$2
app=$1
echo " ====================================== "
echo " (app=)$1 -s rand -d (ip=)$2  -r 1000 -p 10000 > (log=)$3  and limit=$4"
echo " ====================================== "

rm -f $log
while [ $count -lt  $lim  ] ; do 
echo "------------------------" >> $log
date=`date`
echo "iteration = $count -- $date " >> $log
echo "------------------------" >> $log
$app -s rand -d $ip  -r 1000 -p 100000  >>$log
let count=$count+1
done
exit 0