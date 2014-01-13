#!/bin/bash

#################################
#
# File:	 loop_wget.sh
# Description: Loop wget website from internet
# Usage:    loop_wget.sh -n <time> -d <website>
#################################

# resetup route for test 
route del default gw 192.168.10.254 >/dev/null
route add default gw 192.168.1.1 >/dev/null

# loop wget
if [ $# -lt 4 ]; then

    echo "Usage: loop_wget.sh -n <time> -d <website>"
    exit
fi

if [ -z $2 ]; then
    time=5
    echo $time
else
    time=$2
    echo $time
fi
if [ -z $4 ]; then
    website="www.actiontec.com"
    echo $website
else
    website="$4"
    echo $website
fi

i=0
while [ $i -lt $time ]; do

    rm -f ./index.html
    perl /mnt/automation/bin/1.0/common/wget.pl -d $website
    sleep 2
    i=$[i+1]
    echo $i
done

service network restart

sleep 10
