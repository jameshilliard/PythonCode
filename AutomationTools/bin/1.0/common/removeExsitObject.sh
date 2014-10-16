#!/bin/bash
VER="1.0.0"
echo "$0 version : ${VER}"

usage="Usage: removeExsitObject.sh -n <node> [-h]"

while getopts ":n:h" opt ;
do
	case $opt in
        n)
            node=$OPTARG
            ;;

		h)
			echo -e $usage
			exit 0
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

#echo -e "\033[33m perl $U_PATH_TBIN/clicfg.pl -l $G_CURRENTLOG -t telnetGPV-1.log -d $G_PROD_IP_BR0_0_0 -i 23 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -m \">\" -v \"gpv $Node\" \033[0m"
#perl $U_PATH_TBIN/clicfg.pl -l $G_CURRENTLOG -t telnetGPV_1.log -d $G_PROD_IP_BR0_0_0 -i 23 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -m ">" -v "gpv $Node"

cd $U_PATH_TBIN/tr69
ruby tr69client.rb -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 -v GPV -p $Node -o $G_CURRENTLOG/telnetGPV_1.tmp
cd -


if [ ! -e $G_CURRENTLOG/telnetGPV_1.log ]; then
    echo -e "\033[33m gpv $Node failed! \033[0m"
	exit 1
fi

if [ -s $G_CURRENTLOG/telnetGPV_1.log ]; then
    grep -o $U_TR069_DEFAULT_CONNECTION_SERVICE.PortMapping.[0-9]*. $G_CURRENTLOG/telnetGPV_1.log | sort -t "." -nu -k 9.1 | tee $G_CURRENTLOG/B-GEN-TR98-RPC-001
else
    echo -e "\033[33m gpv $Node failed! \033[0m"
	exit 1
fi

if [ ! -e $G_CURRENTLOG/B-GEN-TR98-RPC-001 ]; then
    echo -e "\033[33m create RPC config file failed! \033[0m"
	exit 1
fi

if [ -s $G_CURRENTLOG/B-GEN-TR98-RPC-001 ]; then
    bash $U_PATH_TBIN/launchTr69.sh -v DelObj -c B-GEN-TR98-RPC-001
else
    echo -e "\033[33m NO \"$Node\" object needs to be delete! \033[0m"
	exit 0
fi

if [ $? -ne 0 ]; then
    exit 1
fi

exit 0
