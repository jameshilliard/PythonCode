#/usr/bin/bash -w
##############################################################################
#
#
#   Description : 
#       A tool to do stress test on USB wireless card 
#   Operation :
#       down and up device and scan SSID frequently 
#   Purpose :
#       Make sure the USB wireless card works well during do down and up frequently
#   Author : 
#       rayofox(lhu@actiontec.com)
#   Release History :
#       V 1.0   :       Tue Nov 29 14:52:43 CST 2011
#
##############################################################################

# default parameters value 
loops=1
wifi=wlan0
tt=0

while getopts "hi:r:t" arg 
do
        case $arg in
             i)
                echo "wireless interface name is arg:$OPTARG" 
                wifi=$OPTARG
                ;;
             r)
                echo "loops count : $OPTARG"
                loops=$OPTARG
                ;;
             t)
                 tt=1
                 ;;
             h)
                 echo "Usage : $0 [-h] [-i WIFI_NAME] [-r LOOP_COUNT] [-t]"
                 exit 0
                 ;;
             ?)  
            echo "unkonw argument"
        exit 1
        ;;
        esac
done

echo "Begin Test : "
echo "Loop count : ${loops} "
echo "Wireless Interface : ${wifi}"
if [ $tt -eq 0 ];then
    echo "up and down dev using command : ip link set ${wifi} up/down"
else 
    echo "up and down dev using command : iconfig ${wifi} up/down"
fi

for i in `seq ${loops}`; do
    echo ""
    echo ""
    echo "====================================================================="
    echo "LOOP ==> ${i}"
    date
    # 
    if [ $tt -eq 0 ];then
        echo "up and down dev using command : ip link set ${wifi} up/down"
        ip link set ${wifi} down
        ip link set ${wifi} up
    else 
        echo "up and down dev using command : ifconfig ${wifi} up/down"
        ifconfig ${wifi} down
        ifconfig ${wifi} up
    fi
    
    sleep 2

    res=`iw dev ${wifi} scan | grep SSID | awk '{print $2}' | sort -n | xargs echo`
    echo "Find SSIDs : ${res}"
    
    if [ "${res}" == "" ];then
        echo "Scan failed!"
        date
        #exit 4
    fi

    
done
