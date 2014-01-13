#!/bin/bash - 
#===============================================================================
#
#          FILE: setup_local_telnet.sh
# 
#         USAGE: ./setup_local_telnet.sh 
# 
#   DESCRIPTION: 
#                GUI setup local telnet 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: rayofox(lhu@actiontec.com) 
#  ORGANIZATION: 
#       CREATED: 11/21/2012 01:21:46 PM CST
#      REVISION:  ---
#===============================================================================


REV="$0 version 1.0.0 (21 Nov 2012)"
echo "${REV}"

########
#
# default value
negtive=0
retry=3
if [ "$U_DUT_TYPE" == "PK5K1A" ];then
    retry=1
fi
if [ "$U_DUT_TYPE" == "WECB" ] || [ "$U_DUT_TYPE" == "NcsWecb3000" ] || [ "$U_DUT_TYPE" == "TelusWecb3000"] || ["$U_DUT_TYPE" == "ComcastWecb3000"] || [ "$U_DUT_TYPE" == "VerizonWecb3000"];then
    for i in `seq 1 $retry`;
    do
         date +%m%d_%H:%M:%S
         $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/telnet_clicmd.log  -y ssh -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "ifconfig" --timeout 60
         rc=$?
         date +%m%d_%H:%M:%S
         if [ "$rc" == "0" ];then
             echo "AT_INFO : ssh is enabled PASS!"
             exit 0
         else
             bash $U_PATH_TBIN/pingcurlwget.sh -w http://${G_PROD_IP_BR0_0_0}/telnetd_start
             rc=$?
             if [ "$rc" == "0" ];then
                 $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/ssh_clicmd.log  -y telnet -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 -v "cli -p Device.X_ACTIONTEC_COM_RemoteLogin.Enable int 1" -v "cli -p Device.X_ACTIONTEC_COM_RemoteLogin.Username string ${U_DUT_TELNET_USER}" -v "cli -p Device.X_ACTIONTEC_COM_RemoteLogin.Password string ${U_DUT_TELNET_PWD}" -v "cli -e Device.X_ACTIONTEC_COM_RemoteLogin" -v "cli -f"
                 rc=$?
                 date +%m%d_%H:%M:%S
                 echo "sleep 60"
                 sleep 60
             else
                 echo "AT_ERROR : wget http://${G_PROD_IP_BR0_0_0}/telnetd_start Fail!"
             fi
         fi
    done
    echo "AT_ERROR : ssh is not enabled!"
    exit 1
fi
delay=30
LOOP_TIME=5
DELAY_EACH_LOOP=10

usage="usage: bash $0 [-n] [-t retry_delay] [-m max_retry]"
while [ -n "$1" ];
do
    case "$1" in
    -t)
        delay=$2
        shift 2
        ;;
    -n)
        negtive=1
        shift 1
        ;;
    -m)
        retry=$2
        shift 2
        ;;
    *)
        echo -e $usage
        exit 1
        ;;
    esac
done




gui_enable_telnet(){
    #
    postfile="$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition/B-GEN-ENV.PRE-DUT.TELNET-001-C001"
    if [ -f "$postfile" ]; then
        echo ""
    else
        postfile="$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/Precondition/B-GEN-ENV.PRE-DUT.TELNET-001-C001"
    fi
    #
    $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile
    rc=$?
}

gui_disable_telnet(){
    #
    LOOP_TIME=1
    postfile="$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition/B-GEN-ENV.PRE-DUT.TELNET-001-C002"
    if [ -f "$postfile" ]; then
        echo ""
    else
        postfile="$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/Precondition/B-GEN-ENV.PRE-DUT.TELNET-001-C002"
    fi
    #
    $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile
    rc=$?
}


loop_until_telnet_open(){
    for ii in `seq $LOOP_TIME`; do
        nmap -sS $G_PROD_IP_BR0_0_0 | grep telnet
        rc=$?
        if [ "$rc" == "0" ]; then
            return
        else
            echo "scan opened telent port failed, retry ..."
            sleep $DELAY_EACH_LOOP
        fi
    done

}

check_telnet_enabled(){
    loop_until_telnet_open
    if [ "$rc" == "0" ]; then
        #perl $U_PATH_TBIN/DUTCmd.pl -o checkTelnet.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT
        echo "To exec : clicmd -y telnet -d  $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -P $U_DUT_TELNET_PORT v 'help'"
        clicmd -y telnet -d  $G_PROD_IP_BR0_0_0 -u "$U_DUT_TELNET_USER" -p "$U_DUT_TELNET_PWD" -P $U_DUT_TELNET_PORT -v 'help'
        
        #echo "To exec : DUTCmd.pl -d  $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v 'help' "
        #DUTCmd.pl -d  $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v 'help'
        rc=$?
        if [ "$rc" == "0" ]; then
            return
        else
            sleep 10
            #echo "Retry exec : clicmd -y telnet -d  $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -P $U_DUT_TELNET_PORT -v 'help'"
            #clicmd -y telnet -d  $G_PROD_IP_BR0_0_0 -u "$U_DUT_TELNET_USER" -p "$U_DUT_TELNET_PWD" -P $U_DUT_TELNET_PORT -v 'help'
            
            
            echo "Retry exec : DUTCmd.pl -d  $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v 'help' "
            DUTCmd.pl -d  $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v 'help'
            rc=$?
        fi
    else
        echo "Scan local telnet failed "
    fi
    
    
}

check_telnet_disabled(){
    check_telnet_enabled
    rc=$?
    if [ "$rc" == "0" ]; then
        rc=1
    else
        rc=0
    fi
}



enable_telnet(){
    gui_enable_telnet
    check_telnet_enabled
}

disable_telnet(){
    gui_disable_telnet
    check_telnet_disabled
}

#
#
# main entry
#

for i in `seq $retry`; do
    if [ "$negtive" == "0" ]; then
        enable_telnet
        if [ "$rc" == "0" ];then
            echo "telnet enabled"
            exit 0
        else
            echo "sleep $delay seconds and retry..."
            sleep $delay
        fi

    else
        disable_telnet
        if [ "$rc" == "0" ];then
            echo "telnet disabled"
            exit 0
        else
            echo "sleep $delay seconds and retry..."
            sleep $delay
        fi
    fi

done

echo "AT_ERROR : GUI setup telnet failed"
if [ "$U_DUT_TYPE" == "PK5K1A" ];then
    rm -rf $G_CURRENTLOG/GUI-CHECK-LOCAL-TELNET
    rm -f $G_CURRENTLOG/setup_local_telnet_debug_info.log
    $U_AUTO_CONF_BIN $U_DUT_TYPE $G_SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/Security/firewall/B-GEN-SEC.FW-001-D001 $U_AUTO_CONF_PARAM -l $G_CURRENTLOG/GUI-CHECK-LOCAL-TELNET
    bash $U_PATH_TBIN/cli_dut.sh -v debug.info -o $G_CURRENTLOG/setup_local_telnet_debug_info.log
fi
exit 1

sss = """
显示行 120 - 144
"""

print(len(sss))
