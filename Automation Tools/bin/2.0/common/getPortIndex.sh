#/bin/bash
# Author        :   
# Description   :
#   This tool is using to 
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   |           | Inital Version       
#

REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV

echo "${REV}"

usage="Usage: getPortIndex.sh -f <log file> -o <output file> [-h]\nexpample:\getPortIndex.sh -f input.log -o getPortIndex.log\n"
while getopts ":f:o:h" opt ;
do
	case $opt in
		f)
			logfile=$OPTARG
			;;

        o)
			outputfile=$OPTARG
			;;

		h)
			echo -e $usage
			exit 0
			;;

		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo -e $usage
			exit 1
	esac
done

grep ".*Status=Disabled" $logfile |awk -F . '{print $(NF-1)}' > $G_CURRENTLOG/getPortIndex.log

index_1=`cat $G_CURRENTLOG/getPortIndex.log | head -1`
index_2=`cat $G_CURRENTLOG/getPortIndex.log | tail -1`

rm -f $G_CURRENTLOG/getPortIndex.log

echo "TMP_TR069_CUSTOM_PORT_INDEX_1=$index_1"
echo "TMP_TR069_CUSTOM_PORT_INDEX_2=$index_2"
echo "TMP_TR069_CUSTOM_PORT_INDEX_1=$index_1 TMP_TR069_CUSTOM_PORT_INDEX_2=$index_2" >$outputfile
