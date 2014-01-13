#!/usr/bin/bash
#
# This script is to get BHR2 AssociatedDevice instance number
# 
#
# Hugo 12/28/2010
#

#G_CURRENTLOG="/tmp"
#U_ECB=192.168.1.250
#G_PROD_IP_ETH0_0_0=192.168.1.1
#U_USER=admin
#U_PWD=admin1
#media=clink0
echo > $G_CURRENTLOG/mocanode.txt

while [ $# -gt 0 ]
do 
    case $1 in
	-f)
	    file=$2
	    echo "The file is : $file" >> $G_CURRENTLOG/mocanode.txt
	    shift 2
	    ;;
	-m)
	    media=$2
	    shift 2
	    ;;
    esac
done

if [ $media = 0 ]; then
    media='clink0'
    echo "operation on Lan Coax" >> $G_CURRENTLOG/mocanode.txt
elif [ $media = 1 ]; then
    media='clink1'
    echo "operation on Wan Coax" >> $G_CURRENTLOG/mocanode.txt
else
    echo "Check testsuite file. There missing defination of U_COAX" >> $G_CURRENTLOG/mocanode.txt
    exit 1
fi

# operation in DUT
if [ -z $file ]; then
clicfg.pl -t shell_file.txt -i 23 -u $U_USER -p $U_PWD -l $G_CURRENTLOG -d $G_PROD_IP_ETH0_0_0 -n -v "system exec /bin/EN2210_clnkstat -i $media -a" -m "Wireless Broadband Router> "
file="$G_CURRENTLOG/shell_file.txt"
echo "The file is : $file" >> $G_CURRENTLOG/mocanode.txt
fi

# get MAC in ECB
clicfg.pl -t clicfg_netifconf_01.txt -i 23 -u $U_USER -p $U_PWD -l $G_CURRENTLOG -d $U_ECB -n -v "net ifconfig $media" -m "Wireless Broadband Router> "
mac_moca=`cat $G_CURRENTLOG/clicfg_netifconf_01.txt | grep "MAC=" | awk '{print substr($8,5.17)}'`
mac_moca=`echo $mac_moca | tr [:lower:] [:upper:] | tr -d "\r" | tr -d "\n"`
echo "The MoCA device MAC in its console: $mac_moca" >> $G_CURRENTLOG/mocanode.txt 

index=0
arr=(`cat $file`)
array_length=${#arr[@]}

echo "Total character units: ${array_length}" >> $G_CURRENTLOG/mocanode.txt

i=0
while [ $i -lt $array_length ]
do 
    compstr=`echo ${arr[$i]} | tr [:lower:] [:upper:] | tr -d '\r'`
    if [ "$compstr" = "$mac_moca" ]; then
	    item=`expr $i - 5`
            nnum=`echo ${arr[$item]} | tr -d ':' | tr -d '\r'`
	    echo "Node number in console: $nnum" >> $G_CURRENTLOG/mocanode.txt
	    let nnum=$nnum+1
	    echo "Node number in TR: $nnum" >> $G_CURRENTLOG/mocanode.txt
	    echo $nnum > $SQAROOT/logs/current/node_num.txt
	    break
    fi
    let i=$i+1
done

if [ -z $nnum ]; then
    i=0
    let trigercount=0
    while [ $i -lt $array_length ]
    do
      compstr=`echo ${arr[$i]} | tr [:lower:] [:upper:] | tr -d '\r'`
      if [ "$compstr" = "MAC" ]; then
          trigercount=`expr $trigercount + 1` 
      fi
      if [ $trigercount -eq 3 ]; then
            item=`expr $i - 3`
            nnum=`echo ${arr[$item]} | tr -d ':' | tr -d '\r'`
            echo "Node number in console: $nnum" >> $G_CURRENTLOG/mocanode.txt
            let nnum=$nnum+1
            echo "Node number in TR: $nnum" >> $G_CURRENTLOG/mocanode.txt
            echo $nnum > $SQAROOT/logs/current/node_num.txt
            break
      fi
      let i=$i+1
    done
fi

exit 0


