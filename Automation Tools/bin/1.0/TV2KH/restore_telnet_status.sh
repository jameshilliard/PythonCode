#!/bin/bash
usage="bash $0 [-test]"
#LOG_FILE=$G_CURRENTLOG/waninfo
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
        U_DUT_TELNET_DEFAULT_STATUS=0
        U_PATH_SANITYCFG=$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/testcases/sanity/config
        shift 1
        ;;
    *)
        echo $usage
        #LOG_FILE=$1
        shift 1
        exit 1
        ;;
    esac
done

restoreTelnet(){
    echo "entering function restoreTelnet..."

    if [ $U_DUT_TELNET_DEFAULT_STATUS -eq 1 ]; then
        echo -e "\033[33m the default telnet status of this DUT is on,we don't have to turn it off \033[0m"
    elif [ $U_DUT_TELNET_DEFAULT_STATUS -eq 0 ]; then
        tnetState=`nmap $G_PROD_IP_BR0_0_0|grep telnet|awk '{print $2}'`
        echo -e "\033[33m current telnet status is : "$tnetState"\033[0m"
        if [ "$tnetState" == "open" ]; then
            echo -e "\033[33m shutting down telnet...\033[0m"
            cd $U_PATH_TBIN/AutoConfig
            python -u autoconf.py $U_DUT_TYPE $U_PATH_SANITYCFG/toCloseTnet
        elif [ "$tnetState" == "filtered" ]; then
            echo -e "\033[33m telnet is already dead ...\033[0m"
        fi
    elif [ $U_DUT_TELNET_DEFAULT_STATUS -eq -1 ]; then
        echo -e "\033[33m this DUT don't support telnet...\033[0m"
    fi
}

restoreTelnet
