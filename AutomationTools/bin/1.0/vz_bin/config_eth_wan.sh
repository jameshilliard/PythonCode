#! /usr/bin/bash -w

declare -i k
k=$3
declare -i beg
beg=$1
declare -i end
end=$2
while [ $beg -le $end ]
do
    ip="10.10.10.${beg}"
    ifconfig "eth1:$k" $ip
    ping -I $ip $4 -c 1 > /dev/null
    k=$[k + 1]
    beg=$[beg + 1]
done


