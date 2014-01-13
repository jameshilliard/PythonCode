#!/bin/bash 
#---------------------------------
# Name: Hugo
# Description: 
#
# options: -j is optional
#          -l and -h exist one at least
#          -j json file localtion
#          -l only to verify local domain name
#          -h only to verify hostname
#--------------------------------

#U_COMMONBIN="/mnt/automation/bin/1.0/common"
#G_CURRENTLOG="/tmp"
#G_HOST_USR2="root"
#G_HOST_IP2="192.168.10.54"
#G_HOST_PWD2="actiontec"
#G_HOST_IF2_1_0="eth1"

hostname="Wireless_Broadband_Router"
localdomain="home"
only_localdomain="n"
only_hostname="n"

while [ $# -gt 0 ]
do
  case "$1" in
   -j)
      json_file=$2
      shift
      shift
      ;;
   -l)
      only_localdomain="y"
      shift
      ;;
   -h)
      only_hostname="y"
      shift
      ;;
  esac
done

if [ ! -z "$json_file" ]; then
 hostname=`cat $json_file | grep Hostname | tr -d \" | tr -d \, | tr -d "\r" | awk -F : '{ print $2 }'`
 localdomain=`cat $json_file | grep "Local Domain" | tr -d \" | tr -d \, | tr -d "\r" | awk -F : '{ print $2 }'`
else
 echo "Default hostname and local domain"
fi

echo "Wireless Broadband Router's Hostname is |---> $hostname"
echo "Local Domain is |---> $localdomain"

if [ "$only_hostname" = "y" ];then
  # launch wget to verify hostname is 
  $U_COMMONBIN/sshcli.pl -l  $G_CURRENTLOG/ -o $G_CURRENTLOG/check_wireless_hostname.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "killall dhclient; dhclient $G_HOST_IF2_1_0 -T 15; rm -f /tmp/index.html 2>/dev/null; wget -T 5 -t 2 -P /tmp $hostname"
  rm -f $G_CURRENTLOG/index.html 2>/dev/null
  $U_COMMONBIN/clicfg.pl -c -d $G_HOST_IP2 -l $G_CURRENTLOG -u $G_HOST_USR2 -p $G_HOST_PWD2 -m "sftp> " -v "get /tmp/index.html $G_CURRENTLOG/"
fi

if [ "$only_hostname" = "y" -a -e $G_CURRENTLOG/index.html ]; then
  echo "Wireless Broadband Router Hostname works"
  exit 0
fi

if [ "$only_localdomain" = "y" ]; then
  $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/checklocaldomain.log -d $G_HOST_IP2 -u $G_HOST_USR2 -p $G_HOST_PWD2 -v "/bin/cp /etc/resolv.conf /etc/resolv.conf.asys; rm -f /var/lib/dhclient/dhclient.leases; killall dhclient; dhclient -r $G_HOST_IF2_1_0; dhclient $G_HOST_IF2_1_0 -T 15"
  rm -f $G_CURRENTLOG/resolv.conf 2>/dev/null
  $U_COMMONBIN/clicfg.pl -c -d $G_HOST_IP2 -l $G_CURRENTLOG -u $G_HOST_USR2 -p $G_HOST_PWD2 -m "sftp> " -v "get /etc/resolv.conf $G_CURRENTLOG/"
  $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/cpoverresovlconf.log -d $G_HOST_IP2 -u $G_HOST_USR2 -p $G_HOST_PWD2 -v "/bin/cp /etc/resolv.conf.asys /etc/resolv.conf; rm -f /etc/resolv.conf.asys 2>/dev/null"
fi

grep $localdomain $G_CURRENTLOG/resolv.conf
result=$?
if [ "$only_localdomain" = "y" -a "$result" = "0" ]; then
  echo "Hostname is workable"
  exit 0
fi


if [ \( "$only_hostname" = "n" -a "$only_localdomain" = "n" \) -o \( "$only_hostname" = "y" -a "$only_localdomain" = "y" \) ]; then
    echo "Fail: Invalid options"
    exit 1
  else 
    if [ "$only_hostname" = "y" ]; then
      echo "Fail: Wireless Broadband Router Hostname does not work"
      exit 1
    else 
      if [ "$only_localdomain" = "y" ]; then
      echo "Fail: hostname is not workable"
      exit 1
      fi
    fi
fi
