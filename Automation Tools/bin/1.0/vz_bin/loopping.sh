#!/bin/bash 
#---------------------------------
# Name: Hugo
# Description: 
#
#--------------------------------
#U_COMMONBIN="/mnt/automation/bin/1.0/common"
#G_CURRENTLOG="/tmp"

if [ $1 = "" ]; then
  echo " no parameters!"
  exit 1
fi
HOSTIP=$1

if [ -z $G_CURRENTLOG ]; then
    G_CURRENTLOG="/tmp"
fi

for i in 1 2 3 4 5 6 7 8 9 10 
do
 echo "Try ping to $HOSTIP..."
 perl $SQAROOT/bin/1.0/common/ping.pl -l $G_CURRENTLOG -d $HOSTIP > /dev/null
 if [ $? = 0 ]; then
   echo "Ping pass"
   exit 0
 fi
 sleep 15 
done

exit 1

