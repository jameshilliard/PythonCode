#!/bin/bash
#---------------------------------
# 
# Author        :   Andy Liu
# Description   :
#       This script is used to check if the dependent cases configured in $U_PATH_TBCFG/dependency.cfg passed.
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   |           | Inital Version
#30 May 2013    |   3.0.0   | Andy      | modify for jenkins
#

REV="$0 version 3.0.0 (30 May 2013)"
# print REV

echo "${REV}"

config_file=$G_SQAROOT/testsuites/2.0/$U_DUT_TYPE/cfg/dependency.cfg
#
#--------------------------------

if [ ! -e "$config_file" ]; then
    echo -e " no such $config_file "
	exit 1
fi

#if [ ! -e $SQAROOT/logs/current/result.txt ]; then
#    echo -e " no such $SQAROOT/logs/current/result.txt "
#	exit 1
#fi

#currentTestcase=`echo $G_CURRENTLOG | grep -o [^\/]*\.xml`
#currentTestcase=`echo $G_CURRENTLOG | grep -o "B.*xml"`
echo "U_CUSTOM_CURRENT_CASE_ID=${U_CUSTOM_CURRENT_CASE_ID}"
currentTestcaseID=`echo "$U_CUSTOM_CURRENT_CASE_ID"|awk -F_ '{print $1}'`


dependencys=`grep "^\s*${currentTestcaseID}" $config_file | grep -v "#"  | awk '-F:' '{print $2}' | awk '-F,' '{print $0}' | tr -s "," " "`
echo "dependencys=$dependencys"
flag=0

##the loop for gflaunch.pl
#for i in `echo $dependencys`
#do
#	result=`grep $i $SQAROOT/logs/current/result.txt | tail -2 | grep -v 'http'`
#	if [ $? -eq 0 ]; then
#		expect=`echo $result | grep "Passed"`
#		if [ $? -eq 0 ]; then
#			echo "$i is Passed!" 
#		else
#			echo -e " $i is Failed! " 
#			flag=1
#		fi
#	else
#		echo -e " $i is not found! " 
#		flag=1
#	fi 
#done

#the loop for ATE engine
#for i in `echo $dependencys`
#do
#    result=`ls $G_SQAROOT/logs/current/ | grep $i`
#    if [ $? -eq 0 ]; then
#        expect=`echo $result | grep "PASSED"`
#        if [ $? -eq 0 ]; then
#            echo "$i is Passed!" 
#        else
#            echo -e " $i is Failed! " 
#            flag=1
#        fi
#    else
#        echo -e " $i is not found! " 
#        flag=1
#    fi 
#done

#the loop for jenkins
for i in `echo $dependencys`
do
    echo "sed -n \"/$i/\"p $G_SQAROOT/logs/current/case_result.log | awk '{print $3}'"
    result=`sed -n "/$i/"p $G_SQAROOT/logs/current/case_result.log | awk '{print $3}'`
    if [ "$result" == "passed" ] ;then
        echo "$i is Passed!"
    else
        echo "$i is Failed or not found!"
        flag=1
    fi
done

exit $flag
