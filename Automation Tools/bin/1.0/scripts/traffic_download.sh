#!/bin/bash
if [ "$3" = "" ]; then
log="wget_ftp.log"
else
log=$3 
fi
echo " ====================================== "
echo " Download ftp://root:actiontec@$1/Download/ftp_traffic.bin -O $2 -T 10 -o $log"
echo " ====================================== "
while [ 1 ] ; do 
wget ftp://root:actiontec@$1/Download/ftp_traffic.bin -O $2 -T 60 -o $log
done
exit 0