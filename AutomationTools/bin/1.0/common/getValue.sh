#/bin/bash
usage="Usage: getValue.sh -f <config file> -c <check point> -v <variable name> -o <outputfile> [-h]\nexpample:.\getValue.sh -c HostNumberOfEntries -v TMP_TR069_CUSTOM_HostNumberOfEntries -o output.log\n"
while getopts ":f:c:v:o:h" opt ;
do
	case $opt in
		f)
			configFile=$OPTARG
			;;

        c)
			content=$OPTARG
			;;

		v)
			varName=$OPTARG
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

value=`grep ".*$content" $configFile |awk '{print $(NF)}'`

echo "$varName=$value" 
echo "$varName=$value" > $outputFile
