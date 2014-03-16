#!/bin/bash
#---------------------------------
# Name: Howard Yin
# Description:
# This script is used to
#
#--------------------------------
# History    :
#   DATE        |   REV  | AUTH   | INFO
#13 Apr 2012    |   1.0.0   | howard    | Inital Version

if [ -z $U_PATH_TBIN ] ;then
    source resolve_CONFIG_LOAD.sh
else
    source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh
fi

REV="$0 version 1.0.0 (13 Apr 2012)"
# print REV
echo "${REV}"


while [ $# -gt 0 ]
do
    case "$1" in
    -n)
        nega=1
        echo "negative mode engaged!"
        shift 1
        ;;
    
    *)
        echo ".."
        exit 1
        ;;
    esac
done

#   flag_restore=""
#   flag_gui_setup=""
#
#   restore_post_files=(
#   )

do_restore_mac(){
    for ((i=0;i<`eval echo '$'{#$arrayName[@]}`;i++));
    do
        current_post_file=`eval echo '$'{$arrayName[i]}`
        
        if [ ! -f $U_PATH_WIFICFG/$current_post_file ] ;then
            echo "AT_ERROR : post file $U_PATH_WIFICFG/$current_post_file not existed !"
            exit 1
        fi
        
        $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/$current_post_file $U_AUTO_CONF_PARAM
        
        gui_rc=$?
        
        if [ $gui_rc -gt 0 ] ;then
            echo "AT_ERROR : restore MAC setting failed ."
            exit 1
        else
            echo "Grestore MAC setting succeed !"
            #exit 0
        fi
    done
    }
    
do_restore_mac2(){
    for ((i=0;i<`eval echo '$'{#$arrayName[@]}`;i++));
    do
        current_post_file=`eval echo '$'{$arrayName[i]}`
        
        if [ ! -f $U_PATH_WIFICFG/$current_post_file ] ;then
            echo "AT_ERROR : post file $U_PATH_WIFICFG/$current_post_file not existed !"
            exit 1
        fi
        
        $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/$current_post_file  -v "U_WIRELESSCARD_MAC=$U_WIRELESSCARD_MAC2" $U_AUTO_CONF_PARAM
        
        gui_rc=$?
        
        if [ $gui_rc -gt 0 ] ;then
            echo "AT_ERROR : restore MAC setting failed ."
            exit 1
        else
            echo "Grestore MAC setting succeed !"
            #exit 0
        fi
    done
    }

bash $U_PATH_TBIN/verifyDutLanConnected.sh

lan_rc=$?

if [ $lan_rc -gt 0 ] ;then
    echo "AT_ERROR : lan connection un-available !"
    exit 1
fi

arrayName="restore_post_files"

if [ "$flag_restore" == "1" ] ;then
    if [ "$flag_gui_setup" == "1" ] ;then
        do_restore_mac
    elif [ "$flag_gui_setup" == "2" ] ;then
        do_restore_mac2
    fi
elif [ "$flag_gui_check" == "0" ] ;then
    echo "  no need to restore MAC setting ."
    exit 0
fi
