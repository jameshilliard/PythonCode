#!/bin/bash
echo $*
echo '-----------------------------------------------------------------------------------'
echo "U_DUT_SW_VERSION = >${U_DUT_SW_VERSION}<"
echo "U_CUSTOM_FROM_FW_VER = >${U_CUSTOM_FROM_FW_VER}<"
echo "U_CUSTOM_TO_FW_VER = >${U_CUSTOM_TO_FW_VER}<"
if [ "$1" == "--SET" ];then
    shift
    echo $*
    if [ "$U_DUT_SW_VERSION" == "$U_CUSTOM_FROM_FW_VER" ];then
        echo "$*"
        $*
        exit $?
    else
        echo "NOT GA version : No need do GUI Setup"
    fi
elif [ "$1" == "--RESTORE" ];then
    shift
    echo $*
    if [ "$U_DUT_SW_VERSION" == "$U_CUSTOM_TO_FW_VER" ];then
        echo "$*"
        $*
        exit $?
    else
        echo "NOT Current Version : No need do restore (remove rule)"
    fi
elif [ "$1" == "--DO_IF_GA" ];then
    shift
    echo $*
    if [ "$U_DUT_SW_VERSION" == "$U_CUSTOM_FROM_FW_VER" ];then
        echo "$*"
        $*
        exit $?
    else
        echo "NOT GA Version : No need do it."
    fi
elif [ "$1" == "--DO_IF_CURRENT" ];then
    shift
    echo $*
    if [ "$U_DUT_SW_VERSION" == "$U_CUSTOM_TO_FW_VER" ];then
        echo "$*"
        $*
        exit $?
    else
        echo "NOT Current Version : No need do it."
    fi
fi

