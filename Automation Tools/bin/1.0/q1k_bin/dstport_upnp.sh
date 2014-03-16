#! /bin/sh
#################################################
#  dstport_upnp.sh 
#     This script will try to add UPnP rules to  
#  an external UPnP Internet Gateway Device
#
#  upnpc -a ip port external_port tcp | udp
#  upnpc -d external_port tcp | udp
#
#  Hugo 11/03/2009
#################################################

if [ "$1" = "" ]; then
   echo "Usage: dstport_upnp [-r <max number>] -a[d] <add/del rules>"
   exit 1
fi
range=10
is_delete=no
is_add=no
#G_HOST_TIP0_1_0=192.168.0.200
HOSTIP=`echo ${G_HOST_TIP0_1_0%/*}`
num=0
while [ $# -gt 0 ]
do
  case "$1" in
   -r)
      range=$2
      shift
      shift
      ;;
    -d)
      is_delete=yes
      shift
      ;;
    -a)
      is_add=yes
      shift
      ;;
    *)
      echo "Usage: dstport_upnp [-r <max number>] -a[d] <add/del rules>"
      exit 0
  esac
done

if [ ! -e /usr/bin/upnpc ]; then
  echo "there is missing upnpc tools, please fetch it under tools/1.0/testbed"
  exit 1
fi

GATEW=`echo ${G_PROD_IP_ETH0_0_0%/*}`
defgw=`route -n | grep ^0.0.0.0 | awk '{print $2}' | tr -d ' '`
if [ $GATEW != $defgw ]; then
  echo "excute: route del default gw $defgw"
  route del default gw $defgw
  echo "excute: route add default gw $GATEW"
  route add default gw $GATEW
fi

if [ "$is_add" = "yes" ]; then
  while [ $num -ne $range ]
  do
    /usr/bin/upnpc -a $HOSTIP 10$num 20$num TCP
    echo "add dst TCP port 20$num"
    /usr/bin/upnpc -a $HOSTIP 10$num 20$num UDP
    echo "add dst UDP port 20$num"
    num=`expr $num + 1`
  done
fi

if [ "$is_delete" = "yes" ]; then
   while [ $num -ne $range ]
     do
         /usr/bin/upnpc -d 20$num TCP
         echo "delete dst TCP port 20$num"
         /usr/bin/upnpc -d 20$num UDP
         echo "delete dst UDP port 20$num"
         num=`expr $num + 1`
     done
fi

# To recover previous default gw
if [ $GATEW != $defgw ]; then
  route del default gw $GATEW
  echo "excute: route del default gw $GATEW"
  route add default gw $defgw
  echo "excute: route add default gw $defgw"
fi
