#!/bin/bash

usage="Usage: tr69AddobjectByGUI.sh -c <config file> -o <output file> -n <node> [-f *indexflag*] [-h]\nexpample:\n.tr69AddobjectByGUIsh -c $G_CURRENTLOG\B-GEN-TR98-BA.PFO-003-RPC001 -o output.log -n PortMapping\n"

indexflag=0
while getopts ":c:o:n:fh" opt ;
do
	case $opt in
		c)
	        config=$OPTARG
			;;

		o)
			output=$OPTARG
			;;

		n)
			node=$OPTARG
			;;

		h)
			echo -e $usage
			exit 0
			;;
		f)
			indexflag=1
			;;

		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo -e $usage
			exit 1
	esac
done

if [ -z $config ]; then
	echo "WARN: Please assign the config file"
	echo $usage
	exit 1
fi

if [ -z $output ]; then
	echo "WARN: Please assign the output file"
	echo $usage
	exit 1
fi

if [ -z $node ]; then
	echo "WARN: Please assign the node"
	echo $usage
	exit 1
fi

if [ $indexflag -eq 1 ]; then
	Node=`echo "$U_TR069_DEFAULT_CONNECTION_SERVICE.${node}NumberOfEntries"`
	
	echo "python -u autoconf.py $U_DUT_TYPE $U_PATH_TR069CFG/$config $U_AUTO_CONF_PARAM"
	
	cd $U_PATH_TBIN/AutoConfig
	python -u autoconf.py $U_DUT_TYPE $U_PATH_TR069CFG/$config $U_AUTO_CONF_PARAM
	cd -
	
#	perl $U_PATH_TBIN/clicfg.pl -l $G_CURRENTLOG -t telnetGPV.log -d $G_PROD_IP_BR0_0_0 -i 23 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -m ">" -v "gpv $Node"

    cd $U_PATH_TBIN/tr69
    ruby tr69client.rb -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 -v GPV -p $Node -o $G_CURRENTLOG/telnetGPV.log
    cd -
	
	if [ ! -e $G_CURRENTLOG/telnetGPV.log ]; then
        echo -e "\033[33m gpv ${node}NumberOfEntries failed! \033[0m"
		exit 1
	fi
	
	cat $G_CURRENTLOG/telnetGPV.log | awk '{print "U_TR069_PORT_MAPPING_INDEX=" $3}' > $G_CURRENTLOG/$output
	exit 0
fi

if [ $indexflag -eq 0 ]; then
	Node=`echo "$U_TR069_DEFAULT_CONNECTION_SERVICE.$node."`

#	perl $U_PATH_TBIN/clicfg.pl -l $G_CURRENTLOG -t telnetGPV_1.log -d $G_PROD_IP_BR0_0_0 -i 23 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -m ">" -v "gpv $Node"

    cd $U_PATH_TBIN/tr69
    ruby tr69client.rb -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 -v GPV -p $Node -o $G_CURRENTLOG/telnetGPV_1.log
    cd -
	
	awk -F. '{print $offset}' offset=`echo $Node | awk -F. '{print NF}'` $G_CURRENTLOG/telnetGPV_1.log | sort -nu > $G_CURRENTLOG/indexList_1.log
	
	echo "python -u autoconf.py $U_DUT_TYPE $U_PATH_TR069CFG/$config $U_AUTO_CONF_PARAM"
	
	cd $U_PATH_TBIN/AutoConfig
	python -u autoconf.py $U_DUT_TYPE $U_PATH_TR069CFG/$config $U_AUTO_CONF_PARAM
	cd -
	
#	perl $U_PATH_TBIN/clicfg.pl -l $G_CURRENTLOG -t telnetGPV_2.log -d $G_PROD_IP_BR0_0_0 -i 23 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -m ">" -v "gpv $Node"
    cd $U_PATH_TBIN/tr69
    ruby tr69client.rb -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 -v GPV -p $Node -o $G_CURRENTLOG/telnetGPV_2.log
    cd -
	
	awk -F. '{print $offset}' offset=`echo $Node | awk -F. '{print NF}'` $G_CURRENTLOG/telnetGPV_2.log | sort -nu > $G_CURRENTLOG/indexList_2.log
	
	diffvar=`diff $G_CURRENTLOG/indexList_1.log $G_CURRENTLOG/indexList_2.log`
	if [ $? -eq 0 ]; then
        echo -e "\033[33m NO object is added! \033[0m"
		exit 1
	fi
	
	echo $diffvar | grep -o [0-9]*$ | awk '{print "U_TR069_PORT_MAPPING_INDEX=" $0}' > $G_CURRENTLOG/$output
	exit 0
fi
