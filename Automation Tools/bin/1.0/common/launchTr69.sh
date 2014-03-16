#!/bin/bash

usage="Usage: launchtr69.sh -v <RPC> -c <config file> [-h]\nexpample:\nlaunchtr69.sh -v GPV -c B-GEN-TR98-BA.PFO-003-RPC001 \n"
#G_CURRENTLOG=/root/temp
#U_PATH_TBIN=../Q2K
#U_TR069_MOTIVE_SERVER=10.20.10.26:5031
#U_DUT_SN=00247BDFEB00
#U_TR069_CUSTOM_RPC_DEBUG_LOG=0

createlogname(){
    lognamex=$1
#    echo "ls $G_CURRENTLOG/$lognamex*"
    ls $G_CURRENTLOG/$lognamex* 2> /dev/null
    if [  $? -gt 0 ]; then
#        echo "file not exists"
#        echo -e "\033[33m so the current file to be created is : "$lognamex"\033[0m"
        currlogfilename=$lognamex
    else
#        echo "file exists"
        curr=`ls $G_CURRENTLOG/$lognamex*|wc -l`
        let "next=$curr"
#        echo -e "\033[33m so the current file to be created is : "${lognamex}_$next"\033[0m"
        currlogfilename="${lognamex}_$next"
    fi
}

logpath=$G_CURRENTLOG
while getopts ":v:l:c:oflht" opt ;
do
	case $opt in
		v)
	        RPC=$OPTARG
			;;

		c)
			config=$OPTARG
			;;
        
        l)
			logpath=$OPTARG
			;;

		h)
			echo -e $usage
			exit 0
			;;
        t)
            G_CURRENTLOG=/tmp
            U_PATH_TBIN=../Q2K
            U_DUT_SN=CVJA1141900137
            U_TR069_MOTIVE_SERVER=10.20.10.26:5032
            U_TR069_CUSTOM_RPC_DEBUG_LOG=0
            ;;

		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo -e $usage
			exit 1
	esac
done

comment="# ----------------------- #"

if [ -z $RPC ]; then
    echo -e "\033[33m WARN: Please assign the RPC operation method \033[0m"
	echo $usage
	exit 1
else
	parameter="-v $RPC"
fi

if [ -z $config ]; then
    echo -e "\033[33m WARN: Please assign the config file \033[0m"
	echo $usage
	exit 1
else
	parameter="$parameter -c $G_CURRENTLOG/$config"
fi

if [ -z $U_TR069_CUSTOM_RPC_DEBUG_LOG ]; then
	U_TR069_CUSTOM_RPC_DEBUG_LOG=1
fi

if [ $U_TR069_CUSTOM_RPC_DEBUG_LOG -eq 1 ]; then
	echo $comment
    echo "debug log mode!"

    createlogname ${RPC}_${config}_output.log
    echo "result file : $logpath/$currlogfilename"
    parameter="$parameter -o $logpath/$currlogfilename"

    createlogname ${RPC}_${config}_diff.log
    echo "diff file   : $logpath/$currlogfilename"
    parameter="$parameter -f $logpath/$currlogfilename"

    createlogname ${RPC}_${config}_log.log
    echo "log file    : $logpath/$currlogfilename"
    parameter="$parameter -l $logpath/$currlogfilename"
	echo $comment
else
	echo $comment
    echo "NO debug log mode!"

    createlogname ${RPC}_${config}_output.log
    echo "result file : $logpath/$currlogfilename"
    parameter="$parameter -o $logpath/$currlogfilename"

	echo $comment
fi

cd $U_PATH_TBIN/tr69

echo $comment
echo -e "\033[33m ruby tr69client.rb -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 $parameter \033[0m"
echo $comment

ruby tr69client.rb -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 $parameter 
if [ $? -ne 0 ]; then
	echo -e "\033[33m launch tr69client.rb Failed! \033[0m"
	cd -
	exit 1
fi

cd -

exit 0

