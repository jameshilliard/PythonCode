#!/bin/bash - 
#===============================================================================
#
#          FILE: run_single_fitnesse_case.sh
# 
#         USAGE: ./run_single_fitnesse_case.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: aliu@actiontec.com 
#  ORGANIZATION: 
#       CREATED: 09/05/2013 01:40:46 PM CST
#      REVISION:  ---
#===============================================================================

#set -o nounset                              # Treat unset variables as an error

while [ -n "$1" ];
do
    case "$1" in
        -c)
            echo "test case"
            testcase=$2
            shift 2
            ;;

        -help)
            USAGE
            exit 1
            ;;

        *)
            USAGE
            exit 1
            ;;
    esac
done

if [ -f "/root/FitAuto/pom.xml.bak"  ] ;then
    grep -q "#replcace the test name here#" /root/FitAuto/pom.xml.bak
    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : the pom.xml.bak is invalid, can not find out replace tag <replcace the test name here>"
        exit 1
    else
        rm -f /root/FitAuto/pom.xml
        cp -f /root/FitAuto/pom.xml.bak /root/FitAuto/pom.xml
        sed -i "s/#replcace the test name here#/$testcase/g" /root/FitAuto/pom.xml
        cd /root/FitAuto/
        mvn -P fitnesse-integration integration-test
        exit $?
    fi
else
    echo "AT_ERROR : Can not find out the original pom.xml.bak"
    exit 1
fi
