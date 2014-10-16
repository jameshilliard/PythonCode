#!/bin/bash
REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV

echo "${REV}"

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
#        echo -e " so the current file to be created is : "$lognamex""
        currlogfilename=$lognamex
    else
#        echo "file exists"
        curr=`ls $G_CURRENTLOG/$lognamex*|wc -l`
        let "next=$curr"
#        echo -e " so the current file to be created is : "${lognamex}_$next""
        currlogfilename="${lognamex}_$next"
    fi
}


while getopts ":v:l:c:o:ht" opt ;
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

        o)
            timeout=$OPTARG
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

if [ -z "$timeout" ] ;then
    parameter="-e 300"
else
    parameter="-e $timeout"
fi

if [ -z "$RPC" ] ;then
    echo -e " WARN: Please assign the RPC operation method "
	echo $usage
	exit 1
else
	parameter="$parameter -v $RPC"
fi

if [ -z "$config" ] ;then
    echo -e " WARN: Please assign the config file "
	echo $usage
	exit 1
else
	parameter="$parameter -c $G_CURRENTLOG/$config"
fi

if [ -z "$logpath" ] ;then
    logpath=$G_CURRENTLOG
fi

#if [ -z $U_TR069_CUSTOM_RPC_DEBUG_LOG ]; then
	U_TR069_CUSTOM_RPC_DEBUG_LOG=1
#fi

if [ $U_TR069_CUSTOM_RPC_DEBUG_LOG -eq 1 ]; then
	echo $comment
    echo "full log mode!"

    createlogname ${RPC}_${config}_output.log
    echo "result file : $logpath/$currlogfilename"
    parameter="$parameter -o $logpath/$currlogfilename"

    createlogname ${RPC}_${config}_soap.log
    echo "soap file   : $G_CURRENTLOG/$currlogfilename"
    parameter="$parameter -f $G_CURRENTLOG/$currlogfilename"

    createlogname ${RPC}_${config}_log.log
    echo "log file    : $G_CURRENTLOG/$currlogfilename"
    parameter="$parameter -l $G_CURRENTLOG/$currlogfilename"
	echo $comment
else
	echo $comment
    echo "simple log mode!"

    createlogname ${RPC}_${config}_output.log
    echo "result file : $logpath/$currlogfilename"
    parameter="$parameter -o $logpath/$currlogfilename"

	echo $comment
fi

#cd $U_PATH_TBIN/tr69

echo $comment
echo -e " bash tr69client.sh -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 $parameter "
echo $comment

#ruby tr69client.rb -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 $parameter 
bash $U_PATH_TBIN/tr69client.sh -d $U_TR069_MOTIVE_SERVER -s $U_DUT_SN -x 5 $parameter 
rc=$?

if [ $rc -ne 0 ]; then
	echo -e " launch tr69client.rb Failed! "
	#cd -
	exit 1
fi

#cd -

exit 0

