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

perl $U_COMMONBIN/ping.pl -l $G_CURRENTLOG -d $HOSTIP
if [ $? = 1 ]; then
   echo "ping pass"
   exit 0
fi
