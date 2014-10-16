#!/bin/bash

usage="Usage: testClassify.sh [-l <logdir default = current> ] [-h]\nexpample:\ntestClassify.sh -l logs1\t#fix the dir logs1\ntestClassify.sh\t\t\t#fix the dir current"

logdir=current

while getopts ":l:h" opt ;
do
	case $opt in
		l)
	        logdir=$OPTARG
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

if [ ! -e $SQAROOT/logs/$logdir ]; then
	echo "No such directory!"
	exit 1
fi

cd $SQAROOT/logs/$logdir
rm -f failedCases.txt passedCases.txt
pathprefix=`pwd -P`
for i in `cat result.txt |grep 'Testcase Passed:'|grep -v 'http'|grep -v 'Non-Testcase' |awk '{print $3}'`
do  #echo $i
    path=`ls | grep $i*`
    echo "Testcase Log : $pathprefix/$path" 									>> $pathprefix/passedCases.txt
    cat $i*/result.txt 															>> $pathprefix/passedCases.txt
    echo -e "============================================================\n\n"  >> $pathprefix/passedCases.txt
done
for i in `cat result.txt |grep 'Testcase FAILED:'|grep -v 'http'|grep -v 'Non-Testcase' |awk '{print $3}'`
do  #echo $i
    path=`ls |grep $i*`
    echo "Testcase Log : $pathprefix/$path" 									>> $pathprefix/failedCases.txt
    cat $i*/result.txt 															>> $pathprefix/failedCases.txt
    echo -e "============================================================\n\n"  >> $pathprefix/failedCases.txt
done
