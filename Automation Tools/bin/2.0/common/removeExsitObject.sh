#!/bin/bash
VER="1.0.1"
echo "$0 version : ${VER}"
# VER 1.0.1 fix BUG:diffent log name,cause parse can not find log.

usage="Usage: removeExsitObject.sh -n <node> [-th]"

while getopts ":n:th" opt ;
do
	case $opt in
        n)
            node=$OPTARG
            ;;

		h)
			echo -e $usage
			exit 0
			;;

        t)
            U_TR069_DEFAULT_CONNECTION_SERVICE=InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1
            #U_PATH_TBIN=./
            #G_CURRENTLOG=/root/temp
            #U_DUT_SN=CSJI1271000247
            ;;
            
		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo $usage
			exit 1
	esac
done

if [ -z $node ]; then
	echo "WARN: Please assign the node"
	echo $usage
	exit 1
fi

Node=`echo "$U_TR069_DEFAULT_CONNECTION_SERVICE.$node."`

#echo -e " perl $U_PATH_TBIN/clicfg.pl -l $G_CURRENTLOG -t telnetGPV-1.log -d $G_PROD_IP_BR0_0_0 -i 23 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -m \">\" -v \"gpv $Node\" "
#perl $U_PATH_TBIN/clicfg.pl -l $G_CURRENTLOG -t GPV_${Node}_output.log -d $G_PROD_IP_BR0_0_0 -i 23 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -m ">" -v "gpv $Node"

#cd $U_PATH_TBIN/tr69
#ruby tr69client.rb -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 -v GPV -p $Node -o $G_CURRENTLOG/telnetGPV_1.tmp
bash $U_PATH_TBIN/tr69client.sh -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 -v GPV -p $Node -o $G_CURRENTLOG/GPV_${Node}_output.log
#cd -


if [ ! -e $G_CURRENTLOG/GPV_${Node}_output.log ]; then
    echo -e " gpv $node failed! "
	exit 1
fi

dos2unix GPV_${Node}_output.log

if [ -s $G_CURRENTLOG/GPV_${Node}_output.log ]; then
    grep -o $U_TR069_DEFAULT_CONNECTION_SERVICE.PortMapping.[0-9]*. $G_CURRENTLOG/GPV_${Node}_output.log | sort -t "." -nu -k 9.1 | tee $G_CURRENTLOG/B-GEN-TR98-RPC-001
else
    echo -e " NO \"$Node\" object needs to be delete! "
	exit 0
fi

if [ ! -e $G_CURRENTLOG/B-GEN-TR98-RPC-001 ]; then
    echo -e " create RPC config file failed! "
	exit 1
fi

if [ -s $G_CURRENTLOG/B-GEN-TR98-RPC-001 ]; then
    bash $U_PATH_TBIN/launchTr69.sh -v DelObj -c B-GEN-TR98-RPC-001
else
    echo -e " NO \"$Node\" object needs to be delete! "
	exit 0
fi

if [ $? -ne 0 ]; then
    exit 1
fi

exit 0
