#!/bin/bash
if [ "$1" == "" ];then
    echo "Please enter the first 3 bytes of the network e.g 10.1.10"
exit 0;
fi
n=0
wait=5
lim=255
while [ $n -lt 1 ] ; do
    count=1    
    while [ $count -lt  $lim ];do 
	echo "wget http://$1.$count"
	wget -t 1 -o $1.$count.log -O index_$1.$count.html http://$1.$count/   &
    let count+=1;
    done
    echo "Pause for $wait seconds"
    sleep $wait
done