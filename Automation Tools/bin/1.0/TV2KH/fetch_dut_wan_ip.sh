#!/bin/bash
usage="fetch_dut_wan_ip.sh [LOG_FILE | -test]"
LOG_FILE=$G_CURRENTLOG/waninfo
while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        U_DUT_TYPE=TV2KH
        U_DUT_FW_VERSION=31.60L.14
        U_PATH_TBIN=./
        G_PROD_IP_BR0_0_0=192.168.1.254
        U_DUT_TELNET_USER=admin
        U_DUT_TELNET_PWD=admin
        U_DUT_TELNET_DEFAULT_STATUS=1
        U_PATH_SANITYCFG=$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/testcases/sanity/config
        shift 1
        ;;
    *)
        echo $usage
        LOG_FILE=$1
        shift 1
       # exit 1
        ;;
    esac
done

special_type=(TV2KH)

special_fw=(31.60L.14)

dtype=common

ftype=common

commontnet(){
    echo "entering function commontnet..."
    sh $U_PATH_TBIN/getDUTwaninfo.sh $LOG_FILE
}
commonmini(){
    echo "entering function commonmini"
    echo "sorry,I'm still working on this function..."
}

common(){
    echo "entering function common..."

    if [ $U_DUT_TELNET_DEFAULT_STATUS -eq 1 ]; then
        commontnet
    elif [ $U_DUT_TELNET_DEFAULT_STATUS -eq 0 ]; then
        tnetState=`nmap $G_PROD_IP_BR0_0_0|grep telnet|awk '{print $2}'`
        echo "current telnet status is : "$tnetState
        if [ "$tnetState" == "open" ]; then
            commontnet
        elif [ "$tnetState" == "filtered" ]; then
            cat $U_PATH_SANITYCFG/toOpenTnet |sed "s/remTelUser=[^ |&]*/remTelUser=$U_DUT_TELNET_USER/g"|sed "s/remTelPass=[^ |&]*/remTelPass=$U_DUT_TELNET_PWD/g"|tee $G_CURRENTLOG/toOpenTnet
            #cat $G_CURRENTLOG/toOpenTnet |tee $U_PATH_SANITYCFG/toOpenTnet
            cd $U_PATH_TBIN/AutoConfig
            python -u autoconf.py $U_DUT_TYPE $G_CURRENTLOG/toOpenTnet
            commontnet
        fi
    elif [ $U_DUT_TELNET_DEFAULT_STATUS -eq -1 ]; then
        commonmini
    fi
}

special(){
    echo "entering function special"

    Q2K:common(){
        echo "entering function special -> Q2K:common..."
        commontnet
    }
    
    Q2K:QAB001-33.00L.11g(){
        echo "entering function special -> Q2K:QAB001-33.00L.11g..."
        commontnet
    }
    TV2KH:31.60L.14(){
        echo "entering special -> TV2KH:31.60L.14"
        tnetState=`nmap $G_PROD_IP_BR0_0_0|grep telnet|awk '{print $2}'`
        echo "current telnet status is : "$tnetState
        if [ "$tnetState" == "open" ]; then
            sh $U_PATH_TBIN/getDUTwaninfo.sh $LOG_FILE
        elif [ "$tnetState" == "filtered" ]; then
            cat $U_PATH_SANITYCFG/toOpenTnet |sed "s/remTelUser=[^ |&]*/remTelUser=$U_DUT_TELNET_USER/g"|sed "s/remTelPass=[^ |&]*/remTelPass=$U_DUT_TELNET_PWD/g"|tee $G_CURRENTLOG/toOpenTnet
            #cat $G_CURRENTLOG/toOpenTnet |tee $U_PATH_SANITYCFG/toOpenTnet
            cd $U_PATH_TBIN/AutoConfig
            python -u autoconf.py $U_DUT_TYPE $G_CURRENTLOG/toOpenTnet
            sh $U_PATH_TBIN/getDUTwaninfo.sh $LOG_FILE
        fi
        
    }
    $dtype:$ftype
}

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
elif [ $dtype == $U_DUT_TYPE ]; then
    echo "entering switch : special"
    special
fi
