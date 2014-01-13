#! /bin/sh
##########################################################################
# This script is supposed to run under testframework
# The purpose is to verify system time similar to setting on GUI 
#  It compares values of year, month, day, and hour with corresponding json
#  That hints year is first parameter, month is sec and so on... 
#
#
#   Created by Hugo 06-19-2009
#
#########################################################################


if [ $# -lt 8 ]; then
   echo "Usage: verify_systime -y <year> -m <month> -d <day> -h <hour>"
   echo "e.g."
   echo "    verify_systime -y 2009 -m May -d 14 -h 13"
   exit
fi

jsonYear=$2
jsonMonth=$4
jsonDay=$6
jsonHour=$8

fileName=`ls $G_CURRENTLOG/clicfg* -ct1 | head -1`
localTime=`cat $fileName | grep 'Local time'`

getYear=`echo $localTime | awk '{ print $7 }'`
# to cut carriage return character
getYear=`echo $getYear | tr -d '\015'`
getMonth=`echo $localTime | awk '{ print $4 }'`
getDay=`echo $localTime | awk '{ print $5 }'`
getHour=`echo $localTime | awk '{ print $6 }' | awk -F : '{ print $1 }'`

if [ $jsonYear != $getYear ]; then
   echo "Not match at Year, pleae check json and your parameters"
   echo "or to check if DUT has been set valid value"
   exit 1
fi

if [ $jsonMonth != $getMonth ]; then
   echo "Not match at Month, pleae check json and your parameters"
   echo "or to check if DUT has been set valid value"
   exit 1
fi

if [ $jsonDay != $getDay ]; then
   echo "Not match at Day, pleae check json and your parameters"
   echo "or to check if DUT has been set valid value"
   exit 1
fi

if [ $jsonHour != $getHour ]; then
   echo "Not match at Hour, pleae check json and your parameters"
   echo "or to check if DUT has been set valid value"
   exit 1
fi

echo "Successfully Match year, month, day and hour with json file"
exit 0



