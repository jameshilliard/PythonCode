#!/bin/bash
#
# Author        :   Ares
# Description   :
#   This tool is used to reboot DUT.
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#7 Jun 2012    |   1.0.0    | Ares      | Inital Version  
#

REV="$0 version 1.0.0 (7 Jun 2012)"
# print REV

echo "${REV}"

# USAGE
USAGE()
{
    cat <<usge
USAGE : 

    bash $0 

usge
}

post_file_loc=$G_SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition

pre_reboot(){
    bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 120

    is_dut_wan_ready=$?
}

post_reboot(){
	bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120

	is_dut_avl=$?
	
	if [ $is_dut_avl -gt 0 ] ; then
		echo "AT_ERROR : DUT not available after reboot."
		exit 1
	fi

    if [ $is_dut_wan_ready -eq 0 ] ;then
        bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 600

        is_dut_avl=$?

        if [ $is_dut_avl -gt 0 ] ; then
            echo "AT_ERROR : Can not ping through to WAN after reboot."
            exit 1
        fi
    fi
}

rebootDUT(){

	echo "in function rebootDUT() ..."
	
	echo "	DUT setting on GUI to reboot"
	
	$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.REBOOT-001-C001 $U_AUTO_CONF_PARAM
	
	rc_reset=$?
	
	if [ $rc_reset -gt 0 ] ;then
		echo "AT_ERROR : error occured in reboot DUT on GUI ."
		exit 1
	fi
	
	if [ -z $U_CUSTOM_DUT_REBOOT_TIME ] ;then
		U_CUSTOM_DUT_REBOOT_TIME=60
	fi
	
	echo "sleep $U_CUSTOM_DUT_REBOOT_TIME"
    sleep $U_CUSTOM_DUT_REBOOT_TIME
   
#	bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120
#
#	is_dut_avl=$?
#	
#	if [ $is_dut_avl -gt 0 ] ; then
#		echo "AT_ERROR : DUT not available after reboot."
#		exit 1
#	fi
#
#    bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 120
#
#    is_dut_avl=$?
#
#    if [ $is_dut_avl -gt 0 ] ; then
#        echo "AT_ERROR : Can not ping through to WAN after reboot."
#        exit 1
#    fi
}

pre_reboot

rebootDUT

post_reboot

