#!/bin/bash - 
#===============================================================================
#
#          FILE: sum_test.sh
# 
#         USAGE: ./sum_test.sh 
# 
#   DESCRIPTION: To sum the test results based on test suites.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: rayofox(lhu@actiontec.com), 
#  ORGANIZATION: 
#       CREATED: 10/08/2012 04:12:16 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
#echo $#

if [ $# -le 0 ]; then
    echo "you need pass 1 parameter : a file runtime_status_xxx"
    echo "Usage : "
    echo "sum_test runtime_status_xxx runtime_status_xxx2 ..."
    exit 1
fi

for xx in $* 
do
    echo -e "\n\n"
    echo "----------------"
    if [ -f "$xx" ]; then
        echo "File : $xx"
        cat "$xx" | grep -v pre_ | grep tst | awk '{printf("%s(%d)\nExpected: %d, Executed: %d, Passed: %d, Failed: %d, Skipped: %d, Missed: %d\n"),$13,$2,$2,$2-$3,$4,$5,$6,$3; SUM_TOT+=$2;SUM_PASS+=$4;SUM_FAIL+=$5;SUM_SKIP+=$6;SUM_MISS+=$3} END{printf("TOTAL : \nExpected: %d, Executed: %d, Passed: %d, Failed: %d, Skipped: %d, Missed: %d\n "),SUM_TOT,SUM_TOT-SUM_MISS,SUM_PASS,SUM_FAIL,SUM_SKIP,SUM_MISS}' ;
    else
        echo "File is not exist: $xx"
    fi
done

