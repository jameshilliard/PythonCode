#!/bin/bash
#---------------------------------
# Name: Andy
# Description: 
#   This script is used to configure tr069 settings based on FiberTech.
#
#--------------------------------
# History       :
#   DATE        |   REV     | AUTH      | INFO
#27 Feb 2012    |   1.0.0   | Andy      | Inital Version
############################################################################################

REV="$0 version 1.0.0( 27 Feb 2012 )"
# print REV
echo "${REV}"

while [ -n "$1" ];
do
    case "$1" in
    -test)
        mode=test
        echo "mode : test mode"
        U_PATH_TBIN=./
        U_DUT_FW_VERSION=FTH-BHRK2-10-10-08H
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

function cli_1st_setting
{
    echo "CLI setting : set ACS_URL to cli -s Device.ManagementServer.URL string http://iiothdmw13.iot.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 60"
    #perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -o rc_conf.tmp -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "cat /etc/rc.conf" 
    #$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/rc_conf.tmp  -y  telnet -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0  -v "cli -s InternetGatewayDevice.ManagementServer.ConnectionRequestUsername string actiontec" -v "cli -s InternetGatewayDevice.ManagementServer.ConnectionRequestPassword string 760nmary" -v "cli -s InternetGatewayDevice.ManagementServer.PeriodicInformInterval int 60"

  perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#"  -v "cli -s InternetGatewayDevice.ManagementServer.ConnectionRequestUsername string admin" -v "cli -s InternetGatewayDevice.ManagementServer.ConnectionRequestPassword string newVOLUser1" -v "cli -s InternetGatewayDevice.ManagementServer.PeriodicInformInterval int 60"  -v "cli -s InternetGatewayDevice.ManagementServer.URL string http://iiothdmw13.iot.motive.com/cwmpWeb/CPEMgt"  -v "cli -s InternetGatewayDevice.ManagementServer.Username string admin" -v "cli -s InternetGatewayDevice.ManagementServer.Password string newVOLUser1" -v "cli -s InternetGatewayDevice.ManagementServer.ConnectionRequestURL string "" " -t cli_1st_setting.log  -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : FAILED to perl $U_PATH_TBIN/DUTCmd.pl -o cli_1st_set.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -v \"cli -s InternetGatewayDevice.ManagementServer.URL string http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt\" -v \"cli -s InternetGatewayDevice.ManagementServer.PeriodicInformInterval int 60\" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD"
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
        ACS_USR=`grep "ACS_USERNAME" $G_CURRENTLOG/cwmpInfo.log | awk -F= '{print $2}'`
       
        echo "ACS_URL=$ACS_URL"
        echo "ACS_USR=$ACS_USR"
        #head=`echo $ACS_URL | grep -o "https"`
        if [ "$ACS_USR" != "admin" ]; then
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

function cli_2nd_setting
{
    if [ "$U_CUSTOM_CWMP_FORCE_PERIODIC_INFORM" == "0" -a "$U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS" == "$G_HOST_IP1" ] ;then
        echo "CLI setting : set ACS_URL to http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 86400"
        perl $U_PATH_TBIN/DUTCmd.pl -o cli_2nd_setting.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -v "cli -s InternetGatewayDevice.ManagementServer.URL string http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt" -v "cli -s InternetGatewayDevice.ManagementServer.PeriodicInformInterval int 86400" -v "cli -f a b" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD
    else
        echo "CLI setting : set ACS_URL to http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 60"
        perl $U_PATH_TBIN/DUTCmd.pl -o cli_2nd_setting.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -v "cli -s InternetGatewayDevice.ManagementServer.URL string http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt" -v "cli -s InternetGatewayDevice.ManagementServer.PeriodicInformInterval int 60" -v "cli -f a b" -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD
    fi
    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : FAILED to perl $U_PATH_TBIN/DUTCmd.pl -o cli_2nd_setting.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 ..."
        stop_capture_and_exit 1
    fi
}


#main:
start_capture

cli_1st_setting

check_authorization

cli_2nd_setting

stop_capture_and_exit 0
