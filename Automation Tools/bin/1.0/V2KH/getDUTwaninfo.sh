#!/bin/sh 
# get info by telnet

perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -m ">" -v "route show"  -v "ifconfig" | tee $G_CURRENTLOG/dut_info.log

# remove ^M
dos2unix  $G_CURRENTLOG/dut_info.log
# parse default route info 
dut_wan_if=`awk '{if (/default/) print $8}' $G_CURRENTLOG/dut_info.log`
dut_def_gw=`awk '{if (/default/) print $2}' $G_CURRENTLOG/dut_info.log`
echo "dut_wan_if = $dut_wan_if"
echo "dut_def_gw = $dut_def_gw"

# check wan if
if [ -z $dut_wan_if ]
then
    echo "-| FAIL : DUT WAN IF is empty!\n"
    exit -1
fi

# check default gw
if [ "$dut_def_gw" = "*" ]
then
    #cmd="sed -n '/^$dut_wan_if/{n;p}' $G_CURRENTLOG/dut_info.log|awk '{print $3}'|awk -F: '{print $2}' "
    #echo "cmd = $cmd"
    #echo `sed -n '/^$dut_wan_if/{n;p}' $G_CURRENTLOG/dut_info.log `
    dut_def_gw="`sed -n "/^$dut_wan_if/{n;p}" $G_CURRENTLOG/dut_info.log |awk '{print $3}'|awk -F: '{print $2}'`"
fi

# check default gw again
echo "dut_def_gw = $dut_def_gw"
rc=`echo "$dut_def_gw" | grep  "\."`
if [ -z $rc ]
then
    echo "-| FAIL : DUT default gw failed"
    exit -1
fi

# parse wan ip
dut_wan_ip="`sed -n "/^$dut_wan_if/{n;p}" $G_CURRENTLOG/dut_info.log |awk '{print $2}'|awk -F: '{print $2}'`"
# check wan ip
echo "dut_wan_ip = $dut_wan_ip"
rc=`echo "$dut_wan_ip" | grep  "\."`
if [ -z $rc ]
then
    echo "-| FAIL : DUT WAN IP is error"
    exit -1
fi

# rcfile
rcfile=$1
if [ -z rcfile ]
then
    rcfile=$G_CURRENTLOG/rcfile
fi
# save result to file
echo "TMP_DUT_WAN_IF=$dut_wan_if TMP_DUT_WAN_IP=$dut_wan_ip TMP_DUT_DEF_GW=$dut_def_gw" > $rcfile
exit 0
