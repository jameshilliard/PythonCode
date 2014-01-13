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
U_JACS=/root/automation/bin/1.0/jacs
G_SUB_URL=""

perl $U_JACS/generateCase.pl -s $TMP_DUT_WAN_IP -l "" -u actiontec -p actiontec -n InternetGatewayDevice.Layer3Forwarding.DefaultConnectionService -t GPV -d $G_CURRENTLOG

#ls $G_CURRENTLOG/GPV_InternetGatewayDevice.Layer3Forwarding.DefaultConnectionService.tc
#sleep 2
perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_dns_server.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "killall jacs" -v "perl $U_JACS/executeTest.pl -s $U_JACS/jacs -f $G_CURRENTLOG/GPV_InternetGatewayDevice.Layer3Forwarding.DefaultConnectionService.tc -d $G_CURRENTLOG -l defaultConnectionService.tmp "

cat $G_CURRENTLOG/defaultConnectionService.tmp |grep "The getting value is:"|awk -F: '{print $2}'|sed "s/ //g"| awk '-F.' '{print "U_TR069_DEFAULT_CONNECTION_SERVICE=" $0" ""U_TR069_WANDEVICE_INDEX=" $1"."$2"."$3 " ""U_TR069_WANCONNECTIONDEVICE_INDEX=" $4"."$5}' | tee $G_CURRENTLOG/$output

exit 0
