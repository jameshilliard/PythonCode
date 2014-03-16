#!/bin/bash
#---------------------------------
# Name: Alex
# Description: 
#   This script is used to configure tr069 settings based on Q2KH
#
#--------------------------------
# History       :
#   DATE        |   REV     | AUTH      | INFO
#21 Feb 2012    |   1.0.0   | Alex      | Inital Version
#23 Feb 2012    |   1.0.1   | Alex      | force connction request check
#25 Feb 2012    |   1.0.2   | Alex      | add step of capture,and structure adjustment
############################################################################################

REV="$0 version 1.0.2( 25 Feb 2012 )"
# print REV
echo "${REV}"

while [ -n "$1" ];
do
    case "$1" in
    -test)
        mode=test
        echo "mode : test mode"
        U_PATH_TBIN=./
        U_DUT_FW_VERSION=34.20L.0j
        post_file_loc=/root/automation/platform/2.0/Q2KH/config/34.20L.0j/tr069/Precondition/
        G_CURRENTLOG=/dev/shm
        G_PROD_IP_BR0_0_0=192.168.0.1
        U_DUT_TELNET_USER=admin
        U_DUT_TELNET_PWD=QwestM0dem
        U_AUTO_CONF_BIN=playback_http
        U_AUTO_CONF_PARAM="-d 0"
        U_DUT_TYPE=Q2KH
        G_HOST_USR1=root
        G_HOST_PWD1=actiontec
        G_HOST_TIP1_0_0=192.168.100.121
        G_HOST_IF1_1_0=eth1
        shift 1
        ;; 
    esac
done

post_file_loc=$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition
wait_time=15
trytimes=12
cwmpIndex=1

function start_capture
{
    echo "Start to capture on WAN PC..."
    echo "perl $U_PATH_TBIN/clicfg.pl -o 15 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v \"killall -s SIGINT tcpdump\" -v \"rm -rf /tmp/tr69CONF.cap\" -v \"nohup tcpdump -i $G_HOST_IF1_1_0 -s 0 -w /tmp/tr69CONF.cap > /dev/null 2>&1 &\"  -v \"sleep 3\""
    perl $U_PATH_TBIN/clicfg.pl -o 15 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "killall -s SIGINT tcpdump" -v "rm -rf /tmp/tr69CONF.cap" -v "nohup tcpdump -i $G_HOST_IF1_1_0 -s 0 -w /tmp/tr69CONF.cap > /dev/null 2>&1 &"  -v "sleep 3"
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : FAILED to capture on WAN PC!"
        stop_capture_and_exit 1
    fi
}

function stop_capture_and_exit
{
    ret=$1
    echo "Stop capture on WAN PC."
    echo "perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/stop_tshark.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -v \"jobs;killall -s SIGINT tcpdump;sleep 3\" -v \"mv -f /tmp/tr69CONF.cap $G_CURRENTLOG/tr69CONF.cap ; sleep 3\""
    perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/stop_tshark.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -v "jobs;killall -s SIGINT tcpdump;sleep 3" -v "mv -f /tmp/tr69CONF.cap $G_CURRENTLOG/tr69CONF.cap ; sleep 3"

    if [ $? -ne 0 ]; then
        echo "AT_ERROR : FAILED to capture on WAN PC!"
        exit 1
    fi

    exit $ret
}

function get_cwmp
{
    echo "get cwmp info:"
    filename="cwmpInfo.log""_$cwmpIndex"
    let "cwmpIndex=$cwmpIndex+1"
    if [ "$mode" = "test" ]; then   
        echo "bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/$filename -test"
        bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/$filename -test
    else
        echo "bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/$filename"
        bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/$filename
    fi
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : FAILED to execute bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/$filename"
        stop_capture_and_exit 1
    fi
    for line in `cat $G_CURRENTLOG/$filename`
    do
        echo "$line"
        export $line
    done
}

function post_1st_file
{
    #get_cwmp
    echo "GUI setting : set ACS_URL to http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 60 by post file B-GEN-ENV.PRE-DUT.TR069CONF-001-C001"
    $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.TR069CONF-001-C001
    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : FAILED to $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.TR069CONF-001-C001"
        stop_capture_and_exit 1
    fi
}

function check_authorization
{
    echo "Check that ACS_URL has been set to https://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt by Motive"
    get_cwmp_enable=1
    try=0
    while [ $get_cwmp_enable -eq 1 ]
    do
        if [ "$mode" = "test" ]; then    
            bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/cwmpInfo.log -test
        else
            bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/cwmpInfo.log
        fi
        let "try=$try+1"
        if [ $? -ne 0 ]; then
            echo "AT_ERROR : FAILED to execute bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/cwmpInfo.log"
        fi
    
        ACS_URL=`grep "TMP_DUT_CWMP_ACS_URL" $G_CURRENTLOG/cwmpInfo.log | awk -F= '{print $2}'`
        echo "ACS_URL=$ACS_URL"
        head=`echo $ACS_URL | grep -o "https"`
        if [ "$head" = "https" ]; then
            echo "ACS_URL has been changed by Motice"
            get_cwmp_enable=0
        else
            if [ $try -ge $trytimes ]; then
                echo "AT_ERROR : TR069 auto registration failed,exit!"
                stop_capture_and_exit 1
            else
                echo "Waitting for TR069 auto registration..."
                sleep $wait_time
            fi
        fi
    done
}

function post_2nd_file
{
    get_cwmp
    if [ "$U_CUSTOM_CWMP_FORCE_PERIODIC_INFORM" == "0" -a "$U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS" == "$G_HOST_IP1" ] ;then
        echo "GUI setting : set ACS_URL to http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 86400 by post file B-GEN-ENV.PRE-DUT.TR069CONF-001-C003"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.TR069CONF-001-C003
    else
        echo "GUI setting : set ACS_URL to http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 60 by post file B-GEN-ENV.PRE-DUT.TR069CONF-001-C002"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.TR069CONF-001-C002
    fi
    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : FAILED to $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.TR069CONF-001-C002"
        stop_capture_and_exit 1
    fi
}


#main:
start_capture

post_1st_file

check_authorization

post_2nd_file

stop_capture_and_exit 0
