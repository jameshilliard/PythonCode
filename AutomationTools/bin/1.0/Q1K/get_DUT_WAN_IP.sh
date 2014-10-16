#!/bin/bash
# print version info
VER="1.0.0"
echo "$0 version : ${VER}"


bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/wan_info.log
cat $G_CURRENTLOG/wan_info.log | grep "TMP_DUT_WAN_IP"
exit 0



#usage="get_DUT_WAN_IP.sh -t <dut ip> -u <dut username> -p <dut password>"
#echo $U_DUT_TYPE
#while [ -n "$1" ];
#do
#    case "$1" in
#
#    -t)
#        dutip=$2
#        echo "dut address : ${dutip}"
#        shift 2
#        ;;
#    -u)
#        usrname=$2
#        echo "dut username : ${usrname}"
#        shift 2
#        ;;
#    -p)
#        psw=$2
#        echo "dut password : ${psw}"
#        shift 2
#        ;;
#    *)
#        echo $usage
#        exit 1
#        ;;
#    esac
#done
#Q1K()
#{
#    tclsh $U_PATH_TBIN/DUTcmd.tcl $dutip $usrname $psw 'wan show' |
#    grep -A 1 address|
#    tail -1|
#    awk '{print $8}'| 
#    awk '{print "TMP_DUT_WAN_IP=" $1}'
#}
#SV1KH()
#{
#    echo "TMP_DUT_WAN_IP=$U_CUSTOM_DUT_WAN_IP TMP_DUT_DEF_GW=$U_CUSTOM_DUT_WAN_GW" 
#}
#
#FGT784WN()
#{
#    tclsh $U_PATH_TBIN/DUTcmd.tcl $dutip $usrname $psw 'wan show' |
#    grep -A 1 address|
#    tail -1|
#    grep -o '[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'| 
#    awk '{print "TMP_DUT_WAN_IP=" $1}'
#}
#TV2KH()
#{
#    echo "TMP_DUT_WAN_IP=$U_CUSTOM_DUT_WAN_IP TMP_DUT_DEF_GW=$U_CUSTOM_DUT_WAN_GW"
#}
#Q2K()
#{
#    tclsh $U_PATH_TBIN/DUTcmd.tcl $dutip $usrname $psw 'wan show' |
#    grep -A 1 address|
#    tail -1|
#    grep -o '[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'| 
#    awk '{print "TMP_DUT_WAN_IP=" $1}'
#}
#$U_DUT_TYPE
