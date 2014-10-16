#!/bin/bash
#---------------------------------
# Name: Andy Liu
# Description: 
# This script is used to check if the dependent cases configured in $U_PATH_TBCFG/dependency.cfg passed.
#
#--------------------------------

if [ ! -e $U_PATH_TBCFG/dependency.cfg ]; then
    echo -e "\033[33m no such $U_PATH_TBCFG/dependency.cfg \033[0m"
	exit 1
fi

#if [ ! -e $SQAROOT/logs/current/result.txt ]; then
#    echo -e "\033[33m no such $SQAROOT/logs/current/result.txt \033[0m"
#	exit 1
#fi

currentTestcase=`echo $G_CURRENTLOG | grep -o [^\/]*\.xml`

dependencys=`grep "^\s*$currentTestcase" $U_PATH_TBCFG/dependency.cfg | grep -v "#"  | awk '-F:' '{print $2}' | awk '-F,' '{print $0}' | tr -s "," " "`

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
#			echo -e "\033[33m $i is Failed! \033[0m" 
#			flag=1
#		fi
#	else
#		echo -e "\033[33m $i is not found! \033[0m" 
#		flag=1
#	fi 
#done

#the loop for ATE engine
for i in `echo $dependencys`
do
    result=`ls $G_SQAROOT/logs/current/ | grep $i`
    if [ $? -eq 0 ]; then
        expect=`echo $result | grep "PASSED"`
        if [ $? -eq 0 ]; then
            echo "$i is Passed!" 
        else
            echo -e "\033[33m $i is Failed! \033[0m" 
            flag=1
        fi
    else
        echo -e "\033[33m $i is not found! \033[0m" 
        flag=1
    fi 
done

exit $flag
