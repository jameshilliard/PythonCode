#! /bin/bash
#####################################################
#
# Composed for ddns mail exchanger testing purpose
#
#
#  By Hugo 06/25/2009
#
#####################################################
if [ $# -lt 6 ]; then
   echo "Usage: ddns_check_mailexchanger.sh -u <email user> -d <email domain> -gw <pc1 default gw>"
   exit
fi

emailuser=$2
emaildomain=$4
gateway=$6
gateway=`echo ${gateway%/*}`
dutip=`echo ${G_PROD_IP_ETH0_0_0%/*}`

# To initial PC1 
#route del -net 10.10.10.0 netmask 255.255.255.0 gw $dutip 2>/dev/null
#route del default gw $gateway 2>/dev/null
#route add default gw $dutip
#echo "nameserver 4.2.2.2" > /etc/resolv.conf
netstat -rn
ifconfig eth0_rename down

route add default gw 192.168.1.1 > /dev/null
# send email
rm -f /var/spool/mail/root
echo "here we go" | mutt -s "dyndns email" "$emailuser"@"$emaildomain"
sleep 10

grep Relaying /var/spool/mail/root
if [ $? != 0 ]; then
  is_pass=1
else
  is_pass=0
fi 

service network restart
sleep 10
route add -net 10.10.10.0/24 gw 192.168.1.1 > /dev/null

if [ $is_pass != 0 ];then
  echo "email relay fail"
  exit 1
else
  echo "email relay pass"
  exit 0
fi


