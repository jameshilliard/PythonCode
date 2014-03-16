#! /bin/sh -x
##########################################################################
# This script is supposed to run under testframework
# The purpose is to verify the feature of dhcp lease time 
#  
#   
#
#
#   Created by Hugo 08-14-2009
#
#########################################################################
#G_CURRENTLOG="/root/actiontec/automation/logs/current/tc_dhcplaneth_leasetime43200_aclass1.xml_30"

suffixlog=""
if [ "$1" = "-bigtime" -a "$2" = "" ]; then
  suffixlog=1
  first_macaddr=`cat $G_CURRENTLOG/getipfrombhr2wan.log | grep 'Link encap' | awk NR==1`
  sec_macaddr=`cat $G_CURRENTLOG/getipfrombhr2wan"$suffixlog".log | grep 'Link encap' | awk NR==1`
  first_ipaddr=`cat $G_CURRENTLOG/getipfrombhr2wan.log | grep 'inet addr' | awk NR==1`
  sec_ipaddr=`cat $G_CURRENTLOG/getipfrombhr2wan"$suffixlog".log | grep 'inet addr' | awk NR==1`
else if [ "$1" = "-bigtime" -a "$2" = "-lan" ]; then
  suffixlog=1
  first_macaddr=`cat $G_CURRENTLOG/getipfrombhr2lan.log | grep 'Link encap' | awk NR==1`
  sec_macaddr=`cat $G_CURRENTLOG/getipfrombhr2lan"$suffixlog".log | grep 'Link encap' | awk NR==1`
  first_ipaddr=`cat $G_CURRENTLOG/getipfrombhr2lan.log | grep 'inet addr' | awk NR==1`
  sec_ipaddr=`cat $G_CURRENTLOG/getipfrombhr2lan"$suffixlog".log | grep 'inet addr' | awk NR==1`
else if [ "$1" = "-lan"  ]; then
  first_macaddr=`cat $G_CURRENTLOG/getipfrombhr2lan.log | grep 'Link encap' | awk NR==1`
  sec_macaddr=`cat $G_CURRENTLOG/getipfrombhr2lan.log | grep 'Link encap' | awk NR==2`
  first_ipaddr=`cat $G_CURRENTLOG/getipfrombhr2lan.log | grep 'inet addr' | awk NR==1`
  sec_ipaddr=`cat $G_CURRENTLOG/getipfrombhr2lan.log | grep 'inet addr' | awk NR==2`
else if [ "$1" = "" ]; then
  first_macaddr=`cat $G_CURRENTLOG/getipfrombhr2wan.log | grep 'Link encap' | awk NR==1`
  sec_macaddr=`cat $G_CURRENTLOG/getipfrombhr2wan.log | grep 'Link encap' | awk NR==2`
  first_ipaddr=`cat $G_CURRENTLOG/getipfrombhr2wan.log | grep 'inet addr' | awk NR==1`
  sec_ipaddr=`cat $G_CURRENTLOG/getipfrombhr2wan.log | grep 'inet addr' | awk NR==2`
fi
fi
fi
fi


echo "first_macaddr: $first_macaddr"
echo "sec_macaddr: $sec_macaddr"
echo "first_ipaddr: $first_ipaddr"
echo "sec_ipaddr: $sec_ipaddr"

if [ "$first_macaddr" = "$sec_macaddr" ]; then
  echo "FAIL: Two Times MAC Address are same, check your target PC"
  exit 1 
fi

if [ "$first_ipaddr" != "$sec_ipaddr" ]; then
  echo "FAIL: DHCP Release time testing fail"
  exit 1
else
  echo "Success: DHCP Release time testing"
  exit 0
fi
