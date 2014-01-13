#/bin/bash
# Author        :   
# Description   :
#   This tool is using to 
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   |           | Inital Version       
#21 Nov 2011    |   1.0.1   | andy      | modify match rule to fix BUG: grep ".*$content" -> `grep "$content". need modify testcase B-GEN-TR98-BA.HOSTS-001.xml input -c : HostNumberOfEntries -> InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.Hosts.HostNumberOfEntries
#25 Nov 2011    |   1.0.2   | andy      | modify match rule,fit for CLI_dut log

REV="$0 version 1.0.1 (21 Nov 2011)"
# print REV

echo "${REV}"

usage="Usage: getValue.sh -f <config file> -c <check point> -v <variable name> -o <outputfile> [-h]\nexpample:.\getValue.sh -f GPV_root_ouput.log -c InternetGatewayDevice.LANDevice.1.Hosts.HostNumberOfEntries -v TMP_TR069_CUSTOM_HostNumberOfEntries -o output.log\n"
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

#value=`grep "$content" $configFile |awk '{print $(NF)}'`

value=`grep "$content" $configFile |awk -F '=' '{print $(NF)}' |sed 's/^ *//g'`

echo "$varName=$value" | tee $outputFile
