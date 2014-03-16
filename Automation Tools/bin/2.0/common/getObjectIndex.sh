#/bin/bash
# Author        :   
# Description   :
#   This tool is using to 
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   |           | Inital Version
#07 Dec 2011    |   1.0.1   | andy      | update parse rule. first get the part befor "=". if the log contian such as ip,the origin rule will be get error value.
#

REV="$0 version 1.0.1 (31 Oct 2011)"
# print REV

echo "${REV}"

usage="Usage: getObjectIndex.sh -m <expect> -f <log file> -o <output file> [-h]\nexpample:\getObjectIndex.sh -m 54:e6:fc:6c:e2:26 -f xxx.log -o getObjectIndex.log\n"
while getopts ":m:f:o:h" opt ;
do
	case $opt in
		m)
	        expect=$OPTARG
			;;

		f)
			LogFile=$OPTARG
			;;

		o)
			outputFile=$OPTARG
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
index=0
#index=`grep "$G_HOST_MAC0_2_0" output.log |awk -F . '{printf $(NF-1)}'`

for i in `grep -i "$expect" $LogFile | awk -F = '{print $1}' | awk -F . '{print $(NF-1)}'`
do
    if [ $index -lt $i ] ;then
        let "index=$i"
    fi
done
echo "TMP_TR069_CUSTOM_OBJECT_INDEX=$index"
echo "TMP_TR069_CUSTOM_OBJECT_INDEX=$index" > $outputFile

if [ $index -ne 0 ]; then
	exit 0
else
    echo -e " getObjectIndex.sh failed! "
	exit 1
fi
