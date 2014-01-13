#!/bin/bash
#   iface=$G_HOST_IF0_1_0
#
# Author        :   Howard Yin(hying@actiontec.com)
# Description   :
#   This tool is using to verify if the DUT is connected to WAN
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version       
#

REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV

echo "${REV}"

neg=0

while getopts ":i:tn" opt ;
do
	case $opt in
		i)
	        iface=$OPTARG
            echo "interface : $iface"
			;;
		#l)
        #    log=$OPTARG
		#	echo "log file : $log"
		#	;;
        t)
            U_CUSTOM_WAN_HOST=192.168.10.241
            G_HOST_IF0_1_0=eth1
            G_CURRENTLOG=/dev/shm
            SQAROOT=/root/automation
            G_BINVERSION=1.0
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

if [ -z "$iface" ] ;then
    iface=$G_HOST_IF0_1_0
fi

perl $SQAROOT/bin/$G_BINVERSION/common/verifyPing.pl -d $U_CUSTOM_WAN_HOST -I $iface -t 60 -l $G_CURRENTLOG 2>/dev/null

if [ $? -eq 0 ]; then
	exit 0
else
    echo -e "\033[33m verifyPing.pl failed! \033[0m"
	exit 1
fi
