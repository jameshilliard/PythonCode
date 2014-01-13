#!/bin/bash
#
# Author        :   Howard Yin(hying@actiontec.com)
# Description   :
#   This tool is using to scan SSID.
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version       
#

REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV

echo "${REV}"

usage="bash $0 -i <wlan interface> -s <SSID> -t <test mode> -n <nega mode> -c <scan only mode>\n after running this tool, the interface that connected to the same net with wlan interface will be down.\n but if you engage the scan only mode by using the parameter c, the link status will be restored eventually."

hp=10

neg=0

downed_ifs=(
)

down_index=0

scan_result=0

scan_only=0

while getopts ":i:s:thnc" opt ;
do
	case $opt in
        c)
            scan_only=1
            echo "scan only,the previous link status will be restored"
            ;;
		i)
	        wlan=$OPTARG
            echo "interface : $wlan"
			;;
		s)
            SSID=$OPTARG
			echo "SSID : $SSID"
			;;
        t)
            G_PROD_IP_BR0_0_0=192.168.0.1
            ;;
        n)
            neg=1
			echo "negative test engaged"
			;;
		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo -e $usage
			exit 1
	esac
done

turn_on_wlan(){
    #dhclient -r
    

    ifconfig "$wlan" up

    bcast=`echo $G_PROD_IP_BR0_0_0 |cut -d. -f 1,2,3`"."
    echo "the interfaces that connected to net "$bcast"x will be shut down !"
    downifs=`ifconfig | grep -B 1 $bcast |grep HWaddr |grep -v $wlan| awk '{print $1}'`
    for i in `echo $downifs`
    do
        echo "shutting down $i"

        ifconfig $i down

        echo "push $i in down_ifs $down_index"

        downed_ifs[down_index]=$i

        let "down_index=$down_index+1"
        
    done
    
    ifconfig $wlan |grep "inet addr:"
    
    if [ $? -eq 0 ] ;then
        route del default
        route add default gw $gtway dev $interface
    fi
    
    ifconfig
    route -n
}

check_wlan_on(){
    ifconfig |grep "$wlan"
    if [ $? -eq 0 ] ;then
        echo "$wlan is ready"
    else
        exit 1
    fi
}

scan_SSID(){
    hp_left=$hp
    for i in `seq 1 $hp`
    do
        echo "try $i"

        echo "ifconfig $wlan down"
        ifconfig $wlan down

        echo "ifconfig $wlan up"
        ifconfig $wlan up

        echo "iwlist $wlan scan | grep $SSID"
        iwlist $wlan scan | grep "$SSID"

        if [ $? -eq 0 ] ; then
            break
        else
            sleep 2
            let "hp_left=$hp_left-1"
        fi
    done

    echo "hp left : $hp_left"

    if [ $hp_left -eq 0 ] ;then
        if [ $neg -eq 0 ] ;then
            echo "scan $SSID failed"
            scan_result=1
        elif [ $neg -eq 1 ] ;then
            echo "scan $SSID passed"
            scan_result=0
        fi
    elif [ $hp_left -gt 0 ] ;then
        if [ $neg -eq 0 ] ;then
            echo "scan $SSID passed"
            scan_result=0
        elif [ $neg -eq 1 ] ;then
            echo "scan $SSID failed"
            scan_result=1
        fi
    fi

}

restore_net(){
    ifconfig $wlan down

    for ((i=0;i<${#downed_ifs[@]};i++));
    do
        echo "turning ${downed_ifs[i]} on ..."
        ifconfig ${downed_ifs[i]} up
    done

    echo "route add default gw $G_PROD_IP_BR0_0_0 dev $previous_dfl_dev"
    route add default gw $G_PROD_IP_BR0_0_0 dev $previous_dfl_dev
}

previous_dfl_dev=`route -n|grep "^0"|awk '{print $8}'`

turn_on_wlan

check_wlan_on

scan_SSID

if [ $scan_only -eq 1 ] ;then
    restore_net
fi

exit $scan_result
