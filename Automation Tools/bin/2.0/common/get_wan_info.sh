#!/bin/bash
##ssh to wan cp get dhcp configure   
$U_PATH_TBIN/clicmd -o  $G_CURRENTLOG/dhcp.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "cat /etc/dhcp/dhcpd.conf"
###cat /etc/dhcp/dhcpd.conf >/tmp/dhcp.log
###/tmp/dhcp.log change to ${logpath}/dhcp.log
echo "wan_gw_dhcp;`cat  $G_CURRENTLOG/dhcp.log|grep "option routers"|awk '{print $3}'`"|tee -a  $G_CURRENTLOG/wanpc_set.log
echo "wan_dhcp_ip_start;`cat  $G_CURRENTLOG/dhcp.log|grep "range dynamic-bootp"|awk '{print $3}'`"|tee -a  $G_CURRENTLOG/wanpc_set.log
echo "wan_dhcp_ip_end;`cat  $G_CURRENTLOG/dhcp.log|grep "range dynamic-bootp"|awk '{print $NF}'`"|tee -a  $G_CURRENTLOG/wanpc_set.log
echo "wan_dhcp_dns_1;`cat  $G_CURRENTLOG/dhcp.log|grep "option domain-name-servers"|awk '{print $3}'|awk -F, '{print $1}'`"|tee -a  $G_CURRENTLOG/wanpc_set.log
echo "wan_dhcp_dns_2;`cat  $G_CURRENTLOG/dhcp.log|grep "option domain-name-servers"|awk '{print $3}'|awk -F, '{print $2}'`"|tee -a  $G_CURRENTLOG/wanpc_set.log

