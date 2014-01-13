#!/bin/bash
# print version info
VER="1.0.0"
echo "$0 version : ${VER}"


#tclsh DUTShellCmd.tcl 192.168.0.1 admin QwestM0dem ifconfig |grep -A 1 ppp0|tail -1|awk '{print $2}'|grep -o '[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}'


bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/wan_info.log
awk -F = '{if (/TMP_DUT_WAN_IP/) print $2 }' $G_CURRENTLOG/wan_info.log
exit 0
