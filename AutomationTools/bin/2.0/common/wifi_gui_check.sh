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

#	$G_CURRENTLOG

if [ -z $G_CURRENTLOG ] ;then
	G_CURRENTLOG=/tmp/
fi

REV="$0 version 1.0.0 (13 Apr 2012)"
# print REV
echo "${REV}"


while [ $# -gt 0 ]
do
    case "$1" in
    -i)
		index=$2
        echo "	GUI setting ${index}"
        shift 2
        ;;
    
    *)
		echo ".."
        exit 1
        ;;
    esac
done

#	flag_gui_check=""
#
#	gui_check_post_files1=(
#	)
#
#	gui_check_post_files2=(
#	)

do_gui_check(){
	for ((i=0;i<`eval echo '$'{#$arrayName[@]}`;i++));
	do
		current_post_file=`eval echo '$'{$arrayName[i]}`
		
		if [ ! -f $U_PATH_WIFICFG/$current_post_file ] ;then
			echo "AT_ERROR : post file $U_PATH_WIFICFG/$current_post_file not existed !"
			exit 1
		fi
		
		$U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_WIFICFG/$current_post_file $U_AUTO_CONF_PARAM -l $G_CURRENTLOG/GUI-CHECK-$index
		
		gui_rc=$?
		
		if [ $gui_rc -gt 0 ] ;then
			echo "AT_ERROR : gui checking failed ."
			exit 1
		else
			echo "GUI checking succeed !"
			exit 0
		fi
	done
	}

arrayName="gui_check_post_files1"

if [ "$flag_gui_check" == "1" ] ;then
	do_gui_check
elif [ "$flag_gui_check" == "0" ] ;then
	echo "	no need to do GUI checking ."
	exit 0
fi
