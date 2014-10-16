#!/bin/bash
usage="multi_search_opr.sh [-test] -f <file> -e <string> ... -e <string> -n <string>"

result=0

tosearch(){
    ex(){
        perl $U_PATH_TBIN/searchoperation.pl -e $srhstr -f $filename

        let "result=$result+$?"
    }

    noex(){
        perl $U_PATH_TBIN/searchoperation.pl -n -e $srhstr -f $filename

        let "result=$result+$?"
    }

    if [ $flag -eq 0 ]; then
        ex
    else
        noex
    fi
}

while [ -n "$1" ];
do
    case "$1" in
    -e)
        flag=0
        srhstr=$2

        tosearch

        shift 2
        ;;
    -n)
        flag=1
        srhstr=$2

        tosearch

        shift 2
        ;;
    -f)
        filename=$2

        echo "file name : ${filename}"

        shift 2
        ;;
    -test)
        U_PATH_TBIN=./
        G_CURRENTLOG=/tmp
        G_HOST_IF0_2_0=eth2
        U_DUT_TYPE=TV2KH
        U_DUT_FW_VERSION=31.60L.14
        U_CUSTOM_FTP_SITE=192.168.10.241
        U_CUSTOM_FTP_USR=actiontec
        U_CUSTOM_FTP_PSW=actiontec
        shift 1
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done
echo "the final result is : $result"
exit $result
