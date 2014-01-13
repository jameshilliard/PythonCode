#!/bin/bash

usage="verify_dia.sh [-n] [-test]"
special_type=(TV2KH SV1KH)

special_fw=(31.60L.14)

dtype=common

ftype=common

result=0

switch(){
    echo "entering switch"
    for ((i=0;i<${#special_type[@]};i++)); do
        if [ ${special_type[i]} == $U_DUT_TYPE  ]; then
            dtype=$U_DUT_TYPE
        fi
    done

    for ((i=0;i<${#special_fw[@]};i++)); do
        if [ ${special_fw[i]} == $U_DUT_FW_VERSION  ]; then
            ftype=$U_DUT_FW_VERSION
        fi
    done
    echo "dtype="$dtype
    echo "ftype="$ftype

    if [ $dtype == "common" ]; then
        echo "entering switch : common"
        common
        echo "the result now is : $result"
    elif [ $dtype == $U_DUT_TYPE ]; then
        echo "entering switch : special"
        special
        echo "the result now is : $result"
    fi
}

common(){
    echo "entering function common ... "

    tofail(){
        echo "entering tofail"
        perl $U_PATH_TBIN/searchoperation.pl -e 'FAIL' -f $G_CURRENTLOG/diastatus.log
        let "result=$result+$?"
    }

    topass(){
        echo "entering topass"
        perl $U_PATH_TBIN/searchoperation.pl -n -e  'FAIL' -f $G_CURRENTLOG/diastatus.log
        let "result=$result+$?"
    }
    
    echo "starting to curl"
    
    curl http://$G_PROD_IP_BR0_0_0/advancedutilities_diagnostictest_refresh.html | tee $G_CURRENTLOG/diastatus.log

    $failorpass
}

special(){
    echo "entering function special ... "
    
    TV2KH:31.60L.14(){
        echo "entering function special -> TV2KH:31.60L.14 ..." 

        common
    }
    
    SV1KH:common(){
        echo "entering function special -> SV1KH:common ..."

        common
    }
    $dtype:$ftype
}

flag=0
failorpass=topass
while [ -n "$1" ];
do
    case "$1" in
    -n)
        flag=1
        echo "flag : ${flag}"
        failorpass=tofail
        shift 1
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
switch
echo "the final result is : $result"
exit $result
