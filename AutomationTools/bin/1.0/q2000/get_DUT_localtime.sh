#!/bin/bash
######################################################################################
# Author : Howard Yin                                                                #
# Date : 7-28-2011                                                                   #   
#                                                                                    #
######################################################################################
VER="1.0.0"
echo "$0 version : ${VER}"

usage="fetch_dut_time.sh [-test]"
test_flag=""

while [ -n "$1" ];
do
    case "$1" in
    -test)
        test_flag="-test"
        U_PATH_TBIN=.
        G_CURRENTLOG=/root/Downloads/cli/LOGS
        shift 1
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done

echo "bash $U_PATH_TBIN/cli_dut.sh $test_flag -v dut.date -o $G_CURRENTLOG/dut.date.log"
bash $U_PATH_TBIN/cli_dut.sh $test_flag -v dut.date -o $G_CURRENTLOG/dut.date.log

cat $G_CURRENTLOG/dut.date.log |
grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]'| 
awk -F : '{print "U_CUSTOM_LOCALTIME=" $1*60+$2+1}'
