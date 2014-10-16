#!/bin/bash
VER="1.0.1"
echo "$0 version : ${VER}"

usage="Usage: acquirDefaultConnectionService.sh -o <output file> [-h]\nexpample:\nacquirDefaultConnectionService.sh -o abc.log\t#the logdir is $G_CURRENTLOG\\abc.log\n"

while getopts ":o:ht" opt ;
do
	case $opt in
		o)
	        output=$OPTARG
			;;

		h)
			echo -e $usage
			exit 0
			;;
        t)
            echo "using test mode"
            U_PATH_TBIN=./
            G_CURRENTLOG=/tmp
            G_PROD_IP_BR0_0_0=192.168.0.1
            U_DUT_TELNET_USER=admin
            U_DUT_TELNET_PWD=QwestM0dem
            #U_DUT_TYPE
            #U_DUT_FW_VERSION
            ;;

		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo -e $usage
			exit 1
	esac
done

if [ -z $output ]; then
	echo "WARN: Please assign the output file"
	echo $usage
	exit 1
fi

####date for test#############
#U_PATH_TBIN=.
#G_CURRENTLOG=/root/x
#G_PROD_IP_BR0_0_0=192.168.0.1
#G_PROD_USR0=admin
#G_PROD_PWD0=QwestM0dem
#U_DUT_TYPE=Q2K
#U_DUT_FW_VERSION=1.2.3
#############################
#InternetGatewayDevice.Layer3Forwarding.DefaultConnectionService=InternetGatewayDevice.WANDevice.1.WANConnectionDevice.10.WANPPPConnection.1
    cd $U_PATH_TBIN/tr69
    ruby tr69client.rb -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 -v GPV -p InternetGatewayDevice.Layer3Forwarding.DefaultConnectionService -o $G_CURRENTLOG/$output.tmp
    cd -

	dos2unix $G_CURRENTLOG/$output.tmp
	res=`grep 'InternetGatewayDevice.Layer3Forwarding.DefaultConnectionService[[:space:]]*=' $G_CURRENTLOG/$output.tmp`
    #echo "the result is "$res
	if [ -z "$res" ]; then
		exit 1
	fi
	#echo $res | awk '-F=' '{print "U_TR069_DEFAULT_CONNECTION_SERVICE=" $2}' | tee $G_CURRENTLOG/$output
    echo $res | awk '{print $3}'| awk '-F.' '{print "U_TR069_DEFAULT_CONNECTION_SERVICE=" $0" ""U_TR069_WANDEVICE_INDEX=" $1"."$2"."$3 " ""U_TR069_WANCONNECTIONDEVICE_INDEX=" $4"."$5}' | tee $G_CURRENTLOG/$output
	exit 0
