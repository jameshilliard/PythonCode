#! /bin/bash 
##################################################################
#
# Description:
#   This script is verify dhcp connection in Advanced page
#   It verifies the correction of hostname, physical address etc.
#
# Options:
#   -d dhcp client ip address
#   -t lease time type
#   -h host name
#   -c connction name
#   -s status
#   -e expire time
#
#
#   By Hugo 09/08/2009 
#
##################################################################

#G_CURRENTLOG=/root/actiontec/automation/logs/current/tc_dynlease_0008.xml_3
#U_COMMONBIN=/root/actiontec/automation/bin/1.0/common
#G_HOST_USR2=root
#G_HOST_PWD2=actiontec
#G_HOST_IF2_1_0=eth1

trows=`cat $G_CURRENTLOG/acquiredhcpconnection.log | grep NumberRow | awk '{ print $2 }'| tr -d ','`
hn=""
phyad=""
leasety=""
conname=""
cstatus=""
exptime=""
macadd=""
hostip=""

function acquiremac
{
perl $U_COMMONBIN/sshcli.pl -l  $G_CURRENTLOG/ -o $G_CURRENTLOG/acquiremac.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $hostip -v "ifconfig $G_HOST_IF2_1_0"
macadd=`cat $G_CURRENTLOG/acquiremac.log | grep HWaddr | awk '{print $5}' | tr [A-Z] [a-z]`
}

function blockconn
{
temprows="$trows"
while [ "$temprows" != 0  ]
do
sed -n "/$temprows)\": \[/,/\]/p" $G_CURRENTLOG/acquiredhcpconnection.log > $G_CURRENTLOG/$temprows"conn"
temprows=`expr $temprows - 1` 
done
}

function checkcontents
{
# verify lease type
tpleasety=`cat $G_CURRENTLOG/$tempcout"conn" | grep $leasety | tr -d \" | tr -d \, | tr -d " "`
if [ "$tpleasety" = "$leasety" ]; then
  r_leasety=1
  echo "Success at verify lease type"
else 
  echo "FAIL at verify lease type"
  exit 1
fi

# verify hostname
tphn=`cat $G_CURRENTLOG/$tempcout"conn" | grep $hn | tr -d \" | tr -d \, | tr -d " "`
if [ "$tphn" != "" ]; then
  r_tphn=1
  echo "Success at verify hostname"
else
  echo "FAIL at verify hostname"
  exit 1
fi

# verify connection name
tpconname=`cat $G_CURRENTLOG/$tempcout"conn" | grep $conname | tr -d \" | tr -d \, | tr -d " "` 
if [ "$tpconname" != "" ]; then
  r_tpconname=1
  echo "Success at verify connection name"
else
  echo "FAIL at verify connection name"
  exit 1
fi

# verify status
tpcstatus=`cat $G_CURRENTLOG/$tempcout"conn" | grep $cstatus | tr -d \" | tr -d \, | tr -d " "`
if [ "$tpcstatus" = "$cstatus" ]; then
  r_tpcstatus=1 
  echo "Success at verify status"
else
  echo "FAIL at verify status"
  exit 1
fi

}

while [ $# -gt 0 ]
do
  case "$1" in
   -d)
      hostip=$2
      shift
      shift
      ;;
   -t)
      leasety=$2
      shift
      shift
      ;;
   -h)
      hn=$2
      shift
      shift
      ;;
   -c)
      conname=$2
      shift
      shift
      ;;
   -s)
      cstatus=$2
      shift
      shift
      ;;
   -e)
      exptime=$2
      shift
      shift
      ;;
  esac
done

#--------------------------------
#         Main starts here
#--------------------------------

if [ "$hostip" != "" ]; then
  acquiremac
else
  macadd=00:ff:aa:bb:cc:dd
fi
blockconn
tempcout="$trows"
#echo "tempcout=$tempcout"
everdidcheck=0
while [ "$tempcout" != 0 ]
do
# in the meantime, to verify mac address
grep $macadd $G_CURRENTLOG/$tempcout"conn"
if [ "$?" = "0" ]; then
  echo "Success at verify mac address"
  checkcontents
  everdidcheck=1
fi
tempcout=`expr $tempcout - 1`
done

if [ "$everdidcheck" = "0" ]; then
  echo "Fail: contents in the dhcp connection list are not matched"
  exit 1
else
  echo "Success verify all"
  exit 0
fi


