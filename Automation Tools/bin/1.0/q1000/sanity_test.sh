#!/bin/bash

rubyexec=`which ruby`
logfile="sanitytest.log"
srcdir=$SQAROOT/bin/1.0/q1000
dut="192.168.0.1"
config="${rubyexec} ${srcdir}/configure.rb --dut ${dut} -o ${logfile} --debug 3"

# Change ACS URL
#$config --acs_url http://nowhere.acs.co

# WAN IP settings sanity tests
$config --ppp_username celab --ppp_password celab --wan_ip_address pppoe+,10.10.10.50/29
$config --ppp_username celab --ppp_password celab --wan_ip_address pppoe+,dynamic
$config --ppp_username celab --ppp_password celab --wan_ip_address pppoe+,10.10.10.50
$config --ppp_username celab --ppp_password celab --wan_ip_address pppoe+,10.10.10.50/29+
$config --wan_ip_address pppoe+,dynamic
$config --wan_ip_address pppoe+,10.10.10.50/29:10.10.10.1
$config --ppp_username celab --ppp_password celab --wan_ip_address pppoa+,10.10.10.50/29
$config --ppp_username celab --ppp_password celab --wan_ip_address pppoa+,dynamic
$config --ppp_username celab --ppp_password celab --wan_ip_address pppoa+,10.10.10.50
$config --ppp_username celab --ppp_password celab --wan_ip_address pppoa+,10.10.10.50/29+
$config --wan_ip_address pppoa+,dynamic
$config --wan_ip_address pppoa+,10.10.10.50/29
$config --wan_ip_address dhcp
$config --wan_ip_address dhcp,fruity:qwest.net
$config --wan_ip_address transparent
$config --wan_ip_address static+,10.10.10.50/29:10.10.10.1
$config --ppp_username celab --ppp_password celab --wan_ip_address pppoe+,dynamic
$config --wan_ip_address_dns 10.10.10.1,10.10.10.2
$config --wan_ip_address_dns dynamic
$config --no-igmp_proxy
$config --igmp_proxy
