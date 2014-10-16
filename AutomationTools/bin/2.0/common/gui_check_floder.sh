#!/bin/bash
echo "get adsl vdsl eth"
bash $U_PATH_TBIN/cli_dut.sh -v wan.link -o $G_CURRENTLOG/cli_dut_wan_connect.log
TMP_DUT_WAN_LINK=`cat $G_CURRENTLOG/cli_dut_wan_connect.log|grep "TMP_DUT_WAN_LINK"|awk -F"=" '{print $2}'`
 echo "TMP_DUT_WAN_LINK=$TMP_DUT_WAN_LINK"
TMP_DUT_WAN_ISP_PROTO=`cat $G_CURRENTLOG/cli_dut_wan_connect.log|grep "TMP_DUT_WAN_ISP_PROTO"|awk -F"=" '{print $2}'`
 echo "TMP_DUT_WAN_ISP_PROTO="$TMP_DUT_WAN_ISP_PROTO""
 
 echo "U_CUSTOM_WAN_IS_STATIC_1=$U_CUSTOM_WAN_IS_STATIC"
if [ "$U_CUSTOM_WAN_IS_STATIC" == "0" ] ;then
	 echo "not static"
	 echo "TMP_DUT_WAN_ISP_PROTO=$TMP_DUT_WAN_ISP_PROTO"
	 echo "TMP_DUT_WAN_LINK=$TMP_DUT_WAN_LINK"
	 echo "U_CUSTOM_GUI_CHECK_PATH="$G_CURRENTLOG/../GUI_CHECK/WAN_CHECK_"$TMP_DUT_WAN_LINK"_"$TMP_DUT_WAN_ISP_PROTO""" >$G_CURRENTLOG/gui_name_check.log 

else 
	 echo "U_CUSTOM_WAN_IS_STATIC_2=$U_CUSTOM_WAN_IS_STATIC"
   if [ "$U_CUSTOM_WAN_IS_STATIC" == "1"  ] ;then
 	echo "static status"
 	echo "TMP_DUT_WAN_LINK=$TMP_DUT_WAN_LINK"
 	echo "U_CUSTOM_GUI_CHECK_PATH="$G_CURRENTLOG/../GUI_CHECK/WAN_CHECK_"$TMP_DUT_WAN_LINK"_STATIC"" >$G_CURRENTLOG/gui_name_check.log 
   else 
	  echo "static status error"
	  exit 1
   fi
fi


