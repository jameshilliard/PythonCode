#!/bin/bash

usage="Usage: tsharkDNS.sh [-h]\nexpample:\ntsharkDNS.sh\n"

while getopts ":th" opt ;
do
	case $opt in
		h)
			echo -e $usage
			exit 0
			;;

        t)
            G_CURRENTLOG=/dev/shm
            TMP_DUT_WAN_IP=13.0.0.6
            G_PROD_DNS1_BR0_0_0=210.22.80.3
            G_HOST_IF0_1_0=eth1
            U_CUSTOM_WAN_HOST2=vosky.com
            ;;

		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo -e $usage
			exit 1
	esac
done

createlogname(){
    lognamex=$1
    echo "ls $G_CURRENTLOG/$lognamex*"
    ls $G_CURRENTLOG/$lognamex* 2> /dev/null
    if [  $? -gt 0 ]; then
        echo "file not exists"
        echo "so the current file to be created is : "$lognamex""_"1"
        currlogfilename=$lognamex"_""1"
    else
        echo "file exists"
        curr=`ls $G_CURRENTLOG/$lognamex*|wc -l`
        let "next=$curr+1"
        echo "so the current file to be created is : "$lognamex"_"$next
        currlogfilename=$lognamex"_"$next
    fi
}

createlogname tshark.log
#comment="# ----------------------- #"

echo "tshark -i $G_HOST_IF0_1_0 | grep \"${TMP_DUT_WAN_IP}.*${G_PROD_DNS1_BR0_0_0}.*DNS.*${U_CUSTOM_WAN_HOST2}\" | tee $G_CURRENTLOG/$currlogfilename"
tshark -i $G_HOST_IF0_1_0 | grep "${TMP_DUT_WAN_IP}.*${G_PROD_DNS1_BR0_0_0}.*DNS.*${U_CUSTOM_WAN_HOST2}" | tee $G_CURRENTLOG/$currlogfilename &

sleep 3
echo "ping $U_CUSTOM_WAN_HOST2 -I $G_HOST_IF0_1_0 -c 1"
ping $U_CUSTOM_WAN_HOST2 -I $G_HOST_IF0_1_0 -c 1

sleep 3
killall tshark

sleep 1
if [ -s $G_CURRENTLOG/$currlogfilename ]; then
    echo -e "\033[33m PASSED:Capture DNS reuqest. \033[0m"
    cat $G_CURRENTLOG/$currlogfilename
    exit 0
else
    echo -e "\033[33m FAILED:NOT Capture DNS reuqest. \033[0m"
    exit 1
fi
