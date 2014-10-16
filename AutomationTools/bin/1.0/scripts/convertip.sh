#!/bin/bash
add=$1
dns=$2
fqdn=$3
expenv=$4
if [ -z $1  ] || [ -z $2  ] || [ -z $3 ]  || [ -z $4 ] 
then
echo "Usage:converip.sh ipaddress dnsip fqdn exportenv"
exit 1
fi
test=`expr match "$add" "[0-9].[0-9].[0-9].[0-9]"` 
if [ $test -gt 0 ]
then
   echo $1
else
echo " $1 $2 $3 $expenv"
cmd=`nslookup $add.$fqdn $dns |  grep Address | awk '{sub ("Address: ","", $0 ) ; print }' | grep -v Address |  awk '{sub ("","'$expenv='", $0 ) ; print }'`
echo "$cmd"
fi
exit 0