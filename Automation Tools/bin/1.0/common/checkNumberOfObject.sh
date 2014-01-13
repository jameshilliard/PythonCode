#/bin/bash
usage="Usage: checkNumberOfObjectEX.sh -n <Node of Entries> -i <GPV log>[-h]\nexpample: checkNumberOfObjectEX.sh -n PortMappingNumberOfEntries -i GPV_B-GEN-TR98-BA.PFO-001-RPC-001_output.log\n"
while getopts ":n:i:th" opt ;
do
	case $opt in
		i)
			GPVfile=$OPTARG
			;;
        n)
			node=$OPTARG
			;;

		h)
			echo -e $usage
			exit 0
			;;
        t)
            G_CURRENTLOG=/root/temp
            ;;
		?)
			paralist=-1
			echo "WARN: '-$OPTARG' not supported."
			echo -e $usage
			exit 1
	esac
done

if [ -z $GPVfile ]; then
    echo -e "\033[33mWARN: Please assign the GPV log\033[0m"
	echo $usage
	exit 1
fi

if [ -z $node ]; then
    echo -e "\033[33mWARN: Please assign the node of NumberOfEntries\033[0m"
	echo $usage
	exit 1
fi

numberOfEnties=`grep "$node" $G_CURRENTLOG/$GPVfile | awk '{print $3}'`

numberOfFields=`grep "$node" $G_CURRENTLOG/$GPVfile | awk '{print $1}' | awk -F . '{print NF+1}'`

grep -v "$node" $G_CURRENTLOG/$GPVfile > $G_CURRENTLOG/${GPVfile}.tmp

numberOfObject=`cut -d . -f 1-$numberOfFields $G_CURRENTLOG/${GPVfile}.tmp | sort -t . -unk $numberOfFields | wc -l`

if [ $numberOfEnties -eq $numberOfObject ]; then
    echo "PASS:the NumberOfEntries is equal to the number of objects"
    exit 0
else
    echo -e "\033[33mthe NumberOfEntries is not equal to the number of objects\033[0m"
	exit 1
fi
