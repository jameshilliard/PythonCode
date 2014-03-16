#!/bin/bash
keyword=$1
dest_file=$2
#perl $U_PATH_TBIN/searchoperation.pl -e &quot;login to dut passed&quot; -f $G_CURRENTLOG/remote_login_1.log
if [ "$U_DUT_TYPE" == "TV2KH" ];then
    if [ "$U_DUT_SW_VERSION" == "31.30L.48" ];then
        keyword="${U_CUSTOM_REMOTE_GUI_PORT1}/tcp  *open "
    fi
elif [ "$U_DUT_TYPE" == "BAR1KH" ];then
    if [ "$U_DUT_SW_VERSION" == "33.00L.28" ];then
        keyword="${U_CUSTOM_REMOTE_GUI_PORT1}/tcp  *open "
    fi
fi
perl $U_PATH_TBIN/searchoperation.pl -e "$keyword" -f $dest_file
exit $?

