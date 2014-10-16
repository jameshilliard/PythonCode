#!/bin/bash -w
#---------------------------------
# Name: Tom(caipenghao)
# Description: 
# This script is used to set the environment from afu test(make sure the configure file is here)
#
#
#--------------------------------
if [ $# -eq 0 ]
    then
	echo "acf_env_setting.sh -l logaddress -h help -t testcase"
	exit 1
fi

while [ $# -gt 0 ]
do
    case "$1" in
    
    -h)
	echo "acf_env_setting.sh -l logaddress -h help -t testcase"
	exit 1
	;;
    -l)
	logadr=$2
	shift
	shift
	;;
    -t)
	testcase=$2
	shift
	shift
	;;
    *)
	echo "acf_env_setting.sh -l logaddress -h help -t testcase"
	exit 1
	;;
    esac       
done

if [ "$testcase" = "" ]
    then
	echo "acf_env_setting.sh  -l logaddress -h help -t testcase"
	exit 1

fi

if [ "$logadr" = "" ]
    then
	logadr=`pwd`
fi


#write the special variable
echo "THE SPECIAL VARIABLE FOR THIS PART IS:">> $logadr/result.log
echo -n '$KEYWORD_ONE= '>> $logadr/result.log
echo "$KEYWORD_ONE">> $logadr/result.log
echo -n '$KEYWORD_TWO= '>> $logadr/result.log
echo "$KEYWORD_TWO">> $logadr/result.log
echo -n '$KEYWORD_THREE= '>> $logadr/result.log
echo "$KEYWORD_THREE">> $logadr/result.log
echo -n '$DEFAULT_SAVE_PATH='>> $logadr/result.log
echo "$DEFAULT_SAVE_PATH">> $logadr/result.log
echo -n '$DEFAULT_SAVE_NAME='>> $logadr/result.log
echo "$DEFAULT_SAVE_NAME">> $logadr/result.log
echo "">> $logadr/result.log
echo "-------------------------------------------">> $logadr/result.log
echo "">> $logadr/result.log


#write the command
echo "THE COMMAND FOR THIS TEST CASE IS:">> $logadr/result.log

grep \<script\> $testcase > .temp
i=0
while read line
do
    index=`expr length "$line"`
    length=`expr $index - 17`
    string=`expr substr "$line" 9 $length`
    echo "STEP $i COMMAND:" >> $logadr/result.log
    echo "$string" >> $logadr/result.log
    i=`expr $i + 1`    
done < .temp
rm .temp*


#for config file

rm -f $DEFAULT_SAVE_PATH/$DEFAULT_SAVE_NAME

cp -rf $U_TESTPATH/../tcases/*.conf /tmp/

