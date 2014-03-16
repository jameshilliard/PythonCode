#!/bin/bash
#-----------------------------------
#Name:Adny
#this script is to check the default gateway is correct.
#-----------------------------------

if [ $# -eq 0 ] ;then
    echo "check_default_gateway.sh -e expectGateway -i expectInterface"
    exit 1
fi

while [ $# -gt 0 ]
do
    case "$1" in
    -e)
        expectGateway=$2
        echo "expectGateway : $expectGateway"
        shift 2
        ;;
    -i)
        expectInterface=$2
        echo "expectInterface : $expectInterface"
        shift 2
        ;;
    esac
done

if [ -n $expectGateway ] && [ -n $expectInterface ] ;then
    defaultGateway=`route -n | grep ^0.0.0.0 | awk '{print $2}'`
    defaultInterface=`route -n | grep ^0.0.0.0 | awk '{print $8}'`

    route -n

    if [ "$expectGateway" = "$defaultGateway" ] && [ "$expectInterface" = "$defaultInterface" ] ;then
        echo -e "\033[33m Default gateway is correct! \033[0m"
        exit 0
    else
        echo -e "\033[33m Default gateway is worng! \033[0m"
        exit 1
    fi
fi

echo "check_default_gateway.sh -e expectGateway -i expectInterface"
exit 1
