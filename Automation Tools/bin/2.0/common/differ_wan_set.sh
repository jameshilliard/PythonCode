#!/bin/bash
 bash $U_PATH_TBIN/cli_dut.sh -v wan.dns -o $G_CURRENTLOG/dutwaninfodns.log
 TMP_DUT_WAN_DNS_1=`cat $G_CURRENTLOG/dutwaninfodns.log|grep "TMP_DUT_WAN_DNS_1"|awk -F"=" '{print $2}'`
echo "TMP_DUT_WAN_DNS_1=$TMP_DUT_WAN_DNS_1"
 TMP_DUT_WAN_DNS_2=`cat $G_CURRENTLOG/dutwaninfodns.log|grep "TMP_DUT_WAN_DNS_2"|awk -F"=" '{print $2}'`
echo "TMP_DUT_WAN_DNS_2=$TMP_DUT_WAN_DNS_2"
### check gateway
echo "TMP_DUT_DEF_GW=$TMP_DUT_DEF_GW"
echo "wan_gw_dhcp=`cat $G_CURRENTLOG/wanpc_set.log|grep "wan_gw_dhcp"|awk -F";" '{print $2}'`"
wan_gw_dhcp=`cat $G_CURRENTLOG/wanpc_set.log|grep "wan_gw_dhcp"|awk -F";" '{print $2}'`
if [ "$TMP_DUT_DEF_GW" == "$wan_gw_dhcp" ] ;then
 echo "gateway equal"
else 
 echo "gtway not equal ,have error ,pls check"
 exit 1
fi

### check dns1
echo "TMP_DUT_WAN_DNS_1=$TMP_DUT_WAN_DNS_1"
echo "wan_dhcp_dns_1=`cat $G_CURRENTLOG/wanpc_set.log|grep "wan_dhcp_dns_1"|awk -F";" '{print $2}'`"
wan_dhcp_dns_1=`cat $G_CURRENTLOG/wanpc_set.log|grep "wan_dhcp_dns_1"|awk -F";" '{print $2}'`
if [ "$TMP_DUT_WAN_DNS_1" == "$wan_dhcp_dns_1" ] ;then
 echo "DNS1 equal"
else 
 echo "dns1 not equal ,have error ,pls check"
 exit 1
fi


#### check dns2
echo "TMP_DUT_WAN_DNS_2=$TMP_DUT_WAN_DNS_2"
echo "wan_dhcp_dns_2=`cat $G_CURRENTLOG/wanpc_set.log|grep "wan_dhcp_dns_2"|awk -F";" '{print $2}'`"
wan_dhcp_dns_2=`cat $G_CURRENTLOG/wanpc_set.log|grep "wan_dhcp_dns_2"|awk -F";" '{print $2}'`
if [ "$TMP_DUT_WAN_DNS_2" == "$wan_dhcp_dns_2" ] ;then
 echo "DNS2 equal"
else 
 echo "dns2 not equal ,have error ,pls check"
 exit 1
fi

####check ip in range 
result=0
echo "Get DUT wan ip"
bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/dutwaninfo.log
current_ip=`grep "TMP_DUT_WAN_IP" $G_CURRENTLOG/dutwaninfo.log | awk -F"=" '{print $2}' | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"`
echo "current_ip=$current_ip" 

echo "wan_dhcp_ip_start=`cat $G_CURRENTLOG/wanpc_set.log|grep "wan_dhcp_ip_start"|awk -F";" '{print $2}'`"
wan_dhcp_ip_start=`cat $G_CURRENTLOG/wanpc_set.log|grep "wan_dhcp_ip_start"|awk -F";" '{print $2}'`
echo "minadd=$wan_dhcp_ip_start"
minadd=$wan_dhcp_ip_start

echo "wan_dhcp_ip_end=`cat $G_CURRENTLOG/wanpc_set.log|grep "wan_dhcp_ip_end"|awk -F";" '{print $2}'`"
wan_dhcp_ip_end=`cat $G_CURRENTLOG/wanpc_set.log|grep "wan_dhcp_ip_end"|awk -F";" '{print $2}'`
echo "maxadd=$wan_dhcp_ip_end"
maxadd=$wan_dhcp_ip_end
echo "range $minadd $maxadd" > $G_CURRENTLOG/ipaddress_range_file.conf
    first_range_ip=`grep range $G_CURRENTLOG/ipaddress_range_file.conf | awk '{print $3}' | awk -F. '{print $1}'`
    echo first_range_ip_tmp=$first_range_ip
    first_current_ip_tmp=`echo $current_ip | awk -F. '{print $1}'`
    echo first_current_ip_tmp=$first_current_ip_tmp
if [ "$first_current_ip_tmp" == "$first_range_ip" ] ;then
  echo "first ip equal"
    second_range_ip_tmp=`grep range $G_CURRENTLOG/ipaddress_range_file.conf | awk '{print $3}' | awk -F. '{print $2}'`
    echo second_range_ip_tmp=$second_range_ip_tmp
    second_current_ip_tmp=`echo $current_ip | awk -F. '{print $2}'`
    echo second_current_ip_tmp=$second_current_ip_tmp
	if [ "$second_current_ip_tmp" == "$second_range_ip_tmp" ] ;then
  	echo "second ip equal"
    	third_range_ip_tmp=`grep range $G_CURRENTLOG/ipaddress_range_file.conf | awk '{print $3}' | awk -F. '{print $3}'`
   	 echo third_range_ip_tmp=$third_range_ip_tmp
    	third_current_ip_tmp=`echo $current_ip | awk -F. '{print $3}'`
   	 echo third_current_ip_tmp=$third_current_ip_tmp
	if [ "$third_current_ip_tmp" == "$third_range_ip_tmp" ] ;then
  	echo "third ip equal"
	echo "Execute check ipaddress in range"
   	 ip_min=`grep range $G_CURRENTLOG/ipaddress_range_file.conf | awk '{print $2}' | awk -F. '{print $4}'`
   	 ip_tmp=`grep range $G_CURRENTLOG/ipaddress_range_file.conf | awk '{print $3}' | awk -F. '{print $4}'`
 	   ip_max=`echo ${ip_tmp%;}`
 	   ip=`echo $current_ip | awk -F. '{print $4}'`
        echo "forth ip :$ip $ip_min $ip_max"
   	 if [ "$ip" -ge "$ip_min" ]; then
       		 if [ "$ip" -le "$ip_max" ]; then
          	  echo -e " ipaddress is in the range! "
               	 exit 0
     		   else
        	    echo -e " AT_ERROR : ipaddress is NOT in the range! "
           		 exit 1
       	 fi
   	 else
       		 echo -e " AT_ERROR : ipaddress is NOT in the range! "
        	exit 1
  	  fi
	else 
 	echo  " ipaddress is NOT in the range: the third ip is not equal! "
	 exit 1
	fi
	else 
 	echo  " ipaddress is NOT in the range: the second ip is not equal! "
	 exit 1
	fi
else
 echo  " ipaddress is NOT in the range: the first ip is not equal! "
  exit 1
fi
  
