#!/bin/bash
REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV

echo "${REV}"

usage="Usage: launchtr69.sh -v <RPC> -c <config file> [-h]\nexpample:\nlaunchtr69.sh -v GPV -c B-GEN-TR98-BA.PFO-003-RPC001 \n"

while getopts ":c:v:ht" opt ;
do
	case $opt in
        v)
			RPC=$OPTARG
			;;
		c)
			config=$OPTARG
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
U_JACS=/root/automation/bin/1.0/jacs

jacs_tc=$config"_jacs"
ls $G_CURRENTLOG/$jacs_tc
if [ $? -eq 0 ] ;then
    rm -f $G_CURRENTLOG/$jacs_tc
fi

echo "listen 1234" >>$G_CURRENTLOG/$jacs_tc
echo "connect http://"$TMP_DUT_WAN_IP":4567/ actiontec actiontec NONE" >>$G_CURRENTLOG/$jacs_tc
echo "wait" >>$G_CURRENTLOG/$jacs_tc
echo "rpc InformResponse MaxEnvelopes=1" >>$G_CURRENTLOG/$jacs_tc
echo "wait" >>$G_CURRENTLOG/$jacs_tc

#for node in `cat $G_CURRENTLOG/$config`
#   DeleteObject DelObj
cat $G_CURRENTLOG/$config |while read line
do
    if [ "$RPC" == "GPV" ] ;then
        echo "adding  $line "
        echo "get_params $line" >>$G_CURRENTLOG/$jacs_tc
        echo "wait" >>$G_CURRENTLOG/$jacs_tc
    elif [ "$RPC" == "AddObj" ] ;then
        echo "adding  $line "
        echo "rpc cwmp:AddObject ObjectName=$line" >>$G_CURRENTLOG/$jacs_tc
        echo "wait" >>$G_CURRENTLOG/$jacs_tc
    elif [ "$RPC" == "DelObj" ] ;then
        echo "adding  $line "
        echo "rpc cwmp:DeleteObject ObjectName=$line" >>$G_CURRENTLOG/$jacs_tc
        echo "wait" >>$G_CURRENTLOG/$jacs_tc
    elif [ "$RPC" == "SPV" ] ;then
        echo "adding  $line "
        echo "set_params $line" >>$G_CURRENTLOG/$jacs_tc
        echo "wait" >>$G_CURRENTLOG/$jacs_tc
    elif [ "$RPC" == "GetRPCMethods" ] ;then
        echo "rpc cwmp:GetRPCMethods" >>$G_CURRENTLOG/$jacs_tc
        echo "wait" >>$G_CURRENTLOG/$jacs_tc
    else
        echo "$RPC not supported yet !"
        exit 1
    fi
done

echo "rpc0" >>$G_CURRENTLOG/$jacs_tc
echo "wait" >>$G_CURRENTLOG/$jacs_tc
echo "quit" >>$G_CURRENTLOG/$jacs_tc

log=$RPC"_"`basename $config`"_output.log"
perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/ssh_tr.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "killall jacs" -v "perl $U_JACS/executeTest.pl -s $U_JACS/jacs -f $G_CURRENTLOG/$jacs_tc -d $G_CURRENTLOG -l $log "
