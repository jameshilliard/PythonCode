#!/bin/bash -w
#---------------------------------
# Name: Prince Wang
# Description:
# This script is used to check Ping result.
#
#--------------------------------
# History    :
#   DATE        |   REV  | AUTH   | INFO
#02 MAY 2012    |   1.0.0   | Prince    | Inital Version

if [ -z $U_PATH_TBIN ] ;then
    echo "source resolve_CONFIG_LOAD.sh"
	source resolve_CONFIG_LOAD.sh
else
    echo "source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh"
	source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh
fi


REV="$0 version 1.0.0 (2012-05-02)"
# print REV
echo "${REV}"

index=0

while [ $# -gt 0 ]
do
    case "$1" in
        -n)
            nega=1
            echo "negative mode engaged!"
            shift 1
            ;;
        -f)
            input_file=$2
            echo "Input file : ${input_file}"
            shift 2
            ;;
        -s)
            expected_ping_result=$2
            echo "expected_ping_result : ${expected_ping_result}"
            shift 2
            ;;
        -i)
            index=$2
            echo "index : ${index}"
            shift 2
            ;;
        -test)
            G_CURRENTLOG=.
            U_PATH_TBIN=.
            shift 1
            ;;
         *)
            echo "bash $0 -f <InputFile> -s <expected String>"
            exit 1
            ;;
    esac
done

if [ -z "${index}" ] ;then
    index=1
fi



if [ $index -eq 1 ] ;then
    echo "index=$index"
    if [ $expected_ping_result1 -eq 1 ] ;then
        echo "positive test......"
        perl $U_PATH_TBIN/searchoperation.pl -e "verifyPing passed" -f $G_CURRENTLOG/${input_file}
        if [ $? -ne 0 ] ;then
            echo -e "\nAT_ERROR : checkPing Result Fail!\nPositive test Fail!"
            exit 1
        else
            echo -e "\nCheckPing Result Pass!\npositive test Pass!"
        exit 0
        fi
    elif [ $expected_ping_result1 -eq 0 ] ;then
        echo "negative test......"
        perl $U_PATH_TBIN/searchoperation.pl -e "verifyPing passed" -f $G_CURRENTLOG/${input_file} -n
        if [ $? -eq 0 ] ;then
            echo -e "\nCheckPing Result Pass!\nNegative test Pass!"
            exit 0
        else
            echo -e "\nAT_ERROR : CheckPing Result Fail!\nNegative test Fail!"
            exit 1
        fi
    elif [ "${expected_ping_result1}" == "" ] ;then
        echo -e "\nThe var \$expected_ping_result1 not be defined!" && exit 1
    fi

elif [ $index -eq 2 ] ;then
    echo "index=$index"
    if [ $expected_ping_result2 -eq 1 ] ;then
        echo "positive test......"
        perl $U_PATH_TBIN/searchoperation.pl -e "verifyPing passed" -f $G_CURRENTLOG/${input_file}
        if [ $? -ne 0 ] ;then
            echo -e "\nAT_ERROR : checkPing Result Fail!\nPositive test Fail!"
            exit 1
        else
            echo -e "\nCheckPing Result Pass!\npositive test Pass!"
        exit 0
        fi
    elif [ $expected_ping_result2 -eq 0 ] ;then
        echo "negative test......"
        perl $U_PATH_TBIN/searchoperation.pl -e "verifyPing passed" -f $G_CURRENTLOG/${input_file} -n
        if [ $? -eq 0 ] ;then
            echo -e "\nCheckPing Result Pass!\nNegative test Pass!"
            exit 0
        else
            echo -e "\nAT_ERROR : CheckPing Result Fail!\nNegative test Fail!"
            exit 1
        fi
    elif [ "${expected_ping_result2}" == "" ] ;then
        echo -e "\nThe var \$expected_ping_result2 not be defined!" && exit 1
    fi
else
    echo -e "\nPlease define right index!"
    exit 1
fi
