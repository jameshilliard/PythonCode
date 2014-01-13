#!/bin/bash
usage="Usage: acquireIndex.sh -i <input file> -n <node> -o <output file> [-h]"

while getopts ":i:n:o:h" opt ;
do
	case $opt in
		i)
	        input=$OPTARG
			;;
        n)
            node=$OPTARG
            ;;

		o)
			output=$OPTARG
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

if [ -z $input ]; then
	echo "WARN: Please assign the input file"
	echo $usage
	exit 1
fi

if [ -z $node ]; then
	echo "WARN: Please assign the node"
	echo $usage
	exit 1
fi


if [ -z $output ]; then
	echo "WARN: Please assign the output file"
	echo $usage
	exit 1
fi

subnodeoffset=`echo $node | awk -F . '{print NF-1}'`
subnode=`echo $node | awk -F . '{print $offset}' offset=$subnodeoffset`

awk -F . '{print "TMP_TR069_addsubnodehere_INDEX=" $offset}' offset=`echo $node | awk -F . '{print NF}'` $G_CURRENTLOG/$input | sort -t "=" -nu -k 2.1 | tail -1 > $G_CURRENTLOG/$output

sed -i "s/addsubnodehere/$subnode/g" $G_CURRENTLOG/$output

exit 0
